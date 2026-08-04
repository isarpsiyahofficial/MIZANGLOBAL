#!/usr/bin/env python3
"""Build, integrate and verify the reviewed Modern Standard Arabic locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

from build_ukrainian_locale import (
    english_pairs,
    load_json,
    parse_map,
    replace_all,
    replace_once,
    save_json,
)

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
ARABIC = LIB / "l10n" / "mizan_ar.dart"
ARABIC_DYNAMIC = LIB / "l10n" / "mizan_ar_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "ar").glob("mizan_ar_*.dart")))


def arabic_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanArabic\w+)", source)
        if marker is None:
            raise SystemExit(f"Arabic map marker missing: {path.relative_to(ROOT)}")
        result.extend(parse_map(source, marker.group(0)))
    return result


def integrate_runtime() -> None:
    replace_once(
        I18N,
        "import 'mizan_uk_dynamic.dart';",
        "import 'mizan_uk_dynamic.dart';\nimport 'mizan_ar.dart';\nimport 'mizan_ar_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar'};",
    )
    replace_once(
        I18N,
        "  static bool get isUkrainian => _languageTag == 'uk';\n",
        "  static bool get isUkrainian => _languageTag == 'uk';\n  static bool get isArabic => _languageTag == 'ar';\n",
    )
    replace_once(
        I18N,
        "    'uk' => 'ПІДТВЕРДЖУЮ',\n",
        "    'uk' => 'ПІДТВЕРДЖУЮ',\n    'ar' => 'أؤكد',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'uk' || normalized.startsWith('uk-')) return 'uk';\n",
        "    if (normalized == 'uk' || normalized.startsWith('uk-')) return 'uk';\n    if (normalized == 'ar' || normalized.startsWith('ar-')) return 'ar';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'uk' ||\n        normalized.startsWith('uk-');\n",
        "        normalized == 'uk' ||\n        normalized.startsWith('uk-') ||\n        normalized == 'ar' ||\n        normalized.startsWith('ar-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanUkrainian[visibleSource] ??
          translateUkrainianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'uk'),
          );
    }
""",
        """    } else if (effective == 'uk') {
      result =
          mizanUkrainian[visibleSource] ??
          translateUkrainianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'uk'),
          );
    } else {
      result =
          mizanArabic[visibleSource] ??
          translateArabicReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ar'),
          );
    }
""",
    )
    replace_once(
        I18N,
        """    for (final entry in protected.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
""",
        """    for (final entry in protected.entries) {
      final visibleUser = effective == 'ar'
          ? '\\u2068${entry.value}\\u2069'
          : entry.value;
      result = result.replaceAll(entry.key, visibleUser);
    }
""",
    )

    main = LIB / "main.dart"
    replace_once(
        main,
        "          'uk' => const Locale('uk', 'UA'),\n",
        "          'uk' => const Locale('uk', 'UA'),\n          'ar' => const Locale('ar', 'SA'),\n",
    )
    replace_once(
        main,
        "          Locale('uk', 'UA'),\n",
        "          Locale('uk', 'UA'),\n          Locale('ar', 'SA'),\n",
    )


def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(path, "    required this.nameUk,\n", "    required this.nameUk,\n    required this.nameAr,\n", 3)
    replace_all(path, "  final String nameUk;\n", "  final String nameUk;\n  final String nameAr;\n", 3)
    replace_all(
        path,
        "    nameUk: json['nameUk']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameUk: json['nameUk']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameAr: json['nameAr']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(path, "    'uk' => nameUk,\n", "    'uk' => nameUk,\n    'ar' => nameAr,\n", 3)
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nativeName'",
    )
    replace_once(path, "      nameUk,\n      ...symbols,", "      nameUk,\n      nameAr,\n      ...symbols,")


def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        "import '../models/mizan_models.dart';\n",
        """import '../models/mizan_models.dart';

String _arabicDigits(String value) {
  const western = '0123456789';
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], eastern[index]);
  }
  return result;
}

String _westernDigits(String value) {
  const western = '0123456789';
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result
        .replaceAll(eastern[index], western[index])
        .replaceAll(persian[index], western[index]);
  }
  return result;
}

String _ltrIsolate(String value) => '\\u2066$value\\u2069';
""",
    )
    replace_once(
        path,
        """            : ((MizanI18n.isRussian || MizanI18n.isUkrainian)
                  ? '\\u00A0'
                  : (MizanI18n.isPortuguesePt ? ' ' : '.')));""",
        """            : (MizanI18n.isArabic
                  ? '\\u066C'
                  : ((MizanI18n.isRussian || MizanI18n.isUkrainian)
                        ? '\\u00A0'
                        : (MizanI18n.isPortuguesePt ? ' ' : '.'))));""",
    )
    replace_once(
        path,
        "  final decimalSeparator = MizanI18n.isEnglish ? '.' : ',';\n",
        "  final decimalSeparator = MizanI18n.isEnglish\n      ? '.'\n      : (MizanI18n.isArabic ? '\\u066B' : ',');\n",
    )
    replace_once(
        path,
        """  final amount =
      '${negative ? '-' : ''}${grouped.toString()}$decimalSeparator$decimalPart';
""",
        """  final rawAmount =
      '${negative ? '-' : ''}${grouped.toString()}$decimalSeparator$decimalPart';
  final amount = MizanI18n.isArabic ? _arabicDigits(rawAmount) : rawAmount;
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isUkrainian) {
    if (code == 'UAH') return '$amount\\u00A0₴';
    return '$amount\\u00A0$code';
  }
""",
        """  if (MizanI18n.isUkrainian) {
    if (code == 'UAH') return '$amount\\u00A0₴';
    return '$amount\\u00A0$code';
  }
  if (MizanI18n.isArabic) {
    if (code == 'SAR') return '$amount\\u00A0ر.س';
    if (code == 'AED') return '$amount\\u00A0د.إ';
    return '$amount\\u00A0${_ltrIsolate(code)}';
  }
""",
    )
    replace_once(
        path,
        "      MizanI18n.isUkrainian) {\n",
        "      MizanI18n.isUkrainian ||\n      MizanI18n.isArabic) {\n",
    )
    replace_once(
        path,
        """          (MizanI18n.isRomanian || MizanI18n.isGreek)
              ? '.'
              : (MizanI18n.isPolish ? '\\u202F' : '\\u00A0'),""",
        """          MizanI18n.isArabic
              ? '\\u066C'
              : ((MizanI18n.isRomanian || MizanI18n.isGreek)
                    ? '.'
                    : (MizanI18n.isPolish ? '\\u202F' : '\\u00A0')),""",
    )
    replace_once(
        path,
        "  if (!hasDecimals) return integerPart;\n",
        "  if (!hasDecimals) {\n    return MizanI18n.isArabic ? _arabicDigits(integerPart) : integerPart;\n  }\n",
    )
    replace_once(
        path,
        "  if (MizanI18n.isEnglish) return '$rawInteger.$decimalPart';\n  return '$integerPart,$decimalPart';\n",
        """  if (MizanI18n.isEnglish) return '$rawInteger.$decimalPart';
  if (MizanI18n.isArabic) {
    return _arabicDigits('$integerPart\\u066B$decimalPart');
  }
  return '$integerPart,$decimalPart';
""",
    )
    replace_once(
        path,
        """  var clean = input
      .trim()
      .toLowerCase()
""",
        """  var clean = _westernDigits(input)
      .replaceAll('\\u066C', ',')
      .replaceAll('\\u066B', '.')
      .trim()
      .toLowerCase()
""",
    )

    replace_once(
        path,
        """  const ukMonths = [
    'січ.',
    'лют.',
    'бер.',
    'квіт.',
    'трав.',
    'черв.',
    'лип.',
    'серп.',
    'вер.',
    'жовт.',
    'лист.',
    'груд.',
  ];
""",
        """  const ukMonths = [
    'січ.',
    'лют.',
    'бер.',
    'квіт.',
    'трав.',
    'черв.',
    'лип.',
    'серп.',
    'вер.',
    'жовт.',
    'лист.',
    'груд.',
  ];
  const arMonths = [
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
    )
    replace_once(
        path,
        """  if (MizanI18n.isUkrainian) {
    return '${value.day} ${ukMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isUkrainian) {
    return '${value.day} ${ukMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isArabic) {
    return _arabicDigits('${value.day} ${arMonths[value.month - 1]} ${value.year}');
  }
""",
    )
    replace_once(
        path,
        """  const ukMonths = [
    'січень',
    'лютий',
    'березень',
    'квітень',
    'травень',
    'червень',
    'липень',
    'серпень',
    'вересень',
    'жовтень',
    'листопад',
    'грудень',
  ];
""",
        """  const ukMonths = [
    'січень',
    'лютий',
    'березень',
    'квітень',
    'травень',
    'червень',
    'липень',
    'серпень',
    'вересень',
    'жовтень',
    'листопад',
    'грудень',
  ];
  const arMonths = [
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
    )
    replace_once(
        path,
        """  if (MizanI18n.isUkrainian) {
    return '${ukMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isUkrainian) {
    return '${ukMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isArabic) {
    return _arabicDigits('${arMonths[value.month - 1]} ${value.year}');
  }
""",
    )
    replace_once(
        path,
        "String timeLabel(int hour, int minute) =>\n    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';\n",
        """String timeLabel(int hour, int minute) {
  final value =
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  return MizanI18n.isArabic ? _ltrIsolate(value) : value;
}
""",
    )


def normal(value: str) -> str:
    text = unicodedata.normalize("NFKD", value.casefold())
    return "".join(char for char in text if not unicodedata.combining(char))


def build_catalogs() -> None:
    from babel import Locale

    locale = Locale.parse("ar_SA")
    language_overrides = {
        "pt-BR": "البرتغالية (البرازيل)",
        "pt-PT": "البرتغالية (البرتغال)",
        "fil": "الفلبينية",
        "ar": "العربية",
        "fa": "الفارسية",
        "he": "العبرية",
    }
    country_overrides = {
        "CD": "جمهورية الكونغو الديمقراطية",
        "CG": "جمهورية الكونغو",
        "CI": "ساحل العاج",
        "CV": "الرأس الأخضر",
        "CZ": "التشيك",
        "KR": "كوريا الجنوبية",
        "KP": "كوريا الشمالية",
        "PS": "فلسطين",
        "ST": "ساو تومي وبرينسيب",
        "TL": "تيمور الشرقية",
        "TR": "تركيا",
        "UA": "أوكرانيا",
        "VA": "الفاتيكان",
    }
    currency_overrides = {
        "AED": "الدرهم الإماراتي",
        "BRL": "الريال البرازيلي",
        "EUR": "اليورو",
        "GBP": "الجنيه الإسترليني",
        "RON": "الليو الروماني",
        "RUB": "الروبل الروسي",
        "SAR": "الريال السعودي",
        "TRY": "الليرة التركية",
        "UAH": "الهريفنيا الأوكرانية",
        "USD": "الدولار الأمريكي",
        "CVE": "إسكودو الرأس الأخضر",
        "MZN": "الميتيكال الموزمبيقي",
        "STN": "دوبرا ساو تومي وبرينسيب",
        "XAF": "فرنك وسط أفريقيا",
        "XCD": "دولار شرق الكاريبي",
        "XCG": "غيلدر الكاريبي",
        "XOF": "فرنك غرب أفريقيا",
        "XPF": "فرنك المحيط الهادئ",
        "ZWG": "ذهب زيمبابوي",
    }
    languages_path = ROOT / "assets/data/languages_v1.json"
    languages = load_json(languages_path)
    for item in languages["items"]:
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing Arabic language name for {code}")
        item["nameAr"] = name
    save_json(languages_path, languages)

    countries_path = ROOT / "assets/data/countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Arabic country name for {code}")
        item["nameAr"] = name
    save_json(countries_path, countries)

    currencies_path = ROOT / "assets/data/currencies_v1.json"
    currencies = load_json(currencies_path)
    common_aliases = {
        "USD": ("دولار", "دولار أمريكي", "الدولار الأمريكي", "dollar", "dolar"),
        "EUR": ("يورو", "اليورو", "euro"),
        "GBP": ("جنيه إسترليني", "الجنيه الإسترليني", "pound"),
        "SAR": ("ريال", "ريال سعودي", "الريال السعودي", "riyal"),
        "AED": ("درهم", "درهم إماراتي", "الدرهم الإماراتي", "dirham"),
        "RON": ("ليو", "الليو الروماني", "leu"),
        "TRY": ("ليرة تركية", "الليرة التركية", "lira"),
        "CHF": ("فرنك سويسري", "الفرنك السويسري", "franc"),
        "PLN": ("زلوتي بولندي", "الزلوتي البولندي", "zloty"),
        "JPY": ("ين ياباني", "الين الياباني", "yen"),
        "CNY": ("يوان صيني", "اليوان الصيني", "yuan"),
        "RUB": ("روبل", "روبل روسي", "الروبل الروسي", "ruble", "rouble"),
        "UAH": ("هريفنيا", "هريفنيا أوكرانية", "الهريفنيا الأوكرانية", "hryvnia"),
    }
    for item in currencies["items"]:
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Arabic currency name for {code}")
        item["nameAr"] = name
        aliases = item.setdefault("aliases", [])
        for alias in (name, name.casefold(), normal(name), *common_aliases.get(code, ())):
            if alias and alias not in aliases:
                aliases.append(alias)
    save_json(currencies_path, currencies)


def update_regressions() -> None:
    old_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'}"
    new_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar'}"
    old_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'}"
    new_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar'}"
    old_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'};"
    new_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar'};"
    for root in (ROOT / "test", ROOT / "tools"):
        for path in root.rglob("*"):
            if path.suffix not in {".dart", ".py"} or path == Path(__file__):
                continue
            text = path.read_text(encoding="utf-8")
            changed = text.replace(old_plain, new_plain).replace(old_typed, new_typed).replace(old_runtime, new_runtime)
            changed = changed.replace("      'uk',\n    });", "      'uk',\n      'ar',\n    });")
            if changed != text:
                path.write_text(changed, encoding="utf-8")


def verify() -> None:
    english = english_pairs()
    arabic = arabic_pairs()
    english_keys = [key for key, _ in english]
    arabic_keys = [key for key, _ in arabic]
    failures: list[str] = []
    if len(english) != 791:
        failures.append(f"English reference map changed: {len(english)} keys")
    if len(arabic) != 791:
        failures.append(f"Arabic map must contain 791 values, found {len(arabic)}")
    duplicates = sorted({key for key in arabic_keys if arabic_keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate Arabic keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(arabic_keys))
    extra = sorted(set(arabic_keys) - set(english_keys))
    if missing or extra:
        failures.append(f"Arabic/English key mismatch; missing={missing[:30]}, extra={extra[:30]}")
    values = dict(arabic)
    required_terms = {
        "Ana sayfa": "الصفحة الرئيسية",
        "Kayıtlar": "السجلات",
        "Giderler": "المصروفات",
        "Raporlar": "التقارير",
        "Ayarlar": "الإعدادات",
        "Kredi kartı": "بطاقة ائتمان",
        "Ev kredisi": "قرض سكني",
        "Çek": "شيك مصرفي",
        "Senet": "سند لأمر",
        "Son ödeme tarihi": "تاريخ الاستحقاق",
        "Gecikmede": "متأخر",
        "Fatura": "فاتورة",
        "Gelir": "دخل",
        "Gider": "مصروف",
        "Ödeme": "دفعة",
        "ONAYLIYORUM": "أؤكد",
    }
    for key, expected in required_terms.items():
        if values.get(key) != expected:
            failures.append(f"Native Arabic terminology mismatch for {key!r}: {values.get(key)!r}")
    forbidden_scripts = re.compile(r"[\u0590-\u05FF]|[پچژگکھیےٹڈڑںھۂۃۀ]")
    leaked = [(key, value) for key, value in arabic if forbidden_scripts.search(value)]
    if leaked:
        failures.append(f"Hebrew/Persian/Urdu script leaked into Arabic: {leaked[:10]}")
    for banned in ("ayarlar", "kayıtlar", "giderler", "настройки", "платежи", "settings"):
        hits = [(key, value) for key, value in arabic if banned in value.casefold()]
        if hits:
            failures.append(f"Other-language terminology leaked ({banned}): {hits[:5]}")
    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'ar'",
        "static bool get isArabic",
        "mizanArabic[visibleSource]",
        "translateArabicReviewedDynamic(",
        "'ar' => 'أؤكد'",
        "normalized.startsWith('ar-')",
        "final visibleUser = effective == 'ar'",
        "result.replaceAll(entry.key, visibleUser)",
    ):
        if marker not in i18n:
            failures.append(f"Missing Arabic runtime marker: {marker}")
    main = (LIB / "main.dart").read_text(encoding="utf-8")
    for marker in ("'ar' => const Locale('ar', 'SA')", "Locale('ar', 'SA')"):
        if marker not in main:
            failures.append(f"Missing Arabic Flutter locale marker: {marker}")
    dynamic = ARABIC_DYNAMIC.read_text(encoding="utf-8")
    for marker in (
        "enum _ArabicPlural { zero, one, two, few, many, other }",
        "two: 'دفعتان'",
        "two: 'يومان'",
        "few: 'أيام'",
        "many: 'يوما'",
    ):
        if marker not in dynamic:
            failures.append(f"Missing Arabic dynamic grammar marker: {marker}")
    formatter = (LIB / "core/formatters.dart").read_text(encoding="utf-8")
    for marker in (
        "MizanI18n.isArabic",
        "_arabicDigits",
        "_westernDigits",
        "'\\u066C'",
        "'\\u066B'",
        "'$amount\\u00A0ر.س'",
        "_ltrIsolate(code)",
        "'أغسطس'",
    ):
        if marker not in formatter:
            failures.append(f"Missing Arabic formatting marker: {marker}")
    catalog_model = (LIB / "global/global_catalog.dart").read_text(encoding="utf-8")
    if catalog_model.count("nameAr") < 15:
        failures.append("Arabic catalog model fields are incomplete")
    for filename, expected_count in (("languages_v1.json", 29), ("countries_v1.json", 161), ("currencies_v1.json", 154)):
        payload = load_json(ROOT / "assets/data" / filename)
        items = payload.get("items", [])
        if len(items) != expected_count:
            failures.append(f"{filename} item count changed: {len(items)}")
        missing_names = [str(item.get("code")) for item in items if not item.get("nameAr")]
        if missing_names:
            failures.append(f"{filename} missing nameAr: {missing_names[:20]}")
    fallback = values.get(
        "Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.",
        "",
    )
    if "جدولة تقريبية" not in fallback:
        failures.append("Arabic notification copy does not describe the inexact fallback")
    if failures:
        raise SystemExit("\n".join(failures))
    print(f"Arabic locale verified: {len(arabic)} static values, 29 languages, 161 countries, 154 currencies, RTL runtime and six plural categories.")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    if not args.verify:
        integrate_runtime()
        integrate_catalog_model()
        integrate_formatters()
        build_catalogs()
        update_regressions()
    verify()


if __name__ == "__main__":
    main()
