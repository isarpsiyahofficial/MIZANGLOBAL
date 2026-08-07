from pathlib import Path
import subprocess

p = Path('lib/services/pdf_report_service.dart')
s = p.read_text(encoding='utf-8')

# PDF text direction must follow the selected UI language for RTL languages.
s = s.replace(
    '      textDirection: TextDirection.ltr,',
    "      textDirection: const {'ar', 'fa', 'he', 'ur'}.contains(\n              MizanI18n.normalizeLanguageTag(report.languageTag),\n            )\n          ? TextDirection.rtl\n          : TextDirection.ltr,",
)

# Summary values must never add unrelated currencies.
for old, new in {
    'money(report.totalIncome)': 'moneyBuckets(report.totalIncomeByCurrency)',
    'money(report.totalPayments)': 'moneyBuckets(report.totalPaymentsByCurrency)',
    'money(report.totalExpenses)': 'moneyBuckets(report.totalExpensesByCurrency)',
    'money(report.realizedGrandTotal)': 'moneyBuckets(report.realizedGrandTotalsByCurrency)',
    'money(report.afterPayments)': 'moneyBuckets(report.afterPaymentsByCurrency)',
    'money(report.finalNet)': 'moneyBuckets(report.finalNetByCurrency)',
    'money(report.remainingLoad)': 'moneyBuckets(report.remainingLoadByCurrency)',
    'money(report.overdueLoad)': 'moneyBuckets(report.overdueLoadByCurrency)',
    'money(report.upcomingLoad)': 'moneyBuckets(report.upcomingLoadByCurrency)',
}.items():
    s = s.replace(old, new)

# Every row directly tied to a persisted record uses that record's currency.
s = s.replace('money(detail.amount)', 'money(detail.amount, currencyCode: detail.income.currencyCode)')
s = s.replace('money(detail.payment.amount)', 'money(detail.payment.amount, currencyCode: detail.currencyCode)')
s = s.replace('money(detail.expense.totalAmount)', 'money(detail.expense.totalAmount, currencyCode: detail.expense.currencyCode)')
s = s.replace('money(detail.expense.unitPrice)', 'money(detail.expense.unitPrice, currencyCode: detail.expense.currencyCode)')
s = s.replace('money(record.amount)', 'money(record.amount, currencyCode: record.currencyCode)')

# Distribution sections use explicit currency-bearing entries.
s = s.replace('report.realizedDistribution)', 'report.realizedDistributionByCurrency)')
s = s.replace('report.combinedOutflowDistribution)', 'report.combinedOutflowDistributionByCurrency)')
s = s.replace('money(entry.amount)', 'money(entry.amount, currencyCode: entry.currencyCode)')

# Day headers accept a currency bucket map rather than an invalid scalar sum.
s = s.replace('    required double total,', '    required Map<String, double> totals,')
s = s.replace('money(total)', 'moneyBuckets(totals)')
old_day_total = """      final total =
          expenses.fold<double>(
            0,
            (sum, item) => sum + item.expense.totalAmount,
          ) +
          payments.fold<double>(0, (sum, item) => sum + item.payment.amount);
"""
new_day_total = r'''      final totals = <String, double>{};
      for (final detail in expenses) {
        final code = detail.expense.currencyCode;
        totals[code] = (totals[code] ?? 0) + detail.expense.totalAmount;
      }
      for (final detail in payments) {
        final code = detail.currencyCode;
        totals[code] = (totals[code] ?? 0) + detail.payment.amount;
      }
'''
if old_day_total in s:
    s = s.replace(old_day_total, new_day_total, 1)
s = s.replace('        total: total,', '        totals: totals,')

# Remaining distribution uses record currency + type, never scalar by-type sums.
old_remaining = """    for (final type in RecordType.values) {
      await _keyValue(
        _typeLabel(type),
        money(report.remainingTotalsByType[type] ?? 0),
        continuedTitle: 'Kalan ödeme yükünün dağılımı',
        accentColor: _recordColor(type),
      );
    }
"""
new_remaining = r'''    final remainingBuckets = <String, double>{};
    for (final record in report.remainingDetails) {
      final key = '${record.currencyCode}|${record.type.name}';
      remainingBuckets[key] = (remainingBuckets[key] ?? 0) + record.amount;
    }
    for (final entry in remainingBuckets.entries) {
      final parts = entry.key.split('|');
      final type = RecordType.values.firstWhere((item) => item.name == parts[1]);
      await _keyValue(
        _typeLabel(type),
        money(entry.value, currencyCode: parts[0]),
        continuedTitle: 'Kalan ödeme yükünün dağılımı',
        accentColor: _recordColor(type),
      );
    }
'''
if old_remaining in s:
    s = s.replace(old_remaining, new_remaining, 1)

# Person totals and type rows are derived from that person's actual record currencies.
s = s.replace(
    'money(person.totalRemaining)',
    'moneyBuckets(_recordCurrencyBuckets(person.records))',
)
old_person_type = """        final value = person.byType[type] ?? 0;
        if (value <= 0) continue;
        await _keyValue(
          _typeLabel(type),
          money(value),
          continuedTitle: person.personName,
          accentColor: _recordColor(type),
        );
"""
new_person_type = r'''        final buckets = _recordCurrencyBuckets(
          person.records.where((record) => record.type == type),
        );
        if (buckets.isEmpty) continue;
        await _keyValue(
          _typeLabel(type),
          moneyBuckets(buckets),
          continuedTitle: person.personName,
          accentColor: _recordColor(type),
        );
'''
if old_person_type in s:
    s = s.replace(old_person_type, new_person_type, 1)

# Shared deterministic bucket helper local to the painter.
if 'Map<String, double> _recordCurrencyBuckets(' not in s:
    anchor = '  Color _recordColor(RecordType type) => switch (type) {'
    helper = r'''  Map<String, double> _recordCurrencyBuckets(
    Iterable<RecordReference> records,
  ) {
    final result = <String, double>{};
    for (final record in records) {
      final code = record.currencyCode.trim().toUpperCase();
      final resolved = RegExp(r'^[A-Z]{3}$').hasMatch(code)
          ? code
          : report.currencyCode;
      result[resolved] = (result[resolved] ?? 0) + record.amount;
    }
    result.removeWhere((_, value) => value.abs() < 0.000001);
    return result;
  }

'''
    if anchor not in s:
        raise SystemExit('pdf record color anchor missing')
    s = s.replace(anchor, helper + anchor, 1)

p.write_text(s, encoding='utf-8')
subprocess.run(['dart', 'format', str(p)], check=True)
