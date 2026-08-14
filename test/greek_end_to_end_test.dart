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

  test('Greek reports localize system copy and preserve linked user data', () {
    final now = DateTime(2026, 8, 1, 12);
    final state = comprehensiveState(
      reference: now,
      currencyCode: 'EUR',
    ).copyWith(
      appLanguageTag: 'el',
      debtRegionCountryCode: 'GR',
      defaultCurrencyCode: 'EUR',
    );
    MizanI18n.setProfile(languageTag: 'el', currencyCode: 'EUR');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'el');
    expect(report.currencyCode, 'EUR');
    expect(report.filter.period.label, 'Μηνιαία');
    expect(report.range.label, 'Αύγουστος 2026');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('Έξοδα'),
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
    expect(report.range.label, isNot(contains('august')));
    expect(report.range.label, isNot(contains('sierpień')));
    expect(report.range.label, isNot(contains('August')));
  });

  test('Greek reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 8, 1, 8);
    final state = comprehensiveState(
      reference: now,
      currencyCode: 'EUR',
    ).copyWith(
      appLanguageTag: 'el',
      debtRegionCountryCode: 'GR',
      defaultCurrencyCode: 'EUR',
      notificationSlots: const [],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom-payment-slot-el',
          label: 'Ρυθμίσεις',
          hour: 10,
          minute: 0,
          message: 'Προσαρμοσμένο μήνυμα πελάτη',
        ),
      ],
    );

    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    expect(reminders, isNotEmpty);
    final reminder = reminders.firstWhere(
      (item) => item.sourceId == 'bank-debt-1',
    );
    expect(reminder.title, contains('Τραπεζικό χρέος:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('Προσαρμοσμένο μήνυμα πελάτη'));
    expect(reminder.message, contains('Ημερομηνία λήξης:'));
    expect(reminder.message, contains('2.000,00\u00A0€'));
    expect(reminder.title.contains('\u{E000}'), isFalse);
    expect(reminder.message.contains('\u{E000}'), isFalse);
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.title, isNot(contains('Datorie bancară:')));
    expect(reminder.title, isNot(contains('Zadłużenie bankowe:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
    expect(reminder.message, isNot(contains('Pozostała kwota')));
  });

  test(
    'Greek destructive confirmation accepts only exact ΕΠΙΒΕΒΑΙΩΝΩ',
    () async {
      final state = comprehensiveState().copyWith(
        appLanguageTag: 'el',
        debtRegionCountryCode: 'GR',
        defaultCurrencyCode: 'EUR',
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
        'Επιβεβαιώνω',
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
        confirmation: 'ΕΠΙΒΕΒΑΙΩΝΩ',
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
