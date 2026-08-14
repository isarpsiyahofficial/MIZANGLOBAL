import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';

import 'test_support.dart';

void main() {
  _paymentReminderPreferenceTests();
  test(
    'bildirim saatleri cihaz yerel takviminde 09.00 ve 18.00 olarak kurulur',
    () {
      final now = DateTime(2026, 7, 19, 8, 15);
      final state = comprehensiveState(reference: now);
      final plan = const ReminderPlanBuilder().build(state: state, now: now);
      final paymentReminders = plan
          .where((item) => item.kind == ReminderKind.payment)
          .toList(growable: false);

      expect(paymentReminders, isNotEmpty);
      expect(
        paymentReminders.every(
          (item) => item.scheduledAt.hour == 9 || item.scheduledAt.hour == 18,
        ),
        isTrue,
      );
      expect(
        paymentReminders.every((item) => item.scheduledAt.minute == 0),
        isTrue,
      );
      expect(
        paymentReminders.every((item) => item.scheduledAt.isAfter(now)),
        isTrue,
      );
    },
  );

  test('hatırlatma planı state veya ödeme geçmişini değiştirmez', () {
    final now = DateTime(2026, 7, 19, 8);
    final state = comprehensiveState(reference: now);
    final before = state.toJson();
    final beforePaymentCount = paymentCount(state);

    const ReminderPlanBuilder().build(state: state, now: now);

    expect(state.toJson(), before);
    expect(paymentCount(state), beforePaymentCount);
  });

  test('bütün açık kayıt türleri için benzersiz bildirim kimliği oluşur', () {
    final now = DateTime(2026, 7, 19, 8);
    final plan = const ReminderPlanBuilder().build(
      state: comprehensiveState(reference: now),
      now: now,
    );
    final paymentReminders = plan
        .where((item) => item.kind == ReminderKind.payment)
        .toList(growable: false);
    final ids = paymentReminders.map((item) => item.id).toSet();
    final sourceIds = paymentReminders.map((item) => item.sourceId).toSet();

    expect(ids.length, paymentReminders.length);
    expect(
      sourceIds,
      containsAll(<String>[
        'bank-debt-1',
        'personal-debt-1',
        'bill-1',
        'subscription-1',
        'rent-1',
      ]),
    );
  });

  test('tamamlanan veya arşivlenen kayıt için bildirim oluşmaz', () {
    final now = DateTime(2026, 7, 19, 8);
    final state = MizanState(
      people: [
        PersonAccount(
          id: 'p',
          name: 'Kişi',
          bills: [
            BillEntry(
              id: 'paid',
              currencyCode: 'TRY',
              kind: BillKind.water,
              institutionName: 'Kurum',
              amount: 100,
              dueDate: now.add(const Duration(days: 2)),
              payments: [
                PaymentRecord(id: 'payment', amount: 100, paidAt: now),
              ],
            ),
            BillEntry(
              id: 'archived',
              currencyCode: 'TRY',
              kind: BillKind.phone,
              institutionName: 'Kurum',
              amount: 100,
              dueDate: now.add(const Duration(days: 2)),
              isArchived: true,
            ),
          ],
        ),
      ],
      expenseCategories: const [],
      expenses: const [],
      notificationSlots: const [],
    );
    final plan = const ReminderPlanBuilder().build(state: state, now: now);
    expect(plan, isEmpty);
  });
}

// Ödeme sıklığı ve aylık vade günü doğrulamaları.
void _paymentReminderPreferenceTests() {
  test('bildirim sıklığı günde bir iki ve üç planı doğru saatlerde üretir', () {
    final now = DateTime(2026, 7, 19, 8);
    final base = comprehensiveState(
      reference: now,
    ).copyWith(notificationSlots: const []);
    final expectations = <PaymentReminderFrequency, List<int>>{
      PaymentReminderFrequency.onceDaily: [10],
      PaymentReminderFrequency.twiceDaily: [9, 18],
      PaymentReminderFrequency.threeTimesDaily: [9, 14, 20],
    };
    for (final entry in expectations.entries) {
      final plan = const ReminderPlanBuilder().build(
        state: base.copyWith(paymentReminderFrequency: entry.key),
        now: now,
      );
      final hours = plan
          .where((item) => item.kind == ReminderKind.payment)
          .map((item) => item.scheduledAt.hour)
          .toSet();
      expect(hours, entry.value.toSet());
    }
  });

  test('her ayın belirli günü seçilen banka borcu bildirim planına girer', () {
    final now = DateTime(2026, 7, 1, 8);
    final state = MizanState(
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
                  id: 'monthly',
                  currencyCode: 'TRY',
                  kind: DebtKind.loan,
                  title: 'Aylık kredi',
                  totalAmount: 50000,
                  monthlyAmount: 2500,
                  dueDate: DateTime(2026, 7, 5),
                  dueMode: DebtDueMode.monthlyDay,
                  dueDayOfMonth: 5,
                ),
              ],
            ),
          ],
        ),
      ],
      expenseCategories: const [],
      expenses: const [],
      notificationSlots: const [],
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'payment-test',
          label: 'Ödeme testi',
          hour: 10,
          minute: 0,
          message: 'Kontrol et',
        ),
      ],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
    );
    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    expect(reminders, isNotEmpty);
    expect(reminders.every((item) => item.sourceId == 'monthly'), isTrue);
    expect(
      reminders.any(
        (item) =>
            item.scheduledAt.year == 2026 &&
            item.scheduledAt.month == 7 &&
            item.scheduledAt.day == 1 &&
            item.scheduledAt.hour == 10,
      ),
      isTrue,
    );
    expect(reminders.first.message, contains('5 Tem 2026'));
    expect(reminders.first.message, contains('2.500,00 TL'));
  });

  test(
    'çok kayıtlı planda bildirim sayısı güvenli ve kararlı sınırı aşmaz',
    () {
      final now = DateTime(2026, 7, 25, 8);
      final products = [
        for (var index = 0; index < 180; index++)
          DebtProduct(
            id: 'debt-$index',
            currencyCode: 'TRY',
            kind: DebtKind.creditCard,
            title: 'Kart $index',
            totalAmount: 1000,
            monthlyAmount: 100,
            dueDate: DateTime(2026, 7, 25),
          ),
      ];
      final state = MizanState.empty().copyWith(
        people: [
          PersonAccount(
            id: 'p',
            name: 'Kişi',
            banks: [
              BankGroup(id: 'b', userWrittenName: 'Banka', products: products),
            ],
          ),
        ],
        notificationSlots: defaultNotificationSlots,
      );
      final first = const ReminderPlanBuilder().build(state: state, now: now);
      final second = const ReminderPlanBuilder().build(state: state, now: now);
      expect(
        first.length,
        lessThanOrEqualTo(safeMaximumConcurrentNotifications),
      );
      expect(first.map((item) => item.id).toSet().length, first.length);
      expect(
        second.map((item) => item.id).toList(),
        first.map((item) => item.id).toList(),
      );
    },
  );
}
