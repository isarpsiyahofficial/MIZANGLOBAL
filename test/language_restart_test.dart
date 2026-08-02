import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
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

class _RestartBoundaryHarness extends StatefulWidget {
  const _RestartBoundaryHarness({required this.controller});

  final MizanController controller;

  @override
  State<_RestartBoundaryHarness> createState() => _RestartBoundaryHarnessState();
}

class _RestartBoundaryHarnessState extends State<_RestartBoundaryHarness> {
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.onLanguageChanged = _restart;
  }

  void _restart() {
    if (!mounted) return;
    setState(() => _generation++);
  }

  @override
  void dispose() {
    widget.controller.onLanguageChanged = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey<int>(_generation),
      home: Scaffold(
        body: Text(
          widget.controller.state.appLanguageTag,
          textDirection: TextDirection.ltr,
        ),
      ),
    );
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
    'persisted language callback replaces the complete restart boundary generation',
    (tester) async {
      final initial = comprehensiveState().copyWith(
        setupCompleted: true,
        appLanguageTag: 'tr',
        debtRegionCountryCode: 'TR',
        defaultCurrencyCode: 'TRY',
      );
      final beforeData = _dataOnly(initial);
      final store = MemoryStore(initial);
      final controller = MizanController(store, scheduler: SpyScheduler());
      await controller.load();

      await tester.pumpWidget(_RestartBoundaryHarness(controller: controller));
      final oldKey = tester.widget<MaterialApp>(find.byType(MaterialApp)).key;
      expect(find.text('tr'), findsOneWidget);

      await controller.updateGlobalPreferences(
        appLanguageTag: 'es',
        debtRegionCountryCode: 'TR',
        defaultCurrencyCode: 'TRY',
      );
      await tester.pump();

      expect(controller.state.appLanguageTag, 'es');
      expect(store.current.appLanguageTag, 'es');
      expect(_dataOnly(controller.state), beforeData);
      expect(_dataOnly(store.current), beforeData);
      expect(find.text('es'), findsOneWidget);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).key,
        isNot(equals(oldKey)),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      controller.dispose();
    },
  );

  test('MizanApp wires the controller callback to a keyed full-tree restart', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(
      source,
      contains('widget.controller.onLanguageChanged = _restartAfterLanguageChange;'),
    );
    expect(source, contains('setState(() => _restartGeneration++);'));
    expect(source, contains('key: ValueKey<int>(_restartGeneration),'));
    expect(source, contains('widget.controller.onLanguageChanged = null;'));
  });
}
