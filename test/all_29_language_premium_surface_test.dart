import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_controller.dart';
import 'package:lefferion_prime_mizan/monetization/network_gate_service.dart';
import 'package:lefferion_prime_mizan/monetization/premium_entitlement_store.dart';
import 'package:lefferion_prime_mizan/monetization/pro_branding.dart';
import 'package:lefferion_prime_mizan/screens/premium_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const _tags = <String>[
  'tr',
  'en',
  'es',
  'pt-BR',
  'pt-PT',
  'fr',
  'de',
  'it',
  'nl',
  'pl',
  'ro',
  'el',
  'ru',
  'uk',
  'ar',
  'fa',
  'he',
  'hi',
  'bn',
  'ur',
  'id',
  'ms',
  'fil',
  'vi',
  'th',
  'sw',
  'zh',
  'ja',
  'ko',
];

const _requestedTag = String.fromEnvironment(
  'MIZAN_TEST_LOCALE',
  defaultValue: 'tr',
);

class _OfflineNetworkGate extends NetworkGateService {
  @override
  bool get isOnline => false;

  @override
  Future<void> start() async {}

  @override
  Future<bool> checkNow() async => false;
}

Future<MonetizationController> _controller() async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(const <String, Object>{});
  final controller = MonetizationController(
    entitlementStore: PremiumEntitlementStore(),
    networkGate: _OfflineNetworkGate(),
  );
  await controller.initialize();
  return controller;
}

Future<void> _disposeController(
  WidgetTester tester,
  MonetizationController controller,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  controller.dispose();
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tag = _requestedTag;
  if (!_tags.contains(tag)) {
    throw StateError('Unsupported MIZAN_TEST_LOCALE=$tag');
  }

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  testWidgets(
    '$tag: lifetime-only PRO surface is localized, responsive and fails closed without live Play product',
    (tester) async {
      final controller = await _controller();
      MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: PremiumScreen(controller: controller)),
      );
      await tester.pump();

      String t(String key) => ProBranding.monetizationText(tag, key);

      expect(find.byKey(const ValueKey('premium-status-free')), findsOneWidget);
      expect(find.text(t('lifetimePremium')), findsWidgets);
      expect(find.text(t('buyLifetime')), findsOneWidget);
      expect(find.text(t('purchaseUnavailable')), findsOneWidget);
      expect(find.text(t('playPrice')), findsOneWidget);
      expect(find.text(t('restoreInfo')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('premium-reward-offer')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('premium-promo-offer')), findsOneWidget);

      final purchaseButton = tester.widget<FilledButton>(
        find.byKey(const ValueKey('premium-lifetime-purchase')),
      );
      expect(purchaseButton.onPressed, isNull);
      expect(controller.purchaseService.product, isNull);

      await _disposeController(tester, controller);
    },
  );
}
