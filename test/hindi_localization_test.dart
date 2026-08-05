import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_hi.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Hindi source contains exactly 791 reviewed static values', () {
    expect(mizanHindi.length, 791);
    expect(mizanHindi.values.every((value) => value.trim().isNotEmpty), isTrue);

    final values = mizanHindi.values.join('\n');
    expect(RegExp(r'[\u0900-\u097F]').hasMatch(values), isTrue);
    expect(RegExp(r'[\u0590-\u08FF]').hasMatch(values), isFalse);
    expect(RegExp(r'[\u0980-\u0D7F]').hasMatch(values), isFalse);
    for (final forbidden in const [
      '\u200b',
      '\u200c',
      '\u200d',
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

  test('Hindi locale tags resolve to one runtime', () {
    expect(MizanI18n.isSupported('hi'), isTrue);
    expect(MizanI18n.isSupported('hi-IN'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('HI_in'), 'hi');
  });

  test('Hindi uses reviewed India-oriented financial terminology', () {
    MizanI18n.setProfile(languageTag: 'hi', currencyCode: 'INR');
    expect(MizanI18n.text('Ana sayfa'), 'मुख्य पृष्ठ');
    expect(MizanI18n.text('Kayıtlar'), 'रिकॉर्ड');
    expect(MizanI18n.text('Giderler'), 'खर्च');
    expect(MizanI18n.text('Raporlar'), 'रिपोर्ट');
    expect(MizanI18n.text('Ayarlar'), 'सेटिंग्स');
    expect(MizanI18n.text('Kaydet'), 'सहेजें');
    expect(MizanI18n.text('Banka borcu'), 'बैंक का कर्ज़');
    expect(MizanI18n.text('Kredi'), 'लोन');
    expect(MizanI18n.text('Fatura'), 'बिल');
    expect(MizanI18n.text('Abonelik'), 'सदस्यता');
    expect(MizanI18n.destructiveConfirmation, 'मैं सहमत हूँ');
  });

  test('Hindi dynamic copy handles natural zero one and other forms', () {
    MizanI18n.setProfile(languageTag: 'hi', currencyCode: 'INR');
    expect(MizanI18n.text('0 gün kaldı'), 'अंतिम भुगतान आज है');
    expect(MizanI18n.text('1 gün kaldı'), '1 दिन बाकी');
    expect(MizanI18n.text('2 gün kaldı'), '2 दिन बाकी');
    expect(MizanI18n.text('11 gün kaldı'), '11 दिन बाकी');
    expect(MizanI18n.text('0 ödeme'), '0 भुगतान');
    expect(MizanI18n.text('1 ödeme'), '1 भुगतान');
    expect(MizanI18n.text('2 ödeme'), '2 भुगतान');
    expect(MizanI18n.text('1 gider kaydı'), 'खर्च का 1 रिकॉर्ड');
    expect(MizanI18n.text('2 gider kaydı'), 'खर्च के 2 रिकॉर्ड');
    expect(MizanI18n.text('0 ay'), '0 महीने');
    expect(MizanI18n.text('1 ay'), '1 महीना');
    expect(MizanI18n.text('2 ay'), '2 महीने');
    expect(MizanI18n.text('0 kişi seçili'), 'कोई व्यक्ति नहीं चुना गया');
    expect(MizanI18n.text('1 kişi seçili'), '1 व्यक्ति चुना गया');
    expect(MizanI18n.text('5 kişi seçili'), '5 लोग चुने गए');
  });

  test('Hindi money numbers and Gregorian dates are India-aware', () {
    MizanI18n.setProfile(languageTag: 'hi', currencyCode: 'INR');
    expect(money(1234567.5), '₹12,34,567.50');
    expect(decimalText(1234567.5), '12,34,567.50');
    expect(decimalText(12.5), '12.50');
    expect(shortDate(DateTime(2026, 8, 5)), '5 अग॰ 2026');
    expect(monthLabel(DateTime(2026, 8)), 'अगस्त 2026');
    expect(parseMoney('₹12,34,567.50'), 1234567.5);
    expect(parseMoney('INR 12,34,567.50'), 1234567.5);
    expect(parseMoney('₹१२,३४५.५०'), 12345.5);
    expect(parseOptionalPositiveInt('१२'), 12);
    expect(parsePositiveDecimal('१२.५'), 12.5);

    MizanI18n.setProfile(languageTag: 'hi', currencyCode: 'USD');
    expect(money(1234567.5), 'USD\u00A012,34,567.50');
  });

  test('Hindi catalogs are complete and searchable offline', () async {
    MizanI18n.setProfile(languageTag: 'hi', currencyCode: 'INR');
    final catalog = await GlobalCatalogRepository.load();
    expect(catalog.languages, hasLength(29));
    expect(catalog.countries, hasLength(161));
    expect(catalog.currencies, hasLength(154));
    expect(
      catalog.languages.every((item) => item.nameFor('hi').trim().isNotEmpty),
      isTrue,
    );
    expect(
      catalog.countries.every((item) => item.nameFor('hi').trim().isNotEmpty),
      isTrue,
    );
    expect(
      catalog.currencies.every((item) => item.nameFor('hi').trim().isNotEmpty),
      isTrue,
    );
    expect(catalog.language('hi').nameFor('hi'), 'हिन्दी');
    expect(catalog.country('IN').nameFor('hi'), 'भारत');
    expect(catalog.currency('INR').nameFor('hi'), contains('भारतीय रुपया'));
    expect(
      catalog.countries
          .where((item) => item.matches('भारत'))
          .any((item) => item.code == 'IN'),
      isTrue,
    );
    expect(
      catalog.currencies
          .where((item) => item.matches('रुपया'))
          .any((item) => item.code == 'INR'),
      isTrue,
    );
  });

  test('Hindi preserves user-authored text without RTL isolation', () {
    MizanI18n.setProfile(languageTag: 'hi', currencyCode: 'INR');
    final encoded = MizanI18n.user('Bank 24 - ग्राहक नोट');
    final visible = MizanI18n.text(encoded);
    expect(encoded, startsWith('\u{E000}'));
    expect(encoded, endsWith('\u{E001}'));
    expect(visible, 'Bank 24 - ग्राहक नोट');
    expect(visible, isNot(startsWith('\u2068')));
    expect(
      MizanI18n.text('$encoded · Kalan toplam borç'),
      'Bank 24 - ग्राहक नोट · कुल बाकी कर्ज़',
    );
  });

  test('Hindi notification copy explains exact and approximate scheduling', () {
    MizanI18n.setProfile(languageTag: 'hi', currencyCode: 'INR');
    expect(
      MizanI18n.text(
        'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.',
      ),
      allOf(contains('अनुमानित'), contains('सटीक')),
    );
    expect(
      MizanI18n.text(
        'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.',
      ),
      contains('अनुमानित'),
    );
  });
}
