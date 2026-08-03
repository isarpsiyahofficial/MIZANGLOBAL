#!/usr/bin/env python3
"""Static acceptance checks for the fully integrated English locale."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"

text = I18N.read_text(encoding="utf-8")
map_block = text[
    text.index("static const Map<String, String> _english") :
    text.index("static final List<_LocalizedPattern> _patterns")
]
raw_keys = re.findall(r"^\s*'((?:\\.|[^'])*)':", map_block, re.MULTILINE)
keys = {
    value.replace("\\'", "'")
    .replace("\\n", "\n")
    .replace("\\$", "$")
    .replace("\\\\", "\\")
    for value in raw_keys
}

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

failures: list[str] = []
for path in LIB.rglob("*.dart"):
    rel = path.relative_to(ROOT).as_posix()
    if path == I18N or rel in {
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
        "lib/global/global_catalog.dart",
    }:
        continue
    source = path.read_text(encoding="utf-8")
    if rel.startswith(("lib/screens/", "lib/widgets/", "lib/main.dart")):
        if "package:flutter/material.dart" in source:
            failures.append(f"{rel}: raw Material import bypasses localized Text")
    for line_number, line in enumerate(source.splitlines(), 1):
        stripped = line.strip()
        if stripped.startswith(("//", "import ", "export ")):
            continue
        if "tooltip:" in line and re.search(r"tooltip:\s*['\"]", line):
            failures.append(f"{rel}:{line_number}: raw tooltip literal")
        if "dialogTitle:" in line and re.search(r"dialogTitle:\s*['\"]", line):
            failures.append(f"{rel}:{line_number}: raw file-dialog title")
        for match in quoted.finditer(line):
            value = match.group(2).replace("\\'", "'").replace("\\n", "\n")
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
            if value not in keys:
                failures.append(
                    f"{rel}:{line_number}: fixed Turkish copy has no English key: {value!r}"
                )

all_source = "\n".join(
    path.read_text(encoding="utf-8") for path in LIB.rglob("*.dart")
)
for forbidden in (
    "const localizedInputDecoration",
    "throw const FileSystemException(\n        MizanI18n.text",
):
    if forbidden in all_source:
        failures.append(f"forbidden non-constant localization construct: {forbidden}")

if "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT'};" not in text:
    failures.append("Turkish, English, Spanish, Brazilian Portuguese and European Portuguese must be enabled")
if "'ONAYLIYORUM': 'ONAYLIYORUM'" in map_block:
    failures.append("English confirmation copy still leaks the Turkish command")
if "'ONAYLIYORUM': 'I CONFIRM'" not in map_block:
    failures.append("English confirmation command must be I CONFIRM")

main_source = (LIB / "main.dart").read_text(encoding="utf-8")
if "Locale('pt', 'BR')" not in main_source:
    failures.append("MaterialApp must expose Brazilian Portuguese")
picker_source = (LIB / "widgets" / "global_picker_dialog.dart").read_text(
    encoding="utf-8"
)
if "MizanI18n.supportedLanguageTags.contains(item.code)" not in picker_source:
    failures.append("language picker is not restricted to integrated locales")
pdf_source = (LIB / "services" / "pdf_report_service.dart").read_text(
    encoding="utf-8"
)
if (
    pdf_source.count("TextPainter(") != 1
    or "final localizedText = MizanI18n.text(" not in pdf_source
):
    failures.append("all rasterized PDF text must pass through the centralized localizer")
reminder_source = (LIB / "services" / "reminder_engine.dart").read_text(
    encoding="utf-8"
)
if (
    "title: MizanI18n.text(" not in reminder_source
    or "message: MizanI18n.text(" not in reminder_source
):
    failures.append("Android reminder title/body can leak protected markers")
controller_source = (LIB / "controllers" / "mizan_controller.dart").read_text(
    encoding="utf-8"
)
if "MizanI18n.destructiveConfirmation" not in controller_source:
    failures.append("destructive confirmation is not locale-specific in the controller")
expense_source = (LIB / "screens" / "expenses_screen.dart").read_text(
    encoding="utf-8"
)
if "MizanI18n.destructiveConfirmation" not in expense_source:
    failures.append("localized destructive-confirmation validation is missing")

if failures:
    print("English localization validation failed:")
    for failure in failures:
        print(f"- {failure}")
    raise SystemExit(1)
print(f"English localization validation passed: {len(keys)} fixed translations checked.")
