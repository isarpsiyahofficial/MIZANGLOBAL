import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test('Urdu reports localize system copy and preserve user data', () {
    final now = DateTime(2026, 8, 5, 12);
    final state = comprehensiveState(reference: now, currencyCode: 'PKR')
        .copyWith(
          appLanguageTag: 'ur',
          debtRegionCountryCode: 'PK',
          defaultCurrencyCode: 'PKR',
        );
    MizanI18n.setProfile(languageTag: 'ur', currencyCode: 'PKR');
    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );
    expect(report.languageTag, 'ur');
    expect(report.currencyCode, 'PKR');
    expect(report.filter.period.label, 'ماہانہ');
    expect(report.range.label, 'اگست 2026');
    expect(
      report.selectedPersonNames.any((value) => value.contains('İbrahim')),
      isTrue,
    );
    for (final leak in const [
      'Ağustos',
      'अगस्त',
      'আগস্ট',
      'אוגוסט',
      'أغسطس',
      'اوت',
    ]) {
      expect(report.range.label, isNot(contains(leak)));
    }
  });
}
