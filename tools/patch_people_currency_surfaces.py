from pathlib import Path
import subprocess

p = Path('lib/screens/people_screen.dart')
s = p.read_text(encoding='utf-8')

anchor = 'enum _PersonMetricKind { remaining, monthly, overdue }\n'
if 'Map<String, double> _peopleCurrencyBuckets(' not in s:
    helper = r'''
Map<String, double> _peopleCurrencyBuckets(
  Iterable<({String currencyCode, double amount})> items,
) {
  final result = <String, double>{};
  for (final item in items) {
    if (item.amount.abs() < 0.000001) continue;
    result[item.currencyCode] =
        (result[item.currencyCode] ?? 0) + item.amount;
  }
  return result;
}

Map<String, double> _personRemainingBuckets(PersonAccount person) {
  return _peopleCurrencyBuckets([
    for (final bank in person.banks)
      for (final item in bank.products.where((item) => !item.isArchived))
        (currencyCode: item.currencyCode, amount: item.remainingAmount),
    for (final item in person.personalDebts.where((item) => !item.isArchived))
      (currencyCode: item.currencyCode, amount: item.remainingAmount),
    for (final item in person.bills.where((item) => !item.isArchived))
      (currencyCode: item.currencyCode, amount: item.remainingAmount),
    for (final item in person.subscriptions.where((item) => !item.isArchived))
      (currencyCode: item.currencyCode, amount: item.remainingAmount),
    for (final item in person.rents.where((item) => !item.isArchived))
      (currencyCode: item.currencyCode, amount: item.remainingAmount),
  ]);
}

Map<String, double> _personMonthlyBuckets(PersonAccount person, DateTime month) {
  return _peopleCurrencyBuckets([
    for (final bank in person.banks)
      for (final item in bank.products.where(
        (item) => !item.isArchived && item.remainingAmount > 0 && item.isDueInMonth(month),
      ))
        (currencyCode: item.currencyCode, amount: item.scheduledPaymentAmount),
    for (final item in person.personalDebts.where(
      (item) => !item.isArchived && item.remainingAmount > 0 && item.isDueInMonth(month),
    ))
      (currencyCode: item.currencyCode, amount: item.effectiveDueAmount),
    for (final item in person.bills.where(
      (item) => !item.isArchived && item.isDueInMonth(month),
    ))
      (currencyCode: item.currencyCode, amount: item.amountForMonth(month)),
    for (final item in person.subscriptions.where(
      (item) => !item.isArchived && item.isDueInMonth(month),
    ))
      (currencyCode: item.currencyCode, amount: item.amount),
    for (final item in person.rents.where(
      (item) => !item.isArchived && item.isDueInMonth(month),
    ))
      (currencyCode: item.currencyCode, amount: item.plannedCycleAmount),
  ]);
}
'''
    if anchor not in s:
        raise SystemExit('person metric enum anchor missing')
    s = s.replace(anchor, anchor + helper, 1)

# Simple record group calls use bucket maps rather than mixed scalars.
replacements = {
"""            total: selected.personalDebts
                .where((item) => !item.isArchived)
                .fold<double>(0.0, (sum, item) => sum + item.remainingAmount),""": """            totals: _peopleCurrencyBuckets(
              selected.personalDebts
                  .where((item) => !item.isArchived)
                  .map(
                    (item) => (
                      currencyCode: item.currencyCode,
                      amount: item.remainingAmount,
                    ),
                  ),
            ),""",
"""            total: selected.bills
                .where((item) => !item.isArchived)
                .fold<double>(0.0, (sum, item) => sum + item.remainingAmount),""": """            totals: _peopleCurrencyBuckets(
              selected.bills
                  .where((item) => !item.isArchived)
                  .map(
                    (item) => (
                      currencyCode: item.currencyCode,
                      amount: item.remainingAmount,
                    ),
                  ),
            ),""",
"""            total: selected.subscriptions
                .where((item) => !item.isArchived)
                .fold<double>(0.0, (sum, item) => sum + item.remainingAmount),""": """            totals: _peopleCurrencyBuckets(
              selected.subscriptions
                  .where((item) => !item.isArchived)
                  .map(
                    (item) => (
                      currencyCode: item.currencyCode,
                      amount: item.remainingAmount,
                    ),
                  ),
            ),""",
"""            total: selected.rents
                .where((item) => !item.isArchived)
                .fold<double>(0.0, (sum, item) => sum + item.remainingAmount),""": """            totals: _peopleCurrencyBuckets(
              selected.rents
                  .where((item) => !item.isArchived)
                  .map(
                    (item) => (
                      currencyCode: item.currencyCode,
                      amount: item.remainingAmount,
                    ),
                  ),
            ),""",
}
for old, new in replacements.items():
    s = s.replace(old, new)

# Direct list rows use owning record currency.
s = s.replace('money(debt.remainingAmount)', 'money(debt.remainingAmount, currencyCode: debt.currencyCode)')
s = s.replace('money(item.remainingAmount)', 'money(item.remainingAmount, currencyCode: item.currencyCode)')
s = s.replace('money(currentDue)', 'money(currentDue, currencyCode: bill.currencyCode)', 1)
s = s.replace('money(outstanding)', 'money(outstanding, currencyCode: bill.currencyCode)', 1)
# Rent summary occurs after bill summary.
rent_start = s.find('class _RentSummaryCard')
if rent_start >= 0:
    rent_region = s[rent_start:]
    rent_region = rent_region.replace('money(currentDue)', 'money(currentDue, currencyCode: rent.currencyCode)', 1)
    rent_region = rent_region.replace('money(outstanding)', 'money(outstanding, currencyCode: rent.currencyCode)', 1)
    s = s[:rent_start] + rent_region

# Person selector aggregate cards.
s = s.replace('value: money(selected.totalDebt),', 'value: moneyBuckets(_personRemainingBuckets(selected)),')
s = s.replace('value: money(selected.monthlyLoadFor(now)),', 'value: moneyBuckets(_personMonthlyBuckets(selected, now)),')

# Bank group and card aggregates.
s = s.replace(
    "'${person.banks.length} banka grubu · Kalan ${money(total)}'",
    "'${person.banks.length} banka grubu · Kalan ${moneyBuckets(_peopleCurrencyBuckets([for (final bank in person.banks) for (final item in bank.products.where((item) => !item.isArchived)) (currencyCode: item.currencyCode, amount: item.remainingAmount)]))}'",
)
s = s.replace(
    "'${widget.bank.products.length} kayıt · Kalan ${money(widget.bank.totalDebt)}'",
    "'${widget.bank.products.length} kayıt · Kalan ${moneyBuckets(_peopleCurrencyBuckets(widget.bank.products.where((item) => !item.isArchived).map((item) => (currencyCode: item.currencyCode, amount: item.remainingAmount))))}'",
)
s = s.replace('money(debt.remainingAmount)', 'money(debt.remainingAmount, currencyCode: debt.currencyCode)')

# Simple group model field is now a bucket map.
s = s.replace('    required this.total,\n', '    required this.totals,\n', 1)
s = s.replace('  final double total;\n', '  final Map<String, double> totals;\n', 1)
s = s.replace("subtitle: Text('${widget.count} kayıt · Kalan ${money(widget.total)}'),", "subtitle: Text('${widget.count} kayıt · Kalan ${moneyBuckets(widget.totals)}'),")

# Metric rows carry currency explicitly.
row_start = s.index('class _PersonMetricRow {')
row_end = s.index('class _PersonMetricDetailSheet', row_start)
region = s[row_start:row_end]
region = region.replace('    required this.amount,\n', '    required this.amount,\n    required this.currencyCode,\n', 1)
region = region.replace('  final double amount;\n', '  final double amount;\n  final String currencyCode;\n', 1)
s = s[:row_start] + region + s[row_end:]

# Each metric row inherits its owning record currency.
for token, expr in [
    ('amount: product.remainingAmount,', 'product.currencyCode'),
    ('amount: debt.remainingAmount,', 'debt.currencyCode'),
    ('amount: bill.remainingAmount,', 'bill.currencyCode'),
    ('amount: subscription.remainingAmount,', 'subscription.currencyCode'),
    ('amount: rent.remainingAmount,', 'rent.currencyCode'),
    ('amount: product.scheduledPaymentAmount,', 'product.currencyCode'),
    ('amount: debt.effectiveDueAmount,', 'debt.currencyCode'),
    ('amount: bill.amountForMonth(month),', 'bill.currencyCode'),
    ('amount: subscription.amount,', 'subscription.currencyCode'),
    ('amount: rent.plannedCycleAmount,', 'rent.currencyCode'),
    ('amount: record.amount,', 'record.currencyCode'),
]:
    replacement = token + f'\n            currencyCode: {expr},'
    s = s.replace(token, replacement)

# Metric sheet totals are currency buckets.
s = s.replace(
    '      final total = rows.fold<double>(0, (sum, item) => sum + item.amount);',
    """      final totals = _peopleCurrencyBuckets(
        rows.map(
          (item) => (
            currencyCode: item.currencyCode,
            amount: item.amount,
          ),
        ),
      );""",
)
s = s.replace("_PersonMetricKind.remaining => 'Toplam ${money(total)}',", "_PersonMetricKind.remaining => 'Toplam ${moneyBuckets(totals)}',")
s = s.replace("'${monthLabel(now)} planı · Toplam ${money(total)}'", "'${monthLabel(now)} planı · Toplam ${moneyBuckets(totals)}'")
s = s.replace("'${rows.length} gecikmiş kayıt · Açık dönem toplamı ${money(total)}'", "'${rows.length} gecikmiş kayıt · Açık dönem toplamı ${moneyBuckets(totals)}'")
s = s.replace('money(row.amount)', 'money(row.amount, currencyCode: row.currencyCode)')

# Record detail carries owning currency into all metrics, payments and schedules.
detail_start = s.index('class _RecordDetailData {')
detail_end = s.index('_RecordDetailData _detailData(', detail_start)
region = s[detail_start:detail_end]
region = region.replace('    required this.amountLabel,\n', '    required this.amountLabel,\n    required this.currencyCode,\n', 1)
region = region.replace('  final String amountLabel;\n', '  final String amountLabel;\n  final String currencyCode;\n', 1)
s = s[:detail_start] + region + s[detail_end:]

# Insert currencyCode in every detail return based on the owner in each switch case.
case_specs = [
    ('case RecordType.debt:', 'amountLabel: \'Kalan borç\',', 'debt.currencyCode'),
    ('case RecordType.personalDebt:', 'amountLabel: \'Kalan borç\',', 'debt.currencyCode'),
    ('case RecordType.bill:', 'amountLabel: \'Kalan fatura\',', 'bill.currencyCode'),
    ('case RecordType.subscription:', 'amountLabel: \'Kalan abonelik\',', 'subscription.currencyCode'),
    ('case RecordType.rent:', 'amountLabel: \'Kalan kira / taksit\',', 'rent.currencyCode'),
]
for i, (case, amount_anchor, expr) in enumerate(case_specs):
    start = s.index(case, s.index('_RecordDetailData _detailData('))
    end = s.index(case_specs[i + 1][0], start) if i + 1 < len(case_specs) else len(s)
    region = s[start:end]
    if 'currencyCode:' not in region[:region.find('remainingAmount:')]:
        region = region.replace(amount_anchor, amount_anchor + f'\n        currencyCode: {expr},', 1)
    # Any money embedded in detailLines belongs to this record.
    region = region.replace('money(debt.monthlyAmount)', 'money(debt.monthlyAmount, currencyCode: debt.currencyCode)')
    region = region.replace('money(debt.limit!)', 'money(debt.limit!, currencyCode: debt.currencyCode)')
    region = region.replace('money(debt.usedLimit!)', 'money(debt.usedLimit!, currencyCode: debt.currencyCode)')
    s = s[:start] + region + s[end:]

s = s.replace('value: money(current.remainingAmount),', 'value: money(current.remainingAmount, currencyCode: current.currencyCode),')
s = s.replace('value: money(current.paidAmount),', 'value: money(current.paidAmount, currencyCode: current.currencyCode),')
s = s.replace('title: money(payment.amount),', 'title: money(payment.amount, currencyCode: current.currencyCode),')
s = s.replace("'${money(payment.amount)} tutarındaki ödeme", "'${money(payment.amount, currencyCode: current.currencyCode)} tutarındaki ödeme")
s = s.replace('_ScheduleCard(items: current.schedule)', '_ScheduleCard(items: current.schedule, currencyCode: current.currencyCode)')

# Schedule rows inherit owning record currency.
s = s.replace('const _ScheduleCard({required this.items});', 'const _ScheduleCard({required this.items, required this.currencyCode});')
s = s.replace('  final List<DueScheduleItem> items;\n', '  final List<DueScheduleItem> items;\n  final String currencyCode;\n', 1)
# Restrict trailing money replacement to schedule class.
schedule_start = s.index('class _ScheduleCard extends StatelessWidget')
schedule_end = s.index('class _RecordDetailData', schedule_start)
region = s[schedule_start:schedule_end]
region = region.replace('money(item.amount)', 'money(item.amount, currencyCode: currencyCode)')
s = s[:schedule_start] + region + s[schedule_end:]

p.write_text(s, encoding='utf-8')
subprocess.run(['dart', 'format', str(p)], check=True)
