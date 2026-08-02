#!/usr/bin/env python3
"""Update pre-German locale regressions without weakening their language checks."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = (
    ROOT / "test/english_localization_test.dart",
    ROOT / "test/spanish_localization_test.dart",
    ROOT / "test/portuguese_br_localization_test.dart",
)

OLD_SET = """      'pt-PT',
      'fr',
    });"""
NEW_SET = """      'pt-PT',
      'fr',
      'de',
    });"""
OLD_DE = """    expect(MizanI18n.isSupported('de'), isFalse);"""
NEW_DE = """    expect(MizanI18n.isSupported('de'), isTrue);
    expect(MizanI18n.isSupported('de-DE'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('de-AT'), 'de');"""

for path in FILES:
    text = path.read_text(encoding="utf-8")
    if NEW_SET not in text:
        if text.count(OLD_SET) != 1:
            raise SystemExit(
                f"Expected one supported-language set in {path.relative_to(ROOT)}, "
                f"found {text.count(OLD_SET)}"
            )
        text = text.replace(OLD_SET, NEW_SET, 1)
    if NEW_DE not in text:
        if text.count(OLD_DE) != 1:
            raise SystemExit(
                f"Expected one pre-German assertion in {path.relative_to(ROOT)}, "
                f"found {text.count(OLD_DE)}"
            )
        text = text.replace(OLD_DE, NEW_DE, 1)
    text = text.replace('after French integration', 'after German integration')
    path.write_text(text, encoding="utf-8")

print("Existing-language regressions updated for the integrated German locale.")
