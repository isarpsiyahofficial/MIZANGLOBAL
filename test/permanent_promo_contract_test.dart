import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/monetization/local_promo_service.dart';
import 'package:lefferion_prime_mizan/monetization/premium_entitlement_store.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(const <String, Object>{});
  });

  test(
    'IBRAHIM grants permanent PRO once without exposing it in shipping code',
    () async {
      var temporaryGrantCount = 0;
      var permanentGrantCount = 0;
      final service = MizanPromoCodeService(
        grant: (_) async => temporaryGrantCount++,
        grantPermanent: () async => permanentGrantCount++,
      );

      final first = await service.redeem(' ibrahim ');
      expect(first.accepted, isTrue);
      expect(first.permanent, isTrue);
      expect(first.premiumDuration, isNull);
      expect(permanentGrantCount, 1);
      expect(temporaryGrantCount, 0);
      final shippingSource = <String>[
        File('lib/monetization/local_promo_service.dart').readAsStringSync(),
        File(
          'lib/monetization/monetization_controller.dart',
        ).readAsStringSync(),
      ].join('\n');
      expect(shippingSource, isNot(contains('IBRAHIM')));

      final second = await service.redeem('IBRAHIM');
      expect(second.accepted, isFalse);
      expect(second.messageCode, 'already_used');
      expect(permanentGrantCount, 1);
    },
  );

  test(
    'local permanent promotion survives reload with a distinct source',
    () async {
      final store = PremiumEntitlementStore();
      await store.setPermanentPremium(
        purchaseFingerprint:
            '3d59b034f14c6ec84a0448ed0546d3a93dffe02c7e09e9c3431b062e23549f5c',
        source: PermanentPremiumSource.localPromotion,
      );

      final snapshot = await store.load();
      expect(snapshot.permanent, isTrue);
      expect(snapshot.permanentSource, PermanentPremiumSource.localPromotion);
    },
  );
}
