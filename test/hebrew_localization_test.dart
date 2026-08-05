import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_he.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Hebrew source contains exactly 791 reviewed static values', () {
    expect(mizanHebrew.length, 791);
    expect(
      mizanHebrew.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );

    final values = mizanHebrew.values.join('\n');
    expect(RegExp(r'[\u05D0-\u05EA]').hasMatch(values), isTrue);
    expect(RegExp(r'[\u0600-\u06FF]').hasMatch(values), isFalse);
    expect(RegExp(r'[\u0591-\u05C7]').hasMatch(values), isFalse);
    for (final forbidden in const [
      '\u200e',
      '\u200f',
      '\u202a',
      '\u202b',
      '\u202c',
      '\u202d',
      '\u202e',
      '\u2066',
      '\u2067',
      '\u2068',
      '\u2069',
    ]) {
      expect(values, isNot(contains(forbidden)));
    }
  });

  test('Hebrew and the legacy iw alias resolve to the same runtime', () {
    expect(MizanI18n.isSupported('he'), isTrue);
    expect(MizanI18n.isSupported('he-IL'), isTrue);
    expect(MizanI18n.isSupported('iw-IL'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('HE_il'), 'he');
    expect(MizanI18n.normalizeLanguageTag('iw_IL'), 'he');
  });

  test('Hebrew uses reviewed Israeli financial terminology', () {
    MizanI18n.setProfile(languageTag: 'he', currencyCode: 'ILS');
    expect(MizanI18n.text('Ana sayfa'), 'דף הבית');
    expect(MizanI18n.text('Kayıtlar'), 'רשומות');
    expect(MizanI18n.text('Giderler'), 'הוצאות');
    expect(MizanI18n.text('Raporlar'), 'דוחות');
    expect(MizanI18n.text('Ayarlar'), 'הגדרות');
    expect(MizanI18n.text('Kaydet'), 'שמירה');
    expect(MizanI18n.text('Banka borcu'), 'חוב בנקאי');
    expect(MizanI18n.text('Fatura'), 'חשבון');
    expect(MizanI18n.text('Abonelik'), 'מנוי');
    expect(MizanI18n.destructiveConfirmation, 'אני מאשר');
  });

  test('Hebrew dynamic copy follows one two other and gender rules', () {
    MizanI18n.setProfile(languageTag: 'he', currencyCode: 'ILS');
    expect(MizanI18n.text('0 gün kaldı'), 'מועד הפירעון היום');
    expect(MizanI18n.text('1 gün kaldı'), 'נותר יום אחד');
    expect(MizanI18n.text('2 gün kaldı'), 'נותרו יומיים');
    expect(MizanI18n.text('11 gün kaldı'), 'נותרו 11 ימים');
    expect(MizanI18n.text('0 ödeme'), 'ללא תשלומים');
    expect(MizanI18n.text('1 ödeme'), 'תשלום אחד');
    expect(MizanI18n.text('2 ödeme'), 'שני תשלומים');
    expect(MizanI18n.text('2 gider'), 'שתי הוצאות');
    expect(MizanI18n.text('2 kayıt'), 'שתי רשומות');
    expect(MizanI18n.text('5 kişi seçili'), 'נבחרו 5 אנשים');
    expect(
      MizanI18n.text('2 açık kayıt · ILS 20'),
      'שתי רשומות פתוחות · ILS 20',
    );
    expect(MizanI18n.text('Ayın 1. günü'), 'היום ה-1 בחודש');
    expect(MizanI18n.text('Her ayın 20. günü'), 'היום ה-20 בכל חודש');
  });

  test('Hebrew money numbers and Gregorian dates are locale-aware', () {
    MizanI18n.setProfile(languageTag: 'he', currencyCode: 'ILS');
    final ils = money(1234567.5);
    expect(ils, contains('1,234,567.50'));
    expect(ils, contains('₪'));
    expect(ils, startsWith('\u2066'));
    expect(ils, endsWith('\u2069'));
    expect(decimalText(1250.5), '1,250.50');
    expect(shortDate(DateTime(2026, 8, 1)), '1 אוגוסט 2026');
    expect(monthLabel(DateTime(2026, 3)), 'מרץ 2026');
    expect(parseMoney('₪ 1,234.50'), 1234.5);
    expect(parseMoney('1,234.50 ILS'), 1234.5);
    expect(parseOptionalPositiveInt('12'), 12);
    expect(parsePositiveDecimal('12.5'), 12.5);

    MizanI18n.setProfile(languageTag: 'he', currencyCode: 'USD');
    final usd = money(1234.5);
    expect(usd, contains('1,234.50'));
    expect(usd, contains('USD'));
    expect(usd, startsWith('\u2066'));
    expect(usd, endsWith('\u2069'));
  });

  test('Hebrew catalogs are complete and searchable offline', () async {
    MizanI18n.setProfile(languageTag: 'he', currencyCode: 'ILS');
    final catalog = await GlobalCatalogRepository.load();
    expect(catalog.languages, hasLength(29));
    expect(catalog.countries, hasLength(161));
    expect(catalog.currencies, hasLength(154));
    expect(
      catalog.languages.every((item) => item.nameFor('he').trim().isNotEmpty),
      isTrue,
    );
    expect(
      catalog.countries.every((item) => item.nameFor('he').trim().isNotEmpty),
      isTrue,
    );
    expect(
      catalog.currencies.every((item) => item.nameFor('he').trim().isNotEmpty),
      isTrue,
    );
    expect(catalog.language('he').nameFor('he'), 'עברית');
    expect(catalog.country('IL').nameFor('he'), contains('ישראל'));
    expect(catalog.currency('ILS').nameFor('he'), contains('שקל'));
    expect(
      catalog.countries
          .where((item) => item.matches('ישראל'))
          .any((item) => item.code == 'IL'),
      isTrue,
    );
    expect(
      catalog.currencies
          .where((item) => item.matches('שקל'))
          .any((item) => item.code == 'ILS'),
      isTrue,
    );
  });

  test('Hebrew preserves user text and adds only visible bidi isolation', () {
    MizanI18n.setProfile(languageTag: 'he', currencyCode: 'ILS');
    final encoded = MizanI18n.user('Bank 24 - הערת לקוח');
    final visible = MizanI18n.text(encoded);
    expect(encoded, startsWith('\u{E000}'));
    expect(encoded, endsWith('\u{E001}'));
    expect(visible, '\u2068Bank 24 - הערת לקוח\u2069');
    expect(
      MizanI18n.text('$encoded · Kalan toplam borç'),
      '\u2068Bank 24 - הערת לקוח\u2069 · סך החוב שנותר',
    );
  });

  test('Hebrew notification copy matches exact and fallback scheduling', () {
    MizanI18n.setProfile(languageTag: 'he', currencyCode: 'ILS');
    expect(
      MizanI18n.text(
        'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.',
      ),
      allOf(contains('תזמון משוער'), contains('תזמון מדויק')),
    );
    expect(
      MizanI18n.text(
        'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.',
      ),
      contains('תזמון משוער'),
    );
  });
}
