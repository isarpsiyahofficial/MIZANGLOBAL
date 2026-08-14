import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  test('yeni aylık banka borcunun ilk vadesi bir sonraki ay olur', () async {
    final store = MemoryStore(
      MizanState(
        people: const [
          PersonAccount(
            id: 'person',
            name: 'Kişi',
            banks: [BankGroup(id: 'bank', userWrittenName: 'Banka')],
          ),
        ],
        expenseCategories: const [],
        expenses: const [],
        notificationSlots: const [],
      ),
    );
    final controller = MizanController(store, scheduler: SpyScheduler());
    await controller.load();

    final createdAt = DateTime.now();
    await controller.addDebtProduct(
      personId: 'person',
      bankId: 'bank',
      kind: DebtKind.loan,
      title: 'Aylık kredi',
      totalAmount: 12000,
      monthlyAmount: 1000,
      dueDate: createdAt,
      dueMode: DebtDueMode.monthlyDay,
      dueDayOfMonth: 5,
      installmentCount: 12,
      currentInstallment: 0,
    );

    final debt = controller.state.people.single.banks.single.products.single;
    final expectedMonth = DateTime(createdAt.year, createdAt.month + 1);
    expect(debt.dueDate.year, expectedMonth.year);
    expect(debt.dueDate.month, expectedMonth.month);
    expect(debt.dueDate.day, 5);
  });

  test('geciken aylık borç bütün ödenmemiş dönemleri listeler', () {
    final debt = DebtProduct(
      id: 'debt',
      currencyCode: 'TRY',
      kind: DebtKind.loan,
      title: 'Kredi',
      totalAmount: 12000,
      monthlyAmount: 1000,
      dueDate: DateTime(2026, 6, 5),
      dueMode: DebtDueMode.monthlyDay,
      dueDayOfMonth: 5,
      installmentCount: 12,
      currentInstallment: 0,
    );

    expect(debt.unpaidDueDatesAt(DateTime(2026, 7, 21)), [
      DateTime(2026, 6, 5),
      DateTime(2026, 7, 5),
    ]);

    final junePaid = debt.copyWith(
      payments: [
        PaymentRecord(
          id: 'payment',
          amount: 1000,
          paidAt: DateTime(2026, 7, 10),
          entryType: PaymentEntryType.installment,
          appliesToDueDate: DateTime(2026, 6, 5),
        ),
      ],
    );
    expect(junePaid.unpaidDueDatesAt(DateTime(2026, 7, 21)), [
      DateTime(2026, 7, 5),
    ]);
  });

  test('ödeme bildirimleri 1 ile 10 özel saatte planlanabilir', () async {
    final now = DateTime(2026, 7, 1, 7);
    final state = MizanState(
      people: [
        PersonAccount(
          id: 'person',
          name: 'Kişi',
          bills: [
            BillEntry(
              id: 'bill',
              currencyCode: 'TRY',
              kind: BillKind.electricity,
              institutionName: 'Kurum',
              amount: 500,
              dueDate: DateTime(2026, 7, 5),
            ),
          ],
        ),
      ],
      expenseCategories: const [],
      expenses: const [],
      notificationSlots: defaultNotificationSlots,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'one',
          label: 'Bir',
          hour: 8,
          minute: 15,
          message: 'Birinci',
        ),
        NotificationSlot(
          id: 'two',
          label: 'İki',
          hour: 21,
          minute: 45,
          message: 'İkinci',
        ),
      ],
    );
    final plan = const ReminderPlanBuilder().build(state: state, now: now);
    final times = plan
        .where((item) => item.kind == ReminderKind.payment)
        .map((item) => (item.scheduledAt.hour, item.scheduledAt.minute))
        .toSet();
    expect(times, containsAll(const [(8, 15), (21, 45)]));

    final controller = MizanController(
      MemoryStore(state),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    for (var index = 0; index < 8; index++) {
      await controller.addPaymentNotificationSlot();
    }
    expect(controller.state.paymentNotificationSlots, hasLength(10));
    expect(
      controller.addPaymentNotificationSlot,
      throwsA(isA<ArgumentError>()),
    );
  });

  test('gelir sıklıkları seçili tarih aralığında doğru hesaplanır', () {
    final start = DateTime(2026, 7, 1);
    final end = DateTime(2026, 7, 31);
    const amount = 100.0;

    IncomeEntry income(IncomeFrequency frequency, DateTime date) => IncomeEntry(
      id: frequency.name,
      currencyCode: 'TRY',
      title: frequency.label,
      amount: amount,
      frequency: frequency,
      startDate: date,
    );

    expect(
      income(
        IncomeFrequency.oneTime,
        DateTime(2026, 7, 10),
      ).totalForRange(start, end),
      100,
    );
    expect(
      income(
        IncomeFrequency.daily,
        DateTime(2026, 7, 29),
      ).totalForRange(start, end),
      300,
    );
    expect(
      income(
        IncomeFrequency.weekly,
        DateTime(2026, 7, 6),
      ).totalForRange(start, DateTime(2026, 7, 20)),
      300,
    );
    expect(
      income(
        IncomeFrequency.monthly,
        DateTime(2026, 6, 15),
      ).totalForRange(start, end),
      100,
    );
  });

  test('rapor gelirden ödeme ve giderleri ayrı düşer', () {
    final state = MizanState(
      people: [
        PersonAccount(
          id: 'person',
          name: 'Kişi',
          banks: [
            BankGroup(
              id: 'bank',
              userWrittenName: 'Banka',
              products: [
                DebtProduct(
                  id: 'debt',
                  currencyCode: 'TRY',
                  kind: DebtKind.loan,
                  title: 'Kredi',
                  totalAmount: 10000,
                  monthlyAmount: 2000,
                  dueDate: DateTime(2026, 7, 5),
                  payments: [
                    PaymentRecord(
                      id: 'pay',
                      amount: 2000,
                      paidAt: DateTime(2026, 7, 5),
                      entryType: PaymentEntryType.installment,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      expenseCategories: const [
        ExpenseCategory(id: 'expense-category', name: 'Market'),
      ],
      expenses: [
        ExpenseItem(
          id: 'expense',
          currencyCode: 'TRY',
          categoryId: 'expense-category',
          name: 'Alışveriş',
          quantity: 1,
          unitPrice: 1000,
          spentAt: DateTime(2026, 7, 10),
        ),
      ],
      notificationSlots: const [],
      incomes: [
        IncomeEntry(
          id: 'income',
          currencyCode: 'TRY',
          title: 'Maaş',
          amount: 10000,
          frequency: IncomeFrequency.monthly,
          startDate: DateTime(2026, 7, 1),
        ),
      ],
    );

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(
        period: ReportPeriod.monthly,
        anchorDate: DateTime(2026, 7),
      ),
      now: DateTime(2026, 7, 21),
    );
    expect(report.incomeSpecified, isTrue);
    expect(report.totalIncome, 10000);
    expect(report.totalPayments, 2000);
    expect(report.totalExpenses, 1000);
    expect(report.afterPayments, 8000);
    expect(report.finalNet, 7000);
  });

  test('ay listesi yalnız gerçek kayıt bulunan ayları taşır', () {
    final state = MizanState(
      people: [
        PersonAccount(
          id: 'person',
          name: 'Kişi',
          bills: [
            BillEntry(
              id: 'bill',
              currencyCode: 'TRY',
              kind: BillKind.water,
              institutionName: 'Kurum',
              amount: 200,
              dueDate: DateTime(2026, 8, 5),
            ),
          ],
        ),
      ],
      expenseCategories: const [],
      expenses: [
        ExpenseItem(
          id: 'expense',
          currencyCode: 'TRY',
          categoryId: 'none',
          name: 'Gider',
          quantity: 1,
          unitPrice: 10,
          spentAt: DateTime(2026, 7, 3),
        ),
      ],
      notificationSlots: const [],
    );
    final months = state.availableReportMonths(DateTime(2026, 8, 20));
    expect(months, [DateTime(2026, 8), DateTime(2026, 7)]);
    expect(months, isNot(contains(DateTime(2026, 1))));
  });

  test('gelir ve özel bildirim saatleri JSON ve CSV yedeğinde korunur', () {
    final state = MizanState(
      people: const [],
      expenseCategories: const [],
      expenses: const [],
      notificationSlots: defaultNotificationSlots,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom',
          label: 'Özel',
          hour: 13,
          minute: 37,
          message: 'Kontrol et',
        ),
      ],
      incomes: [
        IncomeEntry(
          id: 'income',
          currencyCode: 'TRY',
          title: 'Serbest çalışma',
          amount: 2500,
          frequency: IncomeFrequency.weekly,
          startDate: DateTime(2026, 7, 1),
          note: 'Opsiyonel',
        ),
      ],
    );

    expect(MizanState.fromJson(state.toJson()).toJson(), state.toJson());
    const service = CsvBackupService();
    final csv = service.exportState(state);
    expect(csv, contains('income'));
    expect(service.importState(csv).toJson(), state.toJson());
  });
}
