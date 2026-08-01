import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/core/localized_material.dart'
    as localized;
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

  test(
    'Spanish is a fully enabled locale without enabling later languages',
    () {
      expect(MizanI18n.supportedLanguageTags, {'tr', 'en', 'es'});
      expect(MizanI18n.isSupported('es'), isTrue);
      expect(MizanI18n.isSupported('es-ES'), isTrue);
      expect(MizanI18n.isSupported('es-MX'), isTrue);
      expect(MizanI18n.normalizeLanguageTag('es-AR'), 'es');
      expect(MizanI18n.isSupported('pt-BR'), isFalse);
      expect(MizanI18n.isSupported('de'), isFalse);
    },
  );

  test('Spanish copy, grammar, dates and numbers are localized natively', () {
    MizanI18n.setProfile(languageTag: 'es', currencyCode: 'USD');

    expect(MizanI18n.text('Ana sayfa'), 'Inicio');
    expect(MizanI18n.text('MİZAN Aylık Raporu'), 'Informe mensual de MİZAN');
    expect(MizanI18n.text('1 gün kaldı'), 'Queda 1 día');
    expect(MizanI18n.text('3 gün kaldı'), 'Quedan 3 días');
    expect(
      MizanI18n.text('Daha fazla gün göster (8 kaldı)'),
      'Mostrar más días (8 restantes)',
    );
    expect(
      MizanI18n.text(
        'Bildirim planı doğrulanamadı; Android tarafında 1 kayıt eksik kaldı.',
      ),
      'No se pudo verificar el calendario de notificaciones; falta 1 registro en Android.',
    );
    expect(MizanI18n.text('1 kişi seçili'), '1 persona seleccionada');
    expect(MizanI18n.text('2 kişi seçili'), '2 personas seleccionadas');
    expect(shortDate(DateTime(2026, 7, 31)), '31 jul 2026');
    expect(monthLabel(DateTime(2026, 7)), 'julio de 2026');
    expect(money(1234567.5), 'USD 1.234.567,50');
    expect(decimalText(12.5), '12,50');
  });

  test('Spanish catalog names and searches use Spanish data', () async {
    MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
    final catalog = await GlobalCatalogRepository.load();

    expect(catalog.language('es').nameFor('es'), 'Español');
    expect(catalog.language('tr').nameFor('es'), 'Turco');
    expect(catalog.country('ES').nameFor('es'), 'España');
    expect(catalog.country('TR').nameFor('es'), 'Turquía');
    expect(catalog.currency('USD').nameFor('es'), 'dólar estadounidense');
    expect(
      catalog.languages.where((item) => item.matches('espa')).single.code,
      'es',
    );
    expect(
      catalog.countries
          .where((item) => item.matches('turqu'))
          .any((item) => item.code == 'TR'),
      isTrue,
    );
    expect(
      catalog.currencies
          .where((item) => item.matches('dólar'))
          .any((item) => item.code == 'USD'),
      isTrue,
    );
  });

  test(
    'user-authored text remains unchanged even when it matches Spanish UI copy',
    () {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');

      final person = MizanI18n.user('Gastos');
      final note = MizanI18n.user('Ajustes');
      expect(
        MizanI18n.user(person),
        person,
        reason: 'protection is idempotent',
      );
      expect(MizanI18n.text(person), 'Gastos');
      expect(MizanI18n.text(note), 'Ajustes');
      expect(
        MizanI18n.text('$person · Kalan toplam borç'),
        'Gastos · Deuda total pendiente',
      );
      expect(MizanI18n.text('Not: $note'), 'Nota: Ajustes');
    },
  );

  testWidgets(
    'Spanish localized text preserves user data matching a country name',
    (tester) async {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
      const rawUserText = 'Jordan / Études';

      expect(MizanI18n.text(MizanI18n.user(rawUserText)), rawUserText);
      expect(MizanI18n.text(MizanI18n.user('Not: Jordan')), 'Not: Jordan');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                localized.Text.user(rawUserText),
                localized.Text('Not: ${MizanI18n.user(rawUserText)}'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(rawUserText), findsOneWidget);
      expect(find.text('Nota: $rawUserText'), findsOneWidget);
      expect(find.text('Jordania / Études'), findsNothing);
      expect(find.text('Nota: Jordania / Études'), findsNothing);
    },
  );

  test('Spanish reports use Spanish labels and preserve raw user data', () {
    final now = DateTime(2026, 7, 31, 12);
    final state = comprehensiveState(
      reference: now,
    ).copyWith(appLanguageTag: 'es', defaultCurrencyCode: 'EUR');
    MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'es');
    expect(report.currencyCode, 'EUR');
    expect(report.filter.period.label, 'Mensual');
    expect(report.range.label, 'julio de 2026');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('Gastos'),
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
    'Spanish Android reminders localize system copy and preserve custom copy',
    () {
      final now = DateTime(2026, 7, 31, 8);
      final state = comprehensiveState(reference: now).copyWith(
        appLanguageTag: 'es',
        defaultCurrencyCode: 'USD',
        notificationSlots: const [],
        paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
        paymentNotificationSlots: const [
          NotificationSlot(
            id: 'custom-payment-slot-es',
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
      expect(reminder.title, contains('Deuda bancaria:'));
      expect(reminder.title, contains('Kart borcu'));
      expect(reminder.message, contains('Gider'));
      expect(reminder.message, contains('Fecha de vencimiento:'));
      expect(reminder.message, contains('Importe pendiente USD'));
      expect(reminder.title.contains('\u{E000}'), isFalse);
      expect(reminder.message.contains('\u{E000}'), isFalse);
      expect(reminder.title, isNot(contains('Banka borcu:')));
      expect(reminder.title, isNot(contains('Bank debt:')));
      expect(reminder.message, isNot(contains('Kalan tutar')));
      expect(reminder.message, isNot(contains('Remaining amount')));
    },
  );

  test('Spanish destructive confirmation requires CONFIRMO', () async {
    final state = comprehensiveState().copyWith(
      appLanguageTag: 'es',
      defaultCurrencyCode: 'EUR',
    );
    final controller = MizanController(
      MemoryStore(state),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    final categoryId = controller.state.expenseCategories.first.id;

    for (final wrong in const ['ONAYLIYORUM', 'I CONFIRM', 'confirmo']) {
      await expectLater(
        controller.deleteExpenseCategory(
          categoryId: categoryId,
          confirmation: wrong,
        ),
        throwsA(isA<ArgumentError>()),
      );
    }
    expect(
      controller.state.expenseCategories.any((item) => item.id == categoryId),
      isTrue,
    );

    await controller.deleteExpenseCategory(
      categoryId: categoryId,
      confirmation: 'CONFIRMO',
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

  testWidgets('Spanish selection renders the main shell entirely in Spanish', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = MizanState.empty().copyWith(
      setupCompleted: true,
      appLanguageTag: 'es',
      debtRegionCountryCode: 'ES',
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
      final navigationFinder = find.byType(NavigationBar);
      expect(navigationFinder, findsOneWidget);
      final navigation = tester.widget<NavigationBar>(navigationFinder);
      expect(navigation.onDestinationSelected, isNotNull);
      navigation.onDestinationSelected!(index);
      await tester.pumpAndSettle();
    }

    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Registros'), findsWidgets);
    expect(find.text('Gastos'), findsWidgets);
    expect(find.text('Informes'), findsWidgets);
    expect(find.text('Ajustes'), findsWidgets);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Kayıtlar'), findsNothing);
    expect(find.text('Records'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('La aplicación está vacía y lista para usar'),
      300,
    );
    expect(
      find.text('La aplicación está vacía y lista para usar'),
      findsOneWidget,
    );

    await selectDestination(1);
    expect(find.text('Añadir persona'), findsOneWidget);
    expect(find.text('Kişi ekle'), findsNothing);
    expect(find.text('Add person'), findsNothing);

    await selectDestination(2);
    expect(find.text('Añadir gasto'), findsWidgets);
    expect(find.text('Gider ekle'), findsNothing);
    expect(find.text('Add expense'), findsNothing);

    await selectDestination(3);
    expect(
      find.text(
        'Muestra con precisión y detalle los pagos, los gastos y las obligaciones pendientes usando el mismo filtro.',
      ),
      findsOneWidget,
    );

    await selectDestination(4);
    expect(find.text('Idioma, país y moneda'), findsOneWidget);
    expect(find.text('España · ES'), findsOneWidget);
    expect(find.text('EUR · euro'), findsOneWidget);
    expect(find.text('Dil, ülke ve para birimi'), findsNothing);
    expect(find.text('Language, country, and currency'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
