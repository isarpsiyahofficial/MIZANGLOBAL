import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_fa.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Persian source contains exactly 791 reviewed static values', () {
    expect(mizanPersian.length, 791);
    expect(
      mizanPersian.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
    final values = mizanPersian.values.join('\n');
    for (final forbidden in <String>[
      'ي',
      'ى',
      'ك',
      'ے',
      'ہ',
      'ھ',
      'ں',
      'ٹ',
      'ڈ',
      'ڑ',
    ]) {
      expect(values, isNot(contains(forbidden)));
    }
  });

  test('Persian is enabled and regional aliases resolve to it', () {
    expect(MizanI18n.isSupported('fa'), isTrue);
    expect(MizanI18n.isSupported('fa-IR'), isTrue);
    expect(MizanI18n.isSupported('fa_AF'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('FA_ir'), 'fa');
  });

  test('Persian uses reviewed Iranian financial terminology', () {
    MizanI18n.setProfile(languageTag: 'fa', currencyCode: 'IRR');
    expect(MizanI18n.text('Ana sayfa'), 'صفحه اصلی');
    expect(MizanI18n.text('Kayıtlar'), 'رکوردها');
    expect(MizanI18n.text('Giderler'), 'هزینه‌ها');
    expect(MizanI18n.text('Raporlar'), 'گزارش‌ها');
    expect(MizanI18n.text('Ayarlar'), 'تنظیمات');
    expect(MizanI18n.text('Kaydet'), 'ذخیره');
    expect(MizanI18n.text('Banka borcu'), 'بدهی بانکی');
    expect(MizanI18n.text('Fatura'), 'قبض');
    expect(MizanI18n.text('Abonelik'), 'اشتراک');
    expect(MizanI18n.destructiveConfirmation, 'تأیید می‌کنم');
  });

  test('Persian dynamic copy follows one-other and singular noun usage', () {
    MizanI18n.setProfile(languageTag: 'fa', currencyCode: 'IRR');
    expect(MizanI18n.text('0 gün kaldı'), 'سررسید امروز است');
    expect(MizanI18n.text('1 gün kaldı'), 'یک روز باقی مانده');
    expect(MizanI18n.text('2 gün kaldı'), '۲ روز باقی مانده');
    expect(MizanI18n.text('11 gün kaldı'), '۱۱ روز باقی مانده');
    expect(MizanI18n.text('102 gün kaldı'), '۱۰۲ روز باقی مانده');
    expect(MizanI18n.text('0 ödeme'), 'بدون پرداخت');
    expect(MizanI18n.text('1 ödeme'), 'یک پرداخت');
    expect(MizanI18n.text('2 ödeme'), '۲ پرداخت');
    expect(MizanI18n.text('5 kişi seçili'), '۵ شخص انتخاب شده');
    expect(MizanI18n.text('2 açık kayıt · IRR 20'), '۲ رکورد باز · IRR 20');
    expect(MizanI18n.text('Ayın 1. günü'), 'روز ۱ ماه');
    expect(MizanI18n.text('Her ayın 20. günü'), 'روز ۲۰ هر ماه');
  });

  test('Persian number money parser and Gregorian dates are locale-aware', () {
    MizanI18n.setProfile(languageTag: 'fa', currencyCode: 'IRR');
    expect(money(1234567.5), '۱٬۲۳۴٬۵۶۷٫۵۰\u00A0ریال');
    expect(decimalText(1250.5), '۱٬۲۵۰٫۵۰');
    expect(shortDate(DateTime(2026, 8, 1)), '۱ اوت ۲۰۲۶');
    expect(monthLabel(DateTime(2026, 3)), 'مارس ۲۰۲۶');
    expect(parseMoney('۱٬۲۳۴٫۵۰'), 1234.5);
    expect(parseMoney('١٬٢٣٤٫٥٠'), 1234.5);
    expect(parseOptionalPositiveInt('۱۲'), 12);
    expect(parsePositiveDecimal('۱۲٫۵'), 12.5);

    MizanI18n.setProfile(languageTag: 'fa', currencyCode: 'USD');
    expect(money(1234.5), '۱٬۲۳۴٫۵۰\u00A0\u2066USD\u2069');
  });

  test('Persian catalogs are complete and searchable offline', () async {
    MizanI18n.setProfile(languageTag: 'fa', currencyCode: 'IRR');
    final catalog = await GlobalCatalogRepository.load();
    expect(catalog.languages, hasLength(29));
    expect(catalog.countries, hasLength(161));
    expect(catalog.currencies, hasLength(154));
    expect(
      catalog.languages.every((item) => item.nameFor('fa').trim().isNotEmpty),
      isTrue,
    );
    expect(
      catalog.countries.every((item) => item.nameFor('fa').trim().isNotEmpty),
      isTrue,
    );
    expect(
      catalog.currencies.every((item) => item.nameFor('fa').trim().isNotEmpty),
      isTrue,
    );
    expect(catalog.language('fa').nameFor('fa'), 'فارسی');
    expect(catalog.country('IR').nameFor('fa'), contains('ایران'));
    expect(catalog.currency('IRR').nameFor('fa'), contains('ریال'));
    expect(
      catalog.countries
          .where((item) => item.matches('ایران'))
          .any((item) => item.code == 'IR'),
      isTrue,
    );
    expect(
      catalog.currencies
          .where((item) => item.matches('ریال'))
          .any((item) => item.code == 'IRR'),
      isTrue,
    );
  });

  test('Persian preserves user text and adds only visible bidi isolation', () {
    MizanI18n.setProfile(languageTag: 'fa', currencyCode: 'IRR');
    final encoded = MizanI18n.user('Bank 24 - یادداشت مشتری');
    final visible = MizanI18n.text(encoded);
    expect(encoded, startsWith('\u{E000}'));
    expect(encoded, endsWith('\u{E001}'));
    expect(visible, '\u2068Bank 24 - یادداشت مشتری\u2069');
    expect(
      MizanI18n.text('$encoded · Kalan toplam borç'),
      '\u2068Bank 24 - یادداشت مشتری\u2069 · مجموع بدهی باقی‌مانده',
    );
  });

  test('Persian notification copy matches exact and fallback scheduling', () {
    MizanI18n.setProfile(languageTag: 'fa', currencyCode: 'IRR');
    expect(
      MizanI18n.text(
        'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.',
      ),
      contains('زمان‌بندی تقریبی'),
    );
    expect(
      MizanI18n.text(
        'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.',
      ),
      'مجوز زمان‌بندی دقیق داده نشد. آزمون با زمان‌بندی تقریبی اجرا می‌شود.',
    );
  });
}
