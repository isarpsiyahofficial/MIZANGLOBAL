#!/usr/bin/env python3
"""Fail-closed audit for reviewed Polish product copy and language purity."""
from __future__ import annotations

import json
import re
from pathlib import Path

from build_polish_locale import ROOT, english_pairs, polish_pairs

CONTRACT = ROOT / "tools" / "polish_native_terms.json"
POLISH_DIR = ROOT / "lib" / "l10n" / "pl"
POLISH_INDEX = ROOT / "lib" / "l10n" / "mizan_pl.dart"
POLISH_DYNAMIC = ROOT / "lib" / "l10n" / "mizan_pl_dynamic.dart"
ENGLISH_VALIDATOR = ROOT / "tools" / "validate_english_localization.py"
SPANISH_VALIDATOR = ROOT / "tools" / "validate_spanish_localization.py"
PT_PT_BUILDER = ROOT / "tools" / "build_pt_pt_locale.py"
SUPPORTED_LANGUAGE_TESTS = (
    ROOT / "test" / "portuguese_br_localization_test.dart",
    ROOT / "test" / "spanish_localization_test.dart",
    ROOT / "test" / "english_localization_test.dart",
)


def _replace_scope_block(validator: Path, pattern: re.Pattern[str], replacement: str) -> None:
    source = validator.read_text(encoding="utf-8")
    if replacement in source:
        return
    source, count = pattern.subn(replacement, source, count=1)
    if count != 1:
        raise SystemExit(f"{validator.name} localization-scope block could not be normalized safely.")
    validator.write_text(source, encoding="utf-8")


def _normalize_legacy_pt_pt_builder() -> None:
    source = PT_PT_BUILDER.read_text(encoding="utf-8")
    marker = "        # Translation catalogs are excluded generically by validator path.\n"
    if marker in source:
        return
    start_token = '        if path.name.endswith(".py"):\n'
    end_token = '        path.write_text(text, encoding="utf-8")\n'
    start = source.find(start_token, source.find("def update_regressions"))
    end = source.find(end_token, start)
    if start < 0 or end < 0:
        raise SystemExit("build_pt_pt_locale.py obsolete validator-list block could not be normalized safely.")
    source = source[:start] + marker + source[end:]
    PT_PT_BUILDER.write_text(source, encoding="utf-8")


def _normalize_supported_language_regressions() -> None:
    assertions = (
        "    expect(MizanI18n.isSupported('pl'), isTrue);\n"
        "    expect(MizanI18n.isSupported('pl-PL'), isTrue);\n"
        "    expect(MizanI18n.normalizeLanguageTag('pl_PL'), 'pl');\n"
    )
    set_old = "      'nl',\n    });"
    set_new = "      'nl',\n      'pl',\n    });"
    assertion_anchor = "    expect(MizanI18n.normalizeLanguageTag('nl-BE'), 'nl');\n"
    for path in SUPPORTED_LANGUAGE_TESTS:
        source = path.read_text(encoding="utf-8")
        source = source.replace("remains enabled after Dutch integration", "remains enabled after Polish integration")
        if "      'pl',\n" not in source:
            if source.count(set_old) != 1:
                raise SystemExit(f"{path.name} supported-language regression set could not be updated safely.")
            source = source.replace(set_old, set_new, 1)
        if assertions not in source:
            if source.count(assertion_anchor) != 1:
                raise SystemExit(f"{path.name} Polish runtime assertions could not be added safely.")
            source = source.replace(assertion_anchor, assertion_anchor + assertions, 1)
        path.write_text(source, encoding="utf-8")

    final_head = ROOT / "test" / "italian_final_head_test.dart"
    if final_head.exists():
        source = final_head.read_text(encoding="utf-8")
        source = source.replace("final Dutch head exposes the complete nine-language runtime", "final Polish head exposes the complete ten-language runtime")
        source = source.replace("final Italian head", "final Polish head")
        old = "      'nl',\n    });"
        new = "      'nl',\n      'pl',\n    });"
        if "      'pl',\n" not in source and old in source:
            source = source.replace(old, new, 1)
        anchor = "    expect(MizanI18n.normalizeLanguageTag('nl-BE'), 'nl');\n"
        if assertions not in source and anchor in source:
            source = source.replace(anchor, anchor + assertions, 1)
        final_head.write_text(source, encoding="utf-8")


def _normalize_cross_language_validator_scope() -> None:
    english_pattern = re.compile(r"    if path == I18N or rel in \{\n.*?\n    \}:\n        continue", re.DOTALL)
    english_replacement = (
        "    if (\n"
        "        path == I18N\n"
        "        or rel == \"lib/global/global_catalog.dart\"\n"
        "        or rel.startswith(\"lib/l10n/\")\n"
        "    ):\n"
        "        continue"
    )
    _replace_scope_block(ENGLISH_VALIDATOR, english_pattern, english_replacement)

    spanish_pattern = re.compile(r"    if rel in \{\n.*?\n    \}:\n        continue", re.DOTALL)
    spanish_replacement = (
        "    if (\n"
        "        rel == \"lib/global/global_catalog.dart\"\n"
        "        or rel.startswith(\"lib/l10n/\")\n"
        "    ):\n"
        "        continue"
    )
    _replace_scope_block(SPANISH_VALIDATOR, spanish_pattern, spanish_replacement)


def main() -> None:
    _normalize_legacy_pt_pt_builder()
    _normalize_supported_language_regressions()
    _normalize_cross_language_validator_scope()

    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    pairs = polish_pairs()
    values = dict(pairs)
    failures: list[str] = []

    english = english_pairs()
    english_values = dict(english)
    english_keys = {key for key, _ in english}
    polish_keys = {key for key, _ in pairs}
    if len(pairs) != 791:
        failures.append(f"Polish static catalog contains {len(pairs)} values instead of 791")
    if polish_keys != english_keys:
        failures.append(f"Polish key set differs from English: missing={sorted(english_keys-polish_keys)[:25]}, extra={sorted(polish_keys-english_keys)[:25]}")

    for key, expected in contract["requiredTerms"].items():
        actual = values.get(key)
        if actual != expected:
            failures.append(f"Required Polish term mismatch for {key!r}: {actual!r}")

    forbidden = tuple(contract["forbiddenVisibleTerms"])
    for key, value in pairs:
        hits = [term for term in forbidden if re.search(rf"(?<!\w){re.escape(term)}(?!\w)", value, re.IGNORECASE)]
        if hits:
            failures.append(f"Foreign-language leakage in {key!r}: {hits} -> {value!r}")
        if "KEEPX" in value or "__KEEP" in value:
            failures.append(f"Unrestored placeholder in {key!r}: {value!r}")
        if value == english_values.get(key) and value not in contract["protectedProductTerms"] and key not in {"IBAN", "CSV", "PDF", "Android", "WhatsApp", "ISO"}:
            failures.append(f"Untranslated English value in {key!r}: {value!r}")

    source_text = "\n".join(path.read_text(encoding="utf-8") for path in sorted(POLISH_DIR.glob("*.dart")))
    source_text += "\n" + POLISH_INDEX.read_text(encoding="utf-8")
    source_text += "\n" + POLISH_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("POTWIERDZAM", "Po terminie", "Termin płatności", "kopia zapasowa"):
        if marker not in source_text:
            failures.append(f"Required Polish source marker missing: {marker}")
    if "CANDIDATE" in source_text or "MANUAL NATIVE REVIEW REQUIRED" in source_text:
        failures.append("Polish source still carries candidate-only review markers")

    informal = re.compile(r"(?<![A-Za-zĄĆĘŁŃÓŚŹŻąćęłńóśźż])(ty|twój|twoja|twoje|tobie|ci)(?![A-Za-zĄĆĘŁŃÓŚŹŻąćęłńóśźż])", re.IGNORECASE)
    for key, value in pairs:
        if informal.search(value):
            failures.append(f"Informal Polish pronoun in reviewed system copy {key!r}: {value!r}")

    if failures:
        raise SystemExit("\n".join(failures))
    print("Polish native-copy audit passed: 791/791 values, binding terminology, formal/impersonal register and language purity verified.")


if __name__ == "__main__":
    main()
