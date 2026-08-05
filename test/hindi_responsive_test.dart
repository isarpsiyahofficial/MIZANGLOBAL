import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';

import 'test_support.dart';

Future<void> _pumpHindiAt(
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

  final state = comprehensiveState(reference: DateTime(2026, 8, 5)).copyWith(
    appLanguageTag: 'hi',
    debtRegionCountryCode: 'IN',
    defaultCurrencyCode: 'INR',
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

Future<void> _visitHindiTabs(WidgetTester tester) async {
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
  testWidgets('Hindi 320x568 at 1.4x is LTR and all tabs avoid overflow', (
    tester,
  ) async {
    await _pumpHindiAt(tester, const Size(320, 568), textScale: 1.4);

    expect(find.text('मुख्य पृष्ठ'), findsWidgets);
    expect(find.text('रिकॉर्ड'), findsWidgets);
    expect(find.text('खर्च'), findsWidgets);
    expect(find.text('रिपोर्ट'), findsWidgets);
    expect(find.text('सेटिंग्स'), findsWidgets);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(find.text('דף הבית'), findsNothing);
    expect(find.text('الصفحة الرئيسية'), findsNothing);
    expect(find.text('Главная'), findsNothing);

    final label = find.text('मुख्य पृष्ठ').first;
    expect(Directionality.of(tester.element(label)), TextDirection.ltr);

    await _visitHindiTabs(tester);
    await _disposeApp(tester);
  });

  testWidgets('Hindi 412x915 at 2.0x remains LTR without overflow', (
    tester,
  ) async {
    await _pumpHindiAt(tester, const Size(412, 915), textScale: 2);
    expect(
      Directionality.of(tester.element(find.text('मुख्य पृष्ठ').first)),
      TextDirection.ltr,
    );
    await _visitHindiTabs(tester);
    await _disposeApp(tester);
  });
}
