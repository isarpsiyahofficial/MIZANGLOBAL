#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected one source anchor, found {count}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def update_controller() -> None:
    path = ROOT / "lib" / "controllers" / "mizan_controller.dart"
    replace_once(
        path,
        """  MizanController(\n    this._store, {\n    this._scheduler = const NoopReminderScheduler(),\n  });\n\n  final MizanStore _store;\n  final ReminderScheduler _scheduler;\n""",
        """  MizanController(\n    this._store, {\n    this._scheduler = const NoopReminderScheduler(),\n    this.onLanguageChanged,\n  });\n\n  final MizanStore _store;\n  final ReminderScheduler _scheduler;\n\n  /// Called only after a changed language preference has been validated and\n  /// durably saved. The UI uses this signal to rebuild the full app tree.\n  VoidCallback? onLanguageChanged;\n""",
        "controller language callback",
    )
    replace_once(
        path,
        """  }) async {\n    final language = appLanguageTag.trim();\n    final country = debtRegionCountryCode.trim().toUpperCase();\n""",
        """  }) async {\n    final previousLanguage = MizanI18n.normalizeLanguageTag(\n      _state.appLanguageTag,\n    );\n    final language = MizanI18n.normalizeLanguageTag(appLanguageTag);\n    final country = debtRegionCountryCode.trim().toUpperCase();\n""",
        "controller previous language capture",
    )
    replace_once(
        path,
        """      reschedule: false,\n    );\n  }\n\n  Future<void> addPerson(String name) async {\n""",
        """      reschedule: false,\n    );\n    if (language != previousLanguage) {\n      onLanguageChanged?.call();\n    }\n  }\n\n  Future<void> addPerson(String name) async {\n""",
        "controller post-save restart signal",
    )


def update_main() -> None:
    path = ROOT / "lib" / "main.dart"
    old = """class MizanApp extends StatelessWidget {\n  const MizanApp({required this.controller, this.catalog, super.key});\n  final MizanController controller;\n  final GlobalCatalog? catalog;\n\n  @override\n  Widget build(BuildContext context) => AnimatedBuilder(\n    animation: controller,\n    builder: (context, _) {\n      final languageTag = MizanI18n.normalizeLanguageTag(\n        controller.state.appLanguageTag,\n      );\n      MizanI18n.setProfile(\n        languageTag: languageTag,\n        currencyCode: controller.state.defaultCurrencyCode,\n      );\n      return MaterialApp(\n        title: 'LEFFERION PRIME - MIZAN',\n        debugShowCheckedModeBanner: false,\n        locale: Locale(languageTag),\n        supportedLocales: const [Locale('tr'), Locale('en'), Locale('es')],\n        localizationsDelegates: const [\n          GlobalMaterialLocalizations.delegate,\n          GlobalWidgetsLocalizations.delegate,\n          GlobalCupertinoLocalizations.delegate,\n        ],\n        theme: MizanTheme.light(),\n        home: MizanHome(controller: controller, catalog: catalog),\n      );\n    },\n  );\n}\n\n"""
    new = """class MizanApp extends StatefulWidget {\n  const MizanApp({required this.controller, this.catalog, super.key});\n  final MizanController controller;\n  final GlobalCatalog? catalog;\n\n  @override\n  State<MizanApp> createState() => _MizanAppState();\n}\n\nclass _MizanAppState extends State<MizanApp> {\n  int _restartGeneration = 0;\n  VoidCallback? _previousLanguageChanged;\n\n  @override\n  void initState() {\n    super.initState();\n    _bindController(widget.controller);\n  }\n\n  @override\n  void didUpdateWidget(covariant MizanApp oldWidget) {\n    super.didUpdateWidget(oldWidget);\n    if (!identical(oldWidget.controller, widget.controller)) {\n      oldWidget.controller.onLanguageChanged = _previousLanguageChanged;\n      _bindController(widget.controller);\n    }\n  }\n\n  void _bindController(MizanController controller) {\n    _previousLanguageChanged = controller.onLanguageChanged;\n    controller.onLanguageChanged = _restartAfterLanguageChange;\n  }\n\n  void _restartAfterLanguageChange() {\n    _previousLanguageChanged?.call();\n    if (!mounted) return;\n    setState(() => _restartGeneration++);\n  }\n\n  @override\n  void dispose() {\n    widget.controller.onLanguageChanged = _previousLanguageChanged;\n    super.dispose();\n  }\n\n  @override\n  Widget build(BuildContext context) => AnimatedBuilder(\n    animation: widget.controller,\n    builder: (context, _) {\n      final languageTag = MizanI18n.normalizeLanguageTag(\n        widget.controller.state.appLanguageTag,\n      );\n      MizanI18n.setProfile(\n        languageTag: languageTag,\n        currencyCode: widget.controller.state.defaultCurrencyCode,\n      );\n      return MaterialApp(\n        key: ValueKey<int>(_restartGeneration),\n        title: 'LEFFERION PRIME - MIZAN',\n        debugShowCheckedModeBanner: false,\n        locale: Locale(languageTag),\n        supportedLocales: const [Locale('tr'), Locale('en'), Locale('es')],\n        localizationsDelegates: const [\n          GlobalMaterialLocalizations.delegate,\n          GlobalWidgetsLocalizations.delegate,\n          GlobalCupertinoLocalizations.delegate,\n        ],\n        theme: MizanTheme.light(),\n        home: MizanHome(\n          key: ValueKey<int>(_restartGeneration),\n          controller: widget.controller,\n          catalog: widget.catalog,\n        ),\n      );\n    },\n  );\n}\n\n"""
    replace_once(path, old, new, "stateful app restart boundary")


def update_validator() -> None:
    path = ROOT / "tools" / "validate_spanish_localization.py"
    text = path.read_text(encoding="utf-8")
    anchor = """if \"supportedLocales: const [Locale('tr'), Locale('en'), Locale('es')]\" not in main_source:\n    failures.append(\"MaterialApp must expose Turkish, English and Spanish\")\n\n"""
    addition = """if \"supportedLocales: const [Locale('tr'), Locale('en'), Locale('es')]\" not in main_source:\n    failures.append(\"MaterialApp must expose Turkish, English and Spanish\")\nif \"class MizanApp extends StatefulWidget\" not in main_source:\n    failures.append(\"MizanApp must own a restartable state boundary\")\nif \"key: ValueKey<int>(_restartGeneration)\" not in main_source:\n    failures.append(\"language changes must replace the complete MaterialApp tree\")\nif \"controller.onLanguageChanged = _restartAfterLanguageChange\" not in main_source:\n    failures.append(\"MizanApp is not connected to the saved-language restart signal\")\n\nfor surface in [LIB / \"main.dart\", *sorted((LIB / \"screens\").glob(\"*.dart\")), *sorted((LIB / \"widgets\").glob(\"*.dart\"))]:\n    source = surface.read_text(encoding=\"utf-8\")\n    if \"package:flutter/material.dart\" in source:\n        failures.append(\n            f\"{surface.relative_to(ROOT)} bypasses the localized Material/Text layer\"\n        )\n    if \"material.Text(\" in source:\n        failures.append(\n            f\"{surface.relative_to(ROOT)} renders system copy outside the localized Text layer\"\n        )\n\n"""
    if addition not in text:
        if text.count(anchor) != 1:
            raise SystemExit("Spanish validator main-source anchor is missing")
        text = text.replace(anchor, addition, 1)

    controller_anchor = """if \"MizanI18n.destructiveConfirmation\" not in expense_source:\n    failures.append(\"expense screen does not display the Spanish confirmation command\")\n\n"""
    controller_addition = """if \"MizanI18n.destructiveConfirmation\" not in expense_source:\n    failures.append(\"expense screen does not display the Spanish confirmation command\")\nif \"VoidCallback? onLanguageChanged;\" not in controller_source:\n    failures.append(\"controller language restart signal is missing\")\ncommit_position = controller_source.find(\"await _commit(\", controller_source.find(\"Future<void> updateGlobalPreferences\"))\nrestart_position = controller_source.find(\"onLanguageChanged?.call();\", commit_position)\nif commit_position < 0 or restart_position < commit_position:\n    failures.append(\"language restart must be signaled only after the durable preference commit\")\n\n"""
    if controller_addition not in text:
        if text.count(controller_anchor) != 1:
            raise SystemExit("Spanish validator controller anchor is missing")
        text = text.replace(controller_anchor, controller_addition, 1)
    path.write_text(text, encoding="utf-8")


def create_restart_tests() -> None:
    path = ROOT / "test" / "language_restart_test.dart"
    path.write_text(
        r'''import 'package:flutter/material.dart';
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
  Future<StoreLoadResult> load() async => StoreLoadResult(
    state: initial,
    source: StoreLoadSource.primary,
  );

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

      final reopened = MizanController(
        store,
        scheduler: SpyScheduler(),
      );
      await reopened.load();
      expect(reopened.state.appLanguageTag, 'es');
      expect(_dataOnly(reopened.state), beforeData);
    },
  );

  test('same language does not restart and a failed save never restarts', () async {
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
  });

  testWidgets(
    'changing language from settings restarts the complete app in Spanish without foreign system copy',
    (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final initial = MizanState.empty().copyWith(
        setupCompleted: true,
        appLanguageTag: 'tr',
        debtRegionCountryCode: 'TR',
        defaultCurrencyCode: 'TRY',
      );
      final store = MemoryStore(initial);
      final controller = MizanController(
        store,
        scheduler: SpyScheduler(),
      );
      final catalog = await GlobalCatalogRepository.load();
      await controller.load();
      await tester.pumpWidget(
        MizanApp(controller: controller, catalog: catalog),
      );
      await tester.pumpAndSettle();

      var navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
      navigation.onDestinationSelected!(4);
      await tester.pumpAndSettle();
      navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigation.selectedIndex, 4);
      expect(find.text('Uygulama dili'), findsOneWidget);

      await tester.tap(find.text('Uygulama dili'));
      await tester.pumpAndSettle();
      expect(find.text('Dil seç'), findsOneWidget);
      await tester.tap(find.text('Español').first);
      await tester.pumpAndSettle();

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
        await tester.pumpAndSettle();
        _expectNoForeignSystemCopy(tester);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
''',
        encoding="utf-8",
    )


def main() -> None:
    update_controller()
    update_main()
    update_validator()
    create_restart_tests()
    print("Language restart and Spanish integrity source changes applied.")


if __name__ == "__main__":
    main()
