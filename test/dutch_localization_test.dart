import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_nl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Dutch source contains exactly 791 reviewed static values', () {
    expect(mizanDutch.length, 791);
    expect(mizanDutch.values.every((value) => value.trim().isNotEmpty), isTrue);
  });

  test('Dutch is enabled and regional aliases resolve to it', () {
    expect(MizanI18n.isSupported('nl'), isTrue);
    expect(MizanI18n.isSupported('nl-NL'), isTrue);
    expect(MizanI18n.isSupported('nl_BE'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('NL_nl'), 'nl');
  });

  test('Dutch uses Netherlands-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'nl', currencyCode: 'EUR');

    expect(MizanI18n.text('Ana sayfa'), 'Overzicht');
    expect(MizanI18n.text('Kayıtlar'), 'Registraties');
    expect(MizanI18n.text('Ayarlar'), 'Instellingen');
    expect(MizanI18n.text('Kaydet'), 'Opslaan');
    expect(MizanI18n.text('Sil'), 'Verwijderen');
    expect(MizanI18n.text('Gelir'), 'Inkomst');
    expect(MizanI18n.text('Abonelik'), 'Abonnement');
    expect(MizanI18n.text('Ev kredisi'), 'Hypotheek');
    expect(MizanI18n.text('KMH hesabı'), 'Rekening met roodstand');
    expect(MizanI18n.text('Senet'), 'Schuldbekentenis');
    expect(MizanI18n.destructiveConfirmation, 'IK BEVESTIG');
  });

  test('Dutch dynamic copy applies singular and plural forms', () {
    MizanI18n.setProfile(languageTag: 'nl', currencyCode: 'EUR');

    expect(MizanI18n.text('1 gün kaldı'), 'Nog 1 dag');
    expect(MizanI18n.text('3 gün kaldı'), 'Nog 3 dagen');
    expect(
      MizanI18n.text('Huur için 1 gün kaldı'),
      'Nog 1 dag tot Huur',
    );
    expect(
      MizanI18n.text('Huur için 2 gün kaldı'),
      'Nog 2 dagen tot Huur',
    );
    expect(MizanI18n.text('Ayın 1. günü'), 'Dag 1 van de maand');
    expect(MizanI18n.text('Her ayın 2. günü'), 'Dag 2 van elke maand');
    expect(MizanI18n.text('1 kişi seçili'), '1 persoon geselecteerd');
    expect(MizanI18n.text('2 kişi seçili'), '2 personen geselecteerd');
    expect(
      MizanI18n.text('1 açık kayıt · EUR 20'),
      '1 registratie openstaand · EUR 20',
    );
    expect(
      MizanI18n.text('2 açık kayıt · EUR 20'),
      '2 registraties openstaand · EUR 20',
    );
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 nieuwe registratie; 1 koppeling bijgewerkt.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      'Er zijn 2 nieuwe registraties toegevoegd; de bestaande gegevens zijn behouden.',
    );
  });

  test('Dutch number date and currency formats follow nl-NL conventions', () {
    MizanI18n.setProfile(languageTag: 'nl', currencyCode: 'EUR');

    expect(money(1234567.5), '€\u00A01.234.567,50');
    expect(decimalText(1250.5), '1250,50');
    expect(shortDate(DateTime(2026, 8, 1)), '1 aug 2026');
    expect(monthLabel(DateTime(2026, 8)), 'augustus 2026');

    MizanI18n.setProfile(languageTag: 'nl', currencyCode: 'USD');
    expect(money(1234.5), 'USD\u00A01.234,50');
  });

  test('Dutch catalogs display names and retain multilingual aliases', () async {
    MizanI18n.setProfile(languageTag: 'nl', currencyCode: 'EUR');
    final catalog = await GlobalCatalogRepository.load();

    expect(catalog.language('nl').nameFor('nl'), 'Nederlands');
    expect(catalog.language('pt-PT').nameFor('nl'), 'Portugees (Portugal)');
    expect(catalog.country('NL').nameFor('nl'), 'Nederland');
    expect(catalog.country('TR').nameFor('nl'), 'Turkije');
    expect(catalog.currency('EUR').nameFor('nl'), 'euro');
    expect(catalog.currency('USD').nameFor('nl'), 'Amerikaanse dollar');
    expect(
      catalog.currencies
          .where((item) => item.matches('Amerikaanse dollars'))
          .singleWhere((item) => item.code == 'USD')
          .nameFor('nl'),
      'Amerikaanse dollar',
    );
    expect(
      catalog.currencies
          .where((item) => item.matches('US dollar'))
          .singleWhere((item) => item.code == 'USD')
          .nameFor('nl'),
      'Amerikaanse dollar',
    );
  });

  test('Dutch never translates user-authored names or notes', () {
    MizanI18n.setProfile(languageTag: 'nl', currencyCode: 'EUR');
    final userName = MizanI18n.user('Instellingen Bank');
    final note = MizanI18n.user('Not: Kira özel açıklama');

    expect(MizanI18n.text(userName), 'Instellingen Bank');
    expect(MizanI18n.text(note), 'Not: Kira özel açıklama');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Instellingen Bank · Totale resterende schuld',
    );
  });

  test('Dutch output does not leak another integrated product language', () {
    MizanI18n.setProfile(languageTag: 'nl', currencyCode: 'EUR');
    const sources = <String>[
      'Ayarlar',
      'Ödemeler',
      'Giderler',
      'Kişisel ve kurumsal borçlar',
      'CSV yedeğini birleştir',
      'PDF raporu',
      'Gecikmiş ödeme yükü',
    ];
    final visible = sources.map(MizanI18n.text).join(' | ');
    for (final foreign in <String>[
      'Impostazioni',
      'Pagamenti',
      'Spese',
      'Einstellungen',
      'Zahlungen',
      'Ausgaben',
      'Paramètres',
      'Paiements',
      'Dépenses',
      'Configuración',
      'Pagos',
      'Gastos',
    ]) {
      expect(visible, isNot(contains(foreign)));
    }
  });
}
