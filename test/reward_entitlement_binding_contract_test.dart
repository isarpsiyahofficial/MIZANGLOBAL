import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'rewarded PRO progress is local and requires three provider callbacks',
    () {
      final controller = File(
        'lib/monetization/monetization_controller.dart',
      ).readAsStringSync();
      final store = File(
        'lib/monetization/premium_entitlement_store.dart',
      ).readAsStringSync();
      final config = File(
        'lib/monetization/monetization_config.dart',
      ).readAsStringSync();
      final ads = File('lib/monetization/ad_service.dart').readAsStringSync();

      final start = controller.indexOf(
        'Future<bool> watchRewardedForDailyPremium()',
      );
      final end = controller.indexOf(
        'Future<PromoRedemptionResult> redeemPromo',
        start,
      );
      expect(start, greaterThanOrEqualTo(0));
      expect(end, greaterThan(start));

      final rewardFlow = controller.substring(start, end);
      expect(rewardFlow, contains('_adService.showRewarded()'));
      expect(rewardFlow, contains('recordRewardedView()'));
      expect(rewardFlow, contains('grantTemporaryDuration'));
      expect(rewardFlow, isNot(contains('rewardSessionStatus')));
      expect(rewardFlow, isNot(contains('_syncTemporaryEntitlement')));
      expect(config, contains('rewardedViewsRequiredForDailyPremium = 3'));
      expect(store, contains('rewardedViewsRequiredForDailyPremium'));
      expect(ads, contains('onUserEarnedReward'));
      expect(ads, isNot(contains('ServerSideVerificationOptions')));
    },
  );
}
