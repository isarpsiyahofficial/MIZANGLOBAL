#!/usr/bin/env python3
"""Build and verify the reviewed Italy-oriented Italian locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
ITALIAN = LIB / "l10n" / "mizan_it.dart"
ITALIAN_DYNAMIC = LIB / "l10n" / "mizan_it_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "it").glob("mizan_it_*.dart")))
CONTRACT = ROOT / "tools" / "italian_native_terms.json"


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


def italian_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanItalian\w+)", source)
        if marker is None:
            raise SystemExit(f"Italian map marker missing: {path.relative_to(ROOT)}")
        result.extend(parse_map(source, marker.group(0)))
    return result


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    if text.count(old) != 1:
        raise SystemExit(
            f"Expected one integration target in {path.relative_to(ROOT)}: {old[:120]!r}"
        )
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_all(path: Path, old: str, new: str, count: int) -> None:
    text = path.read_text(encoding="utf-8")
    if text.count(new) == count:
        return
    if text.count(old) != count:
        raise SystemExit(
            f"Expected {count} integration targets in {path.relative_to(ROOT)}, "
            f"found {text.count(old)}"
        )
    path.write_text(text.replace(old, new), encoding="utf-8")


def integrate_runtime() -> None:
    replace_once(
        I18N,
        "import 'mizan_de_dynamic.dart';",
        "import 'mizan_de_dynamic.dart';\nimport 'mizan_it.dart';\nimport 'mizan_it_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it'};",
    )
    replace_once(
        I18N,
        "  static bool get isGerman => _languageTag == 'de';\n",
        "  static bool get isGerman => _languageTag == 'de';\n  static bool get isItalian => _languageTag == 'it';\n",
    )
    replace_once(
        I18N,
        "    'de' => 'ICH BESTÄTIGE',\n",
        "    'de' => 'ICH BESTÄTIGE',\n    'it' => 'CONFERMO',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'de' || normalized.startsWith('de-')) return 'de';\n",
        "    if (normalized == 'de' || normalized.startsWith('de-')) return 'de';\n    if (normalized == 'it' || normalized.startsWith('it-')) return 'it';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'de' ||\n        normalized.startsWith('de-');\n",
        "        normalized == 'de' ||\n        normalized.startsWith('de-') ||\n        normalized == 'it' ||\n        normalized.startsWith('it-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanGerman[visibleSource] ??
          translateGermanReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'de'),
          );
    }
""",
        """    } else if (effective == 'de') {
      result =
          mizanGerman[visibleSource] ??
          translateGermanReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'de'),
          );
    } else {
      result =
          mizanItalian[visibleSource] ??
          translateItalianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'it'),
          );
    }
""",
    )

    main = LIB / "main.dart"
    replace_once(
        main,
        "          'de' => const Locale('de', 'DE'),\n",
        "          'de' => const Locale('de', 'DE'),\n          'it' => const Locale('it', 'IT'),\n",
    )
    replace_once(
        main,
        "          Locale('de', 'DE'),\n",
        "          Locale('de', 'DE'),\n          Locale('it', 'IT'),\n",
    )


def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(
        path,
        "    required this.nameDe,\n",
        "    required this.nameDe,\n    required this.nameIt,\n",
        3,
    )
    replace_all(
        path,
        "  final String nameDe;\n",
        "  final String nameDe;\n  final String nameIt;\n",
        3,
    )
    replace_all(
        path,
        "    nameDe: json['nameDe']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameDe: json['nameDe']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameIt: json['nameIt']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(
        path,
        "    'de' => nameDe,\n",
        "    'de' => nameDe,\n    'it' => nameIt,\n",
        3,
    )
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nativeName'",
    )
    replace_once(
        path,
        "      nameDe,\n      ...symbols,",
        "      nameDe,\n      nameIt,\n      ...symbols,",
    )


def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        """  if (MizanI18n.isFrench || MizanI18n.isGerman) {
    return code == 'EUR' ? '$amount\\u00A0€' : '$amount\\u00A0$code';
  }
""",
        """  if (MizanI18n.isFrench || MizanI18n.isGerman || MizanI18n.isItalian) {
    return code == 'EUR' ? '$amount\\u00A0€' : '$amount\\u00A0$code';
  }
""",
    )
    replace_once(
        path,
        """  const deMonths = [
    'Jan.',
    'Feb.',
    'März',
    'Apr.',
    'Mai',
    'Juni',
    'Juli',
    'Aug.',
    'Sept.',
    'Okt.',
    'Nov.',
    'Dez.',
  ];
""",
        """  const deMonths = [
    'Jan.',
    'Feb.',
    'März',
    'Apr.',
    'Mai',
    'Juni',
    'Juli',
    'Aug.',
    'Sept.',
    'Okt.',
    'Nov.',
    'Dez.',
  ];
  const itMonths = [
    'gen',
    'feb',
    'mar',
    'apr',
    'mag',
    'giu',
    'lug',
    'ago',
    'set',
    'ott',
    'nov',
    'dic',
  ];
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isGerman) {
    return '${value.day}. ${deMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isGerman) {
    return '${value.day}. ${deMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isItalian) {
    return '${value.day} ${itMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        path,
        """  const deMonths = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
""",
        """  const deMonths = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  const itMonths = [
    'gennaio',
    'febbraio',
    'marzo',
    'aprile',
    'maggio',
    'giugno',
    'luglio',
    'agosto',
    'settembre',
    'ottobre',
    'novembre',
    'dicembre',
  ];
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isGerman) {
    return '${deMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isGerman) {
    return '${deMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isItalian) {
    return '${itMonths[value.month - 1]} ${value.year}';
  }
""",
    )


def normal(value: str) -> str:
    text = unicodedata.normalize("NFKD", value.casefold())
    return "".join(char for char in text if not unicodedata.combining(char))


def load_json(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, payload: dict[str, object]) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )


def build_catalogs() -> None:
    from babel import Locale

    locale = Locale.parse("it_IT")
    language_overrides = {
        "pt-BR": "portoghese (Brasile)",
        "pt-PT": "portoghese (Portogallo)",
        "fil": "filippino",
        "it": "italiano",
    }
    country_overrides = {
        "CI": "Costa d’Ivoire",
        "CD": "Repubblica Democratica del Congo",
        "CG": "Repubblica del Congo",
        "CV": "Capo Verde",
        "CZ": "Cechia",
        "KR": "Corea del Sud",
        "KP": "Corea del Nord",
        "PS": "Territori palestinesi",
        "ST": "São Tomé e Príncipe",
        "TL": "Timor Est",
        "TR": "Turchia",
        "VA": "Città del Vaticano",
    }
    currency_overrides = {
        "BRL": "real brasiliano",
        "EUR": "euro",
        "GBP": "sterlina britannica",
        "TRY": "lira turca",
        "USD": "dollaro statunitense",
        "CVE": "escudo capoverdiano",
        "MZN": "metical mozambicano",
        "STN": "dobra di São Tomé e Príncipe",
        "XAF": "franco CFA (BEAC)",
        "XCD": "dollaro dei Caraibi orientali",
        "XCG": "fiorino caraibico",
        "XOF": "franco CFA (BCEAO)",
        "XPF": "franco CFP",
        "ZWG": "Zimbabwe Gold",
    }

    languages_path = ROOT / "assets" / "data" / "languages_v1.json"
    languages = load_json(languages_path)
    for item in languages["items"]:  # type: ignore[index]
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing Italian language name for {code}")
        item["nameIt"] = name
    save_json(languages_path, languages)

    countries_path = ROOT / "assets" / "data" / "countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Italian country name for {code}")
        item["nameIt"] = name
    save_json(countries_path, countries)

    currencies_path = ROOT / "assets" / "data" / "currencies_v1.json"
    currencies = load_json(currencies_path)
    for item in currencies["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Italian currency name for {code}")
        item["nameIt"] = name
        aliases = item.setdefault("aliases", [])
        common_aliases = {
            "USD": (
                "dollaro americano",
                "dollaro USA",
                "dollaro statunitense",
                "US dollar",
            ),
            "EUR": ("euro", "moneta europea"),
            "GBP": ("sterlina", "sterlina britannica", "pound sterling"),
            "TRY": ("lira turca", "lire turche"),
            "CHF": ("franco svizzero",),
        }
        for alias in (
            name,
            name.casefold(),
            normal(name),
            *common_aliases.get(code, ()),
        ):
            if alias and alias not in aliases:
                aliases.append(alias)
    save_json(currencies_path, currencies)


def update_regressions() -> None:
    old_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de'}"
    new_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it'}"
    old_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de'}"
    new_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it'}"
    for root in (ROOT / "test", ROOT / "tools"):
        for path in root.rglob("*"):
            if path.suffix not in {".dart", ".py"} or path == Path(__file__):
                continue
            text = path.read_text(encoding="utf-8")
            text = text.replace(old_plain, new_plain).replace(old_typed, new_typed)
            path.write_text(text, encoding="utf-8")


def verify() -> None:
    english = english_pairs()
    italian = italian_pairs()
    english_keys = [key for key, _ in english]
    italian_keys = [key for key, _ in italian]
    failures: list[str] = []

    if len(english) != 791:
        failures.append(f"English reference map changed: {len(english)} keys")
    if len(italian) != 791:
        failures.append(f"Italian map must contain 791 values, found {len(italian)}")
    duplicates = sorted({key for key in italian_keys if italian_keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate Italian keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(italian_keys))
    extra = sorted(set(italian_keys) - set(english_keys))
    if missing or extra:
        failures.append(
            f"Italian/English key mismatch; missing={missing[:20]}, extra={extra[:20]}"
        )

    values = dict(italian)
    contract = load_json(CONTRACT)
    for key, expected in contract["requiredTerms"].items():  # type: ignore[index]
        if values.get(key) != expected:
            failures.append(
                f"Native Italian terminology mismatch for {key!r}: {values.get(key)!r}"
            )

    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'it'",
        "static bool get isItalian",
        "mizanItalian[visibleSource]",
        "translateItalianReviewedDynamic(",
        "'it' => 'CONFERMO'",
    ):
        if marker not in i18n:
            failures.append(f"Missing Italian runtime marker: {marker}")
    dynamic = ITALIAN_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("Manca 1 giorno", "registrazioni", "selezionate", "CONFERMO"):
        if marker not in dynamic and marker != "CONFERMO":
            failures.append(f"Missing Italian dynamic grammar marker: {marker}")

    for filename, expected_count in (
        ("languages_v1.json", 29),
        ("countries_v1.json", 161),
        ("currencies_v1.json", 154),
    ):
        payload = load_json(ROOT / "assets" / "data" / filename)
        items = payload["items"]  # type: ignore[index]
        if payload.get("count") != expected_count or len(items) != expected_count:
            failures.append(f"Unexpected catalog size: {filename}")
        missing_names = [
            item.get("code") for item in items if not str(item.get("nameIt", "")).strip()
        ]
        if missing_names:
            failures.append(f"Missing nameIt in {filename}: {missing_names[:20]}")

    if failures:
        print("Italian localization verification failed:")
        for failure in failures:
            print(f"- {failure}")
        raise SystemExit(1)
    print(
        "Italian verification passed: 791/791 static values, dynamic grammar, runtime and catalogs"
    )


def build() -> None:
    english = english_pairs()
    italian = italian_pairs()
    if len(english) != 791 or len(italian) != 791:
        missing = sorted(set(key for key, _ in english) - set(key for key, _ in italian))
        extra = sorted(set(key for key, _ in italian) - set(key for key, _ in english))
        raise SystemExit(
            f"Pre-integration key counts invalid: English={len(english)}, Italian={len(italian)}; "
            f"missing={missing[:30]}, extra={extra[:30]}"
        )
    integrate_runtime()
    integrate_catalog_model()
    integrate_formatters()
    build_catalogs()
    update_regressions()
    verify()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    if args.verify:
        verify()
    else:
        build()


if __name__ == "__main__":
    main()
