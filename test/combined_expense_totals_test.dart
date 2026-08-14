import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

void main() {
  final today = DateTime(2026, 7, 25, 12);

  MizanState buildState() => MizanState(
        people: [
          PersonAccount(
            id: 'p1',
            name: 'Kişi',
            banks: [
              BankGroup(
                id: 'b1',
                userWrittenName: 'Banka',
                products: [
                  DebtProduct(
                    id: 'd1',
                    kind: DebtKind.loan,
                    title: 'Kredi',
                    totalAmount: 10000,
                    monthlyAmount: 1000,
                    dueDate: DateTime(2026, 7, 25),
                    payments: [
                      PaymentRecord(
                        id: 'today-payment',
                        amount: 1000,
                        paidAt: DateTime(2026, 7, 25, 9),
                      ),
                      PaymentRecord(
                        id: 'month-payment',
                        amount: 500,
                        paidAt: DateTime(2026, 7, 10, 9),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            rents: [
              RentEntry(
                id: 'rent-1',
                title: 'Ev kirası',
                amount: 12000,
                paymentDay: 5,
                receiverName: 'Ev sahibi',
                dueDate: DateTime(2026, 7, 5),
                payments: [
                  PaymentRecord(
                    id: 'rent-payment',
                    amount: 2000,
                    paidAt: DateTime(2026, 7, 25, 10),
                  ),
                ],
              ),
            ],
          ),
        ],
        expenseCategories: const [
          ExpenseCategory(id: 'market', name: 'Market')
        ],
        expenses: [
          ExpenseItem(
            id: 'today-expense',
            categoryId: 'market',
            name: 'Market',
            quantity: 1,
            unitPrice: 300,
            spentAt: DateTime(2026, 7, 25, 8),
          ),
          ExpenseItem(
            id: 'month-expense',
            categoryId: 'market',
            name: 'Yakıt',
            quantity: 1,
            unitPrice: 700,
            spentAt: DateTime(2026, 7, 8, 8),
          ),
        ],
        notificationSlots: defaultNotificationSlots,
      );

  test('bugün ve bu ay normal gider ödeme gideri ve toplam ayrılır', () {
    final state = buildState();
    expect(state.expenseTotalForDay(today), 300);
    expect(state.actualPaymentTotalForDay(today), 3000);
    expect(state.totalOutflowForDay(today), 3300);
    expect(state.expenseTotalForMonth(today), 1000);
    expect(state.actualPaymentTotalForMonth(today), 3500);
    expect(state.totalOutflowForMonth(today), 4500);
  });

  test('yedekten dönen kayıtlar aynı toplam hesaplarına dahil edilir', () {
    final restored = MizanState.fromJson(buildState().toJson());
    expect(restored.totalOutflowForDay(today), 3300);
    expect(restored.totalOutflowForMonth(today), 4500);
    expect(restored.expenses, hasLength(2));
    expect(
      restored.people.single.banks.single.products.single.payments,
      hasLength(2),
    );
  });

  test('rapor normal gider ödeme gideri ve toplam gideri ayrı tutar', () {
    final report = const MizanReportService().build(
      state: buildState(),
      filter: ReportFilter(
        period: ReportPeriod.monthly,
        anchorDate: DateTime(2026, 7, 1),
      ),
      now: today,
    );
    expect(report.paymentExpenseTotal, 3500);
    expect(report.normalExpenseTotal, 1000);
    expect(report.combinedExpenseTotal, 4500);
  });
}
