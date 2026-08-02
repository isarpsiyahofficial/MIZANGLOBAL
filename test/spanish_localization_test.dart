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

  test('Spanish remains enabled after French integration', () {
    expect(MizanI18n.supportedLanguageTags, {
      'tr',
      'en',
      'es',
      'pt-BR',
      'pt-PT',
      'fr',
    });
    expect(MizanI18n.isSupported('es'), isTrue);
    expect(MizanI18n.isSupported('es-ES'), isTrue);
    expect(MizanI18n.isSupported('es-MX'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('es-AR'), 'es');
    expect(MizanI18n.isSupported('pt-BR'), isTrue);
    expect(MizanI18n.isSupported('pt-PT'), isTrue);
    expect(MizanI18n.isSupported('fr-FR'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('fr-CA'), 'fr');
    expect(MizanI18n.isSupported('de'), isFalse);
  });

  test('Spanish copy grammar dates numbers and currency are native', () {
    MizanI18n.setProfile(languageTag: 'es', currencyCode: 'USD');

    expect(MizanI18n.text('Ana sayfa'), 'Inicio');
    expect(MizanI18n.text('Kayıtlar'), 'Registros');
    expect(MizanI18n.text('Giderler'), 'Gastos');
    expect(MizanI18n.text('Raporlar'), 'Informes');
    expect(MizanI18n.text('Ayarlar'), 'Ajustes');
    expect(MizanI18n.text('1 gün kaldı'), 'Queda 1 día');
    expect(MizanI18n.text('3 gün kaldı'), 'Quedan 3 días');
    expect(MizanI18n.text('1 kişi seçili'), '1 persona seleccionada');
    expect(MizanI18n.text('2 kişi seçili'), '2 personas seleccionadas');
    expect(shortDate(DateTime(2026, 7, 31)), '31 jul 2026');
    expect(monthLabel(DateTime(2026, 7)), 'julio de 2026');
    expect(money(1234567.5), 'USD 1.234.567,50');
    expect(decimalText(12.5), '12,50');
    expect(MizanI18n.destructiveConfirmation, 'CONFIRMO');
  });

  test(
    'Spanish catalogs localize labels while aliases remain searchable',
    () async {
      MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('es').nameFor('es'), 'Español');
      expect(catalog.language('tr').nameFor('es'), 'Turco');
      expect(catalog.country('ES').nameFor('es'), 'España');
      expect(catalog.country('TR').nameFor('es'), 'Turquía');
      expect(catalog.currency('USD').nameFor('es'), 'dólar estadounidense');
      expect(
        catalog.languages.singleWhere((item) => item.matches('Türkçe')).code,
        'tr',
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
            .nameFor('es'),
        'dólar estadounidense',
      );
    },
  );

  test('user-authored text remains unchanged in Spanish', () {
    MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');

    final person = MizanI18n.user('Gastos');
    final note = MizanI18n.user('Ajustes');
    const rawUserText = 'Jordan / Études';
    expect(MizanI18n.user(person), person);
    expect(MizanI18n.text(person), 'Gastos');
    expect(MizanI18n.text(note), 'Ajustes');
    expect(MizanI18n.text(MizanI18n.user(rawUserText)), rawUserText);
    expect(
      MizanI18n.text('$person · Kalan toplam borç'),
      'Gastos · Deuda total pendiente',
    );
    expect(MizanI18n.text('Not: $note'), 'Nota: Ajustes');
  });

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
  });

  test('Spanish reminders localize system copy and preserve custom copy', () {
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

    final reminder = const ReminderPlanBuilder()
        .build(state: state, now: now)
        .firstWhere((item) => item.sourceId == 'bank-debt-1');
    expect(reminder.title, contains('Deuda bancaria:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('Gider'));
    expect(reminder.message, contains('Fecha de vencimiento:'));
    expect(reminder.message, contains('Importe pendiente USD'));
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.message, isNot(contains('Remaining amount')));
  });

  test('Spanish destructive confirmation requires exact CONFIRMO', () async {
    final controller = MizanController(
      MemoryStore(
        comprehensiveState().copyWith(
          appLanguageTag: 'es',
          defaultCurrencyCode: 'EUR',
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

  test('Spanish selection is wired to the complete main-shell vocabulary', () {
    MizanI18n.setProfile(languageTag: 'es', currencyCode: 'EUR');
    final mainSource = File('lib/main.dart').readAsStringSync();
    expect(mainSource, contains("Locale('es')"));

    final shellCopy = <String, String>{
      'Ana sayfa': 'Inicio',
      'Kayıtlar': 'Registros',
      'Giderler': 'Gastos',
      'Raporlar': 'Informes',
      'Ayarlar': 'Ajustes',
      'Dil, ülke ve para birimi': 'Idioma, país y moneda',
      'Kişi ekle': 'Añadir persona',
      'Gider ekle': 'Añadir gasto',
    };
    for (final entry in shellCopy.entries) {
      expect(MizanI18n.text(entry.key), entry.value, reason: entry.key);
    }
    expect(MizanI18n.text('Ana sayfa'), isNot('Home'));
    expect(MizanI18n.text('Kişi ekle'), isNot('Adicionar pessoa'));
  });
}
