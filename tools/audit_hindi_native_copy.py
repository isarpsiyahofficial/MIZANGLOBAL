#!/usr/bin/env python3
"""Audit reviewed Hindi static product copy for native quality and purity."""
from __future__ import annotations

import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))

from build_hindi_locale import INVISIBLE, hindi_pairs, in_other_script, verify  # noqa: E402

ALLOWED_WITHOUT_DEVANAGARI = {
    'MİZAN GLOBAL',
    'LEFFERION PRIME - MIZAN',
    'LEFFERION PRIME - MİZAN',
    'IBAN',
}
REQUIRED_COPY = {
    'मुख्य पृष्ठ',
    'रिकॉर्ड',
    'खर्च',
    'रिपोर्ट',
    'सेटिंग्स',
    'बैंक का कर्ज़',
    'व्यक्तिगत / व्यावसायिक कर्ज़',
    'बिल',
    'सदस्यता',
    'किराया / किस्त',
    'भुगतान इतिहास',
    'शेष भुगतान दायित्व',
    'अतिदेय भुगतान दायित्व',
    'सूचना की अनुमति',
    'सटीक अलार्म की अनुमति',
    'बैकअप',
    'मैं सहमत हूँ',
}
FORBIDDEN_MACHINE_COPY = {
    'ऋृण',
    'गिरवी रखना',
    'रिवाज़',
    'जाँच करना',
    'वन टाइम',
    'एक - बारगी',
    'स्पष्ट खोज',
    'स्वचालित तुल्यकालन',
    'उत्कृष्ट कर्तव्य',
    'आप LIMIT',
    'Payday',
    'I CONFIRM',
    'मैं CONFIRM',
    'सम्पर्क का नम्बर',
    'अमान्य दलील',
    'कोई लोग',
    'मिलान व्यय',
    'पुरालेख',
    'रिकॉर्ड वाले रिकॉर्ड',
    'टेक्स्ट ओवरफ़्लो',
}
FORBIDDEN_VISIBLE_TURKISH = {
    'Ana sayfa', 'Kayıtlar', 'Giderler', 'Raporlar', 'Ayarlar',
    'Kaydet', 'Sil', 'Vazgeç', 'Banka borcu', 'Kalan tutar',
}
ALLOWED_LATIN = re.compile(
    r'(MİZAN GLOBAL|MİZAN|MIZAN|LEFFERION PRIME|Android|CSV|PDF|ISO|IBAN|INR|TRY|USD|EUR|WhatsApp|ZXQ\d+QXZ)'
)


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    verify()
    pairs = hindi_pairs()
    if len(pairs) != 791:
        fail(f'Hindi native-copy audit expected 791 values, found {len(pairs)}')
    values = [value for _, value in pairs]
    combined = '\n'.join(values)
    devanagari_values = [
        value for value in values if any(0x0900 <= ord(char) <= 0x097F for char in value)
    ]
    if len(devanagari_values) < 750:
        fail(f'Too few Hindi/Devanagari static values: {len(devanagari_values)}')
    no_hindi = [
        (key, value) for key, value in pairs
        if value not in ALLOWED_WITHOUT_DEVANAGARI
        and not any(0x0900 <= ord(char) <= 0x097F for char in value)
    ]
    if no_hindi:
        fail(f'Static values without Hindi product copy: {no_hindi[:20]}')
    script_leaks = [
        (key, value) for key, value in pairs if any(in_other_script(char) for char in value)
    ]
    if script_leaks:
        fail(f'Another product script leaked into Hindi copy: {script_leaks[:20]}')
    if any(char in combined for char in INVISIBLE):
        fail('Invisible/bidi control character leaked into Hindi static copy')
    if any(unicodedata.normalize('NFC', value) != value for value in values):
        fail('Hindi static copy is not NFC-normalized')
    latin_leaks = []
    for key, value in pairs:
        cleaned = ALLOWED_LATIN.sub('', value)
        if re.search(r'[A-Za-z]{3,}', cleaned):
            latin_leaks.append((key, value))
    if latin_leaks:
        fail(f'Unexpected visible Latin product copy in Hindi: {latin_leaks[:20]}')
    missing = sorted(term for term in REQUIRED_COPY if term not in combined)
    if missing:
        fail(f'Required Hindi product copy missing: {missing}')
    bad = sorted(term for term in FORBIDDEN_MACHINE_COPY if term in combined)
    if bad:
        fail(f'Forbidden machine-like Hindi copy remains: {bad}')
    visible_turkish = sorted(term for term in FORBIDDEN_VISIBLE_TURKISH if term in values)
    if visible_turkish:
        fail(f'Visible Turkish leaked into Hindi catalog: {visible_turkish}')
    translations = dict(pairs)
    exact_permission = translations[
        'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.'
    ]
    if 'अनुमानित' not in exact_permission or 'सटीक' not in exact_permission:
        fail('Hindi exact-alarm copy does not explain approximate and exact scheduling')
    if translations['ONAYLIYORUM'] != 'मैं सहमत हूँ':
        fail('Hindi destructive confirmation phrase changed')
    print(
        'Hindi native-copy audit passed: 791/791 values, natural India-oriented Hindi, '
        'Devanagari/NFC/invisible-character purity, product terminology and Android scheduling semantics.'
    )


if __name__ == '__main__':
    main()
