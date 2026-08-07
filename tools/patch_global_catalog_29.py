#!/usr/bin/env python3
from pathlib import Path
p=Path('lib/global/global_catalog.dart')
s=p.read_text(encoding='utf-8')
marker="import '../l10n/ur/mizan_ur_catalog.dart';\n"
assert marker in s
if "mizan_vi_catalog.dart" not in s:
    s=s.replace(marker, marker+"import '../l10n/vi/mizan_vi_catalog.dart';\nimport '../l10n/th/mizan_th_catalog.dart';\nimport '../l10n/sw/mizan_sw_catalog.dart';\n")
repls={
"'zh'=>chineseLanguageNames[code]??nameEn,_=>nameTr":"'zh'=>chineseLanguageNames[code]??nameEn,'vi'=>vietnameseLanguageNames[code]??nameEn,'th'=>thaiLanguageNames[code]??nameEn,'sw'=>swahiliLanguageNames[code]??nameEn,_=>nameTr",
"chineseLanguageNames[code]??'']":"chineseLanguageNames[code]??'',vietnameseLanguageNames[code]??'',thaiLanguageNames[code]??'',swahiliLanguageNames[code]??'']",
"'zh'=>chineseCountryNames[code]??nameEn,_=>nameTr":"'zh'=>chineseCountryNames[code]??nameEn,'vi'=>vietnameseCountryNames[code]??nameEn,'th'=>thaiCountryNames[code]??nameEn,'sw'=>swahiliCountryNames[code]??nameEn,_=>nameTr",
"chineseCountryNames[code]??'',nativeName]":"chineseCountryNames[code]??'',vietnameseCountryNames[code]??'',thaiCountryNames[code]??'',swahiliCountryNames[code]??'',nativeName]",
"'zh'=>chineseCurrencyNames[code]??nameEn,_=>nameTr":"'zh'=>chineseCurrencyNames[code]??nameEn,'vi'=>vietnameseCurrencyNames[code]??nameEn,'th'=>thaiCurrencyNames[code]??nameEn,'sw'=>swahiliCurrencyNames[code]??nameEn,_=>nameTr",
"chineseCurrencyNames[code]??'',...symbols,...aliases]":"chineseCurrencyNames[code]??'',vietnameseCurrencyNames[code]??'',thaiCurrencyNames[code]??'',swahiliCurrencyNames[code]??'',...symbols,...aliases]",
}
for old,new in repls.items():
    assert old in s, old
    s=s.replace(old,new,1)
p.write_text(s,encoding='utf-8')
