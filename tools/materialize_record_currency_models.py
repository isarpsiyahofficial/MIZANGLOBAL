#!/usr/bin/env python3
from pathlib import Path
import re

PATH = Path('lib/models/mizan_models.dart')
text = PATH.read_text(encoding='utf-8')

text = text.replace('const int currentSchemaVersion = 13;', 'const int currentSchemaVersion = 14;')

helper_anchor = "String _string(dynamic value, {String fallback = ''}) =>\n    value is String ? value : fallback;\n"
helper_code = helper_anchor + "\nString _normalizedCurrencyCode(dynamic value) {\n  final code = _string(value).trim().toUpperCase();\n  return RegExp(r'^[A-Z]{3}$').hasMatch(code) ? code : '';\n}\n\nString _resolvedCurrencyCode(String value, String fallback) {\n  final current = _normalizedCurrencyCode(value);\n  if (current.isNotEmpty) return current;\n  final safeFallback = _normalizedCurrencyCode(fallback);\n  return safeFallback.isNotEmpty ? safeFallback : 'TRY';\n}\n"
if '_normalizedCurrencyCode(dynamic value)' not in text:
    if helper_anchor not in text:
        raise SystemExit('helper anchor not found')
    text = text.replace(helper_anchor, helper_code, 1)


def class_bounds(source: str, name: str):
    start = source.index(f'class {name} ')
    nxt = source.find('\nclass ', start + 1)
    end = len(source) if nxt < 0 else nxt
    return start, end


def patch_money_class(source: str, name: str) -> str:
    start, end = class_bounds(source, name)
    region = source[start:end]
    if 'final String currencyCode;' in region:
        return source
    if 'required this.id,' not in region:
        raise SystemExit(f'{name}: id constructor anchor missing')
    region = region.replace('required this.id,', "required this.id,\n    this.currencyCode = '',", 1)
    if 'final String id;' not in region:
        raise SystemExit(f'{name}: id field anchor missing')
    region = region.replace('final String id;', 'final String id;\n  final String currencyCode;', 1)

    copy_idx = region.find(' copyWith({')
    if copy_idx < 0:
        copy_idx = region.find(' copyWith(\n')
    if copy_idx < 0:
        raise SystemExit(f'{name}: copyWith anchor missing')
    brace_idx = region.find('{', copy_idx)
    close_idx = region.find('})', copy_idx)
    copy_signature = region[copy_idx:close_idx if close_idx >= 0 else len(region)]
    if 'String? currencyCode' not in copy_signature:
        region = region[:brace_idx + 1] + '\n    String? currencyCode,' + region[brace_idx + 1:]

    ctor_idx = region.find(f'return {name}(', copy_idx)
    if ctor_idx < 0:
        ctor_idx = region.find(f'=> {name}(', copy_idx)
    if ctor_idx < 0:
        raise SystemExit(f'{name}: copyWith constructor anchor missing')
    match = re.search(r'\bid\s*:\s*id\s*,', region[ctor_idx:])
    if match is None:
        raise SystemExit(f'{name}: copyWith id anchor missing')
    id_idx = ctor_idx + match.start()
    insert_at = ctor_idx + match.end()
    indent = '      ' if 'return ' in region[ctor_idx:ctor_idx + 12] else '    '
    region = region[:insert_at] + f'\n{indent}currencyCode: currencyCode ?? this.currencyCode,' + region[insert_at:]

    json_idx = region.find('Map<String, dynamic> toJson()')
    if json_idx < 0:
        raise SystemExit(f'{name}: toJson anchor missing')
    json_match = re.search(r"'id'\s*:\s*id\s*,", region[json_idx:])
    if json_match is None:
        raise SystemExit(f'{name}: toJson id anchor missing')
    insert_at = json_idx + json_match.end()
    region = region[:insert_at] + "\n    'currencyCode': currencyCode," + region[insert_at:]

    from_idx = region.find(f'factory {name}.fromJson')
    if from_idx < 0:
        raise SystemExit(f'{name}: fromJson anchor missing')
    from_match = re.search(r"id\s*:\s*_string\(json\['id'\]\)\s*,", region[from_idx:])
    if from_match is None:
        raise SystemExit(f'{name}: fromJson id anchor missing')
    insert_at = from_idx + from_match.end()
    region = region[:insert_at] + "\n      currencyCode: _normalizedCurrencyCode(json['currencyCode'])," + region[insert_at:]
    return source[:start] + region + source[end:]


for model in [
    'DebtProduct',
    'PersonalDebtEntry',
    'BillEntry',
    'SubscriptionEntry',
    'RentEntry',
    'ExpenseItem',
    'IncomeEntry',
]:
    text = patch_money_class(text, model)

# RecordReference carries the owning record currency into reports/notifications.
start, end = class_bounds(text, 'RecordReference')
region = text[start:end]
if 'final String currencyCode;' not in region:
    region = region.replace('required this.sourceId,', "required this.sourceId,\n    this.currencyCode = '',", 1)
    region = region.replace('final String sourceId;', 'final String sourceId;\n  final String currencyCode;', 1)
    text = text[:start] + region + text[end:]

# Every generated reference inherits currency from its owning record.
reference_pairs = [
    ('sourceId: product.id,', 'product.currencyCode'),
    ('sourceId: debt.id,', 'debt.currencyCode'),
    ('sourceId: bill.id,', 'bill.currencyCode'),
    ('sourceId: subscription.id,', 'subscription.currencyCode'),
    ('sourceId: rent.id,', 'rent.currencyCode'),
]
for anchor, expr in reference_pairs:
    state_start = text.index('  List<RecordReference> recordReferencesAt(')
    state_end = text.index('  double expenseTotalForCategory(', state_start)
    state_region = text[state_start:state_end]
    needle = anchor + '\n'
    replacement = anchor + f'\n              currencyCode: {expr},\n'
    if replacement.strip() not in state_region:
        if needle not in state_region:
            raise SystemExit(f'reference anchor missing: {anchor}')
        state_region = state_region.replace(needle, replacement, 1)
        text = text[:state_start] + state_region + text[state_end:]

materialize_method = r'''
  MizanState materializeRecordCurrencies([String? fallbackCurrencyCode]) {
    final fallback = _resolvedCurrencyCode(
      fallbackCurrencyCode ?? defaultCurrencyCode,
      'TRY',
    );
    String resolve(String value) => _resolvedCurrencyCode(value, fallback);
    return copyWith(
      people: people
          .map(
            (person) => person.copyWith(
              banks: person.banks
                  .map(
                    (bank) => bank.copyWith(
                      products: bank.products
                          .map(
                            (item) => item.copyWith(
                              currencyCode: resolve(item.currencyCode),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  )
                  .toList(growable: false),
              personalDebts: person.personalDebts
                  .map(
                    (item) => item.copyWith(
                      currencyCode: resolve(item.currencyCode),
                    ),
                  )
                  .toList(growable: false),
              bills: person.bills
                  .map(
                    (item) => item.copyWith(
                      currencyCode: resolve(item.currencyCode),
                    ),
                  )
                  .toList(growable: false),
              subscriptions: person.subscriptions
                  .map(
                    (item) => item.copyWith(
                      currencyCode: resolve(item.currencyCode),
                    ),
                  )
                  .toList(growable: false),
              rents: person.rents
                  .map(
                    (item) => item.copyWith(
                      currencyCode: resolve(item.currencyCode),
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      expenses: expenses
          .map(
            (item) => item.copyWith(
              currencyCode: resolve(item.currencyCode),
            ),
          )
          .toList(growable: false),
      incomes: incomes
          .map(
            (item) => item.copyWith(
              currencyCode: resolve(item.currencyCode),
            ),
          )
          .toList(growable: false),
    );
  }

  bool get hasCompleteRecordCurrencies {
    bool valid(String value) => RegExp(r'^[A-Z]{3}$').hasMatch(value);
    return allDebtProducts.every((item) => valid(item.currencyCode)) &&
        allPersonalDebts.every((item) => valid(item.currencyCode)) &&
        allBills.every((item) => valid(item.currencyCode)) &&
        allSubscriptions.every((item) => valid(item.currencyCode)) &&
        allRents.every((item) => valid(item.currencyCode)) &&
        expenses.every((item) => valid(item.currencyCode)) &&
        incomes.every((item) => valid(item.currencyCode));
  }

  Map<String, double> recordRemainingTotalsByCurrency() {
    final result = <String, double>{};
    void add(String currency, double amount) {
      if (amount == 0) return;
      final code = _resolvedCurrencyCode(currency, defaultCurrencyCode);
      result[code] = (result[code] ?? 0) + amount;
    }
    for (final item in allDebtProducts.where((item) => !item.isArchived)) {
      add(item.currencyCode, item.remainingAmount);
    }
    for (final item in allPersonalDebts.where((item) => !item.isArchived)) {
      add(item.currencyCode, item.remainingAmount);
    }
    for (final item in allBills.where((item) => !item.isArchived)) {
      add(item.currencyCode, item.remainingAmount);
    }
    for (final item in allSubscriptions.where((item) => !item.isArchived)) {
      add(item.currencyCode, item.remainingAmount);
    }
    for (final item in allRents.where((item) => !item.isArchived)) {
      add(item.currencyCode, item.remainingAmount);
    }
    return result;
  }

  Map<String, double> expenseTotalsForRangeByCurrency(
    DateTime start,
    DateTime endInclusive,
  ) {
    final result = <String, double>{};
    for (final item in expenses) {
      final day = _dateOnly(item.spentAt);
      if (day.isBefore(_dateOnly(start)) || day.isAfter(_dateOnly(endInclusive))) {
        continue;
      }
      final code = _resolvedCurrencyCode(item.currencyCode, defaultCurrencyCode);
      result[code] = (result[code] ?? 0) + item.totalAmount;
    }
    return result;
  }

  Map<String, double> incomeTotalsForRangeByCurrency(
    DateTime start,
    DateTime endInclusive,
  ) {
    final result = <String, double>{};
    for (final item in incomes.where((item) => !item.isArchived)) {
      final amount = item.totalForRange(start, endInclusive);
      if (amount == 0) continue;
      final code = _resolvedCurrencyCode(item.currencyCode, defaultCurrencyCode);
      result[code] = (result[code] ?? 0) + amount;
    }
    return result;
  }
'''
copy_anchor = '  MizanState copyWith({\n'
if 'MizanState materializeRecordCurrencies' not in text:
    if copy_anchor not in text:
        raise SystemExit('MizanState copyWith anchor missing')
    text = text.replace(copy_anchor, materialize_method + '\n' + copy_anchor, 1)

factory_start = text.index('  factory MizanState.fromJson(')
factory_end = text.index('  factory MizanState.empty()', factory_start)
factory = text[factory_start:factory_end]
if 'final parsed = MizanState(' not in factory:
    factory = factory.replace('    return MizanState(\n', '    final parsed = MizanState(\n', 1)
    tail = '    ).copyWith(schemaVersion: currentSchemaVersion);\n'
    if tail not in factory:
        raise SystemExit('MizanState fromJson return tail missing')
    factory = factory.replace(
        tail,
        "    );\n    return parsed\n        .materializeRecordCurrencies(parsed.defaultCurrencyCode)\n        .copyWith(schemaVersion: currentSchemaVersion);\n",
        1,
    )
    text = text[:factory_start] + factory + text[factory_end:]

PATH.write_text(text, encoding='utf-8')
