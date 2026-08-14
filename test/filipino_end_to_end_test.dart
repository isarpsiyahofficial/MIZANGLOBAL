import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
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

  test(
    'Filipino reminders localize system copy while custom user message stays unchanged',
    () {
      final now = DateTime(2026, 8, 7, 8);
      final state = comprehensiveState(reference: now, currencyCode: 'PHP')
          .copyWith(
            appLanguageTag: 'fil',
            debtRegionCountryCode: 'PH',
            defaultCurrencyCode: 'PHP',
            notificationSlots: const [],
            paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
            paymentNotificationSlots: const [
              NotificationSlot(
                id: 'custom-fil',
                label: 'Custom Slot 24',
                hour: 10,
                minute: 0,
                message: 'Personal na mensahe ni Ana — 한국어 日本語 中文',
              ),
            ],
          );
      final reminder = const ReminderPlanBuilder()
          .build(state: state, now: now)
          .firstWhere((item) => item.sourceId == 'bank-debt-1');
      expect(reminder.title, contains('Utang sa bangko:'));
      expect(reminder.title, contains('Kart borcu'));
      expect(
        reminder.message,
        contains('Personal na mensahe ni Ana — 한국어 日本語 中文'),
      );
      expect(reminder.message, contains('Due'));
      expect(reminder.message, contains('₱'));
      expect(reminder.title, isNot(contains('Banka borcu:')));
      expect(reminder.message, isNot(contains('Kalan tutar')));
      for (final leak in const [
        'Utang bank',
        'Hutang bank',
        'Pengingat',
        'Peringatan',
      ])
        expect(
          '${reminder.title} ${reminder.message}',
          isNot(contains(leak)),
          reason: leak,
        );
    },
  );
}
