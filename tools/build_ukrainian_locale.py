#!/usr/bin/env python3
"""Build, integrate and verify the reviewed Ukraine-oriented Ukrainian locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
UKRAINIAN = LIB / "l10n" / "mizan_uk.dart"
UKRAINIAN_DYNAMIC = LIB / "l10n" / "mizan_uk_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "uk").glob("mizan_uk_*.dart")))


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


def ukrainian_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanUkrainian\w+)", source)
        if marker is None:
            raise SystemExit(f"Ukrainian map marker missing: {path.relative_to(ROOT)}")
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
        "import 'mizan_ru_dynamic.dart';",
        "import 'mizan_ru_dynamic.dart';\nimport 'mizan_uk.dart';\nimport 'mizan_uk_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'};",
    )
    replace_once(
        I18N,
        "  static bool get isRussian => _languageTag == 'ru';\n",
        "  static bool get isRussian => _languageTag == 'ru';\n  static bool get isUkrainian => _languageTag == 'uk';\n",
    )
    replace_once(
        I18N,
        "    'ru' => 'ПОДТВЕРЖДАЮ',\n",
        "    'ru' => 'ПОДТВЕРЖДАЮ',\n    'uk' => 'ПІДТВЕРДЖУЮ',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'ru' || normalized.startsWith('ru-')) return 'ru';\n",
        "    if (normalized == 'ru' || normalized.startsWith('ru-')) return 'ru';\n    if (normalized == 'uk' || normalized.startsWith('uk-')) return 'uk';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'ru' ||\n        normalized.startsWith('ru-');\n",
        "        normalized == 'ru' ||\n        normalized.startsWith('ru-') ||\n        normalized == 'uk' ||\n        normalized.startsWith('uk-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanRussian[visibleSource] ??
          translateRussianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ru'),
          );
    }
""",
        """    } else if (effective == 'ru') {
      result =
          mizanRussian[visibleSource] ??
          translateRussianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ru'),
          );
    } else {
      result =
          mizanUkrainian[visibleSource] ??
          translateUkrainianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'uk'),
          );
    }
""",
    )
    main = LIB / "main.dart"
    replace_once(
        main,
        "          'ru' => const Locale('ru', 'RU'),\n",
        "          'ru' => const Locale('ru', 'RU'),\n          'uk' => const Locale('uk', 'UA'),\n",
    )
    replace_once(
        main,
        "          Locale('ru', 'RU'),\n",
        "          Locale('ru', 'RU'),\n          Locale('uk', 'UA'),\n",
    )


def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(path, "    required this.nameRu,\n", "    required this.nameRu,\n    required this.nameUk,\n", 3)
    replace_all(path, "  final String nameRu;\n", "  final String nameRu;\n  final String nameUk;\n", 3)
    replace_all(
        path,
        "    nameRu: json['nameRu']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameRu: json['nameRu']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameUk: json['nameUk']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(path, "    'ru' => nameRu,\n", "    'ru' => nameRu,\n    'uk' => nameUk,\n", 3)
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nameRu $nameUk $nativeName'",
    )
    replace_once(path, "      nameRu,\n      ...symbols,", "      nameRu,\n      nameUk,\n      ...symbols,")


def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        """            : (MizanI18n.isRussian
                  ? '\\u00A0'
                  : (MizanI18n.isPortuguesePt ? ' ' : '.')));""",
        """            : ((MizanI18n.isRussian || MizanI18n.isUkrainian)
                  ? '\\u00A0'
                  : (MizanI18n.isPortuguesePt ? ' ' : '.')));""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isRussian) {
    if (code == 'RUB') return '$amount\\u00A0₽';
    return '$amount\\u00A0$code';
  }
""",
        """  if (MizanI18n.isRussian) {
    if (code == 'RUB') return '$amount\\u00A0₽';
    return '$amount\\u00A0$code';
  }
  if (MizanI18n.isUkrainian) {
    if (code == 'UAH') return '$amount\\u00A0₴';
    return '$amount\\u00A0$code';
  }
""",
    )
    replace_once(
        path,
        "  if (MizanI18n.isPolish || MizanI18n.isRomanian || MizanI18n.isGreek || MizanI18n.isRussian) {\n",
        "  if (MizanI18n.isPolish || MizanI18n.isRomanian || MizanI18n.isGreek || MizanI18n.isRussian || MizanI18n.isUkrainian) {\n",
    )
    replace_once(
        path,
        """  const ruMonths = [
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
        """  const ruMonths = [
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
  const ukMonths = [
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
    )
    replace_once(
        path,
        """  if (MizanI18n.isRussian) {
    return '${value.day} ${ruMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isRussian) {
    return '${value.day} ${ruMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isUkrainian) {
    return '${value.day} ${ukMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        path,
        """  const ruMonths = [
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
        """  const ruMonths = [
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
  const ukMonths = [
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
    )
    replace_once(
        path,
        """  if (MizanI18n.isRussian) {
    return '${ruMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isRussian) {
    return '${ruMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isUkrainian) {
    return '${ukMonths[value.month - 1]} ${value.year}';
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

    locale = Locale.parse("uk_UA")
    language_overrides = {
        "pt-BR": "португальська (Бразилія)",
        "pt-PT": "португальська (Португалія)",
        "fil": "філіппінська",
        "uk": "Українська",
    }
    country_overrides = {
        "CD": "Демократична Республіка Конго",
        "CG": "Республіка Конго",
        "CI": "Кот-д’Івуар",
        "CV": "Кабо-Верде",
        "CZ": "Чехія",
        "KR": "Південна Корея",
        "KP": "Північна Корея",
        "PS": "Палестина",
        "ST": "Сан-Томе і Принсіпі",
        "TL": "Східний Тимор",
        "TR": "Туреччина",
        "UA": "Україна",
        "VA": "Ватикан",
    }
    currency_overrides = {
        "BRL": "бразильський реал",
        "EUR": "євро",
        "GBP": "фунт стерлінгів",
        "RON": "румунський лей",
        "RUB": "російський рубль",
        "TRY": "турецька ліра",
        "UAH": "українська гривня",
        "USD": "долар США",
        "CVE": "ескудо Кабо-Верде",
        "MZN": "мозамбіцький метикал",
        "STN": "добра Сан-Томе і Принсіпі",
        "XAF": "франк КФА BEAC",
        "XCD": "східнокарибський долар",
        "XCG": "карибський гульден",
        "XOF": "франк КФА BCEAO",
        "XPF": "франк CFP",
        "ZWG": "зімбабвійське золото",
    }
    languages_path = ROOT / "assets/data/languages_v1.json"
    languages = load_json(languages_path)
    for item in languages["items"]:
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing Ukrainian language name for {code}")
        item["nameUk"] = name
    save_json(languages_path, languages)

    countries_path = ROOT / "assets/data/countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Ukrainian country name for {code}")
        item["nameUk"] = name
    save_json(countries_path, countries)

    currencies_path = ROOT / "assets/data/currencies_v1.json"
    currencies = load_json(currencies_path)
    common_aliases = {
        "USD": ("долар", "долари", "долар сша", "американський долар", "dollar", "dolar"),
        "EUR": ("євро", "euro"),
        "GBP": ("британський фунт", "фунт стерлінгів", "стерлінг", "pound"),
        "RON": ("лей", "румунський лей", "leu"),
        "TRY": ("турецька ліра", "ліра", "lira"),
        "CHF": ("швейцарський франк", "franc", "frank"),
        "PLN": ("польський злотий", "злотий", "zloty"),
        "JPY": ("японська єна", "єна", "yen"),
        "CNY": ("китайський юань", "юань", "yuan"),
        "RUB": ("російський рубль", "рубль", "рублі", "руб", "rubl", "ruble", "rouble"),
        "UAH": ("українська гривня", "гривня", "гривні", "гривень", "грн", "hryvnia", "gryvnia"),
        "AED": ("дирхам оае", "дирхам об’єднаних арабських еміратів", "dirham"),
    }
    for item in currencies["items"]:
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Ukrainian currency name for {code}")
        item["nameUk"] = name
        aliases = item.setdefault("aliases", [])
        for alias in (name, name.casefold(), normal(name), *common_aliases.get(code, ())):
            if alias and alias not in aliases:
                aliases.append(alias)
    save_json(currencies_path, currencies)


def update_regressions() -> None:
    old_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru'}"
    new_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'}"
    old_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru'}"
    new_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'}"
    old_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru'};"
    new_runtime = "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'};"
    for root in (ROOT / "test", ROOT / "tools"):
        for path in root.rglob("*"):
            if path.suffix not in {".dart", ".py"} or path == Path(__file__):
                continue
            text = path.read_text(encoding="utf-8")
            changed = text.replace(old_plain, new_plain).replace(old_typed, new_typed).replace(old_runtime, new_runtime)
            if changed != text:
                path.write_text(changed, encoding="utf-8")
    for filename in (
        "english_localization_test.dart",
        "portuguese_br_localization_test.dart",
        "spanish_localization_test.dart",
        "italian_final_head_test.dart",
    ):
        path = ROOT / "test" / filename
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        text = text.replace("      'ru',\n    });", "      'ru',\n      'uk',\n    });")
        if text != path.read_text(encoding="utf-8"):
            path.write_text(text, encoding="utf-8")


def verify() -> None:
    english = english_pairs()
    ukrainian = ukrainian_pairs()
    english_keys = [key for key, _ in english]
    ukrainian_keys = [key for key, _ in ukrainian]
    failures: list[str] = []
    if len(english) != 791:
        failures.append(f"English reference map changed: {len(english)} keys")
    if len(ukrainian) != 791:
        failures.append(f"Ukrainian map must contain 791 values, found {len(ukrainian)}")
    duplicates = sorted({key for key in ukrainian_keys if ukrainian_keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate Ukrainian keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(ukrainian_keys))
    extra = sorted(set(ukrainian_keys) - set(english_keys))
    if missing or extra:
        failures.append(f"Ukrainian/English key mismatch; missing={missing[:30]}, extra={extra[:30]}")
    values = dict(ukrainian)
    required_terms = {
        "Ana sayfa": "Головна",
        "Kayıtlar": "Записи",
        "Giderler": "Витрати",
        "Raporlar": "Звіти",
        "Ayarlar": "Налаштування",
        "Kredi kartı": "Кредитна картка",
        "Ev kredisi": "Іпотечний кредит",
        "Çek": "Банківський чек",
        "Senet": "Боргова розписка",
        "Son ödeme tarihi": "Строк оплати",
        "Gecikmede": "Прострочено",
        "Fatura": "Рахунок",
        "Gelir": "Дохід",
        "Gider": "Витрата",
        "Ödeme": "Платіж",
        "ONAYLIYORUM": "ПІДТВЕРДЖУЮ",
    }
    for key, expected in required_terms.items():
        if values.get(key) != expected:
            failures.append(f"Native Ukrainian terminology mismatch for {key!r}: {values.get(key)!r}")
    forbidden = re.compile(r"[ыэёъЫЭЁЪ]")
    leaked = [(key, value) for key, value in ukrainian if forbidden.search(value)]
    if leaked:
        failures.append(f"Russian-only letters leaked into Ukrainian: {leaked[:10]}")
    for banned in ("счёт", "отчёт", "платёж", "просрочено", "настройки", "уведомление"):
        hits = [(key, value) for key, value in ukrainian if banned in value.casefold()]
        if hits:
            failures.append(f"Russian terminology leaked ({banned}): {hits[:5]}")
    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'uk'",
        "static bool get isUkrainian",
        "mizanUkrainian[visibleSource]",
        "translateUkrainianReviewedDynamic(",
        "'uk' => 'ПІДТВЕРДЖУЮ'",
        "normalized.startsWith('uk-')",
    ):
        if marker not in i18n:
            failures.append(f"Missing Ukrainian runtime marker: {marker}")
    main = (LIB / "main.dart").read_text(encoding="utf-8")
    for marker in ("'uk' => const Locale('uk', 'UA')", "Locale('uk', 'UA')"):
        if marker not in main:
            failures.append(f"Missing Ukrainian Flutter locale marker: {marker}")
    dynamic = UKRAINIAN_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("Залишилося ${_days(value)}", "відкриті записи", "_selectedPeople(m[1]!)", "Тест буде заплановано приблизно"):
        if marker not in dynamic and marker not in "\n".join(values.values()):
            failures.append(f"Missing Ukrainian dynamic/runtime marker: {marker}")
    formatter = (LIB / "core/formatters.dart").read_text(encoding="utf-8")
    for marker in ("MizanI18n.isUkrainian", "'$amount\\u00A0₴'", "'березень'", "'бер.'"):
        if marker not in formatter:
            failures.append(f"Missing Ukrainian formatting marker: {marker}")
    catalog_model = (LIB / "global/global_catalog.dart").read_text(encoding="utf-8")
    if catalog_model.count("nameUk") < 15:
        failures.append("Ukrainian catalog model fields are incomplete")
    for filename, expected_count in (("languages_v1.json", 29), ("countries_v1.json", 161), ("currencies_v1.json", 154)):
        payload = load_json(ROOT / "assets/data" / filename)
        items = payload.get("items", [])
        if len(items) != expected_count:
            failures.append(f"{filename} item count changed: {len(items)}")
        missing_names = [str(item.get("code")) for item in items if not item.get("nameUk")]
        if missing_names:
            failures.append(f"{filename} missing nameUk: {missing_names[:20]}")
    if values.get("Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.", "").find("приблизне планування") < 0:
        failures.append("Ukrainian notification copy does not describe the inexact fallback")
    if failures:
        raise SystemExit("\n".join(failures))
    print(f"Ukrainian locale verified: {len(ukrainian)} static values, 29 languages, 161 countries, 154 currencies.")


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
