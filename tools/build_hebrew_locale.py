#!/usr/bin/env python3
"""Integrate and verify the reviewed Hebrew locale with pinned CLDR data."""
from __future__ import annotations

import argparse
import json
import re
import sys
import unicodedata
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from build_ukrainian_locale import english_pairs, parse_map  # noqa: E402

CLDR_COMMIT = "3701646856d5cdc946fc8fca8b9a36b5c5c300ba"
CLDR_BASE = f"https://raw.githubusercontent.com/unicode-org/cldr-json/{CLDR_COMMIT}/cldr-json"
PARTS = tuple(sorted((ROOT / "lib/l10n/he").glob("mizan_he_*.dart")))
I18N = ROOT / "lib/l10n/mizan_i18n.dart"
LEGACY_I18N = ROOT / "lib/l10n/mizan_i18n_legacy.dart"
MAIN = ROOT / "lib/main.dart"
CATALOG_MODEL = ROOT / "lib/global/global_catalog.dart"
FORMATTERS = ROOT / "lib/core/formatters_legacy.dart"
LANGUAGES = ROOT / "assets/data/languages_v1.json"
COUNTRIES = ROOT / "assets/data/countries_v1.json"
CURRENCIES = ROOT / "assets/data/currencies_v1.json"

BIDI_CONTROLS = "\u200e\u200f\u202a\u202b\u202c\u202d\u202e\u2066\u2067\u2068\u2069"
ARABIC_RANGES = (
    (0x0600, 0x06FF),
    (0x0750, 0x077F),
    (0x08A0, 0x08FF),
    (0xFB50, 0xFDFF),
    (0xFE70, 0xFEFF),
)
NIQQUD_RANGE = range(0x0591, 0x05C8)


def fail(message: str) -> None:
    raise SystemExit(message)


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    count = text.count(old)
    if count != 1:
        fail(
            f"Expected one Hebrew integration target in {path.relative_to(ROOT)}; "
            f"found {count}: {old[:120]!r}"
        )
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_count(path: Path, old: str, new: str, expected: int) -> None:
    text = path.read_text(encoding="utf-8")
    if text.count(new) == expected:
        return
    count = text.count(old)
    if count != expected:
        fail(
            f"Expected {expected} Hebrew integration targets in {path.relative_to(ROOT)}; "
            f"found {count}: {old[:120]!r}"
        )
    path.write_text(text.replace(old, new), encoding="utf-8")


def load_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, payload: dict[str, object]) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )


def fetch_json(relative: str) -> dict[str, object]:
    request = urllib.request.Request(
        f"{CLDR_BASE}/{relative}",
        headers={"User-Agent": "MIZAN-Hebrew-catalog-builder/1.0"},
    )
    with urllib.request.urlopen(request, timeout=45) as response:
        return json.load(response)


def sanitize_hebrew_sources() -> None:
    paths = (*PARTS, ROOT / "lib/l10n/mizan_he.dart", ROOT / "lib/l10n/mizan_he_dynamic.dart")
    for path in paths:
        text = path.read_text(encoding="utf-8")
        cleaned = text.translate({ord(char): None for char in BIDI_CONTROLS})
        cleaned = unicodedata.normalize("NFC", cleaned)
        if cleaned != text:
            path.write_text(cleaned, encoding="utf-8")


def integrate_i18n() -> None:
    replace_once(
        I18N,
        "import 'mizan_fa_dynamic.dart';",
        "import 'mizan_fa_dynamic.dart';\nimport 'mizan_he.dart';\nimport 'mizan_he_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar', 'fa'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar', 'fa', 'he'};",
    )
    replace_once(
        I18N,
        "  static bool get isPersian => _languageTag == 'fa';\n",
        "  static bool get isPersian => _languageTag == 'fa';\n  static bool get isHebrew => _languageTag == 'he';\n",
    )
    replace_once(
        I18N,
        "    'fa' => 'תأیید می‌کنم',\n".replace("ת", "ت"),
        "    'fa' => 'תأیید می‌کنم',\n    'he' => 'אני מאשר',\n".replace("תأ", "تأ"),
    )
    replace_once(
        I18N,
        "    if (normalized == 'fa' || normalized.startsWith('fa-')) return 'fa';\n",
        "    if (normalized == 'fa' || normalized.startsWith('fa-')) return 'fa';\n    if (normalized == 'he' || normalized.startsWith('he-') || normalized == 'iw' || normalized.startsWith('iw-')) return 'he';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'fa' ||\n        normalized.startsWith('fa-');\n",
        "        normalized == 'fa' ||\n        normalized.startsWith('fa-') ||\n        normalized == 'he' ||\n        normalized.startsWith('he-') ||\n        normalized == 'iw' ||\n        normalized.startsWith('iw-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanPersian[visibleSource] ??
          translatePersianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'fa'),
          );
    }
""",
        """    } else if (effective == 'fa') {
      result =
          mizanPersian[visibleSource] ??
          translatePersianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'fa'),
          );
    } else {
      result =
          mizanHebrew[visibleSource] ??
          translateHebrewReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'he'),
          );
    }
""",
    )
    replace_once(
        I18N,
        "      final visibleUser = effective == 'ar' || effective == 'fa'\n          ? '\\u2068${entry.value}\\u2069'\n          : entry.value;",
        "      final visibleUser = effective == 'ar' || effective == 'fa' || effective == 'he'\n          ? '\\u2068${entry.value}\\u2069'\n          : entry.value;",
    )


def integrate_main() -> None:
    replace_once(
        MAIN,
        "          'fa' => const Locale('fa', 'IR'),\n",
        "          'fa' => const Locale('fa', 'IR'),\n          'he' => const Locale('he', 'IL'),\n",
    )
    replace_once(
        MAIN,
        "          Locale('fa', 'IR'),\n",
        "          Locale('fa', 'IR'),\n          Locale('he', 'IL'),\n",
    )


def integrate_catalog_model() -> None:
    replace_count(
        CATALOG_MODEL,
        "    required this.nameFa,\n",
        "    required this.nameFa,\n    required this.nameHe,\n",
        3,
    )
    replace_count(
        CATALOG_MODEL,
        "  final String nameFa;\n",
        "  final String nameFa;\n  final String nameHe;\n",
        3,
    )
    replace_count(
        CATALOG_MODEL,
        "    nameFa: json['nameFa']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameFa: json['nameFa']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameHe: json['nameHe']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_count(
        CATALOG_MODEL,
        "    'fa' => nameFa,\n",
        "    'fa' => nameFa,\n    'he' => nameHe,\n",
        3,
    )
    replace_once(
        CATALOG_MODEL,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa $nameHe'",
    )
    replace_once(
        CATALOG_MODEL,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa $nameHe $nativeName'",
    )
    replace_once(
        CATALOG_MODEL,
        "      nameFa,\n      ...symbols,",
        "      nameFa,\n      nameHe,\n      ...symbols,",
    )


def integrate_formatters() -> None:
    replace_once(
        FORMATTERS,
        "  final groupSeparator = MizanI18n.isEnglish\n      ? ','",
        "  final groupSeparator = MizanI18n.isEnglish || MizanI18n.isHebrew\n      ? ','",
    )
    replace_once(
        FORMATTERS,
        "  final decimalSeparator = MizanI18n.isEnglish\n      ? '.'",
        "  final decimalSeparator = MizanI18n.isEnglish || MizanI18n.isHebrew\n      ? '.'",
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isPersian) {
    if (code == 'IRR') return '$amount\\u00A0ریال';
    return '$amount\\u00A0${_ltrIsolate(code)}';
  }
""",
        """  if (MizanI18n.isPersian) {
    if (code == 'IRR') return '$amount\\u00A0ریال';
    return '$amount\\u00A0${_ltrIsolate(code)}';
  }
  if (MizanI18n.isHebrew) {
    final symbol = code == 'ILS' ? '₪' : code;
    return _ltrIsolate('$amount\\u00A0$symbol');
  }
""",
    )
    replace_once(
        FORMATTERS,
        "  if (MizanI18n.isEnglish) return '$rawInteger.$decimalPart';",
        "  if (MizanI18n.isEnglish || MizanI18n.isHebrew) {\n    return '$rawInteger.$decimalPart';\n  }",
    )
    replace_once(
        FORMATTERS,
        "      .replaceAll('tl', '')\n",
        "      .replaceAll('tl', '')\n      .replaceAll('₪', '')\n      .replaceAll('ils', '')\n",
    )
    he_months = """  const heMonths = [
    'ינואר',
    'פברואר',
    'מרץ',
    'אפריל',
    'מאי',
    'יוני',
    'יולי',
    'אוגוסט',
    'ספטמבר',
    'אוקטובר',
    'נובמבר',
    'דצמבר',
  ];
"""
    fa_months = """  const faMonths = [
    'ژانویه',
    'فوریه',
    'مارس',
    'آوریل',
    'مه',
    'ژوئن',
    'ژوئیه',
    'اوت',
    'سپتامبر',
    'اکتبر',
    'نوامبر',
    'دسامبر',
  ];
"""
    replace_count(FORMATTERS, fa_months, fa_months + he_months, 2)
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isPersian) {
    return _persianDigits(
      '${value.day} ${faMonths[value.month - 1]} ${value.year}',
    );
  }
""",
        """  if (MizanI18n.isPersian) {
    return _persianDigits(
      '${value.day} ${faMonths[value.month - 1]} ${value.year}',
    );
  }
  if (MizanI18n.isHebrew) {
    return '${value.day} ${heMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isPersian) {
    return _persianDigits('${faMonths[value.month - 1]} ${value.year}');
  }
""",
        """  if (MizanI18n.isPersian) {
    return _persianDigits('${faMonths[value.month - 1]} ${value.year}');
  }
  if (MizanI18n.isHebrew) {
    return '${heMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        FORMATTERS,
        "return MizanI18n.isArabic || MizanI18n.isPersian ? _ltrIsolate(value) : value;",
        "return MizanI18n.isArabic || MizanI18n.isPersian || MizanI18n.isHebrew\n      ? _ltrIsolate(value)\n      : value;",
    )


def update_catalogs() -> None:
    languages_data = fetch_json("cldr-localenames-full/main/he/languages.json")
    territories_data = fetch_json("cldr-localenames-full/main/he/territories.json")
    currencies_data = fetch_json("cldr-numbers-full/main/he/currencies.json")
    language_names = languages_data["main"]["he"]["localeDisplayNames"]["languages"]
    territory_names = territories_data["main"]["he"]["localeDisplayNames"]["territories"]
    currency_names = currencies_data["main"]["he"]["numbers"]["currencies"]

    language_payload = load_json(LANGUAGES)
    country_payload = load_json(COUNTRIES)
    currency_payload = load_json(CURRENCIES)

    language_overrides = {
        "pt-BR": language_names.get("pt-BR", "פורטוגזית ברזילאית"),
        "pt-PT": language_names.get("pt-PT", "פורטוגזית אירופית"),
        "zh-CN": language_names.get("zh-Hans", language_names.get("zh")),
        "he": "עברית",
    }
    missing: list[str] = []
    for item in language_payload["items"]:
        code = str(item["code"])
        candidates = (code, code.replace("_", "-"), code.split("-")[0])
        name = language_overrides.get(code)
        if not name:
            name = next(
                (language_names.get(candidate) for candidate in candidates if language_names.get(candidate)),
                None,
            )
        if not name:
            missing.append(f"language:{code}")
        else:
            item["nameHe"] = name

    for item in country_payload["items"]:
        code = str(item["code"])
        name = territory_names.get(code)
        if not name:
            missing.append(f"country:{code}")
        else:
            item["nameHe"] = name

    for item in currency_payload["items"]:
        code = str(item["code"])
        data = currency_names.get(code)
        name = data.get("displayName") if isinstance(data, dict) else None
        if not name:
            missing.append(f"currency:{code}")
        else:
            item["nameHe"] = name

    if missing:
        fail(f"Pinned CLDR Hebrew catalog names are missing: {missing[:30]}")
    save_json(LANGUAGES, language_payload)
    save_json(COUNTRIES, country_payload)
    save_json(CURRENCIES, currency_payload)


def hebrew_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanHebrew\w+)", source)
        if marker is None:
            fail(f"Hebrew map marker missing: {path.relative_to(ROOT)}")
        result.extend(parse_map(source, marker.group(0)))
    return result


def is_arabic_script(char: str) -> bool:
    code = ord(char)
    return any(start <= code <= end for start, end in ARABIC_RANGES)


def verify() -> None:
    pairs = hebrew_pairs()
    source_pairs = english_pairs()
    source_keys = [key for key, _ in source_pairs]
    keys = [key for key, _ in pairs]
    if len(source_keys) != 791:
        fail(f"Stable source key count changed: {len(source_keys)}")
    if len(keys) != 791 or len(set(keys)) != 791:
        fail(f"Hebrew static key count/uniqueness failed: {len(keys)} / {len(set(keys))}")
    missing = sorted(set(source_keys) - set(keys))
    extra = sorted(set(keys) - set(source_keys))
    if missing or extra:
        fail(f"Hebrew key parity failed. Missing={missing[:30]} Extra={extra[:30]}")

    values = [value for _, value in pairs]
    combined = "\n".join(values)
    if any(char in combined for char in BIDI_CONTROLS):
        fail("Literal bidi control character found in Hebrew static copy")
    arabic_leaks = {
        key: value
        for key, value in pairs
        if any(is_arabic_script(char) for char in value)
    }
    if arabic_leaks:
        fail(f"Arabic/Persian/Urdu script leaked into Hebrew system copy: {list(arabic_leaks.items())[:20]}")
    niqqud_leaks = {
        key: value
        for key, value in pairs
        if any(ord(char) in NIQQUD_RANGE for char in value)
    }
    if niqqud_leaks:
        fail(f"Unexpected niqqud leaked into Hebrew product copy: {list(niqqud_leaks.items())[:20]}")
    if sum(1 for char in combined if 0x05D0 <= ord(char) <= 0x05EA) < 2500:
        fail("Hebrew static copy does not contain enough Hebrew product language")
    if any(unicodedata.normalize("NFC", value) != value for value in values):
        fail("Hebrew static copy is not NFC-normalized")

    for path, expected in ((LANGUAGES, 29), (COUNTRIES, 161), (CURRENCIES, 154)):
        payload = load_json(path)
        items = payload.get("items", [])
        if payload.get("count") != expected or len(items) != expected:
            fail(f"Catalog count changed for {path.name}")
        empty = [str(item.get("code")) for item in items if not str(item.get("nameHe", "")).strip()]
        if empty:
            fail(f"Hebrew catalog names missing in {path.name}: {empty[:20]}")

    i18n = (
        I18N.read_text(encoding="utf-8")
        + LEGACY_I18N.read_text(encoding="utf-8")
    )
    main = MAIN.read_text(encoding="utf-8")
    model = CATALOG_MODEL.read_text(encoding="utf-8")
    required = (
        "static bool get isHebrew",
        "mizanHebrew[visibleSource]",
        "translateHebrewReviewedDynamic(",
        "normalized.startsWith('he-')",
        "normalized.startsWith('iw-')",
        "'he' => nameHe",
    )
    missing_runtime = [marker for marker in required if marker not in i18n + model]
    if missing_runtime:
        fail(f"Hebrew runtime integration incomplete: {missing_runtime}")
    if "Locale('he', 'IL')" not in main:
        fail("Hebrew Flutter locale is not active")
    formatter_text = FORMATTERS.read_text(encoding="utf-8")
    for marker in ("MizanI18n.isHebrew", "₪", "heMonths"):
        if marker not in formatter_text:
            fail(f"Hebrew formatter marker missing: {marker}")
    print(
        f"Hebrew runtime verified: {len(keys)}/791 static values, one/two/other dynamic grammar, "
        "RTL/bidi safety, pinned CLDR 48.2 catalogs 29/161/154, ILS and Gregorian date support."
    )


def apply() -> None:
    sanitize_hebrew_sources()
    integrate_i18n()
    integrate_main()
    integrate_catalog_model()
    integrate_formatters()
    update_catalogs()
    verify()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    if args.apply:
        apply()
    else:
        verify()


if __name__ == "__main__":
    main()
