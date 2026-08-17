import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'rewarded PRO grant is rebound to the verified device before local apply',
    () {
      final source = File(
        'lib/monetization/monetization_controller.dart',
      ).readAsStringSync();

      final start = source.indexOf(
        'Future<bool> watchRewardedForDailyPremium()',
      );
      final end = source.indexOf(
        'Future<PromoRedemptionResult> redeemPromo',
        start,
      );
      expect(start, greaterThanOrEqualTo(0));
      expect(end, greaterThan(start));

      final rewardFlow = source.substring(start, end);
      expect(rewardFlow, contains('rewardSessionStatus(sessionId)'));
      expect(rewardFlow, contains('status.sessionRewarded'));
      expect(rewardFlow, contains('_syncTemporaryEntitlement()'));
      expect(
        rewardFlow,
        isNot(contains('_applyRewardServerState(status)')),
        reason:
            'Session-status payload must never directly grant local PRO; the final '
            'grant must come from the device-bound entitlement sync.',
      );
    },
  );
}
