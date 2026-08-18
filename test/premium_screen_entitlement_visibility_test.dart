import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_controller.dart';
import 'package:lefferion_prime_mizan/monetization/network_gate_service.dart';
import 'package:lefferion_prime_mizan/monetization/premium_entitlement_store.dart';
import 'package:lefferion_prime_mizan/screens/premium_screen.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _OfflineNetworkGate extends NetworkGateService {
  @override
  bool get isOnline => false;

  @override
  Future<void> start() async {}

  @override
  Future<bool> checkNow() async => false;
}

Future<MonetizationController> _controller({
  bool temporary = false,
  bool permanent = false,
}) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(const <String, Object>{});
  final store = PremiumEntitlementStore();
  if (temporary) {
    await store.grantTemporaryDuration(const Duration(days: 1));
  }
  if (permanent) {
    await store.setPermanentPremium(
      purchaseFingerprint:
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );
  }
  final controller = MonetizationController(
    entitlementStore: store,
    networkGate: _OfflineNetworkGate(),
  );
  await controller.initialize();
  return controller;
}

Future<void> _pump(
  WidgetTester tester,
  MonetizationController controller,
) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(controller.dispose);
  MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');
  await tester.pumpWidget(
    MaterialApp(home: PremiumScreen(controller: controller)),
  );
  await tester.pump();
}

void main() {
  testWidgets('free PRO screen exposes free-only upgrade surfaces', (
    tester,
  ) async {
    final controller = await _controller();
    await _pump(tester, controller);

    expect(find.byKey(const ValueKey('premium-status-free')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-active-benefits')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-lifetime-benefits')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-lifetime-purchase')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-reward-offer')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-promo-offer')), findsOneWidget);
  });

  testWidgets('temporary PRO keeps lifetime upgrade and hides reward offer', (
    tester,
  ) async {
    final controller = await _controller(temporary: true);
    await _pump(tester, controller);

    expect(
      find.byKey(const ValueKey('premium-status-temporary')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('premium-active-benefits')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-lifetime-benefits')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-lifetime-purchase')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-reward-offer')), findsNothing);
    expect(find.byKey(const ValueKey('premium-promo-offer')), findsOneWidget);
  });

  testWidgets('permanent PRO hides all upgrade acquisition surfaces', (
    tester,
  ) async {
    final controller = await _controller(permanent: true);
    await _pump(tester, controller);

    expect(
      find.byKey(const ValueKey('premium-status-permanent')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('premium-active-benefits')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-lifetime-benefits')), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-lifetime-purchase')), findsNothing);
    expect(find.byKey(const ValueKey('premium-reward-offer')), findsNothing);
    expect(find.byKey(const ValueKey('premium-promo-offer')), findsNothing);
  });
}
