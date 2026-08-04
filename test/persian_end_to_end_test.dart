import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Persian reports localize system copy and preserve linked user data', () {
    final now = DateTime(2026, 8, 1, 12);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'fa',
      debtRegionCountryCode: 'IR',
      defaultCurrencyCode: 'IRR',
    );
    MizanI18n.setProfile(languageTag: 'fa', currencyCode: 'IRR');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'fa');
    expect(report.currencyCode, 'IRR');
    expect(report.filter.period.label, 'ماهانه');
    expect(report.range.label, 'اوت ۲۰۲۶');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('هزینه‌ها'),
    );
    expect(
      report.selectedPersonNames.any((value) => value.contains('İbrahim')),
      isTrue,
    );
    expect(
      report.remainingDetails.any((item) => item.title.contains('Kart borcu')),
      isTrue,
    );
    expect(report.selectedPersonNames.any((value) => value.contains('\u{E000}')), isFalse);
    expect(
      report.remainingDetails.any(
        (item) => item.title.contains('\u{E000}') || item.subtitle.contains('\u{E000}'),
      ),
      isFalse,
    );
    expect(report.range.label, isNot(contains('Ağustos')));
    expect(report.range.label, isNot(contains('أغسطس')));
    expect(report.range.label, isNot(contains('август')));
  });

  test('Persian reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 8, 1, 8);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'fa',
      debtRegionCountryCode: 'IR',
      defaultCurrencyCode: 'IRR',
      notificationSlots: const [],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom-payment-slot-fa',
          label: 'Custom Slot 24',
          hour: 10,
          minute: 0,
          message: 'پیام اختصاصی مشتری Bank 24',
        ),
      ],
    );

    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    expect(reminders, isNotEmpty);
    final reminder = reminders.firstWhere((item) => item.sourceId == 'bank-debt-1');
    expect(reminder.title, contains('بدهی بانکی:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('پیام اختصاصی مشتری Bank 24'));
    expect(reminder.message, contains('تاریخ سررسید:'));
    expect(reminder.message, contains('۲٬۰۰۰٫۰۰\u00A0ریال'));
    expect(reminder.title.contains('\u{E000}'), isFalse);
    expect(reminder.message.contains('\u{E000}'), isFalse);
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.title, isNot(contains('دين بنكي:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
    expect(reminder.message, isNot(contains('المبلغ المتبقي')));
  });

  test('Persian destructive confirmation accepts only exact phrase', () async {
    final state = comprehensiveState().copyWith(
      appLanguageTag: 'fa',
      debtRegionCountryCode: 'IR',
      defaultCurrencyCode: 'IRR',
    );
    final controller = MizanController(MemoryStore(state), scheduler: SpyScheduler());
    await controller.load();
    final categoryId = controller.state.expenseCategories.first.id;

    for (final wrong in const [
      'ONAYLIYORUM',
      'I CONFIRM',
      'CONFIRMO',
      'JE CONFIRME',
      'ICH BESTÄTIGE',
      'CONFERMO',
      'POTWIERDZAM',
      'CONFIRM',
      'ΕΠΙΒΕΒΑΙΩΝΩ',
      'ПОДТВЕРЖДАЮ',
      'ПІДТВЕРДЖУЮ',
      'أؤكد',
      'تایید میکنم',
    ]) {
      await expectLater(
        controller.deleteExpenseCategory(
          categoryId: categoryId,
          confirmation: wrong,
        ),
        throwsA(isA<ArgumentError>()),
      );
    }

    await controller.deleteExpenseCategory(
      categoryId: categoryId,
      confirmation: 'تأیید می‌کنم',
    );
    expect(controller.state.expenseCategories.any((item) => item.id == categoryId), isFalse);
    expect(controller.state.expenses.any((item) => item.categoryId == categoryId), isFalse);
  });
}
