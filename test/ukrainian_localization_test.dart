import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_uk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Ukrainian source contains exactly 791 reviewed static values', () {
    expect(mizanUkrainian.length, 791);
    expect(
      mizanUkrainian.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test('Ukrainian is enabled and regional aliases resolve to it', () {
    expect(MizanI18n.isSupported('uk'), isTrue);
    expect(MizanI18n.isSupported('uk-UA'), isTrue);
    expect(MizanI18n.isSupported('uk_UA'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('UK_ua'), 'uk');
  });

  test('Ukrainian uses Ukraine-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'uk', currencyCode: 'UAH');

    expect(MizanI18n.text('Ana sayfa'), 'Головна');
    expect(MizanI18n.text('Kayıtlar'), 'Записи');
    expect(MizanI18n.text('Ayarlar'), 'Налаштування');
    expect(MizanI18n.text('Kaydet'), 'Зберегти');
    expect(MizanI18n.text('Sil'), 'Видалити');
    expect(MizanI18n.text('Gelir'), 'Дохід');
    expect(MizanI18n.text('Abonelik'), 'Підписка');
    expect(MizanI18n.text('Ev kredisi'), 'Іпотечний кредит');
    expect(MizanI18n.text('KMH hesabı'), 'Рахунок з овердрафтом');
    expect(MizanI18n.text('Çek'), 'Банківський чек');
    expect(MizanI18n.text('Senet'), 'Боргова розписка');
    expect(MizanI18n.destructiveConfirmation, 'ПІДТВЕРДЖУЮ');
  });

  test('Ukrainian dynamic copy applies one few and many forms', () {
    MizanI18n.setProfile(languageTag: 'uk', currencyCode: 'UAH');

    expect(MizanI18n.text('1 gün kaldı'), 'Залишився 1 день');
    expect(MizanI18n.text('3 gün kaldı'), 'Залишилося 3 дні');
    expect(MizanI18n.text('5 gün kaldı'), 'Залишилося 5 днів');
    expect(MizanI18n.text('11 gün kaldı'), 'Залишилося 11 днів');
    expect(MizanI18n.text('21 gün kaldı'), 'Залишився 21 день');
    expect(MizanI18n.text('Kira için 1 gün kaldı'), 'До Kira залишився 1 день');
    expect(MizanI18n.text('Kira için 2 gün kaldı'), 'До Kira залишилося 2 дні');
    expect(MizanI18n.text('Ayın 1. günü'), '1-й день місяця');
    expect(MizanI18n.text('Her ayın 2. günü'), '2-го числа кожного місяця');
    expect(MizanI18n.text('1 kişi seçili'), 'Вибрано 1 особу');
    expect(MizanI18n.text('2 kişi seçili'), 'Вибрано 2 особи');
    expect(MizanI18n.text('5 kişi seçili'), 'Вибрано 5 осіб');
    expect(
      MizanI18n.text('1 açık kayıt · UAH 20'),
      '1 відкритий запис · UAH 20',
    );
    expect(
      MizanI18n.text('2 açık kayıt · UAH 20'),
      '2 відкриті записи · UAH 20',
    );
    expect(
      MizanI18n.text('1 yeni, 1 ilişki güncellendi.'),
      '1 новий запис, оновлено 1 зв’язок.',
    );
    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      'Додано 2 нові записи; наявні дані збережено.',
    );
  });

  test('Ukrainian number date and currency formats follow uk-UA', () {
    MizanI18n.setProfile(languageTag: 'uk', currencyCode: 'UAH');

    expect(money(1234567.5), '1\u00A0234\u00A0567,50\u00A0₴');
    expect(decimalText(1250.5), '1\u00A0250,50');
    expect(shortDate(DateTime(2026, 8, 1)), '1 серп. 2026');
    expect(monthLabel(DateTime(2026, 3)), 'березень 2026');

    MizanI18n.setProfile(languageTag: 'uk', currencyCode: 'USD');
    expect(money(1234.5), '1\u00A0234,50\u00A0USD');
  });

  test('Ukrainian catalogs display names and retain search aliases', () async {
    MizanI18n.setProfile(languageTag: 'uk', currencyCode: 'UAH');
    final catalog = await GlobalCatalogRepository.load();

    expect(catalog.language('uk').nameFor('uk'), 'Українська');
    expect(
      catalog.language('pt-PT').nameFor('uk'),
      'португальська (Португалія)',
    );
    expect(catalog.country('UA').nameFor('uk'), 'Україна');
    expect(catalog.country('TR').nameFor('uk'), 'Туреччина');
    expect(catalog.currency('UAH').nameFor('uk'), 'українська гривня');
    expect(catalog.currency('USD').nameFor('uk'), 'долар США');
    expect(
      catalog.currencies
          .where((item) => item.matches('американський долар'))
          .singleWhere((item) => item.code == 'USD')
          .nameFor('uk'),
      'долар США',
    );
    expect(
      catalog.currencies
          .where((item) => item.matches('грн'))
          .singleWhere((item) => item.code == 'UAH')
          .nameFor('uk'),
      'українська гривня',
    );
  });

  test('Ukrainian preserves every user-authored name and note', () {
    MizanI18n.setProfile(languageTag: 'uk', currencyCode: 'UAH');
    final userName = MizanI18n.user('Налаштування Bank');
    final note = MizanI18n.user('Not: Kira özel açıklama');

    expect(MizanI18n.text(userName), 'Налаштування Bank');
    expect(MizanI18n.text(note), 'Not: Kira özel açıklama');
    expect(
      MizanI18n.text('$userName · Kalan toplam borç'),
      'Налаштування Bank · Загальний залишок боргу',
    );
  });

  test('Ukrainian output contains no Russian-only product language', () {
    MizanI18n.setProfile(languageTag: 'uk', currencyCode: 'UAH');
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
    for (final russian in <String>[
      'Настройки',
      'Платежи',
      'Расходы',
      'Счёт',
      'Отчёт',
      'Просрочено',
      'Уведомление',
      'ы',
      'э',
      'ё',
      'ъ',
    ]) {
      expect(visible.toLowerCase(), isNot(contains(russian.toLowerCase())));
    }
  });

  test('Ukrainian notification copy matches exact and fallback scheduling', () {
    MizanI18n.setProfile(languageTag: 'uk', currencyCode: 'UAH');

    expect(
      MizanI18n.text(
        'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.',
      ),
      contains('приблизне планування'),
    );
    expect(
      MizanI18n.text(
        'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.',
      ),
      'Дозвіл на точні будильники не надано. Тест буде заплановано приблизно.',
    );
  });
}
