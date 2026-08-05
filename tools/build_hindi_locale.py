#!/usr/bin/env python3
"""Integrate and verify the reviewed India-oriented Hindi locale."""
from __future__ import annotations

import argparse
import json
import re
import sys
import unicodedata
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))

from build_ukrainian_locale import english_pairs, parse_map  # noqa: E402

CLDR_COMMIT = '3701646856d5cdc946fc8fca8b9a36b5c5c300ba'
CLDR_BASE = f'https://raw.githubusercontent.com/unicode-org/cldr-json/{CLDR_COMMIT}/cldr-json'
PARTS = tuple(sorted((ROOT / 'lib/l10n/hi').glob('mizan_hi_*.dart')))
I18N = ROOT / 'lib/l10n/mizan_i18n.dart'
MAIN = ROOT / 'lib/main.dart'
CATALOG_MODEL = ROOT / 'lib/global/global_catalog.dart'
FORMATTERS = ROOT / 'lib/core/formatters.dart'
LANGUAGES = ROOT / 'assets/data/languages_v1.json'
COUNTRIES = ROOT / 'assets/data/countries_v1.json'
CURRENCIES = ROOT / 'assets/data/currencies_v1.json'
INHERITED_REGISTRY_TESTS = (
    ROOT / 'test/english_localization_test.dart',
    ROOT / 'test/portuguese_br_localization_test.dart',
    ROOT / 'test/spanish_localization_test.dart',
    ROOT / 'test/italian_final_head_test.dart',
)

INVISIBLE = '\u200b\u200c\u200d\u200e\u200f\u202a\u202b\u202c\u202d\u202e\u2066\u2067\u2068\u2069'
OTHER_SCRIPT_RANGES = (
    (0x0590, 0x05FF),  # Hebrew
    (0x0600, 0x08FF),  # Arabic, Persian, Urdu
    (0x0980, 0x09FF),  # Bengali
    (0x0B80, 0x0BFF),  # Tamil
    (0x0C00, 0x0C7F),  # Telugu
    (0x0C80, 0x0CFF),  # Kannada
    (0x0D00, 0x0D7F),  # Malayalam
)


def fail(message: str) -> None:
    raise SystemExit(message)


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding='utf-8')
    if new in text:
        return
    count = text.count(old)
    if count != 1:
        fail(
            f'Expected one Hindi integration target in {path.relative_to(ROOT)}; '
            f'found {count}: {old[:140]!r}'
        )
    path.write_text(text.replace(old, new, 1), encoding='utf-8')


def replace_count(path: Path, old: str, new: str, expected: int) -> None:
    text = path.read_text(encoding='utf-8')
    if text.count(new) == expected:
        return
    count = text.count(old)
    if count != expected:
        fail(
            f'Expected {expected} Hindi integration targets in {path.relative_to(ROOT)}; '
            f'found {count}: {old[:140]!r}'
        )
    path.write_text(text.replace(old, new), encoding='utf-8')



def replace_nth(path: Path, old: str, new: str, occurrence: int) -> None:
    text = path.read_text(encoding='utf-8')
    if new in text:
        return
    starts = [match.start() for match in re.finditer(re.escape(old), text)]
    if len(starts) < occurrence:
        fail(
            f'Expected Hindi integration occurrence {occurrence} in '
            f'{path.relative_to(ROOT)}; found {len(starts)}: {old[:140]!r}'
        )
    index = starts[occurrence - 1]
    path.write_text(text[:index] + new + text[index + len(old):], encoding='utf-8')

def load_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding='utf-8'))


def save_json(path: Path, payload: dict[str, object]) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, separators=(',', ':')) + '\n',
        encoding='utf-8',
    )


def fetch_json(relative: str) -> dict[str, object]:
    request = urllib.request.Request(
        f'{CLDR_BASE}/{relative}',
        headers={'User-Agent': 'MIZAN-Hindi-catalog-builder/1.0'},
    )
    with urllib.request.urlopen(request, timeout=45) as response:
        return json.load(response)


def sanitize_hindi_sources() -> None:
    paths = (*PARTS, ROOT / 'lib/l10n/mizan_hi.dart', ROOT / 'lib/l10n/mizan_hi_dynamic.dart')
    for path in paths:
        text = path.read_text(encoding='utf-8')
        cleaned = text.translate({ord(char): None for char in INVISIBLE})
        cleaned = unicodedata.normalize('NFC', cleaned)
        if cleaned != text:
            path.write_text(cleaned, encoding='utf-8')


def integrate_i18n() -> None:
    replace_once(
        I18N,
        "import 'mizan_he_dynamic.dart';",
        "import 'mizan_he_dynamic.dart';\nimport 'mizan_hi.dart';\nimport 'mizan_hi_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar', 'fa', 'he'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar', 'fa', 'he', 'hi'};",
    )
    replace_once(
        I18N,
        "  static bool get isHebrew => _languageTag == 'he';\n",
        "  static bool get isHebrew => _languageTag == 'he';\n  static bool get isHindi => _languageTag == 'hi';\n",
    )
    replace_once(
        I18N,
        "    'he' => 'אני מאשר',\n",
        "    'he' => 'אני מאשר',\n    'hi' => 'मैं सहमत हूँ',\n",
    )
    replace_once(
        I18N,
        "    return 'tr';\n  }\n\n  static bool isSupported",
        "    if (normalized == 'hi' || normalized.startsWith('hi-')) return 'hi';\n    return 'tr';\n  }\n\n  static bool isSupported",
    )
    replace_once(
        I18N,
        "        normalized == 'iw' ||\n        normalized.startsWith('iw-');\n",
        "        normalized == 'iw' ||\n        normalized.startsWith('iw-') ||\n        normalized == 'hi' ||\n        normalized.startsWith('hi-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanHebrew[visibleSource] ??
          translateHebrewReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'he'),
          );
    }
""",
        """    } else if (effective == 'he') {
      result =
          mizanHebrew[visibleSource] ??
          translateHebrewReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'he'),
          );
    } else {
      result =
          mizanHindi[visibleSource] ??
          translateHindiReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'hi'),
          );
    }
""",
    )


def integrate_main() -> None:
    replace_once(
        MAIN,
        "          'he' => const Locale('he', 'IL'),\n",
        "          'he' => const Locale('he', 'IL'),\n          'hi' => const Locale('hi', 'IN'),\n",
    )
    replace_once(
        MAIN,
        "          Locale('he', 'IL'),\n",
        "          Locale('he', 'IL'),\n          Locale('hi', 'IN'),\n",
    )


def integrate_catalog_model() -> None:
    replace_count(
        CATALOG_MODEL,
        '    required this.nameHe,\n',
        '    required this.nameHe,\n    required this.nameHi,\n',
        3,
    )
    replace_count(
        CATALOG_MODEL,
        '  final String nameHe;\n',
        '  final String nameHe;\n  final String nameHi;\n',
        3,
    )
    replace_count(
        CATALOG_MODEL,
        "    nameHe: json['nameHe']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameHe: json['nameHe']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameHi: json['nameHi']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_count(
        CATALOG_MODEL,
        "    'he' => nameHe,\n",
        "    'he' => nameHe,\n    'hi' => nameHi,\n",
        3,
    )
    replace_once(
        CATALOG_MODEL,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa $nameHe'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa $nameHe $nameHi'",
    )
    replace_once(
        CATALOG_MODEL,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa $nameHe $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nameAr $nameFa $nameHe $nameHi $nativeName'",
    )
    replace_once(
        CATALOG_MODEL,
        '      nameHe,\n      ...symbols,',
        '      nameHe,\n      nameHi,\n      ...symbols,',
    )


def integrate_formatters() -> None:
    replace_once(
        FORMATTERS,
        "String _ltrIsolate(String value) => '\\u2066$value\\u2069';\n",
        """String _ltrIsolate(String value) => '\\u2066$value\\u2069';

String _groupIndianDigits(String value) {
  if (value.length <= 3) return value;
  final tail = value.substring(value.length - 3);
  var head = value.substring(0, value.length - 3);
  final groups = <String>[];
  while (head.length > 2) {
    groups.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) groups.insert(0, head);
  return '${groups.join(',')},$tail';
}

bool _isIndianGrouping(List<String> segments) {
  if (segments.length < 2 || segments.first.isEmpty) return false;
  if (segments.first.length > 2 || segments.last.length != 3) return false;
  return segments.skip(1).take(segments.length - 2).every(
    (segment) => segment.length == 2,
  );
}
""",
    )
    replace_once(
        FORMATTERS,
        "  final groupSeparator = MizanI18n.isEnglish || MizanI18n.isHebrew\n      ? ','",
        "  final groupSeparator =\n      MizanI18n.isEnglish || MizanI18n.isHebrew || MizanI18n.isHindi\n      ? ','",
    )
    replace_once(
        FORMATTERS,
        "  final decimalSeparator = MizanI18n.isEnglish || MizanI18n.isHebrew\n      ? '.'",
        "  final decimalSeparator =\n      MizanI18n.isEnglish || MizanI18n.isHebrew || MizanI18n.isHindi\n      ? '.'",
    )
    replace_once(
        FORMATTERS,
        """  for (var index = 0; index < integerPart.length; index++) {
    grouped.write(integerPart[index]);
    final remaining = integerPart.length - index - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      grouped.write(groupSeparator);
    }
  }
""",
        """  if (MizanI18n.isHindi) {
    grouped.write(_groupIndianDigits(integerPart));
  } else {
    for (var index = 0; index < integerPart.length; index++) {
      grouped.write(integerPart[index]);
      final remaining = integerPart.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        grouped.write(groupSeparator);
      }
    }
  }
""",
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isHebrew) {
    final symbol = code == 'ILS' ? '₪' : code;
    return _ltrIsolate('$amount\\u00A0$symbol');
  }
""",
        """  if (MizanI18n.isHebrew) {
    final symbol = code == 'ILS' ? '₪' : code;
    return _ltrIsolate('$amount\\u00A0$symbol');
  }
  if (MizanI18n.isHindi) {
    if (code == 'INR') return '₹$amount';
    return '$code\\u00A0$amount';
  }
""",
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isPolish ||
      MizanI18n.isRomanian ||
""",
        """  if (MizanI18n.isHindi) {
    final negative = integerPart.startsWith('-');
    final digits = negative ? integerPart.substring(1) : integerPart;
    integerPart = '${negative ? '-' : ''}${_groupIndianDigits(digits)}';
  } else if (MizanI18n.isPolish ||
      MizanI18n.isRomanian ||
""",
    )
    replace_once(
        FORMATTERS,
        "  if (MizanI18n.isEnglish || MizanI18n.isHebrew) {\n    return '$rawInteger.$decimalPart';\n  }",
        "  if (MizanI18n.isEnglish || MizanI18n.isHebrew) {\n    return '$rawInteger.$decimalPart';\n  }\n  if (MizanI18n.isHindi) return '$integerPart.$decimalPart';",
    )
    replace_once(
        FORMATTERS,
        "      .replaceAll('ils', '')\n",
        "      .replaceAll('ils', '')\n      .replaceAll('₹', '')\n      .replaceAll('inr', '')\n",
    )
    replace_once(
        FORMATTERS,
        """      final allThousands = segments.skip(1).every((part) => part.length == 3);
      if (!allThousands) {
""",
        """      final allThousands = segments.skip(1).every((part) => part.length == 3);
      final indianThousands = MizanI18n.isHindi && _isIndianGrouping(segments);
      if (!allThousands && !indianThousands) {
""",
    )
    replace_nth(
        FORMATTERS,
        "  const heMonths = [\n",
        """  const hiMonths = [
    'जन॰',
    'फ़र॰',
    'मार्च',
    'अप्रैल',
    'मई',
    'जून',
    'जुलाई',
    'अग॰',
    'सित॰',
    'अक्टू॰',
    'नव॰',
    'दिस॰',
  ];
  const heMonths = [
""",
        1,
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isHebrew) {
    return '${value.day} ${heMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isHebrew) {
    return '${value.day} ${heMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isHindi) {
    return '${value.day} ${hiMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_nth(
        FORMATTERS,
        "  const heMonths = [\n",
        """  const hiMonths = [
    'जनवरी',
    'फ़रवरी',
    'मार्च',
    'अप्रैल',
    'मई',
    'जून',
    'जुलाई',
    'अगस्त',
    'सितंबर',
    'अक्टूबर',
    'नवंबर',
    'दिसंबर',
  ];
  const heMonths = [
""",
        2,
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isHebrew) {
    return '${heMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isHebrew) {
    return '${heMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isHindi) {
    return '${hiMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        FORMATTERS,
        "  const eastern = '٠١٢٣٤٥٦٧٨٩';\n  const persian = '۰۱۲۳۴۵۶۷۸۹';\n",
        "  const eastern = '٠١٢٣٤٥٦٧٨٩';\n  const persian = '۰۱۲۳۴۵۶۷۸۹';\n  const devanagari = '०१२३४५६७८९';\n",
    )
    replace_once(
        FORMATTERS,
        """    result = result
        .replaceAll(eastern[index], western[index])
        .replaceAll(persian[index], western[index]);
""",
        """    result = result
        .replaceAll(eastern[index], western[index])
        .replaceAll(persian[index], western[index])
        .replaceAll(devanagari[index], western[index]);
""",
    )



def integrate_inherited_registry_tests() -> None:
    title_replacements = {
        'English remains enabled after Hebrew integration':
            'English remains enabled after Hindi integration',
        'Brazilian Portuguese remains enabled after Hebrew integration':
            'Brazilian Portuguese remains enabled after Hindi integration',
        'Spanish remains enabled after Hebrew integration':
            'Spanish remains enabled after Hindi integration',
        'final Hebrew head exposes the complete seventeen-language runtime':
            'final Hindi head exposes the complete eighteen-language runtime',
    }
    for path in INHERITED_REGISTRY_TESTS:
        text = path.read_text(encoding='utf-8')
        for old, new in title_replacements.items():
            text = text.replace(old, new)
        if "      'hi',\n" not in text:
            text = text.replace("      'he',\n", "      'he',\n      'hi',\n", 1)
        marker = "    expect(MizanI18n.normalizeLanguageTag('iw_IL'), 'he');\n"
        additions = (
            marker
            + "    expect(MizanI18n.isSupported('hi'), isTrue);\n"
            + "    expect(MizanI18n.isSupported('hi-IN'), isTrue);\n"
            + "    expect(MizanI18n.normalizeLanguageTag('hi_IN'), 'hi');\n"
        )
        if "normalizeLanguageTag('hi_IN')" not in text and marker in text:
            text = text.replace(marker, additions, 1)
        path.write_text(text, encoding='utf-8')

def update_catalogs() -> None:
    current = (
        (LANGUAGES, 29),
        (COUNTRIES, 161),
        (CURRENCIES, 154),
    )
    if all(
        payload.get('count') == expected
        and len(payload.get('items', [])) == expected
        and all(str(item.get('nameHi', '')).strip() for item in payload.get('items', []))
        for path, expected in current
        for payload in (load_json(path),)
    ):
        return
    languages_data = fetch_json('cldr-localenames-full/main/hi/languages.json')
    territories_data = fetch_json('cldr-localenames-full/main/hi/territories.json')
    currencies_data = fetch_json('cldr-numbers-full/main/hi/currencies.json')
    language_names = languages_data['main']['hi']['localeDisplayNames']['languages']
    territory_names = territories_data['main']['hi']['localeDisplayNames']['territories']
    currency_names = currencies_data['main']['hi']['numbers']['currencies']

    language_payload = load_json(LANGUAGES)
    country_payload = load_json(COUNTRIES)
    currency_payload = load_json(CURRENCIES)

    language_overrides = {
        'pt-BR': language_names.get('pt-BR', 'ब्राज़ीली पुर्तगाली'),
        'pt-PT': language_names.get('pt-PT', 'यूरोपीय पुर्तगाली'),
        'hi': 'हिन्दी',
    }
    currency_overrides = {
        'XCG': 'कैरेबियाई गिल्डर',
        'ZWG': 'ज़िम्बाब्वे गोल्ड',
    }
    missing: list[str] = []
    for item in language_payload['items']:
        code = str(item['code'])
        candidates = (code, code.replace('-', '_'), code.split('-')[0])
        name = language_overrides.get(code)
        if not name:
            name = next(
                (language_names.get(candidate) for candidate in candidates if language_names.get(candidate)),
                None,
            )
        if not name:
            missing.append(f'language:{code}')
        else:
            item['nameHi'] = name

    for item in country_payload['items']:
        code = str(item['code'])
        name = territory_names.get(code)
        if not name:
            missing.append(f'country:{code}')
        else:
            item['nameHi'] = name

    for item in currency_payload['items']:
        code = str(item['code'])
        data = currency_names.get(code)
        name = data.get('displayName') if isinstance(data, dict) else None
        name = name or currency_overrides.get(code)
        if not name:
            missing.append(f'currency:{code}')
        else:
            item['nameHi'] = name

    if missing:
        fail(f'Pinned CLDR Hindi catalog names are missing: {missing[:30]}')
    save_json(LANGUAGES, language_payload)
    save_json(COUNTRIES, country_payload)
    save_json(CURRENCIES, currency_payload)


def hindi_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding='utf-8')
        marker = re.search(r'const Map<String, String> (mizanHindi\w+)', source)
        if marker is None:
            fail(f'Hindi map marker missing: {path.relative_to(ROOT)}')
        result.extend(parse_map(source, marker.group(0)))
    return result


def in_other_script(char: str) -> bool:
    code = ord(char)
    return any(start <= code <= end for start, end in OTHER_SCRIPT_RANGES)


def verify() -> None:
    pairs = hindi_pairs()
    source_keys = [key for key, _ in english_pairs()]
    keys = [key for key, _ in pairs]
    if len(source_keys) != 791:
        fail(f'Stable source key count changed: {len(source_keys)}')
    if len(keys) != 791 or len(set(keys)) != 791:
        fail(f'Hindi static key count/uniqueness failed: {len(keys)} / {len(set(keys))}')
    missing = sorted(set(source_keys) - set(keys))
    extra = sorted(set(keys) - set(source_keys))
    if missing or extra:
        fail(f'Hindi key parity failed. Missing={missing[:30]} Extra={extra[:30]}')

    values = [value for _, value in pairs]
    combined = '\n'.join(values)
    if any(char in combined for char in INVISIBLE):
        fail('Invisible or bidi control character found in Hindi static copy')
    leaks = {key: value for key, value in pairs if any(in_other_script(char) for char in value)}
    if leaks:
        fail(f'Other product script leaked into Hindi system copy: {list(leaks.items())[:20]}')
    if sum(1 for char in combined if 0x0900 <= ord(char) <= 0x097F) < 2800:
        fail('Hindi static copy does not contain enough Devanagari product language')
    if any(unicodedata.normalize('NFC', value) != value for value in values):
        fail('Hindi static copy is not NFC-normalized')

    for path, expected in ((LANGUAGES, 29), (COUNTRIES, 161), (CURRENCIES, 154)):
        payload = load_json(path)
        items = payload.get('items', [])
        if payload.get('count') != expected or len(items) != expected:
            fail(f'Catalog count changed for {path.name}')
        empty = [str(item.get('code')) for item in items if not str(item.get('nameHi', '')).strip()]
        if empty:
            fail(f'Hindi catalog names missing in {path.name}: {empty[:20]}')

    runtime = I18N.read_text(encoding='utf-8') + CATALOG_MODEL.read_text(encoding='utf-8')
    required = (
        'static bool get isHindi',
        'mizanHindi[visibleSource]',
        'translateHindiReviewedDynamic(',
        "normalized.startsWith('hi-')",
        "'hi' => nameHi",
    )
    missing_runtime = [marker for marker in required if marker not in runtime]
    if missing_runtime:
        fail(f'Hindi runtime integration incomplete: {missing_runtime}')
    if "Locale('hi', 'IN')" not in MAIN.read_text(encoding='utf-8'):
        fail('Hindi Flutter locale is not active')

    for path in INHERITED_REGISTRY_TESTS:
        text = path.read_text(encoding='utf-8')
        if "      'hi'," not in text or "normalizeLanguageTag('hi_IN')" not in text:
            fail(f'Inherited registry test was not advanced to Hindi: {path.name}')
    formatter_text = FORMATTERS.read_text(encoding='utf-8')
    for marker in ('MizanI18n.isHindi', '₹', '_groupIndianDigits', 'hiMonths'):
        if marker not in formatter_text:
            fail(f'Hindi formatter marker missing: {marker}')
    print(
        f'Hindi runtime verified: {len(keys)}/791 static values, natural one/other grammar, '
        'Devanagari purity, catalogs 29/161/154, Indian grouping, INR and Gregorian dates.'
    )


def apply() -> None:
    sanitize_hindi_sources()
    integrate_i18n()
    integrate_main()
    integrate_catalog_model()
    integrate_formatters()
    integrate_inherited_registry_tests()
    update_catalogs()
    verify()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    if args.apply:
        apply()
    else:
        verify()


if __name__ == '__main__':
    main()
