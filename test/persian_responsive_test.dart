import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';

import 'test_support.dart';

Future<void> _pumpPersianAt(
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
    appLanguageTag: 'fa',
    debtRegionCountryCode: 'IR',
    defaultCurrencyCode: 'IRR',
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

Future<void> _visitPersianTabs(WidgetTester tester) async {
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
  testWidgets('Persian 320x568 at 1.4x is RTL and all tabs avoid overflow', (
    tester,
  ) async {
    await _pumpPersianAt(tester, const Size(320, 568), textScale: 1.4);

    expect(find.text('صفحه اصلی'), findsWidgets);
    expect(find.text('رکوردها'), findsWidgets);
    expect(find.text('هزینه‌ها'), findsWidgets);
    expect(find.text('گزارش‌ها'), findsWidgets);
    expect(find.text('PRO'), findsWidgets);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(find.text('الصفحة الرئيسية'), findsNothing);
    expect(find.text('Главная'), findsNothing);

    final persianLabel = find.text('صفحه اصلی').first;
    expect(Directionality.of(tester.element(persianLabel)), TextDirection.rtl);

    await _visitPersianTabs(tester);
    await _disposeApp(tester);
  });

  testWidgets('Persian 412x915 at 2.0x remains RTL without overflow', (
    tester,
  ) async {
    await _pumpPersianAt(tester, const Size(412, 915), textScale: 2);
    expect(
      Directionality.of(tester.element(find.text('صفحه اصلی').first)),
      TextDirection.rtl,
    );
    await _visitPersianTabs(tester);
    await _disposeApp(tester);
  });
}
