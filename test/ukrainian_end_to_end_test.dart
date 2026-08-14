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

  test(
    'Ukrainian reports localize system copy and preserve linked user data',
    () {
      final now = DateTime(2026, 8, 1, 12);
      final state = comprehensiveState(reference: now, currencyCode: 'UAH')
          .copyWith(
            appLanguageTag: 'uk',
            debtRegionCountryCode: 'UA',
            defaultCurrencyCode: 'UAH',
          );
      MizanI18n.setProfile(languageTag: 'uk', currencyCode: 'UAH');

      final report = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
        now: now,
      );

      expect(report.languageTag, 'uk');
      expect(report.currencyCode, 'UAH');
      expect(report.filter.period.label, 'Щомісяця');
      expect(report.range.label, 'серпень 2026');
      expect(
        report.realizedDistribution.map((entry) => entry.label),
        contains('Витрати'),
      );
      expect(report.selectedPersonNames, contains('İbrahim'));
      expect(
        report.remainingDetails.map((item) => item.title),
        contains('Kart borcu'),
      );
      expect(
        report.selectedPersonNames.any((value) => value.contains('\u{E000}')),
        isFalse,
      );
      expect(
        report.remainingDetails.any(
          (item) =>
              item.title.contains('\u{E000}') ||
              item.subtitle.contains('\u{E000}'),
        ),
        isFalse,
      );
      expect(report.range.label, isNot(contains('август')));
      expect(report.range.label, isNot(contains('sierpień')));
      expect(report.range.label, isNot(contains('August')));
    },
  );

  test('Ukrainian reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 8, 1, 8);
    final state = comprehensiveState(reference: now, currencyCode: 'UAH')
        .copyWith(
          appLanguageTag: 'uk',
          debtRegionCountryCode: 'UA',
          defaultCurrencyCode: 'UAH',
          notificationSlots: const [],
          paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
          paymentNotificationSlots: const [
            NotificationSlot(
              id: 'custom-payment-slot-uk',
              label: 'Налаштування',
              hour: 10,
              minute: 0,
              message: 'Власне повідомлення клієнта',
            ),
          ],
        );

    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    expect(reminders, isNotEmpty);
    final reminder = reminders.firstWhere(
      (item) => item.sourceId == 'bank-debt-1',
    );
    expect(reminder.title, contains('Банківський борг:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('Власне повідомлення клієнта'));
    expect(reminder.message, contains('Строк оплати:'));
    expect(reminder.message, contains('2\u00A0000,00\u00A0₴'));
    expect(reminder.title.contains('\u{E000}'), isFalse);
    expect(reminder.message.contains('\u{E000}'), isFalse);
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.title, isNot(contains('Банковский долг:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
    expect(reminder.message, isNot(contains('Оставшаяся сумма')));
  });

  test(
    'Ukrainian destructive confirmation accepts only exact ПІДТВЕРДЖУЮ',
    () async {
      final state = comprehensiveState().copyWith(
        appLanguageTag: 'uk',
        debtRegionCountryCode: 'UA',
        defaultCurrencyCode: 'UAH',
      );
      final controller = MizanController(
        MemoryStore(state),
        scheduler: SpyScheduler(),
      );
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
        confirmation: 'ПІДТВЕРДЖУЮ',
      );
      expect(
        controller.state.expenseCategories.any((item) => item.id == categoryId),
        isFalse,
      );
      expect(
        controller.state.expenses.any((item) => item.categoryId == categoryId),
        isFalse,
      );
    },
  );
}
