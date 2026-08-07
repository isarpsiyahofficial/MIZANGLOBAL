#!/usr/bin/env python3
from pathlib import Path
import subprocess

p = Path('lib/screens/dashboard_screen.dart')
s = p.read_text(encoding='utf-8')

# Replace scalar fields only inside the dashboard cache object.
start = s.index('class _DashboardData {')
end = s.index("final Expando<_DashboardData>", start)
region = s[start:end]
for old, new in [
    ('required this.monthIncome,', 'required this.monthIncomeByCurrency,'),
    ('required this.todayPayments,', 'required this.todayPaymentsByCurrency,'),
    ('required this.monthPayments,', 'required this.monthPaymentsByCurrency,'),
    ('required this.todayExpenses,', 'required this.todayExpensesByCurrency,'),
    ('required this.monthExpenses,', 'required this.monthExpensesByCurrency,'),
    ('required this.monthOpenTotal,', 'required this.monthOpenByCurrency,'),
    ('final double monthIncome;', 'final Map<String, double> monthIncomeByCurrency;'),
    ('final double todayPayments;', 'final Map<String, double> todayPaymentsByCurrency;'),
    ('final double monthPayments;', 'final Map<String, double> monthPaymentsByCurrency;'),
    ('final double todayExpenses;', 'final Map<String, double> todayExpensesByCurrency;'),
    ('final double monthExpenses;', 'final Map<String, double> monthExpensesByCurrency;'),
    ('final double monthOpenTotal;', 'final Map<String, double> monthOpenByCurrency;'),
]:
    region = region.replace(old, new)
s = s[:start] + region + s[end:]

cache_anchor = "final Expando<_DashboardData> _dashboardDataCache = Expando<_DashboardData>(\n"
if 'Map<String, double> _dashboardRecordBuckets(' not in s:
    helper = r'''Map<String, double> _dashboardRecordBuckets(
  Iterable<RecordReference> records,
) {
  final result = <String, double>{};
  for (final record in records) {
    result[record.currencyCode] =
        (result[record.currencyCode] ?? 0) + record.amount;
  }
  return result;
}

Map<String, double> _dashboardPaymentBuckets(
  Iterable<ReportPaymentDetail> details,
) {
  final result = <String, double>{};
  for (final detail in details) {
    result[detail.currencyCode] =
        (result[detail.currencyCode] ?? 0) + detail.payment.amount;
  }
  return result;
}

Map<String, double> _dashboardSumBuckets(
  Iterable<Map<String, double>> maps,
) {
  final result = <String, double>{};
  for (final map in maps) {
    for (final entry in map.entries) {
      result[entry.key] = (result[entry.key] ?? 0) + entry.value;
    }
  }
  result.removeWhere((_, value) => value.abs() < 0.000001);
  return result;
}

Map<String, double> _dashboardSubtractBuckets(
  Map<String, double> income,
  Iterable<Map<String, double>> outflows,
) {
  final result = <String, double>{...income};
  for (final map in outflows) {
    for (final entry in map.entries) {
      result[entry.key] = (result[entry.key] ?? 0) - entry.value;
    }
  }
  result.removeWhere((_, value) => value.abs() < 0.000001);
  return result;
}

Map<String, double> _dashboardRemainingByType(
  MizanState state,
  RecordType type,
) {
  final result = <String, double>{};
  void add(String code, double amount) {
    if (amount <= 0) return;
    result[code] = (result[code] ?? 0) + amount;
  }
  switch (type) {
    case RecordType.debt:
      for (final item in state.allDebtProducts.where((item) => !item.isArchived)) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
    case RecordType.personalDebt:
      for (final item in state.allPersonalDebts.where((item) => !item.isArchived)) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
    case RecordType.bill:
      for (final item in state.allBills.where((item) => !item.isArchived)) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
    case RecordType.subscription:
      for (final item in state.allSubscriptions.where((item) => !item.isArchived)) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
    case RecordType.rent:
      for (final item in state.allRents.where((item) => !item.isArchived)) {
        add(item.currencyCode, item.remainingAmount);
      }
      break;
  }
  return result;
}

'''
    if cache_anchor not in s:
        raise SystemExit('dashboard cache anchor missing')
    s = s.replace(cache_anchor, helper + cache_anchor, 1)

old = """      data = _DashboardData(
        dayStamp: dayStamp,
        records: records,
        critical: critical,
        monthIncome: state.incomeTotalForMonth(now),
        todayPayments: state.actualPaymentTotalForDay(now),
        monthPayments: state.actualPaymentTotalForMonth(now),
        todayExpenses: state.expenseTotalForDay(now),
        monthExpenses: state.expenseTotalForMonth(now),
        monthOpenRecords: monthOpenRecords,
        monthOpenTotal: monthOpenRecords.fold<double>(
          0,
          (sum, item) => sum + item.amount,
        ),
        monthPaymentDetails: monthPaymentDetails,
      );
"""
new = """      final monthStart = DateTime(now.year, now.month);
      final monthEnd = DateTime(now.year, now.month + 1, 0);
      final todayPaymentDetails = monthPaymentDetails
          .where((item) => dateOnly(item.payment.paidAt) == dateOnly(now))
          .toList(growable: false);
      data = _DashboardData(
        dayStamp: dayStamp,
        records: records,
        critical: critical,
        monthIncomeByCurrency: state.incomeTotalsForRangeByCurrency(
          monthStart,
          monthEnd,
        ),
        todayPaymentsByCurrency: _dashboardPaymentBuckets(todayPaymentDetails),
        monthPaymentsByCurrency: _dashboardPaymentBuckets(monthPaymentDetails),
        todayExpensesByCurrency: state.expenseTotalsForRangeByCurrency(now, now),
        monthExpensesByCurrency: state.expenseTotalsForRangeByCurrency(
          monthStart,
          monthEnd,
        ),
        monthOpenRecords: monthOpenRecords,
        monthOpenByCurrency: _dashboardRecordBuckets(monthOpenRecords),
        monthPaymentDetails: monthPaymentDetails,
      );
"""
if old not in s:
    raise SystemExit('dashboard cache construction anchor missing')
s = s.replace(old, new, 1)

old = """    final monthIncome = resolvedData.monthIncome;
    final todayPayments = resolvedData.todayPayments;
    final monthPayments = resolvedData.monthPayments;
    final todayExpenses = resolvedData.todayExpenses;
    final monthExpenses = resolvedData.monthExpenses;
    final monthOpenRecords = resolvedData.monthOpenRecords;
    final monthOpenTotal = resolvedData.monthOpenTotal;
    final monthPaymentDetails = resolvedData.monthPaymentDetails;
    final todayTotalOutflow = todayExpenses + todayPayments;
    final monthTotalOutflow = monthExpenses + monthPayments;
"""
new = """    final monthIncome = resolvedData.monthIncomeByCurrency;
    final todayPayments = resolvedData.todayPaymentsByCurrency;
    final monthPayments = resolvedData.monthPaymentsByCurrency;
    final todayExpenses = resolvedData.todayExpensesByCurrency;
    final monthExpenses = resolvedData.monthExpensesByCurrency;
    final monthOpenRecords = resolvedData.monthOpenRecords;
    final monthOpenTotal = resolvedData.monthOpenByCurrency;
    final monthPaymentDetails = resolvedData.monthPaymentDetails;
    final todayTotalOutflow = _dashboardSumBuckets([
      todayExpenses,
      todayPayments,
    ]);
    final monthTotalOutflow = _dashboardSumBuckets([
      monthExpenses,
      monthPayments,
    ]);
"""
if old not in s:
    raise SystemExit('dashboard resolved aliases anchor missing')
s = s.replace(old, new, 1)

s = s.replace(
    "          monthIncome: monthIncome,\n          afterPayments: monthIncome - monthPayments,\n          finalNet: monthIncome - monthPayments - monthExpenses,",
    "          monthIncome: monthIncome,\n          afterPayments: _dashboardSubtractBuckets(monthIncome, [monthPayments]),\n          finalNet: _dashboardSubtractBuckets(\n            monthIncome,\n            [monthPayments, monthExpenses],\n          ),",
)
s = s.replace('value: money(state.totalDebt),', 'value: moneyBuckets(state.recordRemainingTotalsByCurrency()),')
s = s.replace('value: money(monthOpenTotal + monthPayments),', 'value: moneyBuckets(_dashboardSumBuckets([monthOpenTotal, monthPayments])),')
s = s.replace("'Açık plan ${money(monthOpenTotal)} · Bu ay yapılan ${money(monthPayments)}'", "'Açık plan ${moneyBuckets(monthOpenTotal)} · Bu ay yapılan ${moneyBuckets(monthPayments)}'")
s = s.replace('value: money(state.overdueTotalAt(now)),', "value: moneyBuckets(\n                _dashboardRecordBuckets(\n                  records.where((item) => item.status == PaymentStatus.overdue),\n                ),\n              ),")
s = s.replace('value: money(state.dueWithinDaysTotal(now, 7)),', "value: moneyBuckets(\n                _dashboardRecordBuckets(\n                  records.where((item) {\n                    final days = calendarDaysBetween(now, item.dueDate);\n                    return days >= 0 && days <= 7 && item.amount > 0;\n                  }),\n                ),\n              ),")
for name in ['todayExpenses', 'monthExpenses', 'todayPayments', 'monthPayments', 'todayTotalOutflow', 'monthTotalOutflow']:
    s = s.replace(f'value: money({name}),', f'value: moneyBuckets({name}),')

s = s.replace('${money(record.amount)}', '${money(record.amount, currencyCode: record.currencyCode)}')
s = s.replace('money(record.amount)', 'money(record.amount, currencyCode: record.currencyCode)')
s = s.replace('money(detail.payment.amount)', 'money(detail.payment.amount, currencyCode: detail.currencyCode)')

start = s.index('  Future<void> _showDebtBreakdown(')
end = s.index('  Future<void> _showMonthlyPaymentOverview(', start)
region = s[start:end]
old_group = """    final groups = <({String title, double amount, RecordType? type})>[
      (
        title: 'Banka borçları',
        amount: state.bankDebtTotal,
        type: RecordType.debt,
      ),
      (
        title: 'Kişisel ve kurumsal borçlar',
        amount: state.personalCorporateDebtTotal,
        type: RecordType.personalDebt,
      ),
      (title: 'Faturalar', amount: state.billTotal, type: RecordType.bill),
      (
        title: 'Abonelikler',
        amount: state.subscriptionTotal,
        type: RecordType.subscription,
      ),
      (
        title: 'Kira ve taksitler',
        amount: state.rentInstallmentTotal,
        type: RecordType.rent,
      ),
      (title: 'Gecikmiş toplam', amount: state.overdueTotalAt(now), type: null),
      (
        title: 'Önümüzdeki 7 gün',
        amount: state.dueWithinDaysTotal(now, 7),
        type: null,
      ),
    ];
"""
new_group = """    final references = state.recordReferencesAt(now);
    final groups = <({String title, Map<String, double> amounts, RecordType? type})>[
      for (final type in RecordType.values)
        (
          title: type.label,
          amounts: _dashboardRemainingByType(state, type),
          type: type,
        ),
      (
        title: 'Gecikmiş toplam',
        amounts: _dashboardRecordBuckets(
          references.where((item) => item.status == PaymentStatus.overdue),
        ),
        type: null,
      ),
      (
        title: 'Önümüzdeki 7 gün',
        amounts: _dashboardRecordBuckets(
          references.where((item) {
            final days = calendarDaysBetween(now, item.dueDate);
            return days >= 0 && days <= 7 && item.amount > 0;
          }),
        ),
        type: null,
      ),
    ];
"""
if old_group not in region:
    raise SystemExit('debt group anchor missing')
region = region.replace(old_group, new_group, 1)
region = region.replace('subtitle: money(group.amount),', 'subtitle: moneyBuckets(group.amounts),')
region = region.replace('leadingColor: group.amount > 0', 'leadingColor: group.amounts.values.any((amount) => amount > 0)')
s = s[:start] + region + s[end:]

s = s.replace(
    "'${openRecords.length} açık kayıt · ${money(openRecords.fold<double>(0, (sum, item) => sum + item.amount))}'",
    "'${openRecords.length} açık kayıt · ${moneyBuckets(_dashboardRecordBuckets(openRecords))}'",
)
s = s.replace(
    "'${paymentDetails.length} ödeme · ${money(paymentDetails.fold<double>(0, (sum, item) => sum + item.payment.amount))}'",
    "'${paymentDetails.length} ödeme · ${moneyBuckets(_dashboardPaymentBuckets(paymentDetails))}'",
)

start = s.index('class _IncomeOverviewCard extends StatelessWidget')
end = s.index('class _IncomeLine extends StatelessWidget', start)
region = s[start:end]
region = region.replace('final double monthIncome;', 'final Map<String, double> monthIncome;')
region = region.replace('final double afterPayments;', 'final Map<String, double> afterPayments;')
region = region.replace('final double finalNet;', 'final Map<String, double> finalNet;')
region = region.replace('money(monthIncome)', 'moneyBuckets(monthIncome)')
region = region.replace('money(afterPayments)', 'moneyBuckets(afterPayments)')
region = region.replace('money(finalNet)', 'moneyBuckets(finalNet)')
s = s[:start] + region + s[end:]

p.write_text(s, encoding='utf-8')
subprocess.run(['dart', 'format', str(p)], check=True)
