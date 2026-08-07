#!/usr/bin/env python3
from pathlib import Path

p = Path('lib/services/report_service.dart')
s = p.read_text(encoding='utf-8')

# Payment details must carry the owning record currency.
s = s.replace(
"""    required this.recordSubtitle,\n    required this.payment,\n  });""",
"""    required this.recordSubtitle,\n    required this.currencyCode,\n    required this.payment,\n  });""",
1,
)
s = s.replace(
"""  final String recordSubtitle;\n  final PaymentRecord payment;""",
"""  final String recordSubtitle;\n  final String currencyCode;\n  final PaymentRecord payment;""",
1,
)

# Person debt summary keeps currency buckets explicitly; no semantic cross-currency total.
s = s.replace(
"""    required this.totalRemaining,\n    required this.byType,\n    required this.records,""",
"""    required this.totalRemaining,\n    required this.totalsByCurrency,\n    required this.byType,\n    required this.records,""",
1,
)
s = s.replace(
"""  final double totalRemaining;\n  final Map<RecordType, double> byType;""",
"""  final double totalRemaining;\n  final Map<String, double> totalsByCurrency;\n  final Map<RecordType, double> byType;""",
1,
)

# Add release-critical currency bucket maps to report snapshot.
ctor_anchor = """    required this.incomeDetails,\n    required this.paymentTotalsByType,"""
ctor_new = """    required this.incomeDetails,\n    required this.incomeTotalsByCurrency,\n    required this.paymentTotalsByCurrency,\n    required this.expenseTotalsByCurrency,\n    required this.remainingTotalsByCurrency,\n    required this.overdueTotalsByCurrency,\n    required this.upcomingTotalsByCurrency,\n    required this.paymentTotalsByType,"""
if 'required this.incomeTotalsByCurrency' not in s:
    if ctor_anchor not in s: raise SystemExit('report constructor anchor missing')
    s = s.replace(ctor_anchor, ctor_new, 1)

field_anchor = """  final List<ReportIncomeDetail> incomeDetails;\n  final Map<RecordType, double> paymentTotalsByType;"""
field_new = """  final List<ReportIncomeDetail> incomeDetails;\n  final Map<String, double> incomeTotalsByCurrency;\n  final Map<String, double> paymentTotalsByCurrency;\n  final Map<String, double> expenseTotalsByCurrency;\n  final Map<String, double> remainingTotalsByCurrency;\n  final Map<String, double> overdueTotalsByCurrency;\n  final Map<String, double> upcomingTotalsByCurrency;\n  final Map<RecordType, double> paymentTotalsByType;"""
if 'final Map<String, double> incomeTotalsByCurrency;' not in s:
    if field_anchor not in s: raise SystemExit('report field anchor missing')
    s = s.replace(field_anchor, field_new, 1)

# Add helpers for UI/PDF to render currencies as separate dynamic sections.
helper_anchor = """  DateTime get balanceReference {"""
helper_code = """  List<String> get activeCurrencyCodes {\n    final codes = <String>{\n      ...incomeTotalsByCurrency.keys,\n      ...paymentTotalsByCurrency.keys,\n      ...expenseTotalsByCurrency.keys,\n      ...remainingTotalsByCurrency.keys,\n      ...overdueTotalsByCurrency.keys,\n      ...upcomingTotalsByCurrency.keys,\n    }.where((item) => item.isNotEmpty).toList(growable: false)\n      ..sort();\n    return codes;\n  }\n\n  double totalForCurrency(Map<String, double> buckets, String currency) =>\n      buckets[currency] ?? 0;\n\n  DateTime get balanceReference {"""
if 'List<String> get activeCurrencyCodes' not in s:
    if helper_anchor not in s: raise SystemExit('helper insertion anchor missing')
    s = s.replace(helper_anchor, helper_code, 1)

# paymentDetailsForRange addPayments carries record currency.
s = s.replace(
"""      required String subtitle,\n      required Iterable<PaymentRecord> payments,""",
"""      required String subtitle,\n      required String currencyCode,\n      required Iterable<PaymentRecord> payments,""",
1,
)
s = s.replace(
"""            recordSubtitle: subtitle,\n            payment: payment,""",
"""            recordSubtitle: subtitle,\n            currencyCode: currencyCode,\n            payment: payment,""",
1,
)
for owner, anchor in [
    ('debt', "subtitle: '${bank.userWrittenName} · ${debt.displayKind}',\n            payments: debt.payments,"),
    ('debt', "subtitle: '${debt.creditorType.label} · ${debt.displayCreditor}',\n          payments: debt.payments,"),
    ('bill', "subtitle: bill.institutionName,\n          payments: bill.payments,"),
    ('subscription', "subtitle: subscription.providerName,\n          payments: subscription.payments,"),
    ('rent', "subtitle: rent.receiverName,\n          payments: rent.payments,"),
]:
    replacement = anchor.replace('payments:', f'currencyCode: {owner}.currencyCode,\n          payments:')
    if anchor in s and replacement not in s:
        s = s.replace(anchor, replacement, 1)

# Build-time bucket creation after income details.
income_anchor = """        .where((item) => item.amount > 0)\n        .toList(growable: false);\n\n    final paymentTotals = <RecordType, double>{"""
income_new = """        .where((item) => item.amount > 0)\n        .toList(growable: false);\n    final incomeTotalsByCurrency = <String, double>{};\n    for (final detail in incomeDetails) {\n      final code = detail.income.currencyCode;\n      incomeTotalsByCurrency[code] =\n          (incomeTotalsByCurrency[code] ?? 0) + detail.amount;\n    }\n\n    final paymentTotalsByCurrency = <String, double>{};\n    final paymentTotals = <RecordType, double>{"""
if 'final incomeTotalsByCurrency = <String, double>{};' not in s:
    if income_anchor not in s: raise SystemExit('income bucket anchor missing')
    s = s.replace(income_anchor, income_new, 1)

# Second addPayments in build: add currency param and bucket accumulation.
start = s.find('    final paymentDetails = <ReportPaymentDetail>[];', s.find('  MizanReport build('))
if start < 0: raise SystemExit('build payment details anchor missing')
section_end = s.find('    for (final person in includedPeople)', start)
section = s[start:section_end]
section = section.replace(
"""      required String subtitle,\n      required Iterable<PaymentRecord> payments,""",
"""      required String subtitle,\n      required String currencyCode,\n      required Iterable<PaymentRecord> payments,""",
1,
)
section = section.replace(
"""        paymentTotals[type] = (paymentTotals[type] ?? 0) + payment.amount;""",
"""        paymentTotals[type] = (paymentTotals[type] ?? 0) + payment.amount;\n        paymentTotalsByCurrency[currencyCode] =\n            (paymentTotalsByCurrency[currencyCode] ?? 0) + payment.amount;""",
1,
)
section = section.replace(
"""            recordSubtitle: subtitle,\n            payment: payment,""",
"""            recordSubtitle: subtitle,\n            currencyCode: currencyCode,\n            payment: payment,""",
1,
)
s = s[:start] + section + s[section_end:]

# Add currency arguments to build calls (only remaining missing instances).
for owner, anchor in [
    ('debt', "subtitle: '${bank.userWrittenName} · ${debt.displayKind}',\n            payments: debt.payments,"),
    ('debt', "subtitle: '${debt.creditorType.label} · ${debt.displayCreditor}',\n          payments: debt.payments,"),
    ('bill', "subtitle: bill.institutionName,\n          payments: bill.payments,"),
    ('subscription', "subtitle: subscription.providerName,\n          payments: subscription.payments,"),
    ('rent', "subtitle: rent.receiverName,\n          payments: rent.payments,"),
]:
    replacement = anchor.replace('payments:', f'currencyCode: {owner}.currencyCode,\n          payments:')
    while anchor in s:
        s = s.replace(anchor, replacement, 1)

# Expense buckets.
expense_anchor = """    final expenseTotals = <String, double>{};\n    for (final item in expenseDetails) {\n      expenseTotals[item.categoryName] =\n          (expenseTotals[item.categoryName] ?? 0) + item.expense.totalAmount;\n    }"""
expense_new = expense_anchor + """\n    final expenseTotalsByCurrency = <String, double>{};\n    for (final item in expenseDetails) {\n      final code = item.expense.currencyCode;\n      expenseTotalsByCurrency[code] =\n          (expenseTotalsByCurrency[code] ?? 0) + item.expense.totalAmount;\n    }"""
if 'final expenseTotalsByCurrency = <String, double>{};' not in s:
    if expense_anchor not in s: raise SystemExit('expense bucket anchor missing')
    s = s.replace(expense_anchor, expense_new, 1)

# Remaining / overdue / upcoming buckets.
remaining_anchor = """    for (final record in remaining) {\n      remainingTotals[record.type] =\n          (remainingTotals[record.type] ?? 0) + record.amount;\n    }"""
remaining_new = remaining_anchor + """\n    final remainingTotalsByCurrency = <String, double>{};\n    final overdueTotalsByCurrency = <String, double>{};\n    for (final record in remaining) {\n      remainingTotalsByCurrency[record.currencyCode] =\n          (remainingTotalsByCurrency[record.currencyCode] ?? 0) + record.amount;\n      if (record.status == PaymentStatus.overdue) {\n        overdueTotalsByCurrency[record.currencyCode] =\n            (overdueTotalsByCurrency[record.currencyCode] ?? 0) + record.amount;\n      }\n    }"""
if 'final remainingTotalsByCurrency = <String, double>{};' not in s:
    if remaining_anchor not in s: raise SystemExit('remaining bucket anchor missing')
    s = s.replace(remaining_anchor, remaining_new, 1)

upcoming_anchor = """          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));\n\n    final personDebtDetails = <ReportPersonDebtDetail>[];"""
upcoming_new = """          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));\n    final upcomingTotalsByCurrency = <String, double>{};\n    for (final record in upcomingDetails) {\n      upcomingTotalsByCurrency[record.currencyCode] =\n          (upcomingTotalsByCurrency[record.currencyCode] ?? 0) + record.amount;\n    }\n\n    final personDebtDetails = <ReportPersonDebtDetail>[];"""
if 'final upcomingTotalsByCurrency = <String, double>{};' not in s:
    if upcoming_anchor not in s: raise SystemExit('upcoming bucket anchor missing')
    s = s.replace(upcoming_anchor, upcoming_new, 1)

# Person summaries: expose buckets and avoid sorting people by meaningless cross-currency sums.
person_anchor = """      personDebtDetails.add(\n        ReportPersonDebtDetail(\n          personId: person.id,\n          personName: person.name,\n          totalRemaining: records.fold<double>(\n            0,\n            (sum, record) => sum + record.amount,\n          ),\n          byType: byType,\n          records: records,\n        ),\n      );\n    }\n    personDebtDetails.sort(\n      (a, b) => b.totalRemaining.compareTo(a.totalRemaining),\n    );"""
person_new = """      final totalsByCurrency = <String, double>{};\n      for (final record in records) {\n        totalsByCurrency[record.currencyCode] =\n            (totalsByCurrency[record.currencyCode] ?? 0) + record.amount;\n      }\n      personDebtDetails.add(\n        ReportPersonDebtDetail(\n          personId: person.id,\n          personName: person.name,\n          totalRemaining: totalsByCurrency.length <= 1\n              ? totalsByCurrency.values.fold<double>(0, (sum, value) => sum + value)\n              : 0,\n          totalsByCurrency: totalsByCurrency,\n          byType: byType,\n          records: records,\n        ),\n      );\n    }\n    personDebtDetails.sort((a, b) => a.personName.compareTo(b.personName));"""
if 'totalsByCurrency: totalsByCurrency' not in s:
    if person_anchor not in s: raise SystemExit('person bucket anchor missing')
    s = s.replace(person_anchor, person_new, 1)

# Return report fields.
return_anchor = """      incomeSpecified: incomeSpecified,\n      incomeDetails: incomeDetails,\n      paymentTotalsByType: paymentTotals,"""
return_new = """      incomeSpecified: incomeSpecified,\n      incomeDetails: incomeDetails,\n      incomeTotalsByCurrency: incomeTotalsByCurrency,\n      paymentTotalsByCurrency: paymentTotalsByCurrency,\n      expenseTotalsByCurrency: expenseTotalsByCurrency,\n      remainingTotalsByCurrency: remainingTotalsByCurrency,\n      overdueTotalsByCurrency: overdueTotalsByCurrency,\n      upcomingTotalsByCurrency: upcomingTotalsByCurrency,\n      paymentTotalsByType: paymentTotals,"""
if 'incomeTotalsByCurrency: incomeTotalsByCurrency' not in s:
    if return_anchor not in s: raise SystemExit('report return anchor missing')
    s = s.replace(return_anchor, return_new, 1)

# Every manually-built remaining reference must preserve the owning record currency.
for owner, anchor in [
    ('debt', 'sourceId: debt.id,\n            bankId: bank.id,'),
    ('debt', 'sourceId: debt.id,\n          title: debt.title,'),
    ('bill', 'sourceId: bill.id,\n          title: bill.kind.label,'),
    ('subscription', 'sourceId: subscription.id,\n          title: subscription.title,'),
    ('rent', 'sourceId: rent.id,\n          title: rent.title,'),
]:
    replacement = anchor.replace('\n', f'\n          currencyCode: {owner}.currencyCode,\n', 1)
    if anchor in s and f'currencyCode: {owner}.currencyCode' not in s[s.find(anchor)-80:s.find(anchor)+len(anchor)+120]:
        s = s.replace(anchor, replacement, 1)

p.write_text(s, encoding='utf-8')

# Add a focused isolation contract.
t = Path('test/report_multicurrency_isolation_test.dart')
t.write_text(r'''import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

void main() {
  test('report keeps income expense payment and remaining totals in ISO buckets', () {
    final now = DateTime(2026, 8, 7);
    final state = MizanState.fromJson({
      'schemaVersion': 14,
      'setupCompleted': true,
      'appLanguageTag': 'en',
      'debtRegionCountryCode': 'US',
      'defaultCurrencyCode': 'USD',
      'people': [
        {
          'id': 'p1',
          'name': 'Owner',
          'banks': [
            {
              'id': 'b1',
              'userWrittenName': 'Bank',
              'products': [
                {
                  'id': 'd1',
                  'currencyCode': 'EUR',
                  'kind': 'loan',
                  'title': 'Euro loan',
                  'totalAmount': 1000,
                  'monthlyAmount': 100,
                  'dueDate': '2026-08-20T00:00:00.000',
                  'payments': [
                    {'id':'pay1','amount':40,'paidAt':'2026-08-07T00:00:00.000'}
                  ],
                },
              ],
            },
          ],
          'personalDebts': [],
          'bills': [],
          'subscriptions': [],
          'rents': [
            {
              'id':'r1',
              'currencyCode':'TRY',
              'kind':'homeRent',
              'title':'Rent',
              'amount':20000,
              'paymentDay':20,
              'receiverName':'Owner',
              'dueDate':'2026-08-20T00:00:00.000'
            }
          ],
        }
      ],
      'expenseCategories': [{'id':'c1','name':'Food','colorValue':4278190080}],
      'expenses': [
        {'id':'e1','currencyCode':'AED','categoryId':'c1','name':'Meal','quantity':1,'unitPrice':50,'spentAt':'2026-08-07T00:00:00.000'}
      ],
      'incomes': [
        {'id':'i1','currencyCode':'CAD','title':'Salary','amount':3000,'frequency':'monthly','startDate':'2026-08-01T00:00:00.000'}
      ],
      'notificationSlots': [],
      'paymentNotificationSlots': [],
    });
    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );
    expect(report.incomeTotalsByCurrency['CAD'], 3000);
    expect(report.expenseTotalsByCurrency['AED'], 50);
    expect(report.paymentTotalsByCurrency['EUR'], 40);
    expect(report.remainingTotalsByCurrency.keys, containsAll(['EUR','TRY']));
    expect(report.activeCurrencyCodes, containsAll(['AED','CAD','EUR','TRY']));
    expect(report.paymentDetails.single.currencyCode, 'EUR');
    expect(report.remainingDetails.every((r) => r.currencyCode.isNotEmpty), isTrue);
  });
}
''', encoding='utf-8')
