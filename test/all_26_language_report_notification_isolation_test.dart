import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';
import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));
  const tags = [
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

  test(
    'all 29 languages build reports with their own runtime and unchanged user data',
    () {
      final now = DateTime(2026, 8, 7, 12);
      for (final tag in tags) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        final state = comprehensiveState(
          reference: now,
        ).copyWith(appLanguageTag: tag, defaultCurrencyCode: 'USD');
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
        expect(report.currencyCode, 'USD', reason: tag);
        expect(
          report.filter.period.label,
          MizanI18n.text('Aylık'),
          reason: tag,
        );
        expect(report.range.label.trim(), isNotEmpty, reason: tag);
        expect(
          report.selectedPersonNames.any((v) => v.contains('İbrahim')),
          isTrue,
          reason: tag,
        );
      }
    },
  );

  test(
    'all 29 languages build localized payment reminders while custom message remains unchanged',
    () {
      final now = DateTime(2026, 8, 7, 8);
      const custom =
          'CUSTOM Bank 24 한국어 日本語 中文 العربية Tiếng Việt ไทย Kiswahili';
      for (final tag in tags) {
        MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
        final state = comprehensiveState(reference: now).copyWith(
          appLanguageTag: tag,
          defaultCurrencyCode: 'USD',
          notificationSlots: const [],
          paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
          paymentNotificationSlots: const [
            NotificationSlot(
              id: 'global-custom',
              label: 'Custom Slot',
              hour: 10,
              minute: 0,
              message: custom,
            ),
          ],
        );
        final reminder = const ReminderPlanBuilder()
            .build(state: state, now: now)
            .firstWhere((e) => e.sourceId == 'bank-debt-1');
        expect(
          reminder.title,
          contains(MizanI18n.text('Banka borcu')),
          reason: tag,
        );
        expect(reminder.title, contains('Kart borcu'), reason: tag);
        expect(reminder.message, contains(custom), reason: tag);
        expect(reminder.message, contains('USD'), reason: tag);
        if (tag != 'tr')
          expect(
            reminder.title,
            isNot(startsWith('Banka borcu:')),
            reason: tag,
          );
      }
    },
  );
}
