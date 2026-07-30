import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';

import 'test_support.dart';

void main() {
  test('eski alarm alanları yedekten güvenle okunur ve tekrar yazılmaz', () {
    final legacy = MizanState.empty().toJson()
      ..['notificationSoundMode'] = 'alarm'
      ..['notificationPresentationMode'] = 'alarm'
      ..['alarmRepeatMode'] = 'after10Minutes'
      ..['paymentNotificationSlots'] = [
        {
          'id': 'legacy-slot',
          'label': 'Eski kayıt',
          'hour': 8,
          'minute': 15,
          'message': 'Kontrol et',
          'enabled': true,
          'presentationMode': 'alarm',
        },
      ];

    final restored = MizanState.fromJson(legacy);
    final saved = restored.toJson();
    expect(restored.notificationSoundMode, NotificationSoundMode.system);
    expect(restored.paymentNotificationSlots.single.minute, 15);
    expect(saved.containsKey('notificationPresentationMode'), isFalse);
    expect(saved.containsKey('alarmRepeatMode'), isFalse);
    expect(
      (saved['paymentNotificationSlots'] as List).single,
      isNot(contains('presentationMode')),
    );
  });

  test(
    'her kayıt ve saat için yalnız sıradaki standart bildirim oluşturulur',
    () {
      final now = DateTime(2026, 7, 22, 7);
      final state = MizanState.empty().copyWith(
        people: [
          PersonAccount(
            id: 'person-1',
            name: 'Kişi',
            banks: [
              BankGroup(
                id: 'bank-1',
                userWrittenName: 'Banka',
                products: [
                  DebtProduct(
                    id: 'debt-1',
                    kind: DebtKind.creditCard,
                    title: 'Kart',
                    totalAmount: 1000,
                    monthlyAmount: 1000,
                    dueDate: DateTime(2026, 7, 22),
                  ),
                ],
              ),
            ],
          ),
        ],
        paymentNotificationSlots: const [
          NotificationSlot(
            id: 'slot-1',
            label: 'Özel',
            hour: 9,
            minute: 25,
            message: 'Ödeme',
          ),
        ],
        notificationSlots: const [],
      );

      final plan = const ReminderPlanBuilder().build(state: state, now: now);
      final payments = plan.where((item) => item.kind == ReminderKind.payment);
      expect(payments.length, 1);
      expect(payments.single.scheduledAt, DateTime(2026, 7, 22, 9, 25));
      expect(payments.single.repeatsDaily, isTrue);
      expect(payments.single.title, isNot(contains('alarm')));
    },
  );

  test('manuel gecikme dönemleri ve tutarı korunur', () {
    final debt = DebtProduct(
      id: 'debt-1',
      kind: DebtKind.loan,
      title: 'Kredi',
      totalAmount: 10000,
      monthlyAmount: 1000,
      dueDate: DateTime(2026, 6, 5),
      dueMode: DebtDueMode.monthlyDay,
      dueDayOfMonth: 5,
      manualOverdueDays: 46,
    );
    final reference = DateTime(2026, 7, 21);
    expect(debt.missedDuePeriodsAt(reference), [
      DateTime(2026, 6, 5),
      DateTime(2026, 7, 5),
    ]);
    expect(debt.dueAmountAt(reference), 2000);
    expect(debt.overdueDaysAt(reference), 46);
  });

  test('dakik test bildirimi controller state verisini değiştirmez', () async {
    final scheduler = SpyScheduler();
    final controller = MizanController(
      MemoryStore(MizanState.empty()),
      scheduler: scheduler,
    );
    await controller.load();
    const testSlot = NotificationSlot(
      id: 'test',
      label: 'Dakik test',
      hour: 14,
      minute: 38,
      message: 'Test mesajı',
    );
    final before = controller.state.toJson();
    final target = await controller.scheduleNotificationTest(testSlot);
    expect(scheduler.testScheduleCount, 1);
    expect(scheduler.lastTestSlot?.minute, 38);
    expect(target, DateTime(2026, 7, 22, 14, 38));
    expect(controller.state.toJson(), before);
  });
}
