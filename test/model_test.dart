import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

import 'test_support.dart';

void main() {
  test('ilk kurulum durumu hiçbir örnek kayıt içermez', () {
    final state = MizanState.empty();
    expect(state.people, isEmpty);
    expect(state.expenseCategories, isEmpty);
    expect(state.expenses, isEmpty);
    expect(state.recordReferencesAt(DateTime.now()), isEmpty);
    expect(paymentCount(state), 0);
  });

  test('beş ana kayıt grubu birbirinden bağımsız toplamlanır', () {
    final state = comprehensiveState();
    expect(state.bankDebtTotal, 9000);
    expect(state.personalCorporateDebtTotal, 6000);
    expect(state.billTotal, 750);
    expect(state.subscriptionTotal, 249.90);
    expect(state.rentInstallmentTotal, 15000);
    expect(state.totalDebt, closeTo(30999.90, 0.001));
    expect(state.expenseTotalForMonth(DateTime(2026, 7)), 450);
  });

  test('kişisel borç ödeme planı gerçekleşen ödemelere göre ilerler', () {
    final state = comprehensiveState();
    final original = state.people.single.personalDebts.single;
    final paid = original.copyWith(
      payments: [
        PaymentRecord(
          id: 'personal-payment-1',
          amount: 2000,
          paidAt: DateTime(2026, 7, 19),
        ),
      ],
    );
    expect(paid.resolvedSchedule.first.isCompleted, isTrue);
    expect(paid.resolvedSchedule[1].isCompleted, isFalse);
    expect(paid.effectiveDueDate, paid.schedule[1].dueDate);
    expect(paid.remainingAmount, 4000);
  });

  test('JSON turu tüm yeni kayıt türlerini ve kaynak bağlarını korur', () {
    final state = comprehensiveState();
    final decoded = MizanState.fromJson(state.toJson());
    expect(decoded.schemaVersion, currentSchemaVersion);
    expect(decoded.people.single.personalDebts, hasLength(1));
    expect(decoded.people.single.subscriptions, hasLength(1));
    expect(
      decoded.people.single.banks.single.products.single.payments,
      hasLength(1),
    );
    expect(
      decoded.toJson(),
      state.copyWith(schemaVersion: currentSchemaVersion).toJson(),
    );
  });

  test('kısmi ödeme yalnız ait olduğu kaydın kalanını azaltır', () {
    final state = comprehensiveState();
    final person = state.people.single;
    final debt = person.banks.single.products.single.copyWith(
      payments: [
        ...person.banks.single.products.single.payments,
        PaymentRecord(
          id: 'second-payment',
          amount: 1000,
          paidAt: DateTime(2026, 7, 19),
        ),
      ],
    );
    expect(debt.remainingAmount, 8000);
    expect(person.personalDebts.single.remainingAmount, 6000);
    expect(person.bills.single.remainingAmount, 750);
    expect(person.rents.single.remainingAmount, 15000);
  });

  _feedbackModelTests();
  _paymentWorkflowModelTests();
}

void _feedbackModelTests() {
  test(
    'önümüzdeki yedi gün toplam borcu değil sıradaki ödeme tutarını kullanır',
    () {
      final reference = DateTime(2026, 7, 19);
      final state = comprehensiveState(reference: reference);
      expect(state.dueWithinDaysTotal(reference, 7), closeTo(19999.90, 0.001));
      final bankRecord = state
          .recordReferencesAt(reference)
          .firstWhere((item) => item.type == RecordType.debt);
      expect(bankRecord.amount, 2000);
      expect(bankRecord.amount, isNot(9000));
    },
  );

  test('banka borcu her ayın belirli gününde planlanabilir', () {
    final debt = DebtProduct(
      id: 'monthly-day',
      kind: DebtKind.loan,
      title: 'Aylık kredi',
      totalAmount: 100000,
      monthlyAmount: 5000,
      dueDate: DateTime(2026, 7, 5),
      dueMode: DebtDueMode.monthlyDay,
      dueDayOfMonth: 5,
    );
    expect(debt.effectiveDueDateAt(DateTime(2026, 7, 2)), DateTime(2026, 7, 5));
    expect(debt.dueAmountAt(DateTime(2026, 7, 2)), 5000);
    expect(debt.isDueInMonth(DateTime(2026, 12)), isTrue);
    final decoded = DebtProduct.fromJson(debt.toJson());
    expect(decoded.dueMode, DebtDueMode.monthlyDay);
    expect(decoded.dueDayOfMonth, 5);
  });

  test('gerçekleşen ödemeler kayıt türlerine göre ayrı toplamlanır', () {
    final reference = DateTime(2026, 7, 19);
    final base = comprehensiveState(reference: reference);
    final person = base.people.single;
    final state = base.copyWith(
      people: [
        person.copyWith(
          personalDebts: [
            person.personalDebts.single.copyWith(
              payments: [
                PaymentRecord(
                  id: 'personal-paid',
                  amount: 1200,
                  paidAt: reference,
                ),
              ],
            ),
          ],
          bills: [
            person.bills.single.copyWith(
              payments: [
                PaymentRecord(id: 'bill-paid', amount: 500, paidAt: reference),
              ],
            ),
          ],
          subscriptions: [
            person.subscriptions.single.copyWith(
              payments: [
                PaymentRecord(
                  id: 'subscription-paid',
                  amount: 249.90,
                  paidAt: reference,
                  appliesToDueDate: person.subscriptions.single.nextDueDate,
                ),
              ],
            ),
          ],
          rents: [
            person.rents.single.copyWith(
              payments: [
                PaymentRecord(id: 'rent-paid', amount: 4000, paidAt: reference),
              ],
            ),
          ],
        ),
      ],
    );
    final totals = state.actualPaymentTotals(month: reference);
    expect(totals[RecordType.debt], 3000);
    expect(totals[RecordType.personalDebt], 1200);
    expect(totals[RecordType.bill], 500);
    expect(totals[RecordType.subscription], 249.90);
    expect(totals[RecordType.rent], 4000);
    expect(state.actualPaymentTotal(month: reference), closeTo(8949.90, 0.001));
  });
}

void _paymentWorkflowModelTests() {
  test('ödeme türü JSON turunda korunur', () {
    final payment = PaymentRecord(
      id: 'p',
      amount: 1500,
      paidAt: DateTime(2026, 7, 21),
      entryType: PaymentEntryType.installment,
    );
    final decoded = PaymentRecord.fromJson(payment.toJson());
    expect(decoded.entryType, PaymentEntryType.installment);
    expect(decoded.amount, 1500);
  });

  test(
    'ödenen ve kalan taksit sayısı taksit ödeme geçmişine göre hesaplanır',
    () {
      final debt = DebtProduct(
        id: 'd',
        kind: DebtKind.loan,
        title: 'Kredi',
        totalAmount: 12000,
        monthlyAmount: 1000,
        dueDate: DateTime(2026, 8, 5),
        installmentCount: 12,
        currentInstallment: 3,
        payments: [
          PaymentRecord(
            id: 'installment',
            amount: 1000,
            paidAt: DateTime(2026, 7, 5),
            entryType: PaymentEntryType.installment,
          ),
          PaymentRecord(
            id: 'partial',
            amount: 250,
            paidAt: DateTime(2026, 7, 10),
            entryType: PaymentEntryType.partial,
          ),
        ],
      );
      expect(debt.paidInstallmentCount, 4);
      expect(debt.remainingInstallmentCount, 8);
      expect(debt.scheduledPaymentAmount, 1000);
    },
  );
}
