import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';
import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));
  test('Japanese report PDF language JPY and user data stay isolated', () {
    final now = DateTime(2026, 8, 7, 12);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'ja',
      debtRegionCountryCode: 'JP',
      defaultCurrencyCode: 'JPY',
    );
    MizanI18n.setProfile(languageTag: 'ja', currencyCode: 'JPY');
    final r = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );
    expect(r.languageTag, 'ja');
    expect(r.currencyCode, 'JPY');
    expect(r.filter.period.label, '毎月');
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
    expect(MizanI18n.text('PDF raporu'), 'PDFレポート');
    expect(MizanI18n.text('Kalan ödeme yükü'), '残りの支払負担');
  });
  test(
    'Japanese notifications use Japanese system copy and preserve custom Korean Chinese text',
    () {
      final now = DateTime(2026, 8, 7, 8);
      final state = comprehensiveState(reference: now).copyWith(
        appLanguageTag: 'ja',
        debtRegionCountryCode: 'JP',
        defaultCurrencyCode: 'JPY',
        notificationSlots: const [],
        paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
        paymentNotificationSlots: const [
          NotificationSlot(
            id: 'custom-ja',
            label: 'Custom 24',
            hour: 10,
            minute: 0,
            message: 'ユーザーメッセージ 한국어 中文 Bank 24',
          ),
        ],
      );
      final reminder = const ReminderPlanBuilder()
          .build(state: state, now: now)
          .firstWhere((e) => e.sourceId == 'bank-debt-1');
      expect(reminder.title, contains('銀行の借入:'));
      expect(reminder.title, contains('Kart borcu'));
      expect(reminder.message, contains('ユーザーメッセージ 한국어 中文 Bank 24'));
      expect(reminder.message, contains('支払期限'));
      expect(reminder.message, contains('JPY'));
      for (final leak in const ['은행 부채', '银行债务', '납부', '付款'])
        expect(
          '${reminder.title} ${reminder.message}',
          isNot(contains(leak)),
          reason: leak,
        );
    },
  );
}
