import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';

import 'test_support.dart';

Future<void> _pumpIndonesianAt(
  WidgetTester tester,
  Size size, {
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final state = comprehensiveState(reference: DateTime(2026, 8, 6)).copyWith(
    appLanguageTag: 'id',
    debtRegionCountryCode: 'ID',
    defaultCurrencyCode: 'IDR',
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

Future<void> _visitIndonesianTabs(WidgetTester tester) async {
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

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

void main() {
  testWidgets('Indonesian 320x568 at 1.4x is LTR and avoids overflow', (
    tester,
  ) async {
    await _pumpIndonesianAt(tester, const Size(320, 568), textScale: 1.4);
    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Catatan'), findsWidgets);
    expect(find.text('Pengeluaran'), findsWidgets);
    expect(find.text('Laporan'), findsWidgets);
    expect(find.text('Pengaturan'), findsWidgets);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('الصفحة الرئيسية'), findsNothing);
    expect(find.text('হোম'), findsNothing);
    expect(
      Directionality.of(tester.element(find.text('Beranda').first)),
      TextDirection.ltr,
    );
    await _visitIndonesianTabs(tester);
    await _disposeApp(tester);
  });

  testWidgets('Indonesian 412x915 at 2.0x remains LTR without overflow', (
    tester,
  ) async {
    await _pumpIndonesianAt(tester, const Size(412, 915), textScale: 2);
    expect(
      Directionality.of(tester.element(find.text('Beranda').first)),
      TextDirection.ltr,
    );
    await _visitIndonesianTabs(tester);
    await _disposeApp(tester);
  });
}
