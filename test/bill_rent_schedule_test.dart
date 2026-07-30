import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

void main() {
  group('değişken aylık faturalar', () {
    test('her ayın gerçek tutarını ayrı korur ve doğru vadeyi izler', () {
      final bill = BillEntry(
        id: 'bill-variable',
        kind: BillKind.electricity,
        institutionName: 'Elektrik',
        amount: 500,
        dueDate: DateTime(2026, 8, 15),
        scheduleMode: BillScheduleMode.monthly,
        paymentDay: 15,
        periodAmounts: [
          BillPeriodAmount(month: DateTime(2026, 8), amount: 730),
          BillPeriodAmount(month: DateTime(2026, 9), amount: 910),
        ],
      );

      expect(bill.amountForMonth(DateTime(2026, 8)), 730);
      expect(bill.amountForMonth(DateTime(2026, 9)), 910);
      expect(bill.amountForMonth(DateTime(2026, 10)), 500);
      expect(
        bill.effectiveDueDateAt(DateTime(2026, 7, 24)),
        DateTime(2026, 8, 15),
      );
      expect(
        bill.statusAt(DateTime(2026, 7, 24)),
        isNot(PaymentStatus.overdue),
      );
    });

    test('ödenen dönem kapanır ve sıradaki ayın değişken tutarı açılır', () {
      final bill = BillEntry(
        id: 'bill-paid',
        kind: BillKind.water,
        institutionName: 'Su',
        amount: 400,
        dueDate: DateTime(2026, 7, 5),
        scheduleMode: BillScheduleMode.monthly,
        paymentDay: 5,
        periodAmounts: [
          BillPeriodAmount(month: DateTime(2026, 7), amount: 600),
          BillPeriodAmount(month: DateTime(2026, 8), amount: 800),
        ],
        payments: [
          PaymentRecord(
            id: 'payment-july',
            amount: 600,
            paidAt: DateTime(2026, 7, 6),
            appliesToDueDate: DateTime(2026, 7, 5),
          ),
        ],
      );

      expect(
        bill.effectiveDueDateAt(DateTime(2026, 7, 24)),
        DateTime(2026, 8, 5),
      );
      expect(bill.dueAmountAt(DateTime(2026, 7, 24)), 800);
      expect(bill.overdueDaysAt(DateTime(2026, 7, 24)), 0);
    });

    test('JSON turunda dönem tutarları kaybolmaz', () {
      final original = BillEntry(
        id: 'bill-json',
        kind: BillKind.naturalGas,
        institutionName: 'Gaz',
        amount: 300,
        dueDate: DateTime(2026, 8, 20),
        scheduleMode: BillScheduleMode.monthly,
        paymentDay: 20,
        periodAmounts: [
          BillPeriodAmount(month: DateTime(2026, 8), amount: 350),
        ],
      );
      final decoded = BillEntry.fromJson(original.toJson());
      expect(decoded.scheduleMode, BillScheduleMode.monthly);
      expect(decoded.paymentDay, 20);
      expect(decoded.amountForMonth(DateTime(2026, 8)), 350);
    });
  });

  group('kira ve taksit takvimi', () {
    test('ev kirası ayın gününü ve ilk ödeme ayını izler', () {
      final rent = RentEntry(
        id: 'home-rent',
        kind: RentEntryKind.homeRent,
        title: 'Ev kirası',
        amount: 15000,
        paymentDay: 15,
        receiverName: 'Ev sahibi',
        dueDate: DateTime(2026, 8, 15),
        recurringMonthly: true,
      );

      expect(
        rent.effectiveDueDateAt(DateTime(2026, 7, 24)),
        DateTime(2026, 8, 15),
      );
      expect(
        rent.statusAt(DateTime(2026, 7, 24)),
        isNot(PaymentStatus.overdue),
      );
      expect(rent.dueAmountAt(DateTime(2026, 7, 24)), 15000);
    });

    test('ürün taksiti sözleşme alanı olmadan aylık planlanır', () {
      final rent = RentEntry(
        id: 'product',
        kind: RentEntryKind.productInstallment,
        title: 'Telefon taksiti',
        amount: 24000,
        paymentDay: 5,
        receiverName: 'Mağaza',
        dueDate: DateTime(2026, 8, 5),
        installmentCount: 12,
        currentInstallment: 0,
      );

      expect(rent.contractStart, isNull);
      expect(rent.contractEnd, isNull);
      expect(rent.isMonthlySchedule, isTrue);
      expect(rent.plannedCycleAmount, 2000);
      expect(
        rent.effectiveDueDateAt(DateTime(2026, 7, 24)),
        DateTime(2026, 8, 5),
      );
    });

    test('ödeme dönemini kapatır ve sonraki ayı açar', () {
      final rent = RentEntry(
        id: 'product-paid',
        kind: RentEntryKind.productInstallment,
        title: 'Bilgisayar taksiti',
        amount: 12000,
        paymentDay: 10,
        receiverName: 'Mağaza',
        dueDate: DateTime(2026, 7, 10),
        installmentCount: 6,
        payments: [
          PaymentRecord(
            id: 'first',
            amount: 2000,
            paidAt: DateTime(2026, 7, 10),
            entryType: PaymentEntryType.installment,
            appliesToDueDate: DateTime(2026, 7, 10),
          ),
        ],
      );

      expect(
        rent.effectiveDueDateAt(DateTime(2026, 7, 24)),
        DateTime(2026, 8, 10),
      );
      expect(rent.overdueDaysAt(DateTime(2026, 7, 24)), 0);
      expect(rent.remainingInstallmentCount, 5);
    });
  });
}
