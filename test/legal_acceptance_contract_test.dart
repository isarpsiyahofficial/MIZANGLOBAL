import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/legal/legal_consent_strings.dart';
import 'package:lefferion_prime_mizan/legal/legal_documents.dart';
import 'package:lefferion_prime_mizan/legal/legal_turkish_documents.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_strings.dart';

void main() {
  const tags = <String>{
    'tr',
    'en',
    'es',
    'pt-BR',
    'pt-PT',
    'fr',
    'de',
    'it',
    'nl',
    'pl',
    'ro',
    'el',
    'ru',
    'uk',
    'ar',
    'fa',
    'he',
    'hi',
    'bn',
    'ur',
    'id',
    'ms',
    'fil',
    'ko',
    'ja',
    'zh',
    'vi',
    'th',
    'sw',
  };

  test('legal consent copy exists independently in all 29 languages', () {
    expect(LegalConsentStrings.supportedTags, tags);
    for (final tag in tags) {
      for (final key in <String>[
        'title',
        'intro',
        'readAll',
        'privacy',
        'terms',
        'purchase',
        'accept',
        'blocked',
        'readDone',
        'masterNotice',
      ]) {
        final value = LegalConsentStrings.text(tag, key).trim();
        expect(value, isNotEmpty, reason: '$tag:$key');
        if (tag != 'en') {
          expect(
            value,
            isNot(LegalConsentStrings.text('en', key)),
            reason: '$tag:$key leaked English fallback',
          );
        }
      }
    }
  });

  test('PRO store and entitlement copy exists in all 29 languages', () {
    expect(MonetizationStrings.supportedLanguageTags, tags);
    const keys = <String>[
      'premium',
      'premiumSubtitle',
      'lifetimePremium',
      'temporaryPremium',
      'freePlan',
      'premiumActive',
      'remaining',
      'lifetime',
      'buyLifetime',
      'playPrice',
      'benefitNoAds',
      'benefitOffline',
      'benefitPdf',
      'restoreInfo',
      'rewardTitle',
      'rewardSubtitle',
      'watchReward',
      'rewardProgress',
      'promoTitle',
      'promoHint',
      'promoApply',
      'promoAccepted',
      'promoAlreadyUsed',
      'promoInvalid',
      'internetRequired',
      'purchaseUnavailable',
      'privacyOptions',
      'privacyPolicy',
      'terms',
      'purchaseTerms',
    ];
    for (final tag in tags) {
      for (final key in keys) {
        final value = MonetizationStrings.text(tag, key).trim();
        expect(value, isNotEmpty, reason: '$tag:$key');
        expect(value, isNot(key), reason: '$tag:$key fell through to raw key');
      }
    }
  });

  test('Turkish and English masters are both substantial legal documents', () {
    for (final type in LegalDocumentType.values) {
      final tr = LegalTurkishDocuments.forType(type);
      final en = MizanLegalDocuments.document(type, 'en').englishMaster;
      expect(tr.length, greaterThan(1500), reason: '$type Turkish master');
      expect(en.length, greaterThan(1500), reason: '$type English master');
      expect(tr, isNot(contains('Play Integrity')));
      expect(en, isNot(contains('Cloudflare')));
    }
  });

  test('first-run and purchase read gates stay wired into production source', () {
    final main = File('lib/main.dart').readAsStringSync();
    final premium = File('lib/screens/premium_screen.dart').readAsStringSync();
    final legal = File(
      'lib/screens/legal_document_screen.dart',
    ).readAsStringSync();
    final consent = File(
      'lib/screens/legal_consent_screen.dart',
    ).readAsStringSync();

    expect(main, contains('LegalConsentScreen'));
    expect(main, contains('hasAcceptedCurrentLegalBundle'));
    expect(consent, contains('LegalDocumentType.values.length'));
    expect(consent, contains('acceptCurrentLegalBundle'));
    expect(premium, contains('hasAcceptedCurrentPurchaseTerms'));
    expect(premium, contains('acceptCurrentPurchaseTerms'));
    expect(premium, contains('requireReadToEnd: true'));
    expect(legal, contains('LegalTurkishDocuments.forType'));
    expect(legal, contains('document.englishMaster'));
    expect(legal, contains('position.maxScrollExtent'));
  });

  test('automatic restore remains silent and uses Google Play ownership', () {
    final purchase = File(
      'lib/monetization/purchase_service.dart',
    ).readAsStringSync();
    final premium = File('lib/screens/premium_screen.dart').readAsStringSync();

    expect(purchase, contains('unawaited(synchronizeOwnedPurchases());'));
    expect(purchase, contains('queryPastPurchases'));
    expect(purchase, isNot(contains('verifyGooglePlayPurchase')));
    expect(premium, isNot(contains('synchronizeOwnedPurchases')));
    expect(premium, isNot(contains('restorePurchases(')));
  });

  test('PRO store surface contains purchase and local promo redemption', () {
    final premium = File('lib/screens/premium_screen.dart').readAsStringSync();
    final promo = File(
      'lib/monetization/local_promo_service.dart',
    ).readAsStringSync();
    expect(premium, contains('buyPermanentPremium'));
    expect(premium, contains('redeemPromo'));
    expect(premium, contains("_t('promoTitle')"));
    expect(premium, contains("_t('buyLifetime')"));
    expect(promo, contains('Hmac(sha256'));
    expect(promo, contains('Duration(days: 7)'));
    expect(promo, contains('Duration(days: 3)'));
    expect(promo, isNot(contains('ESMANUR')));
    expect(promo, isNot(contains('LEFFERION')));
  });

  test('publisher monetization backend is absent', () {
    expect(Directory('backend/monetization-worker').existsSync(), isFalse);
    expect(File('lib/monetization/monetization_api.dart').existsSync(), isFalse);
  });
}
