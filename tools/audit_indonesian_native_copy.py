#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ID_DIR = ROOT / 'lib' / 'l10n' / 'id'
BN_DIR = ROOT / 'lib' / 'l10n' / 'bn'
ENTRY = re.compile(
    r"'((?:\\.|[^'])*)':\s*(?:\n\s*)?'((?:\\.|[^'])*)'",
    re.MULTILINE,
)
FORBIDDEN_SCRIPTS = re.compile(
    r'[\u0400-\u052f\u0590-\u08ff\u0900-\u0dff\u0e00-\u109f'
    r'\u1100-\u11ff\u2e80-\u9fff\uac00-\ud7af]'
)
TURKISH_MARKERS = re.compile(
    r'\b(?:ödeme|gider|borç|kayıt|fatura|kira|taksit|gelir|bildirim|ayarlar|'
    r'kaydet|sil|düzenle|gecikmiş|yaklaşan|tutar|kişi|banka|abonelik)\b',
    re.IGNORECASE,
)
INDONESIAN_MARKERS = (
    'pembayaran', 'pengeluaran', 'utang', 'catatan', 'tagihan', 'pemasukan',
    'notifikasi', 'pengaturan', 'jatuh tempo', 'cicilan', 'simpan', 'hapus',
)
ALLOWED_EQUAL = {
    'Aktif', 'Internet', 'IBAN', 'MİZAN GLOBAL', 'LEFFERION PRIME - MIZAN',
    'LEFFERION PRIME - MİZAN', 'Limit', 'PDF', 'CSV', 'Android', 'MİZAN',
}


def parse_maps(directory: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for path in sorted(directory.glob('mizan_*_*.dart')):
        text = path.read_text(encoding='utf-8')
        for match in ENTRY.finditer(text):
            key = match.group(1).replace("\\'", "'")
            value = match.group(2).replace("\\'", "'")
            if key in result:
                raise AssertionError(f'duplicate key {key!r} in {path}')
            result[key] = value
    return result


def main() -> int:
    source = parse_maps(BN_DIR)
    target = parse_maps(ID_DIR)
    errors: list[str] = []
    if len(source) != 791:
        errors.append(f'expected 791 reference keys, found {len(source)}')
    if len(target) != 791:
        errors.append(f'expected 791 Indonesian keys, found {len(target)}')
    missing = sorted(set(source) - set(target))
    extra = sorted(set(target) - set(source))
    if missing:
        errors.append(f'missing Indonesian keys ({len(missing)}): {missing[:15]}')
    if extra:
        errors.append(f'extra Indonesian keys ({len(extra)}): {extra[:15]}')
    for key, value in target.items():
        if not value.strip():
            errors.append(f'empty Indonesian value for {key!r}')
        if FORBIDDEN_SCRIPTS.search(value):
            errors.append(f'foreign-script leakage for {key!r}: {value!r}')
        if TURKISH_MARKERS.search(value):
            errors.append(f'Turkish fallback marker for {key!r}: {value!r}')
        if key == value and key not in ALLOWED_EQUAL and len(key) > 3:
            errors.append(f'untranslated value for {key!r}')
    joined = ' '.join(target.values()).lower()
    for marker in INDONESIAN_MARKERS:
        if marker not in joined:
            errors.append(f'missing core Indonesian terminology: {marker}')
    dynamic = (ROOT / 'lib' / 'l10n' / 'mizan_id_dynamic.dart').read_text(encoding='utf-8')
    for required in ('translateIndonesianReviewedDynamic', 'Jatuh tempo hari ini', 'SAYA SETUJU'):
        if required.lower() not in (dynamic + joined).lower():
            errors.append(f'missing Indonesian runtime contract: {required}')
    if errors:
        print('\n'.join(f'ERROR: {item}' for item in errors))
        return 1
    print(f'Indonesian native-copy audit passed: {len(target)}/791 static keys, dynamic grammar present.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
