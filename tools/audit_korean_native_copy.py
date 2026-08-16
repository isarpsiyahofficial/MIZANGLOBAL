#!/usr/bin/env python3
from __future__ import annotations
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
KO=[ROOT/f'lib/l10n/ko/mizan_ko_{name}.dart' for name in ('core','dashboard','records','reports','settings','validation')]
ID=[ROOT/f'lib/l10n/id/mizan_id_{name}.dart' for name in ('core','dashboard','records','reports','settings','validation')]
ENTRY = re.compile(r"'((?:\\.|[^'])*)'\s*:\s*'((?:\\.|[^'])*)'\s*,?", re.S)
KANA=re.compile(r'[\u3040-\u30ff]')
HANGUL=re.compile(r'[\uac00-\ud7af]')
CJK_LEAK=('首页','记录','报告','设置','通知','付款','支出','ホーム','レポート','設定','支払い')
def pairs(p):return ENTRY.findall(p.read_text(encoding='utf-8'))
def keyset(paths):return [k for p in paths for k,_ in pairs(p)]
def count_map(text,name):
 m=re.search(rf"const\s+{name}\s*=\s*<String\s*,\s*String>\s*\{{(.*?)\n\}};",text,re.S);assert m,name;return len(ENTRY.findall(m.group(1)))
def main():
 keys=keyset(KO);source=keyset(ID);vals=[v for p in KO for _,v in pairs(p)];joined='\n'.join(vals)
 assert len(keys)==791,len(keys);assert len(set(keys))==791;assert set(keys)==set(source);assert all(v.strip() for v in vals)
 assert sum(bool(HANGUL.search(v)) for v in vals)>650,'too little Hangul in Korean system copy'
 assert not KANA.search(joined),'Japanese kana leaked into Korean'
 for leak in CJK_LEAK:assert leak not in joined,f'foreign CJK system term leaked: {leak}'
 cat=(ROOT/'lib/l10n/ko/mizan_ko_catalog.dart').read_text(encoding='utf-8')
 assert count_map(cat,'koreanLanguageNames')==29;assert count_map(cat,'koreanCountryNames')==161;assert count_map(cat,'koreanCurrencyNames')==154
 runtime=(ROOT/'lib/l10n/mizan_i18n.dart').read_text(encoding='utf-8');fmt=(ROOT/'lib/core/formatters.dart').read_text(encoding='utf-8');main_dart=(ROOT/'lib/main.dart').read_text(encoding='utf-8')
 for marker in ("'ko'",'mizanKorean','translateKoreanReviewedDynamic','확인합니다'):assert marker in runtime,marker
 assert re.search(r"\bcode\s*==\s*'KRW'",fmt), 'KRW formatter branch'
 assert '₩' in fmt
 assert re.search(r"\$\{value\.year\}년\s*\$\{value\.month\}월\s*\$\{value\.day\}일",fmt), 'Korean date formatter'
 assert re.search(r"Locale\(\s*'ko'\s*,\s*'KR'\s*\)",main_dart), 'ko-KR locale'
 print('Korean native-copy audit passed: 791/791, Hangul purity, 29/161/154 catalogs, KRW/date/runtime markers.')
if __name__=='__main__':main()
