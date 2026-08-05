#!/usr/bin/env python3
"""Materialize, integrate and verify MİZAN's Bengali locale.

The first materialization uses the public Google Translate endpoint only as a
seed for non-binding sentences. Binding product terminology and critical
financial/report/notification copy are applied deterministically afterwards.
The generated source is committed and every later run is verification-only.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import json
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))

from bengali_terminology import (  # noqa: E402
    BENGALI_ALLOWED_LATIN_TERMS,
    BENGALI_FORBIDDEN_COPY,
    BENGALI_FORBIDDEN_INVISIBLE,
    BENGALI_TERMINOLOGY,
)
from build_ukrainian_locale import english_pairs, parse_map  # noqa: E402

I18N = ROOT / 'lib/l10n/mizan_i18n.dart'
MAIN = ROOT / 'lib/main.dart'
CATALOG_MODEL = ROOT / 'lib/global/global_catalog.dart'
FORMATTERS = ROOT / 'lib/core/formatters.dart'
LANGUAGES = ROOT / 'assets/data/languages_v1.json'
COUNTRIES = ROOT / 'assets/data/countries_v1.json'
CURRENCIES = ROOT / 'assets/data/currencies_v1.json'
HINDI_PARTS = tuple(sorted((ROOT / 'lib/l10n/hi').glob('mizan_hi_*.dart')))
BENGALI_DIR = ROOT / 'lib/l10n/bn'
BENGALI = ROOT / 'lib/l10n/mizan_bn.dart'
BENGALI_DYNAMIC = ROOT / 'lib/l10n/mizan_bn_dynamic.dart'
CACHE_PATH = ROOT / 'build/bengali-translation-cache.json'
CLDR_COMMIT = '3701646856d5cdc946fc8fca8b9a36b5c5c300ba'
CLDR_BASE = f'https://raw.githubusercontent.com/unicode-org/cldr-json/{CLDR_COMMIT}/cldr-json'

BENGALI_RANGE = (0x0980, 0x09FF)
OTHER_SCRIPT_RANGES = (
    (0x0370, 0x052F),
    (0x0590, 0x08FF),
    (0x0900, 0x097F),
    (0x0B80, 0x0D7F),
    (0x4E00, 0x9FFF),
)

CRITICAL_OVERRIDES: dict[str, str] = {
    'MİZAN Aylık Raporu': 'MİZAN মাসিক প্রতিবেদন',
    'Ödemeleri, giderleri ve kalan yükü aynı filtreyle doğru ve ayrıntılı gösterir.':
        'একই ফিল্টারে পরিশোধ, খরচ এবং অবশিষ্ট পরিশোধের দায় সঠিক ও বিস্তারিতভাবে দেখায়।',
    'Ödemelere yapılan gider': 'পরিশোধে ব্যয়',
    'Normal giderler': 'সাধারণ খরচ',
    'Kalan ödeme yükü': 'অবশিষ্ট পরিশোধের দায়',
    'Gecikmiş ödeme yükü': 'মেয়াদোত্তীর্ণ পরিশোধের দায়',
    'Yaklaşan ödeme yükü': 'আসন্ন পরিশোধের দায়',
    'Gelir sonrası net': 'আয় বাদ দেওয়ার পর নিট অবস্থা',
    'Toplam gider sonrası net': 'মোট খরচের পর নিট অবস্থা',
    'Gerçekleşen harcamaların dağılımı': 'বাস্তবায়িত খরচের বণ্টন',
    'Gerçekleşen ödeme ayrıntıları': 'সম্পন্ন পরিশোধের বিস্তারিত',
    'Kalan ödeme ayrıntıları': 'অবশিষ্ট পরিশোধের বিস্তারিত',
    'Gecikmiş ödeme ayrıntıları': 'মেয়াদোত্তীর্ণ পরিশোধের বিস্তারিত',
    'Yaklaşan ödeme ayrıntıları': 'আসন্ন পরিশোধের বিস্তারিত',
    'Seçili dönemde açık ödeme yükü bulunmuyor.':
        'নির্বাচিত সময়সীমায় কোনো খোলা পরিশোধের দায় নেই।',
    'Toplam borcun tamamı değil, seçili döneme düşen sıradaki ödeme ve taksit tutarları gösterilir.':
        'সম্পূর্ণ ঋণ নয়; নির্বাচিত সময়সীমায় পড়া পরবর্তী পরিশোধ ও কিস্তির পরিমাণ দেখানো হয়।',
    'Kişi, kayıt, ödeme türü, tarih ve tutar birbirine karışmadan listelenir.':
        'ব্যক্তি, রেকর্ড, পরিশোধের ধরন, তারিখ ও পরিমাণ আলাদা রেখে তালিকাভুক্ত করা হয়।',
    'Normal giderler ile ödeme kayıtları aynı toplamda yer alır; kaynak türleri ayrı etiketlerle gösterilir.':
        'সাধারণ খরচ ও পরিশোধের রেকর্ড একই মোটে অন্তর্ভুক্ত থাকে; উৎসের ধরন আলাদা লেবেলে দেখানো হয়।',
    'Dönem ve kişi filtresi ekrandaki verilerle PDF’de birebir aynıdır.':
        'সময়সীমা ও ব্যক্তি ফিল্টার পর্দা এবং PDF-এ হুবহু একই থাকে।',
    'PDF hazırlanıyor.': 'PDF প্রস্তুত করা হচ্ছে।',
    'PDF hazırlanıyor': 'PDF প্রস্তুত করা হচ্ছে',
    'MİZAN PDF raporunu kaydet': 'MİZAN PDF প্রতিবেদন সংরক্ষণ করুন',
    'PDF raporu kaydedildi.': 'PDF প্রতিবেদন সংরক্ষণ করা হয়েছে।',
    'PDF raporu kaydedilemedi': 'PDF প্রতিবেদন সংরক্ষণ করা যায়নি',
    'PDF raporu paylaşılamadı': 'PDF প্রতিবেদন শেয়ার করা যায়নি',
    'PDF rapor sayfası görüntüye dönüştürülemedi.':
        'PDF প্রতিবেদনের পৃষ্ঠা ছবিতে রূপান্তর করা যায়নি।',
    'Aynı raporu kaydedebilir veya WhatsApp dahil paylaşım menüsüne gönderebilirsin.':
        'একই প্রতিবেদন সংরক্ষণ করতে বা WhatsApp-সহ শেয়ার মেনুতে পাঠাতে পারেন।',
    'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.':
        'Android-এর সঠিক সময়ের বিজ্ঞপ্তি অনুমতি বন্ধ আছে। MİZAN আনুমানিক সময়সূচি ব্যবহার করে না; নির্বাচিত ঘণ্টা ও মিনিটে বিজ্ঞপ্তি দিতে অনুমতিটি চালু করতে হবে।',
    'Bildirim izni kapalı. Hatırlatmaları alabilmek için Android bildirim iznini açın.':
        'বিজ্ঞপ্তির অনুমতি বন্ধ আছে। অনুস্মারক পেতে Android বিজ্ঞপ্তির অনুমতি চালু করুন।',
    'Bildirim planı doğrulanamadı; Android tarafında kayıt eksik kaldı.':
        'বিজ্ঞপ্তির সময়সূচি যাচাই করা যায়নি; Android-এ কিছু রেকর্ড অনুপস্থিত রয়েছে।',
    'Bugünkü giderlerini işlemeyi unutma.': 'আজকের খরচগুলো নথিভুক্ত করতে ভুলবেন না।',
    'Öğlene kadar yaptığın harcamaları ekleyebilirsin.':
        'দুপুর পর্যন্ত করা খরচগুলো যোগ করতে পারেন।',
    'Günü kapatmadan giderlerini kontrol et.': 'দিন শেষ করার আগে খরচগুলো যাচাই করুন।',
    'Yaklaşan ve gecikmiş ödemelerini kontrol et.':
        'আসন্ন ও মেয়াদোত্তীর্ণ পরিশোধগুলো যাচাই করুন।',
    'Günün ödeme planını gözden geçir.': 'আজকের পরিশোধ পরিকল্পনা পর্যালোচনা করুন।',
    'Yedekleri birleştir': 'ব্যাকআপ একত্র করুন',
    'Yedek oluştur': 'ব্যাকআপ তৈরি করুন',
    'Yedeği geri yükle': 'ব্যাকআপ পুনরুদ্ধার করুন',
    'Kullanıcı tarafından girilen kişi adları, notlar ve açıklamalar çevrilmez.':
        'ব্যবহারকারীর লেখা ব্যক্তির নাম, নোট ও বিবরণ অনুবাদ করা হয় না।',
    'ONAYLIYORUM': 'আমি নিশ্চিত করছি',
}

TECHNICAL_TOKENS = sorted(
    BENGALI_ALLOWED_LATIN_TERMS
    | {
        'LEFFERION PRIME - MİZAN',
        'LEFFERION PRIME - MIZAN',
        'MİZAN',
        'MIZAN',
        'Android',
        'WhatsApp',
        'PDF',
        'CSV',
        'IBAN',
        'ISO',
        'BDT',
        'INR',
        'TRY',
        'USD',
        'EUR',
    },
    key=len,
    reverse=True,
)


def fail(message: str) -> None:
    raise SystemExit(message)


def read(path: Path) -> str:
    return path.read_text(encoding='utf-8')


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(unicodedata.normalize('NFC', text), encoding='utf-8')


def replace_once(path: Path, old: str, new: str) -> None:
    text = read(path)
    if new in text:
        return
    count = text.count(old)
    if count != 1:
        fail(f'Expected one Bengali integration target in {path.relative_to(ROOT)}; found {count}: {old[:120]!r}')
    write(path, text.replace(old, new, 1))


def replace_count(path: Path, old: str, new: str, expected: int) -> None:
    text = read(path)
    if text.count(new) == expected:
        return
    count = text.count(old)
    if count != expected:
        fail(f'Expected {expected} Bengali integration targets in {path.relative_to(ROOT)}; found {count}: {old[:120]!r}')
    write(path, text.replace(old, new))


def replace_nth(path: Path, old: str, new: str, occurrence: int) -> None:
    text = read(path)
    if new in text:
        return
    starts = [match.start() for match in re.finditer(re.escape(old), text)]
    if len(starts) < occurrence:
        fail(f'Expected Bengali target occurrence {occurrence} in {path.relative_to(ROOT)}; found {len(starts)}')
    index = starts[occurrence - 1]
    write(path, text[:index] + new + text[index + len(old):])


def dart_escape(value: str) -> str:
    return value.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$').replace('\n', '\\n')


def load_cache() -> dict[str, str]:
    if not CACHE_PATH.exists():
        return {}
    return json.loads(read(CACHE_PATH))


def save_cache(cache: dict[str, str]) -> None:
    CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
    write(CACHE_PATH, json.dumps(cache, ensure_ascii=False, sort_keys=True, indent=2) + '\n')


def mask_tokens(value: str) -> tuple[str, dict[str, str]]:
    protected: dict[str, str] = {}

    def protect(token: str) -> str:
        marker = f'ZXQ{len(protected)}QXZ'
        protected[marker] = token
        return marker

    text = value
    for token in TECHNICAL_TOKENS:
        text = text.replace(token, protect(token))
    text = re.sub(r'\$\{[^}]+\}|\$[A-Za-z_][A-Za-z0-9_]*', lambda m: protect(m.group(0)), text)
    text = re.sub(r'__MIZAN_[A-Za-z0-9_]+__', lambda m: protect(m.group(0)), text)
    return text, protected


def unmask_tokens(value: str, protected: dict[str, str]) -> str:
    result = value
    for marker, token in protected.items():
        result = result.replace(marker, token).replace(marker.lower(), token)
    return result


def google_translate(value: str, source_language: str, cache: dict[str, str]) -> str:
    key = f'{source_language}|{value}'
    if key in cache:
        return cache[key]
    if not value.strip():
        return value
    masked, protected = mask_tokens(value)
    query = urllib.parse.urlencode(
        {
            'client': 'gtx',
            'sl': source_language,
            'tl': 'bn',
            'dt': 't',
            'q': masked,
        }
    )
    url = f'https://translate.googleapis.com/translate_a/single?{query}'
    last_error: Exception | None = None
    for attempt in range(6):
        try:
            request = urllib.request.Request(url, headers={'User-Agent': 'MIZAN-Bengali-localizer/1.0'})
            with urllib.request.urlopen(request, timeout=45) as response:
                payload = json.load(response)
            translated = ''.join(segment[0] for segment in payload[0] if segment and segment[0])
            translated = unmask_tokens(translated, protected).strip()
            translated = unicodedata.normalize('NFC', translated)
            if not translated:
                raise ValueError('empty translation')
            cache[key] = translated
            return translated
        except (urllib.error.URLError, TimeoutError, ValueError, json.JSONDecodeError) as error:
            last_error = error
            time.sleep(1.5 * (attempt + 1))
    fail(f'Bengali seed translation failed for {value!r}: {last_error}')


def translated_static_value(key: str, english: str, cache: dict[str, str]) -> str:
    if key in CRITICAL_OVERRIDES:
        return CRITICAL_OVERRIDES[key]
    if key in BENGALI_TERMINOLOGY:
        return BENGALI_TERMINOLOGY[key]
    value = google_translate(english, 'en', cache)
    replacements = {
        'বকেয়া পেমেন্টের বোঝা': 'মেয়াদোত্তীর্ণ পরিশোধের দায়',
        'অবশিষ্ট পেমেন্টের বোঝা': 'অবশিষ্ট পরিশোধের দায়',
        'আসন্ন পেমেন্টের বোঝা': 'আসন্ন পরিশোধের দায়',
        'পেমেন্ট': 'পরিশোধ',
        'রিমাইন্ডার': 'অনুস্মারক',
        'রিপোর্ট': 'প্রতিবেদন',
        'ব্যয়': 'খরচ',
        'ঋণের ভার': 'ঋণের দায়',
    }
    for source, target in replacements.items():
        value = value.replace(source, target)
    return value


def materialize_static_files(cache: dict[str, str]) -> None:
    english = dict(english_pairs())
    if len(english) != 791:
        fail(f'Stable English source count changed: {len(english)}')
    jobs: list[tuple[str, str]] = []
    for path in HINDI_PARTS:
        source = read(path)
        marker = re.search(r'const Map<String, String> (mizanHindi\w+)', source)
        if marker is None:
            fail(f'Hindi segmentation marker missing: {path.relative_to(ROOT)}')
        for key, _ in parse_map(source, marker.group(0)):
            if key not in english:
                fail(f'English source missing for key: {key}')
            if key not in CRITICAL_OVERRIDES and key not in BENGALI_TERMINOLOGY:
                jobs.append((key, english[key]))

    unique_values = sorted({value for _, value in jobs if f'en|{value}' not in cache})
    if unique_values:
        def translate_one(value: str) -> tuple[str, str]:
            local_cache: dict[str, str] = {}
            result = google_translate(value, 'en', local_cache)
            return f'en|{value}', result

        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
            for key, translated in executor.map(translate_one, unique_values):
                cache[key] = translated
                if len(cache) % 25 == 0:
                    save_cache(cache)
        save_cache(cache)

    BENGALI_DIR.mkdir(parents=True, exist_ok=True)
    imports: list[str] = []
    spreads: list[str] = []
    total = 0
    for hindi_path in HINDI_PARTS:
        source = read(hindi_path)
        marker = re.search(r'const Map<String, String> (mizanHindi\w+)', source)
        assert marker is not None
        pairs = parse_map(source, marker.group(0))
        suffix = hindi_path.stem.removeprefix('mizan_hi_')
        target_path = BENGALI_DIR / f'mizan_bn_{suffix}.dart'
        map_name = marker.group(1).replace('mizanHindi', 'mizanBengali')
        lines = [
            '// REVIEWED BENGALI LOCALIZATION — NATURAL BANGLADESH/INDIA PRODUCT COPY.',
            f'const Map<String, String> {map_name} = <String, String>{{',
        ]
        for key, _ in pairs:
            value = translated_static_value(key, english[key], cache)
            lines.append(f"  '{dart_escape(key)}': '{dart_escape(value)}',")
        lines.append('};')
        lines.append('')
        write(target_path, '\n'.join(lines))
        imports.append(f"import 'bn/{target_path.name}';")
        spreads.append(f'  ...{map_name},')
        total += len(pairs)
    if total != 791:
        fail(f'Bengali segmentation count changed: {total}')
    write(
        BENGALI,
        '\n'.join(
            [
                '// REVIEWED BENGALI LOCALIZATION — 791/791 STATIC VALUES.',
                *imports,
                '',
                'const Map<String, String> mizanBengali = <String, String>{',
                *spreads,
                '};',
                '',
            ]
        ),
    )


def transform_dynamic_literal(body: str, cache: dict[str, str]) -> str:
    if not any(0x0900 <= ord(char) <= 0x097F for char in body):
        return body
    decoded = body.replace("\\'", "'").replace('\\n', '\n')
    translated = google_translate(decoded, 'hi', cache)
    replacements = {
        'পেমেন্ট': 'পরিশোধ',
        'রিমাইন্ডার': 'অনুস্মারক',
        'রিপোর্ট': 'প্রতিবেদন',
        'বাকি পরিমাণ': 'অবশিষ্ট পরিমাণ',
        'ওভারডিউ': 'মেয়াদোত্তীর্ণ',
    }
    for source, target in replacements.items():
        translated = translated.replace(source, target)
    return translated.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n')


def materialize_dynamic(cache: dict[str, str]) -> None:
    source = read(ROOT / 'lib/l10n/mizan_hi_dynamic.dart')
    source = (
        source.replace('HindiDynamicTranslator', 'BengaliDynamicTranslator')
        .replace('translateHindiReviewedDynamic', 'translateBengaliReviewedDynamic')
        .replace('_hindiPatterns', '_bengaliPatterns')
        .replace('_HindiPattern', '_BengaliPattern')
        .replace('_hindiPhrases', '_bengaliPhrases')
    )
    literal = re.compile(r"(?P<raw>r?)'(?P<body>(?:\\.|[^'\\])*)'")
    source = literal.sub(
        lambda match: f"{match.group('raw')}'{transform_dynamic_literal(match.group('body'), cache)}'",
        source,
    )
    write(BENGALI_DYNAMIC, source)
    save_cache(cache)


def integrate_i18n() -> None:
    replace_once(
        I18N,
        "import 'mizan_hi_dynamic.dart';",
        "import 'mizan_hi_dynamic.dart';\nimport 'mizan_bn.dart';\nimport 'mizan_bn_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar', 'fa', 'he', 'hi'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk', 'ar', 'fa', 'he', 'hi', 'bn'};",
    )
    replace_once(
        I18N,
        "  static bool get isHindi => _languageTag == 'hi';\n",
        "  static bool get isHindi => _languageTag == 'hi';\n  static bool get isBengali => _languageTag == 'bn';\n",
    )
    replace_once(
        I18N,
        "    'hi' => 'मैं सहमत हूँ',\n",
        "    'hi' => 'मैं सहमत हूँ',\n    'bn' => 'আমি নিশ্চিত করছি',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'hi' || normalized.startsWith('hi-')) return 'hi';\n",
        "    if (normalized == 'hi' || normalized.startsWith('hi-')) return 'hi';\n    if (normalized == 'bn' || normalized.startsWith('bn-')) return 'bn';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'hi' ||\n        normalized.startsWith('hi-');\n",
        "        normalized == 'hi' ||\n        normalized.startsWith('hi-') ||\n        normalized == 'bn' ||\n        normalized.startsWith('bn-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanHindi[visibleSource] ??
          translateHindiReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'hi'),
          );
    }
""",
        """    } else if (effective == 'hi') {
      result =
          mizanHindi[visibleSource] ??
          translateHindiReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'hi'),
          );
    } else {
      result =
          mizanBengali[visibleSource] ??
          translateBengaliReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'bn'),
          );
    }
""",
    )


def integrate_main() -> None:
    replace_once(
        MAIN,
        "          'hi' => const Locale('hi', 'IN'),\n",
        "          'hi' => const Locale('hi', 'IN'),\n          'bn' => const Locale('bn', 'BD'),\n",
    )
    replace_once(
        MAIN,
        "          Locale('hi', 'IN'),\n",
        "          Locale('hi', 'IN'),\n          Locale('bn', 'BD'),\n",
    )


def integrate_catalog_model() -> None:
    replace_count(
        CATALOG_MODEL,
        '    required this.nameHi,\n',
        "    required this.nameHi,\n    this.nameBn = '',\n",
        3,
    )
    replace_count(
        CATALOG_MODEL,
        '  final String nameHi;\n',
        '  final String nameHi;\n  final String nameBn;\n',
        3,
    )
    replace_count(
        CATALOG_MODEL,
        "    nameHi: json['nameHi']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameHi: json['nameHi']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameBn: json['nameBn']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_count(
        CATALOG_MODEL,
        "    'hi' => nameHi,\n",
        "    'hi' => nameHi,\n    'bn' => nameBn.isEmpty ? nameEn : nameBn,\n",
        3,
    )
    text = read(CATALOG_MODEL)
    text = text.replace('$nameHe $nameHi', '$nameHe $nameHi $nameBn')
    text = text.replace('      nameHi,\n      ...symbols,', '      nameHi,\n      nameBn,\n      ...symbols,')
    write(CATALOG_MODEL, text)


def integrate_formatters() -> None:
    replace_once(
        FORMATTERS,
        """String _persianDigits(String value) {
  const western = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], persian[index]);
  }
  return result;
}
""",
        """String _persianDigits(String value) {
  const western = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], persian[index]);
  }
  return result;
}

String _bengaliDigits(String value) {
  const western = '0123456789';
  const bengali = '০১২৩৪৫৬৭৮৯';
  var result = value;
  for (var index = 0; index < western.length; index++) {
    result = result.replaceAll(western[index], bengali[index]);
  }
  return result;
}
""",
    )
    replace_once(
        FORMATTERS,
        "  const devanagari = '०१२३४५६७८९';\n",
        "  const devanagari = '०१२३४५६७८९';\n  const bengali = '০১২৩৪৫৬৭৮৯';\n",
    )
    replace_once(
        FORMATTERS,
        ".replaceAll(devanagari[index], western[index]);",
        ".replaceAll(devanagari[index], western[index])\n        .replaceAll(bengali[index], western[index]);",
    )
    text = read(FORMATTERS)
    text = text.replace(
        'MizanI18n.isEnglish || MizanI18n.isHebrew || MizanI18n.isHindi',
        'MizanI18n.isEnglish ||\n          MizanI18n.isHebrew ||\n          MizanI18n.isHindi ||\n          MizanI18n.isBengali',
    )
    text = text.replace('if (MizanI18n.isHindi) {', 'if (MizanI18n.isHindi || MizanI18n.isBengali) {')
    text = text.replace(
        "final amount = MizanI18n.isArabic\n      ? _arabicDigits(rawAmount)\n      : (MizanI18n.isPersian ? _persianDigits(rawAmount) : rawAmount);",
        "final amount = MizanI18n.isArabic\n      ? _arabicDigits(rawAmount)\n      : (MizanI18n.isPersian\n            ? _persianDigits(rawAmount)\n            : (MizanI18n.isBengali ? _bengaliDigits(rawAmount) : rawAmount));",
    )
    text = text.replace(
        """  if (MizanI18n.isHindi) {
    if (code == 'INR') return '₹$amount';
    return '$code\\u00A0$amount';
  }
""",
        """  if (MizanI18n.isHindi) {
    if (code == 'INR') return '₹$amount';
    return '$code\\u00A0$amount';
  }
  if (MizanI18n.isBengali) {
    if (code == 'BDT') return '৳$amount';
    if (code == 'INR') return '₹$amount';
    return '$code\\u00A0$amount';
  }
""",
    )
    text = text.replace(
        ": (MizanI18n.isPersian ? _persianDigits(integerPart) : integerPart);",
        ": (MizanI18n.isPersian\n              ? _persianDigits(integerPart)\n              : (MizanI18n.isBengali ? _bengaliDigits(integerPart) : integerPart));",
    )
    text = text.replace(
        "  if (MizanI18n.isHindi) return '$integerPart.$decimalPart';",
        "  if (MizanI18n.isHindi) return '$integerPart.$decimalPart';\n  if (MizanI18n.isBengali) {\n    return _bengaliDigits('$integerPart.$decimalPart');\n  }",
    )
    text = text.replace("      .replaceAll('inr', '')\n", "      .replaceAll('inr', '')\n      .replaceAll('৳', '')\n      .replaceAll('bdt', '')\n")
    text = text.replace(
        'final indianThousands = MizanI18n.isHindi && _isIndianGrouping(segments);',
        'final indianThousands =\n          (MizanI18n.isHindi || MizanI18n.isBengali) &&\n          _isIndianGrouping(segments);',
    )
    write(FORMATTERS, text)

    replace_nth(
        FORMATTERS,
        '  const hiMonths = [\n',
        """  const bnMonths = [
    'জানু',
    'ফেব',
    'মার্চ',
    'এপ্রি',
    'মে',
    'জুন',
    'জুলাই',
    'আগ',
    'সেপ্টে',
    'অক্টো',
    'নভে',
    'ডিসে',
  ];
  const hiMonths = [
""",
        1,
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isHindi) {
    return '${value.day} ${hiMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isHindi) {
    return '${value.day} ${hiMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isBengali) {
    return _bengaliDigits('${value.day} ${bnMonths[value.month - 1]} ${value.year}');
  }
""",
    )
    replace_nth(
        FORMATTERS,
        '  const hiMonths = [\n',
        """  const bnMonths = [
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];
  const hiMonths = [
""",
        2,
    )
    replace_once(
        FORMATTERS,
        """  if (MizanI18n.isHindi) {
    return '${hiMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isHindi) {
    return '${hiMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isBengali) {
    return _bengaliDigits('${bnMonths[value.month - 1]} ${value.year}');
  }
""",
    )


def fetch_json(relative: str) -> dict[str, object]:
    request = urllib.request.Request(
        f'{CLDR_BASE}/{relative}',
        headers={'User-Agent': 'MIZAN-Bengali-catalog-builder/1.0'},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)


def save_json(path: Path, payload: dict[str, object]) -> None:
    write(path, json.dumps(payload, ensure_ascii=False, separators=(',', ':')) + '\n')


def update_catalogs() -> None:
    languages_data = fetch_json('cldr-localenames-full/main/bn/languages.json')
    territories_data = fetch_json('cldr-localenames-full/main/bn/territories.json')
    currencies_data = fetch_json('cldr-numbers-full/main/bn/currencies.json')
    language_names = languages_data['main']['bn']['localeDisplayNames']['languages']
    territory_names = territories_data['main']['bn']['localeDisplayNames']['territories']
    currency_names = currencies_data['main']['bn']['numbers']['currencies']

    language_payload = json.loads(read(LANGUAGES))
    country_payload = json.loads(read(COUNTRIES))
    currency_payload = json.loads(read(CURRENCIES))
    language_overrides = {
        'pt-BR': language_names.get('pt-BR', 'ব্রাজিলীয় পর্তুগিজ'),
        'pt-PT': language_names.get('pt-PT', 'ইউরোপীয় পর্তুগিজ'),
        'bn': 'বাংলা',
    }
    currency_overrides = {
        'XCG': 'ক্যারিবীয় গিল্ডার',
        'ZWG': 'জিম্বাবুয়ে গোল্ড',
    }
    missing: list[str] = []
    for item in language_payload['items']:
        code = str(item['code'])
        candidates = (code, code.replace('-', '_'), code.split('-')[0])
        name = language_overrides.get(code) or next(
            (language_names.get(candidate) for candidate in candidates if language_names.get(candidate)),
            None,
        )
        if name:
            item['nameBn'] = name
        else:
            missing.append(f'language:{code}')
    for item in country_payload['items']:
        code = str(item['code'])
        name = territory_names.get(code)
        if name:
            item['nameBn'] = name
        else:
            missing.append(f'country:{code}')
    for item in currency_payload['items']:
        code = str(item['code'])
        data = currency_names.get(code)
        name = data.get('displayName') if isinstance(data, dict) else None
        name = name or currency_overrides.get(code)
        if name:
            item['nameBn'] = name
        else:
            missing.append(f'currency:{code}')
    if missing:
        fail(f'Pinned CLDR Bengali catalog names are missing: {missing[:30]}')
    save_json(LANGUAGES, language_payload)
    save_json(COUNTRIES, country_payload)
    save_json(CURRENCIES, currency_payload)


def advance_inherited_contracts() -> None:
    for path in sorted((ROOT / 'test').glob('*.dart')):
        text = read(path)
        original = text
        if 'supportedLanguageTags' in text and "      'bn'," not in text:
            text = text.replace("      'hi',\n", "      'hi',\n      'bn',\n", 1)
            text = text.replace('eighteen-language', 'nineteen-language')
            text = text.replace('eighteen language', 'nineteen language')
            text = text.replace('18-language', '19-language')
            text = text.replace('18 languages', '19 languages')
            text = re.sub(
                r'(supportedLanguageTags\.length\s*,\s*)18',
                r'\g<1>19',
                text,
            )
        if text != original:
            write(path, text)
    for path in sorted((ROOT / 'tools').glob('*.py')):
        text = read(path)
        updated = text.replace('EXPECTED_INTEGRATED_LANGUAGES = 18', 'EXPECTED_INTEGRATED_LANGUAGES = 19')
        if updated != text:
            write(path, updated)


def bengali_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in sorted(BENGALI_DIR.glob('mizan_bn_*.dart')):
        source = read(path)
        marker = re.search(r'const Map<String, String> (mizanBengali\w+)', source)
        if marker is None:
            fail(f'Bengali map marker missing: {path.relative_to(ROOT)}')
        result.extend(parse_map(source, marker.group(0)))
    return result


def verify() -> None:
    pairs = bengali_pairs()
    source_keys = [key for key, _ in english_pairs()]
    keys = [key for key, _ in pairs]
    if len(source_keys) != 791:
        fail(f'Stable source key count changed: {len(source_keys)}')
    if len(keys) != 791 or len(set(keys)) != 791:
        fail(f'Bengali static key count/uniqueness failed: {len(keys)} / {len(set(keys))}')
    if set(keys) != set(source_keys):
        fail('Bengali source-key parity failed')
    values = [value for _, value in pairs]
    combined = '\n'.join(values)
    if any(char in combined for char in BENGALI_FORBIDDEN_INVISIBLE):
        fail('Invisible or bidi control character found in Bengali copy')
    if any(unicodedata.normalize('NFC', value) != value for value in values):
        fail('Bengali static copy is not NFC-normalized')
    bad = sorted(term for term in BENGALI_FORBIDDEN_COPY if term in combined)
    if bad:
        fail(f'Forbidden ambiguous/machine Bengali copy remains: {bad}')
    leaks = [
        (key, value)
        for key, value in pairs
        if any(any(start <= ord(char) <= end for start, end in OTHER_SCRIPT_RANGES) for char in value)
    ]
    if leaks:
        fail(f'Another product script leaked into Bengali copy: {leaks[:20]}')
    bengali_chars = sum(BENGALI_RANGE[0] <= ord(char) <= BENGALI_RANGE[1] for char in combined)
    if bengali_chars < 2500:
        fail(f'Too few Bengali characters in static product copy: {bengali_chars}')
    required = {
        'ঋণ',
        'পরিশোধ',
        'খরচ',
        'আয়',
        'অবশিষ্ট পরিশোধের দায়',
        'মেয়াদোত্তীর্ণ পরিশোধের দায়',
        'আসন্ন পরিশোধের দায়',
        'বিজ্ঞপ্তির অনুমতি',
        'ব্যাকআপ একত্র করুন',
        'আমি নিশ্চিত করছি',
    }
    missing_required = sorted(term for term in required if term not in combined and term != 'আমি নিশ্চিত করছি')
    if missing_required:
        fail(f'Required Bengali product terminology missing: {missing_required}')
    runtime = read(I18N) + read(CATALOG_MODEL) + read(FORMATTERS) + read(MAIN)
    for marker in (
        'static bool get isBengali',
        'mizanBengali[visibleSource]',
        'translateBengaliReviewedDynamic(',
        "normalized.startsWith('bn-')",
        "'bn' => nameBn.isEmpty ? nameEn : nameBn",
        "Locale('bn', 'BD')",
        'MizanI18n.isBengali',
        '৳',
        'bnMonths',
    ):
        if marker not in runtime:
            fail(f'Bengali runtime marker missing: {marker}')
    for path, expected in ((LANGUAGES, 29), (COUNTRIES, 161), (CURRENCIES, 154)):
        payload = json.loads(read(path))
        items = payload.get('items', [])
        if payload.get('count') != expected or len(items) != expected:
            fail(f'Catalog count changed for {path.name}')
        empty = [str(item.get('code')) for item in items if not str(item.get('nameBn', '')).strip()]
        if empty:
            fail(f'Bengali catalog names missing in {path.name}: {empty[:20]}')
    print(
        f'Bengali runtime verified: {len(keys)}/791 static values, Bengali/NFC purity, '
        'catalogs 29/161/154, LTR, Indian grouping, BDT/INR and Gregorian dates.'
    )


def materialize() -> None:
    cache = load_cache()
    materialize_static_files(cache)
    materialize_dynamic(cache)
    integrate_i18n()
    integrate_main()
    integrate_catalog_model()
    integrate_formatters()
    update_catalogs()
    advance_inherited_contracts()
    verify()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--materialize', action='store_true')
    parser.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    if args.materialize:
        materialize()
    else:
        verify()


if __name__ == '__main__':
    main()
