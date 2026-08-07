#!/usr/bin/env python3
from pathlib import Path

p = Path('lib/controllers/mizan_controller.dart')
s = p.read_text(encoding='utf-8')

# Add/update public API currency parameters.
for method, anchor in [
    ('addDebtProduct', "    String description = '',\n"),
    ('updateDebtProduct', "    String description = '',\n"),
    ('addPersonalDebt', "    String description = '',\n"),
    ('updatePersonalDebt', "    String description = '',\n"),
    ('addBill', "    String description = '',\n"),
    ('updateBill', "    String description = '',\n"),
    ('addSubscription', "    String description = '',\n"),
    ('updateSubscription', "    String description = '',\n"),
    ('addRent', "    String description = '',\n"),
    ('updateRent', "    String description = '',\n"),
    ('addExpense', "    String note = '',\n"),
    ('updateExpense', "    String note = '',\n"),
    ('addIncome', "    String note = '',\n"),
    ('updateIncome', "    String note = '',\n"),
]:
    start = s.index(f'  Future<void> {method}(')
    end = s.index('  }) async {', start) + len('  }) async {')
    region = s[start:end]
    if 'String? currencyCode,' not in region:
        if anchor not in region:
            raise SystemExit(f'{method}: signature anchor missing')
        region = region.replace(anchor, '    String? currencyCode,\n' + anchor, 1)
        s = s[:start] + region + s[end:]

# Builders take explicit record currency.
builder_types = {
    '_buildDebt': 'DebtProduct',
    '_buildPersonalDebt': 'PersonalDebtEntry',
    '_buildBill': 'BillEntry',
    '_buildSubscription': 'SubscriptionEntry',
    '_buildRent': 'RentEntry',
    '_buildExpense': 'ExpenseItem',
}
for builder, result_type in builder_types.items():
    start = s.index(f'  {result_type} {builder}({{')
    end = s.index('  }) {', start) + len('  }) {')
    region = s[start:end]
    if 'required String currencyCode,' not in region:
        region = region.replace('    required String id,\n', '    required String id,\n    required String currencyCode,\n', 1)
        s = s[:start] + region + s[end:]

# Builder constructors persist record currency.
for builder, ctor in [(k, v) for k, v in builder_types.items()]:
    start = s.index(f'  {ctor} {builder}({{')
    end = s.index('\n  }\n', start)
    region = s[start:end]
    needle = f'    return {ctor}(\n      id: id,\n'
    replacement = f'    return {ctor}(\n      id: id,\n      currencyCode: currencyCode,\n'
    if replacement not in region:
        if needle not in region:
            raise SystemExit(f'{builder}: constructor anchor missing')
        region = region.replace(needle, replacement, 1)
        s = s[:start] + region + s[end:]

# Normalize record currency separately from profile semantics.
helper_anchor = "  void _positiveAmount(double value, String label) {\n"
helper = "  String _recordCurrency(String? value, {String? fallback}) {\n    final code = (value ?? fallback ?? _state.defaultCurrencyCode)\n        .trim()\n        .toUpperCase();\n    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) {\n      throw ArgumentError('Kayıt para birimi kodu geçersiz.');\n    }\n    return code;\n  }\n\n" + helper_anchor
if 'String _recordCurrency(String? value' not in s:
    if helper_anchor not in s:
        raise SystemExit('record currency helper anchor missing')
    s = s.replace(helper_anchor, helper, 1)

# New records default from profile; updates preserve record currency unless explicitly changed.
def patch_call(method: str, builder: str, add: bool):
    global s
    start = s.index(f'  Future<void> {method}(')
    next_method = s.find('\n  Future<void> ', start + 10)
    end = len(s) if next_method < 0 else next_method
    region = s[start:end]
    marker = f'{builder}(\n      id:'
    if marker not in region:
        raise SystemExit(f'{method}: {builder} call missing')
    idx = region.index(marker)
    line_end = region.index('\n', idx + len(marker))
    insert = ('      currencyCode: _recordCurrency(currencyCode),\n'
              if add else
              '      currencyCode: _recordCurrency(currencyCode, fallback: existing.currencyCode),\n')
    if 'currencyCode: _recordCurrency(' not in region[idx:idx + 260]:
        region = region[:line_end + 1] + insert + region[line_end + 1:]
        s = s[:start] + region + s[end:]

for method, builder, add in [
    ('addDebtProduct', '_buildDebt', True), ('updateDebtProduct', '_buildDebt', False),
    ('addPersonalDebt', '_buildPersonalDebt', True), ('updatePersonalDebt', '_buildPersonalDebt', False),
    ('addBill', '_buildBill', True), ('updateBill', '_buildBill', False),
    ('addSubscription', '_buildSubscription', True), ('updateSubscription', '_buildSubscription', False),
    ('addRent', '_buildRent', True), ('updateRent', '_buildRent', False),
    ('addExpense', '_buildExpense', True), ('updateExpense', '_buildExpense', False),
]:
    patch_call(method, builder, add)

# updateExpense needs the existing object for fallback.
start = s.index('  Future<void> updateExpense(')
end = s.index('\n  Future<void> deleteExpense', start)
region = s[start:end]
if 'final existing = _expense(expenseId);' not in region:
    if '    _expense(expenseId);\n' not in region:
        raise SystemExit('updateExpense lookup anchor missing')
    region = region.replace('    _expense(expenseId);\n', '    final existing = _expense(expenseId);\n', 1)
    s = s[:start] + region + s[end:]

# Income constructors.
start = s.index('  Future<void> addIncome(')
end = s.index('\n  Future<void> updateIncome', start)
region = s[start:end]
needle = "    final income = IncomeEntry(\n      id: newId('income'),\n"
repl = "    final income = IncomeEntry(\n      id: newId('income'),\n      currencyCode: _recordCurrency(currencyCode),\n"
if repl not in region:
    if needle not in region:
        raise SystemExit('addIncome constructor anchor missing')
    region = region.replace(needle, repl, 1)
    s = s[:start] + region + s[end:]

start = s.index('  Future<void> updateIncome(')
end = s.index('\n  void _validateIncomeTracking', start)
region = s[start:end]
needle = '              return IncomeEntry(\n                id: item.id,\n'
repl = '              return IncomeEntry(\n                id: item.id,\n                currencyCode: _recordCurrency(currencyCode, fallback: item.currencyCode),\n'
if repl not in region:
    if needle not in region:
        raise SystemExit('updateIncome constructor anchor missing')
    region = region.replace(needle, repl, 1)
    s = s[:start] + region + s[end:]

# Modern writes must never contain an unbound money record.
validate_anchor = "  void _validateState(MizanState state) {\n"
window_start = s.index(validate_anchor)
if 'hasCompleteRecordCurrencies' not in s[window_start:window_start + 800]:
    insert = validate_anchor + "    if (!state.hasCompleteRecordCurrencies) {\n      throw StateError('Para taşıyan her kaydın kalıcı ISO para birimi bulunmalıdır.');\n    }\n"
    s = s.replace(validate_anchor, insert, 1)

p.write_text(s, encoding='utf-8')
