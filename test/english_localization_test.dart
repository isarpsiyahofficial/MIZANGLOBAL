import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('only Turkish and English are enabled', () {
    expect(MizanI18n.supportedLanguageTags, {'tr', 'en'});
    expect(MizanI18n.isSupported('tr'), isTrue);
    expect(MizanI18n.isSupported('en-US'), isTrue);
    expect(MizanI18n.isSupported('de'), isFalse);
    expect(MizanI18n.isSupported('fr'), isFalse);
  });

  test('English copy, dates, numbers and dynamic sentences are localized', () {
    MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');

    expect(MizanI18n.text('Ana sayfa'), 'Home');
    expect(MizanI18n.text('MİZAN Aylık Raporu'), 'MİZAN Monthly Report');
    expect(MizanI18n.text('3 gün kaldı'), '3 days remaining');
    expect(
      MizanI18n.text('Daha fazla gün göster (8 kaldı)'),
      'Show more days (8 remaining)',
    );
    expect(shortDate(DateTime(2026, 7, 31)), 'Jul 31, 2026');
    expect(monthLabel(DateTime(2026, 7)), 'July 2026');
    expect(money(1234567.5), 'USD 1,234,567.50');
    expect(decimalText(12.5), '12.50');
  });

  test(
    'user-authored text is never translated even when it matches UI copy',
    () {
      MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');

      final person = MizanI18n.user('Kira');
      final note = MizanI18n.user('Gider');
      expect(
        MizanI18n.user(person),
        person,
        reason: 'protection is idempotent',
      );
      expect(MizanI18n.text(person), 'Kira');
      expect(MizanI18n.text(note), 'Gider');
      expect(
        MizanI18n.text('$person · Kalan toplam borç'),
        'Kira · Total outstanding debt',
      );
      expect(MizanI18n.text('Not: $note'), 'Note: Gider');
    },
  );

  test('English reports use English labels and retain raw user data', () {
    final now = DateTime(2026, 7, 31, 12);
    final state = comprehensiveState(
      reference: now,
    ).copyWith(appLanguageTag: 'en', defaultCurrencyCode: 'USD');
    MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'en');
    expect(report.currencyCode, 'USD');
    expect(report.filter.period.label, 'Monthly');
    expect(report.range.label, 'July 2026');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('Expenses'),
    );
    expect(report.selectedPersonNames, contains('İbrahim'));
    expect(
      report.paymentDetails.map((item) => item.recordTitle),
      contains('Kart borcu'),
    );
    expect(
      report.selectedPersonNames.any((value) => value.contains('\u{E000}')),
      isFalse,
    );
    expect(
      report.paymentDetails.any(
        (item) =>
            item.personName.contains('\u{E000}') ||
            item.recordTitle.contains('\u{E000}') ||
            item.recordSubtitle.contains('\u{E000}'),
      ),
      isFalse,
    );
  });

  test(
    'English Android reminders localize system copy and preserve custom copy',
    () {
      final now = DateTime(2026, 7, 31, 8);
      final state = comprehensiveState(reference: now).copyWith(
        appLanguageTag: 'en',
        defaultCurrencyCode: 'USD',
        notificationSlots: const [],
        paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
        paymentNotificationSlots: const [
          NotificationSlot(
            id: 'custom-payment-slot',
            label: 'Ayarlar',
            hour: 10,
            minute: 0,
            message: 'Gider',
          ),
        ],
      );

      final reminders = const ReminderPlanBuilder().build(
        state: state,
        now: now,
      );
      expect(reminders, isNotEmpty);
      final reminder = reminders.firstWhere(
        (item) => item.sourceId == 'bank-debt-1',
      );
      expect(reminder.title, contains('Bank debt:'));
      expect(reminder.title, contains('Kart borcu'));
      expect(reminder.message, contains('Gider'));
      expect(reminder.message, contains('Due date:'));
      expect(reminder.message, contains('Remaining amount USD'));
      expect(reminder.title.contains('\u{E000}'), isFalse);
      expect(reminder.message.contains('\u{E000}'), isFalse);
      expect(reminder.title, isNot(contains('Banka borcu:')));
      expect(reminder.message, isNot(contains('Kalan tutar')));
    },
  );

  test('English destructive confirmation requires I CONFIRM', () async {
    final state = comprehensiveState().copyWith(
      appLanguageTag: 'en',
      defaultCurrencyCode: 'USD',
    );
    final controller = MizanController(
      MemoryStore(state),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    final categoryId = controller.state.expenseCategories.first.id;

    await expectLater(
      controller.deleteExpenseCategory(
        categoryId: categoryId,
        confirmation: 'ONAYLIYORUM',
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      controller.state.expenseCategories.any((item) => item.id == categoryId),
      isTrue,
    );

    await controller.deleteExpenseCategory(
      categoryId: categoryId,
      confirmation: 'I CONFIRM',
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

  testWidgets('English selection renders the main shell entirely in English', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = MizanState.empty().copyWith(
      setupCompleted: true,
      appLanguageTag: 'en',
      debtRegionCountryCode: 'US',
      defaultCurrencyCode: 'USD',
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
      final navigationFinder = find.byType(NavigationBar);
      expect(navigationFinder, findsOneWidget);
      final navigation = tester.widget<NavigationBar>(navigationFinder);
      expect(navigation.onDestinationSelected, isNotNull);
      navigation.onDestinationSelected!(index);
      await tester.pumpAndSettle();
    }

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Records'), findsWidgets);
    expect(find.text('Expenses'), findsWidgets);
    expect(find.text('Reports'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(find.text('Kayıtlar'), findsNothing);
    expect(find.text('Giderler'), findsNothing);
    expect(find.text('Raporlar'), findsNothing);
    expect(find.text('Ayarlar'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('The app is empty and ready to use'),
      300,
    );
    expect(find.text('The app is empty and ready to use'), findsOneWidget);

    await selectDestination(1);
    expect(find.text('Add person'), findsOneWidget);
    expect(find.text('Kişi ekle'), findsNothing);

    await selectDestination(2);
    expect(find.text('Add expense'), findsWidgets);
    expect(find.text('Gider ekle'), findsNothing);

    await selectDestination(3);
    expect(
      find.text(
        'Shows payments, expenses, and outstanding obligations accurately and in detail using the same filter.',
      ),
      findsOneWidget,
    );

    await selectDestination(4);
    expect(find.text('Language, country, and currency'), findsOneWidget);
    expect(find.text('Dil, ülke ve para birimi'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
