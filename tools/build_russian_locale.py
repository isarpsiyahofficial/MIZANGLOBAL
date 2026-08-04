#!/usr/bin/env python3
"""Build, integrate and verify the reviewed Russia-oriented Russian locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
RUSSIAN = LIB / "l10n" / "mizan_ru.dart"
RUSSIAN_DYNAMIC = LIB / "l10n" / "mizan_ru_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "ru").glob("mizan_ru_*.dart")))


def skip(source: str, index: int) -> int:
    while index < len(source):
        if source[index].isspace():
            index += 1
            continue
        if source.startswith("//", index):
            newline = source.find("\n", index)
            index = len(source) if newline < 0 else newline + 1
            continue
        if source.startswith("/*", index):
            end = source.find("*/", index + 2)
            if end < 0:
                raise ValueError("unterminated block comment")
            index = end + 2
            continue
        break
    return index


def dart_string(source: str, index: int) -> tuple[str, int]:
    raw = False
    if source.startswith("r'", index):
        raw = True
        index += 1
    if index >= len(source) or source[index] != "'":
        raise ValueError(f"expected Dart string at {index}")
    index += 1
    chars: list[str] = []
    while index < len(source):
        char = source[index]
        if char == "'":
            return "".join(chars), index + 1
        if char == "\\" and not raw:
            index += 1
            if index >= len(source):
                raise ValueError("unterminated escape")
            escaped = source[index]
            chars.append({"n": "\n", "r": "\r", "t": "\t"}.get(escaped, escaped))
            index += 1
            continue
        chars.append(char)
        index += 1
    raise ValueError("unterminated Dart string")


def parse_map(source: str, marker: str) -> list[tuple[str, str]]:
    marker_index = source.index(marker)
    start = source.index("{", marker_index) + 1
    end = source.find("\n};", start)
    if end < 0:
        end = source.find("\n  };", start)
    if end < 0:
        raise ValueError(f"map closing brace not found after {marker!r}")
    body = source[start:end]
    result: list[tuple[str, str]] = []
    index = 0
    while True:
        index = skip(body, index)
        if index >= len(body):
            break
        if body.startswith("...", index):
            raise ValueError("spread maps cannot be parsed as source maps")
        key, index = dart_string(body, index)
        index = skip(body, index)
        if index >= len(body) or body[index] != ":":
            raise ValueError(f"expected ':' after {key!r}")
        index = skip(body, index + 1)
        parts: list[str] = []
        while index < len(body) and (body[index] == "'" or body.startswith("r'", index)):
            part, index = dart_string(body, index)
            parts.append(part)
            index = skip(body, index)
        if index >= len(body) or body[index] != ",":
            raise ValueError(f"expected ',' after {key!r}")
        result.append((key, "".join(parts)))
        index += 1
    return result


def english_pairs() -> list[tuple[str, str]]:
    return parse_map(
        I18N.read_text(encoding="utf-8"),
        "static const Map<String, String> _english",
    )


def russian_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanRussian\w+)", source)
        if marker is None:
            raise SystemExit(f"Russian map marker missing: {path.relative_to(ROOT)}")
        result.extend(parse_map(source, marker.group(0)))
    return result


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    count = text.count(old)
    if count != 1:
        raise SystemExit(
            f"Expected one integration target in {path.relative_to(ROOT)}: {old[:140]!r}; found {count}"
        )
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_all(path: Path, old: str, new: str, count: int) -> None:
    text = path.read_text(encoding="utf-8")
    if text.count(new) == count:
        return
    found = text.count(old)
    if found != count:
        raise SystemExit(
            f"Expected {count} integration targets in {path.relative_to(ROOT)}: {old[:120]!r}; found {found}"
        )
    path.write_text(text.replace(old, new), encoding="utf-8")



def integrate_runtime() -> None:
    replace_once(
        I18N,
        "import 'mizan_el_dynamic.dart';",
        "import 'mizan_el_dynamic.dart';\nimport 'mizan_ru.dart';\nimport 'mizan_ru_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'};",
    )
    replace_once(
        I18N,
        "  static bool get isGreek => _languageTag == 'el';\n",
        "  static bool get isGreek => _languageTag == 'el';\n  static bool get isRussian => _languageTag == 'ru';\n",
    )
    replace_once(
        I18N,
        "    'el' => 'ΕΠΙΒΕΒΑΙΩΝΩ',\n",
        "    'el' => 'ΕΠΙΒΕΒΑΙΩΝΩ',\n    'ru' => 'ПОДТВЕРЖДАЮ',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'el' || normalized.startsWith('el-')) return 'el';\n",
        "    if (normalized == 'el' || normalized.startsWith('el-')) return 'el';\n    if (normalized == 'ru' || normalized.startsWith('ru-')) return 'ru';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'el' ||\n        normalized.startsWith('el-');\n",
        "        normalized == 'el' ||\n        normalized.startsWith('el-') ||\n        normalized == 'ru' ||\n        normalized.startsWith('ru-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanGreek[visibleSource] ??
          translateGreekReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'el'),
          );
    }
""",
        """    } else if (effective == 'el') {
      result =
          mizanGreek[visibleSource] ??
          translateGreekReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'el'),
          );
    } else {
      result =
          mizanRussian[visibleSource] ??
          translateRussianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ru'),
          );
    }
""",
    )
    main = LIB / "main.dart"
    replace_once(
        main,
        "          'el' => const Locale('el', 'GR'),\n",
        "          'el' => const Locale('el', 'GR'),\n          'ru' => const Locale('ru', 'RU'),\n",
    )
    replace_once(
        main,
        "          Locale('el', 'GR'),\n",
        "          Locale('el', 'GR'),\n          Locale('ru', 'RU'),\n",
    )


def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(path, "    required this.nameEl,\n", "    required this.nameEl,\n    required this.nameRu,\n", 3)
    replace_all(path, "  final String nameEl;\n", "  final String nameEl;\n  final String nameRu;\n", 3)
    replace_all(
        path,
        "    nameEl: json['nameEl']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameEl: json['nameEl']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameRu: json['nameRu']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(path, "    'el' => nameEl,\n", "    'el' => nameEl,\n    'ru' => nameRu,\n", 3)
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nativeName'",
    )
    replace_once(path, "      nameEl,\n      ...symbols,", "      nameEl,\n      nameRu,\n      ...symbols,")


def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        """  if (MizanI18n.isGreek) {
    if (code == 'EUR') return '$amount\\u00A0€';
    return '$amount\\u00A0$code';
  }
""",
        """  if (MizanI18n.isGreek) {
    if (code == 'EUR') return '$amount\\u00A0€';
    return '$amount\\u00A0$code';
  }
  if (MizanI18n.isRussian) {
    if (code == 'RUB') return '$amount\\u00A0₽';
    return '$amount\\u00A0$code';
  }
""",
    )
    replace_once(
        path,
        "  if (MizanI18n.isPolish || MizanI18n.isRomanian || MizanI18n.isGreek) {\n",
        "  if (MizanI18n.isPolish || MizanI18n.isRomanian || MizanI18n.isGreek || MizanI18n.isRussian) {\n",
    )
    replace_once(
        path,
        "          (MizanI18n.isRomanian || MizanI18n.isGreek) ? '.' : '\\u202F',\n",
        "          (MizanI18n.isRomanian || MizanI18n.isGreek) ? '.' : '\\u00A0',\n",
    )
    replace_once(
        path,
        """  const elMonths = [
    'Ιαν',
    'Φεβ',
    'Μαρ',
    'Απρ',
    'Μαΐ',
    'Ιουν',
    'Ιουλ',
    'Αυγ',
    'Σεπ',
    'Οκτ',
    'Νοε',
    'Δεκ',
  ];
""",
        """  const elMonths = [
    'Ιαν',
    'Φεβ',
    'Μαρ',
    'Απρ',
    'Μαΐ',
    'Ιουν',
    'Ιουλ',
    'Αυγ',
    'Σεπ',
    'Οκτ',
    'Νοε',
    'Δεκ',
  ];
  const ruMonths = [
    'янв.',
    'февр.',
    'мар.',
    'апр.',
    'мая',
    'июн.',
    'июл.',
    'авг.',
    'сент.',
    'окт.',
    'нояб.',
    'дек.',
  ];
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isGreek) {
    return '${value.day} ${elMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isGreek) {
    return '${value.day} ${elMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isRussian) {
    return '${value.day} ${ruMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        path,
        """  const elMonths = [
    'Ιανουάριος',
    'Φεβρουάριος',
    'Μάρτιος',
    'Απρίλιος',
    'Μάιος',
    'Ιούνιος',
    'Ιούλιος',
    'Αύγουστος',
    'Σεπτέμβριος',
    'Οκτώβριος',
    'Νοέμβριος',
    'Δεκέμβριος',
  ];
""",
        """  const elMonths = [
    'Ιανουάριος',
    'Φεβρουάριος',
    'Μάρτιος',
    'Απρίλιος',
    'Μάιος',
    'Ιούνιος',
    'Ιούλιος',
    'Αύγουστος',
    'Σεπτέμβριος',
    'Οκτώβριος',
    'Νοέμβριος',
    'Δεκέμβριος',
  ];
  const ruMonths = [
    'январь',
    'февраль',
    'март',
    'апрель',
    'май',
    'июнь',
    'июль',
    'август',
    'сентябрь',
    'октябрь',
    'ноябрь',
    'декабрь',
  ];
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isGreek) {
    return '${elMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isGreek) {
    return '${elMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isRussian) {
    return '${ruMonths[value.month - 1]} ${value.year}';
  }
""",
    )


def normal(value: str) -> str:
    text = unicodedata.normalize("NFKD", value.casefold())
    return "".join(char for char in text if not unicodedata.combining(char))


def load_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, payload: dict[str, object]) -> None:
    path.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")


def build_catalogs() -> None:
    from babel import Locale
    locale = Locale.parse("ru_RU")
    language_overrides = {
        "pt-BR": "Португальский (Бразилия)",
        "pt-PT": "Португальский (Португалия)",
        "fil": "Филиппинский",
        "ru": "Русский",
    }
    country_overrides = {
        "CD": "Демократическая Республика Конго",
        "CG": "Республика Конго",
        "CI": "Кот-д’Ивуар",
        "CV": "Кабо-Верде",
        "CZ": "Чехия",
        "KR": "Южная Корея",
        "KP": "Северная Корея",
        "PS": "Палестина",
        "ST": "Сан-Томе и Принсипи",
        "TL": "Восточный Тимор",
        "TR": "Турция",
        "VA": "Ватикан",
        "RU": "Россия",
    }
    currency_overrides = {
        "BRL": "бразильский реал",
        "EUR": "евро",
        "GBP": "фунт стерлингов",
        "RON": "румынский лей",
        "RUB": "российский рубль",
        "TRY": "турецкая лира",
        "USD": "доллар США",
        "CVE": "эскудо Кабо-Верде",
        "MZN": "мозамбикский метикал",
        "STN": "добра Сан-Томе и Принсипи",
        "XAF": "франк КФА BEAC",
        "XCD": "восточно-карибский доллар",
        "XCG": "карибский гульден",
        "XOF": "франк КФА BCEAO",
        "XPF": "франк КФП",
        "ZWG": "зимбабвийское золото",
    }
    languages_path = ROOT / "assets/data/languages_v1.json"
    languages = load_json(languages_path)
    for item in languages["items"]:
        code = str(item["code"]); base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name: raise SystemExit(f"Missing Russian language name for {code}")
        item["nameRu"] = name
    save_json(languages_path, languages)
    countries_path = ROOT / "assets/data/countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name: raise SystemExit(f"Missing Russian country name for {code}")
        item["nameRu"] = name
    save_json(countries_path, countries)
    currencies_path = ROOT / "assets/data/currencies_v1.json"
    currencies = load_json(currencies_path)
    common_aliases = {
        "USD": ("доллар", "доллары", "доллар сша", "американский доллар", "dollar", "dollar usa"),
        "EUR": ("евро", "euro"),
        "GBP": ("британский фунт", "фунт стерлингов", "стерлинг", "pound"),
        "RON": ("лей", "румынский лей", "leu"),
        "TRY": ("турецкая лира", "турецкие лиры", "лира", "lira"),
        "CHF": ("швейцарский франк", "frank"),
        "PLN": ("польский злотый", "злотый", "zloty"),
        "JPY": ("японская иена", "иена", "yen"),
        "CNY": ("китайский юань", "юань", "yuan"),
        "RUB": ("российский рубль", "рубль", "рубли", "руб", "rubl", "ruble", "rouble"),
        "AED": ("дирхам оаэ", "дирхам объединённых арабских эмиратов", "dirham"),
    }
    for item in currencies["items"]:
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name: raise SystemExit(f"Missing Russian currency name for {code}")
        item["nameRu"] = name
        aliases = item.setdefault("aliases", [])
        for alias in (name, name.casefold(), normal(name), *common_aliases.get(code, ())):
            if alias and alias not in aliases: aliases.append(alias)
    save_json(currencies_path, currencies)


def update_regressions() -> None:
    old_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'}"
    new_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'}"
    old_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'}"
    new_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'}"
    old_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'};"
    new_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'};"
    for root in (ROOT / "test", ROOT / "tools"):
        for path in root.rglob("*"):
            if path.suffix not in {".dart", ".py"} or path == Path(__file__):
                continue
            text = path.read_text(encoding="utf-8")
            changed = text.replace(old_plain, new_plain).replace(old_typed, new_typed).replace(old_runtime, new_runtime)
            if changed != text: path.write_text(changed, encoding="utf-8")
    for filename in ("english_localization_test.dart", "portuguese_br_localization_test.dart",
                     "spanish_localization_test.dart", "italian_final_head_test.dart"):
        path = ROOT / "test" / filename
        text = path.read_text(encoding="utf-8")
        text = text.replace("      'el',\n    });", "      'el',\n      'ru',\n    });")
        anchor = "    expect(MizanI18n.normalizeLanguageTag('el_GR'), 'el');\n"
        assertions = (
            "    expect(MizanI18n.isSupported('ru'), isTrue);\n"
            "    expect(MizanI18n.isSupported('ru-RU'), isTrue);\n"
            "    expect(MizanI18n.normalizeLanguageTag('ru_RU'), 'ru');\n"
        )
        if anchor in text and assertions not in text: text = text.replace(anchor, anchor + assertions, 1)
        text = text.replace("final Greek head exposes the complete twelve-language runtime",
                            "final Russian head exposes the complete thirteen-language runtime")
        text = text.replace("after Greek integration", "after Russian integration")
        path.write_text(text, encoding="utf-8")


def verify() -> None:
    english = english_pairs(); russian = russian_pairs()
    english_keys = [key for key, _ in english]; russian_keys = [key for key, _ in russian]
    failures: list[str] = []
    if len(english) != 791: failures.append(f"English reference map changed: {len(english)} keys")
    if len(russian) != 791: failures.append(f"Russian map must contain 791 values, found {len(russian)}")
    duplicates = sorted({key for key in russian_keys if russian_keys.count(key) > 1})
    if duplicates: failures.append(f"Duplicate Russian keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(russian_keys)); extra = sorted(set(russian_keys) - set(english_keys))
    if missing or extra: failures.append(f"Russian/English key mismatch; missing={missing[:30]}, extra={extra[:30]}")
    values = dict(russian)
    required_terms = {
        "Ana sayfa": "Главная", "Kayıtlar": "Записи", "Giderler": "Расходы",
        "Raporlar": "Отчеты", "Ayarlar": "Настройки", "Kredi kartı": "Кредитная карта",
        "Ev kredisi": "Ипотека", "Çek": "Банковский чек", "Senet": "Вексель",
        "Son ödeme tarihi": "Срок оплаты", "Gecikmede": "Просрочено",
        "Fatura": "Счет", "Gelir": "Доход", "Gider": "Расход",
        "Ödeme": "Платёж", "ONAYLIYORUM": "ПОДТВЕРЖДАЮ",
    }
    for key, expected in required_terms.items():
        if values.get(key) != expected:
            failures.append(f"Native Russian terminology mismatch for {key!r}: {values.get(key)!r}")
    i18n = I18N.read_text(encoding="utf-8")
    for marker in ("'ru'", "static bool get isRussian", "mizanRussian[visibleSource]",
                   "translateRussianReviewedDynamic(", "'ru' => 'ПОДТВЕРЖДАЮ'",
                   "normalized.startsWith('ru-')"):
        if marker not in i18n: failures.append(f"Missing Russian runtime marker: {marker}")
    main = (LIB / "main.dart").read_text(encoding="utf-8")
    for marker in ("'ru' => const Locale('ru', 'RU')", "Locale('ru', 'RU')"):
        if marker not in main: failures.append(f"Missing Russian Flutter locale marker: {marker}")
    dynamic = RUSSIAN_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("Осталось ${_days(value)}", "открытые записи", "_people(m[1]!)"):
        if marker not in dynamic: failures.append(f"Missing Russian dynamic grammar marker: {marker}")
    formatter = (LIB / "core/formatters.dart").read_text(encoding="utf-8")
    for marker in ("MizanI18n.isRussian", "'$amount\\u00A0₽'", "'март'", "'мар.'"):
        if marker not in formatter: failures.append(f"Missing Russian formatting marker: {marker}")
    catalog_model = (LIB / "global/global_catalog.dart").read_text(encoding="utf-8")
    if catalog_model.count("nameRu") < 15: failures.append("Russian catalog model fields are incomplete")
    for filename, expected_count in (("languages_v1.json", 29), ("countries_v1.json", 161), ("currencies_v1.json", 154)):
        payload = load_json(ROOT / "assets/data" / filename); items = payload.get("items", [])
        if len(items) != expected_count: failures.append(f"{filename} item count changed: {len(items)}")
        missing_names = [str(item.get("code")) for item in items if not item.get("nameRu")]
        if missing_names: failures.append(f"{filename} missing nameRu: {missing_names[:20]}")
    if failures: raise SystemExit("\n".join(failures))
    print(f"Russian locale verified: {len(russian)} static values, 29 languages, 161 countries, 154 currencies.")


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
