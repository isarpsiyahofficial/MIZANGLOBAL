import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/legal/legal_documents.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_config.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_policy.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_strings.dart';
import 'package:lefferion_prime_mizan/monetization/pro_branding.dart';

void main() {
  group('MIZAN monetization contract', () {
    test('commercial constants stay locked', () {
      expect(MonetizationConfig.permanentPremiumProductId, 'premium_lifetime');
      expect(
        MonetizationConfig.networkPollInterval,
        const Duration(seconds: 10),
      );
      expect(
        MonetizationConfig.fullScreenAdCooldown,
        const Duration(seconds: 120),
      );
      expect(MonetizationConfig.behaviorActionThreshold, 3);
      expect(MonetizationConfig.rewardedViewsRequiredForDailyPremium, 3);
      expect(
        MonetizationConfig.rewardedPremiumDuration,
        const Duration(days: 1),
      );
    });

    test('PRO suppresses ads and preserves offline/PDF access', () {
      expect(
        MonetizationPolicy.mayLoadOrShowAds(premium: true, online: true),
        isFalse,
      );
      expect(
        MonetizationPolicy.canUseApp(premium: true, online: false),
        isTrue,
      );
      expect(MonetizationPolicy.canExportPdf(premium: true), isTrue);
      expect(
        MonetizationPolicy.showRewardedPremiumOffer(premium: true),
        isFalse,
      );
    });

    test('free mode remains online-only and PDF stays locked', () {
      expect(
        MonetizationPolicy.canUseApp(premium: false, online: false),
        isFalse,
      );
      expect(
        MonetizationPolicy.canUseApp(premium: false, online: true),
        isTrue,
      );
      expect(MonetizationPolicy.canExportPdf(premium: false), isFalse);
    });

    test('time advertising never opens before 120 seconds', () {
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

    test(
      'behavior advertising uses three actions but keeps global cooldown',
      () {
        expect(
          MonetizationPolicy.behaviorAdEligible(
            premium: false,
            online: true,
            sinceLastFullScreenAd: const Duration(minutes: 10),
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
      },
    );

    test(
      'only the third completed rewarded view satisfies the daily target',
      () {
        expect(
          MonetizationPolicy.rewardEarned(completedRewardedViewsToday: 2),
          isFalse,
        );
        expect(
          MonetizationPolicy.rewardEarned(completedRewardedViewsToday: 3),
          isTrue,
        );
      },
    );

    test('test and production ad IDs fail closed', () {
      expect(
        MonetizationConfig.resolveAdUnitId(
          useTestAds: true,
          productionId: '',
          testId: MonetizationConfig.androidInterstitialTestId,
        ),
        MonetizationConfig.androidInterstitialTestId,
      );
      expect(
        () => MonetizationConfig.resolveAdUnitId(
          useTestAds: false,
          productionId: '',
          testId: MonetizationConfig.androidInterstitialTestId,
        ),
        throwsStateError,
      );
      expect(
        MonetizationConfig.resolveAdUnitId(
          useTestAds: false,
          productionId: 'ca-app-pub-1234567890123456/1234567890',
          testId: MonetizationConfig.androidRewardedTestId,
        ),
        'ca-app-pub-1234567890123456/1234567890',
      );
    });

    test(
      'all 29 monetization surfaces expose native keys and PRO branding',
      () {
        expect(
          MonetizationStrings.supportedLanguageTags,
          MizanI18n.supportedLanguageTags,
        );
        expect(MonetizationStrings.supportedLanguageTags.length, 29);
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
            expect(value, isNot(key), reason: '$tag/$key raw-key fallback');
          }
          expect(ProBranding.monetizationText(tag, 'premium'), 'PRO');
          final reward = ProBranding.monetizationText(tag, 'rewardSubtitle');
          expect(
            reward.contains('3') ||
                reward.contains('٣') ||
                reward.contains('۳') ||
                reward.contains('३') ||
                reward.contains('৩') ||
                reward.contains('๓') ||
                reward.contains('３'),
            isTrue,
            reason: '$tag reward copy must present the three-ad target',
          );
        }
      },
    );

    test('legal documents use only Turkish and English full masters', () {
      for (final type in LegalDocumentType.values) {
        final document = MizanLegalDocuments.document(type, 'en');
        expect(document.localizedOverview, isEmpty, reason: '$type overview');
        expect(
          document.englishMaster.length,
          greaterThan(1500),
          reason: '$type English master',
        );
      }
    });

    test('English legal masters match the final product boundary', () {
      final privacy = MizanLegalDocuments.document(
        LegalDocumentType.privacy,
        'en',
      ).englishMaster;
      final terms = MizanLegalDocuments.document(
        LegalDocumentType.terms,
        'en',
      ).englishMaster;
      final purchase = MizanLegalDocuments.document(
        LegalDocumentType.purchase,
        'en',
      ).englishMaster;
      expect(privacy.length, greaterThan(1500));
      expect(terms.length, greaterThan(1500));
      expect(purchase.length, greaterThan(1500));
      expect(
        privacy,
        contains('does not require a publisher-operated user account'),
      );
      expect(terms, contains('Permanent Premium Purchase Terms are not part'));
      expect(purchase, contains('explicitly accepted'));
      expect(purchase, isNot(contains('rewarded')));
      expect(purchase, isNot(contains('silently')));
      expect(privacy, isNot(contains('Cloudflare')));
      expect(terms, isNot(contains('Play Integrity')));
    });

    test('shipping monetization has no publisher backend dependency', () {
      expect(Directory('backend/monetization-worker').existsSync(), isFalse);
      expect(
        File('lib/monetization/monetization_api.dart').existsSync(),
        isFalse,
      );

      final config = File(
        'lib/monetization/monetization_config.dart',
      ).readAsStringSync();
      final controller = File(
        'lib/monetization/monetization_controller.dart',
      ).readAsStringSync();
      final purchase = File(
        'lib/monetization/purchase_service.dart',
      ).readAsStringSync();
      final promo = File(
        'lib/monetization/local_promo_service.dart',
      ).readAsStringSync();
      final ads = File('lib/monetization/ad_service.dart').readAsStringSync();
      final native = File(
        'android/app/src/main/kotlin/com/lefferionprime/mizanglobal/MainActivity.kt',
      ).readAsStringSync();

      expect(config, isNot(contains('MIZAN_MONETIZATION_API')));
      expect(config, isNot(contains('MIZAN_REQUIRE_BILLING_BACKEND')));
      expect(controller, isNot(contains('MizanMonetizationApi')));
      expect(purchase, contains('queryPastPurchases'));
      expect(purchase, isNot(contains('verifyGooglePlayPurchase')));
      expect(promo, contains('Hmac(sha256'));
      expect(
        promo,
        contains(
          '40d844f4232ec3ccfec81fd04e7256d1b3fcfcc471f2439629d21a6d80eccdaa',
        ),
      );
      expect(
        promo,
        contains(
          '578af8ebcd839ce76ca6028fb78275d8afd4f4093cc7a01477130cbd1873bd26',
        ),
      );
      expect(ads, isNot(contains('ServerSideVerificationOptions')));
      expect(native, isNot(contains('play_integrity')));
      expect(native, isNot(contains('device_identity')));
    });
  });
}
