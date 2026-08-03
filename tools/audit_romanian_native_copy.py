#!/usr/bin/env python3
"""Fail-closed audit for reviewed Romanian product copy and language purity."""
from __future__ import annotations

import json
import re
from pathlib import Path

from build_romanian_locale import ROOT, english_pairs, romanian_pairs

CONTRACT = ROOT / "tools" / "romanian_native_terms.json"
ROMANIAN_DIR = ROOT / "lib" / "l10n" / "ro"
ROMANIAN_INDEX = ROOT / "lib" / "l10n" / "mizan_ro.dart"
ROMANIAN_DYNAMIC = ROOT / "lib" / "l10n" / "mizan_ro_dynamic.dart"
SUPPORTED_LANGUAGE_TESTS = (
    ROOT / "test" / "portuguese_br_localization_test.dart",
    ROOT / "test" / "spanish_localization_test.dart",
    ROOT / "test" / "english_localization_test.dart",
)


def _normalize_supported_language_regressions() -> None:
    assertions = (
        "    expect(MizanI18n.isSupported('ro'), isTrue);\n"
        "    expect(MizanI18n.isSupported('ro-RO'), isTrue);\n"
        "    expect(MizanI18n.normalizeLanguageTag('ro_RO'), 'ro');\n"
    )
    set_old = "      'pl',\n    });"
    set_new = "      'pl',\n      'ro',\n    });"
    assertion_anchor = "    expect(MizanI18n.normalizeLanguageTag('pl_PL'), 'pl');\n"
    for path in SUPPORTED_LANGUAGE_TESTS:
        source = path.read_text(encoding="utf-8")
        source = source.replace(
            "remains enabled after Polish integration",
            "remains enabled after Romanian integration",
        )
        if "      'ro',\n" not in source:
            if source.count(set_old) != 1:
                raise SystemExit(
                    f"{path.name} supported-language set could not be updated safely."
                )
            source = source.replace(set_old, set_new, 1)
        if assertions not in source:
            if source.count(assertion_anchor) != 1:
                raise SystemExit(
                    f"{path.name} Romanian runtime assertions could not be added safely."
                )
            source = source.replace(assertion_anchor, assertion_anchor + assertions, 1)
        path.write_text(source, encoding="utf-8")

    final_head = ROOT / "test" / "italian_final_head_test.dart"
    if final_head.exists():
        source = final_head.read_text(encoding="utf-8")
        source = source.replace(
            "final Polish head exposes the complete ten-language runtime",
            "final Romanian head exposes the complete eleven-language runtime",
        )
        source = source.replace("final Polish head", "final Romanian head")
        if "      'ro',\n" not in source and set_old in source:
            source = source.replace(set_old, set_new, 1)
        if assertions not in source and assertion_anchor in source:
            source = source.replace(assertion_anchor, assertion_anchor + assertions, 1)
        final_head.write_text(source, encoding="utf-8")


def main() -> None:
    _normalize_supported_language_regressions()
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    pairs = romanian_pairs()
    values = dict(pairs)
    failures: list[str] = []

    english = english_pairs()
    english_values = dict(english)
    english_keys = {key for key, _ in english}
    romanian_keys = {key for key, _ in pairs}
    if len(pairs) != 791:
        failures.append(
            f"Romanian static catalog contains {len(pairs)} values instead of 791"
        )
    if romanian_keys != english_keys:
        failures.append(
            "Romanian key set differs from English: "
            f"missing={sorted(english_keys-romanian_keys)[:25]}, "
            f"extra={sorted(romanian_keys-english_keys)[:25]}"
        )

    for key, expected in contract["requiredTerms"].items():
        actual = values.get(key)
        if actual != expected:
            failures.append(f"Required Romanian term mismatch for {key!r}: {actual!r}")

    forbidden = tuple(contract["forbiddenVisibleTerms"])
    protected_exact = {
        "MİZAN",
        "MİZAN GLOBAL",
        "LEFFERION PRIME",
        "Android",
        "CSV",
        "PDF",
        "WhatsApp",
        "IBAN",
        "ISO",
        "Internet",
        "TRY",
        "RON",
        "USD",
        "EUR",
    }
    for key, value in pairs:
        hits = [
            term
            for term in forbidden
            if re.search(rf"(?<!\w){re.escape(term)}(?!\w)", value, re.IGNORECASE)
        ]
        if hits:
            failures.append(
                f"Foreign-language leakage in {key!r}: {hits} -> {value!r}"
            )
        if "KEEPX" in value or "__KEEP" in value:
            failures.append(f"Unrestored placeholder in {key!r}: {value!r}")
        if (
            value == english_values.get(key)
            and value not in protected_exact
            and key not in protected_exact
            and not re.fullmatch(r"[A-Z0-9 ._/:+%®©-]+", value)
        ):
            failures.append(f"Untranslated English value in {key!r}: {value!r}")

    source_text = "\n".join(
        path.read_text(encoding="utf-8") for path in sorted(ROMANIAN_DIR.glob("*.dart"))
    )
    source_text += "\n" + ROMANIAN_INDEX.read_text(encoding="utf-8")
    source_text += "\n" + ROMANIAN_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("CONFIRM", "Restant", "Data scadenței", "copie de siguranță"):
        if marker not in source_text:
            failures.append(f"Required Romanian source marker missing: {marker}")
    if "CANDIDATE" in source_text or "MANUAL NATIVE REVIEW REQUIRED" in source_text:
        failures.append("Romanian source still carries candidate-only review markers")

    informal = re.compile(
        r"(?<![A-Za-zĂÂÎȘȚăâîșț])(tu|ție|ți|tău|ta|tale|vrei)(?![A-Za-zĂÂÎȘȚăâîșț])",
        re.IGNORECASE,
    )
    for key, value in pairs:
        if informal.search(value):
            failures.append(
                f"Informal Romanian pronoun in reviewed system copy {key!r}: {value!r}"
            )

    suspicious = re.compile(
        r"\b(?:record|records|settings|expenses|payments|backup|due date|overdue)\b",
        re.IGNORECASE,
    )
    for key, value in pairs:
        if suspicious.search(value):
            failures.append(f"English UI leakage in {key!r}: {value!r}")

    if failures:
        raise SystemExit("\n".join(failures))
    print(
        "Romanian native-copy audit passed: 791/791 values, binding terminology, "
        "formal/impersonal register and language purity verified."
    )


if __name__ == "__main__":
    main()
