import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const tags = <String>[
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
  const currencies = <String, String>{
    'tr': 'TRY',
    'en': 'USD',
    'es': 'EUR',
    'pt-BR': 'BRL',
    'pt-PT': 'EUR',
    'fr': 'EUR',
    'de': 'EUR',
    'it': 'EUR',
    'nl': 'EUR',
    'pl': 'PLN',
    'ro': 'RON',
    'el': 'EUR',
    'ru': 'RUB',
    'uk': 'UAH',
    'ar': 'SAR',
    'fa': 'IRR',
    'he': 'ILS',
    'hi': 'INR',
    'bn': 'BDT',
    'ur': 'PKR',
    'id': 'IDR',
    'ms': 'MYR',
    'fil': 'PHP',
    'vi': 'VND',
    'th': 'THB',
    'sw': 'KES',
    'zh': 'CNY',
    'ja': 'JPY',
    'ko': 'KRW',
  };
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test('all 29 languages keep reports in the selected language', () {
    final now = DateTime(2026, 8, 7, 12);
    for (final tag in tags) {
      final currency = currencies[tag]!;
      MizanI18n.setProfile(languageTag: tag, currencyCode: currency);
      final state = comprehensiveState(
        reference: now,
      ).copyWith(appLanguageTag: tag, defaultCurrencyCode: currency);
      final report = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
        now: now,
      );
      expect(
        report.languageTag,
        MizanI18n.normalizeLanguageTag(tag),
        reason: tag,
      );
      expect(report.currencyCode, currency, reason: tag);
      expect(report.range.label.trim(), isNotEmpty, reason: tag);
      expect(report.filter.period.label.trim(), isNotEmpty, reason: tag);
      if (tag != 'tr') {
        expect(
          report.filter.period.label,
          isNot('Aylık'),
          reason: 'report period leaked Turkish in $tag',
        );
        expect(
          report.range.label,
          isNot(contains('Ağustos')),
          reason: 'report month leaked Turkish in $tag',
        );
      }
    }
  });
}
