import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';

import 'test_support.dart';

void main() {
  test(
    'ödeme saati kaydedilince plan ek onay olmadan otomatik yenilenir',
    () async {
      final scheduler = SpyScheduler();
      final controller = MizanController(
        MemoryStore(comprehensiveState()),
        scheduler: scheduler,
      );
      await controller.load();
      final before = scheduler.rescheduleCount;
      final slot = controller.state.paymentNotificationSlots.first;

      await controller.updatePaymentNotificationSlot(
        slotId: slot.id,
        hour: 22,
        minute: 17,
        message: 'Dakik otomatik senkronizasyon',
      );

      expect(scheduler.rescheduleCount, before + 1);
      final scheduled = scheduler.lastScheduledState!.paymentNotificationSlots
          .firstWhere((item) => item.id == slot.id);
      expect(scheduled.hour, 22);
      expect(scheduled.minute, 17);
    },
  );

  test(
    'gider hatırlatma saati ve açık durumu otomatik senkronize edilir',
    () async {
      final scheduler = SpyScheduler();
      final controller = MizanController(
        MemoryStore(comprehensiveState()),
        scheduler: scheduler,
      );
      await controller.load();
      final before = scheduler.rescheduleCount;
      final slot = controller.state.notificationSlots.first;

      await controller.updateNotificationSlot(
        slotId: slot.id,
        hour: 6,
        minute: 43,
        enabled: false,
        message: 'Yeni gider mesajı',
      );

      expect(scheduler.rescheduleCount, before + 1);
      final scheduled = scheduler.lastScheduledState!.notificationSlots
          .firstWhere((item) => item.id == slot.id);
      expect(scheduled.hour, 6);
      expect(scheduled.minute, 43);
      expect(scheduled.enabled, isFalse);
    },
  );

  test(
    'bildirim açılınca eksik Android izinleri otomatik istenir ve planlanır',
    () async {
      final scheduler = SpyScheduler()
        ..permissionGranted = false
        ..preciseTimingGranted = false;
      final initial = comprehensiveState().copyWith(
        notificationsEnabled: false,
      );
      final controller = MizanController(
        MemoryStore(initial),
        scheduler: scheduler,
      );
      await controller.load();
      scheduler.permissionGranted = false;
      scheduler.preciseTimingGranted = false;
      scheduler.permissionRequestCount = 0;
      scheduler.rescheduleCount = 0;

      await controller.setNotificationsEnabled(true);

      expect(scheduler.permissionRequestCount, greaterThanOrEqualTo(1));
      expect(scheduler.rescheduleCount, 1);
      expect(controller.state.notificationsEnabled, isTrue);
      expect(controller.notificationHealth.permissionGranted, isTrue);
      expect(controller.notificationHealth.preciseTimingGranted, isTrue);
    },
  );

  test(
    'Android izin ekranından dönünce plan kendiliğinden senkronize edilir',
    () async {
      final scheduler = SpyScheduler();
      final controller = MizanController(
        MemoryStore(comprehensiveState()),
        scheduler: scheduler,
      );
      await controller.load();
      final before = scheduler.rescheduleCount;

      await controller.synchronizeNotificationsAfterSystemResume();

      expect(scheduler.rescheduleCount, before + 1);
    },
  );

  testWidgets(
    'uygulama resumed olduğunda manuel butonsuz otomatik planlama yapar',
    (tester) async {
      final scheduler = SpyScheduler();
      final controller = MizanController(
        MemoryStore(comprehensiveState()),
        scheduler: scheduler,
      );
      await controller.load();
      await tester.pumpWidget(MizanApp(controller: controller));
      final before = scheduler.rescheduleCount;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(scheduler.rescheduleCount, before + 1);
    },
  );

  test('seçilen dakika plan modelinde saniyesiz ve tam dakika korunur', () {
    final state = MizanState.empty().copyWith(
      notificationSlots: const [
        NotificationSlot(
          id: 'daily-exact',
          label: 'Dakik gider',
          hour: 14,
          minute: 37,
          message: 'Dakik çalış',
        ),
      ],
    );
    final plan = const ReminderPlanBuilder().build(
      state: state,
      now: DateTime(2026, 7, 22, 14, 36, 59),
    );
    final reminder = plan.firstWhere((item) => item.sourceId == 'daily-exact');
    expect(reminder.scheduledAt, DateTime(2026, 7, 22, 14, 37));
    expect(reminder.scheduledAt.second, 0);
  });
}
