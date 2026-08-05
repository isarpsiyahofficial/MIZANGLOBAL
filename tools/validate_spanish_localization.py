#!/usr/bin/env python3
"""Static acceptance checks for the fully integrated native-level Spanish locale."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
SPANISH = LIB / "l10n" / "mizan_es.dart"


def decode_dart(value: str) -> str:
    return (
        value.replace(r"\'", "'")
        .replace(r"\n", "\n")
        .replace(r"\$", "$")
        .replace(r"\\", "\\")
    )


def parse_map(source: str, start: str, end: str) -> dict[str, str]:
    block = source[source.index(start) : source.index(end, source.index(start))]
    pattern = re.compile(
        r"^\s*'((?:\\.|[^'])*)':\s*'((?:\\.|[^'])*)',\s*$",
        re.MULTILINE,
    )
    return {decode_dart(key): decode_dart(value) for key, value in pattern.findall(block)}


failures: list[str] = []
i18n_text = I18N.read_text(encoding="utf-8")
spanish_text = SPANISH.read_text(encoding="utf-8")
english = parse_map(
    i18n_text,
    "static const Map<String, String> _english",
    "static final List<_LocalizedPattern> _patterns",
)
spanish = parse_map(
    spanish_text,
    "const Map<String, String> mizanSpanish",
    "String translateSpanishDynamic",
)

if len(english) != 791:
    failures.append(f"English reference map changed unexpectedly: {len(english)} keys")
if len(spanish) != 791:
    failures.append(
        f"Spanish map must contain exactly 791 fixed translations, found {len(spanish)}"
    )
if set(spanish) != set(english):
    missing = sorted(set(english) - set(spanish))[:10]
    extra = sorted(set(spanish) - set(english))[:10]
    failures.append(f"Spanish/English key mismatch; missing={missing}, extra={extra}")

required_copy = {
    "Ana sayfa": "Inicio",
    "Kayıtlar": "Registros",
    "Giderler": "Gastos",
    "Raporlar": "Informes",
    "Ayarlar": "Ajustes",
    "MİZAN Aylık Raporu": "Informe mensual de MİZAN",
    "Son ödeme tarihi": "Fecha de vencimiento",
    "Kalan tutar": "Importe pendiente",
    "Kalan ödeme yükü": "Obligaciones de pago pendientes",
    "Gerçekleşen ödeme ayrıntıları": "Detalles de pagos registrados",
    "Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.": "Debes escribir CONFIRMO exactamente para eliminar la categoría.",
    "ONAYLIYORUM": "CONFIRMO",
    "CSV yedeğini dışa aktar": "Exportar copia de seguridad CSV",
    "PDF raporu": "Informe PDF",
}
for key, expected in required_copy.items():
    if spanish.get(key) != expected:
        failures.append(
            f"native Spanish copy mismatch for {key!r}: {spanish.get(key)!r}"
        )

allowed_identical = {
    "MİZAN GLOBAL",
    "IBAN",
    "Mar",
    "May",
    "LEFFERION PRIME - MIZAN",
}
for key, value in spanish.items():
    if not value.strip():
        failures.append(f"empty Spanish value: {key!r}")
    if value == key and key not in allowed_identical:
        failures.append(f"untranslated Turkish value: {key!r}")

forbidden_english = (
    "Home",
    "Records",
    "Expenses",
    "Reports",
    "Settings",
    "Add person",
    "Add expense",
    "Monthly",
    "Remaining amount",
    "Due date",
    "I CONFIRM",
    "No matching results",
    "Payment reminders",
    "Report summary",
)
for key, value in spanish.items():
    for phrase in forbidden_english:
        if phrase.casefold() in value.casefold():
            failures.append(f"English leakage in {key!r}: {phrase!r}")

forbidden_turkish_words = re.compile(
    r"\b(?:ana sayfa|kayıtlar|giderler|raporlar|ayarlar|ödeme|borç|fatura|"
    r"kira|taksit|bildirim|hatırlatma|kalan tutar|son ödeme|kişi ekle|"
    r"gider ekle|onaylıyorum)\b",
    re.IGNORECASE,
)
for key, value in spanish.items():
    if forbidden_turkish_words.search(value):
        failures.append(f"Turkish leakage in Spanish value for {key!r}: {value!r}")

if (
    "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT'};"
    not in i18n_text
):
    failures.append("supported locales must include tr/en/es/pt-BR/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT/pt-PT")
if "'es' => 'CONFIRMO'" not in i18n_text:
    failures.append("Spanish destructive confirmation command is missing")
if not re.search(r"result\s*=\s*mizanSpanish\[visibleSource\]", i18n_text):
    failures.append("Spanish fixed-copy map is not connected to the runtime localizer")
if "translateSpanishDynamic(" not in i18n_text:
    failures.append("Spanish dynamic-copy localizer is not connected")

main_source = (LIB / "main.dart").read_text(encoding="utf-8")
if "Locale('pt', 'BR')" not in main_source:
    failures.append("MaterialApp must expose Brazilian Portuguese")
if "class MizanApp extends StatefulWidget" not in main_source:
    failures.append("MizanApp must own a restartable state boundary")
if "key: ValueKey<int>(_restartGeneration)" not in main_source:
    failures.append("language changes must replace the complete MaterialApp tree")
if "controller.onLanguageChanged = _restartAfterLanguageChange" not in main_source:
    failures.append("MizanApp is not connected to the saved-language restart signal")

for surface in [
    LIB / "main.dart",
    *sorted((LIB / "screens").glob("*.dart")),
    *sorted((LIB / "widgets").glob("*.dart")),
]:
    source = surface.read_text(encoding="utf-8")
    if "package:flutter/material.dart" in source:
        failures.append(
            f"{surface.relative_to(ROOT)} bypasses the localized Material/Text layer"
        )
    if "material.Text(" in source:
        failures.append(
            f"{surface.relative_to(ROOT)} renders system copy outside the localized Text layer"
        )

# Every fixed Turkish UI literal used by the app must have both English and Spanish keys.
quoted = re.compile(r"(?<![A-Za-z0-9_])(?:r)?(['\"])(.*?)(?<!\\)\1")
turkish_chars = re.compile(r"[çğıöşüÇĞİÖŞÜ]")
turkish_words = re.compile(
    r"\b(?:ve|veya|için|bu|ile|kayıt|ödeme|gider|borç|fatura|kira|taksit|"
    r"kişi|gelir|bildirim|hatırlatma|rapor|seç|ekle|sil|düzenle|açık|kapalı|"
    r"tarih|tutar|kalan|gecik|vade|ay|gün|yıl|toplam|not|başlık|açıklama|"
    r"kurum|banka|abonelik|ayar|doğrulama|başlangıç|son|önümüzdeki|bugün)\b",
    re.IGNORECASE,
)
localized_formatter_literals = {"março"}
for path in LIB.rglob("*.dart"):
    rel = path.relative_to(ROOT).as_posix()
    if rel in {
        "lib/l10n/mizan_i18n.dart",
        "lib/l10n/mizan_es.dart",
        "lib/l10n/mizan_pt_br.dart",
        "lib/l10n/mizan_pt_br_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/l10n/mizan_pt_pt.dart",
        "lib/l10n/mizan_pt_pt_dynamic.dart",
        "lib/global/global_catalog.dart",
    }:
        continue
    for line_number, line in enumerate(
        path.read_text(encoding="utf-8").splitlines(), 1
    ):
        stripped = line.strip()
        if stripped.startswith(("//", "import ", "export ")):
            continue
        for match in quoted.finditer(line):
            value = match.group(2).replace(r"\'", "'").replace(r"\n", "\n")
            if (
                not value
                or len(value) == 1
                or value == "RAPOR"
                or "$" in value
                or "\\" in value
            ):
                continue
            if (
                rel == "lib/core/formatters.dart"
                and value in localized_formatter_literals
            ):
                continue
            if not (turkish_chars.search(value) or turkish_words.search(value)):
                continue
            if value not in spanish:
                failures.append(
                    f"{rel}:{line_number}: fixed Turkish copy has no Spanish key: {value!r}"
                )

for file_name, expected_count in (
    ("languages_v1.json", 29),
    ("countries_v1.json", 161),
    ("currencies_v1.json", 154),
):
    payload = json.loads(
        (ROOT / "assets" / "data" / file_name).read_text(encoding="utf-8")
    )
    items = payload.get("items", [])
    if len(items) != expected_count:
        failures.append(
            f"{file_name}: expected {expected_count} items, found {len(items)}"
        )
    for item in items:
        if not str(item.get("nameEs", "")).strip():
            failures.append(f"{file_name}: missing nameEs for {item.get('code')}")

currencies = json.loads(
    (ROOT / "assets" / "data" / "currencies_v1.json").read_text(
        encoding="utf-8"
    )
)["items"]
usd = next(item for item in currencies if item["code"] == "USD")
if (
    usd.get("nameEs") != "dólar estadounidense"
    or "dólar estadounidense" not in usd.get("aliases", [])
):
    failures.append("USD Spanish name/search alias is incomplete")

catalog_source = (LIB / "global" / "global_catalog.dart").read_text(
    encoding="utf-8"
)
if catalog_source.count("'es' => nameEs") != 3:
    failures.append("language/country/currency catalog entries must all render nameEs")
for screen in (
    LIB / "screens" / "global_setup_screen.dart",
    LIB / "screens" / "settings_screen.dart",
    LIB / "widgets" / "global_picker_dialog.dart",
):
    if "nameFor(MizanI18n.languageTag)" not in screen.read_text(encoding="utf-8"):
        failures.append(
            f"{screen.relative_to(ROOT)} does not render localized catalog names"
        )

controller_source = (LIB / "controllers" / "mizan_controller.dart").read_text(
    encoding="utf-8"
)
expense_source = (LIB / "screens" / "expenses_screen.dart").read_text(
    encoding="utf-8"
)
if "MizanI18n.destructiveConfirmation" not in controller_source:
    failures.append("controller does not enforce the Spanish confirmation command")
if "MizanI18n.destructiveConfirmation" not in expense_source:
    failures.append("expense screen does not display the Spanish confirmation command")
if "VoidCallback? onLanguageChanged;" not in controller_source:
    failures.append("controller language restart signal is missing")
commit_position = controller_source.find(
    "await _commit(", controller_source.find("Future<void> updateGlobalPreferences")
)
restart_position = controller_source.find("onLanguageChanged?.call();", commit_position)
if commit_position < 0 or restart_position < commit_position:
    failures.append(
        "language restart must be signaled only after the durable preference commit"
    )

# Native-language grammar gates for singular/plural and financial terminology.
for required in (
    "'Queda', 'Quedan'",
    "'falta', 'faltan'",
    "'seleccionada', 'seleccionadas'",
    "'Se añadió', 'Se añadieron'",
    "'No se pudo escribir', 'No se pudieron escribir'",
    "Importe pendiente",
    "Fecha de vencimiento",
    "Obligaciones de pago pendientes",
    "Pago registrado",
):
    if required not in spanish_text:
        failures.append(f"Spanish native-language gate is missing: {required}")

if failures:
    print("Spanish localization validation failed:")
    for failure in failures:
        print(f"- {failure}")
    raise SystemExit(1)
print(
    f"Spanish localization validation passed: {len(spanish)} fixed translations, "
    "dynamic grammar, catalogs and runtime wiring checked."
)
