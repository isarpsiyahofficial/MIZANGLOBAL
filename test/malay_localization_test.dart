import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ms.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(()=>MizanI18n.setProfile(languageTag:'tr',currencyCode:'TRY'));

  test('Malay covers exactly the same 791 stable keys',(){
    expect(mizanIndonesian.length,791);
    expect(mizanMalay.length,791);
    expect(mizanMalay.keys.toSet(),mizanIndonesian.keys.toSet());
    expect(mizanMalay.values.every((value)=>value.trim().isNotEmpty),isTrue);
    final joined=mizanMalay.values.join('\n').toLowerCase();
    for(final indonesianOnly in const['pengeluaran','pengaturan','utang','tagihan','cicilan','perusahaan','notifikasi','pengingat','perangkat','cadangan','riwayat','hapus','pribadi','layanan','asuransi','kendaraan','rekening','kartu','nomor','terlambat','mendatang','dibagikan','perkiraan']){
      final token=RegExp('(?<![a-z])${RegExp.escape(indonesianOnly)}(?![a-z])');
      expect(token.hasMatch(joined),isFalse,reason:indonesianOnly);
    }
  });

  test('Malay locale and core product terminology are stable',(){
    expect(MizanI18n.isSupported('ms'),isTrue);
    expect(MizanI18n.isSupported('ms-MY'),isTrue);
    expect(MizanI18n.normalizeLanguageTag('MS_my'),'ms');
    MizanI18n.setProfile(languageTag:'ms-MY',currencyCode:'MYR');
    expect(MizanI18n.text('Ana sayfa'),'Laman utama');
    expect(MizanI18n.text('Kayıtlar'),'Rekod');
    expect(MizanI18n.text('Giderler'),'Perbelanjaan');
    expect(MizanI18n.text('Raporlar'),'Laporan');
    expect(MizanI18n.text('Ayarlar'),'Tetapan');
    expect(MizanI18n.text('Banka borcu'),'Hutang bank');
    expect(MizanI18n.text('Fatura'),'Bil');
    expect(MizanI18n.text('Kira / taksit'),'Sewa / Ansuran');
    expect(MizanI18n.destructiveConfirmation,'SAYA SAHKAN');
  });

  test('Malay money numbers and Gregorian dates follow Malaysia conventions',(){
    MizanI18n.setProfile(languageTag:'ms',currencyCode:'MYR');
    expect(money(1234567.5),'RM1,234,567.50');
    expect(decimalText(1234567.5),'1,234,567.50');
    expect(shortDate(DateTime(2026,8,7)),'7 Ogo 2026');
    expect(monthLabel(DateTime(2026,8)),'Ogos 2026');
    expect(parseMoney('RM1,234,567.50'),1234567.5);
    expect(parseMoney('MYR 1,234,567.50'),1234567.5);
  });

  test('Malay dynamic payment states do not fall back to Turkish or Indonesian',(){
    MizanI18n.setProfile(languageTag:'ms',currencyCode:'MYR');
    expect(MizanI18n.text('3 gün kaldı'),contains('3'));
    expect(MizanI18n.text('3 gün kaldı'),isNot(contains('gün')));
    expect(MizanI18n.text('Ödeme 5 gün gecikti.'),isNot(contains('Pembayaran terlambat')));
    expect(MizanI18n.text('Ödeme 5 gün gecikti.'),isNot(contains('Ödeme')));
  });

  test('Malay catalogs are complete offline and native-searchable',()async{
    MizanI18n.setProfile(languageTag:'ms',currencyCode:'MYR');
    final catalog=await GlobalCatalogRepository.load();
    expect(catalog.languages,hasLength(29));
    expect(catalog.countries,hasLength(161));
    expect(catalog.currencies,hasLength(154));
    expect(catalog.language('ms').nameFor('ms'),'Melayu');
    expect(catalog.country('MY').nameFor('ms'),'Malaysia');
    expect(catalog.currency('MYR').nameFor('ms'),'Ringgit Malaysia');
    expect(catalog.countries.every((item)=>item.nameFor('ms').trim().isNotEmpty),isTrue);
    expect(catalog.currencies.every((item)=>item.nameFor('ms').trim().isNotEmpty),isTrue);
    expect(catalog.currencies.where((item)=>item.matches('ringgit')).any((item)=>item.code=='MYR'),isTrue);
  });

  test('Malay report PDF notification and backup vocabulary is separated',(){
    MizanI18n.setProfile(languageTag:'ms',currencyCode:'MYR');
    expect(MizanI18n.text('Kalan ödeme yükü'),'Baki komitmen pembayaran');
    expect(MizanI18n.text('PDF raporu'),'Laporan PDF');
    expect(MizanI18n.text('Bildirim sistemi'),'Sistem pemberitahuan');
    expect(MizanI18n.text('CSV yedekleme'),'Sandaran CSV');
    expect(MizanI18n.text('Günlük gider hatırlatmaları'),'Peringatan perbelanjaan harian');
  });

  test('Malay preserves multilingual user text unchanged',(){
    MizanI18n.setProfile(languageTag:'ms',currencyCode:'MYR');
    final raw='Bank 24 - Nota Aisyah 中文 العربية';
    expect(MizanI18n.text(MizanI18n.user(raw)),raw);
  });
}
