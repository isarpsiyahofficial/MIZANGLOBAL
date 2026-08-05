import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_bn.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Bengali source contains exactly 791 complete static values', () {
    expect(mizanBengali.length, 791);
    expect(
      mizanBengali.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );

    final values = mizanBengali.values.join('\n');
    expect(RegExp(r'[\u0980-\u09FF]').hasMatch(values), isTrue);
    expect(RegExp(r'[\u0590-\u08FF]').hasMatch(values), isFalse);
    expect(RegExp(r'[\u0A00-\u0D7F]').hasMatch(values), isFalse);
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

  test('Bengali locale variants resolve to one LTR runtime', () {
    expect(MizanI18n.isSupported('bn'), isTrue);
    expect(MizanI18n.isSupported('bn-BD'), isTrue);
    expect(MizanI18n.isSupported('bn-IN'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('BN_bd'), 'bn');
    expect(MizanI18n.normalizeLanguageTag('bn_IN'), 'bn');
  });

  test('Bengali uses stable natural financial terminology', () {
    MizanI18n.setProfile(languageTag: 'bn', currencyCode: 'BDT');
    expect(MizanI18n.text('Ana sayfa'), 'হোম');
    expect(MizanI18n.text('Kayıtlar'), 'রেকর্ড');
    expect(MizanI18n.text('Giderler'), 'খরচ');
    expect(MizanI18n.text('Raporlar'), 'প্রতিবেদন');
    expect(MizanI18n.text('Ayarlar'), 'সেটিংস');
    expect(MizanI18n.text('Kaydet'), 'সংরক্ষণ করুন');
    expect(MizanI18n.text('Banka borcu'), 'ব্যাংক ঋণ');
    expect(MizanI18n.text('Fatura'), 'বিল');
    expect(MizanI18n.text('Abonelik'), 'সাবস্ক্রিপশন');
    expect(MizanI18n.text('Kalan ödeme yükü'), 'অবশিষ্ট পরিশোধের দায়');
    expect(
      MizanI18n.text('Gecikmiş ödeme yükü'),
      'মেয়াদোত্তীর্ণ পরিশোধের দায়',
    );
    expect(
      MizanI18n.text('Yaklaşan ödeme yükü'),
      'আসন্ন পরিশোধের দায়',
    );
    expect(MizanI18n.destructiveConfirmation, 'আমি নিশ্চিত করছি');
  });

  test('Bengali money, numbers and Gregorian dates are locale-aware', () {
    MizanI18n.setProfile(languageTag: 'bn', currencyCode: 'BDT');
    expect(money(1234567.5), '৳১২,৩৪,৫৬৭.৫০');
    expect(decimalText(1234567.5), '১২,৩৪,৫৬৭.৫০');
    expect(decimalText(12.5), '১২.৫০');
    expect(shortDate(DateTime(2026, 8, 5)), '৫ আগ ২০২৬');
    expect(monthLabel(DateTime(2026, 8)), 'আগস্ট ২০২৬');
    expect(parseMoney('৳১২,৩৪,৫৬৭.৫০'), 1234567.5);
    expect(parseMoney('BDT 12,34,567.50'), 1234567.5);
    expect(parseOptionalPositiveInt('১২'), 12);
    expect(parsePositiveDecimal('১২.৫'), 12.5);

    MizanI18n.setProfile(languageTag: 'bn-IN', currencyCode: 'INR');
    expect(money(1234567.5), '₹১২,৩৪,৫৬৭.৫০');

    MizanI18n.setProfile(languageTag: 'bn', currencyCode: 'USD');
    expect(money(1234567.5), 'USD\u00A0১২,৩৪,৫৬৭.৫০');
  });

  test('Bengali catalogs are complete and searchable offline', () async {
    MizanI18n.setProfile(languageTag: 'bn', currencyCode: 'BDT');
    final catalog = await GlobalCatalogRepository.load();
    expect(catalog.languages, hasLength(29));
    expect(catalog.countries, hasLength(161));
    expect(catalog.currencies, hasLength(154));
    expect(
      catalog.languages.every((item) => item.nameFor('bn').trim().isNotEmpty),
      isTrue,
    );
    expect(
      catalog.countries.every((item) => item.nameFor('bn').trim().isNotEmpty),
      isTrue,
    );
    expect(
      catalog.currencies.every((item) => item.nameFor('bn').trim().isNotEmpty),
      isTrue,
    );
    expect(catalog.language('bn').nameFor('bn'), 'বাংলা');
    expect(catalog.country('BD').nameFor('bn'), 'বাংলাদেশ');
    expect(catalog.country('IN').nameFor('bn'), 'ভারত');
    expect(catalog.currency('BDT').nameFor('bn'), contains('টাকা'));
    expect(catalog.currency('INR').nameFor('bn'), contains('রুপি'));
    expect(
      catalog.countries
          .where((item) => item.matches('বাংলাদেশ'))
          .any((item) => item.code == 'BD'),
      isTrue,
    );
    expect(
      catalog.currencies
          .where((item) => item.matches('টাকা'))
          .any((item) => item.code == 'BDT'),
      isTrue,
    );
  });

  test('Bengali preserves user-authored text unchanged', () {
    MizanI18n.setProfile(languageTag: 'bn', currencyCode: 'BDT');
    final encoded = MizanI18n.user('Bank 24 - গ্রাহকের নোট');
    final visible = MizanI18n.text(encoded);
    expect(encoded, startsWith('\u{E000}'));
    expect(encoded, endsWith('\u{E001}'));
    expect(visible, 'Bank 24 - গ্রাহকের নোট');
    expect(visible, isNot(startsWith('\u2068')));
    expect(
      MizanI18n.text('$encoded · Kalan toplam borç'),
      'Bank 24 - গ্রাহকের নোট · মোট অবশিষ্ট ঋণ',
    );
  });

  test('Bengali report, PDF and exact-alarm copy stays distinct', () {
    MizanI18n.setProfile(languageTag: 'bn', currencyCode: 'BDT');
    expect(
      MizanI18n.text('Kalan ödeme yükünün dağılımı'),
      'অবশিষ্ট পরিশোধের দায়ের বণ্টন',
    );
    expect(
      MizanI18n.text(
        'Dönem ve kişi filtresi ekrandaki verilerle PDF’de birebir aynıdır.',
      ),
      'সময়পর্ব ও ব্যক্তি ফিল্টার পর্দা এবং PDF-এ হুবহু একই থাকে।',
    );
    expect(
      MizanI18n.text(
        'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.',
      ),
      allOf(contains('আনুমানিক'), contains('সঠিক')),
    );
  });
}
