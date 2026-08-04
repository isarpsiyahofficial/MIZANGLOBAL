from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from persian_terminology import (  # noqa: E402
    PERSIAN_DIGITS,
    PERSIAN_FORBIDDEN_SYSTEM_CHARACTERS,
    PERSIAN_REQUIRED_CHARACTERS,
    PERSIAN_TERMINOLOGY,
    REQUIRED_TERMS,
)

CONTRACT = ROOT / "docs/localization/persian-quality-contract.md"
I18N = ROOT / "lib/l10n/mizan_i18n.dart"
MAIN = ROOT / "lib/main.dart"
CATALOG_MODEL = ROOT / "lib/global/global_catalog.dart"
LANGUAGES = ROOT / "assets/data/languages_v1.json"
COUNTRIES = ROOT / "assets/data/countries_v1.json"
CURRENCIES = ROOT / "assets/data/currencies_v1.json"


def load_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def fail(message: str) -> None:
    raise SystemExit(message)


def validate_contract() -> None:
    text = CONTRACT.read_text(encoding="utf-8")
    required = (
        "791/791",
        "Farsça (`fa-IR`)",
        "TextDirection.rtl",
        "U+06CC",
        "U+06A9",
        "U+200C",
        "\\u2066",
        "\\u2068",
        "\\u2069",
        "Gregoryen",
        "Şemsi/Jalali",
        "IRR",
        "tümen",
        "one/other",
        "29 dil, 161 ülke ve 154 para birimi",
        "inexactAllowWhileIdle",
    )
    missing = [marker for marker in required if marker not in text]
    if missing:
        fail(f"Persian quality contract is incomplete: {missing}")


def validate_language_order_and_counts() -> None:
    language_payload = load_json(LANGUAGES)
    country_payload = load_json(COUNTRIES)
    currency_payload = load_json(CURRENCIES)

    if language_payload.get("count") != 29 or len(language_payload.get("items", [])) != 29:
        fail("Language catalog count changed from 29")
    if country_payload.get("count") != 161 or len(country_payload.get("items", [])) != 161:
        fail("Country catalog count changed from 161")
    if currency_payload.get("count") != 154 or len(currency_payload.get("items", [])) != 154:
        fail("Currency catalog count changed from 154")

    codes = [str(item.get("code")) for item in language_payload["items"]]
    if "ar" not in codes or "fa" not in codes:
        fail("Arabic or Persian is missing from the language catalog")
    if codes.index("fa") != codes.index("ar") + 1:
        fail(f"Persian is not immediately after Arabic: {codes}")

    persian = language_payload["items"][codes.index("fa")]
    if persian.get("nativeName") != "فارسی":
        fail(f"Unexpected Persian native name: {persian.get('nativeName')!r}")
    if persian.get("countryCodes") != ["IR", "AF"]:
        fail(f"Unexpected Persian country coverage: {persian.get('countryCodes')!r}")


def validate_terminology() -> None:
    if len(PERSIAN_TERMINOLOGY) < 140:
        fail(f"Persian terminology coverage is too small: {len(PERSIAN_TERMINOLOGY)}")

    empty = [key for key, value in PERSIAN_TERMINOLOGY.items() if not key.strip() or not value.strip()]
    if empty:
        fail(f"Persian terminology contains empty entries: {empty[:10]}")

    values = list(PERSIAN_TERMINOLOGY.values())
    combined = "\n".join(values)
    for char in PERSIAN_REQUIRED_CHARACTERS:
        if char not in combined:
            fail(f"Required Persian character is absent from terminology: U+{ord(char):04X}")

    leaked = {
        char: [key for key, value in PERSIAN_TERMINOLOGY.items() if char in value]
        for char in PERSIAN_FORBIDDEN_SYSTEM_CHARACTERS
    }
    leaked = {char: keys for char, keys in leaked.items() if keys}
    if leaked:
        formatted = {f"U+{ord(char):04X}": keys[:10] for char, keys in leaked.items()}
        fail(f"Arabic/Urdu character variants leaked into Persian terminology: {formatted}")

    missing_terms = sorted(term for term in REQUIRED_TERMS if term not in combined)
    if missing_terms:
        fail(f"Required Persian product terms are missing: {missing_terms}")

    if sum(value.count("\u200c") for value in values) < 8:
        fail("Persian terminology does not exercise enough correct ZWNJ compounds")

    if PERSIAN_DIGITS not in "۰۱۲۳۴۵۶۷۸۹":
        fail("Persian digit reference changed unexpectedly")

    banned_words = ("settings", "payment", "expense", "настройки", "платежи", "إعدادات")
    hits = {
        word: [key for key, value in PERSIAN_TERMINOLOGY.items() if word.casefold() in value.casefold()]
        for word in banned_words
    }
    hits = {word: keys for word, keys in hits.items() if keys}
    if hits:
        fail(f"Other-language product terminology leaked into Persian glossary: {hits}")


def validate_runtime_lock() -> None:
    i18n = I18N.read_text(encoding="utf-8")
    main = MAIN.read_text(encoding="utf-8")
    catalog_model = CATALOG_MODEL.read_text(encoding="utf-8")

    required_arabic = (
        "static bool get isArabic",
        "mizanArabic[visibleSource]",
        "translateArabicReviewedDynamic(",
        "normalized.startsWith('ar-')",
    )
    missing_arabic = [marker for marker in required_arabic if marker not in i18n]
    if missing_arabic:
        fail(f"Accepted Arabic runtime is missing before Persian bootstrap: {missing_arabic}")

    forbidden_runtime = (
        "static bool get isPersian",
        "mizanPersian[visibleSource]",
        "translatePersianReviewedDynamic(",
        "normalized.startsWith('fa-')",
        "'fa' =>",
    )
    activated = [marker for marker in forbidden_runtime if marker in i18n]
    if activated:
        fail(f"Persian runtime was activated before acceptance gates: {activated}")

    if "Locale('fa'" in main or "Locale(\"fa\"" in main:
        fail("Persian Flutter locale was activated before acceptance gates")
    if "nameFa" in catalog_model:
        fail("Persian catalog model fields were activated before reviewed catalog data")
    if (ROOT / "lib/l10n/mizan_fa.dart").exists() or (ROOT / "lib/l10n/fa").exists():
        fail("Persian runtime source exists before 791-text acceptance")


def validate_inherited_defect_fixes() -> None:
    monthly = (ROOT / "lib/services/monthly_payment_status_service.dart").read_text(encoding="utf-8")
    notifications = (ROOT / "lib/services/notification_service.dart").read_text(encoding="utf-8")
    formatters = (ROOT / "lib/core/formatters.dart").read_text(encoding="utf-8")

    if "referenceDate" not in monthly or "calendarDaysBetween" not in monthly:
        fail("Monthly payment status reference-day fix is not present")
    for marker in ("exactAllowWhileIdle", "inexactAllowWhileIdle"):
        if marker not in notifications:
            fail(f"Notification fallback scheduling marker is missing: {marker}")
    for marker in ("_arabicDigits", "_westernDigits", "_ltrIsolate"):
        if marker not in formatters:
            fail(f"Accepted RTL/number formatter marker is missing: {marker}")


def main() -> None:
    validate_contract()
    validate_language_order_and_counts()
    validate_terminology()
    validate_runtime_lock()
    validate_inherited_defect_fixes()
    print(
        "Persian bootstrap scope verified: catalog order ar→fa, 29/161/154 counts, "
        f"{len(PERSIAN_TERMINOLOGY)} reviewed terms, Persian character/ZWNJ rules, "
        "RTL/bidi contract, Gregorian calendar lock, inherited Arabic runtime and defect fixes."
    )


if __name__ == "__main__":
    main()
