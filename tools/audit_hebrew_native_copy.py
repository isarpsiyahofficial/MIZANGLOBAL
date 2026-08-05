#!/usr/bin/env python3
"""Audit the reviewed Hebrew static catalog for language and product quality."""
from __future__ import annotations

import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from build_hebrew_locale import BIDI_CONTROLS, hebrew_pairs, is_arabic_script, verify  # noqa: E402

ALLOWED_WITHOUT_HEBREW = {
    "MİZAN GLOBAL",
    "LEFFERION PRIME - MIZAN",
    "LEFFERION PRIME - MİZAN",
    "PDF",
    "CSV",
    "IBAN",
    "Android",
}
REQUIRED_COPY = {
    "דף הבית",
    "רשומות",
    "הוצאות",
    "דוחות",
    "הגדרות",
    "חוב בנקאי",
    "חוב אישי או עסקי",
    "חשבון",
    "מנוי",
    "שכר דירה או תשלום",
    "היסטוריית תשלומים",
    "התחייבויות תשלום שנותרו",
    "הרשאת התראות",
    "הרשאה לתזמון מדויק",
    "גיבוי",
    "מיזוג גיבוי CSV עם הנתונים הקיימים",
}
FORBIDDEN_VISIBLE_TURKISH = {
    "Ana sayfa",
    "Kayıtlar",
    "Giderler",
    "Raporlar",
    "Ayarlar",
    "Kaydet",
    "Sil",
    "Vazgeç",
    "Banka borcu",
    "Kalan tutar",
    "Son ödeme tarihi",
}


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    verify()
    pairs = hebrew_pairs()
    if len(pairs) != 791:
        fail(f"Hebrew native-copy audit expected 791 values, found {len(pairs)}")

    values = [value for _, value in pairs]
    combined = "\n".join(values)
    hebrew_specific = [
        value for value in values if any(0x05D0 <= ord(char) <= 0x05EA for char in value)
    ]
    if len(hebrew_specific) < 650:
        fail(f"Too few Hebrew-specific static values: {len(hebrew_specific)}")

    no_hebrew = [
        (key, value)
        for key, value in pairs
        if value not in ALLOWED_WITHOUT_HEBREW
        and not any(0x05D0 <= ord(char) <= 0x05EA for char in value)
    ]
    if no_hebrew:
        fail(f"Static values without Hebrew product copy: {no_hebrew[:20]}")

    arabic_leaks = [
        (key, value)
        for key, value in pairs
        if any(is_arabic_script(char) for char in value)
    ]
    if arabic_leaks:
        fail(f"Arabic/Persian/Urdu script leaked into Hebrew copy: {arabic_leaks[:20]}")

    niqqud_leaks = [
        (key, value)
        for key, value in pairs
        if any(0x0591 <= ord(char) <= 0x05C7 for char in value)
    ]
    if niqqud_leaks:
        fail(f"Unexpected niqqud leaked into Hebrew product copy: {niqqud_leaks[:20]}")

    if any(char in combined for char in BIDI_CONTROLS):
        fail("Literal bidi control character leaked into Hebrew static copy")
    if any(unicodedata.normalize("NFC", value) != value for value in values):
        fail("Hebrew static copy is not NFC-normalized")

    missing_copy = sorted(value for value in REQUIRED_COPY if value not in values)
    if missing_copy:
        fail(f"Required Hebrew product copy is missing: {missing_copy}")
    leaks = sorted(token for token in FORBIDDEN_VISIBLE_TURKISH if token in values)
    if leaks:
        fail(f"Visible Turkish UI values leaked into Hebrew catalog: {leaks}")

    translations = dict(pairs)
    exact_permission = translations[
        "Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır."
    ]
    test_permission = translations[
        "Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak."
    ]
    for value in (exact_permission, test_permission):
        if "תזמון משוער" not in value:
            fail("Hebrew notification fallback copy does not describe approximate scheduling")
    if "תזמון מדויק" not in exact_permission:
        fail("Hebrew exact-alarm copy does not describe exact scheduling")

    print(
        "Hebrew native-copy audit passed: 791/791 values, natural Hebrew coverage, "
        "script/NFC/bidi purity, product terminology and Android scheduling semantics."
    )


if __name__ == "__main__":
    main()
