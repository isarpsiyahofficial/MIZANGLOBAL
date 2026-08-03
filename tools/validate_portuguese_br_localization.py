#!/usr/bin/env python3
"""Static acceptance checks for the fully integrated Brazilian Portuguese locale."""
from __future__ import annotations

import json
import re
from pathlib import Path

from generate_pt_br_localization_draft import (
    ENGLISH_MARKER,
    PORTUGUESE_MARKER,
    _parse_map,
    _parse_output_map,
)

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n/mizan_i18n.dart"
PORTUGUESE = LIB / "l10n/mizan_pt_br.dart"
DYNAMIC = LIB / "l10n/mizan_pt_br_dynamic.dart"
PATCH_DIR = ROOT / "tools/pt_br_review"

failures: list[str] = []

i18n_text = I18N.read_text(encoding="utf-8")
portuguese_text = PORTUGUESE.read_text(encoding="utf-8")
dynamic_text = DYNAMIC.read_text(encoding="utf-8")
english_pairs = _parse_map(i18n_text, ENGLISH_MARKER)
portuguese_pairs = _parse_output_map(portuguese_text)
english = dict(english_pairs)
portuguese = dict(portuguese_pairs)

if len(english_pairs) != 791:
    failures.append(f"English reference map changed unexpectedly: {len(english_pairs)} keys")
if len(portuguese_pairs) != 791:
    failures.append(
        f"Brazilian Portuguese map must contain exactly 791 fixed translations, found {len(portuguese_pairs)}"
    )
if set(portuguese) != set(english):
    missing = sorted(set(english) - set(portuguese))[:10]
    extra = sorted(set(portuguese) - set(english))[:10]
    failures.append(f"pt-BR/English key mismatch; missing={missing}, extra={extra}")

reviewed: dict[str, str] = {}
for patch_file in sorted(PATCH_DIR.glob("*.json")):
    payload = json.loads(patch_file.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        failures.append(f"review patch is not an object: {patch_file.name}")
        continue
    for key, value in payload.items():
        if key in reviewed:
            failures.append(f"duplicate reviewed key: {key!r}")
        reviewed[key] = value
if len(reviewed) != 791 or set(reviewed) != set(english):
    failures.append(
        f"native review patches must cover all 791 keys exactly, found {len(reviewed)}"
    )
for key, value in portuguese.items():
    if not value.strip():
        failures.append(f"empty pt-BR value: {key!r}")
    if reviewed.get(key) != value:
        failures.append(f"runtime pt-BR value differs from reviewed value: {key!r}")

required_copy = {
    "Ana sayfa": "Início",
    "Kayıtlar": "Registros",
    "Giderler": "Despesas",
    "Raporlar": "Relatórios",
    "Ayarlar": "Configurações",
    "MİZAN Aylık Raporu": "Relatório mensal do MİZAN",
    "Son ödeme tarihi": "Data de vencimento",
    "Kalan tutar": "Valor restante",
    "Kalan ödeme yükü": "Obrigações de pagamento restantes",
    "Gerçekleşen ödeme ayrıntıları": "Detalhes dos pagamentos realizados",
    "Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.": "Para excluir a categoria, digite exatamente CONFIRMO.",
    "ONAYLIYORUM": "CONFIRMO",
    "CSV yedeğini dışa aktar": "Exportar backup CSV",
    "PDF raporu": "Relatório PDF",
    "Uygulama dili": "Idioma do aplicativo",
    "Ülke / borç bölgesi": "País / Região da dívida",
    "Varsayılan para birimi": "Moeda padrão",
}
for key, expected in required_copy.items():
    if portuguese.get(key) != expected:
        failures.append(
            f"reviewed Brazilian Portuguese copy mismatch for {key!r}: {portuguese.get(key)!r}"
        )

forbidden_english = (
    "Home",
    "Records",
    "Expenses",
    "Reports",
    "Settings",
    "Add person",
    "Add expense",
    "Monthly report",
    "Remaining amount",
    "Due date",
    "I CONFIRM",
    "No matching results",
    "Payment reminders",
    "Report summary",
)
for key, value in portuguese.items():
    for phrase in forbidden_english:
        if phrase.casefold() in value.casefold():
            failures.append(f"English leakage in pt-BR value for {key!r}: {phrase!r}")

forbidden_turkish = re.compile(
    r"\b(?:ana sayfa|kayıtlar|giderler|raporlar|ayarlar|ödeme|borç|fatura|"
    r"kira|taksit|bildirim|hatırlatma|kalan tutar|son ödeme|kişi ekle|"
    r"gider ekle|onaylıyorum|kaydet|vazgeç|sil|düzenle)\b",
    re.IGNORECASE,
)
for key, value in portuguese.items():
    if forbidden_turkish.search(value):
        failures.append(f"Turkish leakage in pt-BR value for {key!r}: {value!r}")

for forbidden_spanish in (
    "Ajustes",
    "Informe mensual",
    "Fecha de vencimiento",
    "Importe pendiente",
    "Añadir persona",
    "Añadir gasto",
    "Debes escribir CONFIRMO",
    "copia de seguridad CSV",
):
    for key, value in portuguese.items():
        if forbidden_spanish.casefold() in value.casefold():
            failures.append(
                f"Spanish leakage in pt-BR value for {key!r}: {forbidden_spanish!r}"
            )

runtime_requirements = (
    "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro'};",
    "static bool get isPortugueseBr => _languageTag == 'pt-BR';",
    "'pt-BR' => 'CONFIRMO'",
    "if (normalized == 'pt-br') return 'pt-BR';",
    "normalized == 'pt-br'",
    "mizanPortugueseBr[visibleSource]",
    "translatePortugueseBrReviewedDynamic(",
    "languageTag: 'pt-BR'",
)
for requirement in runtime_requirements:
    if requirement not in i18n_text:
        failures.append(f"pt-BR runtime wiring is missing: {requirement}")
if "normalized.startsWith('pt-')" in i18n_text:
    failures.append("generic Portuguese variants must not be accepted as Brazilian Portuguese")

main_source = (LIB / "main.dart").read_text(encoding="utf-8")
if "const Locale('pt', 'BR')" not in main_source:
    failures.append("MaterialApp locale must use the explicit pt-BR region")
if main_source.count("Locale('pt', 'BR')") < 2:
    failures.append("pt-BR must be used for both active locale and supported locales")

catalog_expectations = (
    ("languages_v1.json", 29),
    ("countries_v1.json", 161),
    ("currencies_v1.json", 154),
)
loaded_catalogs: dict[str, list[dict[str, object]]] = {}
for file_name, expected_count in catalog_expectations:
    payload = json.loads((ROOT / "assets/data" / file_name).read_text(encoding="utf-8"))
    items = payload.get("items", [])
    loaded_catalogs[file_name] = items
    if payload.get("count") != expected_count or len(items) != expected_count:
        failures.append(
            f"{file_name}: expected {expected_count} items, found count={payload.get('count')} items={len(items)}"
        )
    for item in items:
        if not str(item.get("namePtBr", "")).strip():
            failures.append(f"{file_name}: missing namePtBr for {item.get('code')}")

currencies = loaded_catalogs.get("currencies_v1.json", [])
usd = next((item for item in currencies if item.get("code") == "USD"), None)
brl = next((item for item in currencies if item.get("code") == "BRL"), None)
if not usd or usd.get("namePtBr") != "dólar americano":
    failures.append("USD Brazilian Portuguese name must be dólar americano")
elif "dólar americano" not in usd.get("aliases", []):
    failures.append("USD Brazilian Portuguese search alias is missing")
if not brl or brl.get("namePtBr") != "real brasileiro":
    failures.append("BRL Brazilian Portuguese name must be real brasileiro")

catalog_source = (LIB / "global/global_catalog.dart").read_text(encoding="utf-8")
if catalog_source.count("'pt-BR' => namePtBr") != 3:
    failures.append("language/country/currency catalog entries must all render namePtBr")
if catalog_source.count("final String namePtBr;") != 3:
    failures.append("all three catalog option types must store namePtBr")

picker_source = (LIB / "widgets/global_picker_dialog.dart").read_text(encoding="utf-8")
if ".nativeName" in picker_source:
    failures.append("picker rows must not display native names")
if picker_source.count("nameFor(MizanI18n.languageTag)") < 3:
    failures.append("all picker rows must render only the selected-language name")
if picker_source.count("matches: (item, query) => item.matches(query)") != 2:
    failures.append("language and country picker searches must retain multilingual aliases")
if "matches: (item, query) => catalog.currencyMatches(item, query)" not in picker_source:
    failures.append(
        "currency picker must retain multilingual aliases while prioritizing exact ISO codes"
    )

formatter_source = (LIB / "core/formatters.dart").read_text(encoding="utf-8")
for requirement in (
    "MizanI18n.isPortugueseBr && code == 'BRL'",
    "return 'R\\$ $amount';",
    "const ptBrMonths = [",
    "'fev'",
    "'set'",
    "'dez'",
    "'janeiro'",
    "'fevereiro'",
    "'dezembro'",
    "MizanI18n.isPortugueseBr",
    "de ${value.year}",
):
    if requirement not in formatter_source:
        failures.append(f"pt-BR formatter gate is missing: {requirement}")

for requirement in (
    "translatePortugueseBrReviewedDynamic",
    "String _count(",
    "'dia', 'dias'",
    "'registro', 'registros'",
    "'pagamento', 'pagamentos'",
    "'despesa', 'despesas'",
    "Faltam",
    "em atraso",
    "Não foi possível",
    "CONFIRMO",
):
    if requirement not in dynamic_text and requirement != "CONFIRMO":
        failures.append(f"pt-BR dynamic grammar gate is missing: {requirement}")

controller_source = (LIB / "controllers/mizan_controller.dart").read_text(encoding="utf-8")
if "MizanI18n.destructiveConfirmation" not in controller_source:
    failures.append("controller must enforce the locale-specific destructive command")
if "VoidCallback? onLanguageChanged;" not in controller_source:
    failures.append("controller language restart signal is missing")
commit_position = controller_source.find(
    "await _commit(", controller_source.find("Future<void> updateGlobalPreferences")
)
restart_position = controller_source.find("onLanguageChanged?.call();", commit_position)
if commit_position < 0 or restart_position < commit_position:
    failures.append("language restart must occur only after durable preference storage")

if failures:
    print("Brazilian Portuguese localization validation failed:")
    for failure in failures:
        print(f"- {failure}")
    raise SystemExit(1)
print(
    "Brazilian Portuguese localization validation passed: 791/791 reviewed static "
    "translations, dynamic grammar, catalogs, formatters, picker purity and runtime wiring checked."
)
