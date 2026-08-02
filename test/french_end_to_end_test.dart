import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('French reports localize system copy and preserve linked user data', () {
    final now = DateTime(2026, 8, 1, 12);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'fr',
      debtRegionCountryCode: 'FR',
      defaultCurrencyCode: 'EUR',
    );
    MizanI18n.setProfile(languageTag: 'fr', currencyCode: 'EUR');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'fr');
    expect(report.currencyCode, 'EUR');
    expect(report.filter.period.label, 'Mensuel');
    expect(report.range.label, 'août 2026');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('Dépenses'),
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
  });

  test('French reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 8, 1, 8);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'fr',
      debtRegionCountryCode: 'FR',
      defaultCurrencyCode: 'EUR',
      notificationSlots: const [],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom-payment-slot-fr',
          label: 'Paramètres',
          hour: 10,
          minute: 0,
          message: 'Message client personnalisé',
        ),
      ],
    );

    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    expect(reminders, isNotEmpty);
    final reminder = reminders.firstWhere(
      (item) => item.sourceId == 'bank-debt-1',
    );
    expect(reminder.title, contains('Dette bancaire:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('Message client personnalisé'));
    expect(reminder.message, contains('Échéance :'));
    expect(reminder.message, contains('Montant restant 2\u202F000,00\u00A0€'));
    expect(reminder.title.contains('\u{E000}'), isFalse);
    expect(reminder.message.contains('\u{E000}'), isFalse);
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.title, isNot(contains('Bank debt:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
    expect(reminder.message, isNot(contains('Remaining amount')));
  });

  test('French destructive confirmation accepts only exact JE CONFIRME', () async {
    final state = comprehensiveState().copyWith(
      appLanguageTag: 'fr',
      debtRegionCountryCode: 'FR',
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
      'Je confirme',
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
      confirmation: 'JE CONFIRME',
    );
    expect(
      controller.state.expenseCategories.any((item) => item.id == categoryId),
      isFalse,
    );
    expect(
      controller.state.expenses.any((item) => item.categoryId == categoryId),
      isFalse,
    );
  });

  testWidgets(
    'French renders all primary destinations at 320 px and 1.4x text without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.4;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final state = MizanState.empty().copyWith(
        setupCompleted: true,
        appLanguageTag: 'fr',
        debtRegionCountryCode: 'FR',
        defaultCurrencyCode: 'EUR',
      );
      final controller = MizanController(
        MemoryStore(state),
        scheduler: SpyScheduler(),
      );
      final catalog = await GlobalCatalogRepository.load();
      await controller.load();
      await tester.pumpWidget(MizanApp(controller: controller, catalog: catalog));
      await tester.pumpAndSettle();

      Future<void> selectDestination(int index) async {
        final finder = find.byType(NavigationBar);
        expect(finder, findsOneWidget);
        final navigation = tester.widget<NavigationBar>(finder);
        navigation.onDestinationSelected!(index);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      expect(find.text('Accueil'), findsWidgets);
      expect(find.text('Dossiers'), findsWidgets);
      expect(find.text('Dépenses'), findsWidgets);
      expect(find.text('Rapports'), findsWidgets);
      expect(find.text('Paramètres'), findsWidgets);
      expect(find.text('Ana sayfa'), findsNothing);
      expect(find.text('Home'), findsNothing);
      expect(tester.takeException(), isNull);

      for (var index = 0; index < 5; index++) {
        await selectDestination(index);
      }

      await selectDestination(1);
      expect(find.text('Ajouter une personne'), findsOneWidget);
      await selectDestination(2);
      expect(find.text('Ajouter une dépense'), findsWidgets);
      await selectDestination(4);
      expect(find.text('Langue, pays et devise'), findsOneWidget);
      expect(find.text('France · FR'), findsOneWidget);
      expect(find.text('EUR · euro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
