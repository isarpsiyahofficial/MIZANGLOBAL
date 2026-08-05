#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import time
import unicodedata
import urllib.parse
import urllib.request
from pathlib import Path

from build_ukrainian_locale import english_pairs, parse_map

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'build' / 'hindi-candidate'
CACHE = OUT / 'translation-cache.json'
HE_PARTS = tuple(sorted((ROOT / 'lib/l10n/he').glob('mizan_he_*.dart')))

MANUAL = {
    'Home': 'मुख्य पृष्ठ',
    'Records': 'रिकॉर्ड',
    'Expenses': 'खर्च',
    'Reports': 'रिपोर्ट',
    'Settings': 'सेटिंग्स',
    'Save': 'सहेजें',
    'Delete': 'हटाएँ',
    'Edit': 'संपादित करें',
    'Add': 'जोड़ें',
    'Continue': 'जारी रखें',
    'Back': 'वापस',
    'Cancel': 'रद्द करें',
    'Close': 'बंद करें',
    'Confirm': 'पुष्टि करें',
    'Debt': 'कर्ज़',
    'Bank debt': 'बैंक का कर्ज़',
    'Personal / corporate debt': 'व्यक्तिगत / व्यावसायिक कर्ज़',
    'Bill': 'बिल',
    'Subscription': 'सदस्यता',
    'Rent / installment': 'किराया / किस्त',
    'Payment': 'भुगतान',
    'Payment history': 'भुगतान इतिहास',
    'Income': 'आय',
    'Expense': 'खर्च',
    'Amount': 'राशि',
    'Balance': 'शेष राशि',
    'Remaining balance': 'बाकी शेष राशि',
    'Due date': 'अंतिम भुगतान तिथि',
    'Overdue': 'समय सीमा पार',
    'Reminder': 'रिमाइंडर',
    'Notification': 'सूचना',
    'Backup': 'बैकअप',
    'Report': 'रिपोर्ट',
    'Language': 'भाषा',
    'Country': 'देश',
    'Currency': 'मुद्रा',
    'Default currency': 'डिफ़ॉल्ट मुद्रा',
    'Hindi': 'हिन्दी',
    'India': 'भारत',
    'Search': 'खोजें',
    'All': 'सभी',
    'Today': 'आज',
    'Tomorrow': 'कल',
    'Yesterday': 'कल',
    'Active': 'सक्रिय',
    'Inactive': 'निष्क्रिय',
    'Completed': 'पूरा हुआ',
    'Monthly': 'मासिक',
    'Weekly': 'साप्ताहिक',
    'Daily': 'दैनिक',
    'Yearly': 'वार्षिक',
}

PROTECTED = re.compile(
    r'(MİZAN GLOBAL|MİZAN|LEFFERION PRIME|Android|CSV|PDF|ISO|IBAN|INR|TRY|USD|EUR|[A-Z]{3}|%\d+|\d+%|https?://\S+|__MIZAN_USER_\d+__)'
)


def protect(text: str) -> tuple[str, dict[str, str]]:
    tokens: dict[str, str] = {}

    def repl(match: re.Match[str]) -> str:
        key = f'ZXQ{len(tokens):03d}QXZ'
        tokens[key] = match.group(0)
        return key

    return PROTECTED.sub(repl, text), tokens


def unprotect(text: str, tokens: dict[str, str]) -> str:
    for key, value in tokens.items():
        text = text.replace(key, value)
        text = text.replace(key.lower(), value)
    return text


def google_translate(text: str) -> str:
    if not text.strip():
        return text
    if text in MANUAL:
        return MANUAL[text]
    protected, tokens = protect(text)
    query = urllib.parse.urlencode(
        {'client': 'gtx', 'sl': 'en', 'tl': 'hi', 'dt': 't', 'q': protected}
    )
    url = f'https://translate.googleapis.com/translate_a/single?{query}'
    last: Exception | None = None
    for attempt in range(6):
        try:
            request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(request, timeout=30) as response:
                payload = json.load(response)
            value = ''.join(part[0] for part in payload[0] if part and part[0])
            value = unprotect(value, tokens)
            value = unicodedata.normalize('NFC', value).strip()
            if value:
                return value
        except Exception as exc:
            last = exc
            time.sleep(1.5 * (attempt + 1))
    raise RuntimeError(f'translation failed for {text!r}: {last}')


def dart_quote(value: str) -> str:
    return "'" + value.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n') + "'"


def key_partitions() -> list[tuple[Path, str, list[str]]]:
    result = []
    for path in HE_PARTS:
        source = path.read_text(encoding='utf-8')
        marker_match = re.search(r'const Map<String, String> (mizanHebrew\w+)', source)
        if marker_match is None:
            raise RuntimeError(f'marker missing: {path}')
        pairs = parse_map(source, marker_match.group(0))
        suffix = path.stem.removeprefix('mizan_he_')
        result.append((path, suffix, [key for key, _ in pairs]))
    return result


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    cache: dict[str, str] = {}
    if CACHE.exists():
        cache = json.loads(CACHE.read_text(encoding='utf-8'))
    english = dict(english_pairs())
    if len(english) != 791:
        raise SystemExit(f'expected 791 English values, got {len(english)}')
    unique_values = list(dict.fromkeys(english.values()))
    for index, value in enumerate(unique_values, 1):
        if value not in cache:
            cache[value] = google_translate(value)
            CACHE.write_text(
                json.dumps(cache, ensure_ascii=False, indent=2), encoding='utf-8'
            )
            if index % 25 == 0:
                print(f'translated {index}/{len(unique_values)}', flush=True)
            time.sleep(0.08)
    hi_dir = OUT / 'lib/l10n/hi'
    hi_dir.mkdir(parents=True, exist_ok=True)
    total = 0
    for _, suffix, keys in key_partitions():
        variable = 'mizanHindi' + ''.join(part.capitalize() for part in suffix.split('_'))
        lines = [
            '// MACHINE-GENERATED HINDI CANDIDATE — REQUIRES NATIVE PRODUCT REVIEW.',
            f'const Map<String, String> {variable} = <String, String>{{',
        ]
        for key in keys:
            value = cache[english[key]]
            lines.append(f'  {dart_quote(key)}: {dart_quote(value)},')
            total += 1
        lines.append('};')
        (hi_dir / f'mizan_hi_{suffix}.dart').write_text(
            '\n'.join(lines) + '\n', encoding='utf-8'
        )
    if total != 791:
        raise SystemExit(f'partition total mismatch: {total}')
    (OUT / 'candidate-summary.json').write_text(
        json.dumps(
            {'staticKeys': total, 'uniqueEnglishValues': len(unique_values)}, indent=2
        ),
        encoding='utf-8',
    )
    print(f'Hindi candidate generated: {total}/791')


if __name__ == '__main__':
    main()
