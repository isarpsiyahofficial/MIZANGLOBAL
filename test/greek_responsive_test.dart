import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';

import 'test_support.dart';

Future<void> _pumpGreekAt(
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

  final state = comprehensiveState(reference: DateTime(2026, 8, 1)).copyWith(
    appLanguageTag: 'el',
    debtRegionCountryCode: 'GR',
    defaultCurrencyCode: 'EUR',
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

Future<void> _visitGreekTabs(WidgetTester tester) async {
  for (final icon in const [
    Icons.people_alt_outlined,
    Icons.shopping_bag_outlined,
    Icons.bar_chart_outlined,
    Icons.storefront_outlined,
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
  testWidgets('Greek 320x568 at 1.4x renders all tabs without overflow', (
    tester,
  ) async {
    await _pumpGreekAt(tester, const Size(320, 568), textScale: 1.4);
    expect(find.text('Αρχική'), findsWidgets);
    expect(find.text('Εγγραφές'), findsWidgets);
    expect(find.text('Έξοδα'), findsWidgets);
    expect(find.text('Αναφορές'), findsWidgets);
    expect(find.text('Κατάστημα'), findsWidgets);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Prezentare generală'), findsNothing);
    await _visitGreekTabs(tester);
    await _disposeApp(tester);
  });

  testWidgets('Greek 412x915 at 2.0x renders all tabs without overflow', (
    tester,
  ) async {
    await _pumpGreekAt(tester, const Size(412, 915), textScale: 2);
    await _visitGreekTabs(tester);
    await _disposeApp(tester);
  });
}
