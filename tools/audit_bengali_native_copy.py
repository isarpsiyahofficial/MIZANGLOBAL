#!/usr/bin/env python3
"""Audit final Bengali static product copy for native quality and purity."""
from __future__ import annotations

import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))

from materialize_bengali_locale import bengali_pairs, verify  # noqa: E402

ALLOWED_WITHOUT_BENGALI = {
    'MİZAN GLOBAL',
    'LEFFERION PRIME - MIZAN',
    'LEFFERION PRIME - MİZAN',
    'IBAN',
    'PDF',
    'CSV',
}
ALLOWED_LATIN = re.compile(
    r'(MİZAN GLOBAL|MİZAN|MIZAN|LEFFERION PRIME|Android|CSV|PDF|ISO|IBAN|BDT|INR|TRY|USD|EUR|WhatsApp|ZXQ\d+QXZ)'
)
REQUIRED_COPY = {
    'হোম',
    'রেকর্ড',
    'খরচ',
    'প্রতিবেদন',
    'সেটিংস',
    'ব্যাংক ঋণ',
    'ব্যক্তিগত / ব্যবসায়িক ঋণ',
    'বিল',
    'সাবস্ক্রিপশন',
    'ভাড়া ও কিস্তি',
    'পরিশোধের ইতিহাস',
    'অবশিষ্ট পরিশোধের দায়',
    'মেয়াদোত্তীর্ণ পরিশোধের দায়',
    'আসন্ন পরিশোধের দায়',
    'বিজ্ঞপ্তির অনুমতি',
    'সঠিক সময়ের অ্যালার্মের অনুমতি',
    'CSV ব্যাকআপ একত্র করুন',
    'আমি নিশ্চিত করছি',
    'PDF প্রতিবেদন',
}
FORBIDDEN_MACHINE_COPY = {
    'I CONFIRM',
    'CONFIRM',
    'অর্থপ্রদান',
    'পেমেন্ট',
    'রিমাইন্ডার',
    'রিপোর্ট',
    'ওভারডিউ',
    'ওভারডু',
    'ব্রেকডাউন',
    'ডেটা মার্জ',
    'শিশু সম্পর্ক',
    'অসামান্য পরিশোধ',
    'বকেয়া পরিশোধ বিশদ',
    'কোন আয় তথ্য',
    'টেক্সট ওভারফ্লো',
    'রেকর্ডযুক্ত রেকর্ড',
}
FORBIDDEN_VISIBLE_TURKISH = {
    'Ana sayfa',
    'Kayıtlar',
    'Giderler',
    'Raporlar',
    'Ayarlar',
    'Kaydet',
    'Sil',
    'Vazgeç',
    'Banka borcu',
    'Kalan tutar',
}
INVISIBLE = tuple(
    chr(code)
    for code in (
        0x200B,
        0x200C,
        0x200D,
        0x200E,
        0x200F,
        0x202A,
        0x202B,
        0x202C,
        0x202D,
        0x202E,
        0x2066,
        0x2067,
        0x2068,
        0x2069,
    )
)


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    verify()
    pairs = bengali_pairs()
    if len(pairs) != 791:
        fail(f'Bengali native-copy audit expected 791 values, found {len(pairs)}')
    values = [value for _, value in pairs]
    combined = '\n'.join(values)
    bengali_values = [
        value for value in values if any(0x0980 <= ord(char) <= 0x09FF for char in value)
    ]
    if len(bengali_values) < 750:
        fail(f'Too few Bengali static values: {len(bengali_values)}')
    no_bengali = [
        (key, value)
        for key, value in pairs
        if value not in ALLOWED_WITHOUT_BENGALI
        and not any(0x0980 <= ord(char) <= 0x09FF for char in value)
    ]
    if no_bengali:
        fail(f'Static values without Bengali product copy: {no_bengali[:20]}')
    if any(char in combined for char in INVISIBLE):
        fail('Invisible/bidi control character leaked into Bengali static copy')
    if any(unicodedata.normalize('NFC', value) != value for value in values):
        fail('Bengali static copy is not NFC-normalized')
    latin_leaks = []
    for key, value in pairs:
        cleaned = ALLOWED_LATIN.sub('', value)
        if re.search(r'[A-Za-z]{3,}', cleaned):
            latin_leaks.append((key, value))
    if latin_leaks:
        fail(f'Unexpected visible Latin product copy in Bengali: {latin_leaks[:20]}')
    missing = sorted(term for term in REQUIRED_COPY if term not in combined)
    if missing:
        fail(f'Required Bengali product copy missing: {missing}')
    bad = sorted(term for term in FORBIDDEN_MACHINE_COPY if term in combined)
    if bad:
        fail(f'Forbidden machine-like Bengali copy remains: {bad}')
    visible_turkish = sorted(term for term in FORBIDDEN_VISIBLE_TURKISH if term in values)
    if visible_turkish:
        fail(f'Visible Turkish leaked into Bengali catalog: {visible_turkish}')
    translations = dict(pairs)
    exact_permission = translations[
        'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.'
    ]
    if 'আনুমানিক' not in exact_permission or 'সঠিক' not in exact_permission:
        fail('Bengali exact-alarm copy does not explain approximate and exact scheduling')
    if translations['ONAYLIYORUM'] != 'আমি নিশ্চিত করছি':
        fail('Bengali destructive confirmation phrase changed')
    report = (ROOT / 'lib/l10n/bn/mizan_bn_reports.dart').read_text(encoding='utf-8')
    for marker in (
        'অবশিষ্ট পরিশোধের দায়ের বণ্টন',
        'মেয়াদোত্তীর্ণ পরিমাণ হলো খোলা ও অপরিশোধিত সময়পর্বগুলোর মোট।',
        'সময়পর্ব ও ব্যক্তি ফিল্টার পর্দা এবং PDF-এ হুবহু একই থাকে।',
        'PDF প্রতিবেদনের পৃষ্ঠা ছবিতে রূপান্তর করা যায়নি।',
    ):
        if marker not in report:
            fail(f'Natural Bengali report/PDF marker missing: {marker}')
    print(
        'Bengali native-copy audit passed: 791/791 values, Bengali/NFC purity, '
        'natural financial terminology, report/PDF copy and Android scheduling semantics.'
    )


if __name__ == '__main__':
    main()
