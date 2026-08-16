#!/usr/bin/env python3
from __future__ import annotations
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
JA=[ROOT/f'lib/l10n/ja/mizan_ja_{name}.dart' for name in ('core','dashboard','records','reports','settings','validation')]
ID=[ROOT/f'lib/l10n/id/mizan_id_{name}.dart' for name in ('core','dashboard','records','reports','settings','validation')]
ENTRY = re.compile(r"'((?:\\.|[^'])*)'\s*:\s*'((?:\\.|[^'])*)'\s*,?", re.S)
HANGUL=re.compile(r'[\uac00-\ud7af]')
KANA=re.compile(r'[\u3040-\u30ff]')
FOREIGN_TERMS=('홈','기록','보고서','설정','알림','납부','首页','记录','报告','设置','银行债务','付款','账单','订阅')
def pairs(p):return ENTRY.findall(p.read_text(encoding='utf-8'))
def keys(paths):return [k for p in paths for k,_ in pairs(p)]
def count_map(text,name):
 m=re.search(rf"const\s+{name}\s*=\s*<String\s*,\s*String>\s*\{{(.*?)\n\}};",text,re.S);assert m,name;return len(ENTRY.findall(m.group(1)))
def main():
 ks=keys(JA);source=keys(ID);vals=[v for p in JA for _,v in pairs(p)];joined='\n'.join(vals)
 assert len(ks)==791,len(ks);assert len(set(ks))==791,'duplicate Japanese keys';assert set(ks)==set(source),'Japanese keyset differs from stable product set';assert all(v.strip() for v in vals)
 assert not HANGUL.search(joined),'Korean Hangul leaked into Japanese system copy'
 assert sum(bool(KANA.search(v)) for v in vals)>500,'too little Japanese kana in system copy'
 for leak in FOREIGN_TERMS:assert leak not in joined,f'foreign CJK system label leaked: {leak}'
 cat=(ROOT/'lib/l10n/ja/mizan_ja_catalog.dart').read_text(encoding='utf-8')
 assert count_map(cat,'japaneseLanguageNames')==29;assert count_map(cat,'japaneseCountryNames')==161;assert count_map(cat,'japaneseCurrencyNames')==154
 runtime=(ROOT/'lib/l10n/mizan_i18n.dart').read_text(encoding='utf-8');fmt=(ROOT/'lib/core/formatters.dart').read_text(encoding='utf-8');main=(ROOT/'lib/main.dart').read_text(encoding='utf-8')
 for marker in ("'ja'",'mizanJapanese','translateJapaneseReviewedDynamic','確認します'):assert marker in runtime,marker
 assert re.search(r"\bcode\s*==\s*'JPY'",fmt), 'JPY formatter branch'
 assert '¥' in fmt
 assert re.search(r"\$\{value\.year\}年\$\{value\.month\}月\$\{value\.day\}日",fmt), 'Japanese date formatter'
 assert re.search(r"Locale\(\s*'ja'\s*,\s*'JP'\s*\)",main), 'ja-JP locale'
 print('Japanese native-copy audit passed: 791/791, kana purity, no Hangul/Chinese labels, 29/161/154 catalogs, JPY/date/runtime markers.')
if __name__=='__main__':main()
