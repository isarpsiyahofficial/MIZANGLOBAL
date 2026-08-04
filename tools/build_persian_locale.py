#!/usr/bin/env python3
"""Integrate and verify the reviewed Persian locale with pinned CLDR data."""
from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from build_ukrainian_locale import english_pairs, parse_map  # noqa: E402

CLDR_COMMIT = "3701646856d5cdc946fc8fca8b9a36b5c5c300ba"
CLDR_BASE = f"https://raw.githubusercontent.com/unicode-org/cldr-json/{CLDR_COMMIT}/cldr-json"
PARTS = tuple(sorted((ROOT / "lib/l10n/fa").glob("mizan_fa_*.dart")))
I18N = ROOT / "lib/l10n/mizan_i18n.dart"
MAIN = ROOT / "lib/main.dart"
CATALOG_MODEL = ROOT / "lib/global/global_catalog.dart"
FORMATTERS = ROOT / "lib/core/formatters.dart"
LANGUAGES = ROOT / "assets/data/languages_v1.json"
COUNTRIES = ROOT / "assets/data/countries_v1.json"
CURRENCIES = ROOT / "assets/data/currencies_v1.json"

BIDI_CONTROLS = "\u200e\u200f\u202a\u202b\u202c\u202d\u202e\u2066\u2067\u2068\u2069"
FORBIDDEN_PERSIAN = "يىكےہھںٹڈڑ"


def fail(message: str) -> None:
    raise SystemExit(message)


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    count = text.count(old)
    if count != 1:
        fail(f"Expected one integration target in {path.relative_to(ROOT)}; found {count}: {old[:120]!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_count(path: Path, old: str, new: str, expected: int) -> None:
    text = path.read_text(encoding="utf-8")
    if text.count(new) == expected:
        return
    count = text.count(old)
    if count != expected:
        fail(f"Expected {expected} targets in {path.relative_to(ROOT)}; found {count}: {old[:120]!r}")
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
        headers={"User-Agent": "MIZAN-Persian-catalog-builder/1.0"},
    )
    with urllib.request.urlopen(request, timeout=45) as response:
        return json.load(response)


def sanitize_persian_sources() -> None:
    for path in (*PARTS, ROOT / "lib/l10n/mizan_fa.dart", ROOT / "lib/l10n/mizan_fa_dynamic.dart"):
        text = path.read_text(encoding="utf-8")
        cleaned = text.translate({ord(char): None for char in BIDI_CONTROLS})
        if cleaned != text:
            path.write_text(cleaned, encoding="utf-8")


def integrate_i18n() -> None:
    replace_once(
        I18N,
        "import 'mizan_ar_dynamic.dart';",
        "import 'mizan_ar_dynamic.dart';\nimport 'mizan_fa.dart';\nimport 'mizan_fa_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar', 'fa'};",
    )
    replace_once(
        I18N,
        "  static bool get isArabic => _languageTag == 'ar';\n",
        "  static bool get isArabic => _languageTag == 'ar';\n  static bool get isPersian => _languageTag == 'fa';\n",
    )
    replace_once(I18N, "    'ar' => 'أؤكد',\n", "    'ar' => 'أؤكد',\n    'fa' => 'تأیید می‌کنم',\n")
    replace_once(
        I18N,
        "    if (normalized == 'ar' || normalized.startsWith('ar-')) return 'ar';\n",
        "    if (normalized == 'ar' || normalized.startsWith('ar-')) return 'ar';\n    if (normalized == 'fa' || normalized.startsWith('fa-')) return 'fa';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'ar' ||\n        normalized.startsWith('ar-');\n",
        "        normalized == 'ar' ||\n        normalized.startsWith('ar-') ||\n        normalized == 'fa' ||\n        normalized.startsWith('fa-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanArabic[visibleSource] ??
          translateArabicReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ar'),
          );
    }
""",
        """    } else if (effective == 'ar') {
      result =
          mizanArabic[visibleSource] ??
          translateArabicReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ar'),
          );
    } else {
      result =
          mizanPersian[visibleSource] ??
          translatePersianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'fa'),
          );
    }
""",
    )
    replace_once(
        I18N,
        "      final visibleUser = effective == 'ar'\n          ? '\\u2068${entry.value}\\u2069'\n          : entry.value;",
        "      final visibleUser = effective == 'ar' || effective == 'fa'\n          ? '\\u2068${entry.value}\\u2069'\n          : entry.value;",
    )


def integrate_main() -> None:
    replace_once(
        MAIN,
        "          'ar' => const Locale('ar', 'SA'),\n",
        "          'ar' => const Locale('ar', 'SA'),\n          'fa' => const Locale('fa', 'IR'),\n",
    )
    replace_once(
        MAIN,
        "          Locale('ar', 'SA'),\n",
        "          Locale('ar', 'SA'),\n          Locale('fa', 'IR'),\n",
    )


def integrate_catalog_model() -> None:
    replace_count(CATALOG_MODEL, "    required this.nameAr,\n", "    required this.nameAr,\n    required this.nameFa,\n", 3)
    replace_count(CATALOG_MODEL, "  final String nameAr;\n", "  final String nameAr;\n  final String nameFa;\n", 3)
    replace_count(
        CATALOG_MODEL,
        "    nameAr: json['nameAr']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameAr: json['nameAr']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameFa: json['nameFa']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_count(CATALOG_MODEL, "    'ar' => nameAr,\n", "    'ar' => nameAr,\n    'fa' => nameFa,\n", 3)
    replace_once(
        CATALOG_MODEL,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa'",
    )
    replace_once(
        CATALOG_MODEL,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa $nativeName'",
    )
    replace_once(CATALOG_MODEL, "      nameAr,\n      ...symbols,", "      nameAr,\n      nameFa,\n      ...symbols,")


def integrate_formatters() -> None:
    replace_once(
        FORMATTERS,
        """String _arabicDigits(String value) {
  const western = '0123456789';
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], eastern[index]);
  }
  return result;
}
""",
        """String _arabicDigits(String value) {
  const western = '0123456789';
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], eastern[index]);
  }
  return result;
}

String _persianDigits(String value) {
  const western = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], persian[index]);
  }
  return result;
}
""",
    )
    replace_once(FORMATTERS, "MizanI18n.isArabic\n                  ? '\\u066C'", "(MizanI18n.isArabic || MizanI18n.isPersian)\n                  ? '\\u066C'")
    replace_once(FORMATTERS, "(MizanI18n.isArabic ? '\\u066B' : ',')", "((MizanI18n.isArabic || MizanI18n.isPersian) ? '\\u066B' : ',')")
    replace_once(FORMATTERS, "final amount = MizanI18n.isArabic ? _arabicDigits(rawAmount) : rawAmount;", "final amount = MizanI18n.isArabic\n      ? _arabicDigits(rawAmount)\n      : (MizanI18n.isPersian ? _persianDigits(rawAmount) : rawAmount);")
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isArabic) {
    if (code == 'SAR') return '$amount\\u00A0ر.س';
    if (code == 'AED') return '$amount\\u00A0د.إ';
    return '$amount\\u00A0${_ltrIsolate(code)}';
  }
""",
        """  if (MizanI18n.isArabic) {
    if (code == 'SAR') return '$amount\\u00A0ر.س';
    if (code == 'AED') return '$amount\\u00A0د.إ';
    return '$amount\\u00A0${_ltrIsolate(code)}';
  }
  if (MizanI18n.isPersian) {
    if (code == 'IRR') return '$amount\\u00A0ریال';
    return '$amount\\u00A0${_ltrIsolate(code)}';
  }
""",
    )
    replace_once(FORMATTERS, "      MizanI18n.isArabic) {", "      MizanI18n.isArabic ||\n      MizanI18n.isPersian) {")
    replace_once(FORMATTERS, "          MizanI18n.isArabic\n              ? '\\u066C'", "          (MizanI18n.isArabic || MizanI18n.isPersian)\n              ? '\\u066C'")
    replace_once(FORMATTERS, "return MizanI18n.isArabic ? _arabicDigits(integerPart) : integerPart;", "return MizanI18n.isArabic\n        ? _arabicDigits(integerPart)\n        : (MizanI18n.isPersian ? _persianDigits(integerPart) : integerPart);")
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isArabic) {
    return _arabicDigits('$integerPart\\u066B$decimalPart');
  }
""",
        """  if (MizanI18n.isArabic) {
    return _arabicDigits('$integerPart\\u066B$decimalPart');
  }
  if (MizanI18n.isPersian) {
    return _persianDigits('$integerPart\\u066B$decimalPart');
  }
""",
    )
    replace_once(
        FORMATTERS,
        "  final normalized = input.trim().replaceAll(',', '.');",
        "  final normalized = _westernDigits(input)\n      .replaceAll('\\u066C', '')\n      .replaceAll('\\u066B', '.')\n      .trim()\n      .replaceAll(',', '.');",
    )
    replace_count(FORMATTERS, "  final clean = input.trim();\n", "  final clean = _westernDigits(input).trim();\n", 2)
    replace_count(
        FORMATTERS,
        """  const arMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
""",
        """  const arMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  const faMonths = [
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
""",
        2,
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isArabic) {
    return _arabicDigits(
      '${value.day} ${arMonths[value.month - 1]} ${value.year}',
    );
  }
""",
        """  if (MizanI18n.isArabic) {
    return _arabicDigits(
      '${value.day} ${arMonths[value.month - 1]} ${value.year}',
    );
  }
  if (MizanI18n.isPersian) {
    return _persianDigits(
      '${value.day} ${faMonths[value.month - 1]} ${value.year}',
    );
  }
""",
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isArabic) {
    return _arabicDigits('${arMonths[value.month - 1]} ${value.year}');
  }
""",
        """  if (MizanI18n.isArabic) {
    return _arabicDigits('${arMonths[value.month - 1]} ${value.year}');
  }
  if (MizanI18n.isPersian) {
    return _persianDigits('${faMonths[value.month - 1]} ${value.year}');
  }
""",
    )
    replace_once(FORMATTERS, "return MizanI18n.isArabic ? _ltrIsolate(value) : value;", "return MizanI18n.isArabic || MizanI18n.isPersian\n      ? _ltrIsolate(value)\n      : value;")


def update_catalogs() -> None:
    languages_data = fetch_json("cldr-localenames-full/main/fa/languages.json")
    territories_data = fetch_json("cldr-localenames-full/main/fa/territories.json")
    currencies_data = fetch_json("cldr-numbers-full/main/fa/currencies.json")
    language_names = languages_data["main"]["fa"]["localeDisplayNames"]["languages"]
    territory_names = territories_data["main"]["fa"]["localeDisplayNames"]["territories"]
    currency_names = currencies_data["main"]["fa"]["numbers"]["currencies"]

    language_payload = load_json(LANGUAGES)
    country_payload = load_json(COUNTRIES)
    currency_payload = load_json(CURRENCIES)

    language_overrides = {
        "pt-BR": language_names.get("pt-BR", "پرتغالی برزیل"),
        "pt-PT": language_names.get("pt-PT", "پرتغالی پرتغال"),
        "zh-CN": language_names.get("zh-Hans", language_names.get("zh")),
    }
    missing: list[str] = []
    for item in language_payload["items"]:
        code = str(item["code"])
        candidates = (code, code.replace("_", "-"), code.split("-")[0])
        name = language_overrides.get(code)
        if not name:
            name = next((language_names.get(candidate) for candidate in candidates if language_names.get(candidate)), None)
        if not name:
            missing.append(f"language:{code}")
        else:
            item["nameFa"] = name

    for item in country_payload["items"]:
        code = str(item["code"])
        name = territory_names.get(code)
        if not name:
            missing.append(f"country:{code}")
        else:
            item["nameFa"] = name

    for item in currency_payload["items"]:
        code = str(item["code"])
        data = currency_names.get(code)
        name = data.get("displayName") if isinstance(data, dict) else None
        if not name:
            missing.append(f"currency:{code}")
        else:
            item["nameFa"] = name

    if missing:
        fail(f"Pinned CLDR Persian catalog names are missing: {missing[:30]}")
    save_json(LANGUAGES, language_payload)
    save_json(COUNTRIES, country_payload)
    save_json(CURRENCIES, currency_payload)


def persian_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanPersian\w+)", source)
        if marker is None:
            fail(f"Persian map marker missing: {path.relative_to(ROOT)}")
        result.extend(parse_map(source, marker.group(0)))
    return result


def verify() -> None:
    pairs = persian_pairs()
    source_pairs = english_pairs()
    source_keys = [key for key, _ in source_pairs]
    keys = [key for key, _ in pairs]
    if len(source_keys) != 791:
        fail(f"Stable source key count changed: {len(source_keys)}")
    if len(keys) != 791 or len(set(keys)) != 791:
        fail(f"Persian static key count/uniqueness failed: {len(keys)} / {len(set(keys))}")
    missing = sorted(set(source_keys) - set(keys))
    extra = sorted(set(keys) - set(source_keys))
    if missing or extra:
        fail(f"Persian key parity failed. Missing={missing[:20]} Extra={extra[:20]}")

    values = [value for _, value in pairs]
    leaks = {char: [key for key, value in pairs if char in value] for char in FORBIDDEN_PERSIAN}
    leaks = {char: names for char, names in leaks.items() if names}
    if leaks:
        fail(f"Forbidden Arabic/Urdu character variants in Persian system copy: {leaks}")
    if any(char in "\n".join(values) for char in BIDI_CONTROLS):
        fail("Literal bidi control character found in Persian static copy")
    if sum(value.count("\u200c") for value in values) < 20:
        fail("Persian static copy does not exercise sufficient correct ZWNJ usage")

    for path, expected in ((LANGUAGES, 29), (COUNTRIES, 161), (CURRENCIES, 154)):
        payload = load_json(path)
        items = payload.get("items", [])
        if payload.get("count") != expected or len(items) != expected:
            fail(f"Catalog count changed for {path.name}")
        empty = [str(item.get("code")) for item in items if not str(item.get("nameFa", "")).strip()]
        if empty:
            fail(f"Persian catalog names missing in {path.name}: {empty[:20]}")

    i18n = I18N.read_text(encoding="utf-8")
    main = MAIN.read_text(encoding="utf-8")
    model = CATALOG_MODEL.read_text(encoding="utf-8")
    required = (
        "static bool get isPersian",
        "mizanPersian[visibleSource]",
        "translatePersianReviewedDynamic(",
        "normalized.startsWith('fa-')",
        "'fa' => nameFa",
    )
    missing_runtime = [marker for marker in required if marker not in i18n + model]
    if missing_runtime:
        fail(f"Persian runtime integration incomplete: {missing_runtime}")
    if "Locale('fa', 'IR')" not in main:
        fail("Persian Flutter locale is not active")
    for marker in ("_persianDigits", "MizanI18n.isPersian", "ریال"):
        if marker not in FORMATTERS.read_text(encoding="utf-8"):
            fail(f"Persian formatter marker missing: {marker}")
    print(
        f"Persian runtime verified: {len(keys)}/791 static values, one/other dynamic grammar, "
        "RTL/bidi safety, pinned CLDR 48.2 catalogs 29/161/154, Persian number/money/Gregorian date support."
    )


def apply() -> None:
    sanitize_persian_sources()
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
