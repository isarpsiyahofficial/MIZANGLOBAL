import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';

import 'test_support.dart';

Future<void> _pump(WidgetTester tester, Size size, double scale) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final state = comprehensiveState(reference: DateTime(2026, 8, 7)).copyWith(
    appLanguageTag: 'ms',
    debtRegionCountryCode: 'MY',
    defaultCurrencyCode: 'MYR',
  );
  final controller = MizanController(
    MemoryStore(state),
    scheduler: SpyScheduler(),
  );
  await controller.load();
  await tester.pumpWidget(MizanApp(controller: controller));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _visit(WidgetTester tester) async {
  for (final icon in const [
    Icons.people_alt_outlined,
    Icons.shopping_bag_outlined,
    Icons.bar_chart_outlined,
    Icons.settings_outlined,
    Icons.space_dashboard_outlined,
  ]) {
    final bar = find.byType(NavigationBar);
    final rail = find.byType(NavigationRail);
    final root = bar.evaluate().isNotEmpty ? bar : rail;
    await tester.tap(find.descendant(of: root, matching: find.byIcon(icon)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }
}

void main() {
  testWidgets(
    'Malay 320x568 at 1.4x has no overflow or Indonesian/Turkish nav leakage',
    (tester) async {
      await _pump(tester, const Size(320, 568), 1.4);
      for (final text in const [
        'Laman utama',
        'Rekod',
        'Perbelanjaan',
        'Laporan',
        'Tetapan',
      ])
        expect(find.text(text), findsWidgets);
      expect(find.text('Ana sayfa'), findsNothing);
      expect(find.text('Beranda'), findsNothing);
      expect(
        Directionality.of(tester.element(find.text('Laman utama').first)),
        TextDirection.ltr,
      );
      await _visit(tester);
    },
  );
  testWidgets('Malay 412x915 at 2.0x remains usable without overflow', (
    tester,
  ) async {
    await _pump(tester, const Size(412, 915), 2);
    expect(
      Directionality.of(tester.element(find.text('Laman utama').first)),
      TextDirection.ltr,
    );
    await _visit(tester);
  });
}
