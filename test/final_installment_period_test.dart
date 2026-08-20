import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

void main() {
  test('kira ve taksit aylık yükü kalan bakiye yerine dönem tutarıdır', () {
    final rent = RentEntry(
      id: 'rent-final',
      title: 'Ürün taksiti',
      amount: 24000,
      paymentDay: 5,
      receiverName: 'İşletme',
      dueDate: DateTime(2026, 7, 26),
      installmentCount: 12,
      currentInstallment: 1,
      payments: [
        PaymentRecord(
          id: 'rent-payment',
          amount: 2000,
          paidAt: DateTime(2026, 7, 5),
          entryType: PaymentEntryType.installment,
        ),
      ],
    );
    final person = PersonAccount(
      id: 'person-final',
      name: 'Test',
      rents: [rent],
    );
    final state = MizanState(
      people: [person],
      expenseCategories: const [],
      expenses: const [],
    );

    expect(rent.remainingAmount, 22000);
    expect(rent.scheduledPaymentAmount, closeTo(2200, 0.001));
    expect(person.monthlyLoadFor(DateTime(2026, 7)), closeTo(2200, 0.001));
    final reference = state
        .recordReferencesAt(DateTime(2026, 7, 21))
        .singleWhere((item) => item.type == RecordType.rent);
    expect(reference.amount, closeTo(2200, 0.001));
    expect(reference.amount, isNot(22000));
  });
}
