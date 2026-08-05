#!/usr/bin/env python3
"""Validate final Hindi runtime scope and inherited MİZAN guarantees."""
from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))

from build_hindi_locale import verify as verify_runtime  # noqa: E402
from hindi_terminology import (  # noqa: E402
    HINDI_FORBIDDEN_INVISIBLE,
    HINDI_REQUIRED_CHARACTERS,
    HINDI_TERMINOLOGY,
)

CONTRACT = ROOT / 'docs/localization/hindi-quality-contract.md'
I18N = ROOT / 'lib/l10n/mizan_i18n.dart'
MAIN = ROOT / 'lib/main.dart'
FORMATTERS = ROOT / 'lib/core/formatters.dart'
CATALOG_MODEL = ROOT / 'lib/global/global_catalog.dart'
LANGUAGES = ROOT / 'assets/data/languages_v1.json'
COUNTRIES = ROOT / 'assets/data/countries_v1.json'
CURRENCIES = ROOT / 'assets/data/currencies_v1.json'
EXPECTED_INTEGRATED_LANGUAGES = {
    'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl',
    'ro', 'el', 'ru', 'uk', 'ar', 'fa', 'he', 'hi',
}


def fail(message: str) -> None:
    raise SystemExit(message)


def load_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding='utf-8'))


def validate_contract() -> None:
    text = CONTRACT.read_text(encoding='utf-8')
    required = (
        '791/791', 'Hintçe (`hi-IN`)', 'TextDirection.ltr', 'Gregoryen',
        'INR', '₹1,23,456.78', 'one` ve `other',
        '29 dil, 161 ülke ve 154 para birimi',
        'exactAllowWhileIdle', 'inexactAllowWhileIdle',
        '320×568 / 1,4×', '412×915 / 2,0×',
    )
    missing = [marker for marker in required if marker not in text]
    if missing:
        fail(f'Hindi quality contract incomplete: {missing}')
    if any(char in text for char in HINDI_FORBIDDEN_INVISIBLE):
        fail('Hindi contract contains literal invisible control characters')


def validate_terminology() -> None:
    if len(HINDI_TERMINOLOGY) < 200:
        fail(f'Hindi terminology coverage too small: {len(HINDI_TERMINOLOGY)}')
    if any(not key.strip() or not value.strip() for key, value in HINDI_TERMINOLOGY.items()):
        fail('Hindi terminology contains an empty entry')
    values = list(HINDI_TERMINOLOGY.values())
    combined = '\n'.join(values)
    for char in HINDI_REQUIRED_CHARACTERS:
        if char not in combined:
            fail(f'Required Hindi character absent: U+{ord(char):04X}')
    no_hindi = [
        key for key, value in HINDI_TERMINOLOGY.items()
        if value not in {'CSV', 'PDF', 'IBAN'}
        and not any(0x0900 <= ord(char) <= 0x097F for char in value)
    ]
    if no_hindi:
        fail(f'Hindi terminology lacks Devanagari: {no_hindi[:20]}')
    if any(any(char in value for char in HINDI_FORBIDDEN_INVISIBLE) for value in values):
        fail('Invisible controls leaked into Hindi terminology')
    if any(unicodedata.normalize('NFC', value) != value for value in values):
        fail('Hindi terminology is not NFC-normalized')


def validate_catalogs() -> None:
    payloads = (
        (load_json(LANGUAGES), 29, 'language'),
        (load_json(COUNTRIES), 161, 'country'),
        (load_json(CURRENCIES), 154, 'currency'),
    )
    for payload, expected, label in payloads:
        items = payload.get('items', [])
        if payload.get('count') != expected or len(items) != expected:
            fail(f'{label} catalog count changed from {expected}')
        missing = [str(item.get('code')) for item in items if not str(item.get('nameHi', '')).strip()]
        if missing:
            fail(f'Hindi {label} names missing: {missing[:20]}')
    languages = payloads[0][0]['items']
    codes = [str(item.get('code')) for item in languages]
    if codes.index('hi') != codes.index('he') + 1:
        fail(f'Hindi is not immediately after Hebrew: {codes}')
    hindi = languages[codes.index('hi')]
    expected = {
        'nativeName': 'हिन्दी',
        'nameTr': 'Hintçe',
        'nameEn': 'Hindi',
        'countryCodes': ['IN'],
        'nameHi': 'हिन्दी',
    }
    actual = {key: hindi.get(key) for key in expected}
    if actual != expected:
        fail(f'Unexpected Hindi language metadata: {actual}')


def validate_runtime() -> None:
    i18n = I18N.read_text(encoding='utf-8')
    main = MAIN.read_text(encoding='utf-8')
    formatters = FORMATTERS.read_text(encoding='utf-8')
    model = CATALOG_MODEL.read_text(encoding='utf-8')
    match = re.search(
        r'supportedLanguageTags\s*=\s*<String>\{(?P<body>[^}]*)\}',
        i18n,
        flags=re.DOTALL,
    )
    if not match:
        fail('Could not read supportedLanguageTags')
    tags = set(re.findall(r"'([^']+)'", match.group('body')))
    if tags != EXPECTED_INTEGRATED_LANGUAGES:
        fail(f'Eighteen-language runtime changed unexpectedly: {sorted(tags)}')
    required_i18n = (
        "import 'mizan_hi.dart';",
        "import 'mizan_hi_dynamic.dart';",
        'static bool get isHindi',
        'mizanHindi[visibleSource]',
        'translateHindiReviewedDynamic(',
        "normalized.startsWith('hi-')",
        "'hi' => 'मैं सहमत हूँ'",
    )
    missing = [marker for marker in required_i18n if marker not in i18n]
    if missing:
        fail(f'Hindi runtime integration incomplete: {missing}')
    if "Locale('hi', 'IN')" not in main:
        fail('Hindi Flutter locale is not active')
    for marker in ('required this.nameHi', 'final String nameHi', "'hi' => nameHi"):
        if marker not in model:
            fail(f'Hindi catalog model marker missing: {marker}')
    for marker in ('MizanI18n.isHindi', '₹', '_groupIndianDigits', 'hiMonths', 'devanagari'):
        if marker not in formatters:
            fail(f'Hindi formatter marker missing: {marker}')
    inherited = (
        'static bool get isHebrew',
        'mizanHebrew[visibleSource]',
        'translateHebrewReviewedDynamic(',
        "normalized.startsWith('iw-')",
        "'he' => 'אני מאשר'",
    )
    missing_inherited = [marker for marker in inherited if marker not in i18n]
    if missing_inherited:
        fail(f'Hebrew final runtime regressed: {missing_inherited}')


def validate_inherited_reliability_fixes() -> None:
    monthly = (ROOT / 'lib/services/monthly_payment_status_service.dart').read_text(encoding='utf-8')
    notifications = (ROOT / 'lib/services/notification_service.dart').read_text(encoding='utf-8')
    report = (ROOT / 'lib/services/report_service.dart').read_text(encoding='utf-8')
    if 'referenceDate' not in monthly or 'calendarDaysBetween' not in monthly:
        fail('Monthly payment status reference-day fix missing')
    for marker in ('exactAllowWhileIdle', 'inexactAllowWhileIdle'):
        if marker not in notifications:
            fail(f'Notification scheduling marker missing: {marker}')
    for marker in ('currencyCode', 'selectedPersonNames', 'ReportFilter'):
        if marker not in report:
            fail(f'Report integrity marker missing: {marker}')


def main() -> None:
    validate_contract()
    validate_terminology()
    validate_catalogs()
    validate_runtime()
    validate_inherited_reliability_fixes()
    verify_runtime()
    print(
        'Hindi final scope verified: 791/791 copy, hi-IN runtime, natural one/other grammar, '
        'Devanagari/NFC purity, LTR mixed-script behavior, catalogs 29/161/154, Indian grouping, '
        'INR, Gregorian dates and inherited language/report/overdue/notification guarantees.'
    )


if __name__ == '__main__':
    main()
