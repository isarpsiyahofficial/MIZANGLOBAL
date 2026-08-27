import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/services/pdf_report_renderer.dart'
    as renderer;
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const reportKeys = <String>[
    'Rapor özeti',
    'Gelir',
    'Ödemelere yapılan gider',
    'Normal giderler',
    'Toplam gider',
    'Gelir ayrıntıları',
    'Gerçekleşen harcamaların dağılımı',
    'Gerçekleşen ödeme ayrıntıları',
    'Gider dağılımı',
    'Gider ayrıntıları',
    'Kalan ödeme yükünün dağılımı',
    'Kalan ödeme ayrıntıları',
    'Kişi bazında güncel kalan borç',
  ];
  const dueDetailSource =
      'Vade, kişi, kayıt türü, gecikme süresi ve sıradaki ödeme tutarı birlikte sunulur.';
  const warningSource =
      'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.';

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('PDF renderer has no pre-localized Turkish template recomposition', () {
    final source = File(
      'lib/services/pdf_report_renderer.dart',
    ).readAsStringSync();
    expect(source, isNot(contains(r'$mizanCalculationWarning')));
    expect(source, isNot(contains(r'\nNot: $note')));

    final reportsScreen = File(
      'lib/screens/reports_screen.dart',
    ).readAsStringSync();
    expect(reportsScreen, isNot(contains(r'. $mizanCalculationWarning')));
    expect(reportsScreen, contains('subtitleAlreadyLocalized: true'));
  });

  test(
    'all 29 PDF render paths contain only the selected system copy',
    () async {
      for (final tag in MizanI18n.supportedLanguageTags) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        final now = DateTime(2026, 8, 26, 13, 35);
        final state = comprehensiveState(reference: now, currencyCode: 'USD')
            .copyWith(
              appLanguageTag: tag,
              debtRegionCountryCode: 'US',
              defaultCurrencyCode: 'USD',
            );
        final report = const MizanReportService().build(
          state: state,
          filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
          now: now,
        );
        final visible = await const renderer.PdfReportService()
            .debugVisibleCopy(report);
        final exact = visible.toSet();
        final joined = visible.join('\n');

        for (final source in reportKeys) {
          final localized = MizanI18n.text(source, languageTag: tag);
          expect(localized.trim(), isNotEmpty, reason: '$tag/$source');
          expect(
            exact,
            contains(localized),
            reason: '$tag/$source not painted',
          );
          if (tag != 'tr' && localized != source) {
            expect(
              exact,
              isNot(contains(source)),
              reason: '$tag leaked $source',
            );
          }
        }

        final localizedDue = MizanI18n.text(dueDetailSource, languageTag: tag);
        final localizedWarning = MizanI18n.text(
          warningSource,
          languageTag: tag,
        );
        expect(
          joined,
          contains('$localizedDue $localizedWarning'),
          reason: tag,
        );
        if (tag != 'tr') {
          expect(joined, isNot(contains(dueDetailSource)), reason: '$tag due');
          expect(
            joined,
            isNot(contains(warningSource)),
            reason: '$tag warning',
          );
        }
        if (tag != 'en') {
          final englishWarning = MizanI18n.text(
            warningSource,
            languageTag: 'en',
          );
          if (englishWarning != localizedWarning) {
            expect(
              joined,
              isNot(contains(englishWarning)),
              reason: '$tag leaked English warning',
            );
          }
        }

        if (tag != 'tr') {
          for (final leakedMarker in const <String>[
            'LEFFERION PRIME - MİZAN · Sayfa ',
            ' · devam',
            'Dönem:',
            'Kişi kapsamı:',
            'Oluşturulma:',
            'GÜN BAŞLIĞI',
            'Günlük harcamalar',
          ]) {
            expect(
              joined,
              isNot(contains(leakedMarker)),
              reason: '$tag leaked PDF marker: $leakedMarker',
            );
          }
          expect(
            joined,
            isNot(matches(RegExp(r'\d+ günlük harcama · \d+ ödeme'))),
            reason: '$tag leaked PDF day totals',
          );
        }
      }
    },
  );
}
