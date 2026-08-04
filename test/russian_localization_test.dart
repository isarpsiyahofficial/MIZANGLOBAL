import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ru.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Russian source contains exactly 791 reviewed static values', () {
    expect(mizanRussian.length, 791);
    expect(mizanRussian.values.every((value) => value.trim().isNotEmpty), isTrue);
  });

  test('Russian is enabled and regional aliases resolve to it', () {
    expect(MizanI18n.isSupported('ru'), isTrue);
    expect(MizanI18n.isSupported('ru-RU'), isTrue);
    expect(MizanI18n.isSupported('ru_RU'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('RU_ru'), 'ru');
  });

  test('Russian uses Russia-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'ru', currencyCode: 'RUB');

    expect(MizanI18n.text('Ana sayfa'), 'Главная');
    expect(MizanI18n.text('Kayıtlar'), 'Записи');
    expect(MizanI18n.text('Ayarlar'), 'Настройки');
    expect(MizanI18n.text('Kaydet'), 'Сохранить');
    expect(MizanI18n.text('Sil'), 'Удалить');
    expect(MizanI18n.text('Gelir'), 'Доход');
    expect(MizanI18n.text('Abonelik'), 'Подписка');
    expect(MizanI18n.text('Ev kredisi'), 'Ипотека');
    expect(MizanI18n.text('KMH hesabı'), 'Счёт с овердрафтом');
    expect(MizanI18n.text('Çek'), 'Банковский чек');
    expect(MizanI18n.text('Senet'), 'Вексель');
    expect(MizanI18n.destructiveConfirmation, 'ПОДТВЕРЖДАЮ');
  });

  test('Russian dynamic copy applies singular and plural forms', () {
    MizanI18n.setProfile(languageTag: 'ru', currencyCode: 'RUB');

    expect(MizanI18n.text('1 gün kaldı'), 'Осталось 1 день');
    expect(MizanI18n.text('3 gün kaldı'), 'Осталось 3 дня');
    expect(MizanI18n.text('5 gün kaldı'), 'Осталось 5 дней');
    expect(MizanI18n.text('11 gün kaldı'), 'Осталось 11 дней');
    expect(MizanI18n.text('21 gün kaldı'), 'Осталось 21 день');
    expect(
      MizanI18n.text('Kira için 1 gün kaldı'),
      'До Kira осталось 1 день',
    );
    expect(
      MizanI18n.text('Kira için 2 gün kaldı'),
      'До Kira осталось 2 дня',
    );
    expect(MizanI18n.text('Ayın 1. günü'), '1-й день месяца');
    expect(MizanI18n.text('Her ayın 2. günü'), '2-го числа каждого месяца');
    expect(MizanI18n.text('1 kişi seçili'), 'Выбран 1 человек');
    expect(MizanI18n.text('2 kişi seçili'), 'Выбрано 2 человека');
    expect(
      MizanI18n.text('1 açık kayıt · RUB 20'),
      '1 открытая запись · RUB 20',
    );
    expect(
      MizanI18n.text('2 açık kayıt · RUB 20'),
      '2 открытые записи · RUB 20',
    );
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 новая запись, обновлена 1 связь.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      'Добавлено 2 новые записи; существующие данные сохранены.',
    );
  });

  test('Russian number date and currency formats follow ru-RU conventions', () {
    MizanI18n.setProfile(languageTag: 'ru', currencyCode: 'RUB');

    expect(money(1234567.5), '1\u00A0234\u00A0567,50\u00A0₽');
    expect(decimalText(1250.5), '1\u00A0250,50');
    expect(shortDate(DateTime(2026, 8, 1)), '1 авг. 2026');
    expect(monthLabel(DateTime(2026, 3)), 'март 2026');

    MizanI18n.setProfile(languageTag: 'ru', currencyCode: 'USD');
    expect(money(1234.5), '1\u00A0234,50\u00A0USD');
  });

  test(
    'Russian catalogs display names and retain multilingual aliases',
    () async {
      MizanI18n.setProfile(languageTag: 'ru', currencyCode: 'RUB');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('ru').nameFor('ru'), 'Русский');
      expect(
        catalog.language('pt-PT').nameFor('ru'),
        'Португальский (Португалия)',
      );
      expect(catalog.country('RU').nameFor('ru'), 'Россия');
      expect(catalog.country('TR').nameFor('ru'), 'Турция');
      expect(catalog.currency('RUB').nameFor('ru'), 'российский рубль');
      expect(catalog.currency('USD').nameFor('ru'), 'доллар США');
      expect(
        catalog.currencies
            .where((item) => item.matches('американский доллар'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('ru'),
        'доллар США',
      );
      expect(
        catalog.currencies
            .where((item) => item.matches('турецкие лиры'))
            .singleWhere((item) => item.code == 'TRY')
            .nameFor('ru'),
        'турецкая лира',
      );
    },
  );

  test('Russian never translates user-authored names or notes', () {
    MizanI18n.setProfile(languageTag: 'ru', currencyCode: 'RUB');
    final userName = MizanI18n.user('Настройки Bank');
    final note = MizanI18n.user('Not: Kira özel açıklama');

    expect(MizanI18n.text(userName), 'Настройки Bank');
    expect(MizanI18n.text(note), 'Not: Kira özel açıklama');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Настройки Bank · Общая непогашенная задолженность',
    );
  });

  test('Russian output does not leak another integrated product language', () {
    MizanI18n.setProfile(languageTag: 'ru', currencyCode: 'RUB');
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
      'Setări',
      'Înregistrări',
      'Cheltuieli',
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
