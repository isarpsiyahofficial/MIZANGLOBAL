from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from build_persian_locale import verify as verify_runtime  # noqa: E402
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
        "exactAllowWhileIdle",
        "inexactAllowWhileIdle",
    )
    missing = [marker for marker in required if marker not in text]
    if missing:
        fail(f"Persian quality contract is incomplete: {missing}")


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
        missing = [str(item.get("code")) for item in items if not str(item.get("nameFa", "")).strip()]
        if missing:
            fail(f"Persian {label} names are missing: {missing[:20]}")

    language_payload = payloads[0][0]
    codes = [str(item.get("code")) for item in language_payload["items"]]
    if codes.index("fa") != codes.index("ar") + 1:
        fail(f"Persian is not immediately after Arabic: {codes}")
    persian = language_payload["items"][codes.index("fa")]
    if persian.get("nativeName") != "فارسی" or persian.get("countryCodes") != ["IR", "AF"]:
        fail(f"Unexpected Persian language metadata: {persian}")


def validate_terminology() -> None:
    if len(PERSIAN_TERMINOLOGY) < 140:
        fail(f"Persian terminology coverage is too small: {len(PERSIAN_TERMINOLOGY)}")
    values = list(PERSIAN_TERMINOLOGY.values())
    combined = "\n".join(values)
    if any(not key.strip() or not value.strip() for key, value in PERSIAN_TERMINOLOGY.items()):
        fail("Persian terminology contains an empty entry")
    for char in PERSIAN_REQUIRED_CHARACTERS:
        if char not in combined:
            fail(f"Required Persian character is absent: U+{ord(char):04X}")
    leaks = {
        char: [key for key, value in PERSIAN_TERMINOLOGY.items() if char in value]
        for char in PERSIAN_FORBIDDEN_SYSTEM_CHARACTERS
    }
    leaks = {char: keys for char, keys in leaks.items() if keys}
    if leaks:
        fail(f"Arabic/Urdu variants leaked into Persian terminology: {leaks}")
    missing_terms = sorted(term for term in REQUIRED_TERMS if term not in combined)
    if missing_terms:
        fail(f"Required Persian product terms are missing: {missing_terms}")
    if sum(value.count("\u200c") for value in values) < 8:
        fail("Persian terminology does not exercise enough correct ZWNJ compounds")
    if PERSIAN_DIGITS != "۰۱۲۳۴۵۶۷۸۹":
        fail("Persian digit reference changed unexpectedly")


def validate_runtime() -> None:
    i18n = I18N.read_text(encoding="utf-8")
    main = MAIN.read_text(encoding="utf-8")
    catalog_model = CATALOG_MODEL.read_text(encoding="utf-8")
    required_i18n = (
        "static bool get isPersian",
        "mizanPersian[visibleSource]",
        "translatePersianReviewedDynamic(",
        "normalized.startsWith('fa-')",
        "'fa' => 'تأیید می‌کنم'",
    )
    missing = [marker for marker in required_i18n if marker not in i18n]
    if missing:
        fail(f"Persian runtime is incomplete: {missing}")
    if "Locale('fa', 'IR')" not in main:
        fail("Persian Flutter locale is not active")
    for marker in ("required this.nameFa", "final String nameFa", "'fa' => nameFa"):
        if marker not in catalog_model:
            fail(f"Persian catalog model marker is missing: {marker}")


def validate_inherited_fixes() -> None:
    monthly = (ROOT / "lib/services/monthly_payment_status_service.dart").read_text(encoding="utf-8")
    formatters = (ROOT / "lib/core/formatters.dart").read_text(encoding="utf-8")
    if "referenceDate" not in monthly or "calendarDaysBetween" not in monthly:
        fail("Monthly payment status reference-day fix is missing")
    if (ROOT / "lib/services/notification_service.dart").exists():
        fail("Removed notification platform service returned to product source")
    for marker in ("_arabicDigits", "_persianDigits", "_westernDigits", "_ltrIsolate"):
        if marker not in formatters:
            fail(f"RTL/number formatter marker is missing: {marker}")


def main() -> None:
    validate_contract()
    validate_catalogs()
    validate_terminology()
    validate_runtime()
    validate_inherited_fixes()
    verify_runtime()
    print(
        "Persian final scope verified: 791/791 copy, fa-IR runtime, one/other grammar, "
        "Persian character/ZWNJ purity, RTL/bidi, pinned CLDR catalogs, Gregorian dates, "
        "IRR/rial and inherited overdue/notification fixes."
    )


if __name__ == "__main__":
    main()
