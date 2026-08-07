import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';

void main(){
  tearDown(()=>MizanI18n.setProfile(languageTag:'tr',currencyCode:'TRY'));

  const tags=<String>['tr','en','es','pt-BR','pt-PT','fr','de','it','nl','pl','ro','el','ru','uk','ar','fa','he','hi','bn','ur','id','ms'];

  test('exactly 22 integrated locale options are registered',(){
    expect(MizanI18n.supportedLanguageTags,tags.toSet());
    expect(MizanI18n.supportedLanguageTags,hasLength(22));
  });

  test('every integrated language owns navigation report and notification copy',(){
    final snapshots=<String,List<String>>{};
    for(final tag in tags){
      MizanI18n.setProfile(languageTag:tag,currencyCode:'USD');
      final values=<String>[
        MizanI18n.text('Ana sayfa'),
        MizanI18n.text('Kayıtlar'),
        MizanI18n.text('Giderler'),
        MizanI18n.text('Raporlar'),
        MizanI18n.text('Ayarlar'),
        MizanI18n.text('Bildirim sistemi'),
        MizanI18n.text('PDF raporu'),
        MizanI18n.text('Kalan ödeme yükü'),
      ];
      expect(values.every((value)=>value.trim().isNotEmpty),isTrue,reason:tag);
      if(tag!='tr'){
        expect(values,contains(isNot('Raporlar')),reason:tag);
        expect(values.where((value)=>const{'Ana sayfa','Kayıtlar','Giderler','Raporlar','Ayarlar'}.contains(value)).length,lessThan(3),reason:'Turkish leakage in $tag');
      }
      snapshots[tag]=values;
    }
    for(var i=0;i<tags.length;i++){
      for(var j=i+1;j<tags.length;j++){
        expect(snapshots[tags[i]],isNot(equals(snapshots[tags[j]])),reason:'${tags[i]} and ${tags[j]} unexpectedly share the complete system snapshot');
      }
    }
  });

  test('script-specific languages stay in their own script',(){
    final checks=<String,RegExp>{
      'el':RegExp(r'[\u0370-\u03ff]'),'ru':RegExp(r'[\u0400-\u04ff]'),'uk':RegExp(r'[\u0400-\u04ff]'),
      'ar':RegExp(r'[\u0600-\u06ff]'),'fa':RegExp(r'[\u0600-\u06ff]'),'ur':RegExp(r'[\u0600-\u06ff]'),
      'he':RegExp(r'[\u0590-\u05ff]'),'hi':RegExp(r'[\u0900-\u097f]'),'bn':RegExp(r'[\u0980-\u09ff]'),
    };
    for(final entry in checks.entries){
      MizanI18n.setProfile(languageTag:entry.key,currencyCode:'USD');
      final joined=['Ana sayfa','Giderler','Raporlar','Ayarlar','Bildirim sistemi'].map(MizanI18n.text).join(' ');
      expect(entry.value.hasMatch(joined),isTrue,reason:entry.key);
    }
  });

  test('switching languages never retains the previous language snapshot',(){
    List<String>? previous;
    String? previousTag;
    for(final tag in tags){
      MizanI18n.setProfile(languageTag:tag,currencyCode:'USD');
      final current=['Ana sayfa','Giderler','Ayarlar','Bildirim sistemi'].map(MizanI18n.text).toList();
      if(previous!=null)expect(current,isNot(equals(previous)),reason:'$previousTag -> $tag');
      previous=current;previousTag=tag;
    }
  });
}
