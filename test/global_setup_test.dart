import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('global katalog 29 dil 161 ülke ve 154 para birimi içerir', () async {
    final catalog = await GlobalCatalogRepository.load();
    expect(catalog.languages, hasLength(29));
    expect(catalog.countries, hasLength(161));
    expect(catalog.currencies, hasLength(154));
    expect(catalog.languages.where((item) => item.code == 'zh'), hasLength(1));
    expect(catalog.countries.any((item) => item.code == 'TR'), isTrue);
    expect(catalog.currencies.any((item) => item.code == 'TRY'), isTrue);
    expect(catalog.currencies.any((item) => item.code == 'USD'), isTrue);
  });

  test('dil ülke ve para birimi araması önek ve alias ile çalışır', () async {
    final catalog = await GlobalCatalogRepository.load();
    expect(
      catalog.languages.where((item) => item.matches('çin')).single.code,
      'zh',
    );
    expect(
      catalog.countries
          .where((item) => item.matches('tur'))
          .any((item) => item.code == 'TR'),
      isTrue,
    );
    expect(
      catalog.countries
          .where((item) => item.matches('US'))
          .any((item) => item.code == 'US'),
      isTrue,
    );
    expect(
      catalog.currencies
          .where((item) => item.matches('dol'))
          .any((item) => item.code == 'USD'),
      isTrue,
    );
    expect(
      catalog.currencies.where((item) => item.matches('TRY')).single.code,
      'TRY',
    );
  });

  test('eski TR yedeği global profil alanları olmadan güvenle açılır', () {
    final legacy = MizanState.fromJson(<String, dynamic>{
      'schemaVersion': 12,
      'people': const [],
      'expenseCategories': const [],
      'expenses': const [],
      'notificationSlots': const [],
      'paymentNotificationSlots': const [],
      'incomes': const [],
    });
    expect(legacy.setupCompleted, isTrue);
    expect(legacy.appLanguageTag, 'tr');
    expect(legacy.debtRegionCountryCode, 'TR');
    expect(legacy.defaultCurrencyCode, 'TRY');
  });

  test('yeni kurulum yalnız bir kez seçim ister', () {
    final fresh = MizanState.freshInstall();
    expect(fresh.setupCompleted, isFalse);
    final completed = fresh.copyWith(
      setupCompleted: true,
      appLanguageTag: 'en',
      debtRegionCountryCode: 'US',
      defaultCurrencyCode: 'USD',
    );
    final reopened = MizanState.fromJson(completed.toJson());
    expect(reopened.setupCompleted, isTrue);
    expect(reopened.appLanguageTag, 'en');
    expect(reopened.debtRegionCountryCode, 'US');
    expect(reopened.defaultCurrencyCode, 'USD');
  });

  test('ayar değişikliği kullanıcı kayıtlarını silmez', () async {
    final initial = comprehensiveState();
    final store = MemoryStore(initial);
    final controller = MizanController(store, scheduler: SpyScheduler());
    await controller.load();
    final before = controller.state.people.single.toJson();

    await controller.updateGlobalPreferences(
      appLanguageTag: 'en',
      debtRegionCountryCode: 'US',
      defaultCurrencyCode: 'USD',
    );

    expect(controller.state.people.single.toJson(), before);
    expect(controller.state.appLanguageTag, 'en');
    expect(controller.state.debtRegionCountryCode, 'US');
    expect(controller.state.defaultCurrencyCode, 'USD');
  });

  test('CSV yedeği ayarları korur ve desteklenmeyen dili güvenle sınırlar', () {
    const service = CsvBackupService();
    final state = comprehensiveState().copyWith(
      appLanguageTag: 'ar',
      debtRegionCountryCode: 'AE',
      defaultCurrencyCode: 'AED',
      recentCurrencyCodes: const ['AED', 'USD'],
    );
    final restored = service.importState(service.exportState(state));
    expect(restored.appLanguageTag, 'tr');
    expect(restored.debtRegionCountryCode, 'AE');
    expect(restored.defaultCurrencyCode, 'AED');
    expect(restored.recentCurrencyCodes, const ['AED', 'USD']);
  });
}
