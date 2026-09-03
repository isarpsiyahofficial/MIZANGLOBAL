import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';
import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));
  test(
    'Korean report and PDF surface keep Korean language KRW and user data isolated',
    () {
      final now = DateTime(2026, 8, 7, 12);
      final state = comprehensiveState(reference: now, currencyCode: 'KRW')
          .copyWith(
            appLanguageTag: 'ko',
            debtRegionCountryCode: 'KR',
            defaultCurrencyCode: 'KRW',
          );
      MizanI18n.setProfile(languageTag: 'ko', currencyCode: 'KRW');
      final r = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
        now: now,
      );
      expect(r.languageTag, 'ko');
      expect(r.currencyCode, 'KRW');
      expect(r.filter.period.label, '매월');
      expect(r.range.label, '2026년 8월');
      expect(r.selectedPersonNames.any((v) => v.contains('İbrahim')), isTrue);
      for (final leak in const ['8月', 'Agosto', 'Agustus', 'Ogos', 'Ağustos'])
        expect(r.range.label, isNot(contains(leak)), reason: leak);
      expect(MizanI18n.text('PDF raporu'), 'PDF 보고서');
      expect(MizanI18n.text('Kalan ödeme yükü'), '남은 납부 부담');
    },
  );
}
