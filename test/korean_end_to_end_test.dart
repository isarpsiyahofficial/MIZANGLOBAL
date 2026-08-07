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
    'Korean report and PDF surface keep Korean language KRW and user data isolated',
    () {
      final now = DateTime(2026, 8, 7, 12);
      final state = comprehensiveState(reference: now).copyWith(
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
  test(
    'Korean notification system copy does not leak Japanese or Chinese while custom copy is preserved',
    () {
      final now = DateTime(2026, 8, 7, 8);
      final state = comprehensiveState(reference: now).copyWith(
        appLanguageTag: 'ko',
        debtRegionCountryCode: 'KR',
        defaultCurrencyCode: 'KRW',
        notificationSlots: const [],
        paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
        paymentNotificationSlots: const [
          NotificationSlot(
            id: 'custom-ko',
            label: 'Custom 24',
            hour: 10,
            minute: 0,
            message: '사용자 메시지 日本語 中文 Bank 24',
          ),
        ],
      );
      final reminder = const ReminderPlanBuilder()
          .build(state: state, now: now)
          .firstWhere((e) => e.sourceId == 'bank-debt-1');
      expect(reminder.title, contains('은행 부채:'));
      expect(reminder.title, contains('Kart borcu'));
      expect(reminder.message, contains('사용자 메시지 日本語 中文 Bank 24'));
      expect(reminder.message, contains('납부 기한'));
      expect(reminder.message, contains('KRW'));
      for (final leak in const ['銀行の負債', '银行债务', '支払い', '付款'])
        expect(
          '${reminder.title} ${reminder.message}',
          isNot(contains(leak)),
          reason: leak,
        );
    },
  );
}
