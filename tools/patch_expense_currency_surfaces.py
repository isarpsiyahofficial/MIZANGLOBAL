from pathlib import Path
import subprocess

# ---- Expense browser: day totals retain ISO buckets; amount sorting is only
# meaningful when the whole result is homogeneous in one currency.
p = Path('lib/services/expense_browser_service.dart')
s = p.read_text(encoding='utf-8')
s = s.replace(
"""    required this.items,\n    required this.total,\n  });""",
"""    required this.items,\n    required this.total,\n    required this.totalsByCurrency,\n  });""",
1,
)
s = s.replace(
"""  final List<ExpenseItem> items;\n  final double total;""",
"""  final List<ExpenseItem> items;\n  final double total;\n  final Map<String, double> totalsByCurrency;""",
1,
)
old_group = """          return ExpenseDayGroup(\n            day: day,\n            items: List<ExpenseItem>.unmodifiable(items),\n            total: items.fold<double>(0, (sum, item) => sum + item.totalAmount),\n          );"""
new_group = """          final totalsByCurrency = <String, double>{};\n          for (final item in items) {\n            totalsByCurrency[item.currencyCode] =\n                (totalsByCurrency[item.currencyCode] ?? 0) + item.totalAmount;\n          }\n          return ExpenseDayGroup(\n            day: day,\n            items: List<ExpenseItem>.unmodifiable(items),\n            total: totalsByCurrency.length == 1\n                ? totalsByCurrency.values.single\n                : 0,\n            totalsByCurrency: Map<String, double>.unmodifiable(\n              totalsByCurrency,\n            ),\n          );"""
if old_group in s:
    s = s.replace(old_group, new_group, 1)
old_sort = """    result.sort(\n      (a, b) => switch (sort) {\n        ExpenseDaySort.newest => b.day.compareTo(a.day),\n        ExpenseDaySort.oldest => a.day.compareTo(b.day),\n        ExpenseDaySort.highestTotal =>\n          b.total.compareTo(a.total) != 0\n              ? b.total.compareTo(a.total)\n              : b.day.compareTo(a.day),\n        ExpenseDaySort.lowestTotal =>\n          a.total.compareTo(b.total) != 0\n              ? a.total.compareTo(b.total)\n              : b.day.compareTo(a.day),\n      },\n    );"""
new_sort = """    final resultCurrencies = <String>{\n      for (final group in result) ...group.totalsByCurrency.keys,\n    };\n    final canCompareAmounts = resultCurrencies.length == 1;\n    result.sort(\n      (a, b) => switch (sort) {\n        ExpenseDaySort.newest => b.day.compareTo(a.day),\n        ExpenseDaySort.oldest => a.day.compareTo(b.day),\n        ExpenseDaySort.highestTotal => canCompareAmounts\n            ? (b.total.compareTo(a.total) != 0\n                  ? b.total.compareTo(a.total)\n                  : b.day.compareTo(a.day))\n            : b.day.compareTo(a.day),\n        ExpenseDaySort.lowestTotal => canCompareAmounts\n            ? (a.total.compareTo(b.total) != 0\n                  ? a.total.compareTo(b.total)\n                  : b.day.compareTo(a.day))\n            : b.day.compareTo(a.day),\n      },\n    );"""
if old_sort in s:
    s = s.replace(old_sort, new_sort, 1)
p.write_text(s, encoding='utf-8')

# ---- Expenses screen: all aggregate values are currency bucket strings.
p = Path('lib/screens/expenses_screen.dart')
s = p.read_text(encoding='utf-8')
helper_anchor = 'class ExpensesScreen extends StatefulWidget {'
if 'Map<String, double> _expenseBuckets(' not in s:
    helper = r'''Map<String, double> _expenseBuckets(Iterable<ExpenseItem> items) {
  final result = <String, double>{};
  for (final item in items) {
    result[item.currencyCode] =
        (result[item.currencyCode] ?? 0) + item.totalAmount;
  }
  return result;
}

Map<String, double> _paymentExpenseBuckets(
  Iterable<ReportPaymentDetail> details,
) {
  final result = <String, double>{};
  for (final detail in details) {
    result[detail.currencyCode] =
        (result[detail.currencyCode] ?? 0) + detail.payment.amount;
  }
  return result;
}

Map<String, double> _sumExpenseBuckets(
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

'''
    if helper_anchor not in s:
        raise SystemExit('expenses helper anchor missing')
    s = s.replace(helper_anchor, helper + helper_anchor, 1)

old_totals = """    final visibleTotal = groups.fold<double>(\n      0,\n      (sum, group) => sum + group.total,\n    );"""
new_totals = """    final visibleTotalsByCurrency = _expenseBuckets(\n      groups.expand((group) => group.items),\n    );"""
if old_totals in s:
    s = s.replace(old_totals, new_totals, 1)
old_payment = """    final paymentTotal = paymentDetails.fold<double>(\n      0,\n      (sum, item) => sum + item.payment.amount,\n    );"""
new_payment = """    final paymentTotalsByCurrency = _paymentExpenseBuckets(paymentDetails);\n    final allTotalsByCurrency = _sumExpenseBuckets([\n      visibleTotalsByCurrency,\n      paymentTotalsByCurrency,\n    ]);\n    final todayExpenseTotalsByCurrency = state.expenseTotalsForRangeByCurrency(\n      now,\n      now,\n    );\n    final monthExpenseTotalsByCurrency = state.expenseTotalsForRangeByCurrency(\n      DateTime(now.year, now.month),\n      DateTime(now.year, now.month + 1, 0),\n    );"""
if old_payment in s:
    s = s.replace(old_payment, new_payment, 1)

replacements = {
    'money(state.expenseTotalForDay(now))': 'moneyBuckets(todayExpenseTotalsByCurrency)',
    'money(state.expenseTotalForMonth(now))': 'moneyBuckets(monthExpenseTotalsByCurrency)',
    'money(visibleTotal)': 'moneyBuckets(visibleTotalsByCurrency)',
    'money(paymentTotal)': 'moneyBuckets(paymentTotalsByCurrency)',
    'money(visibleTotal + paymentTotal)': 'moneyBuckets(allTotalsByCurrency)',
    "'${groups.length} gün · $visibleItems kayıt · ${money(visibleTotal)}'": "'${groups.length} gün · $visibleItems kayıt · ${moneyBuckets(visibleTotalsByCurrency)}'",
    'money(widget.group.total)': 'moneyBuckets(widget.group.totalsByCurrency)',
    'money(detail.payment.amount)': 'money(detail.payment.amount, currencyCode: detail.currencyCode)',
    'money(item.unitPrice)': 'money(item.unitPrice, currencyCode: item.currencyCode)',
    'money(item.totalAmount)': 'money(item.totalAmount, currencyCode: item.currencyCode)',
}
for old, new in replacements.items():
    s = s.replace(old, new)

# Category manager totals are bucketed.
s = s.replace(
    "'${widget.controller.state.expensesForCategory(category.id).length} gider · ${money(widget.controller.state.expenseTotalForCategory(category.id))}'",
    "'${widget.controller.state.expensesForCategory(category.id).length} gider · ${moneyBuckets(_expenseBuckets(widget.controller.state.expensesForCategory(category.id)))}'",
)

# Payment day sorting/headers must not compare or sum unlike currencies.
old_entries = """    final entries = groups.entries.toList()\n      ..sort((a, b) {\n        final aTotal = a.value.fold<double>(\n          0,\n          (sum, item) => sum + item.payment.amount,\n        );\n        final bTotal = b.value.fold<double>(\n          0,\n          (sum, item) => sum + item.payment.amount,\n        );\n        return switch (widget.sort) {\n          ExpenseDaySort.newest => b.key.compareTo(a.key),\n          ExpenseDaySort.oldest => a.key.compareTo(b.key),\n          ExpenseDaySort.highestTotal =>\n            bTotal.compareTo(aTotal) != 0\n                ? bTotal.compareTo(aTotal)\n                : b.key.compareTo(a.key),\n          ExpenseDaySort.lowestTotal =>\n            aTotal.compareTo(bTotal) != 0\n                ? aTotal.compareTo(bTotal)\n                : b.key.compareTo(a.key),\n        };\n      });"""
new_entries = """    final allPaymentCurrencies = widget.details\n        .map((detail) => detail.currencyCode)\n        .toSet();\n    final canComparePaymentAmounts = allPaymentCurrencies.length == 1;\n    final entries = groups.entries.toList()\n      ..sort((a, b) {\n        final aTotal = canComparePaymentAmounts\n            ? a.value.fold<double>(\n                0,\n                (sum, item) => sum + item.payment.amount,\n              )\n            : 0.0;\n        final bTotal = canComparePaymentAmounts\n            ? b.value.fold<double>(\n                0,\n                (sum, item) => sum + item.payment.amount,\n              )\n            : 0.0;\n        return switch (widget.sort) {\n          ExpenseDaySort.newest => b.key.compareTo(a.key),\n          ExpenseDaySort.oldest => a.key.compareTo(b.key),\n          ExpenseDaySort.highestTotal => canComparePaymentAmounts\n              ? (bTotal.compareTo(aTotal) != 0\n                    ? bTotal.compareTo(aTotal)\n                    : b.key.compareTo(a.key))\n              : b.key.compareTo(a.key),\n          ExpenseDaySort.lowestTotal => canComparePaymentAmounts\n              ? (aTotal.compareTo(bTotal) != 0\n                    ? aTotal.compareTo(bTotal)\n                    : b.key.compareTo(a.key))\n              : b.key.compareTo(a.key),\n        };\n      });"""
if old_entries in s:
    s = s.replace(old_entries, new_entries, 1)
s = s.replace(
    "'${entry.value.length} ödeme · ${money(entry.value.fold<double>(0, (sum, item) => sum + item.payment.amount))}'",
    "'${entry.value.length} ödeme · ${moneyBuckets(_paymentExpenseBuckets(entry.value))}'",
)

p.write_text(s, encoding='utf-8')
subprocess.run([
    'dart',
    'format',
    'lib/services/expense_browser_service.dart',
    'lib/screens/expenses_screen.dart',
], check=True)
