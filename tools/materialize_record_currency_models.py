#!/usr/bin/env python3
from pathlib import Path
import subprocess

p = Path('lib/services/report_service.dart')
s = p.read_text(encoding='utf-8')

# Payment details carry the owning record currency.
old = "    required this.recordSubtitle,\n    required this.payment,\n"
new = "    required this.recordSubtitle,\n    required this.currencyCode,\n    required this.payment,\n"
if 'required this.currencyCode,' not in s[s.index('class ReportPaymentDetail'):s.index('class ReportExpenseDetail')]:
    if old not in s: raise SystemExit('ReportPaymentDetail constructor anchor missing')
    s = s.replace(old, new, 1)
field_anchor = '  final String recordSubtitle;\n  final PaymentRecord payment;\n'
field_new = '  final String recordSubtitle;\n  final String currencyCode;\n  final PaymentRecord payment;\n'
if field_new not in s:
    if field_anchor not in s: raise SystemExit('ReportPaymentDetail field anchor missing')
    s = s.replace(field_anchor, field_new, 1)

# Distribution entries can identify their currency without breaking old callers.
dist_start = s.index('class ReportDistributionEntry')
dist_end = s.index('class ReportInstallmentDetail', dist_start)
dist = s[dist_start:dist_end]
if 'this.currencyCode' not in dist:
    dist = dist.replace('    this.expenseCategory,\n', "    this.expenseCategory,\n    this.currencyCode = '',\n", 1)
    dist = dist.replace('  final String? expenseCategory;\n', '  final String? expenseCategory;\n  final String currencyCode;\n', 1)
    s = s[:dist_start] + dist + s[dist_end:]

# Add currency-safe aggregate API while retaining legacy scalar getters for
# backwards source compatibility. User-visible global UI will use these maps.
report_start = s.index('class MizanReport {')
report_end = s.index('\nclass MizanReportService', report_start)
report = s[report_start:report_end]
if 'Map<String, double> get totalIncomeByCurrency' not in report:
    anchor = '  double get totalIncome =>\n'
    idx = report.index(anchor)
    block = r'''  String _resolvedReportCurrency(String value) {
    final code = value.trim().toUpperCase();
    if (RegExp(r'^[A-Z]{3}$').hasMatch(code)) return code;
    final fallback = currencyCode.trim().toUpperCase();
    return RegExp(r'^[A-Z]{3}$').hasMatch(fallback) ? fallback : 'TRY';
  }

  void _addCurrencyAmount(
    Map<String, double> target,
    String code,
    double amount,
  ) {
    if (amount == 0) return;
    final resolved = _resolvedReportCurrency(code);
    target[resolved] = (target[resolved] ?? 0) + amount;
  }

  Map<String, double> _combineCurrencyMaps(
    Iterable<Map<String, double>> maps,
  ) {
    final result = <String, double>{};
    for (final map in maps) {
      for (final entry in map.entries) {
        _addCurrencyAmount(result, entry.key, entry.value);
      }
    }
    result.removeWhere((_, value) => value.abs() < 0.000001);
    return result;
  }

  Map<String, double> get totalIncomeByCurrency {
    final result = <String, double>{};
    for (final detail in incomeDetails) {
      _addCurrencyAmount(result, detail.income.currencyCode, detail.amount);
    }
    return result;
  }

  Map<String, double> get totalPaymentsByCurrency {
    final result = <String, double>{};
    for (final detail in paymentDetails) {
      _addCurrencyAmount(result, detail.currencyCode, detail.payment.amount);
    }
    return result;
  }

  Map<String, double> get totalExpensesByCurrency {
    final result = <String, double>{};
    for (final detail in expenseDetails) {
      _addCurrencyAmount(
        result,
        detail.expense.currencyCode,
        detail.expense.totalAmount,
      );
    }
    return result;
  }

  Map<String, double> get realizedGrandTotalsByCurrency =>
      _combineCurrencyMaps([totalPaymentsByCurrency, totalExpensesByCurrency]);

  Map<String, double> get remainingLoadByCurrency {
    final result = <String, double>{};
    for (final item in remainingDetails) {
      _addCurrencyAmount(result, item.currencyCode, item.amount);
    }
    return result;
  }

  Map<String, double> get overdueLoadByCurrency {
    final result = <String, double>{};
    for (final item in remainingDetails.where(
      (item) => item.status == PaymentStatus.overdue,
    )) {
      _addCurrencyAmount(result, item.currencyCode, item.amount);
    }
    return result;
  }

  Map<String, double> get upcomingLoadByCurrency {
    final result = <String, double>{};
    for (final item in upcomingDetails) {
      _addCurrencyAmount(result, item.currencyCode, item.amount);
    }
    return result;
  }

  Map<String, double> get afterPaymentsByCurrency {
    final negatives = <String, double>{
      for (final entry in totalPaymentsByCurrency.entries)
        entry.key: -entry.value,
    };
    return _combineCurrencyMaps([totalIncomeByCurrency, negatives]);
  }

  Map<String, double> get finalNetByCurrency {
    final outflows = <String, double>{};
    for (final entry in totalPaymentsByCurrency.entries) {
      _addCurrencyAmount(outflows, entry.key, -entry.value);
    }
    for (final entry in totalExpensesByCurrency.entries) {
      _addCurrencyAmount(outflows, entry.key, -entry.value);
    }
    return _combineCurrencyMaps([totalIncomeByCurrency, outflows]);
  }

  List<ReportDistributionEntry> get realizedDistributionByCurrency {
    final result = <ReportDistributionEntry>[];
    for (final entry in totalExpensesByCurrency.entries) {
      result.add(
        ReportDistributionEntry(
          label: MizanI18n.text('Giderler'),
          amount: entry.value,
          currencyCode: entry.key,
        ),
      );
    }
    final payments = <String, double>{};
    for (final detail in paymentDetails) {
      final key = '${detail.currencyCode}|${detail.type.name}';
      payments[key] = (payments[key] ?? 0) + detail.payment.amount;
    }
    for (final entry in payments.entries) {
      final parts = entry.key.split('|');
      final type = RecordType.values.firstWhere(
        (item) => item.name == parts[1],
      );
      result.add(
        ReportDistributionEntry(
          label: type.label,
          amount: entry.value,
          type: type,
          currencyCode: parts[0],
        ),
      );
    }
    result.sort((a, b) {
      final currencyOrder = a.currencyCode.compareTo(b.currencyCode);
      if (currencyOrder != 0) return currencyOrder;
      final amountOrder = b.amount.compareTo(a.amount);
      return amountOrder != 0 ? amountOrder : a.label.compareTo(b.label);
    });
    return result;
  }

  List<ReportDistributionEntry> get combinedOutflowDistributionByCurrency {
    final result = <ReportDistributionEntry>[];
    final expenses = <String, double>{};
    for (final detail in expenseDetails) {
      final key = '${detail.expense.currencyCode}|${detail.categoryName}';
      expenses[key] = (expenses[key] ?? 0) + detail.expense.totalAmount;
    }
    for (final entry in expenses.entries) {
      final split = entry.key.indexOf('|');
      final code = entry.key.substring(0, split);
      final category = entry.key.substring(split + 1);
      result.add(
        ReportDistributionEntry(
          label: '${MizanI18n.text('Günlük harcama')} · $category',
          amount: entry.value,
          expenseCategory: category,
          currencyCode: code,
        ),
      );
    }
    final payments = <String, double>{};
    for (final detail in paymentDetails) {
      final key = '${detail.currencyCode}|${detail.type.name}';
      payments[key] = (payments[key] ?? 0) + detail.payment.amount;
    }
    for (final entry in payments.entries) {
      final parts = entry.key.split('|');
      final type = RecordType.values.firstWhere(
        (item) => item.name == parts[1],
      );
      result.add(
        ReportDistributionEntry(
          label: '${MizanI18n.text('Ödeme')} · ${type.label}',
          amount: entry.value,
          type: type,
          currencyCode: parts[0],
        ),
      );
    }
    result.removeWhere((entry) => entry.amount <= 0);
    result.sort((a, b) {
      final currencyOrder = a.currencyCode.compareTo(b.currencyCode);
      if (currencyOrder != 0) return currencyOrder;
      final amountOrder = b.amount.compareTo(a.amount);
      return amountOrder != 0 ? amountOrder : a.label.compareTo(b.label);
    });
    return result;
  }

'''
    report = report[:idx] + block + report[idx:]
    s = s[:report_start] + report + s[report_end:]

# Patch both addPayments local functions to require and store owning currency.
search_from = 0
for occurrence in range(2):
    fn = '    void addPayments({\n'
    start = s.find(fn, search_from)
    if start < 0: raise SystemExit(f'addPayments #{occurrence + 1} missing')
    end = s.find('    }) {', start)
    sig = s[start:end]
    if 'required String currencyCode,' not in sig:
        sig = sig.replace('      required String subtitle,\n', '      required String subtitle,\n      required String currencyCode,\n', 1)
        s = s[:start] + sig + s[end:]
        end += len('      required String currencyCode,\n')
    detail_start = s.find('          ReportPaymentDetail(\n', end)
    detail_end = s.find('          ),\n', detail_start)
    detail = s[detail_start:detail_end]
    if 'currencyCode: currencyCode,' not in detail:
        detail = detail.replace('            recordSubtitle: subtitle,\n', '            recordSubtitle: subtitle,\n            currencyCode: currencyCode,\n', 1)
        s = s[:detail_start] + detail + s[detail_end:]
    search_from = detail_end + 20

# Every addPayments call inherits parent record currency. There are two sets of
# calls (range helper + report build), so replace every unique parent anchor.
for parent, title_anchor in [
    ('debt', '            payments: debt.payments,\n'),
    ('bill', '          payments: bill.payments,\n'),
    ('subscription', '          payments: subscription.payments,\n'),
    ('rent', '          payments: rent.payments,\n'),
]:
    # debt covers both bank debt and personal debt: both variables are named debt.
    replacement = title_anchor.replace('payments:', f'currencyCode: {parent}.currencyCode,\n' + title_anchor[:len(title_anchor)-len(title_anchor.lstrip())] + 'payments:')
    # Use a simple preceding insertion for all occurrences not already patched.
    pos = 0
    while True:
        idx = s.find(title_anchor, pos)
        if idx < 0: break
        prev = s[max(0, idx-100):idx]
        if f'currencyCode: {parent}.currencyCode,' not in prev:
            indent = title_anchor[:len(title_anchor)-len(title_anchor.lstrip())]
            s = s[:idx] + indent + f'currencyCode: {parent}.currencyCode,\n' + s[idx:]
            pos = idx + len(indent) + len(parent) + 35
        else:
            pos = idx + len(title_anchor)

# `_fullRemainingReferences` manually creates RecordReference and must retain
# each parent's currency too.
full_start = s.index('  List<RecordReference> _fullRemainingReferences(')
full = s[full_start:]
for var, anchor in [
    ('debt', '            sourceId: debt.id,\n'),
    ('bill', '          sourceId: bill.id,\n'),
    ('subscription', '          sourceId: subscription.id,\n'),
    ('rent', '          sourceId: rent.id,\n'),
]:
    pos = 0
    while True:
        idx = full.find(anchor, pos)
        if idx < 0: break
        after = idx + len(anchor)
        if f'currencyCode: {var}.currencyCode,' not in full[after:after+100]:
            indent = anchor[:len(anchor)-len(anchor.lstrip())]
            full = full[:after] + indent + f'currencyCode: {var}.currencyCode,\n' + full[after:]
            pos = after + 50
        else:
            pos = after
s = s[:full_start] + full

p.write_text(s, encoding='utf-8')
subprocess.run(['dart', 'format', str(p)], check=True)
