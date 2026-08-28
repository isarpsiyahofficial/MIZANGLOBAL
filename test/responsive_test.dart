import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/main.dart';

import 'test_support.dart';

Future<void> _pumpAt(
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
  final controller = MizanController(
    MemoryStore(comprehensiveState(reference: DateTime.now())),
    scheduler: SpyScheduler(),
  );
  await controller.load();
  await tester.pumpWidget(MizanApp(controller: controller));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _visitTabs(WidgetTester tester) async {
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

void main() {
  for (final size in const [
    Size(320, 568),
    Size(360, 800),
    Size(412, 915),
    Size(500, 1200),
    Size(1180, 820),
  ]) {
    testWidgets(
      '${size.width.toInt()}x${size.height.toInt()} tüm sekmeler taşmasız',
      (tester) async {
        await _pumpAt(tester, size);
        await _visitTabs(tester);
      },
    );
  }

  testWidgets('412x915 yüzde 200 yazı boyutunda ana ekranlar taşmasız', (
    tester,
  ) async {
    await _pumpAt(tester, const Size(412, 915), textScale: 2);
    await _visitTabs(tester);
  });
  testWidgets('320x568 bildirimsiz ayarlar taşmasız açılır', (tester) async {
    await _pumpAt(tester, const Size(320, 568));
    final bar = find.byType(NavigationBar);
    final rail = find.byType(NavigationRail);
    final root = bar.evaluate().isNotEmpty ? bar : rail;
    await tester.tap(
      find.descendant(
        of: root,
        matching: find.byIcon(Icons.storefront_outlined),
      ),
    );
    await tester.pumpAndSettle();
    final settingsAction = find.byKey(const ValueKey('pro-open-settings'));
    if (settingsAction.evaluate().isNotEmpty) {
      await tester.tap(settingsAction);
      await tester.pumpAndSettle();
    }

    expect(find.text('Bildirim sistemi'), findsNothing);
    expect(find.text('Ödeme hatırlatması 1'), findsNothing);
    expect(find.text('Hatırlatmayı düzenle'), findsNothing);
    expect(find.text('Anlık yerel kayıt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
