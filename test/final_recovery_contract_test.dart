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

  test('report UI exposes every period already supported by report service', () {
    final source = File('lib/screens/reports_screen.dart').readAsStringSync();
    final service = File('lib/services/report_service.dart').readAsStringSync();
    for (final period in <String>['daily', 'weekly', 'monthly', 'yearly', 'allTime']) {
      expect(service, contains('ReportPeriod.$period'));
      expect(source, contains('ReportPeriod.$period'));
    }
    expect(source, contains('showDatePicker('));
  });

  test('purchase cannot start when purchase-term persistence fails', () {
    final store = File('lib/legal/legal_acceptance_store.dart').readAsStringSync();
    final premium = File('lib/screens/premium_screen.dart').readAsStringSync();
    expect(store, contains('static Future<bool> acceptCurrentPurchaseTerms()'));
    expect(store, contains('return await prefs.setString('));
    expect(premium, contains('final recorded ='));
    expect(premium, contains('if (!recorded)'));
    final failedIndex = premium.indexOf('if (!recorded)');
    final buyIndex = premium.indexOf('buyPermanentPremium()');
    expect(failedIndex, greaterThanOrEqualTo(0));
    expect(buyIndex, greaterThan(failedIndex));
  });

  test('legal documents use visible PRO branding', () {
    final english = File('lib/legal/legal_documents.dart').readAsStringSync();
    final turkish = File('lib/legal/legal_turkish_documents.dart').readAsStringSync();
    expect(english, isNot(contains('Premium')));
    expect(turkish, isNot(contains('Premium')));
    expect(english, contains('Permanent PRO Purchase Terms'));
    expect(turkish, contains('Kalıcı PRO Satın Alma Koşulları'));
  });

  test('both release workflows regenerate launcher icons before release build', () {
    final android = File('.github/workflows/android-release.yml').readAsStringSync();
    final finalAudit = File('.github/workflows/final-branch-ci.yml').readAsStringSync();
    expect(android, contains('dart run flutter_launcher_icons'));
    expect(finalAudit, contains('dart run flutter_launcher_icons'));
    expect(
      finalAudit.indexOf('dart run flutter_launcher_icons'),
      lessThan(finalAudit.indexOf('flutter build apk --release')),
    );
  });
}
