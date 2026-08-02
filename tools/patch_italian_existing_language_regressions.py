#!/usr/bin/env python3
"""Update pre-Italian locale regressions without weakening their language checks."""
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

print("Existing-language regressions updated for the integrated Italian locale.")
