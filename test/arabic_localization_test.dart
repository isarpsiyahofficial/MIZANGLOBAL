import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ar.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Arabic source contains exactly 791 reviewed static values', () {
    expect(mizanArabic.length, 791);
    expect(
      mizanArabic.values.every((value) => value.trim().isNotEmpty),
      isTrue,
    );
  });

  test('Arabic is enabled and regional aliases resolve to it', () {
    expect(MizanI18n.isSupported('ar'), isTrue);
    expect(MizanI18n.isSupported('ar-SA'), isTrue);
    expect(MizanI18n.isSupported('ar_EG'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('AR_ae'), 'ar');
  });

  test('Arabic uses clear Modern Standard Arabic financial terminology', () {
    MizanI18n.setProfile(languageTag: 'ar', currencyCode: 'SAR');

    expect(MizanI18n.text('Ana sayfa'), 'الصفحة الرئيسية');
    expect(MizanI18n.text('Kayıtlar'), 'السجلات');
    expect(MizanI18n.text('Giderler'), 'المصروفات');
    expect(MizanI18n.text('Raporlar'), 'التقارير');
    expect(MizanI18n.text('Ayarlar'), 'الإعدادات');
    expect(MizanI18n.text('Kaydet'), 'حفظ');
    expect(MizanI18n.text('Gelir'), 'دخل');
    expect(MizanI18n.text('Abonelik'), 'اشتراك');
    expect(MizanI18n.text('Ev kredisi'), 'قرض سكني');
    expect(MizanI18n.text('KMH hesabı'), 'حساب سحب على المكشوف');
    expect(MizanI18n.text('Çek'), 'شيك مصرفي');
    expect(MizanI18n.text('Senet'), 'سند لأمر');
    expect(MizanI18n.destructiveConfirmation, 'أؤكد');
  });

  test('Arabic dynamic copy applies all six cardinal plural categories', () {
    MizanI18n.setProfile(languageTag: 'ar', currencyCode: 'SAR');

    expect(MizanI18n.text('0 gün kaldı'), 'موعد الاستحقاق اليوم');
    expect(MizanI18n.text('1 gün kaldı'), 'يتبقى يوم واحد');
    expect(MizanI18n.text('2 gün kaldı'), 'يتبقى يومان');
    expect(MizanI18n.text('3 gün kaldı'), 'يتبقى 3 أيام');
    expect(MizanI18n.text('11 gün kaldı'), 'يتبقى 11 يوما');
    expect(MizanI18n.text('102 gün kaldı'), 'يتبقى 102 يوم');

    expect(MizanI18n.text('0 ödeme'), 'لا دفعات');
    expect(MizanI18n.text('1 ödeme'), 'دفعة واحدة');
    expect(MizanI18n.text('2 ödeme'), 'دفعتان');
    expect(MizanI18n.text('5 ödeme'), '5 دفعات');
    expect(MizanI18n.text('11 ödeme'), '11 دفعة');
    expect(MizanI18n.text('100 ödeme'), '100 دفعة');

    expect(MizanI18n.text('1 kişi seçili'), 'تم تحديد شخص واحد');
    expect(MizanI18n.text('2 kişi seçili'), 'تم تحديد شخصان');
    expect(MizanI18n.text('5 kişi seçili'), 'تم تحديد 5 أشخاص');
    expect(MizanI18n.text('1 açık kayıt · SAR 20'), 'سجل مفتوح واحد · SAR 20');
    expect(MizanI18n.text('2 açık kayıt · SAR 20'), 'سجلان مفتوحان · SAR 20');
    expect(MizanI18n.text('Ayın 1. günü'), 'اليوم 1 من الشهر');
    expect(MizanI18n.text('Her ayın 2. günü'), 'اليوم 2 من كل شهر');
  });

  test('Arabic number date currency and parser formats are locale-aware', () {
    MizanI18n.setProfile(languageTag: 'ar', currencyCode: 'SAR');

    expect(money(1234567.5), '١٬٢٣٤٬٥٦٧٫٥٠\u00A0ر.س');
    expect(decimalText(1250.5), '١٬٢٥٠٫٥٠');
    expect(shortDate(DateTime(2026, 8, 1)), '١ أغسطس ٢٠٢٦');
    expect(monthLabel(DateTime(2026, 3)), 'مارس ٢٠٢٦');
    expect(parseMoney('١٬٢٣٤٫٥٠'), 1234.5);
    expect(parseMoney('۱۲۳۴٫۵۰'), 1234.5);

    MizanI18n.setProfile(languageTag: 'ar', currencyCode: 'USD');
    expect(money(1234.5), '١٬٢٣٤٫٥٠\u00A0\u2066USD\u2069');
  });

  test(
    'Arabic catalogs display names and retain Arabic and Latin aliases',
    () async {
      MizanI18n.setProfile(languageTag: 'ar', currencyCode: 'SAR');
      final catalog = await GlobalCatalogRepository.load();

      expect(catalog.language('ar').nameFor('ar'), 'العربية');
      expect(catalog.language('uk').nameFor('ar'), contains('الأوكرانية'));
      expect(catalog.country('SA').nameFor('ar'), 'المملكة العربية السعودية');
      expect(catalog.country('UA').nameFor('ar'), 'أوكرانيا');
      expect(catalog.currency('SAR').nameFor('ar'), 'الريال السعودي');
      expect(catalog.currency('USD').nameFor('ar'), 'الدولار الأمريكي');
      expect(
        catalog.currencies
            .where((item) => item.matches('دولار أمريكي'))
            .singleWhere((item) => item.code == 'USD')
            .nameFor('ar'),
        'الدولار الأمريكي',
      );
      expect(
        catalog.currencies
            .where((item) => item.matches('riyal'))
            .singleWhere((item) => item.code == 'SAR')
            .nameFor('ar'),
        'الريال السعودي',
      );
    },
  );

  test('Arabic preserves user text and adds only visible bidi isolation', () {
    MizanI18n.setProfile(languageTag: 'ar', currencyCode: 'SAR');
    final encoded = MizanI18n.user('Bank 24 - ملاحظة العميل');
    final visible = MizanI18n.text(encoded);

    expect(encoded, startsWith('\u{E000}'));
    expect(encoded, endsWith('\u{E001}'));
    expect(visible, '\u2068Bank 24 - ملاحظة العميل\u2069');
    expect(
      MizanI18n.text('$encoded · Kalan toplam borç'),
      '\u2068Bank 24 - ملاحظة العميل\u2069 · إجمالي الدين المتبقي',
    );
  });

  test(
    'Arabic output contains no Turkish Russian Ukrainian Persian or Hebrew UI',
    () {
      MizanI18n.setProfile(languageTag: 'ar', currencyCode: 'SAR');
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
      for (final leak in <String>[
        'Ayarlar',
        'Ödemeler',
        'Настройки',
        'Платежи',
        'Налаштування',
        'Звіти',
        'تنظیمات',
        'پرداخت',
        'הגדרות',
        'پ',
        'چ',
        'ژ',
        'گ',
      ]) {
        expect(visible.toLowerCase(), isNot(contains(leak.toLowerCase())));
      }
    },
  );

  test('Arabic notification copy matches exact and fallback scheduling', () {
    MizanI18n.setProfile(languageTag: 'ar', currencyCode: 'SAR');

    expect(
      MizanI18n.text(
        'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.',
      ),
      contains('جدولة تقريبية'),
    );
    expect(
      MizanI18n.text(
        'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.',
      ),
      'لم يمنح إذن التنبيهات الدقيقة. ستتم جدولة الاختبار بصورة تقريبية.',
    );
  });
}
