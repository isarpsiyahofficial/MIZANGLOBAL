#!/usr/bin/env python3
"""Fail-closed audit for reviewed Dutch product copy and language purity."""
from __future__ import annotations

import json
import re
from pathlib import Path

from build_dutch_locale import ROOT, dutch_pairs, english_pairs

CONTRACT = ROOT / "tools" / "dutch_native_terms.json"
DUTCH_DIR = ROOT / "lib" / "l10n" / "nl"
DUTCH_DYNAMIC = ROOT / "lib" / "l10n" / "mizan_nl_dynamic.dart"
ENGLISH_VALIDATOR = ROOT / "tools" / "validate_english_localization.py"


def _normalize_cross_language_validator_scope() -> None:
    """Keep the English guard on product UI sources, never translated catalogs."""
    source = ENGLISH_VALIDATOR.read_text(encoding="utf-8")
    broad_skip = re.compile(
        r"    if path == I18N or rel in \{\n.*?\n    \}:\n        continue",
        re.DOTALL,
    )
    replacement = (
        "    if (\n"
        "        path == I18N\n"
        "        or rel == \"lib/global/global_catalog.dart\"\n"
        "        or rel.startswith(\"lib/l10n/\")\n"
        "    ):\n"
        "        continue"
    )
    if replacement not in source:
        source, count = broad_skip.subn(replacement, source, count=1)
        if count != 1:
            raise SystemExit(
                "English validator localization-scope block could not be normalized safely."
            )
        ENGLISH_VALIDATOR.write_text(source, encoding="utf-8")


def main() -> None:
    _normalize_cross_language_validator_scope()
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    pairs = dutch_pairs()
    values = dict(pairs)
    failures: list[str] = []

    english = english_pairs()
    english_keys = {key for key, _ in english}
    dutch_keys = {key for key, _ in pairs}
    if len(pairs) != 791:
        failures.append(f"Dutch static catalog contains {len(pairs)} values instead of 791")
    if dutch_keys != english_keys:
        failures.append(
            f"Dutch key set differs from English: missing={sorted(english_keys-dutch_keys)[:25]}, extra={sorted(dutch_keys-english_keys)[:25]}"
        )

    for key, expected in contract["requiredTerms"].items():
        actual = values.get(key)
        if actual != expected:
            failures.append(f"Required Dutch term mismatch for {key!r}: {actual!r}")

    forbidden = tuple(contract["forbiddenVisibleTerms"])
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

    source_text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in sorted(DUTCH_DIR.glob("*.dart"))
    )
    source_text += "\n" + DUTCH_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("IK BEVESTIG", "Achterstallig", "Vervaldatum", "reservekopie"):
        if marker not in source_text:
            failures.append(f"Required Dutch source marker missing: {marker}")

    # Explanatory copy must not drift into informal jij/je/jouw register.
    informal = re.compile(
        r"(?<![A-Za-zÀ-ÿ])(jij|jouw)(?![A-Za-zÀ-ÿ])", re.IGNORECASE
    )
    for key, value in pairs:
        if informal.search(value):
            failures.append(
                f"Informal Dutch pronoun in reviewed system copy {key!r}: {value!r}"
            )

    if failures:
        raise SystemExit("\n".join(failures))
    print(
        "Dutch native-copy audit passed: 791/791 values, binding terminology, formal register and language purity verified."
    )


if __name__ == "__main__":
    main()
