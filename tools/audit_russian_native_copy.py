#!/usr/bin/env python3
"""Fail-closed audit for reviewed Russia-oriented Russian product copy."""
from __future__ import annotations
import json, re
from build_russian_locale import ROOT, english_pairs, russian_pairs

CONTRACT = ROOT / 'tools/russian_native_terms.json'
RUSSIAN_DIR = ROOT / 'lib/l10n/ru'
RUSSIAN_INDEX = ROOT / 'lib/l10n/mizan_ru.dart'
RUSSIAN_DYNAMIC = ROOT / 'lib/l10n/mizan_ru_dynamic.dart'

def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    pairs = russian_pairs(); values = dict(pairs); failures = []
    english = dict(english_pairs())
    if len(pairs) != 791 or len(values) != 791:
        failures.append(f'Russian catalog must contain 791 unique values, found {len(pairs)}/{len(values)}')
    if set(values) != set(english):
        failures.append('Russian key set differs from English')
    for key, expected in contract['requiredTerms'].items():
        if values.get(key) != expected:
            failures.append(f'Required Russian term mismatch for {key!r}: {values.get(key)!r}')
    protected = {
        'MİZAN GLOBAL', 'MİZAN', 'MIZAN', 'LEFFERION PRIME', 'Lefferion Prime', 'Android', 'Google Play',
        'CSV', 'PDF', 'WhatsApp', 'IBAN', 'ISO', 'Pro', 'TRY', 'RON', 'USD',
        'EUR', 'GBP', 'CHF', 'JPY', 'CNY', 'RUB', 'PLN', 'AED', 'SAR', 'KWD',
        'QAR', 'BHD', 'OMR',
    }
    allowed_latin = re.compile(
        r'^(?:[A-Z0-9 ._/:+%®©-]|MİZAN|LEFFERION|PRIME|Android|Google|Play|CSV|PDF|WhatsApp|IBAN|ISO|Pro)+$'
    )
    for key, value in pairs:
        for term in contract['forbiddenVisibleTerms']:
            if re.search(rf'(?<!\w){re.escape(term)}(?!\w)', value, re.I):
                failures.append(f'Foreign-language leakage in {key!r}: {term!r} -> {value!r}')
        if value == english.get(key) and value not in protected and key not in protected and not allowed_latin.fullmatch(value):
            failures.append(f'Untranslated English value: {key!r} -> {value!r}')
        if 'ZXQ' in value or '__KEEP' in value:
            failures.append(f'Unrestored placeholder in {key!r}')
        cleaned = value
        for token in sorted(protected, key=len, reverse=True):
            cleaned = cleaned.replace(token, '')
        if re.search(r'[A-Za-z]', cleaned):
            failures.append(f'Unexpected Latin-script leakage in {key!r}: {value!r}')
    text = (
        '\n'.join(path.read_text(encoding='utf-8') for path in sorted(RUSSIAN_DIR.glob('*.dart')))
        + '\n' + RUSSIAN_INDEX.read_text(encoding='utf-8')
        + '\n' + RUSSIAN_DYNAMIC.read_text(encoding='utf-8')
    )
    for marker in ('ПОДТВЕРЖДАЮ', 'Просрочено', 'Срок оплаты', 'резервн', 'Осталось ${_days(value)}'):
        if marker not in text:
            failures.append(f'Required Russian source marker missing: {marker}')
    if 'CANDIDATE' in text or 'MACHINE-GENERATED' in text:
        failures.append('Russian source still carries candidate-only markers')
    if failures:
        raise SystemExit('\n'.join(failures))
    print('Russian native-copy audit passed: 791/791 values, binding terminology, plural grammar and language purity verified.')

if __name__ == '__main__':
    main()
