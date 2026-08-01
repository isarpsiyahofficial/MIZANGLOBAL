#!/usr/bin/env python3
"""Update pre-pt-BR regression expectations after the locale is fully integrated."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPANISH_TEST = ROOT / "test/spanish_localization_test.dart"

OLD = """  test(
    'Spanish is a fully enabled locale without enabling later languages',
    () {
      expect(MizanI18n.supportedLanguageTags, {'tr', 'en', 'es'});
      expect(MizanI18n.isSupported('es'), isTrue);
      expect(MizanI18n.isSupported('es-ES'), isTrue);
      expect(MizanI18n.isSupported('es-MX'), isTrue);
      expect(MizanI18n.normalizeLanguageTag('es-AR'), 'es');
      expect(MizanI18n.isSupported('pt-BR'), isFalse);
      expect(MizanI18n.isSupported('de'), isFalse);
    },
  );
"""

NEW = """  test(
    'Spanish remains fully enabled after Brazilian Portuguese integration',
    () {
      expect(MizanI18n.supportedLanguageTags, {'tr', 'en', 'es', 'pt-BR'});
      expect(MizanI18n.isSupported('es'), isTrue);
      expect(MizanI18n.isSupported('es-ES'), isTrue);
      expect(MizanI18n.isSupported('es-MX'), isTrue);
      expect(MizanI18n.normalizeLanguageTag('es-AR'), 'es');
      expect(MizanI18n.isSupported('pt-BR'), isTrue);
      expect(MizanI18n.isSupported('pt_BR'), isTrue);
      expect(MizanI18n.normalizeLanguageTag('pt_BR'), 'pt-BR');
      expect(MizanI18n.isSupported('pt'), isFalse);
      expect(MizanI18n.isSupported('pt-PT'), isFalse);
      expect(MizanI18n.isSupported('de'), isFalse);
    },
  );
"""


def main() -> None:
    source = SPANISH_TEST.read_text(encoding="utf-8")
    if NEW in source:
        print("Spanish regression expectations already include pt-BR.")
        return
    if source.count(OLD) != 1:
        raise SystemExit("Could not locate the exact pre-pt-BR Spanish regression block")
    SPANISH_TEST.write_text(source.replace(OLD, NEW, 1), encoding="utf-8")
    print("Updated Spanish regression expectations for integrated pt-BR.")


if __name__ == "__main__":
    main()
