import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

void main() {
  final now = DateTime(2026, 7, 21, 12);

  MizanState reportState() => MizanState(
    people: [
      PersonAccount(
        id: 'p1',
        name: 'Ali',
        banks: [
          BankGroup(
            id: 'b1',
            userWrittenName: 'Banka A',
            products: [
              DebtProduct(
                id: 'd1',
                kind: DebtKind.loan,
                title: 'Kredi',
                totalAmount: 12000,
                monthlyAmount: 1000,
                installmentCount: 12,
                currentInstallment: 2,
                dueDate: DateTime(2026, 7, 25),
                payments: [
                  PaymentRecord(
                    id: 'pay-bank',
                    amount: 1000,
                    paidAt: DateTime(2026, 7, 5),
                    entryType: PaymentEntryType.installment,
                  ),
                  PaymentRecord(
                    id: 'pay-bank-old',
                    amount: 500,
                    paidAt: DateTime(2026, 6, 5),
                    entryType: PaymentEntryType.partial,
                  ),
                ],
              ),
            ],
          ),
        ],
        bills: [
          BillEntry(
            id: 'bill1',
            kind: BillKind.electricity,
            institutionName: 'Elektrik',
            amount: 600,
            dueDate: DateTime(2026, 7, 24),
            payments: [
              PaymentRecord(
                id: 'pay-bill',
                amount: 200,
                paidAt: DateTime(2026, 7, 10),
                entryType: PaymentEntryType.partial,
              ),
            ],
          ),
        ],
      ),
      PersonAccount(
        id: 'p2',
        name: 'Ayşe',
        personalDebts: [
          PersonalDebtEntry(
            id: 'pd1',
            creditorType: CreditorType.person,
            title: 'Şahıs borcu',
            creditorName: 'Mehmet',
            totalAmount: 3000,
            debtDate: DateTime(2026, 1, 1),
            dueDate: DateTime(2026, 7, 23),
            frequency: PaymentFrequency.monthly,
            isInstallment: true,
            installmentCount: 3,
            monthlyAmount: 1000,
            payments: [
              PaymentRecord(
                id: 'pay-personal',
                amount: 1000,
                paidAt: DateTime(2026, 7, 7),
                entryType: PaymentEntryType.installment,
              ),
            ],
          ),
        ],
        subscriptions: [
          SubscriptionEntry(
            id: 'sub1',
            kind: SubscriptionKind.digitalService,
            title: 'Bulut',
            providerName: 'Servis',
            amount: 150,
            frequency: PaymentFrequency.monthly,
            nextDueDate: DateTime(2026, 7, 22),
            payments: [
              PaymentRecord(
                id: 'pay-sub',
                amount: 150,
                paidAt: DateTime(2026, 7, 8),
                entryType: PaymentEntryType.debtClosure,
                appliesToDueDate: DateTime(2026, 7, 22),
              ),
            ],
          ),
        ],
        rents: [
          RentEntry(
            id: 'rent1',
            title: 'Ev kirası',
            amount: 24000,
            paymentDay: 5,
            receiverName: 'Ev sahibi',
            dueDate: DateTime(2026, 7, 26),
            installmentCount: 12,
            currentInstallment: 1,
            payments: [
              PaymentRecord(
                id: 'pay-rent',
                amount: 2000,
                paidAt: DateTime(2026, 7, 5),
                entryType: PaymentEntryType.installment,
              ),
            ],
          ),
        ],
      ),
    ],
    expenseCategories: const [
      ExpenseCategory(id: 'market', name: 'Market'),
      ExpenseCategory(id: 'fuel', name: 'Yakıt'),
    ],
    expenses: [
      ExpenseItem(
        id: 'e1',
        categoryId: 'market',
        name: 'Alışveriş',
        quantity: 1,
        unitPrice: 750,
        spentAt: DateTime(2026, 7, 5),
      ),
      ExpenseItem(
        id: 'e2',
        categoryId: 'fuel',
        name: 'Benzin',
        quantity: 1,
        unitPrice: 1000,
        spentAt: DateTime(2026, 6, 20),
      ),
    ],
  );

  test('aylık rapor ödeme türlerini giderlerden ayrı toplar', () {
    final report = MizanReportService().build(
      state: reportState(),
      filter: ReportFilter(
        period: ReportPeriod.monthly,
        anchorDate: DateTime(2026, 7, 1),
      ),
      now: now,
    );

    expect(report.paymentTotalsByType[RecordType.debt], 1000);
    expect(report.paymentTotalsByType[RecordType.personalDebt], 1000);
    expect(report.paymentTotalsByType[RecordType.bill], 200);
    expect(report.paymentTotalsByType[RecordType.subscription], 150);
    expect(report.paymentTotalsByType[RecordType.rent], 2000);
    expect(report.totalPayments, 4350);
    expect(report.totalExpenses, 750);
    expect(report.realizedGrandTotal, 5100);
    expect(report.expenseTotalsByCategory['Market'], 750);
    expect(report.expenseTotalsByCategory.containsKey('Yakıt'), isFalse);
  });

  test(
    'belirli kişi filtresi yalnız seçili kişinin finans kayıtlarını kapsar',
    () {
      final report = MizanReportService().build(
        state: reportState(),
        filter: ReportFilter(
          period: ReportPeriod.monthly,
          anchorDate: DateTime(2026, 7, 1),
          selectedPersonIds: {'p1'},
        ),
        now: now,
      );

      expect(report.selectedPersonNames, ['Ali']);
      expect(report.totalPayments, 1200);
      expect(
        report.paymentDetails.every((item) => item.personId == 'p1'),
        isTrue,
      );
      expect(report.personDebtDetails, hasLength(1));
      expect(report.personDebtDetails.single.personName, 'Ali');
      expect(
        report.personDebtDetails.single.byType[RecordType.debt],
        10500,
        reason:
            'Kişi bazlı borç taksit tutarı değil gerçek kalan bakiye olmalı.',
      );
      expect(
        report.totalExpenses,
        750,
        reason:
            'Gider modelinde kişi bağı olmadığı için dönem gideri ayrı kalır.',
      );
    },
  );

  test('tüm zamanlar eski ve yeni ödeme ile giderleri birlikte kapsar', () {
    final report = MizanReportService().build(
      state: reportState(),
      filter: ReportFilter(
        period: ReportPeriod.allTime,
        anchorDate: DateTime(2026, 7, 1),
      ),
      now: now,
    );

    expect(report.range.start, isNull);
    expect(report.range.endInclusive, isNull);
    expect(report.totalPayments, 4850);
    expect(report.totalExpenses, 1750);
    expect(report.realizedGrandTotal, 6600);
    expect(report.paymentDetails, hasLength(6));
    expect(report.expenseDetails, hasLength(2));
  });

  test('tüm zamanlarda kişi ve kalan durum filtreleri birlikte çalışır', () {
    final report = MizanReportService().build(
      state: reportState(),
      filter: ReportFilter(
        period: ReportPeriod.allTime,
        anchorDate: DateTime(2026, 7, 1),
        selectedPersonIds: {'p1'},
        status: PaymentStatus.upcoming,
      ),
      now: now,
    );

    expect(report.range.label, 'Tüm zamanlar');
    expect(report.selectedPersonNames, ['Ali']);
    expect(report.totalPayments, 1700);
    expect(
      report.paymentDetails.every((item) => item.personId == 'p1'),
      isTrue,
    );
    expect(report.remainingDetails, isNotEmpty);
    expect(
      report.remainingDetails.every(
        (item) =>
            item.personId == 'p1' && item.status == PaymentStatus.upcoming,
      ),
      isTrue,
    );
    expect(
      report.totalExpenses,
      1750,
      reason:
          'Giderler kişi filtresinden bağımsız, tüm zaman filtresine bağlıdır.',
    );
  });

  test('yıllık rapor güncel yılda bugüne kadar olan dönemi kullanır', () {
    final range = ReportFilter(
      period: ReportPeriod.yearly,
      anchorDate: DateTime(2026, 2, 1),
    ).range(now);
    expect(range.start, DateTime(2026, 1, 1));
    expect(range.endInclusive, DateTime(2026, 7, 21));
  });

  test('kalan ödeme yükü toplam bakiye yerine dönem taksitini kullanır', () {
    final report = MizanReportService().build(
      state: reportState(),
      filter: ReportFilter(
        period: ReportPeriod.monthly,
        anchorDate: DateTime(2026, 7, 1),
      ),
      now: now,
    );
    final bank = report.remainingDetails.firstWhere(
      (item) => item.type == RecordType.debt,
    );
    final rent = report.remainingDetails.firstWhere(
      (item) => item.type == RecordType.rent,
    );
    expect(bank.amount, 1000);
    expect(bank.amount, isNot(10500));
    expect(rent.amount, closeTo(2200, 0.001));
    expect(rent.amount, isNot(22000));
  });

  test('gecikmiş aylık taksitler bütün açık dönemleriyle toplanır', () {
    final state = MizanState(
      people: [
        PersonAccount(
          id: 'overdue-person',
          name: 'Test kişi',
          banks: [
            BankGroup(
              id: 'overdue-bank',
              userWrittenName: 'Test bankası',
              products: [
                DebtProduct(
                  id: 'overdue-47',
                  kind: DebtKind.loan,
                  title: '47 günlük gecikme',
                  totalAmount: 20000,
                  monthlyAmount: 3500,
                  dueDate: DateTime(2026, 6, 5),
                  dueMode: DebtDueMode.monthlyDay,
                  dueDayOfMonth: 5,
                  manualOverdueDays: 47,
                  manualOverdueRecordedAt: now,
                ),
                DebtProduct(
                  id: 'overdue-31',
                  kind: DebtKind.creditCard,
                  title: '31 günlük gecikme',
                  totalAmount: 25000,
                  monthlyAmount: 6211,
                  dueDate: DateTime(2026, 6, 20),
                  dueMode: DebtDueMode.monthlyDay,
                  dueDayOfMonth: 20,
                  manualOverdueDays: 31,
                  manualOverdueRecordedAt: now,
                ),
                DebtProduct(
                  id: 'overdue-20',
                  kind: DebtKind.overdraft,
                  title: '20 günlük gecikme',
                  totalAmount: 12000,
                  monthlyAmount: 4200,
                  dueDate: DateTime(2026, 7, 1),
                  dueMode: DebtDueMode.monthlyDay,
                  dueDayOfMonth: 1,
                  manualOverdueDays: 20,
                  manualOverdueRecordedAt: now,
                ),
              ],
            ),
          ],
        ),
      ],
      expenseCategories: const [],
      expenses: const [],
    );

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(
        period: ReportPeriod.monthly,
        anchorDate: DateTime(2026, 7),
      ),
      now: now,
    );
    final byId = {
      for (final item in report.remainingDetails) item.sourceId: item.amount,
    };

    expect(byId['overdue-47'], 7000);
    expect(byId['overdue-31'], 12422);
    expect(byId['overdue-20'], 4200);
    expect(report.overdueLoad, 23622);
    expect(report.overdueLoad, greaterThan(10000));
  });

  test('rapor ödeme ayrıntılarını çoğaltmadan toplamla birebir eşler', () {
    final report = MizanReportService().build(
      state: reportState(),
      filter: ReportFilter(
        period: ReportPeriod.monthly,
        anchorDate: DateTime(2026, 7, 1),
      ),
      now: now,
    );
    final ids = report.paymentDetails.map((item) => item.payment.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    expect(
      report.paymentDetails.fold<double>(
        0,
        (sum, item) => sum + item.payment.amount,
      ),
      report.totalPayments,
    );
    expect(
      report.expenseDetails.fold<double>(
        0,
        (sum, item) => sum + item.expense.totalAmount,
      ),
      report.totalExpenses,
    );
  });

  test('yıllık rapor yalnız seçili yıl içindeki hareketleri toplar', () {
    final report = MizanReportService().build(
      state: reportState(),
      filter: ReportFilter(
        period: ReportPeriod.yearly,
        anchorDate: DateTime(2026, 1, 1),
      ),
      now: now,
    );
    expect(report.totalPayments, 4850);
    expect(report.totalExpenses, 1750);
    expect(report.paymentDetails, hasLength(6));
  });
}
