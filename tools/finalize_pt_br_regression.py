#!/usr/bin/env python3
"""Finalize pt-BR regression expectations and reviewed dynamic grammar."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENGLISH_TEST = ROOT / "test/english_localization_test.dart"
SPANISH_TEST = ROOT / "test/spanish_localization_test.dart"
PORTUGUESE_TEST = ROOT / "test/portuguese_br_localization_test.dart"
DYNAMIC = ROOT / "lib/l10n/mizan_pt_br_dynamic.dart"

OLD_ENGLISH_TEST = """  test('Turkish, English and Spanish are enabled', () {
    expect(MizanI18n.supportedLanguageTags, {'tr', 'en', 'es'});
    expect(MizanI18n.isSupported('tr'), isTrue);
    expect(MizanI18n.isSupported('en-US'), isTrue);
    expect(MizanI18n.isSupported('es-MX'), isTrue);
    expect(MizanI18n.isSupported('de'), isFalse);
    expect(MizanI18n.isSupported('fr'), isFalse);
  });
"""

NEW_ENGLISH_TEST = """  test('Turkish, English, Spanish and Brazilian Portuguese are enabled', () {
    expect(MizanI18n.supportedLanguageTags, {'tr', 'en', 'es', 'pt-BR'});
    expect(MizanI18n.isSupported('tr'), isTrue);
    expect(MizanI18n.isSupported('en-US'), isTrue);
    expect(MizanI18n.isSupported('es-MX'), isTrue);
    expect(MizanI18n.isSupported('pt-BR'), isTrue);
    expect(MizanI18n.isSupported('pt_BR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('pt_BR'), 'pt-BR');
    expect(MizanI18n.isSupported('pt'), isFalse);
    expect(MizanI18n.isSupported('pt-PT'), isFalse);
    expect(MizanI18n.isSupported('de'), isFalse);
    expect(MizanI18n.isSupported('fr'), isFalse);
  });
"""

OLD_SPANISH_TEST = """  test(
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

NEW_SPANISH_TEST = """  test(
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

OLD_MONEY_EXPECTATION = """    expect(money(1234567.5), r'R$ 1.234.567,50');
    expect(money(1234567.5, currencyCode: 'USD'), 'USD 1.234.567,50');
    expect(decimalText(12.5), '12,50');
"""

NEW_MONEY_EXPECTATION = """    expect(money(1234567.5), r'R$ 1.234.567,50');
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'USD');
    expect(money(1234567.5), 'USD 1.234.567,50');
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');
    expect(decimalText(12.5), '12,50');
"""

OLD_REPORT_ASSERTIONS = """    expect(report.selectedPersonNames, contains('İbrahim'));
    expect(
      report.paymentDetails.map((item) => item.recordTitle),
      contains('Kart borcu'),
    );
    expect(
      report.selectedPersonNames.any((value) => value.contains('\\u{E000}')),
      isFalse,
    );
    expect(
      report.paymentDetails.any(
        (item) =>
            item.personName.contains('\\u{E000}') ||
            item.recordTitle.contains('\\u{E000}') ||
            item.recordSubtitle.contains('\\u{E000}'),
      ),
      isFalse,
    );
"""

NEW_REPORT_ASSERTIONS = """    expect(report.selectedPersonNames, contains('İbrahim'));
    expect(report.paymentDetails, isEmpty);
    expect(
      report.remainingDetails.map((item) => item.title),
      contains('Kart borcu'),
    );
    expect(
      report.selectedPersonNames.any((value) => value.contains('\\u{E000}')),
      isFalse,
    );
    expect(
      report.remainingDetails.any(
        (item) =>
            item.title.contains('\\u{E000}') ||
            item.subtitle.contains('\\u{E000}'),
      ),
      isFalse,
    );
"""

OLD_REMINDER_EXPECTATION = """    expect(reminder.message, contains('Valor restante BRL'));
"""

NEW_REMINDER_EXPECTATION = """    expect(reminder.message, contains(r'Valor restante R$ 2.000,00'));
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
        "_remainingVerb(m[2]!)",
    ),
    (
        "'Não foi possível verificar a programação de notificações; faltam ${_records(m[1]!)} no Android.'",
        "'Não foi possível verificar a programação de notificações; ${_missingVerb(m[1]!)} ${_records(m[1]!)} no Android.'",
        "_missingVerb(m[1]!)",
    ),
    (
        "'${_records(m[1]!)} novos; ${_relationships(m[2]!)} atualizados${m[3]}.'",
        "'${_newRecords(m[1]!)}; ${_updatedRelationships(m[2]!)}${m[3]}.'",
        "_updatedRelationships(m[2]!)",
    ),
    (
        "'Faltam ${_days(m[1]!)}'",
        "'${_remainingVerb(m[1]!)} ${_days(m[1]!)}'",
        "_remainingVerb(m[1]!)",
    ),
    (
        "'${_records(m[1]!)} novos foram adicionados; os dados existentes foram preservados.'",
        "'${_addedRecords(m[1]!)}; os dados existentes foram preservados.'",
        "_addedRecords(m[1]!)",
    ),
)


def replace_once_or_done(source: str, old: str, new: str, label: str) -> str:
    if new in source:
        return source
    if source.count(old) != 1:
        raise SystemExit(f"Could not locate exact {label} source")
    return source.replace(old, new, 1)


def finalize_english_regression() -> bool:
    source = ENGLISH_TEST.read_text(encoding="utf-8")
    updated = replace_once_or_done(
        source,
        OLD_ENGLISH_TEST,
        NEW_ENGLISH_TEST,
        "pre-pt-BR English locale regression block",
    )
    if updated == source:
        print("English regression expectations already include pt-BR.")
        return False
    ENGLISH_TEST.write_text(updated, encoding="utf-8")
    print("Updated English regression expectations for integrated pt-BR.")
    return True


def finalize_spanish_regression() -> bool:
    source = SPANISH_TEST.read_text(encoding="utf-8")
    updated = replace_once_or_done(
        source,
        OLD_SPANISH_TEST,
        NEW_SPANISH_TEST,
        "pre-pt-BR Spanish regression block",
    )
    if updated == source:
        print("Spanish regression expectations already include pt-BR.")
        return False
    SPANISH_TEST.write_text(updated, encoding="utf-8")
    print("Updated Spanish regression expectations for integrated pt-BR.")
    return True


def finalize_portuguese_regression() -> bool:
    source = PORTUGUESE_TEST.read_text(encoding="utf-8")
    updated = replace_once_or_done(
        source,
        OLD_MONEY_EXPECTATION,
        NEW_MONEY_EXPECTATION,
        "pt-BR currency formatter regression block",
    )
    updated = replace_once_or_done(
        updated,
        OLD_REPORT_ASSERTIONS,
        NEW_REPORT_ASSERTIONS,
        "pt-BR report data-preservation assertions",
    )
    updated = replace_once_or_done(
        updated,
        OLD_REMINDER_EXPECTATION,
        NEW_REMINDER_EXPECTATION,
        "pt-BR reminder currency assertion",
    )
    if updated == source:
        print("Brazilian Portuguese regression expectations are already final.")
        return False
    PORTUGUESE_TEST.write_text(updated, encoding="utf-8")
    print("Corrected Brazilian Portuguese report, reminder and currency expectations.")
    return True


def refine_dynamic_grammar() -> bool:
    source = DYNAMIC.read_text(encoding="utf-8")
    updated = source
    if "String _remainingVerb(" not in updated:
        updated = replace_once_or_done(
            updated,
            HELPER_ANCHOR,
            HELPERS,
            "pt-BR dynamic helper anchor",
        )
    for index, (old, new, marker) in enumerate(DYNAMIC_REPLACEMENTS, 1):
        if marker in updated:
            continue
        if updated.count(old) != 1:
            raise SystemExit(
                f"Could not locate pt-BR dynamic grammar replacement {index}"
            )
        updated = updated.replace(old, new, 1)
    if UNUSED_RELATIONSHIP_HELPER in updated:
        updated = updated.replace(UNUSED_RELATIONSHIP_HELPER, "", 1)
    if updated == source:
        print("Brazilian Portuguese dynamic singular/plural grammar is already final.")
        return False
    DYNAMIC.write_text(updated, encoding="utf-8")
    print("Refined Brazilian Portuguese dynamic singular/plural grammar.")
    return True


def main() -> None:
    finalize_english_regression()
    finalize_spanish_regression()
    finalize_portuguese_regression()
    refine_dynamic_grammar()


if __name__ == "__main__":
    main()
