import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/mizan_clock.dart';
import 'package:lefferion_prime_mizan/core/theme.dart';
import 'package:lefferion_prime_mizan/legal/legal_acceptance_store.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_support.dart';

const _screenshotFontFamily = 'MizanScreenshotFont';
final _visualNow = DateTime(2026, 8, 1, 10);

Future<void> _loadFont(String family, List<String> candidates) async {
  final path = candidates.firstWhere(
    (candidate) => candidate.isNotEmpty && File(candidate).existsSync(),
    orElse: () => throw StateError('$family fontu test ortamında bulunamadı.'),
  );
  final loader = FontLoader(family);
  loader.addFont(
    File(path).readAsBytes().then(
      (bytes) => ByteData.view(Uint8List.fromList(bytes).buffer),
    ),
  );
  await loader.load();
}

Future<void> _loadScreenshotFonts() async {
  await _loadFont(_screenshotFontFamily, const [
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    '/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf',
    '/usr/share/fonts/truetype/freefont/FreeSans.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '';
  await _loadFont('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '/opt/hostedtoolcache/flutter/stable-x64/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

Future<void> _pumpApp(
  WidgetTester tester,
  MizanState state, {
  Size size = const Size(412, 915),
}) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  await LegalAcceptanceStore.acceptCurrentLegalBundle();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final controller = MizanController(
    MemoryStore(state),
    scheduler: SpyScheduler(),
  );
  await controller.load();
  final baseTheme = MizanTheme.light();
  await tester.pumpWidget(
    MaterialApp(
      title: 'LEFFERION PRIME - MİZAN',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: _screenshotFontFamily),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(
          fontFamily: _screenshotFontFamily,
        ),
      ),
      home: MizanHome(controller: controller),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _tapNavigation(WidgetTester tester, IconData icon) async {
  final navigationBar = find.byType(NavigationBar);
  final navigationRail = find.byType(NavigationRail);
  final root = navigationBar.evaluate().isNotEmpty
      ? navigationBar
      : navigationRail;
  final target = find.descendant(of: root, matching: find.byIcon(icon));
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _scrollToTextAndTap(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.scrollUntilVisible(
    target,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _capture(
  WidgetTester tester,
  String filename, {
  Finder? target,
}) async {
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await expectLater(
    target ?? find.byType(Scaffold).first,
    matchesGoldenFile('goldens/$filename.png'),
  );
}

void main() {
  setUpAll(() async {
    WidgetController.hitTestWarningShouldBeFatal = true;
    await _loadScreenshotFonts();
  });
  setUp(() => MizanClock.setNowForTesting(_visualNow));
  tearDown(MizanClock.resetForTesting);

  testWidgets('ilk kurulum boş ana sayfa', (tester) async {
    await _pumpApp(tester, MizanState.empty());
    await _capture(tester, '01-first-install-empty-dashboard');
  });

  testWidgets('ilk kurulum boş kayıtlar ekranı', (tester) async {
    await _pumpApp(tester, MizanState.empty());
    await _tapNavigation(tester, Icons.people_alt_outlined);
    await _capture(tester, '02-first-install-empty-records');
  });

  testWidgets('dolu ana sayfa ve toplamlar', (tester) async {
    await _pumpApp(tester, comprehensiveState(reference: _visualNow));
    await _capture(tester, '03-dashboard-populated');
  });

  testWidgets('kalan toplam borç detayı', (tester) async {
    await _pumpApp(tester, comprehensiveState(reference: _visualNow));
    await tester.tap(find.text('Kalan toplam borç'));
    await tester.pumpAndSettle();
    await _capture(
      tester,
      '04-total-debt-breakdown',
      target: find.byType(Overlay).first,
    );
  });

  testWidgets('beş bölümlü kayıtlar ekranı', (tester) async {
    await _pumpApp(tester, comprehensiveState(reference: _visualNow));
    await _tapNavigation(tester, Icons.people_alt_outlined);
    await _capture(tester, '05-records-groups');
  });

  testWidgets('kişi detayları ve ilişkili kayıtlar', (tester) async {
    await _pumpApp(tester, comprehensiveState(reference: _visualNow));
    await _tapNavigation(tester, Icons.people_alt_outlined);
    await _scrollToTextAndTap(tester, 'Kişi detaylarını aç');
    await _capture(
      tester,
      '06-person-details',
      target: find.byType(Overlay).first,
    );
  });

  testWidgets('kritik ödeme detay ekranı', (tester) async {
    await _pumpApp(tester, comprehensiveState(reference: _visualNow));
    await _scrollToTextAndTap(tester, 'Kart borcu');
    await _capture(
      tester,
      '06-critical-payment-detail',
      target: find.byType(Overlay).first,
    );
  });

  testWidgets('kişisel kurumsal borç detayı', (tester) async {
    await _pumpApp(tester, comprehensiveState(reference: _visualNow));
    await _tapNavigation(tester, Icons.people_alt_outlined);
    await _scrollToTextAndTap(tester, 'Kişisel ve Kurumsal Borçlar');
    await _scrollToTextAndTap(tester, 'Senet ödemesi');
    await _capture(
      tester,
      '07-personal-corporate-debt-detail',
      target: find.byType(Overlay).first,
    );
  });

  testWidgets('giderler ekranı', (tester) async {
    await _pumpApp(tester, comprehensiveState(reference: _visualNow));
    await _tapNavigation(tester, Icons.shopping_bag_outlined);
    await _capture(tester, '08-expenses-simple');
  });

  testWidgets('raporlar ekranı', (tester) async {
    await _pumpApp(tester, comprehensiveState(reference: _visualNow));
    await _tapNavigation(tester, Icons.bar_chart_outlined);
    await _capture(tester, '09-reports-simple');
  });

  testWidgets('ayarlar ekranı', (tester) async {
    await _pumpApp(tester, MizanState.empty());
    await _tapNavigation(tester, Icons.settings_outlined);
    await _capture(tester, '10-settings-safe');
  });

  testWidgets('tablet ana sayfa', (tester) async {
    await _pumpApp(
      tester,
      comprehensiveState(reference: _visualNow),
      size: const Size(1180, 820),
    );
    await _capture(tester, '11-dashboard-tablet');
  });

  testWidgets('ödeme türü seçimi', (tester) async {
    await _pumpApp(
      tester,
      comprehensiveState(reference: _visualNow),
      size: const Size(500, 1200),
    );
    await _scrollToTextAndTap(tester, 'Kart borcu');
    final addPayment = find.text('Ödeme ekle');
    await tester.scrollUntilVisible(
      addPayment,
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(addPayment);
    await tester.pumpAndSettle();
    await _capture(
      tester,
      '12-payment-type-dialog',
      target: find.byType(Overlay).first,
    );
  });
}
