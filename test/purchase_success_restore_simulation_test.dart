import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:lefferion_prime_mizan/monetization/ad_service.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_config.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_controller.dart';
import 'package:lefferion_prime_mizan/monetization/network_gate_service.dart';
import 'package:lefferion_prime_mizan/monetization/premium_entitlement_store.dart';
import 'package:lefferion_prime_mizan/monetization/purchase_service.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _OnlineNetworkGate extends NetworkGateService {
  bool online = false;

  @override
  bool get isOnline => online;

  @override
  Future<void> start() async {}

  @override
  Future<bool> checkNow() async => online;

  void setOnline(bool value) {
    if (online == value) return;
    online = value;
    notifyListeners();
  }
}

class _RecordingAdService extends MizanAdService {
  bool premiumSuppressed = false;

  @override
  Future<void> initializeForFreeUser() async {}

  @override
  Future<void> setPremiumSuppressed(bool value) async {
    premiumSuppressed = value;
    notifyListeners();
  }
}

class _SimulatedPurchasePlatform extends InAppPurchasePlatform {
  _SimulatedPurchasePlatform({this.purchaseAfterBuy, this.purchaseOnRestore});

  final StreamController<List<PurchaseDetails>> _updates =
      StreamController<List<PurchaseDetails>>.broadcast();
  final PurchaseDetails? purchaseAfterBuy;
  final PurchaseDetails? purchaseOnRestore;
  bool restoreDeliveryEnabled = false;
  int buyCalls = 0;
  int restoreCalls = 0;
  final List<PurchaseDetails> completed = <PurchaseDetails>[];

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
        description: 'Simulation product',
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
    final purchase = purchaseAfterBuy;
    if (purchase != null) {
      scheduleMicrotask(() => _updates.add(<PurchaseDetails>[purchase]));
    }
    return true;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restoreCalls++;
    final purchase = purchaseOnRestore;
    if (restoreDeliveryEnabled && purchase != null) {
      scheduleMicrotask(() => _updates.add(<PurchaseDetails>[purchase]));
    }
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completed.add(purchase);
  }

  Future<void> close() => _updates.close();
}

PurchaseDetails _purchase(PurchaseStatus status, String token) {
  final purchase = PurchaseDetails(
    purchaseID: 'test-$token',
    productID: MonetizationConfig.permanentPremiumProductId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local-$token',
      serverVerificationData: token,
      source: 'simulated_store',
    ),
    transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
    status: status,
  );
  purchase.pendingCompletePurchase = true;
  return purchase;
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 200; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('Timed out while waiting for the simulated purchase update.');
}

Future<
  (
    MonetizationController,
    MizanPurchaseService,
    PremiumEntitlementStore,
    _OnlineNetworkGate,
    _RecordingAdService,
  )
>
_controllerFor(_SimulatedPurchasePlatform platform) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(const <String, Object>{});
  final store = PremiumEntitlementStore();
  final previousPlatformOverride = debugDefaultTargetPlatformOverride;
  late final InAppPurchase purchaseApi;
  try {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    purchaseApi = InAppPurchase.instance;
  } finally {
    debugDefaultTargetPlatformOverride = previousPlatformOverride;
  }
  InAppPurchasePlatform.instance = platform;
  final purchaseService = MizanPurchaseService(
    inAppPurchase: purchaseApi,
    entitlementStore: store,
  );
  final network = _OnlineNetworkGate();
  final ads = _RecordingAdService();
  final controller = MonetizationController(
    entitlementStore: store,
    networkGate: network,
    adService: ads,
    purchaseService: purchaseService,
  );
  await controller.initialize(legalAccessGranted: true);
  await Future<void>.delayed(Duration.zero);
  await purchaseService.initialize();
  await purchaseService.synchronizeOwnedPurchases();
  network.online = true;
  return (controller, purchaseService, store, network, ads);
}

void _expectPermanentBenefits(
  MonetizationController controller,
  _OnlineNetworkGate network,
  _RecordingAdService ads,
) {
  expect(controller.isPermanentPremium, isTrue);
  expect(controller.isPremium, isTrue);
  expect(controller.permanentPurchaseFingerprint, hasLength(64));
  expect(controller.canExportPdf, isTrue);
  expect(controller.canAttemptPermanentPurchase, isFalse);
  expect(controller.shouldShowRewardedPremium, isFalse);
  expect(ads.premiumSuppressed, isTrue);

  network.setOnline(false);
  expect(controller.canUseApp, isTrue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'completed Google Play purchase grants every Permanent PRO gate',
    () async {
      final platform = _SimulatedPurchasePlatform(
        purchaseAfterBuy: _purchase(
          PurchaseStatus.purchased,
          'purchase-token-with-valid-server-proof',
        ),
      );
      final (controller, purchaseService, store, network, ads) =
          await _controllerFor(platform);

      expect(await controller.buyPermanentPremium(), isTrue);
      await _waitUntil(() => controller.isPermanentPremium);

      final snapshot = await store.load();
      expect(platform.buyCalls, 1);
      expect(platform.completed, hasLength(1));
      expect(snapshot.permanent, isTrue);
      expect(snapshot.permanentSource, PermanentPremiumSource.googlePlay);
      expect(snapshot.temporaryUntilUtc, isNull);
      expect(snapshot.permanentPurchaseFingerprint, hasLength(64));
      _expectPermanentBenefits(controller, network, ads);

      await purchaseService.disposeService();
      controller.dispose();
      await platform.close();
    },
  );

  test(
    'automatic restored purchase is accepted and grants Permanent PRO',
    () async {
      final platform = _SimulatedPurchasePlatform(
        purchaseOnRestore: _purchase(
          PurchaseStatus.restored,
          'restored-token-with-valid-server-proof',
        ),
      );
      final (controller, purchaseService, store, network, ads) =
          await _controllerFor(platform);

      platform.restoreDeliveryEnabled = true;
      await purchaseService.synchronizeOwnedPurchases();
      await _waitUntil(() => controller.isPermanentPremium);

      final snapshot = await store.load();
      expect(platform.restoreCalls, greaterThanOrEqualTo(1));
      expect(platform.completed, hasLength(1));
      expect(snapshot.permanent, isTrue);
      expect(snapshot.permanentSource, PermanentPremiumSource.googlePlay);
      expect(snapshot.permanentPurchaseFingerprint, hasLength(64));
      _expectPermanentBenefits(controller, network, ads);

      await purchaseService.disposeService();
      controller.dispose();
      await platform.close();
    },
  );
}
