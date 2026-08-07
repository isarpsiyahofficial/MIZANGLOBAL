#!/usr/bin/env python3
from pathlib import Path
import subprocess

# Shared formatter for dynamic currency buckets.
fmt = Path('lib/core/formatters.dart')
s = fmt.read_text(encoding='utf-8')
if 'String moneyBuckets(' not in s:
    anchor = 'String moneyForCurrency(num value, String currencyCode) =>\n    money(value, currencyCode: currencyCode);\n'
    if anchor not in s:
        raise SystemExit('moneyForCurrency anchor missing')
    helper = anchor + "\n\nString moneyBuckets(\n  Map<String, double> values, {\n  String empty = '—',\n}) {\n  final entries = values.entries\n      .where((entry) => entry.value.abs() > 0.000001)\n      .toList(growable: false)\n    ..sort((a, b) => a.key.compareTo(b.key));\n  if (entries.isEmpty) return empty;\n  return entries\n      .map((entry) => money(entry.value, currencyCode: entry.key))\n      .join(' · ');\n}\n"
    s = s.replace(anchor, helper, 1)
    fmt.write_text(s, encoding='utf-8')

p = Path('lib/screens/reports_screen.dart')
s = p.read_text(encoding='utf-8')

# Top-level metric cards.
replacements = {
    "money(report.totalIncome)": "moneyBuckets(report.totalIncomeByCurrency)",
    "money(report.totalPayments)": "moneyBuckets(report.totalPaymentsByCurrency)",
    "money(report.totalExpenses)": "moneyBuckets(report.totalExpensesByCurrency)",
    "money(report.remainingLoad)": "moneyBuckets(report.remainingLoadByCurrency)",
    "money(report.overdueLoad)": "moneyBuckets(report.overdueLoadByCurrency)",
    "money(report.upcomingLoad)": "moneyBuckets(report.upcomingLoadByCurrency)",
    "money(report.realizedGrandTotal)": "moneyBuckets(report.realizedGrandTotalsByCurrency)",
}
for old, new in replacements.items():
    s = s.replace(old, new)

# Detail rows always use the record currency.
s = s.replace('money(detail.amount)', 'money(detail.amount, currencyCode: detail.income.currencyCode)')
s = s.replace('money(detail.payment.amount)', 'money(detail.payment.amount, currencyCode: detail.currencyCode)')
s = s.replace('money(record.amount)', 'money(record.amount, currencyCode: record.currencyCode)')
s = s.replace('money(expense.totalAmount)', 'money(expense.totalAmount, currencyCode: expense.currencyCode)')
s = s.replace('money(expense.unitPrice)', 'money(expense.unitPrice, currencyCode: expense.currencyCode)')

# Currency-safe distributions.
s = s.replace('report.realizedDistribution)', 'report.realizedDistributionByCurrency)')
s = s.replace('report.combinedOutflowDistribution)', 'report.combinedOutflowDistributionByCurrency)')

# Distribution entries carry currency into their formatter.
s = s.replace(
    "                amount: entry.amount,\n                icon: entry.type == null",
    "                amount: entry.amount,\n                currencyCode: entry.currencyCode,\n                icon: entry.type == null",
)
s = s.replace(
    "                amount: entry.amount,\n                icon: entry.type == null\n                    ? Icons.category_outlined",
    "                amount: entry.amount,\n                currencyCode: entry.currencyCode,\n                icon: entry.type == null\n                    ? Icons.category_outlined",
)

# Remaining distribution: derive from records rather than scalar by-type totals.
old = """          entries: [
            for (final type in RecordType.values)
              _ReportEntry(
                label: reportTypeLabel(type),
                amount: report.remainingTotalsByType[type] ?? 0,
                icon: recordIcon(type),
              ),
          ],
"""
new = """          entries: _remainingDistributionEntries(report),
"""
if old in s:
    s = s.replace(old, new, 1)

# Report metric detail items carry exact currency.
metric_start = s.index('class _ReportMetricDetailItem')
metric_end = s.index('class _ReportMetricDetailSheet', metric_start)
metric = s[metric_start:metric_end]
metric = metric.replace(
    "      color = MizanTheme.ink,\n      record = null,",
    "      color = MizanTheme.ink,\n      currencyCode = '',\n      record = null,",
)
if 'required this.currencyCode,' not in metric:
    metric = metric.replace('    required this.color,\n', '    required this.color,\n    required this.currencyCode,\n', 1)
if 'final String currencyCode;' not in metric:
    metric = metric.replace('  final Color color;\n', '  final Color color;\n  final String currencyCode;\n', 1)
s = s[:metric_start] + metric + s[metric_end:]

# Populate detail item currency.
for anchor, value in [
    ('            color: MizanTheme.green,\n', 'detail.expense.currencyCode'),
    ('            color: MizanTheme.blue,\n            payment: detail,\n', 'detail.currencyCode'),
    ('            color: statusColor(record.status),\n            record: record,\n', 'record.currencyCode'),
]:
    if value not in s[s.find(anchor)-120:s.find(anchor)+220] if s.find(anchor)>=0 else '':
        if anchor not in s:
            raise SystemExit(f'metric detail anchor missing for {value}')
        if 'payment:' in anchor or 'record:' in anchor:
            lines = anchor.splitlines(keepends=True)
            s = s.replace(anchor, lines[0] + f'            currencyCode: {value},\n' + ''.join(lines[1:]), 1)
        else:
            s = s.replace(anchor, anchor + f'            currencyCode: {value},\n', 1)

# Unit price inside metric detail subtitle.
s = s.replace(
    '${money(detail.expense.unitPrice)}',
    '${money(detail.expense.unitPrice, currencyCode: detail.expense.currencyCode)}',
)
# Metric detail trailing amount.
s = s.replace('money(item.amount)', 'money(item.amount, currencyCode: item.currencyCode)')

# Income/net inline totals switch from illegal scalar sums to buckets.
s = s.replace("_InlineTotal(label: 'Gelir', amount: report.totalIncome)", "_InlineTotal(label: 'Gelir', amounts: report.totalIncomeByCurrency)")
s = s.replace("amount: report.afterPayments,", "amounts: report.afterPaymentsByCurrency,")
s = s.replace("amount: report.finalNet,", "amounts: report.finalNetByCurrency,")
s = s.replace("amount: report.totalPayments,", "amounts: report.totalPaymentsByCurrency,")
s = s.replace("_InlineTotal(label: 'Normal giderler', amount: report.totalExpenses)", "_InlineTotal(label: 'Normal giderler', amounts: report.totalExpensesByCurrency)")
s = s.replace("_InlineTotal(label: 'Gelir sonrası net', amount: report.finalNet)", "_InlineTotal(label: 'Gelir sonrası net', amounts: report.finalNetByCurrency)")
inline_start = s.index('class _InlineTotal extends StatelessWidget')
inline_end = s.index('class _ReportEntry', inline_start)
inline = s[inline_start:inline_end]
inline = inline.replace('const _InlineTotal({required this.label, required this.amount});', 'const _InlineTotal({required this.label, required this.amounts});')
inline = inline.replace('final double amount;', 'final Map<String, double> amounts;')
inline = inline.replace('money(amount)', 'moneyBuckets(amounts)')
s = s[:inline_start] + inline + s[inline_end:]

# Report entries can format explicit currency.
entry_start = s.index('class _ReportEntry {')
entry_end = s.index('class _ReportSection', entry_start)
entry = s[entry_start:entry_end]
if 'this.currencyCode = ' not in entry:
    entry = entry.replace('    required this.icon,\n', "    required this.icon,\n    this.currencyCode = '',\n", 1)
    entry = entry.replace('  final IconData icon;\n', '  final IconData icon;\n  final String currencyCode;\n', 1)
s = s[:entry_start] + entry + s[entry_end:]
# If no code is supplied this is only safe for zero/legacy homogeneous uses.
s = s.replace(
    'money(item.amount, currencyCode: item.currencyCode)',
    "item.currencyCode.isEmpty\n                                  ? money(item.amount)\n                                  : money(item.amount, currencyCode: item.currencyCode)",
    1,
)

# Currency-safe remaining distribution helper.
helper_anchor = 'class _ReportSection extends StatelessWidget {'
if '_remainingDistributionEntries(MizanReport report)' not in s:
    helper = r'''List<_ReportEntry> _remainingDistributionEntries(MizanReport report) {
  final totals = <String, double>{};
  for (final record in report.remainingDetails) {
    final key = '${record.currencyCode}|${record.type.name}';
    totals[key] = (totals[key] ?? 0) + record.amount;
  }
  final result = <_ReportEntry>[];
  for (final entry in totals.entries) {
    final parts = entry.key.split('|');
    final type = RecordType.values.firstWhere((item) => item.name == parts[1]);
    result.add(
      _ReportEntry(
        label: reportTypeLabel(type),
        amount: entry.value,
        currencyCode: parts[0],
        icon: recordIcon(type),
      ),
    );
  }
  return result;
}

'''
    s = s.replace(helper_anchor, helper + helper_anchor, 1)

# Outflow day totals must stay separated by currency.
out_start = s.index('class _ReportOutflowDay {')
out_end = s.index('class _ReportOutflowGroupsState', out_start)
out = s[out_start:out_end]
old_totals = """  double get normalTotal =>
      expenses.fold<double>(0, (sum, item) => sum + item.expense.totalAmount);

  double get paymentTotal =>
      payments.fold<double>(0, (sum, item) => sum + item.payment.amount);

  double get total => normalTotal + paymentTotal;
"""
new_totals = r'''  Map<String, double> get totalsByCurrency {
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
if old_totals in out:
    out = out.replace(old_totals, new_totals, 1)
s = s[:out_start] + out + s[out_end:]
s = s.replace('money(group.total)', 'moneyBuckets(group.totalsByCurrency)')

# Expense day header gets buckets instead of a scalar.
s = s.replace(
    "              total: entry.value.fold<double>(\n                0,\n                (sum, item) => sum + item.expense.totalAmount,\n              ),",
    "              totals: {\n                for (final code in entry.value.map((item) => item.expense.currencyCode).toSet())\n                  code: entry.value\n                      .where((item) => item.expense.currencyCode == code)\n                      .fold<double>(0, (sum, item) => sum + item.expense.totalAmount),\n              },",
)
day_start = s.index('class _ReportExpenseDayHeader extends StatelessWidget')
day_end = s.index('class _ReportExpenseDetailCard', day_start)
day = s[day_start:day_end]
day = day.replace('required this.total,', 'required this.totals,')
day = day.replace('final double total;', 'final Map<String, double> totals;')
day = day.replace('money(total)', 'moneyBuckets(totals)')
s = s[:day_start] + day + s[day_end:]

# Person debt summaries derive buckets from records.
s = s.replace(
    "subtitle: Text('Toplam kalan: ${money(person.totalRemaining)}'),",
    "subtitle: Text(\n          'Toplam kalan: ${moneyBuckets(_recordBuckets(person.records))}',\n        ),",
)
s = s.replace(
    'money(widget.person.byType[widget.type] ?? 0)',
    'moneyBuckets(_recordBuckets(widget.person.records.where((item) => item.type == widget.type)))',
)
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
    if anchor not in s: raise SystemExit('record bucket helper anchor missing')
    s = s.replace(anchor, helper + anchor, 1)

p.write_text(s, encoding='utf-8')
subprocess.run(['dart', 'format', str(fmt), str(p)], check=True)
