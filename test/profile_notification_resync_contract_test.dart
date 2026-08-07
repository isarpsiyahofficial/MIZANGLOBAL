import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';

import 'test_support.dart';

void main() {
  test(
    'language change reschedules system notifications without changing data',
    () async {
      final initial = comprehensiveState().copyWith(
        setupCompleted: true,
        appLanguageTag: 'tr',
        debtRegionCountryCode: 'TR',
        defaultCurrencyCode: 'TRY',
      );
      final store = MemoryStore(initial);
      final scheduler = SpyScheduler();
      final controller = MizanController(store, scheduler: scheduler);
      await controller.load();
      final baselineReschedules = scheduler.rescheduleCount;
      final before = controller.state.people.single.toJson();

      await controller.updateGlobalPreferences(
        appLanguageTag: 'en',
        debtRegionCountryCode: controller.state.debtRegionCountryCode,
        defaultCurrencyCode: controller.state.defaultCurrencyCode,
      );

      expect(scheduler.rescheduleCount, baselineReschedules + 1);
      expect(controller.state.people.single.toJson(), before);
      expect(controller.state.debtRegionCountryCode, 'TR');
      expect(controller.state.defaultCurrencyCode, 'TRY');
    },
  );

  test(
    'region-only change does not rewrite the notification schedule',
    () async {
      final store = MemoryStore(
        comprehensiveState().copyWith(
          setupCompleted: true,
          appLanguageTag: 'en',
          debtRegionCountryCode: 'US',
          defaultCurrencyCode: 'USD',
        ),
      );
      final scheduler = SpyScheduler();
      final controller = MizanController(store, scheduler: scheduler);
      await controller.load();
      final baselineReschedules = scheduler.rescheduleCount;

      await controller.updateGlobalPreferences(
        appLanguageTag: controller.state.appLanguageTag,
        debtRegionCountryCode: 'CA',
        defaultCurrencyCode: controller.state.defaultCurrencyCode,
      );

      expect(scheduler.rescheduleCount, baselineReschedules);
    },
  );

  test(
    'default-currency-only change does not rewrite existing notification plan',
    () async {
      final store = MemoryStore(
        comprehensiveState().copyWith(
          setupCompleted: true,
          appLanguageTag: 'en',
          debtRegionCountryCode: 'US',
          defaultCurrencyCode: 'USD',
        ),
      );
      final scheduler = SpyScheduler();
      final controller = MizanController(store, scheduler: scheduler);
      await controller.load();
      final baselineReschedules = scheduler.rescheduleCount;

      await controller.updateGlobalPreferences(
        appLanguageTag: controller.state.appLanguageTag,
        debtRegionCountryCode: controller.state.debtRegionCountryCode,
        defaultCurrencyCode: 'EUR',
      );

      expect(scheduler.rescheduleCount, baselineReschedules);
    },
  );
}
