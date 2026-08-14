from pathlib import Path

path = Path('lib/services/monthly_payment_status_service.dart')
text = path.read_text(encoding='utf-8')
old = """      sourceId: record.sourceId,
      bankId: record.bankId,
"""
new = """      sourceId: record.sourceId,
      currencyCode: record.currencyCode,
      bankId: record.bankId,
"""
if text.count(old) != 1:
    raise SystemExit(
        f'expected one RecordReference reconstruction without currency, found {text.count(old)}'
    )
path.write_text(text.replace(old, new, 1), encoding='utf-8')
print('preserved currencyCode while rebuilding monthly RecordReference timing')

test_path = Path('test/monthly_payment_currency_contract_test.dart')
if test_path.exists():
    raise SystemExit('monthly payment currency regression test unexpectedly already exists')
test_path.write_text(
    r'''import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/monthly_payment_status_service.dart';

void main() {
  test('monthly payment timing rebuild preserves record ISO currency', () {
    final reference = DateTime(2026, 8, 1, 10);
    final state = MizanState(
      people: [
        PersonAccount(
          id: 'person',
          name: 'User',
          banks: [
            BankGroup(
              id: 'bank',
              userWrittenName: 'User bank',
              products: [
                DebtProduct(
                  id: 'debt',
                  currencyCode: 'EUR',
                  kind: DebtKind.custom,
                  title: 'Home financing',
                  customKindName: 'Mortgage',
                  totalAmount: 1000,
                  monthlyAmount: 250,
                  dueDate: DateTime(2026, 8, 3),
                ),
              ],
            ),
          ],
        ),
      ],
      expenseCategories: const [],
      expenses: const [],
      notificationSlots: const [],
      appLanguageTag: 'en',
      debtRegionCountryCode: 'DE',
      defaultCurrencyCode: 'EUR',
    );

    final status = const MonthlyPaymentStatusService().build(
      state: state,
      month: reference,
      referenceDate: reference,
    );

    expect(status.openRecords, hasLength(1));
    expect(status.openRecords.single.sourceId, 'debt');
    expect(status.openRecords.single.currencyCode, 'EUR');
    expect(status.openRecords.single.amount, 250);
  });
}
''',
    encoding='utf-8',
)
print('created monthly payment currency regression test')
