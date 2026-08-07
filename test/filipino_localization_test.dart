import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/global/global_catalog.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_fil.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(()=>MizanI18n.setProfile(languageTag:'tr',currencyCode:'TRY'));
  test('Filipino source is complete and key-identical to the 791 product set',(){
    expect(mizanFilipino,hasLength(791));
    expect(mizanFilipino.keys.toSet(),mizanIndonesian.keys.toSet());
    expect(mizanFilipino.values.every((v)=>v.trim().isNotEmpty),isTrue);
    final values=mizanFilipino.values.join('\n');
    expect(RegExp(r'[\u0370-\u052f\u0590-\u0dff\u2e80-\u9fff\uac00-\ud7af]').hasMatch(values),isFalse);
    for(final residue in const ['pengeluaran','pembayaran','catatan','tagihan','cicilan','notifikasi','pengingat','perbelanjaan','hutang','pemberitahuan','peringatan','tetapan','ansuran']){
      expect(values.toLowerCase(),isNot(contains(residue)),reason:residue);
    }
  });
  test('Filipino locale variants and Tagalog compatibility resolve safely',(){
    expect(MizanI18n.isSupported('fil'),isTrue);expect(MizanI18n.isSupported('fil-PH'),isTrue);expect(MizanI18n.isSupported('tl-PH'),isTrue);
    expect(MizanI18n.normalizeLanguageTag('FIL_ph'),'fil');expect(MizanI18n.normalizeLanguageTag('tl_PH'),'fil');
  });
  test('Filipino finance and report terms are distinct and natural',(){
    MizanI18n.setProfile(languageTag:'fil-PH',currencyCode:'PHP');
    expect(MizanI18n.text('Ana sayfa'),'Simula');expect(MizanI18n.text('Kayıtlar'),'Mga tala');expect(MizanI18n.text('Giderler'),'Mga gastusin');expect(MizanI18n.text('Raporlar'),'Mga ulat');expect(MizanI18n.text('Ayarlar'),'Mga setting');
    expect(MizanI18n.text('Banka borcu'),'Utang sa bangko');expect(MizanI18n.text('Kalan ödeme yükü'),'Natitirang obligasyon sa pagbabayad');expect(MizanI18n.text('Gecikmiş ödeme yükü'),'Overdue na obligasyon sa pagbabayad');expect(MizanI18n.destructiveConfirmation,'KINUKUMPIRMA KO');
    expect(MizanI18n.text('3 gün kaldı'),'3 araw na lang');expect(MizanI18n.text('Ödeme 5 gün gecikti.'),'Overdue ng 5 araw ang bayad.');
  });
  test('Philippine peso, numbers and Gregorian dates follow PH conventions',(){
    MizanI18n.setProfile(languageTag:'fil',currencyCode:'PHP');
    expect(money(1234567.5),'₱1,234,567.50');expect(decimalText(1234567.5),'1,234,567.50');
    expect(shortDate(DateTime(2026,8,7)),'Ago 7, 2026');expect(monthLabel(DateTime(2026,8)),'Agosto 2026');
    expect(parseMoney('₱1,234,567.50'),1234567.5);expect(parseMoney('PHP 1,234,567.50'),1234567.5);
    MizanI18n.setProfile(languageTag:'fil',currencyCode:'USD');expect(money(1234.5),'USD\u00A01,234.50');
  });
  test('Filipino offline catalogs contain every global selector item',()async{
    MizanI18n.setProfile(languageTag:'fil',currencyCode:'PHP');final catalog=await GlobalCatalogRepository.load();
    expect(catalog.languages,hasLength(29));expect(catalog.countries,hasLength(161));expect(catalog.currencies,hasLength(154));
    expect(catalog.language('fil').nameFor('fil'),'Filipino');expect(catalog.country('PH').nameFor('fil'),'Pilipinas');expect(catalog.currency('PHP').nameFor('fil'),'Piso ng Pilipinas');
    expect(catalog.countries.where((e)=>e.matches('Pilip')).any((e)=>e.code=='PH'),isTrue);expect(catalog.currencies.where((e)=>e.matches('Piso')).any((e)=>e.code=='PHP'),isTrue);
  });
  test('language switching never leaks Filipino into prior languages',(){
    MizanI18n.setLanguageTag('fil');expect(MizanI18n.text('Raporlar'),'Mga ulat');
    MizanI18n.setLanguageTag('tr');expect(MizanI18n.text('Raporlar'),'Raporlar');
    MizanI18n.setLanguageTag('en');expect(MizanI18n.text('Raporlar'),'Reports');
    MizanI18n.setLanguageTag('id');expect(MizanI18n.text('Raporlar'),'Laporan');
    MizanI18n.setLanguageTag('ms');expect(MizanI18n.text('Raporlar'),'Laporan');
    MizanI18n.setLanguageTag('ar');expect(MizanI18n.text('Raporlar'),isNot('Mga ulat'));
  });
  test('user-authored mixed text remains byte-visible and untranslated',(){
    MizanI18n.setProfile(languageTag:'fil',currencyCode:'PHP');final encoded=MizanI18n.user('BDO 24 - Tala ni Ana 中文 한국어 日本語');
    expect(MizanI18n.text(encoded),'BDO 24 - Tala ni Ana 中文 한국어 日本語');
    expect(MizanI18n.text('$encoded · Kalan toplam borç'),'BDO 24 - Tala ni Ana 中文 한국어 日本語 · Kabuuang natitirang utang');
  });
}
