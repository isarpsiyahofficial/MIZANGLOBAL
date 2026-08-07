import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ar.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_bn.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_de.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_el.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_es.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_fa.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_fr.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_he.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_hi.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_it.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ms.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_nl.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_pl.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_pt_br.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_pt_pt.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ro.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ru.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_uk.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_ur.dart';

void main(){
  final maps=<String,Map<String,String>>{
    'es':mizanSpanish,'pt-BR':mizanPortugueseBr,'pt-PT':mizanPortuguesePt,'fr':mizanFrench,'de':mizanGerman,'it':mizanItalian,'nl':mizanDutch,'pl':mizanPolish,'ro':mizanRomanian,'el':mizanGreek,'ru':mizanRussian,'uk':mizanUkrainian,'ar':mizanArabic,'fa':mizanPersian,'he':mizanHebrew,'hi':mizanHindi,'bn':mizanBengali,'ur':mizanUrdu,'id':mizanIndonesian,'ms':mizanMalay,
  };
  final reference=mizanSpanish.keys.toSet();

  test('20 static localized maps share the exact 791 stable system keys',(){
    expect(reference,hasLength(791));
    for(final entry in maps.entries){
      expect(entry.value,hasLength(791),reason:entry.key);
      expect(entry.value.keys.toSet(),reference,reason:entry.key);
      expect(entry.value.values.every((value)=>value.trim().isNotEmpty),isTrue,reason:entry.key);
    }
  });

  test('English covers the same 791 source keys without empty fallback',(){
    MizanI18n.setProfile(languageTag:'en',currencyCode:'USD');
    final values=<String>[];var changed=0;
    for(final key in reference){final value=MizanI18n.text(key);values.add(value);if(value!=key)changed++;}
    expect(values,hasLength(791));expect(values.every((value)=>value.trim().isNotEmpty),isTrue);expect(changed,greaterThan(740));
  });

  test('Turkish stable source remains the reference and is never rewritten',(){
    MizanI18n.setProfile(languageTag:'tr',currencyCode:'TRY');
    for(final key in reference)expect(MizanI18n.text(key),key);
  });
}
