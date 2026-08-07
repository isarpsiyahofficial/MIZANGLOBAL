#!/usr/bin/env python3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def patch(path,replacements):
 p=ROOT/path;s=p.read_text(encoding='utf-8')
 for old,new in replacements:
  if new in s: continue
  if old not in s: raise SystemExit(f'marker not found in {path}: {old[:100]}')
  s=s.replace(old,new,1)
 p.write_text(s,encoding='utf-8')

patch(Path('lib/l10n/mizan_i18n.dart'),[
 ("import 'mizan_ja_dynamic.dart';", "import 'mizan_ja_dynamic.dart';\nimport 'mizan_zh.dart';\nimport 'mizan_zh_dynamic.dart';"),
 ("'ko','ja'};", "'ko','ja','zh'};"),
 ("static bool get isJapanese=>_languageTag=='ja';", "static bool get isJapanese=>_languageTag=='ja';static bool get isChinese=>_languageTag=='zh';"),
 ("'ja'=>'確認します',_=>legacy.MizanI18n.destructiveConfirmation", "'ja'=>'確認します','zh'=>'我确认',_=>legacy.MizanI18n.destructiveConfirmation"),
 ("if(n=='ja'||n.startsWith('ja-'))return'ja';return legacy", "if(n=='ja'||n.startsWith('ja-'))return'ja';if(n=='zh'||n.startsWith('zh-')||n=='zh-cn'||n=='zh-hans')return'zh';return legacy"),
 ("n=='ja'||n.startsWith('ja-')||legacy.MizanI18n.isSupported(value)", "n=='ja'||n.startsWith('ja-')||n=='zh'||n.startsWith('zh-')||legacy.MizanI18n.isSupported(value)"),
 ("isKorean||isJapanese;", "isKorean||isJapanese||isChinese;"),
 ("{'ur','id','ms','fil','ko','ja'}.contains(effective)", "{'ur','id','ms','fil','ko','ja','zh'}.contains(effective)"),
 ("else{result=mizanJapanese[visible]??translateJapaneseReviewedDynamic(visible,(v)=>text(v,languageTag:'ja'));}", "else if(effective=='ja'){result=mizanJapanese[visible]??translateJapaneseReviewedDynamic(visible,(v)=>text(v,languageTag:'ja'));}else{result=mizanChinese[visible]??translateChineseReviewedDynamic(visible,(v)=>text(v,languageTag:'zh'));}"),
])

patch(Path('lib/core/formatters.dart'),[
 ("&&!MizanI18n.isKorean&&!MizanI18n.isJapanese)return legacy.money(value);", "&&!MizanI18n.isKorean&&!MizanI18n.isJapanese&&!MizanI18n.isChinese)return legacy.money(value);"),
 ("if(MizanI18n.isKorean||MizanI18n.isJapanese){final amount=", "if(MizanI18n.isKorean||MizanI18n.isJapanese||MizanI18n.isChinese){final amount="),
 ("&&!MizanI18n.isKorean&&!MizanI18n.isJapanese)return legacy.decimalText(value);", "&&!MizanI18n.isKorean&&!MizanI18n.isJapanese&&!MizanI18n.isChinese)return legacy.decimalText(value);"),
 ("if(MizanI18n.isMalay||MizanI18n.isFilipino||MizanI18n.isKorean||MizanI18n.isJapanese){", "if(MizanI18n.isMalay||MizanI18n.isFilipino||MizanI18n.isKorean||MizanI18n.isJapanese||MizanI18n.isChinese){"),
 ("else if(MizanI18n.isJapanese){prepared=prepared.replaceAll(RegExp('JPY',caseSensitive:false),'').replaceAll('¥','').replaceAll('￥','').replaceAll('円','');}", "else if(MizanI18n.isJapanese){prepared=prepared.replaceAll(RegExp('JPY',caseSensitive:false),'').replaceAll('¥','').replaceAll('￥','').replaceAll('円','');}else if(MizanI18n.isChinese){prepared=prepared.replaceAll(RegExp('CNY',caseSensitive:false),'').replaceAll('¥','').replaceAll('￥','').replaceAll('元','');}"),
 ("if(MizanI18n.isJapanese)return'${value.year}年${value.month}月${value.day}日';return legacy.shortDate(value);", "if(MizanI18n.isJapanese)return'${value.year}年${value.month}月${value.day}日';if(MizanI18n.isChinese)return'${value.year}年${value.month}月${value.day}日';return legacy.shortDate(value);"),
 ("if(MizanI18n.isJapanese)return'${value.year}年${value.month}月';return legacy.monthLabel(value);", "if(MizanI18n.isJapanese)return'${value.year}年${value.month}月';if(MizanI18n.isChinese)return'${value.year}年${value.month}月';return legacy.monthLabel(value);"),
])

patch(Path('lib/main.dart'),[
 ("'ja'=>const Locale('ja','JP'),_=>Locale(languageTag)", "'ja'=>const Locale('ja','JP'),'zh'=>const Locale('zh','CN'),_=>Locale(languageTag)"),
 ("Locale('ko','KR'),Locale('ja','JP')],", "Locale('ko','KR'),Locale('ja','JP'),Locale('zh','CN')],"),
])

patch(Path('lib/global/global_catalog.dart'),[
 ("import '../l10n/ja/mizan_ja_catalog.dart';", "import '../l10n/ja/mizan_ja_catalog.dart';\nimport '../l10n/zh/mizan_zh_catalog.dart';"),
 ("'ja'=>japaneseLanguageNames[code]??nameEn,_=>nameTr", "'ja'=>japaneseLanguageNames[code]??nameEn,'zh'=>chineseLanguageNames[code]??nameEn,_=>nameTr"),
 ("japaneseLanguageNames[code]??'']);", "japaneseLanguageNames[code]??'',chineseLanguageNames[code]??'']);"),
 ("'ja'=>japaneseCountryNames[code]??nameEn,_=>nameTr", "'ja'=>japaneseCountryNames[code]??nameEn,'zh'=>chineseCountryNames[code]??nameEn,_=>nameTr"),
 ("japaneseCountryNames[code]??'',nativeName]);", "japaneseCountryNames[code]??'',chineseCountryNames[code]??'',nativeName]);"),
 ("'ja'=>japaneseCurrencyNames[code]??nameEn,_=>nameTr", "'ja'=>japaneseCurrencyNames[code]??nameEn,'zh'=>chineseCurrencyNames[code]??nameEn,_=>nameTr"),
 ("japaneseCurrencyNames[code]??'',...symbols,...aliases]);", "japaneseCurrencyNames[code]??'',chineseCurrencyNames[code]??'',...symbols,...aliases]);"),
])

p=ROOT/'test/all_language_isolation_test.dart';s=p.read_text(encoding='utf-8')
s=s.replace("'fil','ko'];","'fil','ko','ja','zh'];").replace('exactly 24 integrated locale options are registered','exactly 26 integrated locale options are registered').replace('hasLength(24)','hasLength(26)')
p.write_text(s,encoding='utf-8')

for i in range(1,12):
 name='filipino-final-head-marker.md' if i==1 else f'filipino-final-head-marker-{i}.md'
 (ROOT/'docs/localization'/name).unlink(missing_ok=True)

# Self-clean temporary orchestration files before the materialized commit.
(ROOT/'tools/materialize_chinese_runtime.py').unlink(missing_ok=True)
(ROOT/'.github/workflows/chinese-materialize-and-final-gates.yml').unlink(missing_ok=True)
print('Chinese runtime materialized and temporary orchestration removed.')
