import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_pl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Polish source contains exactly 791 reviewed static values', () {
    expect(mizanPolish.length, 791);
    expect(
      mizanPolish.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test('Polish is enabled and regional aliases resolve to it', () {
    expect(MizanI18n.isSupported('pl'), isTrue);
    expect(MizanI18n.isSupported('pl-PL'), isTrue);
    expect(MizanI18n.isSupported('pl_PL'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('PL_pl'), 'pl');
  });

  test('Polish uses Poland-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'pl', currencyCode: 'PLN');

    expect(MizanI18n.text('Ana sayfa'), 'Pulpit');
    expect(MizanI18n.text('Kayıtlar'), 'Rejestry');
    expect(MizanI18n.text('Ayarlar'), 'Ustawienia');
    expect(MizanI18n.text('Kaydet'), 'Zapisz');
    expect(MizanI18n.text('Sil'), 'Usuń');
    expect(MizanI18n.text('Gelir'), 'Dochód');
    expect(MizanI18n.text('Abonelik'), 'Subskrypcja');
    expect(MizanI18n.text('Ev kredisi'), 'Kredyt hipoteczny');
    expect(MizanI18n.text('KMH hesabı'), 'Kredyt w rachunku bieżącym');
    expect(MizanI18n.text('Senet'), 'Weksel');
    expect(MizanI18n.destructiveConfirmation, 'POTWIERDZAM');
  });

  test('Polish dynamic copy applies singular and plural forms', () {
    MizanI18n.setProfile(languageTag: 'pl', currencyCode: 'PLN');

    expect(MizanI18n.text('1 gün kaldı'), 'Pozostał 1 dzień');
    expect(MizanI18n.text('3 gün kaldı'), 'Pozostały 3 dni');
    expect(MizanI18n.text('Huur için 1 gün kaldı'), 'Do Huur pozostał 1 dzień');
    expect(MizanI18n.text('Huur için 2 gün kaldı'), 'Do Huur pozostało 2 dni');
    expect(MizanI18n.text('Ayın 1. günü'), '1. dzień miesiąca');
    expect(MizanI18n.text('Her ayın 2. günü'), '2. dnia każdego miesiąca');
    expect(MizanI18n.text('1 kişi seçili'), 'Wybrano 1 osobę');
    expect(MizanI18n.text('2 kişi seçili'), 'Wybrano 2 osoby');
    expect(MizanI18n.text('1 açık kayıt · EUR 20'), '1 otwarty wpis · EUR 20');
    expect(MizanI18n.text('2 açık kayıt · EUR 20'), '2 otwarte wpisy · EUR 20');
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 nowy wpis; zaktualizowano 1 powiązanie.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      'Dodano 2 nowe wpisy; istniejące dane zostały zachowane.',
    );
  });

  test('Polish number date and currency formats follow pl-PL conventions', () {
    MizanI18n.setProfile(languageTag: 'pl', currencyCode: 'PLN');

    expect(money(1234567.5), '1\u202F234\u202F567,50\u00A0zł');
    expect(decimalText(1250.5), '1\u202F250,50');
    expect(shortDate(DateTime(2026, 8, 1)), '1 sie 2026');
    expect(monthLabel(DateTime(2026, 8)), 'sierpień 2026');

    MizanI18n.setProfile(languageTag: 'pl', currencyCode: 'USD');
    expect(money(1234.5), '1\u202F234,50\u00A0USD');
  });

  test(
    'Polish catalogs display names and retain multilingual aliases',
    () async {
      MizanI18n.setProfile(languageTag: 'pl', currencyCode: 'PLN');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('pl').nameFor('pl'), 'polski');
      expect(
        catalog.language('pt-PT').nameFor('pl'),
        'portugalski (Portugalia)',
      );
      expect(catalog.country('PL').nameFor('pl'), 'Polska');
      expect(catalog.country('TR').nameFor('pl'), 'Turcja');
      expect(catalog.currency('PLN').nameFor('pl'), 'złoty polski');
      expect(catalog.currency('USD').nameFor('pl'), 'dolar amerykański');
      expect(
        catalog.currencies
            .where((item) => item.matches('dolary amerykańskie'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('pl'),
        'dolar amerykański',
      );
      expect(
        catalog.currencies
            .where((item) => item.matches('dolar USA'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('pl'),
        'dolar amerykański',
      );
    },
  );

  test('Polish never translates user-authored names or notes', () {
    MizanI18n.setProfile(languageTag: 'pl', currencyCode: 'PLN');
    final userName = MizanI18n.user('Ustawienia Bank');
    final note = MizanI18n.user('Not: Kira özel açıklama');

    expect(MizanI18n.text(userName), 'Ustawienia Bank');
    expect(MizanI18n.text(note), 'Not: Kira özel açıklama');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Ustawienia Bank · Łączne pozostałe zadłużenie',
    );
  });

  test('Polish output does not leak another integrated product language', () {
    MizanI18n.setProfile(languageTag: 'pl', currencyCode: 'PLN');
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
      'Instellingen',
      'Registraties',
      'Uitgaven',
    ]) {
      expect(visible, isNot(contains(foreign)));
    }
  });
}
