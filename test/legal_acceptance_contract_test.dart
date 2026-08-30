import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/legal/legal_acceptance_store.dart';
import 'package:lefferion_prime_mizan/legal/legal_consent_strings.dart';
import 'package:lefferion_prime_mizan/legal/legal_documents.dart';
import 'package:lefferion_prime_mizan/legal/legal_turkish_documents.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test('legal navigation copy remains available in all 29 languages', () {
    expect(LegalConsentStrings.supportedTags, tags);
    for (final tag in tags) {
      for (final key in <String>[
        'title',
        'privacy',
        'terms',
        'purchase',
        'accept',
        'privacyAcknowledgement',
        'purchaseAcceptance',
        'continue',
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
      'purchaseReadRequirement',
      'temporaryPurchaseLocked',
    ];
    for (final tag in tags) {
      for (final key in keys) {
        final value = MonetizationStrings.text(tag, key).trim();
        expect(value, isNotEmpty, reason: '$tag:$key');
        expect(value, isNot(key), reason: '$tag:$key fell through to raw key');
      }
    }
  });

  test('general and purchase legal acceptance are independent', () async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    expect(await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle(), isFalse);
    expect(
      await LegalAcceptanceStore.hasAcceptedCurrentPurchaseTerms(),
      isFalse,
    );

    await LegalAcceptanceStore.acceptCurrentLegalBundle();
    expect(await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle(), isTrue);
    expect(
      await LegalAcceptanceStore.hasAcceptedCurrentPurchaseTerms(),
      isFalse,
    );

    await LegalAcceptanceStore.acceptCurrentPurchaseTerms();
    expect(
      await LegalAcceptanceStore.hasAcceptedCurrentPurchaseTerms(),
      isTrue,
    );
  });

  test(
    'Turkish and English masters are complete and cleaned legal documents',
    () {
      for (final type in LegalDocumentType.values) {
        final tr = LegalTurkishDocuments.forType(type);
        final en = MizanLegalDocuments.document(type, 'en').englishMaster;
        expect(tr.length, greaterThan(1500), reason: '$type Turkish master');
        expect(en.length, greaterThan(1500), reason: '$type English master');

        final combined = '$tr\n$en'.toLowerCase();
        for (final forbidden in <String>[
          'yürürlük tarihi',
          'effective date',
          'ip adresi',
          'ip address',
          'request metadata',
          'rdp=1',
          'esmanur',
          'promosyon kod',
          'promotion code',
          'ödüllü reklam',
          'rewarded advertising',
          'sessizce geri',
          'silent restore',
          'previous purchases are restored',
          'önceki satın alımlar',
          'restore button',
          'geri yükleme düğmesi',
        ]) {
          expect(
            combined,
            isNot(contains(forbidden)),
            reason: '$type:$forbidden',
          );
        }
      }

      expect(
        LegalTurkishDocuments.terms,
        contains('reklamların gösterilmemesi amaçlanır'),
      );
      expect(
        MizanLegalDocuments.document(
          LegalDocumentType.terms,
          'en',
        ).englishMaster,
        contains('designed not to show App-served advertising'),
      );
    },
  );

  test('first-run and purchase read gates match the final legal flow', () {
    final consent = File(
      'lib/screens/legal_consent_screen.dart',
    ).readAsStringSync();
    final premium = File('lib/screens/premium_screen.dart').readAsStringSync();
    final purchaseConsent = File(
      'lib/screens/purchase_consent_screen.dart',
    ).readAsStringSync();
    final legal = File(
      'lib/screens/legal_document_screen.dart',
    ).readAsStringSync();

    expect(consent, contains('LegalDocumentType.privacy'));
    expect(consent, contains('LegalDocumentType.terms'));
    expect(
      consent,
      isNot(
        contains('_documentTile(\n                LegalDocumentType.purchase'),
      ),
    );
    expect(consent, contains('acceptCurrentLegalBundle'));

    expect(premium, contains('hasAcceptedCurrentPurchaseTerms'));
    expect(premium, contains('PurchaseConsentScreen'));
    expect(premium, contains('buyPermanentPremium'));

    expect(
      purchaseConsent,
      contains(
        'static const _documents = <LegalDocumentType>['
        'LegalDocumentType.purchase];',
      ),
    );
    expect(purchaseConsent, contains('requireReadToEnd: true'));
    expect(purchaseConsent, contains('acceptCurrentPurchaseTerms'));
    expect(purchaseConsent, contains("_documents.every(_read.contains)"));

    expect(legal, contains('LegalTurkishDocuments.forType'));
    expect(legal, contains('englishMaster'));
    expect(consent, contains("_t('privacyAcknowledgement')"));
    expect(purchaseConsent, contains("_t('purchaseAcceptance')"));
    expect(legal, contains("label: Text(_t('readDone'))"));
    expect(legal, isNot(contains('LegalLocaleSummaries')));
  });

  test('retired duplicate legal narration files are absent', () {
    for (final path in <String>[
      'lib/legal/legal_document_focus.dart',
      'lib/legal/legal_locale_summaries.dart',
      'lib/legal/serverless_legal_overview.dart',
    ]) {
      expect(File(path).existsSync(), isFalse, reason: path);
    }
  });

  test('automatic Google Play ownership sync remains implementation-only', () {
    final purchase = File(
      'lib/monetization/purchase_service.dart',
    ).readAsStringSync();
    final masters = <String>[
      LegalTurkishDocuments.privacy,
      LegalTurkishDocuments.terms,
      LegalTurkishDocuments.purchase,
      for (final type in LegalDocumentType.values)
        MizanLegalDocuments.document(type, 'en').englishMaster,
    ].join('\n').toLowerCase();

    expect(purchase, contains('queryPastPurchases'));
    expect(purchase, contains('unawaited(synchronizeOwnedPurchases());'));
    expect(masters, isNot(contains('querypastpurchases')));
    expect(masters, isNot(contains('synchronizeownedpurchases')));
  });
}
