import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lefferion_prime_mizan/monetization/premium_entitlement_store.dart';
import 'package:lefferion_prime_mizan/monetization/purchase_service.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PremiumEntitlementStore freshStore() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(const <String, Object>{});
    return PremiumEntitlementStore();
  }

  InAppPurchase testPurchaseApi() {
    final previousPlatformOverride = debugDefaultTargetPlatformOverride;
    try {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      return InAppPurchase.instance;
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatformOverride;
    }
  }

  test('temporary PRO blocks purchase inside the purchase service', () async {
    final store = freshStore();
    await store.grantTemporaryDuration(const Duration(days: 1));
    final service = MizanPurchaseService(
      inAppPurchase: testPurchaseApi(),
      entitlementStore: store,
    );

    expect(await service.buyPermanentPremium(), isFalse);
    expect(service.lastError, 'premium_already_active');
    service.dispose();
  });

  test(
    'permanent PRO blocks repeat purchase inside the purchase service',
    () async {
      final store = freshStore();
      await store.setPermanentPremium(
        purchaseFingerprint:
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      );
      final service = MizanPurchaseService(
        inAppPurchase: testPurchaseApi(),
        entitlementStore: store,
      );

      expect(await service.buyPermanentPremium(), isFalse);
      expect(service.lastError, 'premium_already_active');
      service.dispose();
    },
  );
}
