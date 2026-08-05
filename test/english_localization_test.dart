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

  test('English remains enabled after Hindi integration', () {
    expect(MizanI18n.supportedLanguageTags, {
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
    });
    expect(MizanI18n.isSupported('tr'), isTrue);
    expect(MizanI18n.isSupported('en-US'), isTrue);
    expect(MizanI18n.isSupported('es-MX'), isTrue);
    expect(MizanI18n.isSupported('pt-BR'), isTrue);
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

  test('English copy dates numbers and dynamic sentences are localized', () {
    MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');

    expect(MizanI18n.text('Ana sayfa'), 'Home');
    expect(MizanI18n.text('Kayıtlar'), 'Records');
    expect(MizanI18n.text('Giderler'), 'Expenses');
    expect(MizanI18n.text('Raporlar'), 'Reports');
    expect(MizanI18n.text('Ayarlar'), 'Settings');
    expect(MizanI18n.text('1 gün kaldı'), '1 day remaining');
    expect(MizanI18n.text('3 gün kaldı'), '3 days remaining');
    expect(MizanI18n.text('1 gün gecikmede'), '1 day overdue');
    expect(MizanI18n.text('4 gün gecikmede'), '4 days overdue');
    expect(MizanI18n.text('Ödeme 1 gün gecikti.'), 'Payment is 1 day overdue.');
    expect(
      MizanI18n.text('Ödeme 2 gün gecikti.'),
      'Payment is 2 days overdue.',
    );
    expect(MizanI18n.text('1 kayıt'), '1 record');
    expect(MizanI18n.text('2 kayıt'), '2 records');
    expect(MizanI18n.text('1 ödeme'), '1 payment');
    expect(MizanI18n.text('2 ödeme'), '2 payments');
    expect(MizanI18n.text('1 gider'), '1 expense');
    expect(MizanI18n.text('2 gider'), '2 expenses');
    expect(MizanI18n.text('1 gün'), '1 day');
    expect(MizanI18n.text('2 gün'), '2 days');
    expect(MizanI18n.text('1 ay'), '1 month');
    expect(MizanI18n.text('2 ay'), '2 months');
    expect(MizanI18n.text('1 kişi seçili'), '1 person selected');
    expect(MizanI18n.text('2 kişi seçili'), '2 people selected');
    expect(
      MizanI18n.text('1 yeni kayıt eklendi; mevcut veriler korundu.'),
      '1 new record was added; existing data was preserved.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      '2 new records were added; existing data was preserved.',
    );
    expect(shortDate(DateTime(2026, 7, 31)), 'Jul 31, 2026');
    expect(monthLabel(DateTime(2026, 7)), 'July 2026');
    expect(money(1234567.5), 'USD 1,234,567.50');
    expect(decimalText(12.5), '12.50');
    expect(MizanI18n.destructiveConfirmation, 'I CONFIRM');
  });

  test(
    'English catalogs localize labels while aliases remain searchable',
    () async {
      MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('en').nameFor('en'), 'English');
      expect(catalog.language('tr').nameFor('en'), 'Turkish');
      expect(catalog.country('US').nameFor('en'), 'United States');
      expect(catalog.country('TR').nameFor('en'), 'Türkiye');
      expect(catalog.currency('USD').nameFor('en'), 'US Dollar');
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
            .nameFor('en'),
        'US Dollar',
      );
    },
  );

  test('user-authored text is never translated in English', () {
    MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');

    final person = MizanI18n.user('Kira');
    final note = MizanI18n.user('Gider');
    expect(MizanI18n.user(person), person);
    expect(MizanI18n.text(person), 'Kira');
    expect(MizanI18n.text(note), 'Gider');
    expect(
      MizanI18n.text('$person · Kalan toplam borç'),
      'Kira · Total outstanding debt',
    );
    expect(MizanI18n.text('Not: $note'), 'Note: Gider');
  });

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
  });

  test('English reminders localize system copy and preserve custom copy', () {
    final now = DateTime(2026, 7, 31, 8);
    final state = comprehensiveState(reference: now).copyWith(
      appLanguageTag: 'en',
      defaultCurrencyCode: 'USD',
      notificationSlots: const [],
      paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
      paymentNotificationSlots: const [
        NotificationSlot(
          id: 'custom-payment-slot-en',
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
    expect(reminder.title, contains('Bank debt:'));
    expect(reminder.title, contains('Kart borcu'));
    expect(reminder.message, contains('Gider'));
    expect(reminder.message, contains('Due date:'));
    expect(reminder.message, contains('Remaining amount USD'));
    expect(reminder.title, isNot(contains('Banka borcu:')));
    expect(reminder.message, isNot(contains('Kalan tutar')));
  });

  test('English destructive confirmation requires exact I CONFIRM', () async {
    final controller = MizanController(
      MemoryStore(
        comprehensiveState().copyWith(
          appLanguageTag: 'en',
          defaultCurrencyCode: 'USD',
        ),
      ),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    final categoryId = controller.state.expenseCategories.first.id;

    for (final wrong in const ['ONAYLIYORUM', 'CONFIRMO', 'i confirm']) {
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
    controller.dispose();
  });

  test('English selection is wired to the complete main-shell vocabulary', () {
    MizanI18n.setProfile(languageTag: 'en', currencyCode: 'USD');
    final mainSource = File('lib/main.dart').readAsStringSync();
    expect(mainSource, contains("Locale('en')"));

    final shellCopy = <String, String>{
      'Ana sayfa': 'Home',
      'Kayıtlar': 'Records',
      'Giderler': 'Expenses',
      'Raporlar': 'Reports',
      'Ayarlar': 'Settings',
      'Dil, ülke ve para birimi': 'Language, country, and currency',
      'Kişi ekle': 'Add person',
      'Gider ekle': 'Add expense',
    };
    for (final entry in shellCopy.entries) {
      expect(MizanI18n.text(entry.key), entry.value, reason: entry.key);
    }
    expect(MizanI18n.text('Ana sayfa'), isNot('Inicio'));
    expect(MizanI18n.text('Kişi ekle'), isNot('Ajouter une personne'));
  });
}
