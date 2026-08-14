import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';

import 'test_support.dart';

void main() {
  DebtProduct monthlyDebt({
    int? manualDays,
    DateTime? recordedAt,
    DateTime? since,
    DateTime? dueDate,
    List<DateTime> periods = const [],
    List<PaymentRecord> payments = const [],
  }) => DebtProduct(
    id: 'debt',
    kind: DebtKind.loan,
    title: 'Aylık kredi',
    totalAmount: 12000,
    monthlyAmount: 1000,
    dueDate: dueDate ?? DateTime(2026, 8, 5),
    dueMode: DebtDueMode.monthlyDay,
    dueDayOfMonth: 5,
    manualOverdueDays: manualDays,
    manualOverdueRecordedAt: recordedAt,
    manualOverdueSince: since,
    manualOverduePeriods: periods,
    payments: payments,
  );

  MizanState stateWithDebt(DebtProduct debt) => MizanState(
    people: [
      PersonAccount(
        id: 'person',
        name: 'Kişi',
        banks: [
          BankGroup(id: 'bank', userWrittenName: 'Banka', products: [debt]),
        ],
      ),
    ],
    expenseCategories: const [],
    expenses: const [],
    notificationSlots: const [],
    paymentNotificationSlots: const [
      NotificationSlot(
        id: 'morning',
        label: 'Sabah',
        hour: 9,
        minute: 0,
        message: 'Ödemeyi kontrol et.',
      ),
    ],
  );

  test('manuel gecikme daha eskiyse aylık vade hesabının önüne geçer', () {
    final debt = DebtProduct(
      id: 'manual-priority',
      kind: DebtKind.loan,
      title: 'Manuel gecikmeli kredi',
      totalAmount: 12000,
      monthlyAmount: 1000,
      dueDate: DateTime(2026, 7, 5),
      dueMode: DebtDueMode.monthlyDay,
      dueDayOfMonth: 5,
      manualOverdueDays: 46,
      manualOverdueRecordedAt: DateTime(2026, 7, 21),
      manualOverdueSince: DateTime(2026, 6, 5),
    );

    expect(debt.unpaidDueDatesAt(DateTime(2026, 7, 24)), [
      DateTime(2026, 7, 5),
    ]);
    expect(debt.currentManualOverdueDaysAt(DateTime(2026, 7, 24)), 49);
    expect(debt.overdueDaysAt(DateTime(2026, 7, 24)), 49);
  });

  test('manuel 30 gün ertesi günlerde 31 32 33 olarak ilerler', () {
    final debt = DebtProduct(
      id: 'manual-daily',
      kind: DebtKind.loan,
      title: 'Takvim çakışmalı kredi',
      totalAmount: 12000,
      monthlyAmount: 1000,
      dueDate: DateTime(2026, 6, 24),
      dueMode: DebtDueMode.monthlyDay,
      dueDayOfMonth: 24,
      manualOverdueDays: 30,
      manualOverdueRecordedAt: DateTime(2026, 7, 21),
      manualOverdueSince: DateTime(2026, 6, 21),
    );

    expect(debt.overdueDaysAt(DateTime(2026, 7, 21)), 30);
    expect(debt.overdueDaysAt(DateTime(2026, 7, 22)), 31);
    expect(debt.overdueDaysAt(DateTime(2026, 7, 23)), 32);
    expect(debt.overdueDaysAt(DateTime(2026, 7, 24)), 33);
  });

  test(
    'ilgili olmayan düzenleme manuel gecikme referansını sıfırlamaz',
    () async {
      final original = monthlyDebt(
        manualDays: 46,
        recordedAt: DateTime(2026, 7, 21),
        since: DateTime(2026, 6, 5),
      );
      final store = MemoryStore(stateWithDebt(original));
      final controller = MizanController(store, scheduler: SpyScheduler());
      await controller.load();

      await controller.updateDebtProduct(
        personId: 'person',
        bankId: 'bank',
        debtId: 'debt',
        kind: original.kind,
        title: 'Sadece başlık değişti',
        totalAmount: original.totalAmount,
        monthlyAmount: original.monthlyAmount,
        dueDate: original.dueDate,
        dueMode: original.dueMode,
        dueDayOfMonth: original.dueDayOfMonth,
        manualOverdueDays: 46,
        replaceManualOverdueDays: false,
      );

      final updated =
          controller.state.people.single.banks.single.products.single;
      expect(updated.manualOverdueDays, 46);
      expect(updated.manualOverdueRecordedAt, DateTime(2026, 7, 21));
      expect(updated.manualOverdueSince, DateTime(2026, 6, 5));
    },
  );

  test('açıkça onaylanan manuel değişiklik referansı yeniden kurar', () async {
    final original = monthlyDebt(
      manualDays: 46,
      recordedAt: DateTime(2026, 7, 21),
      since: DateTime(2026, 6, 5),
    );
    final store = MemoryStore(stateWithDebt(original));
    final controller = MizanController(store, scheduler: SpyScheduler());
    await controller.load();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await controller.updateDebtProduct(
      personId: 'person',
      bankId: 'bank',
      debtId: 'debt',
      kind: original.kind,
      title: original.title,
      totalAmount: original.totalAmount,
      monthlyAmount: original.monthlyAmount,
      dueDate: original.dueDate,
      dueMode: original.dueMode,
      dueDayOfMonth: original.dueDayOfMonth,
      manualOverdueDays: 12,
      replaceManualOverdueDays: true,
    );

    final updated = controller.state.people.single.banks.single.products.single;
    expect(updated.manualOverdueDays, 12);
    expect(updated.manualOverdueRecordedAt, today);
    expect(
      updated.manualOverdueSince,
      today.subtract(const Duration(days: 12)),
    );
  });

  test('manuel gecikme günü takvimle her gün bir artar', () {
    final debt = monthlyDebt(
      manualDays: 46,
      recordedAt: DateTime(2026, 7, 21),
      since: DateTime(2026, 6, 5),
    );

    expect(debt.overdueDaysAt(DateTime(2026, 7, 21)), 46);
    expect(debt.overdueDaysAt(DateTime(2026, 7, 22)), 47);
    expect(debt.overdueDaysAt(DateTime(2026, 7, 24)), 49);
  });

  test('10 günlük eski CSV yedeğindeki 13 gün gecikme 23 güne çıkar', () {
    const service = CsvBackupService();
    final backupDay = DateTime(2026, 7, 14);
    final reference = DateTime(2026, 7, 24);
    final original = stateWithDebt(
      monthlyDebt(manualDays: 13, dueDate: DateTime(2026, 7, 5)),
    );
    final rows = CsvCodec().decode(service.exportState(original));
    final header = rows.first.map((value) => value.toString()).toList();
    final dateIndex = header.indexOf('date');
    final dataIndex = header.indexOf('data_json');
    final snapshot = rows[1];
    snapshot[dateIndex] = backupDay.toUtc().toIso8601String();
    final json = Map<String, dynamic>.from(
      jsonDecode(snapshot[dataIndex].toString()) as Map,
    );
    final debtJson = ((json['people'] as List).first as Map)['banks'] as List;
    final product =
        (((debtJson.first as Map)['products'] as List).first as Map);
    product.remove('manualOverdueRecordedAt');
    product.remove('manualOverdueSince');
    snapshot[dataIndex] = jsonEncode(json);

    final imported = service.importState(CsvCodec().encode(rows));
    final debt = imported.people.single.banks.single.products.single;
    expect(debt.manualOverdueRecordedAt, backupDay);
    expect(debt.overdueDaysAt(reference), 23);
  });

  test('seçilen gecikmiş aylar doğru hesaplanır ve ödeme ile azalır', () {
    final reference = DateTime(2026, 7, 24);
    final debt = monthlyDebt(periods: [DateTime(2026, 5), DateTime(2026, 6)]);

    expect(debt.unpaidDueDatesAt(reference), [
      DateTime(2026, 5, 5),
      DateTime(2026, 6, 5),
    ]);
    expect(debt.overdueDaysAt(reference), 80);
    expect(debt.dueAmountAt(reference), 2000);

    final mayPaid = debt.copyWith(
      payments: [
        PaymentRecord(
          id: 'payment',
          amount: 1000,
          paidAt: DateTime(2026, 7, 24),
          entryType: PaymentEntryType.installment,
          appliesToDueDate: DateTime(2026, 5, 5),
        ),
      ],
    );
    expect(mayPaid.unpaidDueDatesAt(reference), [DateTime(2026, 6, 5)]);
    expect(mayPaid.overdueDaysAt(reference), 49);
    expect(mayPaid.dueAmountAt(reference), 1000);
  });

  test('bildirim manuel gecikme referansını aylık vadeye tercih eder', () {
    final now = DateTime(2026, 7, 24, 8);
    final state = stateWithDebt(
      monthlyDebt(
        manualDays: 46,
        recordedAt: DateTime(2026, 7, 21),
        since: DateTime(2026, 6, 5),
        dueDate: DateTime(2026, 7, 5),
      ),
    );

    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    final payment = reminders.firstWhere(
      (item) => item.kind == ReminderKind.payment,
    );
    expect(payment.message, contains('Ödeme 49 gün gecikti.'));
  });

  test('gecikme bildirimi seçilen en eski ödenmeyen dönemi kullanır', () {
    final now = DateTime(2026, 7, 24, 8);
    final state = stateWithDebt(
      monthlyDebt(periods: [DateTime(2026, 5), DateTime(2026, 6)]),
    );

    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    final payment = reminders.firstWhere(
      (item) => item.kind == ReminderKind.payment,
    );
    expect(payment.message, contains('Ödeme 80 gün gecikti.'));
  });

  test(
    'her ayın 5i yeni kayıtta bütün aylarda sonraki takvim ayına geçer',
    () async {
      final store = MemoryStore(
        const MizanState(
          people: [
            PersonAccount(
              id: 'person',
              name: 'Kişi',
              banks: [BankGroup(id: 'bank', userWrittenName: 'Banka')],
            ),
          ],
          expenseCategories: [],
          expenses: [],
          notificationSlots: [],
        ),
      );
      final controller = MizanController(store, scheduler: SpyScheduler());
      await controller.load();
      final createdAt = DateTime.now();

      await controller.addDebtProduct(
        personId: 'person',
        bankId: 'bank',
        kind: DebtKind.loan,
        title: 'Takvim kredisi',
        totalAmount: 12000,
        monthlyAmount: 1000,
        dueDate: createdAt,
        dueMode: DebtDueMode.monthlyDay,
        dueDayOfMonth: 5,
      );

      final due =
          controller.state.people.single.banks.single.products.single.dueDate;
      final expected = DateTime(createdAt.year, createdAt.month + 1, 5);
      expect(due, expected);
    },
  );
}
