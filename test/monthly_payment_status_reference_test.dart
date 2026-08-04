import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/monthly_payment_status_service.dart';

void main() {
  MizanState stateWith(DebtProduct debt) => MizanState.empty().copyWith(
    people: [
      PersonAccount(
        id: 'person',
        name: 'Kişi',
        banks: [
          BankGroup(
            id: 'bank',
            userWrittenName: 'Banka',
            products: [debt],
          ),
        ],
      ),
    ],
  );

  test('ayın ilk günü gecikme ay sonuna sıçramaz, yalnız bir gün ilerler', () {
    final debt = DebtProduct(
      id: 'overdue',
      kind: DebtKind.loan,
      title: 'Gecikmeli kredi',
      totalAmount: 12000,
      monthlyAmount: 1000,
      dueDate: DateTime(2026, 8, 5),
      dueMode: DebtDueMode.monthlyDay,
      dueDayOfMonth: 5,
      manualOverdueDays: 57,
      manualOverdueRecordedAt: DateTime(2026, 7, 31),
      manualOverdueSince: DateTime(2026, 6, 4),
    );
    final state = stateWith(debt);
    final reference = DateTime(2026, 8, 1, 10);

    final normal = state.recordReferencesAt(reference).single;
    final monthly = const MonthlyPaymentStatusService().build(
      state: state,
      month: reference,
      referenceDate: reference,
    );

    expect(normal.overdueDays, 58);
    expect(monthly.openRecords, hasLength(1));
    expect(monthly.openRecords.single.overdueDays, 58);
    expect(monthly.openRecords.single.status, PaymentStatus.overdue);
    expect(monthly.openRecords.single.dueDate, DateTime(2026, 6, 4));
    expect(monthly.openRecords.single.overdueDays, isNot(88));
  });

  test('ayın ileriki vadesi ayın ilk gününde gecikmiş gösterilmez', () {
    final reference = DateTime(2026, 8, 1, 10);
    final state = stateWith(
      DebtProduct(
        id: 'future',
        kind: DebtKind.creditCard,
        title: 'Ağustos kartı',
        totalAmount: 5000,
        monthlyAmount: 5000,
        dueDate: DateTime(2026, 8, 15),
      ),
    );

    final monthly = const MonthlyPaymentStatusService().build(
      state: state,
      month: reference,
      referenceDate: reference,
    );
    final record = monthly.openRecords.single;

    expect(record.dueDate, DateTime(2026, 8, 15));
    expect(record.overdueDays, 0);
    expect(record.status, PaymentStatus.active);
  });
}
