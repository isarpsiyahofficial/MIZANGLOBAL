from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from hebrew_terminology import (  # noqa: E402
    HEBREW_DIGITS,
    HEBREW_FORBIDDEN_LITERAL_BIDI,
    HEBREW_REQUIRED_CHARACTERS,
    HEBREW_TERMINOLOGY,
    REQUIRED_HEBREW_TERMS,
)

CONTRACT = ROOT / "docs/localization/hebrew-quality-contract.md"
I18N = ROOT / "lib/l10n/mizan_i18n.dart"
MAIN = ROOT / "lib/main.dart"
FORMATTERS = ROOT / "lib/core/formatters.dart"
LANGUAGES = ROOT / "assets/data/languages_v1.json"
COUNTRIES = ROOT / "assets/data/countries_v1.json"
CURRENCIES = ROOT / "assets/data/currencies_v1.json"

ARABIC_SCRIPT_RANGES = (
    (0x0600, 0x06FF),
    (0x0750, 0x077F),
    (0x08A0, 0x08FF),
    (0xFB50, 0xFDFF),
    (0xFE70, 0xFEFF),
)
HEBREW_NIQQUD_RANGE = range(0x0591, 0x05C8)
ALLOWED_TECHNICAL_VALUES = {"CSV", "PDF", "IBAN"}
EXPECTED_INTEGRATED_LANGUAGES = {
    "tr",
    "en",
    "es",
    "pt-BR",
    "pt-PT",
    "fr",
    "de",
    "it",
    "nl",
    "pl",
    "ro",
    "el",
    "ru",
    "uk",
    "ar",
    "fa",
}


def fail(message: str) -> None:
    raise SystemExit(message)


def load_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def is_hebrew_letter(char: str) -> bool:
    return 0x05D0 <= ord(char) <= 0x05EA


def is_arabic_script(char: str) -> bool:
    code = ord(char)
    return any(start <= code <= end for start, end in ARABIC_SCRIPT_RANGES)


def validate_contract() -> None:
    text = CONTRACT.read_text(encoding="utf-8")
    required = (
        "791/791",
        "İbranice (`he-IL`)",
        "TextDirection.rtl",
        "\\u2066",
        "\\u2067",
        "\\u2068",
        "\\u2069",
        "Gregoryen",
        "İbrani takvimine",
        "ILS",
        "one`, `two`, `other",
        "29 dil, 161 ülke ve 154 para birimi",
        "exactAllowWhileIdle",
        "inexactAllowWhileIdle",
        "iw",
    )
    missing = [marker for marker in required if marker not in text]
    if missing:
        fail(f"Hebrew quality contract is incomplete: {missing}")
    if any(char in text for char in HEBREW_FORBIDDEN_LITERAL_BIDI):
        fail("Hebrew quality contract contains literal bidi control characters")


def validate_terminology() -> None:
    if len(HEBREW_TERMINOLOGY) < 200:
        fail(f"Hebrew terminology coverage is too small: {len(HEBREW_TERMINOLOGY)}")
    if any(not key.strip() or not value.strip() for key, value in HEBREW_TERMINOLOGY.items()):
        fail("Hebrew terminology contains an empty entry")

    values = list(HEBREW_TERMINOLOGY.values())
    combined = "\n".join(values)
    for char in HEBREW_REQUIRED_CHARACTERS:
        if char not in combined:
            fail(f"Required Hebrew character is absent: U+{ord(char):04X}")

    non_hebrew = [
        key
        for key, value in HEBREW_TERMINOLOGY.items()
        if value not in ALLOWED_TECHNICAL_VALUES
        and not any(is_hebrew_letter(char) for char in value)
    ]
    if non_hebrew:
        fail(f"Hebrew terminology lacks Hebrew letters: {non_hebrew[:20]}")

    arabic_leaks = {
        key: value
        for key, value in HEBREW_TERMINOLOGY.items()
        if any(is_arabic_script(char) for char in value)
    }
    if arabic_leaks:
        fail(f"Arabic/Persian/Urdu script leaked into Hebrew terminology: {arabic_leaks}")

    niqqud_leaks = {
        key: value
        for key, value in HEBREW_TERMINOLOGY.items()
        if any(ord(char) in HEBREW_NIQQUD_RANGE for char in value)
    }
    if niqqud_leaks:
        fail(f"Unexpected niqqud leaked into Hebrew product terminology: {niqqud_leaks}")

    bidi_leaks = {
        key: value
        for key, value in HEBREW_TERMINOLOGY.items()
        if any(char in value for char in HEBREW_FORBIDDEN_LITERAL_BIDI)
    }
    if bidi_leaks:
        fail(f"Literal bidi controls leaked into Hebrew terminology: {bidi_leaks}")

    not_normalized = {
        key: value
        for key, value in HEBREW_TERMINOLOGY.items()
        if unicodedata.normalize("NFC", value) != value
    }
    if not_normalized:
        fail(f"Hebrew terminology is not NFC-normalized: {not_normalized}")

    missing_terms = sorted(term for term in REQUIRED_HEBREW_TERMS if term not in combined)
    if missing_terms:
        fail(f"Required Hebrew product terms are missing: {missing_terms}")
    if HEBREW_DIGITS != "0123456789":
        fail("Hebrew digit reference changed unexpectedly")


def validate_catalog_sequence() -> None:
    payloads = (
        (load_json(LANGUAGES), 29, "language"),
        (load_json(COUNTRIES), 161, "country"),
        (load_json(CURRENCIES), 154, "currency"),
    )
    for payload, expected, label in payloads:
        items = payload.get("items", [])
        if payload.get("count") != expected or len(items) != expected:
            fail(f"{label} catalog count changed from {expected}")

    languages = payloads[0][0]["items"]
    codes = [str(item.get("code")) for item in languages]
    if codes.index("he") != codes.index("fa") + 1:
        fail(f"Hebrew is not immediately after Persian: {codes}")
    hebrew = languages[codes.index("he")]
    expected_metadata = {
        "nativeName": "עברית",
        "nameTr": "İbranice",
        "nameEn": "Hebrew",
        "countryCodes": ["IL"],
    }
    actual_metadata = {key: hebrew.get(key) for key in expected_metadata}
    if actual_metadata != expected_metadata:
        fail(f"Unexpected Hebrew language metadata: {actual_metadata}")


def validate_activation_lock_and_inherited_runtime() -> None:
    i18n = I18N.read_text(encoding="utf-8")
    main = MAIN.read_text(encoding="utf-8")
    formatters = FORMATTERS.read_text(encoding="utf-8")

    match = re.search(
        r"supportedLanguageTags\s*=\s*<String>\{(?P<body>[^}]*)\}",
        i18n,
        flags=re.DOTALL,
    )
    if not match:
        fail("Could not read supportedLanguageTags")
    tags = set(re.findall(r"'([^']+)'", match.group("body")))
    if tags != EXPECTED_INTEGRATED_LANGUAGES:
        fail(f"Inherited sixteen-language runtime changed unexpectedly: {sorted(tags)}")

    premature_markers = (
        "import 'mizan_he.dart';",
        "import 'mizan_he_dynamic.dart';",
        "static bool get isHebrew",
        "mizanHebrew[visibleSource]",
        "translateHebrewReviewedDynamic(",
        "normalized.startsWith('he-')",
        "Locale('he', 'IL')",
    )
    found = [marker for marker in premature_markers if marker in i18n or marker in main]
    if found:
        fail(f"Hebrew runtime was enabled before the 791-key acceptance gates: {found}")

    inherited_markers = (
        "static bool get isPersian",
        "mizanPersian[visibleSource]",
        "translatePersianReviewedDynamic(",
        "normalized.startsWith('fa-')",
        "'fa' => 'تأیید می‌کنم'",
    )
    missing = [marker for marker in inherited_markers if marker not in i18n]
    if missing:
        fail(f"Persian final runtime regressed: {missing}")
    if "Locale('fa', 'IR')" not in main:
        fail("Persian Flutter locale regressed")
    for marker in ("_arabicDigits", "_persianDigits", "_westernDigits", "_ltrIsolate"):
        if marker not in formatters:
            fail(f"Inherited RTL/number formatter marker is missing: {marker}")


def validate_inherited_reliability_fixes() -> None:
    monthly = (ROOT / "lib/services/monthly_payment_status_service.dart").read_text(encoding="utf-8")
    notifications = (ROOT / "lib/services/notification_service.dart").read_text(encoding="utf-8")
    if "referenceDate" not in monthly or "calendarDaysBetween" not in monthly:
        fail("Monthly payment status reference-day fix is missing")
    for marker in ("exactAllowWhileIdle", "inexactAllowWhileIdle"):
        if marker not in notifications:
            fail(f"Notification fallback scheduling marker is missing: {marker}")


def main() -> None:
    validate_contract()
    validate_terminology()
    validate_catalog_sequence()
    validate_activation_lock_and_inherited_runtime()
    validate_inherited_reliability_fixes()
    print(
        "Hebrew scope foundation verified: binding he-IL contract, reviewed terminology, "
        "fa→he catalog order, RTL/bidi rules, CLDR one/two/other requirements, ILS and "
        "Gregorian-date policy, inherited sixteen-language runtime, and activation lock."
    )


if __name__ == "__main__":
    main()
