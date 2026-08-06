#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from babel import Locale

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def write(path: str, value: str) -> None:
    (ROOT / path).write_text(value, encoding='utf-8')


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{label}: expected one match, found {count}')
    return text.replace(old, new, 1)


def patch_i18n() -> None:
    path = 'lib/l10n/mizan_i18n.dart'
    text = read(path)
    if "import 'mizan_id.dart';" in text:
        return
    text = replace_once(
        text,
        "import 'mizan_bn_dynamic.dart';\n",
        "import 'mizan_bn_dynamic.dart';\nimport 'mizan_id.dart';\nimport 'mizan_id_dynamic.dart';\n",
        'i18n imports',
    )
    text = replace_once(text, "'hi', 'bn'};", "'hi', 'bn', 'id'};", 'supported tags')
    text = replace_once(
        text,
        "  static bool get isBengali => _languageTag == 'bn';\n",
        "  static bool get isBengali => _languageTag == 'bn';\n  static bool get isIndonesian => _languageTag == 'id';\n",
        'Indonesian getter',
    )
    text = replace_once(
        text,
        "    'bn' => 'আমি নিশ্চিত করছি',\n",
        "    'bn' => 'আমি নিশ্চিত করছি',\n    'id' => 'SAYA SETUJU',\n",
        'confirmation',
    )
    text = replace_once(
        text,
        "    if (normalized == 'bn' || normalized.startsWith('bn-')) return 'bn';\n    return 'tr';",
        "    if (normalized == 'bn' || normalized.startsWith('bn-')) return 'bn';\n    if (normalized == 'id' || normalized.startsWith('id-') || normalized == 'in' || normalized.startsWith('in-')) return 'id';\n    return 'tr';",
        'normalize id',
    )
    text = replace_once(
        text,
        "        normalized == 'bn' ||\n        normalized.startsWith('bn-');",
        "        normalized == 'bn' ||\n        normalized.startsWith('bn-') ||\n        normalized == 'id' ||\n        normalized.startsWith('id-') ||\n        normalized == 'in' ||\n        normalized.startsWith('in-');",
        'supported id',
    )
    text = replace_once(
        text,
        "    } else {\n      result =\n          mizanBengali[visibleSource] ??\n          translateBengaliReviewedDynamic(\n            visibleSource,\n            (value) => text(value, languageTag: 'bn'),\n          );\n    }",
        "    } else if (effective == 'bn') {\n      result =\n          mizanBengali[visibleSource] ??\n          translateBengaliReviewedDynamic(\n            visibleSource,\n            (value) => text(value, languageTag: 'bn'),\n          );\n    } else {\n      result =\n          mizanIndonesian[visibleSource] ??\n          translateIndonesianReviewedDynamic(\n            visibleSource,\n            (value) => text(value, languageTag: 'id'),\n          );\n    }",
        'Indonesian dispatch',
    )
    write(path, text)


def patch_main() -> None:
    path = 'lib/main.dart'
    text = read(path)
    if "'id' => const Locale('id', 'ID')" in text:
        return
    text = replace_once(
        text,
        "          'bn' => const Locale('bn', 'BD'),\n",
        "          'bn' => const Locale('bn', 'BD'),\n          'id' => const Locale('id', 'ID'),\n",
        'main locale switch',
    )
    text = replace_once(
        text,
        "          Locale('bn', 'BD'),\n",
        "          Locale('bn', 'BD'),\n          Locale('id', 'ID'),\n",
        'supported locales',
    )
    write(path, text)


def patch_formatters() -> None:
    path = 'lib/core/formatters.dart'
    text = read(path)
    if 'MizanI18n.isIndonesian' in text:
        return
    text = replace_once(
        text,
        "  if (MizanI18n.isBengali) {\n    if (code == 'BDT') return '৳$amount';\n    if (code == 'INR') return '₹$amount';\n    return '$code\\u00A0$amount';\n  }",
        "  if (MizanI18n.isBengali) {\n    if (code == 'BDT') return '৳$amount';\n    if (code == 'INR') return '₹$amount';\n    return '$code\\u00A0$amount';\n  }\n  if (MizanI18n.isIndonesian) {\n    if (code == 'IDR') return 'Rp$amount';\n    return '$code\\u00A0$amount';\n  }",
        'IDR money',
    )
    text = replace_once(
        text,
        "      .replaceAll('bdt', '')\n",
        "      .replaceAll('bdt', '')\n      .replaceAll('Rp', '')\n      .replaceAll('rp', '')\n      .replaceAll('idr', '')\n",
        'IDR parsing',
    )
    text = replace_once(
        text,
        "  const bnMonths = [\n    'জানু',",
        "  const idMonths = [\n    'Jan',\n    'Feb',\n    'Mar',\n    'Apr',\n    'Mei',\n    'Jun',\n    'Jul',\n    'Agu',\n    'Sep',\n    'Okt',\n    'Nov',\n    'Des',\n  ];\n  const bnMonths = [\n    'জানু',",
        'short Indonesian months',
    )
    text = replace_once(
        text,
        "  if (MizanI18n.isBengali) {\n    return _bengaliDigits(\n      '${value.day} ${bnMonths[value.month - 1]} ${value.year}',\n    );\n  }\n  final months =",
        "  if (MizanI18n.isBengali) {\n    return _bengaliDigits(\n      '${value.day} ${bnMonths[value.month - 1]} ${value.year}',\n    );\n  }\n  if (MizanI18n.isIndonesian) {\n    return '${value.day} ${idMonths[value.month - 1]} ${value.year}';\n  }\n  final months =",
        'short Indonesian date',
    )
    text = replace_once(
        text,
        "  const bnMonths = [\n    'জানুয়ারি',",
        "  const idMonths = [\n    'Januari',\n    'Februari',\n    'Maret',\n    'April',\n    'Mei',\n    'Juni',\n    'Juli',\n    'Agustus',\n    'September',\n    'Oktober',\n    'November',\n    'Desember',\n  ];\n  const bnMonths = [\n    'জানুয়ারি',",
        'long Indonesian months',
    )
    text = replace_once(
        text,
        "  if (MizanI18n.isBengali) {\n    return _bengaliDigits('${bnMonths[value.month - 1]} ${value.year}');\n  }\n  if (MizanI18n.isPortugueseBr",
        "  if (MizanI18n.isBengali) {\n    return _bengaliDigits('${bnMonths[value.month - 1]} ${value.year}');\n  }\n  if (MizanI18n.isIndonesian) {\n    return '${idMonths[value.month - 1]} ${value.year}';\n  }\n  if (MizanI18n.isPortugueseBr",
        'Indonesian month label',
    )
    write(path, text)


def patch_catalog_model() -> None:
    path = 'lib/global/global_catalog.dart'
    text = read(path)
    if 'final String nameId;' in text:
        return
    if text.count("    this.nameBn = '',\n") != 3:
        raise RuntimeError('global constructors changed')
    text = text.replace("    this.nameBn = '',\n", "    this.nameBn = '',\n    this.nameId = '',\n")
    if text.count('  final String nameBn;\n') != 3:
        raise RuntimeError('global fields changed')
    text = text.replace('  final String nameBn;\n', '  final String nameBn;\n  final String nameId;\n')
    factory = "    nameBn: json['nameBn']?.toString() ?? json['nameEn']?.toString() ?? '',\n"
    if text.count(factory) != 3:
        raise RuntimeError('global factories changed')
    text = text.replace(factory, factory + "    nameId: json['nameId']?.toString() ?? json['nameEn']?.toString() ?? '',\n")
    switch = "    'bn' => nameBn.isEmpty ? nameEn : nameBn,\n"
    if text.count(switch) != 3:
        raise RuntimeError('global display switches changed')
    text = text.replace(switch, switch + "    'id' => nameId.isEmpty ? nameEn : nameId,\n")
    text = text.replace('$nameHi $nameBn', '$nameHi $nameBn $nameId')
    text = replace_once(text, '      nameBn,\n      ...symbols,', '      nameBn,\n      nameId,\n      ...symbols,', 'currency search field')
    write(path, text)


def patch_catalog_data() -> None:
    locale = Locale.parse('id')
    data_dir = ROOT / 'assets' / 'data'
    language_path = data_dir / 'languages_v1.json'
    language_data = json.loads(language_path.read_text(encoding='utf-8'))
    manual_language = {
        'pt-BR': 'Portugis (Brasil)',
        'pt-PT': 'Portugis (Portugal)',
        'zh-Hans': 'Tionghoa Sederhana',
        'zh-Hant': 'Tionghoa Tradisional',
    }
    for item in language_data['items']:
        code = item['code']
        item['nameId'] = manual_language.get(code) or locale.languages.get(code.split('-')[0].lower()) or item['nameEn']
    if not any(item['code'] == 'id' for item in language_data['items']):
        language_data['items'].append({
            'code': 'id', 'nativeName': 'Bahasa Indonesia', 'nameTr': 'Endonezce',
            'nameEn': 'Indonesian', 'nameEs': 'Indonesio', 'namePtBr': 'indonésio',
            'namePtPt': 'indonésio', 'nameFr': 'indonésien', 'nameDe': 'Indonesisch',
            'nameIt': 'indonesiano', 'nameNl': 'Indonesisch', 'namePl': 'indonezyjski',
            'nameRo': 'indoneziană', 'nameEl': 'Ινδονησιακά', 'nameRu': 'индонезийский',
            'nameUk': 'індонезійська', 'nameAr': 'الإندونيسية', 'nameFa': 'اندونزیایی',
            'nameHe': 'אינדונזית', 'nameHi': 'इंडोनेशियाई', 'nameBn': 'ইন্দোনেশীয়',
            'nameId': 'Bahasa Indonesia', 'countryCodes': ['ID'],
        })
    language_data['count'] = len(language_data['items'])
    language_path.write_text(json.dumps(language_data, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')

    for filename, names in (
        ('countries_v1.json', locale.territories),
        ('currencies_v1.json', locale.currencies),
    ):
        path = data_dir / filename
        data = json.loads(path.read_text(encoding='utf-8'))
        missing: list[str] = []
        for item in data['items']:
            value = names.get(item['code'])
            if not value:
                missing.append(item['code'])
                continue
            item['nameId'] = value
            if filename.startswith('currencies'):
                item['aliases'] = list(dict.fromkeys([*item.get('aliases', []), value]))
        if missing:
            raise RuntimeError(f'CLDR Indonesian names missing for {filename}: {missing}')
        data['count'] = len(data['items'])
        path.write_text(json.dumps(data, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')


def main() -> None:
    patch_i18n()
    patch_main()
    patch_formatters()
    patch_catalog_model()
    patch_catalog_data()


if __name__ == '__main__':
    main()
