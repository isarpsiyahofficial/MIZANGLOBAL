from pathlib import Path
import subprocess

fmt = Path('lib/core/formatters.dart')
text = fmt.read_text(encoding='utf-8')
if 'String moneyBuckets(' not in text:
    anchor = 'String moneyForCurrency(num value, String currencyCode) =>\n    money(value, currencyCode: currencyCode);\n'
    if anchor not in text:
        raise SystemExit('moneyForCurrency anchor missing')
    text = text.replace(
        anchor,
        anchor + "\n\nString moneyBuckets(\n  Map<String, double> values, {\n  String empty = '—',\n}) {\n  final entries = values.entries\n      .where((entry) => entry.value.abs() > 0.000001)\n      .toList(growable: false)\n    ..sort((a, b) => a.key.compareTo(b.key));\n  if (entries.isEmpty) return empty;\n  return entries\n      .map((entry) => money(entry.value, currencyCode: entry.key))\n      .join(' · ');\n}\n",
        1,
    )
fmt.write_text(text, encoding='utf-8')

p = Path('lib/screens/reports_screen.dart')
s = p.read_text(encoding='utf-8')

for old, new in {
    'money(report.totalIncome)': 'moneyBuckets(report.totalIncomeByCurrency)',
    'money(report.totalPayments)': 'moneyBuckets(report.totalPaymentsByCurrency)',
    'money(report.totalExpenses)': 'moneyBuckets(report.totalExpensesByCurrency)',
    'money(report.remainingLoad)': 'moneyBuckets(report.remainingLoadByCurrency)',
    'money(report.overdueLoad)': 'moneyBuckets(report.overdueLoadByCurrency)',
    'money(report.upcomingLoad)': 'moneyBuckets(report.upcomingLoadByCurrency)',
    'money(report.realizedGrandTotal)': 'moneyBuckets(report.realizedGrandTotalsByCurrency)',
}.items():
    s = s.replace(old, new)

# Explicit currency for directly owned rows.
s = s.replace('money(detail.amount)', 'money(detail.amount, currencyCode: detail.income.currencyCode)')
s = s.replace('money(detail.payment.amount)', 'money(detail.payment.amount, currencyCode: detail.currencyCode)')
s = s.replace('money(record.amount)', 'money(record.amount, currencyCode: record.currencyCode)')
s = s.replace('money(expense.totalAmount)', 'money(expense.totalAmount, currencyCode: expense.currencyCode)')
s = s.replace('money(expense.unitPrice)', 'money(expense.unitPrice, currencyCode: expense.currencyCode)')
s = s.replace('${money(detail.expense.unitPrice)}', '${money(detail.expense.unitPrice, currencyCode: detail.expense.currencyCode)}')

# Metric detail item owns currency.
start = s.index('class _ReportMetricDetailItem')
end = s.index('class _ReportMetricDetailSheet', start)
region = s[start:end]
region = region.replace("      color = MizanTheme.ink,\n      record = null,", "      color = MizanTheme.ink,\n      currencyCode = '',\n      record = null,")
if 'required this.currencyCode,' not in region:
    region = region.replace('    required this.color,\n', '    required this.color,\n    required this.currencyCode,\n', 1)
if 'final String currencyCode;' not in region:
    region = region.replace('  final Color color;\n', '  final Color color;\n  final String currencyCode;\n', 1)
s = s[:start] + region + s[end:]

start = s.index('class _ReportMetricDetailSheet')
end = s.index('class _ReportFilters', start)
region = s[start:end]
region = region.replace(
    '            color: MizanTheme.green,\n          ),',
    '            color: MizanTheme.green,\n            currencyCode: detail.expense.currencyCode,\n          ),',
    1,
)
region = region.replace(
    '            color: MizanTheme.blue,\n            payment: detail,',
    '            color: MizanTheme.blue,\n            currencyCode: detail.currencyCode,\n            payment: detail,',
    1,
)
region = region.replace(
    '            color: statusColor(record.status),\n            record: record,',
    '            color: statusColor(record.status),\n            currencyCode: record.currencyCode,\n            record: record,',
    1,
)
region = region.replace('money(item.amount)', 'money(item.amount, currencyCode: item.currencyCode)')
s = s[:start] + region + s[end:]

# Income/net cards use currency buckets.
s = s.replace("_InlineTotal(label: 'Gelir', amount: report.totalIncome)", "_InlineTotal(label: 'Gelir', amounts: report.totalIncomeByCurrency)")
s = s.replace('              amount: report.afterPayments,', '              amounts: report.afterPaymentsByCurrency,')
s = s.replace('              amount: report.finalNet,', '              amounts: report.finalNetByCurrency,')
s = s.replace('            amount: report.totalPayments,', '            amounts: report.totalPaymentsByCurrency,')
s = s.replace("_InlineTotal(label: 'Normal giderler', amount: report.totalExpenses)", "_InlineTotal(label: 'Normal giderler', amounts: report.totalExpensesByCurrency)")
s = s.replace("_InlineTotal(label: 'Gelir sonrası net', amount: report.finalNet)", "_InlineTotal(label: 'Gelir sonrası net', amounts: report.finalNetByCurrency)")
start = s.index('class _InlineTotal extends StatelessWidget')
end = s.index('class _ReportEntry', start)
region = s[start:end]
region = region.replace('const _InlineTotal({required this.label, required this.amount});', 'const _InlineTotal({required this.label, required this.amounts});')
region = region.replace('final double amount;', 'final Map<String, double> amounts;')
region = region.replace('money(amount)', 'moneyBuckets(amounts)')
s = s[:start] + region + s[end:]

# Report entries with explicit currency.
start = s.index('class _ReportEntry {')
end = s.index('class _ReportSection', start)
region = s[start:end]
if 'this.currencyCode' not in region:
    region = region.replace('    required this.icon,\n', "    required this.icon,\n    this.currencyCode = '',\n", 1)
    region = region.replace('  final IconData icon;\n', '  final IconData icon;\n  final String currencyCode;\n', 1)
s = s[:start] + region + s[end:]
start = s.index('class _ReportSection')
end = s.index('class _ReportDueDetailCard', start)
region = s[start:end]
region = region.replace('money(item.amount)', "item.currencyCode.isEmpty\n                                  ? money(item.amount)\n                                  : money(item.amount, currencyCode: item.currencyCode)")
s = s[:start] + region + s[end:]

# Use currency-safe report distributions and pass their code to entries.
s = s.replace('report.realizedDistribution)', 'report.realizedDistributionByCurrency)')
s = s.replace('report.combinedOutflowDistribution)', 'report.combinedOutflowDistributionByCurrency)')
# Add currencyCode only to the two loops whose entries are ReportDistributionEntry.
for marker in ['for (final entry in report.realizedDistributionByCurrency)', 'for (final entry in report.combinedOutflowDistributionByCurrency)']:
    idx = s.find(marker)
    if idx >= 0:
        entry_idx = s.find('_ReportEntry(', idx)
        entry_end = s.find('              ),', entry_idx)
        block = s[entry_idx:entry_end]
        if 'currencyCode:' not in block:
            block = block.replace('                amount: entry.amount,\n', '                amount: entry.amount,\n                currencyCode: entry.currencyCode,\n', 1)
            s = s[:entry_idx] + block + s[entry_end:]

# Remaining section derives from actual records by currency+type.
old = """          entries: [
            for (final type in RecordType.values)
              _ReportEntry(
                label: reportTypeLabel(type),
                amount: report.remainingTotalsByType[type] ?? 0,
                icon: recordIcon(type),
              ),
          ],
"""
if old in s:
    s = s.replace(old, '          entries: _remainingDistributionEntries(report),\n', 1)
if 'List<_ReportEntry> _remainingDistributionEntries' not in s:
    anchor = 'class _ReportSection extends StatelessWidget {'
    helper = r'''List<_ReportEntry> _remainingDistributionEntries(MizanReport report) {
  final totals = <String, double>{};
  for (final record in report.remainingDetails) {
    final key = '${record.currencyCode}|${record.type.name}';
    totals[key] = (totals[key] ?? 0) + record.amount;
  }
  return [
    for (final entry in totals.entries)
      _ReportEntry(
        label: reportTypeLabel(
          RecordType.values.firstWhere(
            (item) => item.name == entry.key.split('|')[1],
          ),
        ),
        amount: entry.value,
        currencyCode: entry.key.split('|')[0],
        icon: recordIcon(
          RecordType.values.firstWhere(
            (item) => item.name == entry.key.split('|')[1],
          ),
        ),
      ),
  ];
}

'''
    s = s.replace(anchor, helper + anchor, 1)

# Outflow day headers aggregate currency buckets, never numeric cross-currency sum.
start = s.index('class _ReportOutflowDay {')
end = s.index('class _ReportOutflowGroupsState', start)
region = s[start:end]
old = """  double get normalTotal =>
      expenses.fold<double>(0, (sum, item) => sum + item.expense.totalAmount);

  double get paymentTotal =>
      payments.fold<double>(0, (sum, item) => sum + item.payment.amount);

  double get total => normalTotal + paymentTotal;
"""
new = r'''  Map<String, double> get totalsByCurrency {
    final result = <String, double>{};
    for (final detail in expenses) {
      final code = detail.expense.currencyCode;
      result[code] = (result[code] ?? 0) + detail.expense.totalAmount;
    }
    for (final detail in payments) {
      final code = detail.currencyCode;
      result[code] = (result[code] ?? 0) + detail.payment.amount;
    }
    return result;
  }
'''
if old in region:
    region = region.replace(old, new, 1)
s = s[:start] + region + s[end:]
s = s.replace('money(group.total)', 'moneyBuckets(group.totalsByCurrency)')

# Expense day header gets a currency map.
s = s.replace(
    "              total: entry.value.fold<double>(\n                0,\n                (sum, item) => sum + item.expense.totalAmount,\n              ),",
    "              totals: {\n                for (final code in entry.value.map((item) => item.expense.currencyCode).toSet())\n                  code: entry.value\n                      .where((item) => item.expense.currencyCode == code)\n                      .fold<double>(0, (sum, item) => sum + item.expense.totalAmount),\n              },",
)
start = s.index('class _ReportExpenseDayHeader extends StatelessWidget')
end = s.index('class _ReportExpenseDetailCard', start)
region = s[start:end]
region = region.replace('required this.total,', 'required this.totals,')
region = region.replace('final double total;', 'final Map<String, double> totals;')
region = region.replace('money(total)', 'moneyBuckets(totals)')
s = s[:start] + region + s[end:]

# Person debt summaries derive from records.
s = s.replace("subtitle: Text('Toplam kalan: ${money(person.totalRemaining)}'),", "subtitle: Text('Toplam kalan: ${moneyBuckets(_recordBuckets(person.records))}'),")
s = s.replace('money(widget.person.byType[widget.type] ?? 0)', 'moneyBuckets(_recordBuckets(widget.person.records.where((item) => item.type == widget.type)))')
if 'Map<String, double> _recordBuckets(' not in s:
    anchor = 'String _anchorLabel(ReportPeriod period, DateTime anchor) => switch (period) {'
    helper = r'''Map<String, double> _recordBuckets(Iterable<RecordReference> records) {
  final result = <String, double>{};
  for (final record in records) {
    result[record.currencyCode] =
        (result[record.currencyCode] ?? 0) + record.amount;
  }
  return result;
}

'''
    s = s.replace(anchor, helper + anchor, 1)

p.write_text(s, encoding='utf-8')
subprocess.run(['dart', 'format', str(fmt), str(p)], check=True)
