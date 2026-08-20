import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test(
    'Filipino reports keep report PDF language currency and user data isolated',
    () {
      final now = DateTime(2026, 8, 7, 12);
      final state = comprehensiveState(reference: now, currencyCode: 'PHP')
          .copyWith(
            appLanguageTag: 'fil',
            debtRegionCountryCode: 'PH',
            defaultCurrencyCode: 'PHP',
          );
      MizanI18n.setProfile(languageTag: 'fil', currencyCode: 'PHP');
      final report = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
        now: now,
      );
      expect(report.languageTag, 'fil');
      expect(report.currencyCode, 'PHP');
      expect(report.filter.period.label, 'Buwanan');
      expect(report.range.label, 'Agosto 2026');
      expect(
        report.selectedPersonNames.any((v) => v.contains('İbrahim')),
        isTrue,
      );
      for (final leak in const [
        'Ağustos',
        'Agustus',
        'Ogos',
        'August',
        '8월',
        '8月',
      ])
        expect(report.range.label, isNot(contains(leak)), reason: leak);
      expect(MizanI18n.text('PDF raporu'), 'PDF report');
      expect(
        MizanI18n.text('Kalan ödeme yükü'),
        'Natitirang obligasyon sa pagbabayad',
      );
    },
  );
}
