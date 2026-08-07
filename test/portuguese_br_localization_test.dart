import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
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

  test('Brazilian Portuguese remains enabled after Hindi integration', () {
    expect(
      MizanI18n.supportedLanguageTags,
      containsAll({
        'tr',
        'en',
        'es',
        'pt-BR',
        'pt-PT',
        'fr',
        'de',
        'it',
        'nl',
        'pl',
        'ro',
        'el',
        'ru',
        'uk',
        'ar',
        'fa',
        'he',
        'hi',
        'bn',
      }),
    );
    expect(MizanI18n.isSupported('pt-BR'), isTrue);
    expect(MizanI18n.isSupported('pt_BR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('PT-br'), 'pt-BR');
    expect(MizanI18n.isSupported('pt'), isFalse);
    expect(MizanI18n.isSupported('pt-PT'), isTrue);
    expect(MizanI18n.isSupported('fr-FR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('fr-CA'), 'fr');
    expect(MizanI18n.isSupported('de'), isTrue);
    expect(MizanI18n.isSupported('de-DE'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('de-AT'), 'de');
    expect(MizanI18n.isSupported('it'), isTrue);
    expect(MizanI18n.isSupported('it-IT'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('it-CH'), 'it');
    expect(MizanI18n.isSupported('nl'), isTrue);
    expect(MizanI18n.isSupported('nl-NL'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('nl-BE'), 'nl');
    expect(MizanI18n.isSupported('pl'), isTrue);
    expect(MizanI18n.isSupported('pl-PL'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('pl_PL'), 'pl');
    expect(MizanI18n.isSupported('ro'), isTrue);
    expect(MizanI18n.isSupported('ro-RO'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('ro_RO'), 'ro');
    expect(MizanI18n.isSupported('el'), isTrue);
    expect(MizanI18n.isSupported('el-GR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('el_GR'), 'el');
    expect(MizanI18n.isSupported('ru'), isTrue);
    expect(MizanI18n.isSupported('ru-RU'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('ru_RU'), 'ru');
    expect(MizanI18n.isSupported('fa'), isTrue);
    expect(MizanI18n.isSupported('fa-IR'), isTrue);
    expect(MizanI18n.isSupported('he'), isTrue);
    expect(MizanI18n.isSupported('he-IL'), isTrue);
    expect(MizanI18n.isSupported('iw-IL'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('he_IL'), 'he');
    expect(MizanI18n.normalizeLanguageTag('iw_IL'), 'he');
    expect(MizanI18n.isSupported('hi'), isTrue);
    expect(MizanI18n.isSupported('hi-IN'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('hi_IN'), 'hi');
    expect(MizanI18n.normalizeLanguageTag('fa_AF'), 'fa');
  });

  test('pt-BR copy grammar dates numbers and currency are native', () {
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');

    expect(MizanI18n.text('Ana sayfa'), 'Início');
    expect(MizanI18n.text('Kayıtlar'), 'Registros');
    expect(MizanI18n.text('Giderler'), 'Despesas');
    expect(MizanI18n.text('Raporlar'), 'Relatórios');
    expect(MizanI18n.text('Ayarlar'), 'Configurações');
    expect(MizanI18n.text('1 gün kaldı'), 'Falta 1 dia');
    expect(MizanI18n.text('3 gün kaldı'), 'Faltam 3 dias');
    expect(MizanI18n.text('1 kişi seçili'), '1 pessoa selecionada');
    expect(MizanI18n.text('2 kişi seçili'), '2 pessoas selecionadas');
    expect(shortDate(DateTime(2026, 8, 1)), '1 ago 2026');
    expect(monthLabel(DateTime(2026, 8)), 'agosto de 2026');
    expect(money(1234567.5), r'R$ 1.234.567,50');
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'USD');
    expect(money(1234567.5), 'USD 1.234.567,50');
    expect(decimalText(12.5), '12,50');
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');
    expect(MizanI18n.destructiveConfirmation, 'CONFIRMO');
  });

  test(
    'pt-BR catalogs localize labels while aliases remain searchable',
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
        catalog.countries.singleWhere((item) => item.matches('Türkiye')).code,
        'TR',
      );
      expect(
        catalog.countries
            .singleWhere((item) => item.matches('Deutschland'))
            .code,
        'DE',
      );
      expect(
        catalog.currencies
            .singleWhere(
              (item) => item.code == 'USD' && item.matches('US Dollar'),
            )
            .nameFor('pt-BR'),
        'dólar americano',
      );
    },
  );

  test('user-authored names and notes are never translated in pt-BR', () {
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');

    final person = MizanI18n.user('Configurações');
    final bank = MizanI18n.user('Türkiye Bankası');
    final note = MizanI18n.user('Not: Relatórios');
    expect(MizanI18n.user(person), person);
    expect(MizanI18n.text(person), 'Configurações');
    expect(MizanI18n.text(bank), 'Türkiye Bankası');
    expect(MizanI18n.text(note), 'Not: Relatórios');
    expect(
      MizanI18n.text('$person · Kalan toplam borç'),
      'Configurações · Dívida total restante',
    );
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
      report.remainingDetails.map((item) => item.title),
      contains('Kart borcu'),
    );
    expect(
      report.selectedPersonNames.any((value) => value.contains('\u{E000}')),
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

    final reminder = const ReminderPlanBuilder()
        .build(state: state, now: now)
        .firstWhere((item) => item.sourceId == 'bank-debt-1');
    expect(reminder.title, contains('Dívida bancária:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('Despesa personalizada'));
    expect(reminder.message, contains('Data de vencimento:'));
    expect(reminder.message, contains(r'Valor restante R$ 2.000,00'));
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.message, isNot(contains('Remaining amount')));
  });

  test('pt-BR destructive confirmation accepts only exact CONFIRMO', () async {
    final controller = MizanController(
      MemoryStore(
        comprehensiveState().copyWith(
          appLanguageTag: 'pt-BR',
          debtRegionCountryCode: 'BR',
          defaultCurrencyCode: 'BRL',
        ),
      ),
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

  test('pt-BR selection is wired to the complete main-shell vocabulary', () {
    MizanI18n.setProfile(languageTag: 'pt-BR', currencyCode: 'BRL');
    final mainSource = File('lib/main.dart').readAsStringSync();
    expect(mainSource, contains("'pt-BR' => const Locale('pt', 'BR')"));
    expect(mainSource, contains("Locale('pt', 'BR')"));

    final shellCopy = <String, String>{
      'Ana sayfa': 'Início',
      'Kayıtlar': 'Registros',
      'Giderler': 'Despesas',
      'Raporlar': 'Relatórios',
      'Ayarlar': 'Configurações',
      'Dil, ülke ve para birimi': 'Idioma, país e moeda',
      'Kişi ekle': 'Adicionar pessoa',
      'Gider ekle': 'Adicionar despesa',
    };
    for (final entry in shellCopy.entries) {
      expect(MizanI18n.text(entry.key), entry.value, reason: entry.key);
    }
    expect(MizanI18n.text('Ana sayfa'), isNot('Home'));
    expect(MizanI18n.text('Kişi ekle'), isNot('Añadir persona'));
  });
}
