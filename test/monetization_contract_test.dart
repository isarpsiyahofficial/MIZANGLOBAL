import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/legal/legal_documents.dart';
import 'package:lefferion_prime_mizan/legal/legal_locale_summaries.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_config.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_policy.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_strings.dart';
import 'package:lefferion_prime_mizan/monetization/pro_branding.dart';

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

    test('PRO always suppresses app ads even while online', () {
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

    test('PRO works offline while free mode is blocked offline', () {
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

    test('PDF export is PRO-only', () {
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

    test('behavior trigger cannot be bypassed by time eligibility', () {
      expect(
        MonetizationPolicy.adBreakEligible(
          trigger: AdBreakTrigger.behavior,
          premium: false,
          online: true,
          sinceLastFullScreenAd: const Duration(minutes: 30),
          completedMeaningfulActions: 2,
        ),
        isFalse,
      );
      expect(
        MonetizationPolicy.adBreakEligible(
          trigger: AdBreakTrigger.time,
          premium: false,
          online: true,
          sinceLastFullScreenAd: const Duration(minutes: 30),
          completedMeaningfulActions: 0,
        ),
        isTrue,
      );
      expect(
        MonetizationPolicy.adBreakEligible(
          trigger: AdBreakTrigger.behavior,
          premium: false,
          online: true,
          sinceLastFullScreenAd: const Duration(seconds: 120),
          completedMeaningfulActions: 3,
        ),
        isTrue,
      );
    });

    test('behavior gate still requires global cooldown', () {
      expect(
        MonetizationPolicy.behaviorAdEligible(
          premium: false,
          online: true,
          sinceLastFullScreenAd: const Duration(seconds: 119),
          completedMeaningfulActions: 3,
        ),
        isFalse,
      );
    });

    test('third verified rewarded view earns the daily 24-hour PRO grant', () {
      expect(
        MonetizationPolicy.rewardEarned(completedRewardedViewsToday: 2),
        isFalse,
      );
      expect(
        MonetizationPolicy.rewardEarned(completedRewardedViewsToday: 3),
        isTrue,
      );
    });

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
        () => MonetizationConfig.resolveAdUnitId(
          useTestAds: false,
          productionId: MonetizationConfig.androidRewardedTestId,
          testId: MonetizationConfig.androidRewardedTestId,
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

    test('monetization localization covers exactly 29 supported language tags', () {
      expect(
        MonetizationStrings.supportedLanguageTags,
        MizanI18n.supportedLanguageTags,
      );
      expect(MonetizationStrings.supportedLanguageTags.length, 29);
    });

    test('every locale exposes critical monetization labels without key fallback', () {
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
          expect(
            value,
            isNot(key),
            reason: '$tag/$key must not fall back to the raw key',
          );
        }
      }
    });

    test('all 29 monetization surfaces brand the entitlement as PRO', () {
      for (final tag in MizanI18n.supportedLanguageTags) {
        expect(
          ProBranding.monetizationText(tag, 'premium'),
          'PRO',
          reason: '$tag must present the commercial tier as PRO',
        );
        final visibleSubtitle =
            ProBranding.monetizationText(tag, 'premiumSubtitle');
        final localizedPremium = MonetizationStrings.text(tag, 'premium');
        if (localizedPremium != 'PRO') {
          expect(
            visibleSubtitle,
            isNot(contains(localizedPremium)),
            reason: '$tag must not leak the prior commercial label',
          );
        }
      }
    });

    test('terms and purchase explanations cover all 29 locales', () {
      expect(
        LegalLocaleSummaries.supportedLanguageTags,
        MizanI18n.supportedLanguageTags,
      );
      expect(LegalLocaleSummaries.supportedLanguageTags.length, 29);
      final englishTerms = LegalLocaleSummaries.overview(
        LegalDocumentType.terms,
        'en',
      );
      final englishPurchase = LegalLocaleSummaries.overview(
        LegalDocumentType.purchase,
        'en',
      );
      for (final tag in MizanI18n.supportedLanguageTags) {
        final terms = LegalLocaleSummaries.overview(
          LegalDocumentType.terms,
          tag,
        );
        final purchase = LegalLocaleSummaries.overview(
          LegalDocumentType.purchase,
          tag,
        );
        expect(terms.trim(), isNotEmpty, reason: '$tag terms must exist');
        expect(purchase.trim(), isNotEmpty, reason: '$tag purchase must exist');
        expect(terms.length, greaterThan(300), reason: '$tag terms too short');
        expect(
          purchase.length,
          greaterThan(400),
          reason: '$tag purchase terms too short',
        );
        if (tag != 'en') {
          expect(
            terms,
            isNot(englishTerms),
            reason: '$tag terms must not silently fall back to English',
          );
          expect(
            purchase,
            isNot(englishPurchase),
            reason: '$tag purchase must not silently fall back to English',
          );
        }
        final visibleTerms = ProBranding.visibleText(tag, terms);
        final visiblePurchase = ProBranding.visibleText(tag, purchase);
        final localizedPremium = MonetizationStrings.text(tag, 'premium');
        if (localizedPremium != 'PRO') {
          expect(visibleTerms, isNot(contains(localizedPremium)));
          expect(visiblePurchase, isNot(contains(localizedPremium)));
        }
      }
    });

    test('English legal masters cover restore, refund and ad-free entitlement', () {
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

      expect(privacy, contains('purchase token'));
      expect(privacy, contains('Google Play Integrity'));
      expect(terms.toLowerCase(), contains('ads'));
      expect(purchase.toLowerCase(), contains('restore'));
      expect(purchase.toLowerCase(), contains('restore button'));
      expect(purchase.toLowerCase(), contains('refund'));
      expect(purchase, contains('ESMANUR'));
      expect(purchase, contains('LEFFERION'));
    });

    test('rewarded PRO is server-authoritative and SSV-bound', () {
      final controllerSource =
          File('lib/monetization/monetization_controller.dart').readAsStringSync();
      final adSource = File('lib/monetization/ad_service.dart').readAsStringSync();
      final workerSource =
          File('backend/monetization-worker/src/index.ts').readAsStringSync();

      final rewardMethodStart =
          controllerSource.indexOf('Future<bool> watchRewardedForDailyPremium()');
      final promoMethodStart = controllerSource.indexOf(
        'Future<PromoRedemptionResult> redeemPromo',
        rewardMethodStart,
      );
      expect(rewardMethodStart, greaterThanOrEqualTo(0));
      expect(promoMethodStart, greaterThan(rewardMethodStart));
      final rewardMethod = controllerSource.substring(
        rewardMethodStart,
        promoMethodStart,
      );
      expect(rewardMethod, contains('createRewardSession'));
      expect(rewardMethod, contains('rewardSessionStatus'));
      expect(rewardMethod, isNot(contains('recordRewardedView')));
      expect(rewardMethod, isNot(contains('grantTemporaryDuration')));
      expect(adSource, contains('ServerSideVerificationOptions'));
      expect(adSource, contains('customData'));
      expect(workerSource, contains('/v1/reward/admob/ssv'));
      expect(workerSource, contains('rewarded_transactions'));
      expect(workerSource, contains('transaction_id'));
      expect(
        workerSource,
        contains('urn:ietf:params:oauth:grant-type:jwt-bearer'),
      );
    });
  });
}
