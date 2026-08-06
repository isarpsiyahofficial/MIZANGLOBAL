import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_hi.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ur.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY'));

  test('Urdu source contains exactly 791 complete static values', () {
    expect(mizanUrdu.length, 791);
    expect(mizanUrdu.keys.toSet(), mizanHindi.keys.toSet());
    expect(mizanUrdu.values.every((value) => value.trim().isNotEmpty), isTrue);
    final values = mizanUrdu.values.join('\n');
    expect(RegExp(r'[\u0600-\u06FF]').hasMatch(values), isTrue);
    expect(RegExp(r'[\u0900-\u0D7F\u0400-\u052F\u0590-\u05FF]').hasMatch(values), isFalse);
  });

  test('Urdu locale variants resolve to one RTL runtime', () {
    expect(MizanI18n.isSupported('ur'), isTrue);
    expect(MizanI18n.isSupported('ur-PK'), isTrue);
    expect(MizanI18n.isSupported('ur-IN'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('UR_pk'), 'ur');
    expect(MizanI18n.normalizeLanguageTag('ur_IN'), 'ur');
  });

  test('Urdu uses natural financial terminology and dynamic grammar', () {
    MizanI18n.setProfile(languageTag: 'ur-PK', currencyCode: 'PKR');
    expect(MizanI18n.text('Ana sayfa'), 'ہوم');
    expect(MizanI18n.text('Kayıtlar'), 'ریکارڈ');
    expect(MizanI18n.text('Giderler'), 'اخراجات');
    expect(MizanI18n.text('Raporlar'), 'رپورٹس');
    expect(MizanI18n.text('Ayarlar'), 'ترتیبات');
    expect(MizanI18n.text('3 gün kaldı'), '3 دن باقی');
    expect(MizanI18n.text('Ödeme 5 gün gecikti.'), 'ادائیگی میں 5 دن کی تاخیر ہے۔');
    expect(MizanI18n.destructiveConfirmation, 'میں تصدیق کرتا ہوں');
  });

  test('Urdu money, numbers and Gregorian dates are locale-aware', () {
    MizanI18n.setProfile(languageTag: 'ur-PK', currencyCode: 'PKR');
    expect(money(1234567.5), '\u2066PKR\u00A01,234,567.50\u2069');
    expect(decimalText(1234567.5), '1234567.50');
    expect(shortDate(DateTime(2026, 8, 5)), '5 اگست 2026');
    expect(monthLabel(DateTime(2026, 8)), 'اگست 2026');
    expect(parseMoney('PKR 1,234,567.50'), 1234567.5);
    expect(parseMoney('₨ 1,234,567.50'), 1234567.5);

    MizanI18n.setProfile(languageTag: 'ur-IN', currencyCode: 'INR');
    expect(money(1234567.5), '\u2066₹12,34,567.50\u2069');
    expect(decimalText(1234567.5), '12,34,567.50');
  });

  test('Urdu catalogs are complete and searchable offline', () async {
    final catalog = await GlobalCatalogRepository.load();
    expect(catalog.languages, hasLength(29));
    expect(catalog.countries, hasLength(161));
    expect(catalog.currencies, hasLength(154));
    expect(catalog.language('ur').nameFor('ur'), 'اردو');
    expect(catalog.country('PK').nameFor('ur'), 'پاکستان');
    expect(catalog.country('IN').nameFor('ur'), 'بھارت');
    expect(catalog.currency('PKR').nameFor('ur'), 'پاکستانی روپیہ');
    expect(catalog.currency('INR').nameFor('ur'), 'بھارتی روپیہ');
  });

  test('Urdu preserves mixed user text with bidi isolation', () {
    MizanI18n.setProfile(languageTag: 'ur', currencyCode: 'PKR');
    final encoded = MizanI18n.user('Bank 24 - صارف کا نوٹ');
    expect(MizanI18n.text(encoded), '\u2068Bank 24 - صارف کا نوٹ\u2069');
    expect(
      MizanI18n.text('$encoded · Kalan toplam borç'),
      '\u2068Bank 24 - صارف کا نوٹ\u2069 · کل باقی قرض',
    );
  });
}
