#!/usr/bin/env python3
"""Fail-closed audit for reviewed Greece-oriented Greek product copy."""
from __future__ import annotations
import json,re
from pathlib import Path
from build_greek_locale import ROOT, english_pairs, greek_pairs

CONTRACT=ROOT/'tools'/'greek_native_terms.json'
GREEK_DIR=ROOT/'lib/l10n/el'
GREEK_INDEX=ROOT/'lib/l10n/mizan_el.dart'
GREEK_DYNAMIC=ROOT/'lib/l10n/mizan_el_dynamic.dart'

def main()->None:
    contract=json.loads(CONTRACT.read_text(encoding='utf-8'))
    pairs=greek_pairs(); values=dict(pairs); failures=[]
    english=dict(english_pairs())
    if len(pairs)!=791 or len(values)!=791: failures.append(f'Greek catalog must contain 791 unique values, found {len(pairs)}/{len(values)}')
    if set(values)!=set(english): failures.append('Greek key set differs from English')
    for key,expected in contract['requiredTerms'].items():
        if values.get(key)!=expected: failures.append(f'Required Greek term mismatch for {key!r}: {values.get(key)!r}')
    protected={'MİZAN','MİZAN GLOBAL','LEFFERION PRIME','Android','CSV','PDF','WhatsApp','IBAN','ISO','TRY','RON','USD','EUR','GBP','CHF','JPY','CNY','RUB','PLN','AED','SAR','KWD','QAR','BHD','OMR'}
    for key,value in pairs:
        for term in contract['forbiddenVisibleTerms']:
            if re.search(rf'(?<!\w){re.escape(term)}(?!\w)',value,re.I): failures.append(f'Foreign-language leakage in {key!r}: {term!r} -> {value!r}')
        if value==english.get(key) and value not in protected and key not in protected and not re.fullmatch(r'[A-Z0-9 ._/:+%®©-]+',value): failures.append(f'Untranslated English value: {key!r} -> {value!r}')
        if re.search(r'(?<![Α-ωΆ-ώ])(εσύ|σου|θέλεις)(?![Α-ωΆ-ώ])',value,re.I): failures.append(f'Informal singular Greek in {key!r}: {value!r}')
        if 'ZXQ' in value or '__KEEP' in value: failures.append(f'Unrestored placeholder in {key!r}')
    text='\n'.join(p.read_text(encoding='utf-8') for p in sorted(GREEK_DIR.glob('*.dart')))+'\n'+GREEK_INDEX.read_text(encoding='utf-8')+'\n'+GREEK_DYNAMIC.read_text(encoding='utf-8')
    for marker in ('ΕΠΙΒΕΒΑΙΩΝΩ','Σε καθυστέρηση','Ημερομηνία λήξης','αντίγραφο ασφαλείας','Απομένει 1 ημέρα'):
        if marker not in text: failures.append(f'Required Greek source marker missing: {marker}')
    if 'CANDIDATE' in text: failures.append('Greek source still carries candidate-only markers')
    if failures: raise SystemExit('\n'.join(failures))
    print('Greek native-copy audit passed: 791/791 values, binding terminology, formal register and language purity verified.')
if __name__=='__main__': main()
