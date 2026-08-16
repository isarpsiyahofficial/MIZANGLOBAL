import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_config.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_policy.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_strings.dart';

void main() {
  group('MIZAN monetization contract', () {
    test('core commercial constants stay locked', () {
      expect(MonetizationConfig.permanentPremiumProductId, 'premium_lifetime');
      expect(MonetizationConfig.networkPollInterval, const Duration(seconds: 10));
      expect(MonetizationConfig.fullScreenAdCooldown, const Duration(seconds: 120));
      expect(MonetizationConfig.behaviorActionThreshold, 3);
      expect(MonetizationConfig.rewardedViewsRequiredForDailyPremium, 3);
      expect(MonetizationConfig.rewardedPremiumDuration, const Duration(days: 1));
    });

    test('premium always suppresses app ads even while online', () {
      expect(
        MonetizationPolicy.mayLoadOrShowAds(premium: true, online: true),
        isFalse,
      );
      expect(
        MonetizationPolicy.timeAdEligible(
          premium: true,
          online: true,
          sinceLastFullScreenAd: const Duration(days: 10),
        ),
        isFalse,
      );
      expect(
        MonetizationPolicy.behaviorAdEligible(
          premium: true,
          online: true,
          sinceLastFullScreenAd: const Duration(days: 10),
          completedMeaningfulActions: 999,
        ),
        isFalse,
      );
      expect(
        MonetizationPolicy.showRewardedPremiumOffer(premium: true),
        isFalse,
      );
    });

    test('premium works offline while free mode is blocked offline', () {
      expect(
        MonetizationPolicy.canUseApp(premium: true, online: false),
        isTrue,
      );
      expect(
        MonetizationPolicy.canUseApp(premium: false, online: false),
        isFalse,
      );
      expect(
        MonetizationPolicy.canUseApp(premium: false, online: true),
        isTrue,
      );
    });

    test('PDF export is premium-only', () {
      expect(MonetizationPolicy.canExportPdf(premium: true), isTrue);
      expect(MonetizationPolicy.canExportPdf(premium: false), isFalse);
    });

    test('full-screen time gate opens at 120 seconds, never before', () {
      expect(
        MonetizationPolicy.timeAdEligible(
          premium: false,
          online: true,
          sinceLastFullScreenAd: const Duration(seconds: 119),
        ),
        isFalse,
      );
      expect(
        MonetizationPolicy.timeAdEligible(
          premium: false,
          online: true,
          sinceLastFullScreenAd: const Duration(seconds: 120),
        ),
        isTrue,
      );
    });

    test('behavior gate requires three completed actions and global cooldown', () {
      expect(
        MonetizationPolicy.behaviorAdEligible(
          premium: false,
          online: true,
          sinceLastFullScreenAd: const Duration(seconds: 120),
          completedMeaningfulActions: 2,
        ),
        isFalse,
      );
      expect(
        MonetizationPolicy.behaviorAdEligible(
          premium: false,
          online: true,
          sinceLastFullScreenAd: const Duration(seconds: 119),
          completedMeaningfulActions: 3,
        ),
        isFalse,
      );
      expect(
        MonetizationPolicy.behaviorAdEligible(
          premium: false,
          online: true,
          sinceLastFullScreenAd: const Duration(seconds: 120),
          completedMeaningfulActions: 3,
        ),
        isTrue,
      );
    });

    test('third rewarded view earns the daily 24-hour premium grant', () {
      expect(MonetizationPolicy.rewardEarned(completedRewardedViewsToday: 2), isFalse);
      expect(MonetizationPolicy.rewardEarned(completedRewardedViewsToday: 3), isTrue);
    });

    test('premium UI covers exactly the same 29 supported language tags', () {
      expect(MonetizationStrings.supportedLanguageTags, MizanI18n.supportedLanguageTags);
      expect(MonetizationStrings.supportedLanguageTags.length, 29);
    });

    test('every locale exposes the critical premium labels without key fallback', () {
      const keys = <String>[
        'premium',
        'premiumSubtitle',
        'lifetimePremium',
        'temporaryPremium',
        'buyLifetime',
        'restoreInfo',
        'rewardTitle',
        'rewardSubtitle',
        'promoTitle',
        'promoApply',
        'benefitNoAds',
        'benefitOffline',
        'benefitPdf',
      ];
      for (final tag in MizanI18n.supportedLanguageTags) {
        for (final key in keys) {
          final value = MonetizationStrings.text(tag, key).trim();
          expect(value, isNotEmpty, reason: '$tag/$key must not be empty');
          expect(value, isNot(key), reason: '$tag/$key must not fall back to the raw key');
        }
      }
    });
  });
}
