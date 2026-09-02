import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:lefferion_prime_mizan/legal/legal_consent_strings.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_config.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_controller.dart';
import 'package:lefferion_prime_mizan/monetization/network_gate_service.dart';
import 'package:lefferion_prime_mizan/monetization/premium_entitlement_store.dart';
import 'package:lefferion_prime_mizan/monetization/purchase_service.dart';
import 'package:lefferion_prime_mizan/screens/premium_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _OnlineNetworkGate extends NetworkGateService {
  @override
  bool get isOnline => true;

  @override
  Future<void> start() async {}

  @override
  Future<bool> checkNow() async => true;
}

class _AvailablePurchasePlatform extends InAppPurchasePlatform {
  final StreamController<List<PurchaseDetails>> _updates =
      StreamController<List<PurchaseDetails>>.broadcast(sync: true);

  int buyCalls = 0;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _updates.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async => ProductDetailsResponse(
    productDetails: <ProductDetails>[
      ProductDetails(
        id: MonetizationConfig.permanentPremiumProductId,
        title: 'Permanent PRO',
        description: 'Contract activation test product',
        price: r'$9.99',
        rawPrice: 9.99,
        currencyCode: 'USD',
      ),
    ],
    notFoundIDs: const <String>[],
  );

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyCalls++;
    return true;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}

  Future<void> close() => _updates.close();
}

FilledButton _purchaseButton(WidgetTester tester) =>
    tester.widget<FilledButton>(
      find.byKey(const ValueKey('premium-lifetime-purchase')),
    );

FilledButton _filledButton(WidgetTester tester, String label) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, label));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'reading and accepting the purchase contract enables the live PRO purchase',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(const <String, Object>{});
      MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');

      final platform = _AvailablePurchasePlatform();
      final previousPlatformOverride = debugDefaultTargetPlatformOverride;
      late final InAppPurchase purchaseApi;
      try {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        purchaseApi = InAppPurchase.instance;
      } finally {
        debugDefaultTargetPlatformOverride = previousPlatformOverride;
      }
      InAppPurchasePlatform.instance = platform;

      final store = PremiumEntitlementStore();
      final purchaseService = MizanPurchaseService(
        inAppPurchase: purchaseApi,
        entitlementStore: store,
      );
      final controller = MonetizationController(
        entitlementStore: store,
        networkGate: _OnlineNetworkGate(),
        purchaseService: purchaseService,
      );
      await controller.initialize(legalAccessGranted: true);
      await purchaseService.initialize();

      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: PremiumScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(purchaseService.product, isNotNull);
      expect(_purchaseButton(tester).onPressed, isNull);
      expect(platform.buyCalls, 0);

      final review = find.byKey(
        const ValueKey('premium-read-purchase-contract'),
      );
      await tester.ensureVisible(review);
      await tester.tap(review);
      await tester.pumpAndSettle();

      final purchaseLabel = LegalConsentStrings.text('en', 'purchase');
      await tester.tap(find.text(purchaseLabel));
      await tester.pumpAndSettle();

      final readDoneLabel = LegalConsentStrings.text('en', 'readDone');
      expect(_filledButton(tester, readDoneLabel).onPressed, isNull);
      final scrollable = find.byType(Scrollable).first;
      final scrollState = tester.state<ScrollableState>(scrollable);
      expect(scrollState.position.maxScrollExtent, greaterThan(0));
      scrollState.position.jumpTo(scrollState.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(_filledButton(tester, readDoneLabel).onPressed, isNotNull);
      await tester.tap(find.widgetWithText(FilledButton, readDoneLabel));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('purchase-terms-confirmation')),
      );
      await tester.pumpAndSettle();
      final continueLabel = LegalConsentStrings.text('en', 'continue');
      expect(_filledButton(tester, continueLabel).onPressed, isNotNull);
      await tester.tap(find.byKey(const ValueKey('purchase-bundle-accept')));
      await tester.pumpAndSettle();

      expect(_purchaseButton(tester).onPressed, isNotNull);
      final purchase = find.byKey(const ValueKey('premium-lifetime-purchase'));
      await tester.ensureVisible(purchase);
      await tester.tap(purchase);
      await tester.pump();
      expect(platform.buyCalls, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await purchaseService.disposeService();
      controller.dispose();
      await platform.close();
    },
  );
}
