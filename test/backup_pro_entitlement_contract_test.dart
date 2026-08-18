import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/monetization/monetization_strings.dart';
import 'package:lefferion_prime_mizan/monetization/premium_entitlement_store.dart';
import 'package:lefferion_prime_mizan/monetization/pro_branding.dart';
import 'package:lefferion_prime_mizan/widgets/backup_premium_access_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('backup dependencies cover exactly all 29 UI languages', () {
    expect(
      MonetizationStrings.supportedLanguageTags,
      MizanI18n.supportedLanguageTags,
    );
    expect(MonetizationStrings.supportedLanguageTags.length, 29);
    for (final tag in MizanI18n.supportedLanguageTags) {
      for (final key in const [
        'lifetimePremium',
        'temporaryPremium',
        'buyLifetime',
        'purchaseUnavailable',
        'restoreInfo',
      ]) {
        final value = ProBranding.monetizationText(tag, key).trim();
        expect(value, isNotEmpty, reason: '$tag/$key');
        expect(value, isNot(key), reason: '$tag/$key raw-key fallback');
      }
      final backupTitle = MizanI18n.text('CSV yedekleme', languageTag: tag);
      expect(backupTitle.trim(), isNotEmpty, reason: '$tag backup title');
      if (tag != 'tr') {
        expect(
          backupTitle,
          isNot('CSV yedekleme'),
          reason: '$tag Turkish leak',
        );
      }
    }
  });

  test(
    'temporary entitlement never creates permanent purchase proof',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final store = PremiumEntitlementStore();
      final temporary = await store.grantTemporaryDuration(
        const Duration(days: 7),
      );
      expect(temporary.permanent, isFalse);
      expect(temporary.permanentPurchaseFingerprint, isNull);

      const fingerprint =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      final permanent = await store.setPermanentPremium(
        purchaseFingerprint: fingerprint,
      );
      expect(permanent.permanent, isTrue);
      expect(permanent.permanentPurchaseFingerprint, fingerprint);
      expect(permanent.temporaryUntilUtc, isNull);

      final cleared = await store.clearPermanentPremium();
      expect(cleared.permanent, isFalse);
      expect(cleared.permanentPurchaseFingerprint, isNull);
    },
  );

  testWidgets('free user sees backup lock and no backup actions', (
    tester,
  ) async {
    MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BackupPremiumAccessCard(
            controller: null,
            isPermanentPremium: false,
            isTemporaryPremium: false,
            busy: false,
            onExport: () {},
            onImport: () {},
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('backup-pro-locked')), findsOneWidget);
    expect(find.byKey(const ValueKey('backup-export-enabled')), findsNothing);
    expect(find.byKey(const ValueKey('backup-import-enabled')), findsNothing);
    expect(
      find.textContaining(ProBranding.monetizationText('en', 'buyLifetime')),
      findsWidgets,
    );
  });

  testWidgets('temporary PRO remains backup-locked', (tester) async {
    MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BackupPremiumAccessCard(
            controller: null,
            isPermanentPremium: false,
            isTemporaryPremium: true,
            busy: false,
            onExport: () {},
            onImport: () {},
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('backup-pro-locked')), findsOneWidget);
    expect(find.byKey(const ValueKey('backup-export-enabled')), findsNothing);
    expect(find.byKey(const ValueKey('backup-import-enabled')), findsNothing);
    expect(
      find.textContaining(
        ProBranding.monetizationText('en', 'temporaryPremium'),
      ),
      findsWidgets,
    );
  });

  testWidgets('only permanent PRO exposes backup actions', (tester) async {
    var exports = 0;
    var imports = 0;
    MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BackupPremiumAccessCard(
            controller: null,
            isPermanentPremium: true,
            isTemporaryPremium: false,
            busy: false,
            onExport: () => exports++,
            onImport: () => imports++,
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('backup-pro-unlocked')), findsOneWidget);
    expect(find.byKey(const ValueKey('backup-export-enabled')), findsOneWidget);
    expect(find.byKey(const ValueKey('backup-import-enabled')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('backup-export-enabled')));
    await tester.tap(find.byKey(const ValueKey('backup-import-enabled')));
    expect(exports, 1);
    expect(imports, 1);
  });

  test(
    'Google Play purchase proof and backup gates stay structurally separate',
    () {
      final purchase = File(
        'lib/monetization/purchase_service.dart',
      ).readAsStringSync();
      final controller = File(
        'lib/monetization/monetization_controller.dart',
      ).readAsStringSync();
      final settings = File(
        'lib/screens/settings_screen.dart',
      ).readAsStringSync();
      final csv = File(
        'lib/services/csv_backup_service.dart',
      ).readAsStringSync();

      expect(purchase, contains('queryPastPurchases'));
      expect(purchase, contains('serverVerificationData'));
      expect(purchase, contains('sha256.convert'));
      expect(purchase, contains('purchaseFingerprint: _purchaseFingerprint'));
      expect(controller, contains('isPermanentPremium'));
      expect(
        controller,
        contains(
          'String? get permanentPurchaseFingerprint => isPermanentPremium',
        ),
      );
      expect(settings, contains('!monetization.isPermanentPremium'));
      expect(settings, isNot(contains('if (!monetization.isPremium)')));
      expect(csv, contains("'entitlement_proof'"));
      expect(csv, contains("'google_play_permanent'"));
      expect(csv, contains("'google_play_non_consumable'"));
      expect(csv, contains('permanentPurchaseFingerprint'));
      expect(csv, isNot(contains('temporaryUntilUtc')));
      expect(csv, isNot(contains('rewardedViewsToday')));
      expect(csv, isNot(contains('promo.used')));
    },
  );
}
