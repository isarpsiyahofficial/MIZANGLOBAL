import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/screens/dashboard_screen.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  testWidgets(
    'ana sayfa bu ayın açık planını ve yapılan ödemeyi ayrı gösterir',
    (tester) async {
      final now = DateTime.now();
      final banks = <BankGroup>[
        for (var index = 0; index < 8; index++)
          BankGroup(
            id: 'bank-$index',
            userWrittenName: 'Banka $index',
            products: [
              DebtProduct(
                id: 'debt-$index',
                kind: DebtKind.creditCard,
                title: 'Kart $index',
                totalAmount: 1000,
                monthlyAmount: 1000,
                dueDate: DateTime(
                  now.year,
                  now.month,
                  (index + 1).clamp(1, 28).toInt(),
                ),
                dueMode: DebtDueMode.monthlyDay,
                dueDayOfMonth: (index + 1).clamp(1, 28).toInt(),
                payments: index == 7
                    ? [
                        PaymentRecord(
                          id: 'paid-current-month',
                          amount: 1000,
                          paidAt: DateTime(now.year, now.month, 2),
                          entryType: PaymentEntryType.installment,
                        ),
                      ]
                    : const [],
              ),
            ],
          ),
      ];
      final state = MizanState.empty().copyWith(
        people: [PersonAccount(id: 'person', name: 'Test', banks: banks)],
      );
      final controller = MizanController(
        MemoryStore(state),
        scheduler: SpyScheduler(),
      );
      await controller.load();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DashboardScreen(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      final tracking = find.text('Bu Ayın Ödeme Durumu');
      expect(tracking, findsOneWidget);
      await tester.ensureVisible(tracking);
      await tester.tap(
        find.ancestor(of: tracking, matching: find.byType(InkWell)).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Açık planlanan ödemeler'), findsOneWidget);
      expect(find.textContaining('7 açık kayıt'), findsOneWidget);
      final paidSection = find.text('Bu ay yapılan ödemeler');
      await tester.scrollUntilVisible(
        paidSection,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(paidSection, findsOneWidget);
      expect(find.textContaining('1 ödeme'), findsOneWidget);
    },
  );

  test('yaklaşan ödeme yalnız önümüzdeki 7 günü kapsar', () {
    final now = DateTime(2026, 7, 10, 12);
    final state = MizanState.empty().copyWith(
      people: [
        PersonAccount(
          id: 'p',
          name: 'Kişi',
          banks: [
            BankGroup(
              id: 'b',
              userWrittenName: 'Banka',
              products: [
                DebtProduct(
                  id: 'day-7',
                  kind: DebtKind.loan,
                  title: '7 gün',
                  totalAmount: 1000,
                  monthlyAmount: 1000,
                  dueDate: now.add(const Duration(days: 7)),
                ),
                DebtProduct(
                  id: 'day-8',
                  kind: DebtKind.loan,
                  title: '8 gün',
                  totalAmount: 2000,
                  monthlyAmount: 2000,
                  dueDate: now.add(const Duration(days: 8)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.upcomingDetails.map((item) => item.sourceId), ['day-7']);
    expect(report.upcomingLoad, 1000);
  });

  test(
    'gerçekleşen ve birleşik gider dağılımları büyükten küçüğe sıralanır',
    () {
      final now = DateTime(2026, 7, 20);
      final state = MizanState.empty().copyWith(
        expenseCategories: const [ExpenseCategory(id: 'daily', name: 'Genel')],
        expenses: [
          ExpenseItem(
            id: 'expense',
            categoryId: 'daily',
            name: 'Günlük gider',
            quantity: 1,
            unitPrice: 27800,
            spentAt: now,
          ),
        ],
        people: [
          PersonAccount(
            id: 'p',
            name: 'Kişi',
            bills: [
              BillEntry(
                id: 'bill',
                kind: BillKind.electricity,
                institutionName: 'Kurum',
                amount: 8500,
                dueDate: now,
                payments: [
                  PaymentRecord(id: 'bill-payment', amount: 8500, paidAt: now),
                ],
              ),
            ],
            banks: [
              BankGroup(
                id: 'b',
                userWrittenName: 'Banka',
                products: [
                  DebtProduct(
                    id: 'debt',
                    kind: DebtKind.loan,
                    title: 'Kredi',
                    totalAmount: 3000,
                    monthlyAmount: 3000,
                    dueDate: now,
                    payments: [
                      PaymentRecord(
                        id: 'debt-payment',
                        amount: 3000,
                        paidAt: now,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final report = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
        now: now,
      );

      expect(report.realizedDistribution.first.label, 'Giderler');
      expect(
        report.realizedDistribution.map((item) => item.amount),
        orderedEquals([27800, 8500, 3000, 0, 0, 0]),
      );
      expect(
        report.combinedOutflowDistribution.map((item) => item.amount),
        orderedEquals([27800, 8500, 3000]),
      );
    },
  );
}
