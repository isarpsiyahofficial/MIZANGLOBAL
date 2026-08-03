import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ro.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Romanian source contains exactly 791 reviewed static values', () {
    expect(mizanRomanian.length, 791);
    expect(
      mizanRomanian.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test('Romanian is enabled and regional aliases resolve to it', () {
    expect(MizanI18n.isSupported('ro'), isTrue);
    expect(MizanI18n.isSupported('ro-RO'), isTrue);
    expect(MizanI18n.isSupported('ro_RO'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('RO_ro'), 'ro');
  });

  test('Romanian uses Romania-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'ro', currencyCode: 'RON');

    expect(MizanI18n.text('Ana sayfa'), 'Prezentare generală');
    expect(MizanI18n.text('Kayıtlar'), 'Înregistrări');
    expect(MizanI18n.text('Ayarlar'), 'Setări');
    expect(MizanI18n.text('Kaydet'), 'Salvează');
    expect(MizanI18n.text('Sil'), 'Șterge');
    expect(MizanI18n.text('Gelir'), 'Venit');
    expect(MizanI18n.text('Abonelik'), 'Abonament');
    expect(MizanI18n.text('Ev kredisi'), 'Credit ipotecar');
    expect(MizanI18n.text('KMH hesabı'), 'Cont cu descoperit de cont');
    expect(MizanI18n.text('Senet'), 'Bilet la ordin');
    expect(MizanI18n.destructiveConfirmation, 'CONFIRM');
  });

  test('Romanian dynamic copy applies singular and plural forms', () {
    MizanI18n.setProfile(languageTag: 'ro', currencyCode: 'RON');

    expect(MizanI18n.text('1 gün kaldı'), 'A mai rămas 1 zi');
    expect(MizanI18n.text('3 gün kaldı'), 'Au mai rămas 3 zile');
    expect(
      MizanI18n.text('Chirie için 1 gün kaldı'),
      'A mai rămas 1 zi până la Chirie',
    );
    expect(
      MizanI18n.text('Chirie için 2 gün kaldı'),
      'Au mai rămas 2 zile până la Chirie',
    );
    expect(MizanI18n.text('Ayın 1. günü'), 'Ziua 1 a lunii');
    expect(MizanI18n.text('Her ayın 2. günü'), 'În ziua 2 a fiecărei luni');
    expect(MizanI18n.text('1 kişi seçili'), '1 persoană selectată');
    expect(MizanI18n.text('2 kişi seçili'), '2 persoane selectate');
    expect(
      MizanI18n.text('1 açık kayıt · RON 20'),
      '1 înregistrare deschisă · RON 20',
    );
    expect(
      MizanI18n.text('2 açık kayıt · RON 20'),
      '2 înregistrări deschise · RON 20',
    );
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 înregistrare nouă; a fost actualizată 1 asociere.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      'Au fost adăugate 2 înregistrări noi; datele existente au fost păstrate.',
    );
  });

  test(
    'Romanian number date and currency formats follow ro-RO conventions',
    () {
      MizanI18n.setProfile(languageTag: 'ro', currencyCode: 'RON');

      expect(money(1234567.5), '1.234.567,50\u00A0lei');
      expect(decimalText(1250.5), '1.250,50');
      expect(shortDate(DateTime(2026, 8, 1)), '1 aug. 2026');
      expect(monthLabel(DateTime(2026, 8)), 'august 2026');

      MizanI18n.setProfile(languageTag: 'ro', currencyCode: 'USD');
      expect(money(1234.5), '1.234,50\u00A0USD');
    },
  );

  test(
    'Romanian catalogs display names and retain multilingual aliases',
    () async {
      MizanI18n.setProfile(languageTag: 'ro', currencyCode: 'RON');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('ro').nameFor('ro'), 'română');
      expect(
        catalog.language('pt-PT').nameFor('ro'),
        'portugheză (Portugalia)',
      );
      expect(catalog.country('RO').nameFor('ro'), 'România');
      expect(catalog.country('TR').nameFor('ro'), 'Turcia');
      expect(catalog.currency('RON').nameFor('ro'), 'leu românesc');
      expect(catalog.currency('USD').nameFor('ro'), 'dolar american');
      expect(
        catalog.currencies
            .where((item) => item.matches('dolari americani'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('ro'),
        'dolar american',
      );
      expect(
        catalog.currencies
            .where((item) => item.matches('lei românești'))
            .singleWhere((item) => item.code == 'RON')
            .nameFor('ro'),
        'leu românesc',
      );
    },
  );

  test('Romanian never translates user-authored names or notes', () {
    MizanI18n.setProfile(languageTag: 'ro', currencyCode: 'RON');
    final userName = MizanI18n.user('Setări Bank');
    final note = MizanI18n.user('Not: Kira özel açıklama');

    expect(MizanI18n.text(userName), 'Setări Bank');
    expect(MizanI18n.text(note), 'Not: Kira özel açıklama');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Setări Bank · Datorie totală rămasă',
    );
  });

  test('Romanian output does not leak another integrated product language', () {
    MizanI18n.setProfile(languageTag: 'ro', currencyCode: 'RON');
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
      'Ustawienia',
      'Płatności',
      'Wydatki',
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
      'Instellingen',
      'Registraties',
      'Uitgaven',
    ]) {
      expect(visible, isNot(contains(foreign)));
    }
  });
}
