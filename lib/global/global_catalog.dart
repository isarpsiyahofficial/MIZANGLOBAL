import 'dart:convert';

import 'package:flutter/services.dart';

import '../l10n/id/mizan_id_catalog.dart';
import '../l10n/ur/mizan_ur_catalog.dart';

String normalizeGlobalSearch(String value) {
  var text = value.trim().toLowerCase();
  const replacements = <String, String>{
    'ç':'c','ğ':'g','ı':'i','ö':'o','ş':'s','ü':'u','á':'a','à':'a','â':'a','ä':'a','ã':'a','å':'a','æ':'ae','é':'e','è':'e','ê':'e','ë':'e','í':'i','ì':'i','î':'i','ï':'i','ó':'o','ò':'o','ô':'o','õ':'o','ø':'o','ú':'u','ù':'u','û':'u','ý':'y','ÿ':'y','ñ':'n','ß':'ss','œ':'oe',
  };
  replacements.forEach((source,target)=>text=text.replaceAll(source,target));
  return text.replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}]+',unicode:true),' ').trim();
}

bool _searchMatches(String query, Iterable<String> values) {
  final normalized=normalizeGlobalSearch(query);
  if(normalized.isEmpty)return true;
  for(final value in values){
    final candidate=normalizeGlobalSearch(value);
    if(candidate==normalized||candidate.startsWith(normalized))return true;
    if(candidate.split(' ').any((part)=>part.startsWith(normalized)))return true;
  }
  return false;
}

class LanguageOption {
  const LanguageOption({required this.code,required this.nativeName,required this.nameTr,required this.nameEn,required this.nameEs,required this.namePtBr,required this.namePtPt,required this.nameFr,required this.nameDe,required this.nameIt,required this.nameNl,required this.namePl,required this.nameRo,required this.nameEl,required this.nameRu,required this.nameUk,required this.nameAr,required this.nameFa,required this.nameHe,required this.nameHi,this.nameBn='',required this.countryCodes});
  final String code,nativeName,nameTr,nameEn,nameEs,namePtBr,namePtPt,nameFr,nameDe,nameIt,nameNl,namePl,nameRo,nameEl,nameRu,nameUk,nameAr,nameFa,nameHe,nameHi,nameBn;
  final List<String> countryCodes;
  factory LanguageOption.fromJson(Map<String,dynamic> json)=>LanguageOption(code:json['code']?.toString()??'',nativeName:json['nativeName']?.toString()??'',nameTr:json['nameTr']?.toString()??'',nameEn:json['nameEn']?.toString()??'',nameEs:json['nameEs']?.toString()??json['nameEn']?.toString()??'',namePtBr:json['namePtBr']?.toString()??json['nameEn']?.toString()??'',namePtPt:json['namePtPt']?.toString()??json['nameEn']?.toString()??'',nameFr:json['nameFr']?.toString()??json['nameEn']?.toString()??'',nameDe:json['nameDe']?.toString()??json['nameEn']?.toString()??'',nameIt:json['nameIt']?.toString()??json['nameEn']?.toString()??'',nameNl:json['nameNl']?.toString()??json['nameEn']?.toString()??'',namePl:json['namePl']?.toString()??json['nameEn']?.toString()??'',nameRo:json['nameRo']?.toString()??json['nameEn']?.toString()??'',nameEl:json['nameEl']?.toString()??json['nameEn']?.toString()??'',nameRu:json['nameRu']?.toString()??json['nameEn']?.toString()??'',nameUk:json['nameUk']?.toString()??json['nameEn']?.toString()??'',nameAr:json['nameAr']?.toString()??json['nameEn']?.toString()??'',nameFa:json['nameFa']?.toString()??json['nameEn']?.toString()??'',nameHe:json['nameHe']?.toString()??json['nameEn']?.toString()??'',nameHi:json['nameHi']?.toString()??json['nameEn']?.toString()??'',nameBn:json['nameBn']?.toString()??json['nameEn']?.toString()??'',countryCodes:((json['countryCodes'] as List?)??const[]).map((e)=>e.toString()).toList(growable:false));
  String nameFor(String languageTag)=>switch(languageTag){'en'=>nameEn,'es'=>nameEs,'pt-BR'=>namePtBr,'pt-PT'=>namePtPt,'fr'=>nameFr,'de'=>nameDe,'it'=>nameIt,'nl'=>nameNl,'pl'=>namePl,'ro'=>nameRo,'el'=>nameEl,'ru'=>nameRu,'uk'=>nameUk,'ar'=>nameAr,'fa'=>nameFa,'he'=>nameHe,'hi'=>nameHi,'bn'=>nameBn.isEmpty?nameEn:nameBn,'ur'=>urduLanguageNames[code]??nameEn,'id'=>indonesianLanguageNames[code]??nameEn,_=>nameTr};
  bool matches(String query)=>_searchMatches(query,[code,nativeName,nameTr,nameEn,nameEs,namePtBr,namePtPt,nameFr,nameDe,nameIt,nameNl,namePl,nameRo,nameEl,nameRu,nameUk,nameAr,nameFa,nameHe,nameHi,nameBn,urduLanguageNames[code]??'',indonesianLanguageNames[code]??'']);
}

class CountryOption {
  const CountryOption({required this.code,required this.nameTr,required this.nameEn,required this.nameEs,required this.namePtBr,required this.namePtPt,required this.nameFr,required this.nameDe,required this.nameIt,required this.nameNl,required this.namePl,required this.nameRo,required this.nameEl,required this.nameRu,required this.nameUk,required this.nameAr,required this.nameFa,required this.nameHe,required this.nameHi,this.nameBn='',required this.nativeName,required this.defaultLanguage,required this.supportedLanguages,required this.currencyCodes});
  final String code,nameTr,nameEn,nameEs,namePtBr,namePtPt,nameFr,nameDe,nameIt,nameNl,namePl,nameRo,nameEl,nameRu,nameUk,nameAr,nameFa,nameHe,nameHi,nameBn,nativeName,defaultLanguage;
  final List<String> supportedLanguages,currencyCodes;
  factory CountryOption.fromJson(Map<String,dynamic> json)=>CountryOption(code:json['code']?.toString()??'',nameTr:json['nameTr']?.toString()??'',nameEn:json['nameEn']?.toString()??'',nameEs:json['nameEs']?.toString()??json['nameEn']?.toString()??'',namePtBr:json['namePtBr']?.toString()??json['nameEn']?.toString()??'',namePtPt:json['namePtPt']?.toString()??json['nameEn']?.toString()??'',nameFr:json['nameFr']?.toString()??json['nameEn']?.toString()??'',nameDe:json['nameDe']?.toString()??json['nameEn']?.toString()??'',nameIt:json['nameIt']?.toString()??json['nameEn']?.toString()??'',nameNl:json['nameNl']?.toString()??json['nameEn']?.toString()??'',namePl:json['namePl']?.toString()??json['nameEn']?.toString()??'',nameRo:json['nameRo']?.toString()??json['nameEn']?.toString()??'',nameEl:json['nameEl']?.toString()??json['nameEn']?.toString()??'',nameRu:json['nameRu']?.toString()??json['nameEn']?.toString()??'',nameUk:json['nameUk']?.toString()??json['nameEn']?.toString()??'',nameAr:json['nameAr']?.toString()??json['nameEn']?.toString()??'',nameFa:json['nameFa']?.toString()??json['nameEn']?.toString()??'',nameHe:json['nameHe']?.toString()??json['nameEn']?.toString()??'',nameHi:json['nameHi']?.toString()??json['nameEn']?.toString()??'',nameBn:json['nameBn']?.toString()??json['nameEn']?.toString()??'',nativeName:json['nativeName']?.toString()??'',defaultLanguage:json['defaultLanguage']?.toString()??'en',supportedLanguages:((json['supportedLanguages'] as List?)??const[]).map((e)=>e.toString()).toList(growable:false),currencyCodes:((json['currencyCodes'] as List?)??const[]).map((e)=>e.toString()).toList(growable:false));
  String nameFor(String languageTag)=>switch(languageTag){'en'=>nameEn,'es'=>nameEs,'pt-BR'=>namePtBr,'pt-PT'=>namePtPt,'fr'=>nameFr,'de'=>nameDe,'it'=>nameIt,'nl'=>nameNl,'pl'=>namePl,'ro'=>nameRo,'el'=>nameEl,'ru'=>nameRu,'uk'=>nameUk,'ar'=>nameAr,'fa'=>nameFa,'he'=>nameHe,'hi'=>nameHi,'bn'=>nameBn.isEmpty?nameEn:nameBn,'ur'=>urduCountryNames[code]??nameEn,'id'=>indonesianCountryNames[code]??nameEn,_=>nameTr};
  bool matches(String query)=>_searchMatches(query,[code,nameTr,nameEn,nameEs,namePtBr,namePtPt,nameFr,nameDe,nameIt,nameNl,namePl,nameRo,nameEl,nameRu,nameUk,nameAr,nameFa,nameHe,nameHi,nameBn,urduCountryNames[code]??'',indonesianCountryNames[code]??'',nativeName]);
}

class CurrencyOption {
  const CurrencyOption({required this.code,required this.nameTr,required this.nameEn,required this.nameEs,required this.namePtBr,required this.namePtPt,required this.nameFr,required this.nameDe,required this.nameIt,required this.nameNl,required this.namePl,required this.nameRo,required this.nameEl,required this.nameRu,required this.nameUk,required this.nameAr,required this.nameFa,required this.nameHe,required this.nameHi,this.nameBn='',required this.symbols,required this.minorUnits,required this.aliases});
  final String code,nameTr,nameEn,nameEs,namePtBr,namePtPt,nameFr,nameDe,nameIt,nameNl,namePl,nameRo,nameEl,nameRu,nameUk,nameAr,nameFa,nameHe,nameHi,nameBn;
  final List<String> symbols,aliases; final int minorUnits;
  factory CurrencyOption.fromJson(Map<String,dynamic> json)=>CurrencyOption(code:json['code']?.toString()??'',nameTr:json['nameTr']?.toString()??'',nameEn:json['nameEn']?.toString()??'',nameEs:json['nameEs']?.toString()??json['nameEn']?.toString()??'',namePtBr:json['namePtBr']?.toString()??json['nameEn']?.toString()??'',namePtPt:json['namePtPt']?.toString()??json['nameEn']?.toString()??'',nameFr:json['nameFr']?.toString()??json['nameEn']?.toString()??'',nameDe:json['nameDe']?.toString()??json['nameEn']?.toString()??'',nameIt:json['nameIt']?.toString()??json['nameEn']?.toString()??'',nameNl:json['nameNl']?.toString()??json['nameEn']?.toString()??'',namePl:json['namePl']?.toString()??json['nameEn']?.toString()??'',nameRo:json['nameRo']?.toString()??json['nameEn']?.toString()??'',nameEl:json['nameEl']?.toString()??json['nameEn']?.toString()??'',nameRu:json['nameRu']?.toString()??json['nameEn']?.toString()??'',nameUk:json['nameUk']?.toString()??json['nameEn']?.toString()??'',nameAr:json['nameAr']?.toString()??json['nameEn']?.toString()??'',nameFa:json['nameFa']?.toString()??json['nameEn']?.toString()??'',nameHe:json['nameHe']?.toString()??json['nameEn']?.toString()??'',nameHi:json['nameHi']?.toString()??json['nameEn']?.toString()??'',nameBn:json['nameBn']?.toString()??json['nameEn']?.toString()??'',symbols:((json['symbols'] as List?)??const[]).map((e)=>e.toString()).toList(growable:false),minorUnits:(json['minorUnits'] as num?)?.toInt()??2,aliases:((json['aliases'] as List?)??const[]).map((e)=>e.toString()).toList(growable:false));
  String nameFor(String languageTag)=>switch(languageTag){'en'=>nameEn,'es'=>nameEs,'pt-BR'=>namePtBr,'pt-PT'=>namePtPt,'fr'=>nameFr,'de'=>nameDe,'it'=>nameIt,'nl'=>nameNl,'pl'=>namePl,'ro'=>nameRo,'el'=>nameEl,'ru'=>nameRu,'uk'=>nameUk,'ar'=>nameAr,'fa'=>nameFa,'he'=>nameHe,'hi'=>nameHi,'bn'=>nameBn.isEmpty?nameEn:nameBn,'ur'=>urduCurrencyNames[code]??nameEn,'id'=>indonesianCurrencyNames[code]??nameEn,_=>nameTr};
  String get primarySymbol=>symbols.isEmpty?code:symbols.first;
  bool matches(String query)=>_searchMatches(query,[code,nameTr,nameEn,nameEs,namePtBr,namePtPt,nameFr,nameDe,nameIt,nameNl,namePl,nameRo,nameEl,nameRu,nameUk,nameAr,nameFa,nameHe,nameHi,nameBn,urduCurrencyNames[code]??'',indonesianCurrencyNames[code]??'',...symbols,...aliases]);
}

class GlobalCatalog {
  const GlobalCatalog({required this.languages,required this.countries,required this.currencies});
  final List<LanguageOption> languages; final List<CountryOption> countries; final List<CurrencyOption> currencies;
  bool currencyMatches(CurrencyOption item,String query){final normalized=normalizeGlobalSearch(query);if(normalized.isEmpty)return true;final exact=currencies.any((c)=>normalizeGlobalSearch(c.code)==normalized);return exact?normalizeGlobalSearch(item.code)==normalized:item.matches(query);}
  LanguageOption language(String code)=>languages.firstWhere((item)=>item.code==code,orElse:()=>languages.first);
  CountryOption country(String code)=>countries.firstWhere((item)=>item.code==code,orElse:()=>countries.first);
  CurrencyOption currency(String code)=>currencies.firstWhere((item)=>item.code==code,orElse:()=>currencies.first);
}

class GlobalCatalogRepository {
  GlobalCatalogRepository._(); static GlobalCatalog? _current;
  static GlobalCatalog get current{final value=_current;if(value==null)throw StateError('Global katalog henüz yüklenmedi.');return value;}
  static Future<GlobalCatalog> load() async {
    if(_current case final existing?)return existing;
    Future<List<Map<String,dynamic>>> loadItems(String path) async {final decoded=jsonDecode(await rootBundle.loadString(path));final map=Map<String,dynamic>.from(decoded as Map);return ((map['items'] as List?)??const[]).whereType<Map>().map((item)=>Map<String,dynamic>.from(item)).toList(growable:false);}
    final languageItems=await loadItems('assets/data/languages_v1.json'); final countryItems=await loadItems('assets/data/countries_v1.json'); final currencyItems=await loadItems('assets/data/currencies_v1.json');
    final catalog=GlobalCatalog(languages:languageItems.map(LanguageOption.fromJson).toList(),countries:countryItems.map(CountryOption.fromJson).toList(),currencies:currencyItems.map(CurrencyOption.fromJson).toList());
    if(catalog.languages.length!=29||catalog.countries.length!=161||catalog.currencies.length!=154)throw StateError('Global katalog sayıları doğrulanamadı.');
    _current=catalog; return catalog;
  }
}
