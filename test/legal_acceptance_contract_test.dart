import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/legal/legal_consent_strings.dart';
import 'package:lefferion_prime_mizan/legal/legal_documents.dart';
import 'package:lefferion_prime_mizan/legal/legal_turkish_documents.dart';

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

  test('Turkish and English masters are both substantial legal documents', () {
    for (final type in LegalDocumentType.values) {
      final tr = LegalTurkishDocuments.forType(type);
      final en = MizanLegalDocuments.document(type, 'en').englishMaster;
      expect(tr.length, greaterThan(1500), reason: '$type Turkish master');
      expect(en.length, greaterThan(1500), reason: '$type English master');
    }
  });

  test('first-run and purchase read gates are wired into production source', () {
    final main = File('lib/main.dart').readAsStringSync();
    final premium = File('lib/screens/premium_screen.dart').readAsStringSync();
    final legal = File('lib/screens/legal_document_screen.dart').readAsStringSync();
    final consent = File('lib/screens/legal_consent_screen.dart').readAsStringSync();

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

  test('automatic restore remains silent and no restore button is added', () {
    final purchase = File('lib/monetization/purchase_service.dart').readAsStringSync();
    final premium = File('lib/screens/premium_screen.dart').readAsStringSync();

    expect(purchase, contains('synchronizeOwnedPurchases'));
    expect(purchase, contains('queryPastPurchases'));
    expect(purchase, contains('There is intentionally no user-facing restore button'));
    expect(premium, isNot(contains('restorePurchases(')));
  });

  test('Premium store surface contains purchase and promo redemption', () {
    final premium = File('lib/screens/premium_screen.dart').readAsStringSync();
    expect(premium, contains('buyPermanentPremium'));
    expect(premium, contains('redeemPromo'));
    expect(premium, contains("_t('promoTitle')"));
    expect(premium, contains("_t('buyLifetime')"));
  });

  test('server promo contract keeps exact campaign durations', () {
    final worker = File(
      'backend/monetization-worker/src/index.ts',
    ).readAsStringSync();
    expect(worker, contains('ESMANUR: 7'));
    expect(worker, contains('LEFFERION: 3'));
  });
}
