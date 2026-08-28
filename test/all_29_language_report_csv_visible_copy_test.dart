import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/mizan_clock.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/screens/reports_screen.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

const _tags = <String>[
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
  'vi',
  'th',
  'sw',
  'zh',
  'ja',
  'ko',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 8, 26, 13, 35);

  tearDown(() {
    MizanClock.resetForTesting();
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  testWidgets(
    'all 29 report screens keep composed titles and due copy in the selected language',
    (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      MizanClock.setNowForTesting(now);

      const dueSource =
          'Vade, kişi, kayıt türü, gecikme süresi ve sıradaki ödeme tutarı birlikte sunulur.';
      const warningSource =
          'Lefferion Prime - MİZAN hata yapabilir. Lütfen vade, gecikme ve ödeme bilgilerini son kez kontrol edin.';

      for (final tag in _tags) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        final state = comprehensiveState(reference: now, currencyCode: 'USD')
            .copyWith(
              setupCompleted: true,
              appLanguageTag: tag,
              debtRegionCountryCode: 'US',
              defaultCurrencyCode: 'USD',
            );
        final controller = MizanController(
          MemoryStore(state),
          scheduler: SpyScheduler(),
        );
        await controller.load();
        final report = const MizanReportService().build(
          state: state,
          filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
          now: now,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ReportsScreen(controller: controller)),
          ),
        );
        await tester.pumpAndSettle();

        final totalTitle = find.byKey(
          const ValueKey('report-realized-total-title'),
        );
        await tester.scrollUntilVisible(
          totalTitle,
          500,
          scrollable: find.byType(Scrollable).first,
          maxScrolls: 20,
        );
        final expectedTotalTitle =
            '${MizanI18n.text('Toplam gider', languageTag: tag)} · ${report.range.label}';
        expect(find.text(expectedTotalTitle), findsOneWidget, reason: tag);
        if (tag != 'tr') {
          expect(
            expectedTotalTitle,
            isNot(contains(' toplam gider')),
            reason: '$tag mixed localized range with Turkish suffix',
          );
        }

        final dueSection = find.byKey(const ValueKey('report-due-details'));
        await tester.scrollUntilVisible(
          dueSection,
          500,
          scrollable: find.byType(Scrollable).first,
          maxScrolls: 30,
        );
        final expectedDue =
            '${MizanI18n.text(dueSource, languageTag: tag)} '
            '${MizanI18n.text(warningSource, languageTag: tag)}';
        expect(find.text(expectedDue), findsOneWidget, reason: tag);
        if (tag != 'tr') {
          expect(find.textContaining(dueSource), findsNothing, reason: tag);
        }
        expect(tester.takeException(), isNull, reason: tag);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        controller.dispose();
      }
    },
  );

  test(
    'all 29 CSV backups localize visible metadata from the saved profile',
    () {
      final service = CsvBackupService();
      final codec = CsvCodec();
      for (final tag in _tags) {
        final state = comprehensiveState(reference: now, currencyCode: 'USD')
            .copyWith(
              appLanguageTag: tag,
              debtRegionCountryCode: 'US',
              defaultCurrencyCode: 'USD',
            );

        MizanI18n.setProfile(languageTag: tag == 'tr' ? 'en' : 'tr');
        final rows = codec.decode(service.exportState(state));
        final header = rows.first.map((value) => value.toString()).toList();
        final typeIndex = header.indexOf('entity_type');
        final nameIndex = header.indexOf('name');
        final snapshot = rows.singleWhere(
          (row) => row[typeIndex].toString() == 'snapshot',
        );
        expect(
          snapshot[nameIndex],
          MizanI18n.text('MİZAN tam yedek', languageTag: tag),
          reason: tag,
        );
      }
    },
  );
}
