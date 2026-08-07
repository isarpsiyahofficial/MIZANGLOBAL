#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def patch(path,replacements):
 p=ROOT/path;s=p.read_text(encoding='utf-8')
 for old,new in replacements:
  if new in s: continue
  if old not in s: raise SystemExit(f'marker not found in {path}: {old[:120]}')
  s=s.replace(old,new,1)
 p.write_text(s,encoding='utf-8')

# Materialize Japanese and Simplified Chinese together. The consolidated branch
# intentionally carried both reviewed source packs, but its runtime facade was
# still at the Korean epoch. Applying both layers in one deterministic pass
# avoids depending on a superseded Japanese PR trigger.
patch(Path('lib/l10n/mizan_i18n.dart'),[
 ("import 'mizan_ko_dynamic.dart';", "import 'mizan_ko_dynamic.dart';\nimport 'mizan_ja.dart';\nimport 'mizan_ja_dynamic.dart';\nimport 'mizan_zh.dart';\nimport 'mizan_zh_dynamic.dart';"),
 ("'fil','ko'};", "'fil','ko','ja','zh'};"),
 ("static bool get isKorean=>_languageTag=='ko';", "static bool get isKorean=>_languageTag=='ko';\n  static bool get isJapanese=>_languageTag=='ja';\n  static bool get isChinese=>_languageTag=='zh';"),
 ("'ko'=>'확인합니다',_=>legacy.MizanI18n.destructiveConfirmation", "'ko'=>'확인합니다','ja'=>'確認します','zh'=>'我确认',_=>legacy.MizanI18n.destructiveConfirmation"),
 ("if(normalized=='ko'||normalized.startsWith('ko-'))return'ko';\n    return legacy", "if(normalized=='ko'||normalized.startsWith('ko-'))return'ko';\n    if(normalized=='ja'||normalized.startsWith('ja-'))return'ja';\n    if(normalized=='zh'||normalized.startsWith('zh-')||normalized=='zh-cn'||normalized=='zh-hans')return'zh';\n    return legacy"),
 ("normalized=='ko'||normalized.startsWith('ko-')||legacy.MizanI18n.isSupported(value)", "normalized=='ko'||normalized.startsWith('ko-')||normalized=='ja'||normalized.startsWith('ja-')||normalized=='zh'||normalized.startsWith('zh-')||legacy.MizanI18n.isSupported(value)"),
 ("isFilipino||isKorean;", "isFilipino||isKorean||isJapanese||isChinese;"),
 ("effective!='fil'&&effective!='ko')return legacy", "effective!='fil'&&effective!='ko'&&effective!='ja'&&effective!='zh')return legacy"),
 ("else{result=mizanKorean[visibleSource]??translateKoreanReviewedDynamic(visibleSource,(value)=>text(value,languageTag:'ko'));}", "else if(effective=='ko'){result=mizanKorean[visibleSource]??translateKoreanReviewedDynamic(visibleSource,(value)=>text(value,languageTag:'ko'));}\n    else if(effective=='ja'){result=mizanJapanese[visibleSource]??translateJapaneseReviewedDynamic(visibleSource,(value)=>text(value,languageTag:'ja'));}\n    else{result=mizanChinese[visibleSource]??translateChineseReviewedDynamic(visibleSource,(value)=>text(value,languageTag:'zh'));}"),
])

patch(Path('lib/core/formatters.dart'),[
 ("&&!MizanI18n.isFilipino&&!MizanI18n.isKorean)return legacy.money(value);", "&&!MizanI18n.isFilipino&&!MizanI18n.isKorean&&!MizanI18n.isJapanese&&!MizanI18n.isChinese)return legacy.money(value);"),
 ("if(MizanI18n.isKorean&&MizanI18n.currencyCode=='KRW'){final rounded=safe.round();return'₩${_groupThousands(rounded.toString(),',')}';}", "if(MizanI18n.isKorean&&MizanI18n.currencyCode=='KRW'){final rounded=safe.round();return'₩${_groupThousands(rounded.toString(),',')}';}\n  if(MizanI18n.isJapanese&&MizanI18n.currencyCode=='JPY'){final rounded=safe.round();return'¥${_groupThousands(rounded.toString(),',')}';}"),
 ("if(MizanI18n.isKorean){final amount='${_groupThousands(signedInteger,',')}.${fixed.last}';return'${MizanI18n.currencyCode}\\u00A0$amount';}", "if(MizanI18n.isKorean){final amount='${_groupThousands(signedInteger,',')}.${fixed.last}';return'${MizanI18n.currencyCode}\\u00A0$amount';}\n  if(MizanI18n.isJapanese){final amount='${_groupThousands(signedInteger,',')}.${fixed.last}';return'${MizanI18n.currencyCode}\\u00A0$amount';}\n  if(MizanI18n.isChinese){final amount='${_groupThousands(signedInteger,',')}.${fixed.last}';return MizanI18n.currencyCode=='CNY'?'¥$amount':'${MizanI18n.currencyCode}\\u00A0$amount';}"),
 ("&&!MizanI18n.isFilipino&&!MizanI18n.isKorean)return legacy.decimalText(value);", "&&!MizanI18n.isFilipino&&!MizanI18n.isKorean&&!MizanI18n.isJapanese&&!MizanI18n.isChinese)return legacy.decimalText(value);"),
 ("if(MizanI18n.isKorean&&MizanI18n.currencyCode=='KRW')return _groupThousands(value.round().toString(),',');", "if(MizanI18n.isKorean&&MizanI18n.currencyCode=='KRW')return _groupThousands(value.round().toString(),',');\n  if(MizanI18n.isJapanese&&MizanI18n.currencyCode=='JPY')return _groupThousands(value.round().toString(),',');"),
 ("MizanI18n.isMalay||MizanI18n.isFilipino||MizanI18n.isKorean){", "MizanI18n.isMalay||MizanI18n.isFilipino||MizanI18n.isKorean||MizanI18n.isJapanese||MizanI18n.isChinese){"),
 ("else if(MizanI18n.isKorean){prepared=prepared.replaceAll(RegExp('KRW',caseSensitive:false),'').replaceAll('₩','').replaceAll('원','');}return legacy.parseMoney(prepared);", "else if(MizanI18n.isKorean){prepared=prepared.replaceAll(RegExp('KRW',caseSensitive:false),'').replaceAll('₩','').replaceAll('원','');}else if(MizanI18n.isJapanese){prepared=prepared.replaceAll(RegExp('JPY',caseSensitive:false),'').replaceAll('¥','').replaceAll('￥','').replaceAll('円','');}else if(MizanI18n.isChinese){prepared=prepared.replaceAll(RegExp('CNY',caseSensitive:false),'').replaceAll('¥','').replaceAll('￥','').replaceAll('元','');}return legacy.parseMoney(prepared);"),
 ("if(MizanI18n.isKorean)return'${value.year}년 ${value.month}월 ${value.day}일';return legacy.shortDate(value);", "if(MizanI18n.isKorean)return'${value.year}년 ${value.month}월 ${value.day}일';if(MizanI18n.isJapanese||MizanI18n.isChinese)return'${value.year}年${value.month}月${value.day}日';return legacy.shortDate(value);"),
 ("if(MizanI18n.isKorean)return'${value.year}년 ${value.month}월';return legacy.monthLabel(value);", "if(MizanI18n.isKorean)return'${value.year}년 ${value.month}월';if(MizanI18n.isJapanese||MizanI18n.isChinese)return'${value.year}年${value.month}月';return legacy.monthLabel(value);"),
])

patch(Path('lib/main.dart'),[
 ("'ko'=>const Locale('ko','KR'),_=>Locale(languageTag)", "'ko'=>const Locale('ko','KR'),'ja'=>const Locale('ja','JP'),'zh'=>const Locale('zh','CN'),_=>Locale(languageTag)"),
 ("Locale('fil','PH'),Locale('ko','KR')],", "Locale('fil','PH'),Locale('ko','KR'),Locale('ja','JP'),Locale('zh','CN')],"),
])

patch(Path('lib/global/global_catalog.dart'),[
 ("import '../l10n/ko/mizan_ko_catalog.dart';", "import '../l10n/ko/mizan_ko_catalog.dart';\nimport '../l10n/ja/mizan_ja_catalog.dart';\nimport '../l10n/zh/mizan_zh_catalog.dart';"),
 ("'ko'=>koreanLanguageNames[code]??nameEn,_=>nameTr", "'ko'=>koreanLanguageNames[code]??nameEn,'ja'=>japaneseLanguageNames[code]??nameEn,'zh'=>chineseLanguageNames[code]??nameEn,_=>nameTr"),
 ("koreanLanguageNames[code]??'']);", "koreanLanguageNames[code]??'',japaneseLanguageNames[code]??'',chineseLanguageNames[code]??'']);"),
 ("'ko'=>koreanCountryNames[code]??nameEn,_=>nameTr", "'ko'=>koreanCountryNames[code]??nameEn,'ja'=>japaneseCountryNames[code]??nameEn,'zh'=>chineseCountryNames[code]??nameEn,_=>nameTr"),
 ("koreanCountryNames[code]??'',nativeName]);", "koreanCountryNames[code]??'',japaneseCountryNames[code]??'',chineseCountryNames[code]??'',nativeName]);"),
 ("'ko'=>koreanCurrencyNames[code]??nameEn,_=>nameTr", "'ko'=>koreanCurrencyNames[code]??nameEn,'ja'=>japaneseCurrencyNames[code]??nameEn,'zh'=>chineseCurrencyNames[code]??nameEn,_=>nameTr"),
 ("koreanCurrencyNames[code]??'',...symbols,...aliases]);", "koreanCurrencyNames[code]??'',japaneseCurrencyNames[code]??'',chineseCurrencyNames[code]??'',...symbols,...aliases]);"),
])

p=ROOT/'test/all_language_isolation_test.dart';s=p.read_text(encoding='utf-8')
s=s.replace("'fil','ko'];","'fil','ko','ja','zh'];").replace('exactly 24 integrated locale options are registered','exactly 26 integrated locale options are registered').replace('hasLength(24)','hasLength(26)')
p.write_text(s,encoding='utf-8')

for i in range(1,12):
 name='filipino-final-head-marker.md' if i==1 else f'filipino-final-head-marker-{i}.md'
 (ROOT/'docs/localization'/name).unlink(missing_ok=True)

(ROOT/'tools/materialize_chinese_runtime.py').unlink(missing_ok=True)
(ROOT/'.github/workflows/chinese-materialize-and-final-gates.yml').unlink(missing_ok=True)
print('Japanese and Chinese runtime materialized; temporary materializer removed.')
