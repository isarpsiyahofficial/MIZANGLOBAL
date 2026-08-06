import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test('Urdu reports localize system copy and preserve user data', () {
    final now = DateTime(2026, 8, 5, 12);
    final state = comprehensiveState(reference: now).copyWith(
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
    expect(report.selectedPersonNames.any((value) => value.contains('İbrahim')), isTrue);
    for (final leak in const ['Ağustos', 'अगस्त', 'আগস্ট', 'אוגוסט', 'أغسطس', 'اوت']) {
      expect(report.range.label, isNot(contains(leak)));
    }
  });

  test('Urdu reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 8, 5, 8);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'ur',
      debtRegionCountryCode: 'PK',
      defaultCurrencyCode: 'PKR',
      notificationSlots: const [],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom-payment-slot-ur',
          label: 'Custom Slot 24',
          hour: 10,
          minute: 0,
          message: 'صارف کے لیے ذاتی پیغام Bank 24',
        ),
      ],
    );
    final reminder = const ReminderPlanBuilder()
        .build(state: state, now: now)
        .firstWhere((item) => item.sourceId == 'bank-debt-1');
    expect(reminder.title, contains('بینک کا قرض:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('صارف کے لیے ذاتی پیغام Bank 24'));
    expect(reminder.message, contains('آخری ادائیگی کی تاریخ'));
    expect(reminder.message, contains('PKR'));
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
  });
}
