#!/usr/bin/env python3
"""Apply the locked 791-line native Greek review to the isolated candidate."""
from __future__ import annotations
import hashlib,json,re
from pathlib import Path
from build_greek_locale import ROOT, english_pairs, parse_map

REVIEW=ROOT/'tools'/'greek_review.json'
PARTS=tuple(sorted((ROOT/'lib/l10n/el').glob('mizan_el_*.dart')))
INDEX=ROOT/'lib/l10n/mizan_el.dart'
LOCKED_CANDIDATE_SHA='2b55c67093fa2facff3ee0a6deec2d7aeadb55ef6e6748f209f4e3d2cb95a1c8'

def quote(value:str)->str:
    value=(value.replace('\\','\\\\').replace("'","\\'").replace('$','\\$')
           .replace('\r','\\r').replace('\n','\\n').replace('\t','\\t'))
    return f"'{value}'"

def main()->None:
    review=json.loads(REVIEW.read_text(encoding='utf-8'))
    english=dict(english_pairs())
    candidate={}
    parsed=[]
    for path in PARTS:
        source=path.read_text(encoding='utf-8')
        match=re.search(r'const Map<String, String> (mizanGreek\w+)',source)
        if not match: raise SystemExit(f'Greek map marker missing: {path}')
        pairs=parse_map(source,match.group(0)); parsed.append((path,match.group(1),pairs))
        candidate.update(pairs)
    locked_candidate={key:item.get('candidate') for key,item in review.items()}
    digest=hashlib.sha256(json.dumps(locked_candidate,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()).hexdigest()
    if digest != LOCKED_CANDIDATE_SHA:
        raise SystemExit(f'Locked Greek review candidate SHA mismatch: {digest}')
    if len(review)!=791 or set(review)!=set(english) or set(candidate)!=set(review):
        raise SystemExit(f'Review coverage mismatch: {len(review)}')
    for key,item in review.items():
        if item.get('source')!=english[key] or not str(item.get('final','')).strip() or item.get('decision') not in {'accepted','corrected'}:
            raise SystemExit(f'Invalid review entry: {key!r}')
    total=0
    for path,map_name,pairs in parsed:
        lines=['// REVIEWED GREEK LOCALIZATION — GREECE-ORIENTED NATIVE COPY.',f'const Map<String, String> {map_name} = <String, String>{{']
        for key,_ in pairs:
            lines.append(f'  {quote(key)}: {quote(review[key]["final"])},')
        lines.extend(['};',''])
        path.write_text('\n'.join(lines),encoding='utf-8'); total+=len(pairs)
    text=INDEX.read_text(encoding='utf-8')
    text=text.replace('// MACHINE-GENERATED GREEK REVIEW CANDIDATE — NOT RUNTIME-APPROVED.','// REVIEWED GREEK LOCALIZATION — 791/791 STATIC VALUES.')
    INDEX.write_text(text,encoding='utf-8')
    corrected=sum(1 for item in review.values() if item['decision']=='corrected')
    print(f'Applied locked native Greek review: {total}/791 values; {corrected} corrected, {791-corrected} accepted after manual inspection.')
if __name__=='__main__': main()
