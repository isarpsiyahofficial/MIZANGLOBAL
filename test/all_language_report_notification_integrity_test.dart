import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
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
  };
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test('all 22 languages keep reports in the selected language', () {
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

  test(
    'all 22 languages keep notification system copy isolated while preserving user fields',
    () {
      final now = DateTime(2026, 8, 7, 8);
      for (final tag in tags) {
        final currency = currencies[tag]!;
        MizanI18n.setProfile(languageTag: tag, currencyCode: currency);
        final state = comprehensiveState(reference: now).copyWith(
          appLanguageTag: tag,
          defaultCurrencyCode: currency,
          notificationSlots: const [],
          paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
          paymentNotificationSlots: const [
            NotificationSlot(
              id: 'cross-language-slot',
              label: 'User Slot 24',
              hour: 10,
              minute: 0,
              message: 'CUSTOM USER MESSAGE 24',
            ),
          ],
        );
        final reminder = const ReminderPlanBuilder()
            .build(state: state, now: now)
            .firstWhere((item) => item.sourceId == 'bank-debt-1');
        expect(
          reminder.title,
          contains('Kart borcu'),
          reason: 'user-authored title changed in $tag',
        );
        expect(
          reminder.message,
          contains('CUSTOM USER MESSAGE 24'),
          reason: 'user message changed in $tag',
        );
        if (tag != 'tr') {
          expect(
            reminder.title,
            isNot(contains('Banka borcu:')),
            reason: 'notification title leaked Turkish in $tag',
          );
          expect(
            reminder.message,
            isNot(contains('Kalan tutar')),
            reason: 'notification body leaked Turkish in $tag',
          );
        }
      }
    },
  );
}
