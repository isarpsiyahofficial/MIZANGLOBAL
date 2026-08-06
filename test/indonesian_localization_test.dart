import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Indonesian source contains exactly 791 complete static values', () {
    expect(mizanIndonesian.length, 791);
    expect(mizanIndonesian.values.every((value) => value.trim().isNotEmpty), isTrue);
    final values = mizanIndonesian.values.join('\n');
    expect(RegExp(r'[\u0400-\u052f\u0590-\u0dff\u2e80-\u9fff]').hasMatch(values), isFalse);
    for (final forbidden in const [
      '\u200b', '\u200c', '\u200d', '\u200e', '\u200f',
      '\u202a', '\u202b', '\u202c', '\u202d', '\u202e',
      '\u2066', '\u2067', '\u2068', '\u2069',
    ]) {
      expect(values, isNot(contains(forbidden)));
    }
  });

  test('Indonesian locale variants resolve to one LTR runtime', () {
    expect(MizanI18n.isSupported('id'), isTrue);
    expect(MizanI18n.isSupported('id-ID'), isTrue);
    expect(MizanI18n.isSupported('in-ID'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('ID_id'), 'id');
    expect(MizanI18n.normalizeLanguageTag('in_ID'), 'id');
  });

  test('Indonesian uses stable natural financial terminology', () {
    MizanI18n.setProfile(languageTag: 'id', currencyCode: 'IDR');
    expect(MizanI18n.text('Ana sayfa'), 'Beranda');
    expect(MizanI18n.text('Kayıtlar'), 'Catatan');
    expect(MizanI18n.text('Giderler'), 'Pengeluaran');
    expect(MizanI18n.text('Raporlar'), 'Laporan');
    expect(MizanI18n.text('Ayarlar'), 'Pengaturan');
    expect(MizanI18n.text('Kaydet'), 'Simpan');
    expect(MizanI18n.text('Banka borcu'), 'Utang bank');
    expect(MizanI18n.text('Fatura'), 'Tagihan');
    expect(MizanI18n.text('Abonelik'), 'Langganan');
    expect(MizanI18n.text('Kalan ödeme yükü'), 'Sisa kewajiban pembayaran');
    expect(MizanI18n.text('Gecikmiş ödeme yükü'), 'Kewajiban pembayaran terlambat');
    expect(MizanI18n.text('Yaklaşan ödeme yükü'), 'Kewajiban pembayaran mendatang');
    expect(MizanI18n.destructiveConfirmation, 'SAYA SETUJU');
  });

  test('Indonesian dynamic grammar uses clear counts and states', () {
    MizanI18n.setProfile(languageTag: 'id', currencyCode: 'IDR');
    expect(MizanI18n.text('3 gün kaldı'), '3 hari lagi');
    expect(MizanI18n.text('2 ödeme'), '2 pembayaran');
    expect(
      MizanI18n.text('Daha fazla gün göster (4 kaldı)'),
      'Tampilkan hari lainnya (4 tersisa)',
    );
    expect(MizanI18n.text('Ödeme 5 gün gecikti.'), 'Pembayaran terlambat 5 hari.');
    expect(
      MizanI18n.text('LEFFERION PRIME - MİZAN · Sayfa 3'),
      'LEFFERION PRIME - MİZAN · Halaman 3',
    );
  });

  test('Indonesian money numbers and Gregorian dates follow Indonesia conventions', () {
    MizanI18n.setProfile(languageTag: 'id', currencyCode: 'IDR');
    expect(money(1234567.5), 'Rp1.234.567,50');
    expect(decimalText(1234567.5), '1.234.567,50');
    expect(decimalText(12.5), '12,50');
    expect(shortDate(DateTime(2026, 8, 6)), '6 Agu 2026');
    expect(monthLabel(DateTime(2026, 8)), 'Agustus 2026');
    expect(parseMoney('Rp1.234.567,50'), 1234567.5);
    expect(parseMoney('IDR 1.234.567,50'), 1234567.5);

    MizanI18n.setProfile(languageTag: 'id', currencyCode: 'USD');
    expect(money(1234567.5), 'USD\u00A01.234.567,50');
  });

  test('Indonesian catalogs are complete natural and searchable offline', () async {
    MizanI18n.setProfile(languageTag: 'id', currencyCode: 'IDR');
    final catalog = await GlobalCatalogRepository.load();
    expect(catalog.languages.length, greaterThanOrEqualTo(29));
    expect(catalog.countries, hasLength(161));
    expect(catalog.currencies, hasLength(154));
    expect(catalog.languages.every((item) => item.nameFor('id').trim().isNotEmpty), isTrue);
    expect(catalog.countries.every((item) => item.nameFor('id').trim().isNotEmpty), isTrue);
    expect(catalog.currencies.every((item) => item.nameFor('id').trim().isNotEmpty), isTrue);
    expect(catalog.language('id').nameFor('id').toLowerCase(), contains('indonesia'));
    expect(catalog.country('ID').nameFor('id'), 'Indonesia');
    expect(catalog.currency('IDR').nameFor('id').toLowerCase(), contains('rupiah'));
    expect(
      catalog.countries.where((item) => item.matches('Indonesia')).any((item) => item.code == 'ID'),
      isTrue,
    );
    expect(
      catalog.currencies.where((item) => item.matches('rupiah')).any((item) => item.code == 'IDR'),
      isTrue,
    );
  });

  test('Indonesian preserves user-authored multilingual text unchanged', () {
    MizanI18n.setProfile(languageTag: 'id', currencyCode: 'IDR');
    final encoded = MizanI18n.user('Bank 24 - Catatan Budi 中文 العربية');
    final visible = MizanI18n.text(encoded);
    expect(visible, 'Bank 24 - Catatan Budi 中文 العربية');
    expect(
      MizanI18n.text('$encoded · Kalan toplam borç'),
      'Bank 24 - Catatan Budi 中文 العربية · Total sisa utang',
    );
  });

  test('Indonesian report PDF and exact-alarm copy stays distinct', () {
    MizanI18n.setProfile(languageTag: 'id', currencyCode: 'IDR');
    expect(
      MizanI18n.text('Kalan ödeme yükünün dağılımı'),
      'Distribusi sisa kewajiban pembayaran',
    );
    expect(
      MizanI18n.text('Dönem ve kişi filtresi ekrandaki verilerle PDF’de birebir aynıdır.'),
      contains('PDF'),
    );
    expect(
      MizanI18n.text('Normal giderler ve ödemeler ayrı başlıklar altında kalır; yalnız toplam hesaplamada birleşir.'),
      allOf(contains('terpisah'), contains('total')),
    );
    expect(
      MizanI18n.text('Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.'),
      allOf(contains('Android'), contains('tepat waktu'), contains('perkiraan')),
    );
  });

  test('switching languages never leaks Indonesian into Turkish Arabic or English', () {
    MizanI18n.setLanguageTag('id');
    expect(MizanI18n.text('Raporlar'), 'Laporan');
    MizanI18n.setLanguageTag('tr');
    expect(MizanI18n.text('Raporlar'), 'Raporlar');
    MizanI18n.setLanguageTag('en');
    expect(MizanI18n.text('Raporlar'), 'Reports');
    MizanI18n.setLanguageTag('ar');
    final arabic = MizanI18n.text('Raporlar');
    expect(arabic, isNot('Laporan'));
    expect(RegExp(r'[\u0600-\u06ff]').hasMatch(arabic), isTrue);
  });
}
