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

  test('Dutch reports localize system copy and preserve linked user data', () {
    final now = DateTime(2026, 8, 1, 12);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'nl',
      debtRegionCountryCode: 'NL',
      defaultCurrencyCode: 'EUR',
    );
    MizanI18n.setProfile(languageTag: 'nl', currencyCode: 'EUR');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'nl');
    expect(report.currencyCode, 'EUR');
    expect(report.filter.period.label, 'Maandelijks');
    expect(report.range.label, 'augustus 2026');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('Uitgaven'),
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
    expect(report.range.label, isNot(contains('agosto')));
    expect(report.range.label, isNot(contains('August')));
  });

  test('Dutch reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 8, 1, 8);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'nl',
      debtRegionCountryCode: 'NL',
      defaultCurrencyCode: 'EUR',
      notificationSlots: const [],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom-payment-slot-nl',
          label: 'Instellingen',
          hour: 10,
          minute: 0,
          message: 'Aangepast bericht van de klant',
        ),
      ],
    );

    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    expect(reminders, isNotEmpty);
    final reminder = reminders.firstWhere(
      (item) => item.sourceId == 'bank-debt-1',
    );
    expect(reminder.title, contains('Bankschuld:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('Aangepast bericht van de klant'));
    expect(reminder.message, contains('Vervaldatum:'));
    expect(reminder.message, contains('€\u00A02.000,00'));
    expect(reminder.title.contains('\u{E000}'), isFalse);
    expect(reminder.message.contains('\u{E000}'), isFalse);
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.title, isNot(contains('Debito bancario:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
    expect(reminder.message, isNot(contains('Importo residuo')));
  });

  test(
    'Dutch destructive confirmation accepts only exact IK BEVESTIG',
    () async {
      final state = comprehensiveState().copyWith(
        appLanguageTag: 'nl',
        debtRegionCountryCode: 'NL',
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
        'Ik bevestig',
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
        confirmation: 'IK BEVESTIG',
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
