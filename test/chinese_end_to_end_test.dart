import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';
import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));
  test('Chinese report PDF language CNY and user data stay isolated', () {
    final now = DateTime(2026, 8, 7, 12);
    final state = comprehensiveState(reference: now, currencyCode: 'CNY')
        .copyWith(
          appLanguageTag: 'zh',
          debtRegionCountryCode: 'CN',
          defaultCurrencyCode: 'CNY',
        );
    MizanI18n.setProfile(languageTag: 'zh', currencyCode: 'CNY');
    final r = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );
    expect(r.languageTag, 'zh');
    expect(r.currencyCode, 'CNY');
    expect(r.filter.period.label, '每月');
    expect(r.range.label, '2026年8月');
    expect(r.selectedPersonNames.any((v) => v.contains('İbrahim')), isTrue);
    for (final leak in const [
      '2026년 8월',
      'Agosto',
      'Agustus',
      'Ogos',
      'Ağustos',
    ])
      expect(r.range.label, isNot(contains(leak)), reason: leak);
    expect(MizanI18n.text('PDF raporu'), 'PDF 报告');
    expect(MizanI18n.text('Kalan ödeme yükü'), '剩余付款负担');
  });
}
