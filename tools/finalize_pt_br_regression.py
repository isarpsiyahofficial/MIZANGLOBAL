#!/usr/bin/env python3
"""Finalize pt-BR regression expectations and reviewed dynamic grammar."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPANISH_TEST = ROOT / "test/spanish_localization_test.dart"
DYNAMIC = ROOT / "lib/l10n/mizan_pt_br_dynamic.dart"

OLD_TEST = """  test(
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

NEW_TEST = """  test(
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

HELPER_ANCHOR = """String _dailyExpenses(String value) => value == '1'
    ? '$value despesa diária'
    : '$value despesas diárias';
"""
HELPERS = """String _dailyExpenses(String value) => value == '1'
    ? '$value despesa diária'
    : '$value despesas diárias';
String _remainingVerb(String value) => value == '1' ? 'Falta' : 'Faltam';
String _missingVerb(String value) => value == '1' ? 'falta' : 'faltam';
String _newRecords(String value) =>
    value == '1' ? '1 registro novo' : '$value registros novos';
String _addedRecords(String value) => value == '1'
    ? '1 registro novo foi adicionado'
    : '$value registros novos foram adicionados';
String _updatedRelationships(String value) => value == '1'
    ? '1 vínculo atualizado'
    : '$value vínculos atualizados';
"""

UNUSED_RELATIONSHIP_HELPER = (
    "String _relationships(String value) => "
    "_count(value, 'vínculo', 'vínculos');\n"
)

DYNAMIC_REPLACEMENTS = (
    (
        "'Faltam ${_days(m[2]!)} para ${m[1]}'",
        "'${_remainingVerb(m[2]!)} ${_days(m[2]!)} para ${m[1]}'",
    ),
    (
        "'Não foi possível verificar a programação de notificações; faltam ${_records(m[1]!)} no Android.'",
        "'Não foi possível verificar a programação de notificações; ${_missingVerb(m[1]!)} ${_records(m[1]!)} no Android.'",
    ),
    (
        "'${_records(m[1]!)} novos; ${_relationships(m[2]!)} atualizados${m[3]}.'",
        "'${_newRecords(m[1]!)}; ${_updatedRelationships(m[2]!)}${m[3]}.'",
    ),
    (
        "'Faltam ${_days(m[1]!)}'",
        "'${_remainingVerb(m[1]!)} ${_days(m[1]!)}'",
    ),
    (
        "'${_records(m[1]!)} novos foram adicionados; os dados existentes foram preservados.'",
        "'${_addedRecords(m[1]!)}; os dados existentes foram preservados.'",
    ),
)


def replace_once_or_done(source: str, old: str, new: str, label: str) -> str:
    if new in source:
        return source
    if source.count(old) != 1:
        raise SystemExit(f"Could not locate exact {label} source")
    return source.replace(old, new, 1)


def finalize_spanish_regression() -> bool:
    source = SPANISH_TEST.read_text(encoding="utf-8")
    updated = replace_once_or_done(
        source,
        OLD_TEST,
        NEW_TEST,
        "pre-pt-BR Spanish regression block",
    )
    if updated == source:
        print("Spanish regression expectations already include pt-BR.")
        return False
    SPANISH_TEST.write_text(updated, encoding="utf-8")
    print("Updated Spanish regression expectations for integrated pt-BR.")
    return True


def refine_dynamic_grammar() -> bool:
    source = DYNAMIC.read_text(encoding="utf-8")
    updated = replace_once_or_done(
        source,
        HELPER_ANCHOR,
        HELPERS,
        "pt-BR dynamic helper anchor",
    )
    for index, (old, new) in enumerate(DYNAMIC_REPLACEMENTS, 1):
        updated = replace_once_or_done(
            updated,
            old,
            new,
            f"pt-BR dynamic grammar replacement {index}",
        )
    if UNUSED_RELATIONSHIP_HELPER in updated:
        updated = updated.replace(UNUSED_RELATIONSHIP_HELPER, "", 1)
    if updated == source:
        print("Brazilian Portuguese dynamic singular/plural grammar is already final.")
        return False
    DYNAMIC.write_text(updated, encoding="utf-8")
    print("Refined Brazilian Portuguese dynamic singular/plural grammar.")
    return True


def main() -> None:
    finalize_spanish_regression()
    refine_dynamic_grammar()


if __name__ == "__main__":
    main()
