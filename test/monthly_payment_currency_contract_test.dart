import 'package:flutter_test/flutter_test.dart';
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
