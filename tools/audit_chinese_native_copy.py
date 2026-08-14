#!/usr/bin/env python3
from __future__ import annotations
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ZH=[ROOT/f'lib/l10n/zh/mizan_zh_{name}.dart' for name in ('core','dashboard','records','reports','settings','validation')]
ID=[ROOT/f'lib/l10n/id/mizan_id_{name}.dart' for name in ('core','dashboard','records','reports','settings','validation')]
ENTRY=re.compile(r"^\s*'((?:\\.|[^'])*)':\s*'((?:\\.|[^'])*)',?\s*$",re.M)
HANGUL=re.compile(r'[\uac00-\ud7af]');KANA=re.compile(r'[\u3040-\u30ff]');HAN=re.compile(r'[\u3400-\u9fff]')
FOREIGN=('홈','기록','보고서','설정','알림','납부','ホーム','レポート','設定','支払い','銀行の借入','記録','通知システム')
TRADITIONAL=('設定','記錄','報告','銀行債務','貨幣','賬單','訂閱','付款截止日為今天')
def pairs(p):return ENTRY.findall(p.read_text(encoding='utf-8'))
def keys(paths):return [k for p in paths for k,_ in pairs(p)]
def count_map(text,name):
 m=re.search(rf"const {name}=<String,String>\{{(.*?)\n\}};",text,re.S)
 if not m:return -1
 return len(re.findall(r"'[^']+'\s*:\s*'[^']*'",m.group(1)))
def main():
 errors=[]
 def check(ok,label):
  if not ok:
   errors.append(label);print(f'::error title=Chinese native-copy audit::{label}')
 ks=keys(ZH);source=keys(ID);vals=[v for p in ZH for _,v in pairs(p)];joined='\n'.join(vals)
 check(len(ks)==791,f'key-count expected=791 actual={len(ks)}')
 check(len(set(ks))==791,'duplicate Chinese keys')
 check(set(ks)==set(source),'Chinese keyset differs from stable product set')
 check(all(v.strip() for v in vals),'empty Chinese static value')
 check(not HANGUL.search(joined),'Korean Hangul leaked into Chinese system copy')
 check(not KANA.search(joined),'Japanese kana leaked into Chinese system copy')
 check(sum(bool(HAN.search(v)) for v in vals)>700,'too little Han script in Chinese copy')
 for leak in FOREIGN:check(leak not in joined,f'foreign CJK system label leaked: {leak}')
 for leak in TRADITIONAL:check(leak not in joined,f'traditional/Japanese form leaked: {leak}')
 for required in ('首页','记录','支出','报告','设置','通知系统','银行债务','账单','订阅','我确认'):check(required in joined,f'required Simplified Chinese term missing: {required}')
 cat=(ROOT/'lib/l10n/zh/mizan_zh_catalog.dart').read_text(encoding='utf-8')
 for name,expected in (('chineseLanguageNames',29),('chineseCountryNames',161),('chineseCurrencyNames',154)):
  actual=count_map(cat,name);check(actual==expected,f'{name} expected={expected} actual={actual}')
 runtime=(ROOT/'lib/l10n/mizan_i18n.dart').read_text(encoding='utf-8');fmt=(ROOT/'lib/core/formatters.dart').read_text(encoding='utf-8');main=(ROOT/'lib/main.dart').read_text(encoding='utf-8')
 for marker in ("'zh'",'mizanChinese','translateChineseReviewedDynamic','我确认'):check(marker in runtime,f'runtime marker missing: {marker}')
 check(bool(re.search(r"\bcode\s*==\s*'CNY'",fmt)),'CNY formatter branch missing')
 check('¥' in fmt,'CNY symbol missing')
 check(bool(re.search(r"MizanI18n\.isChinese.*?\$\{value\.year\}年\$\{value\.month\}月\$\{value\.day\}日",fmt,re.S)),'Chinese date formatter missing')
 check(bool(re.search(r"Locale\(\s*'zh'\s*,\s*'CN'\s*\)",main)),'zh-CN Flutter locale missing')
 markers=list((ROOT/'docs/localization').glob('filipino-final-head-marker*.md'));check(not markers,f'temporary Filipino markers remain: {markers}')
 if errors:raise SystemExit(f'Chinese native-copy audit failed with {len(errors)} gate(s).')
 print('Simplified Chinese audit passed: 791/791, no Hangul/Kana, simplified-copy gate, 29/161/154 catalogs, CNY/date/runtime markers.')
if __name__=='__main__':main()