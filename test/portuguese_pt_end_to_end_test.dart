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

  test('pt-PT dynamic grammar uses European Portuguese singular and plural', () {
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');

    expect(MizanI18n.text('1 gün kaldı'), 'Falta 1 dia');
    expect(MizanI18n.text('3 gün kaldı'), 'Faltam 3 dias');
    expect(MizanI18n.text('1 kişi seçili'), '1 pessoa selecionada');
    expect(MizanI18n.text('2 kişi seçili'), '2 pessoas selecionadas');
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 registo novo; 1 ligação atualizada.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      '2 registos novos foram adicionados; os dados existentes foram preservados.',
    );
  });

  test('pt-PT reports localize system copy and preserve linked user data', () {
    final now = DateTime(2026, 8, 1, 12);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'pt-PT',
      debtRegionCountryCode: 'PT',
      defaultCurrencyCode: 'EUR',
    );
    MizanI18n.setProfile(languageTag: 'pt-PT', currencyCode: 'EUR');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'pt-PT');
    expect(report.currencyCode, 'EUR');
    expect(report.filter.period.label, 'Mensal');
    expect(report.range.label, 'agosto de 2026');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('Despesas'),
    );
    expect(report.selectedPersonNames, contains('İbrahim'));
    expect(report.paymentDetails, isEmpty);
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

  test('pt-PT reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 8, 1, 8);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'pt-PT',
      debtRegionCountryCode: 'PT',
      defaultCurrencyCode: 'EUR',
      notificationSlots: const [],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom-payment-slot-pt-pt',
          label: 'Definições',
          hour: 10,
          minute: 0,
          message: 'Despesa personalizada',
        ),
      ],
    );

    final reminders = const ReminderPlanBuilder().build(state: state, now: now);
    expect(reminders, isNotEmpty);
    final reminder = reminders.firstWhere(
      (item) => item.sourceId == 'bank-debt-1',
    );
    expect(reminder.title, contains('Dívida bancária:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('Despesa personalizada'));
    expect(reminder.message, contains('Data de vencimento:'));
    expect(reminder.message, contains('Valor restante 2 000,00 €'));
    expect(reminder.title.contains('\u{E000}'), isFalse);
    expect(reminder.message.contains('\u{E000}'), isFalse);
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.title, isNot(contains('Bank debt:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
    expect(reminder.message, isNot(contains('Remaining amount')));
  });

  test('pt-PT destructive confirmation accepts only exact CONFIRMO', () async {
    final state = comprehensiveState().copyWith(
      appLanguageTag: 'pt-PT',
      debtRegionCountryCode: 'PT',
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
    controller.dispose();
  });

  testWidgets('pt-PT selection renders the main shell without foreign copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> renderFrame() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    }

    final state = MizanState.empty().copyWith(
      setupCompleted: true,
      appLanguageTag: 'pt-PT',
      debtRegionCountryCode: 'PT',
      defaultCurrencyCode: 'EUR',
    );
    final controller = MizanController(
      MemoryStore(state),
      scheduler: SpyScheduler(),
    );
    final catalog = await GlobalCatalogRepository.load();
    await controller.load();
    await tester.pumpWidget(MizanApp(controller: controller, catalog: catalog));
    await renderFrame();

    Future<void> selectDestination(int index) async {
      final finder = find.byType(NavigationBar);
      expect(finder, findsOneWidget);
      final navigation = tester.widget<NavigationBar>(finder);
      navigation.onDestinationSelected!(index);
      await renderFrame();
    }

    expect(find.text('Início'), findsWidgets);
    expect(find.text('Registos'), findsWidgets);
    expect(find.text('Despesas'), findsWidgets);
    expect(find.text('Relatórios'), findsWidgets);
    expect(find.text('Definições'), findsWidgets);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Configurações'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('A aplicação está vazia e pronta a utilizar'),
      300,
    );
    await renderFrame();
    expect(
      find.text('A aplicação está vazia e pronta a utilizar'),
      findsOneWidget,
    );

    await selectDestination(1);
    expect(find.text('Adicionar pessoa'), findsOneWidget);
    expect(find.text('Kişi ekle'), findsNothing);
    expect(find.text('Add person'), findsNothing);
    expect(find.text('Añadir persona'), findsNothing);

    await selectDestination(2);
    expect(find.text('Adicionar despesa'), findsWidgets);
    expect(find.text('Gider ekle'), findsNothing);
    expect(find.text('Add expense'), findsNothing);
    expect(find.text('Añadir gasto'), findsNothing);

    await selectDestination(4);
    expect(find.text('Idioma, país e moeda'), findsOneWidget);
    expect(find.text('Portugal · PT'), findsOneWidget);
    expect(find.text('EUR · euro'), findsOneWidget);
    expect(find.text('Dil, ülke ve para birimi'), findsNothing);
    expect(find.text('Language, country, and currency'), findsNothing);
    expect(find.text('Idioma, país y moneda'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    controller.dispose();
  });
}
