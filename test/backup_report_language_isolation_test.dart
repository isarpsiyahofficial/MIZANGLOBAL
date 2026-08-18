import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/monetization/pro_branding.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';
import 'package:lefferion_prime_mizan/widgets/backup_premium_access_card.dart';
import 'package:lefferion_prime_mizan/widgets/pdf_premium_access_card.dart';

void main() {
  test(
    'backup and PDF access catalogs cover exactly the same 29 languages',
    () {
      expect(
        PdfAccessStrings.supportedLanguageTags,
        MizanI18n.supportedLanguageTags,
      );

      for (final tag in MizanI18n.supportedLanguageTags) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        expect(
          MizanI18n.text('CSV yedekleme', languageTag: tag).trim(),
          isNotEmpty,
          reason: '$tag backup title',
        );
        expect(
          ProBranding.monetizationText(tag, 'buyLifetime').trim(),
          isNotEmpty,
          reason: '$tag backup PRO action',
        );
        for (final key in const [
          'pdfTitle',
          'lockedTitle',
          'lockedHint',
          'lockedBody',
          'unlockedHint',
          'preview',
          'download',
          'share',
        ]) {
          expect(
            PdfAccessStrings.text(tag, key).trim(),
            isNotEmpty,
            reason: '$tag pdf/$key',
          );
        }
        for (final period in ReportPeriod.values) {
          expect(
            period.labelFor(tag).trim(),
            isNotEmpty,
            reason: '$tag/${period.name}',
          );
        }
      }
    },
  );

  test(
    'backup and report surfaces do not expose raw exception or TR filename fallbacks',
    () {
      final settings = File(
        'lib/screens/settings_screen.dart',
      ).readAsStringSync();
      final reports = File(
        'lib/screens/reports_screen.dart',
      ).readAsStringSync();

      expect(settings, isNot(contains(r'CSV yedeği oluşturulamadı: $error')));
      expect(settings, isNot(contains(r'CSV yedeği birleştirilemedi: $error')));
      expect(settings, isNot(contains("'Yeni eklenecek: ")));
      expect(settings, isNot(contains("'Eksik ilişkisi tamamlanacak: ")));
      expect(reports, isNot(contains(r'PDF raporu kaydedilemedi: $error')));
      expect(reports, isNot(contains(r'PDF raporu paylaşılamadı: $error')));
      expect(reports, isNot(contains("_ => 'RAPOR'")));
      expect(reports, isNot(contains('period.name.toUpperCase()')));
      expect(
        reports,
        contains('report.filter.period.labelFor(report.languageTag)'),
      );
    },
  );

  testWidgets(
    'backup and PDF lock surfaces render the active language for all 29 locales',
    (tester) async {
      for (final tag in MizanI18n.supportedLanguageTags) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  BackupPremiumAccessCard(
                    controller: null,
                    isPermanentPremium: false,
                    isTemporaryPremium: false,
                    busy: false,
                    onExport: () {},
                    onImport: () {},
                  ),
                  PdfPremiumAccessCard(
                    controller: null,
                    isPremium: false,
                    generating: false,
                    onSave: () {},
                    onShare: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        final backupTitle = MizanI18n.text('CSV yedekleme', languageTag: tag);
        final targetPdf = PdfAccessStrings.text(tag, 'lockedBody');
        expect(find.text(backupTitle), findsWidgets, reason: '$tag backup');
        expect(find.text(targetPdf), findsOneWidget, reason: '$tag PDF');
        if (tag != 'tr') {
          expect(
            find.text('CSV yedekleme'),
            findsNothing,
            reason: '$tag <- tr backup',
          );
          expect(
            find.text(PdfAccessStrings.text('tr', 'lockedBody')),
            findsNothing,
            reason: '$tag <- tr PDF',
          );
        }
        if (tag != 'en') {
          expect(
            find.text(PdfAccessStrings.text('en', 'lockedBody')),
            findsNothing,
            reason: '$tag <- en PDF',
          );
        }
      }
    },
  );
}
