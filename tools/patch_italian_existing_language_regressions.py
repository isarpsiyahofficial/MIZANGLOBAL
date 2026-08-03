#!/usr/bin/env python3
"""Update pre-Italian regressions without weakening their language checks."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = (
    ROOT / "test/english_localization_test.dart",
    ROOT / "test/spanish_localization_test.dart",
    ROOT / "test/portuguese_br_localization_test.dart",
)

OLD_SET = """      'fr',
      'de',
    });"""
NEW_SET = """      'fr',
      'de',
      'it',
    });"""
OLD_TAIL = """    expect(MizanI18n.isSupported('de'), isTrue);
    expect(MizanI18n.isSupported('de-DE'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('de-AT'), 'de');"""
NEW_TAIL = """    expect(MizanI18n.isSupported('de'), isTrue);
    expect(MizanI18n.isSupported('de-DE'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('de-AT'), 'de');
    expect(MizanI18n.isSupported('it'), isTrue);
    expect(MizanI18n.isSupported('it-IT'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('it-CH'), 'it');"""

for path in FILES:
    text = path.read_text(encoding="utf-8")
    if NEW_SET not in text:
        if text.count(OLD_SET) != 1:
            raise SystemExit(
                f"Expected one supported-language set in {path.relative_to(ROOT)}, "
                f"found {text.count(OLD_SET)}"
            )
        text = text.replace(OLD_SET, NEW_SET, 1)
    if "MizanI18n.isSupported('it-IT')" not in text:
        if text.count(OLD_TAIL) != 1:
            raise SystemExit(
                f"Expected one German integration tail in {path.relative_to(ROOT)}, "
                f"found {text.count(OLD_TAIL)}"
            )
        text = text.replace(OLD_TAIL, NEW_TAIL, 1)
    text = text.replace('after German integration', 'after Italian integration')
    path.write_text(text, encoding="utf-8")

ITALIAN_SCOPE = """        "lib/l10n/mizan_it.dart",
        "lib/l10n/mizan_it_dynamic.dart",
        "lib/l10n/it/mizan_it_core.dart",
        "lib/l10n/it/mizan_it_validation.dart",
        "lib/l10n/it/mizan_it_dashboard.dart",
        "lib/l10n/it/mizan_it_records.dart",
        "lib/l10n/it/mizan_it_reports.dart",
        "lib/l10n/it/mizan_it_settings.dart",
"""

# Strict cross-language validators scan product surfaces for untranslated
# Turkish literals. Dedicated locale sources are outside that product-surface
# scan, while their own 791-key and native-language audits remain mandatory.
for validator_name in (
    "validate_english_localization.py",
    "validate_spanish_localization.py",
):
    validator = ROOT / "tools" / validator_name
    validator_text = validator.read_text(encoding="utf-8")
    if '"lib/l10n/mizan_it.dart",' not in validator_text:
        anchor = '        "lib/l10n/de/mizan_de_settings.dart",\n'
        if anchor not in validator_text:
            raise SystemExit(
                f"German locale exclusion anchor is missing from {validator_name}"
            )
        validator_text = validator_text.replace(anchor, anchor + ITALIAN_SCOPE, 1)
        validator.write_text(validator_text, encoding="utf-8")

print(
    "Existing-language regressions and strict validator scopes updated for Italian."
)
