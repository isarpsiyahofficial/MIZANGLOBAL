import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';

import 'test_support.dart';

Map<String, dynamic> _businessPayload(MizanState state) => <String, dynamic>{
  'people': state.people.map((item) => item.toJson()).toList(),
  'expenseCategories': state.expenseCategories
      .map((item) => item.toJson())
      .toList(),
  'expenses': state.expenses.map((item) => item.toJson()).toList(),
  'incomes': state.incomes.map((item) => item.toJson()).toList(),
  'notificationSlots': state.notificationSlots
      .map((item) => item.toJson())
      .toList(),
  'paymentNotificationSlots': state.paymentNotificationSlots
      .map((item) => item.toJson())
      .toList(),
  'notificationsEnabled': state.notificationsEnabled,
  'notificationSoundMode': state.notificationSoundMode.name,
  'notificationVibrationEnabled': state.notificationVibrationEnabled,
};

void main() {
  test(
    'language change preserves region, default currency, and all business data',
    () async {
      final initial = comprehensiveState().copyWith(
        setupCompleted: true,
        appLanguageTag: 'tr',
        debtRegionCountryCode: 'TR',
        defaultCurrencyCode: 'TRY',
        recentCurrencyCodes: const ['TRY', 'USD'],
      );
      final store = MemoryStore(initial);
      final controller = MizanController(store, scheduler: SpyScheduler());
      await controller.load();
      final before = _businessPayload(controller.state);

      await controller.updateGlobalPreferences(
        appLanguageTag: 'en',
        debtRegionCountryCode: controller.state.debtRegionCountryCode,
        defaultCurrencyCode: controller.state.defaultCurrencyCode,
      );

      expect(controller.state.appLanguageTag, 'en');
      expect(controller.state.debtRegionCountryCode, 'TR');
      expect(controller.state.defaultCurrencyCode, 'TRY');
      expect(_businessPayload(controller.state), before);
    },
  );

  test(
    'region change preserves language, default currency, and all business data',
    () async {
      final initial = comprehensiveState().copyWith(
        setupCompleted: true,
        appLanguageTag: 'de',
        debtRegionCountryCode: 'DE',
        defaultCurrencyCode: 'EUR',
      );
      final store = MemoryStore(initial);
      final controller = MizanController(store, scheduler: SpyScheduler());
      await controller.load();
      final before = _businessPayload(controller.state);

      await controller.updateGlobalPreferences(
        appLanguageTag: controller.state.appLanguageTag,
        debtRegionCountryCode: 'CH',
        defaultCurrencyCode: controller.state.defaultCurrencyCode,
      );

      expect(controller.state.appLanguageTag, 'de');
      expect(controller.state.debtRegionCountryCode, 'CH');
      expect(controller.state.defaultCurrencyCode, 'EUR');
      expect(_businessPayload(controller.state), before);
    },
  );

  test(
    'default currency change preserves language, region, and all business data',
    () async {
      final initial = comprehensiveState().copyWith(
        setupCompleted: true,
        appLanguageTag: 'en',
        debtRegionCountryCode: 'US',
        defaultCurrencyCode: 'USD',
        recentCurrencyCodes: const ['USD', 'EUR'],
      );
      final store = MemoryStore(initial);
      final controller = MizanController(store, scheduler: SpyScheduler());
      await controller.load();
      final before = _businessPayload(controller.state);

      await controller.updateGlobalPreferences(
        appLanguageTag: controller.state.appLanguageTag,
        debtRegionCountryCode: controller.state.debtRegionCountryCode,
        defaultCurrencyCode: 'AED',
      );

      expect(controller.state.appLanguageTag, 'en');
      expect(controller.state.debtRegionCountryCode, 'US');
      expect(controller.state.defaultCurrencyCode, 'AED');
      expect(controller.state.recentCurrencyCodes.first, 'AED');
      expect(_businessPayload(controller.state), before);
    },
  );

  test(
    'current CSV snapshot carries and restores all three profile preferences',
    () {
      const service = CsvBackupService();
      final source = comprehensiveState().copyWith(
        setupCompleted: true,
        appLanguageTag: 'ja',
        debtRegionCountryCode: 'JP',
        defaultCurrencyCode: 'JPY',
        recentCurrencyCodes: const ['JPY', 'USD'],
      );

      final restored = service.importState(service.exportState(source));

      expect(restored.setupCompleted, isTrue);
      expect(restored.appLanguageTag, 'ja');
      expect(restored.debtRegionCountryCode, 'JP');
      expect(restored.defaultCurrencyCode, 'JPY');
      expect(restored.recentCurrencyCodes, const ['JPY', 'USD']);
      expect(_businessPayload(restored), _businessPayload(source));
    },
  );

  test(
    'legacy Turkish state without global profile remains compatible and data-identical',
    () {
      final source = comprehensiveState();
      final legacyJson = Map<String, dynamic>.from(source.toJson())
        ..remove('setupCompleted')
        ..remove('appLanguageTag')
        ..remove('debtRegionCountryCode')
        ..remove('defaultCurrencyCode')
        ..remove('recentCurrencyCodes')
        ..['schemaVersion'] = 12;

      final restored = MizanState.fromJson(legacyJson);

      expect(restored.setupCompleted, isTrue);
      expect(restored.appLanguageTag, 'tr');
      expect(restored.debtRegionCountryCode, 'TR');
      expect(restored.defaultCurrencyCode, 'TRY');
      expect(_businessPayload(restored), _businessPayload(source));
    },
  );

  test('backup merge adopts profile only for an unfinished fresh setup', () {
    const service = CsvBackupService();
    final imported = comprehensiveState().copyWith(
      setupCompleted: true,
      appLanguageTag: 'fr',
      debtRegionCountryCode: 'FR',
      defaultCurrencyCode: 'EUR',
      recentCurrencyCodes: const ['EUR', 'USD'],
    );

    final merged = service
        .mergeStates(MizanState.freshInstall(), imported)
        .state;

    expect(merged.setupCompleted, isTrue);
    expect(merged.appLanguageTag, 'fr');
    expect(merged.debtRegionCountryCode, 'FR');
    expect(merged.defaultCurrencyCode, 'EUR');
    expect(merged.recentCurrencyCodes, const ['EUR', 'USD']);
    expect(merged.people, isNotEmpty);
  });

  test(
    'backup merge into configured app preserves current profile preferences',
    () {
      const service = CsvBackupService();
      final current = MizanState.empty().copyWith(
        setupCompleted: true,
        appLanguageTag: 'en',
        debtRegionCountryCode: 'US',
        defaultCurrencyCode: 'USD',
      );
      final imported = comprehensiveState().copyWith(
        setupCompleted: true,
        appLanguageTag: 'de',
        debtRegionCountryCode: 'DE',
        defaultCurrencyCode: 'EUR',
      );

      final merged = service.mergeStates(current, imported).state;

      expect(merged.appLanguageTag, 'en');
      expect(merged.debtRegionCountryCode, 'US');
      expect(merged.defaultCurrencyCode, 'USD');
      expect(merged.people, isNotEmpty);
    },
  );

  test('re-importing the same backup is idempotent for user records', () {
    const service = CsvBackupService();
    final imported = comprehensiveState();
    final first = service.mergeStates(MizanState.empty(), imported).state;
    final firstPayload = _businessPayload(first);
    final secondResult = service.mergeStates(first, imported);

    expect(_businessPayload(secondResult.state), firstPayload);
    expect(secondResult.addedCount, 0);
  });
}
