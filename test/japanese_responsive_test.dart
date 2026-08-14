import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'test_support.dart';

Future<void> _pump(WidgetTester t, Size s, double scale) async {
  t.view.physicalSize = s;
  t.view.devicePixelRatio = 1;
  t.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  final state = comprehensiveState(reference: DateTime(2026, 8, 7)).copyWith(
    appLanguageTag: 'ja',
    debtRegionCountryCode: 'JP',
    defaultCurrencyCode: 'JPY',
  );
  final c = MizanController(MemoryStore(state), scheduler: SpyScheduler());
  await c.load();
  await t.pumpWidget(MizanApp(controller: c));
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

Future<void> _visit(WidgetTester t) async {
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
    await t.tap(find.descendant(of: root, matching: find.byIcon(icon)));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }
}

void main() {
  testWidgets('Japanese 320x568 at 1.4x has no Korean or Chinese nav leakage', (
    t,
  ) async {
    await _pump(t, const Size(320, 568), 1.4);
    for (final text in const ['ホーム', '記録', '支出', 'レポート', '設定'])
      expect(find.text(text), findsWidgets);
    for (final leak in const [
      '홈',
      '기록',
      '보고서',
      '설정',
      '首页',
      '记录',
      '报告',
      '设置',
      'Home',
    ]) expect(find.text(leak), findsNothing, reason: leak);
    expect(
      Directionality.of(t.element(find.text('ホーム').first)),
      TextDirection.ltr,
    );
    await _visit(t);
  });
  testWidgets('Japanese 412x915 at 2.0x remains usable without overflow', (
    t,
  ) async {
    await _pump(t, const Size(412, 915), 2);
    expect(
      Directionality.of(t.element(find.text('ホーム').first)),
      TextDirection.ltr,
    );
    await _visit(t);
  });
}
