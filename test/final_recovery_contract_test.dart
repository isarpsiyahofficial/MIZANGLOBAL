import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expense UI exposes 30 60 and 90 day ranges without a Turkish leak', () {
    final source = File('lib/screens/expenses_screen.dart').readAsStringSync();
    expect(source, contains('_ExpensePeriod.days30'));
    expect(source, contains('_ExpensePeriod.days60'));
    expect(source, contains('Duration(days: 59)'));
    expect(source, contains('_ExpensePeriod.days90'));
    expect(source, contains("MizanI18n.text('Son 30 gün')"));
    expect(source, contains("replaceFirst('30', '60')"));
    expect(source, contains("replaceFirst('৩০', '৬০')"));
    expect(source, contains("replaceFirst('۳۰', '۶۰')"));
  });

  test(
    'report UI exposes every period already supported by report service',
    () {
      final source = File('lib/screens/reports_screen.dart').readAsStringSync();
      final service = File(
        'lib/services/report_service.dart',
      ).readAsStringSync();
      for (final period in <String>[
        'daily',
        'weekly',
        'monthly',
        'yearly',
        'allTime',
      ]) {
        expect(service, contains('ReportPeriod.$period'));
        expect(source, contains('ReportPeriod.$period'));
      }
      expect(source, contains('showDatePicker('));
    },
  );

  test('purchase cannot start when purchase-term persistence fails', () {
    final store = File(
      'lib/legal/legal_acceptance_store.dart',
    ).readAsStringSync();
    final premium = File('lib/screens/premium_screen.dart').readAsStringSync();
    final purchaseConsent = File(
      'lib/screens/purchase_consent_screen.dart',
    ).readAsStringSync();
    expect(store, contains('static Future<bool> acceptCurrentPurchaseTerms()'));
    expect(store, contains('return await prefs.setString('));
    expect(purchaseConsent, contains('final recorded ='));
    expect(purchaseConsent, contains('if (!recorded)'));
    final failedIndex = purchaseConsent.indexOf('if (!recorded)');
    final completedIndex = purchaseConsent.indexOf('pop(true)');
    expect(failedIndex, greaterThanOrEqualTo(0));
    expect(completedIndex, greaterThan(failedIndex));
    final gateIndex = premium.indexOf('if (_purchaseTermsAccepted != true)');
    final reviewIndex = premium.indexOf(
      'await _reviewPurchaseTerms()',
      gateIndex,
    );
    final buyIndex = premium.indexOf('buyPermanentPremium()');
    expect(gateIndex, greaterThanOrEqualTo(0));
    expect(reviewIndex, greaterThan(gateIndex));
    expect(buyIndex, greaterThan(reviewIndex));
  });

  test('general legal gate stays closed when persistence fails', () {
    final store = File(
      'lib/legal/legal_acceptance_store.dart',
    ).readAsStringSync();
    final consent = File(
      'lib/screens/legal_consent_screen.dart',
    ).readAsStringSync();
    expect(store, contains('static Future<bool> acceptCurrentLegalBundle()'));
    expect(
      consent,
      contains(
        'final recorded = await LegalAcceptanceStore.acceptCurrentLegalBundle();',
      ),
    );
    expect(consent, contains('if (!recorded)'));
    final failedIndex = consent.indexOf('if (!recorded)');
    final acceptedIndex = consent.indexOf('widget.onAccepted()');
    expect(failedIndex, greaterThanOrEqualTo(0));
    expect(acceptedIndex, greaterThan(failedIndex));
  });

  test('legal documents use visible PRO branding', () {
    final english = File('lib/legal/legal_documents.dart').readAsStringSync();
    final turkish = File(
      'lib/legal/legal_turkish_documents.dart',
    ).readAsStringSync();
    expect(english, isNot(contains('Premium')));
    expect(turkish, isNot(contains('Premium')));
    expect(english, contains('Permanent PRO Purchase Terms'));
    expect(turkish, contains('Kalıcı PRO Satın Alma Koşulları'));
  });

  test(
    'both release workflows regenerate launcher icons before release build',
    () {
      final android = File(
        '.github/workflows/android-release.yml',
      ).readAsStringSync();
      final finalAudit = File(
        '.github/workflows/final-branch-ci.yml',
      ).readAsStringSync();
      expect(android, contains('dart run flutter_launcher_icons'));
      expect(finalAudit, contains('dart run flutter_launcher_icons'));
      expect(
        finalAudit.indexOf('dart run flutter_launcher_icons'),
        lessThan(finalAudit.indexOf('flutter build apk --release')),
      );
    },
  );
}
