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
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Brazilian Portuguese is enabled without accepting other variants', () {
    expect(MizanI18n.supportedLanguageTags, {'tr', 'en', 'es', 'pt-BR'});
    expect(MizanI18n.isSupported('pt-BR'), isTrue);
    expect(MizanI18n.isSupported('pt_BR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('pt_BR'), 'pt-BR');
    expect(MizanI18n.normalizeLanguageTag('PT-br'), 'pt-BR');
    expect(MizanI18n.isSupported('pt'), isFalse);
    expect(MizanI18n.isSupported('pt-PT'), isFalse);
    expect(MizanI18n.normalizeLanguageTag('pt-PT'), 'tr');
    expect(MizanI18n.isSupported('de'), isFalse);
  });

  test('pt-BR copy grammar dates numbers and currency are native', () {
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');

    expect(MizanI18n.text('Ana sayfa'), 'Início');
    expect(MizanI18n.text('Kayıtlar'), 'Registros');
    expect(MizanI18n.text('Giderler'), 'Despesas');
    expect(MizanI18n.text('Raporlar'), 'Relatórios');
    expect(MizanI18n.text('Ayarlar'), 'Configurações');
    expect(MizanI18n.text('MİZAN Aylık Raporu'), 'Relatório mensal do MİZAN');
    expect(MizanI18n.text('1 gün kaldı'), 'Falta 1 dia');
    expect(MizanI18n.text('3 gün kaldı'), 'Faltam 3 dias');
    expect(
      MizanI18n.text('Fatura için 1 gün kaldı'),
      'Falta 1 dia para Fatura',
    );
    expect(
      MizanI18n.text(
        'Bildirim planı doğrulanamadı; Android tarafında 1 kayıt eksik kaldı.',
      ),
      'Não foi possível verificar a programação de notificações; falta 1 registro no Android.',
    );
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 registro novo; 1 vínculo atualizado.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      '2 registros novos foram adicionados; os dados existentes foram preservados.',
    );
    expect(MizanI18n.text('1 kişi seçili'), '1 pessoa selecionada');
    expect(MizanI18n.text('2 kişi seçili'), '2 pessoas selecionadas');
    expect(shortDate(DateTime(2026, 8, 1)), '1 ago 2026');
    expect(monthLabel(DateTime(2026, 8)), 'agosto de 2026');
    expect(money(1234567.5), r'R$ 1.234.567,50');
    expect(money(1234567.5, currencyCode: 'USD'), 'USD 1.234.567,50');
    expect(decimalText(12.5), '12,50');
    expect(MizanI18n.destructiveConfirmation, 'CONFIRMO');
  });

  test(
    'pt-BR catalog names are visible while all aliases remain searchable',
    () async {
      MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('pt-BR').nameFor('pt-BR'), 'português (Brasil)');
      expect(catalog.language('tr').nameFor('pt-BR'), 'turco');
      expect(catalog.country('BR').nameFor('pt-BR'), 'Brasil');
      expect(catalog.country('TR').nameFor('pt-BR'), 'Turquia');
      expect(catalog.currency('BRL').nameFor('pt-BR'), 'real brasileiro');
      expect(catalog.currency('USD').nameFor('pt-BR'), 'dólar americano');

      expect(
        catalog.countries
            .where((item) => item.matches('Türkiye'))
            .singleWhere((item) => item.code == 'TR')
            .nameFor('pt-BR'),
        'Turquia',
      );
      expect(
        catalog.currencies
            .where((item) => item.matches('US Dollar'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('pt-BR'),
        'dólar americano',
      );
      expect(
        catalog.languages
            .where((item) => item.matches('Türkçe'))
            .singleWhere((item) => item.code == 'tr')
            .nameFor('pt-BR'),
        'turco',
      );
    },
  );

  test('user-authored names and notes are never translated in pt-BR', () {
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');

    final person = MizanI18n.user('Configurações');
    final bank = MizanI18n.user('Türkiye Bankası');
    final note = MizanI18n.user('Not: Relatórios');
    expect(MizanI18n.user(person), person, reason: 'protection is idempotent');
    expect(MizanI18n.text(person), 'Configurações');
    expect(MizanI18n.text(bank), 'Türkiye Bankası');
    expect(MizanI18n.text(note), 'Not: Relatórios');
    expect(
      MizanI18n.text('$person · Kalan toplam borç'),
      'Configurações · Dívida total restante',
    );
    expect(MizanI18n.text('Not: $bank'), 'Nota: Türkiye Bankası');
  });

  test('pt-BR reports localize system copy and preserve linked user data', () {
    final now = DateTime(2026, 8, 1, 12);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'pt-BR',
      debtRegionCountryCode: 'BR',
      defaultCurrencyCode: 'BRL',
    );
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'pt-BR');
    expect(report.currencyCode, 'BRL');
    expect(report.filter.period.label, 'Mensal');
    expect(report.range.label, 'agosto de 2026');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('Despesas'),
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

  test('pt-BR reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 8, 1, 8);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'pt-BR',
      defaultCurrencyCode: 'BRL',
      notificationSlots: const [],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom-payment-slot-pt-br',
          label: 'Configurações',
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
    expect(reminder.message, contains('Valor restante BRL'));
    expect(reminder.title.contains('\u{E000}'), isFalse);
    expect(reminder.message.contains('\u{E000}'), isFalse);
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.title, isNot(contains('Bank debt:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
    expect(reminder.message, isNot(contains('Remaining amount')));
  });

  test('pt-BR destructive confirmation accepts only exact CONFIRMO', () async {
    final state = comprehensiveState().copyWith(
      appLanguageTag: 'pt-BR',
      debtRegionCountryCode: 'BR',
      defaultCurrencyCode: 'BRL',
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

  testWidgets('pt-BR selection renders the main shell without foreign copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = MizanState.empty().copyWith(
      setupCompleted: true,
      appLanguageTag: 'pt-BR',
      debtRegionCountryCode: 'BR',
      defaultCurrencyCode: 'BRL',
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
    }

    expect(find.text('Início'), findsWidgets);
    expect(find.text('Registros'), findsWidgets);
    expect(find.text('Despesas'), findsWidgets);
    expect(find.text('Relatórios'), findsWidgets);
    expect(find.text('Configurações'), findsWidgets);
    expect(find.text('Ana sayfa'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Inicio'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('O aplicativo está vazio e pronto para uso'),
      300,
    );
    expect(
      find.text('O aplicativo está vazio e pronto para uso'),
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
    expect(find.text('Brasil · BR'), findsOneWidget);
    expect(find.text('BRL · real brasileiro'), findsOneWidget);
    expect(find.text('Dil, ülke ve para birimi'), findsNothing);
    expect(find.text('Language, country, and currency'), findsNothing);
    expect(find.text('Idioma, país y moneda'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
