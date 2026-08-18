#!/usr/bin/env python3
"""Apply the complete reviewed Romanian override set to the locked candidate."""
from __future__ import annotations
import json,re
from pathlib import Path
from build_romanian_locale import ROOT, parse_map

REVIEW = ROOT / 'tools' / 'romanian_review.json'
PARTS = tuple(sorted((ROOT/'lib/l10n/ro').glob('mizan_ro_*.dart')))
INDEX = ROOT/'lib/l10n/mizan_ro.dart'

def quote(value:str)->str:
    value=(value.replace('\\','\\\\').replace("'","\\'").replace('$','\\$')
           .replace('\r','\\r').replace('\n','\\n').replace('\t','\\t'))
    return f"'{value}'"

def main():
    review=json.loads(REVIEW.read_text(encoding='utf-8'))
    seen=set(); total=0
    for path in PARTS:
        source=path.read_text(encoding='utf-8')
        match=re.search(r'const Map<String, String> (mizanRomanian\w+)',source)
        if not match: raise SystemExit(f'map marker missing: {path}')
        pairs=parse_map(source,match.group(0))
        lines=[
            f'const Map<String, String> {match.group(1)} = <String, String>{{',
        ]
        for key,value in pairs:
            if key in review:
                value=review[key]; seen.add(key)
            lines.append(f'  {quote(key)}: {quote(value)},')
        lines.append('};')
        path.write_text('\n'.join(lines)+'\n',encoding='utf-8')
        total += len(pairs)
    missing=sorted(set(review)-seen)
    if missing: raise SystemExit(f'Review contains unknown keys: {missing}')
    if total != 791: raise SystemExit(f'Expected 791 values, found {total}')
    text=INDEX.read_text(encoding='utf-8')
    text=text.replace('// ROMANIAN LOCALIZATION CANDIDATE — 791/791 STATIC VALUES.\n','')
    INDEX.write_text(text,encoding='utf-8')
    print(f'Applied {len(review)} native-review corrections across {total}/791 values.')
if __name__=='__main__': main()
