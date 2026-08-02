import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/local_store.dart';

import 'test_support.dart';

Map<String, dynamic> _dataOnly(MizanState state) {
  final json = Map<String, dynamic>.from(state.toJson());
  for (final key in const <String>[
    'appLanguageTag',
    'debtRegionCountryCode',
    'defaultCurrencyCode',
    'recentCurrencyCodes',
  ]) {
    json.remove(key);
  }
  return json;
}

class _FailingSaveStore implements MizanStore {
  _FailingSaveStore(this.initial);

  final MizanState initial;

  @override
  Future<StoreLoadResult> load() async =>
      StoreLoadResult(state: initial, source: StoreLoadSource.primary);

  @override
  Future<void> reset(MizanState state) async {
    throw StateError('save-failed');
  }

  @override
  Future<void> save(MizanState state) async {
    throw StateError('save-failed');
  }
}

void _expectNoForeignSystemCopy(WidgetTester tester) {
  final rendered = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
      .where((value) => value.trim().isNotEmpty)
      .join('\n');

  for (final forbidden in const <String>[
    'Ana sayfa',
    'Kayıtlar',
    'Giderler',
    'Raporlar',
    'Ayarlar',
    'Dil, ülke ve para birimi',
    'Bildirim sistemi',
    'Ödeme hatırlatmaları',
    'Kişi ekle',
    'Gider ekle',
    'Home',
    'Records',
    'Expenses',
    'Reports',
    'Settings',
    'Language, country, and currency',
    'Notification system',
    'Payment reminders',
    'Add person',
    'Add expense',
  ]) {
    expect(rendered, isNot(contains(forbidden)), reason: rendered);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'changed language is durably saved before restart and every data record survives reload',
    () async {
      final initial = comprehensiveState().copyWith(
        setupCompleted: true,
        appLanguageTag: 'tr',
        debtRegionCountryCode: 'TR',
        defaultCurrencyCode: 'TRY',
      );
      final beforeData = _dataOnly(initial);
      final store = MemoryStore(initial);
      var restartCount = 0;
      MizanState? stateAtRestart;
      final controller = MizanController(
        store,
        scheduler: SpyScheduler(),
        onLanguageChanged: () {
          restartCount++;
          stateAtRestart = MizanState.fromJson(store.current.toJson());
        },
      );
      await controller.load();

      await controller.updateGlobalPreferences(
        appLanguageTag: 'es',
        debtRegionCountryCode: 'TR',
        defaultCurrencyCode: 'TRY',
      );

      expect(restartCount, 1);
      expect(stateAtRestart, isNotNull);
      expect(stateAtRestart!.appLanguageTag, 'es');
      expect(store.current.appLanguageTag, 'es');
      expect(_dataOnly(store.current), beforeData);
      expect(_dataOnly(controller.state), beforeData);

      final reopened = MizanController(store, scheduler: SpyScheduler());
      await reopened.load();
      expect(reopened.state.appLanguageTag, 'es');
      expect(_dataOnly(reopened.state), beforeData);
    },
  );

  test(
    'same language does not restart and a failed save never restarts',
    () async {
      final initial = comprehensiveState().copyWith(
        setupCompleted: true,
        appLanguageTag: 'es',
        debtRegionCountryCode: 'ES',
        defaultCurrencyCode: 'EUR',
      );
      var sameLanguageRestarts = 0;
      final stable = MizanController(
        MemoryStore(initial),
        scheduler: SpyScheduler(),
        onLanguageChanged: () => sameLanguageRestarts++,
      );
      await stable.load();
      await stable.updateGlobalPreferences(
        appLanguageTag: 'es-ES',
        debtRegionCountryCode: 'ES',
        defaultCurrencyCode: 'EUR',
      );
      expect(sameLanguageRestarts, 0);

      var failedSaveRestarts = 0;
      final failing = MizanController(
        _FailingSaveStore(initial.copyWith(appLanguageTag: 'tr')),
        scheduler: SpyScheduler(),
        onLanguageChanged: () => failedSaveRestarts++,
      );
      await failing.load();
      await expectLater(
        failing.updateGlobalPreferences(
          appLanguageTag: 'es',
          debtRegionCountryCode: 'ES',
          defaultCurrencyCode: 'EUR',
        ),
        throwsA(isA<StateError>()),
      );
      expect(failedSaveRestarts, 0);
      expect(failing.state.appLanguageTag, 'tr');
    },
  );

  testWidgets(
    'changing language from settings restarts the complete app in Spanish without foreign system copy',
    (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> renderFrame() async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      }

      final initial = MizanState.empty().copyWith(
        setupCompleted: true,
        appLanguageTag: 'tr',
        debtRegionCountryCode: 'TR',
        defaultCurrencyCode: 'TRY',
      );
      final store = MemoryStore(initial);
      final controller = MizanController(store, scheduler: SpyScheduler());
      final catalog = await GlobalCatalogRepository.load();
      await controller.load();
      await tester.pumpWidget(
        MizanApp(controller: controller, catalog: catalog),
      );
      await renderFrame();

      var navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
      navigation.onDestinationSelected!(4);
      await renderFrame();
      navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigation.selectedIndex, 4);
      expect(find.text('Uygulama dili'), findsOneWidget);

      await tester.tap(find.text('Uygulama dili'));
      await renderFrame();
      expect(find.text('Dil seç'), findsOneWidget);
      await tester.tap(find.text('ES').first);
      await renderFrame();

      expect(controller.state.appLanguageTag, 'es');
      expect(store.current.appLanguageTag, 'es');
      navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(
        navigation.selectedIndex,
        0,
        reason: 'The rebuilt app must restart from the home destination.',
      );
      expect(find.text('Inicio'), findsWidgets);
      expect(find.text('Registros'), findsWidgets);
      expect(find.text('Gastos'), findsWidgets);
      expect(find.text('Informes'), findsWidgets);
      expect(find.text('Ajustes'), findsWidgets);
      _expectNoForeignSystemCopy(tester);

      for (var index = 0; index < 5; index++) {
        navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
        navigation.onDestinationSelected!(index);
        await renderFrame();
        _expectNoForeignSystemCopy(tester);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
