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
SPANISH_VALIDATOR = ROOT / "tools" / "validate_spanish_localization.py"
PT_PT_BUILDER = ROOT / "tools" / "build_pt_pt_locale.py"


def _replace_scope_block(
    validator: Path,
    pattern: re.Pattern[str],
    replacement: str,
) -> None:
    source = validator.read_text(encoding="utf-8")
    if replacement in source:
        return
    source, count = pattern.subn(replacement, source, count=1)
    if count != 1:
        raise SystemExit(
            f"{validator.name} localization-scope block could not be normalized safely."
        )
    validator.write_text(source, encoding="utf-8")


def _normalize_legacy_pt_pt_builder() -> None:
    """Remove obsolete per-locale validator-list mutation from the pt-PT builder."""
    source = PT_PT_BUILDER.read_text(encoding="utf-8")
    marker = (
        "        # Translation catalogs are excluded generically by validator path.\n"
    )
    if marker in source:
        return
    start_token = '        if path.name.endswith(".py"):\n'
    end_token = '        path.write_text(text, encoding="utf-8")\n'
    start = source.find(start_token, source.find("def update_regressions"))
    end = source.find(end_token, start)
    if start < 0 or end < 0:
        raise SystemExit(
            "build_pt_pt_locale.py obsolete validator-list block could not be normalized safely."
        )
    source = source[:start] + marker + source[end:]
    PT_PT_BUILDER.write_text(source, encoding="utf-8")


def _normalize_cross_language_validator_scope() -> None:
    """Keep source guards on product UI code, never translated catalogs."""
    english_pattern = re.compile(
        r"    if path == I18N or rel in \{\n.*?\n    \}:\n        continue",
        re.DOTALL,
    )
    english_replacement = (
        "    if (\n"
        "        path == I18N\n"
        "        or rel == \"lib/global/global_catalog.dart\"\n"
        "        or rel.startswith(\"lib/l10n/\")\n"
        "    ):\n"
        "        continue"
    )
    _replace_scope_block(
        ENGLISH_VALIDATOR,
        english_pattern,
        english_replacement,
    )

    spanish_pattern = re.compile(
        r"    if rel in \{\n.*?\n    \}:\n        continue",
        re.DOTALL,
    )
    spanish_replacement = (
        "    if (\n"
        "        rel == \"lib/global/global_catalog.dart\"\n"
        "        or rel.startswith(\"lib/l10n/\")\n"
        "    ):\n"
        "        continue"
    )
    _replace_scope_block(
        SPANISH_VALIDATOR,
        spanish_pattern,
        spanish_replacement,
    )


def main() -> None:
    _normalize_legacy_pt_pt_builder()
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
