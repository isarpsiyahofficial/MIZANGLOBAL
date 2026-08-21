#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path('.')


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def write(path: str, text: str) -> None:
    (ROOT / path).write_text(text, encoding='utf-8')


def replace_once(path: str, old: str, new: str) -> None:
    text = read(path)
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: expected one marker, found {count}: {old[:100]!r}')
    write(path, text.replace(old, new, 1))


def regex_once(path: str, pattern: str, replacement: str) -> None:
    text = read(path)
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.S)
    if count != 1:
        raise RuntimeError(f'{path}: regex marker not found exactly once: {pattern[:120]!r}')
    write(path, updated)


replace_once(
    'lib/screens/expenses_screen.dart',
    'enum _ExpensePeriod { thisMonth, days30, days90, custom, all }',
    'enum _ExpensePeriod { thisMonth, days30, days60, days90, custom, all }',
)
replace_once(
    'lib/screens/expenses_screen.dart',
    "    _ExpensePeriod.days30 => 'Son 30 gün',\n    _ExpensePeriod.days90 => 'Son 90 gün',",
    "    _ExpensePeriod.days30 => 'Son 30 gün',\n    _ExpensePeriod.days60 => _last60DaysLabel(),\n    _ExpensePeriod.days90 => 'Son 90 gün',",
)
replace_once(
    'lib/screens/expenses_screen.dart',
    "}\n\nMap<String, double> _expenseBuckets(Iterable<ExpenseItem> items) {",
    "}\n\nString _last60DaysLabel() {\n  final localizedThirty = MizanI18n.text('Son 30 gün');\n  return localizedThirty\n      .replaceFirst('30', '60')\n      .replaceFirst('৩০', '৬০')\n      .replaceFirst('۳۰', '۶۰');\n}\n\nMap<String, double> _expenseBuckets(Iterable<ExpenseItem> items) {",
)
replace_once(
    'lib/screens/expenses_screen.dart',
    "    _ExpensePeriod.days90 => (\n      start: dateOnly(now).subtract(const Duration(days: 89)),",
    "    _ExpensePeriod.days60 => (\n      start: dateOnly(now).subtract(const Duration(days: 59)),\n      end: dateOnly(now),\n    ),\n    _ExpensePeriod.days90 => (\n      start: dateOnly(now).subtract(const Duration(days: 89)),",
)

replace_once(
    'lib/screens/reports_screen.dart',
    "                for (final item in const [\n                  ReportPeriod.monthly,\n                  ReportPeriod.yearly,\n                  ReportPeriod.allTime,",
    "                for (final item in const [\n                  ReportPeriod.daily,\n                  ReportPeriod.weekly,\n                  ReportPeriod.monthly,\n                  ReportPeriod.yearly,\n                  ReportPeriod.allTime,",
)
regex_once(
    'lib/screens/reports_screen.dart',
    r"                onPressed: period == ReportPeriod\.monthly\n.*?                icon: const Icon\(Icons\.calendar_month_outlined\),",
    """                onPressed: switch (period) {
                  ReportPeriod.daily || ReportPeriod.weekly => () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: anchorDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100, 12, 31),
                    );
                    if (selected != null) onAnchorChanged(dateOnly(selected));
                  },
                  ReportPeriod.monthly => availableMonths.isEmpty
                      ? null
                      : () async {
                          final selected = await _selectRecordedMonth(
                            context,
                            availableMonths,
                            anchorDate,
                          );
                          if (selected != null) onAnchorChanged(selected);
                        },
                  ReportPeriod.yearly => availableYears.isEmpty
                      ? null
                      : () async {
                          final selected = await _selectRecordedYear(
                            context,
                            availableYears,
                            anchorDate.year,
                          );
                          if (selected != null) {
                            onAnchorChanged(DateTime(selected));
                          }
                        },
                  ReportPeriod.allTime => null,
                },
                icon: const Icon(Icons.calendar_month_outlined),""",
)
replace_once(
    'lib/screens/reports_screen.dart',
    "    'Hafta: ${shortDate(anchor.subtract(Duration(days: anchor.weekday - 1)))}',",
    "    \"${MizanI18n.text('Hafta')}: ${shortDate(anchor.subtract(Duration(days: anchor.weekday - 1)))}\",",
)

regex_once(
    'lib/legal/legal_acceptance_store.dart',
    r"  static Future<void> acceptCurrentLegalBundle\(\) async \{\n    final prefs = await SharedPreferences\.getInstance\(\);\n    await prefs\.setString\(_generalAcceptanceKey, currentVersion\);\n  \}",
    """  static Future<bool> acceptCurrentLegalBundle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_generalAcceptanceKey, currentVersion);
    } on Object {
      return false;
    }
  }""",
)
regex_once(
    'lib/legal/legal_acceptance_store.dart',
    r"  static Future<void> acceptCurrentPurchaseTerms\(\) async \{\n    final prefs = await SharedPreferences\.getInstance\(\);\n    await prefs\.setString\(_purchaseAcceptanceKey, currentPurchaseVersion\);\n  \}",
    """  static Future<bool> acceptCurrentPurchaseTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
        _purchaseAcceptanceKey,
        currentPurchaseVersion,
      );
    } on Object {
      return false;
    }
  }""",
)
replace_once(
    'lib/screens/premium_screen.dart',
    '      await LegalAcceptanceStore.acceptCurrentPurchaseTerms();',
    """      final recorded = await LegalAcceptanceStore.acceptCurrentPurchaseTerms();
      if (!recorded) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_t('purchaseUnavailable'))));
        return;
      }""",
)
replace_once(
    'lib/screens/legal_consent_screen.dart',
    """    await LegalAcceptanceStore.acceptCurrentLegalBundle();
    if (!mounted) return;
    widget.onAccepted();""",
    """    final recorded = await LegalAcceptanceStore.acceptCurrentLegalBundle();
    if (!mounted) return;
    if (!recorded) {
      setState(() => _saving = false);
      return;
    }
    widget.onAccepted();""",
)

for legal in ('lib/legal/legal_documents.dart', 'lib/legal/legal_turkish_documents.dart'):
    text = read(legal)
    if 'Premium' not in text:
        raise RuntimeError(f'{legal}: no Premium marker found')
    text = text.replace('Premium', 'PRO')
    text = text.replace('2026-08-20-general-r1', '2026-08-21-general-r2')
    text = text.replace('2026-08-20-purchase-r1', '2026-08-21-purchase-r2')
    write(legal, text)

replace_once(
    'tools/validate_project.py',
    '["Google Play", "explicitly accepted", "Kalıcı Premium", "ayrıca kabul edilir"]',
    '["Google Play", "explicitly accepted", "Kalıcı PRO", "ayrıca kabul edilir"]',
)
replace_once(
    'test/monetization_contract_test.dart',
    "contains('Permanent Premium Purchase Terms are not part')",
    "contains('Permanent PRO Purchase Terms are not part')",
)
replace_once(
    'test/all_29_language_legal_read_gate_test.dart',
    "'$tag: Permanent Premium purchase terms require explicit acceptance'",
    "'$tag: Permanent PRO purchase terms require explicit acceptance'",
)

for stale in (
    'test/goldens/01-dashboard-phone.png',
    'test/goldens/02-people-phone.png',
    'test/goldens/03-debt-detail-phone.png',
    'test/goldens/04-expenses-phone.png',
    'test/goldens/05-reports-phone.png',
    'test/goldens/06-settings-phone.png',
    'test/goldens/07-dashboard-tablet.png',
):
    path = ROOT / stale
    if not path.is_file():
        raise RuntimeError(f'missing stale golden expected for deletion: {stale}')
    path.unlink()

print('Final recovery source patch applied successfully.')
