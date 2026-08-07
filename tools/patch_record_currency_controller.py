#!/usr/bin/env python3
from pathlib import Path

p = Path('lib/controllers/mizan_controller.dart')
s = p.read_text(encoding='utf-8')


def once(old: str, new: str, label: str):
    global s
    if new in s:
        return
    if old not in s:
        raise SystemExit(f'missing anchor: {label}')
    s = s.replace(old, new, 1)

# Add/update public API parameters.
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
    if 'String? currencyCode,' in region:
        continue
    if anchor not in region:
        raise SystemExit(f'{method}: signature anchor missing')
    region = region.replace(anchor, '    String? currencyCode,\n' + anchor, 1)
    s = s[:start] + region + s[end:]

# Builders take a validated, explicit ISO code.
for builder in ['_buildDebt', '_buildPersonalDebt', '_buildBill', '_buildSubscription', '_buildRent', '_buildExpense']:
    start = s.index(f'  {"DebtProduct" if builder == "_buildDebt" else "PersonalDebtEntry" if builder == "_buildPersonalDebt" else "BillEntry" if builder == "_buildBill" else "SubscriptionEntry" if builder == "_buildSubscription" else "RentEntry" if builder == "_buildRent" else "ExpenseItem"} {builder}({{')
    end = s.index('  }) {', start) + len('  }) {')
    region = s[start:end]
    if 'required String currencyCode,' not in region:
        region = region.replace('    required String id,\n', '    required String id,\n    required String currencyCode,\n', 1)
        s = s[:start] + region + s[end:]

# Builder constructors persist the code.
for ctor, builder in [
    ('DebtProduct', '_buildDebt'),
    ('PersonalDebtEntry', '_buildPersonalDebt'),
    ('BillEntry', '_buildBill'),
    ('SubscriptionEntry', '_buildSubscription'),
    ('RentEntry', '_buildRent'),
    ('ExpenseItem', '_buildExpense'),
]:
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

# Validate/normalize record currency independently from profile default.
helper_anchor = "  void _positiveAmount(double value, String label) {\n"
helper = "  String _recordCurrency(String? value, {String? fallback}) {\n    final code = (value ?? fallback ?? _state.defaultCurrencyCode)\n        .trim()\n        .toUpperCase();\n    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) {\n      throw ArgumentError('Kayıt para birimi kodu geçersiz.');\n    }\n    return code;\n  }\n\n" + helper_anchor
if 'String _recordCurrency(String? value' not in s:
    if helper_anchor not in s:
        raise SystemExit('record currency helper anchor missing')
    s = s.replace(helper_anchor, helper, 1)

# Add call gets current default; update preserves record unless explicitly changed.
def patch_calls(method: str, builder: str, add: bool):
    global s
    start = s.index(f'  Future<void> {method}(')
    next_method = s.find('\n  Future<void> ', start + 10)
    end = len(s) if next_method < 0 else next_method
    region = s[start:end]
    if f'{builder}(\n' not in region:
        raise SystemExit(f'{method}: {builder} call missing')
    marker = f'{builder}(\n      id:'
    idx = region.index(marker)
    line_end = region.index('\n', idx + len(marker))
    insert = '      currencyCode: _recordCurrency(currencyCode),\n' if add else '      currencyCode: _recordCurrency(currencyCode, fallback: existing.currencyCode),\n'
    if 'currencyCode: _recordCurrency(' not in region[idx:idx+220]:
        region = region[:line_end+1] + insert + region[line_end+1:]
        s = s[:start] + region + s[end:]

for method, builder, add in [
    ('addDebtProduct', '_buildDebt', True), ('updateDebtProduct', '_buildDebt', False),
    ('addPersonalDebt', '_buildPersonalDebt', True), ('updatePersonalDebt', '_buildPersonalDebt', False),
    ('addBill', '_buildBill', True), ('updateBill', '_buildBill', False),
    ('addSubscription', '_buildSubscription', True), ('updateSubscription', '_buildSubscription', False),
    ('addRent', '_buildRent', True), ('updateRent', '_buildRent', False),
    ('addExpense', '_buildExpense', True), ('updateExpense', '_buildExpense', False),
]:
    patch_calls(method, builder, add)

# updateExpense must preserve the existing record code.
start = s.index('  Future<void> updateExpense(')
end = s.index('\n  Future<void> deleteExpense', start)
region = s[start:end]
if 'final existing = _expense(expenseId);' not in region:
    region = region.replace('    _expense(expenseId);\n', '    final existing = _expense(expenseId);\n', 1)
    s = s[:start] + region + s[end:]

# Income constructors.
start = s.index('  Future<void> addIncome(')
end = s.index('\n  Future<void> updateIncome', start)
region = s[start:end]
needle = "    final income = IncomeEntry(\n      id: newId('income'),\n"
repl = "    final income = IncomeEntry(\n      id: newId('income'),\n      currencyCode: _recordCurrency(currencyCode),\n"
if repl not in region:
    if needle not in region: raise SystemExit('addIncome constructor anchor missing')
    region = region.replace(needle, repl, 1)
    s = s[:start] + region + s[end:]

start = s.index('  Future<void> updateIncome(')
end = s.index('\n  void _validateIncomeTracking', start)
region = s[start:end]
needle = '              return IncomeEntry(\n                id: item.id,\n'
repl = '              return IncomeEntry(\n                id: item.id,\n                currencyCode: _recordCurrency(currencyCode, fallback: item.currencyCode),\n'
if repl not in region:
    if needle not in region: raise SystemExit('updateIncome constructor anchor missing')
    region = region.replace(needle, repl, 1)
    s = s[:start] + region + s[end:]

# Reject incomplete currencies before persistence. Legacy load materializes before reaching controller.
validate_anchor = "  void _validateState(MizanState state) {\n"
if 'hasCompleteRecordCurrencies' not in s[s.index(validate_anchor):s.index(validate_anchor)+650]:
    insert = validate_anchor + "    if (!state.hasCompleteRecordCurrencies) {\n      throw StateError('Para taşıyan her kaydın kalıcı ISO para birimi bulunmalıdır.');\n    }\n"
    s = s.replace(validate_anchor, insert, 1)

p.write_text(s, encoding='utf-8')
