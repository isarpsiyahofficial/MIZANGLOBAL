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
    'Romanian reports localize system copy and preserve linked user data',
    () {
      final now = DateTime(2026, 8, 1, 12);
      final state = comprehensiveState(reference: now).copyWith(
        appLanguageTag: 'ro',
        debtRegionCountryCode: 'RO',
        defaultCurrencyCode: 'RON',
      );
      MizanI18n.setProfile(languageTag: 'ro', currencyCode: 'RON');

      final report = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
        now: now,
      );

      expect(report.languageTag, 'ro');
      expect(report.currencyCode, 'RON');
      expect(report.filter.period.label, 'Lunar');
      expect(report.range.label, 'august 2026');
      expect(
        report.realizedDistribution.map((entry) => entry.label),
        contains('Cheltuieli'),
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
      expect(report.range.label, isNot(contains('sierpień')));
      expect(report.range.label, isNot(contains('August')));
    },
  );

  test('Romanian reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 8, 1, 8);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'ro',
      debtRegionCountryCode: 'RO',
      defaultCurrencyCode: 'RON',
      notificationSlots: const [],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom-payment-slot-ro',
          label: 'Setări',
          hour: 10,
          minute: 0,
          message: 'Mesaj personalizat al clientului',
        ),
      ],
    );

    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    expect(reminders, isNotEmpty);
    final reminder = reminders.firstWhere(
      (item) => item.sourceId == 'bank-debt-1',
    );
    expect(reminder.title, contains('Datorie bancară:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('Mesaj personalizat al clientului'));
    expect(reminder.message, contains('Data scadenței:'));
    expect(reminder.message, contains('2.000,00\u00A0lei'));
    expect(reminder.title.contains('\u{E000}'), isFalse);
    expect(reminder.message.contains('\u{E000}'), isFalse);
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.title, isNot(contains('Zadłużenie bankowe:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
    expect(reminder.message, isNot(contains('Pozostała kwota')));
  });

  test(
    'Romanian destructive confirmation accepts only exact CONFIRM',
    () async {
      final state = comprehensiveState().copyWith(
        appLanguageTag: 'ro',
        debtRegionCountryCode: 'RO',
        defaultCurrencyCode: 'RON',
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
        'Confirm',
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
        confirmation: 'CONFIRM',
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
