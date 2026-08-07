#!/usr/bin/env python3
from pathlib import Path
p=Path(__file__).resolve().parents[1]/'lib/core/formatters.dart'
s=p.read_text(encoding='utf-8')
old="if(MizanI18n.isKorean||MizanI18n.isJapanese||MizanI18n.isChinese){final amount='${_groupThousands(signedInteger,',')}.${fixed.last}';return'${MizanI18n.currencyCode}\\u00A0$amount';}"
new="if(MizanI18n.isChinese&&MizanI18n.currencyCode=='CNY'){final amount='${_groupThousands(signedInteger,',')}.${fixed.last}';return'¥$amount';}if(MizanI18n.isKorean||MizanI18n.isJapanese||MizanI18n.isChinese){final amount='${_groupThousands(signedInteger,',')}.${fixed.last}';return'${MizanI18n.currencyCode}\\u00A0$amount';}"
if new not in s:
 if old not in s: raise SystemExit('Chinese CNY formatter insertion marker not found')
 s=s.replace(old,new,1)
p.write_text(s,encoding='utf-8')
Path(__file__).unlink(missing_ok=True)
print('CNY symbol formatter finalized.')
