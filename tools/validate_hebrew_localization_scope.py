from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from build_hebrew_locale import verify as verify_runtime  # noqa: E402
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
CATALOG_MODEL = ROOT / "lib/global/global_catalog.dart"
LANGUAGES = ROOT / "assets/data/languages_v1.json"
COUNTRIES = ROOT / "assets/data/countries_v1.json"
CURRENCIES = ROOT / "assets/data/currencies_v1.json"
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
    "he",
    "hi", 'bn',
}


def fail(message: str) -> None:
    raise SystemExit(message)


def load_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def is_hebrew_letter(char: str) -> bool:
    return 0x05D0 <= ord(char) <= 0x05EA


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
    no_hebrew = [
        key
        for key, value in HEBREW_TERMINOLOGY.items()
        if value not in {"CSV", "PDF", "IBAN"}
        and not any(is_hebrew_letter(char) for char in value)
    ]
    if no_hebrew:
        fail(f"Hebrew terminology lacks Hebrew letters: {no_hebrew[:20]}")
    if any(any(char in value for char in HEBREW_FORBIDDEN_LITERAL_BIDI) for value in values):
        fail("Literal bidi controls leaked into Hebrew terminology")
    if any(unicodedata.normalize("NFC", value) != value for value in values):
        fail("Hebrew terminology is not NFC-normalized")
    missing_terms = sorted(term for term in REQUIRED_HEBREW_TERMS if term not in combined)
    if missing_terms:
        fail(f"Required Hebrew product terms are missing: {missing_terms}")
    if HEBREW_DIGITS != "0123456789":
        fail("Hebrew digit reference changed unexpectedly")


def validate_catalogs() -> None:
    payloads = (
        (load_json(LANGUAGES), 29, "language"),
        (load_json(COUNTRIES), 161, "country"),
        (load_json(CURRENCIES), 154, "currency"),
    )
    for payload, expected, label in payloads:
        items = payload.get("items", [])
        if payload.get("count") != expected or len(items) != expected:
            fail(f"{label} catalog count changed from {expected}")
        missing = [str(item.get("code")) for item in items if not str(item.get("nameHe", "")).strip()]
        if missing:
            fail(f"Hebrew {label} names are missing: {missing[:20]}")

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
        "nameHe": "עברית",
    }
    actual_metadata = {key: hebrew.get(key) for key in expected_metadata}
    if actual_metadata != expected_metadata:
        fail(f"Unexpected Hebrew language metadata: {actual_metadata}")


def validate_runtime() -> None:
    i18n = I18N.read_text(encoding="utf-8")
    main = MAIN.read_text(encoding="utf-8")
    formatters = FORMATTERS.read_text(encoding="utf-8")
    model = CATALOG_MODEL.read_text(encoding="utf-8")

    match = re.search(
        r"supportedLanguageTags\s*=\s*<String>\{(?P<body>[^}]*)\}",
        i18n,
        flags=re.DOTALL,
    )
    if not match:
        fail("Could not read supportedLanguageTags")
    tags = set(re.findall(r"'([^']+)'", match.group("body")))
    if tags != EXPECTED_INTEGRATED_LANGUAGES:
        fail(f"Nineteen-language runtime changed unexpectedly: {sorted(tags)}")

    required_i18n = (
        "import 'mizan_he.dart';",
        "import 'mizan_he_dynamic.dart';",
        "static bool get isHebrew",
        "mizanHebrew[visibleSource]",
        "translateHebrewReviewedDynamic(",
        "normalized.startsWith('he-')",
        "normalized.startsWith('iw-')",
        "'he' => 'אני מאשר'",
    )
    missing = [marker for marker in required_i18n if marker not in i18n]
    if missing:
        fail(f"Hebrew runtime integration is incomplete: {missing}")
    if "Locale('he', 'IL')" not in main:
        fail("Hebrew Flutter locale is not active")
    for marker in ("required this.nameHe", "final String nameHe", "'he' => nameHe"):
        if marker not in model:
            fail(f"Hebrew catalog model marker is missing: {marker}")
    for marker in ("MizanI18n.isHebrew", "₪", "heMonths", "_ltrIsolate"):
        if marker not in formatters:
            fail(f"Hebrew formatter marker is missing: {marker}")

    inherited = (
        "static bool get isPersian",
        "mizanPersian[visibleSource]",
        "translatePersianReviewedDynamic(",
        "normalized.startsWith('fa-')",
        "'fa' => 'תأیید می‌کنم'".replace("תأ", "تأ"),
    )
    missing_inherited = [marker for marker in inherited if marker not in i18n]
    if missing_inherited:
        fail(f"Persian final runtime regressed: {missing_inherited}")


def validate_inherited_reliability_fixes() -> None:
    monthly = (ROOT / "lib/services/monthly_payment_status_service.dart").read_text(encoding="utf-8")
    if "referenceDate" not in monthly or "calendarDaysBetween" not in monthly:
        fail("Monthly payment status reference-day fix is missing")
    if (ROOT / "lib/services/notification_service.dart").exists():
        fail("Removed notification platform service returned to product source")


def main() -> None:
    validate_contract()
    validate_terminology()
    validate_catalogs()
    validate_runtime()
    validate_inherited_reliability_fixes()
    verify_runtime()
    print(
        "Hebrew final scope verified: 791/791 copy, he-IL/iw runtime, one/two/other grammar, "
        "Hebrew script/NFC purity, RTL/bidi, pinned CLDR catalogs, Gregorian dates, ILS and "
        "inherited language/report/overdue/notification fixes."
    )


if __name__ == "__main__":
    main()
