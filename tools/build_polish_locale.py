#!/usr/bin/env python3
"""Build, integrate and verify the reviewed Poland-oriented Polish locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
POLISH = LIB / "l10n" / "mizan_pl.dart"
POLISH_DYNAMIC = LIB / "l10n" / "mizan_pl_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "pl").glob("mizan_pl_*.dart")))


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


def polish_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanPolish\w+)", source)
        if marker is None:
            raise SystemExit(f"Polish map marker missing: {path.relative_to(ROOT)}")
        result.extend(parse_map(source, marker.group(0)))
    return result


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    if text.count(old) != 1:
        raise SystemExit(
            f"Expected one integration target in {path.relative_to(ROOT)}: {old[:120]!r}; found {text.count(old)}"
        )
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def replace_all(path: Path, old: str, new: str, count: int) -> None:
    text = path.read_text(encoding="utf-8")
    if text.count(new) == count:
        return
    if text.count(old) != count:
        raise SystemExit(
            f"Expected {count} integration targets in {path.relative_to(ROOT)}, found {text.count(old)}"
        )
    path.write_text(text.replace(old, new), encoding="utf-8")


def integrate_runtime() -> None:
    replace_once(
        I18N,
        "import 'mizan_nl_dynamic.dart';",
        "import 'mizan_nl_dynamic.dart';\nimport 'mizan_pl.dart';\nimport 'mizan_pl_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'};",
    )
    replace_once(
        I18N,
        "  static bool get isDutch => _languageTag == 'nl';\n",
        "  static bool get isDutch => _languageTag == 'nl';\n  static bool get isPolish => _languageTag == 'pl';\n",
    )
    replace_once(
        I18N,
        "    'nl' => 'IK BEVESTIG',\n",
        "    'nl' => 'IK BEVESTIG',\n    'pl' => 'POTWIERDZAM',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'nl' || normalized.startsWith('nl-')) return 'nl';\n",
        "    if (normalized == 'nl' || normalized.startsWith('nl-')) return 'nl';\n    if (normalized == 'pl' || normalized.startsWith('pl-')) return 'pl';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'nl' ||\n        normalized.startsWith('nl-');\n",
        "        normalized == 'nl' ||\n        normalized.startsWith('nl-') ||\n        normalized == 'pl' ||\n        normalized.startsWith('pl-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanDutch[visibleSource] ??
          translateDutchReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'nl'),
          );
    }
""",
        """    } else if (effective == 'nl') {
      result =
          mizanDutch[visibleSource] ??
          translateDutchReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'nl'),
          );
    } else {
      result =
          mizanPolish[visibleSource] ??
          translatePolishReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pl'),
          );
    }
""",
    )

    main = LIB / "main.dart"
    replace_once(
        main,
        "          'nl' => const Locale('nl', 'NL'),\n",
        "          'nl' => const Locale('nl', 'NL'),\n          'pl' => const Locale('pl', 'PL'),\n",
    )
    replace_once(
        main,
        "          Locale('nl', 'NL'),\n",
        "          Locale('nl', 'NL'),\n          Locale('pl', 'PL'),\n",
    )

def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(
        path,
        "    required this.nameNl,\n",
        "    required this.nameNl,\n    required this.namePl,\n",
        3,
    )
    replace_all(
        path,
        "  final String nameNl;\n",
        "  final String nameNl;\n  final String namePl;\n",
        3,
    )
    replace_all(
        path,
        "    nameNl: json['nameNl']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameNl: json['nameNl']?.toString() ?? json['nameEn']?.toString() ?? '',\n    namePl: json['namePl']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(
        path,
        "    'nl' => nameNl,\n",
        "    'nl' => nameNl,\n    'pl' => namePl,\n",
        3,
    )
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nativeName'",
    )
    replace_once(
        path,
        "      nameNl,\n      ...symbols,",
        "      nameNl,\n      namePl,\n      ...symbols,",
    )

def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        """  final groupSeparator = MizanI18n.isEnglish
      ? ','
      : (MizanI18n.isFrench
            ? '\\u202F'
            : (MizanI18n.isPortuguesePt ? ' ' : '.'));
""",
        """  final groupSeparator = MizanI18n.isEnglish
      ? ','
      : ((MizanI18n.isFrench || MizanI18n.isPolish)
            ? '\\u202F'
            : (MizanI18n.isPortuguesePt ? ' ' : '.'));
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isDutch) {
    return code == 'EUR' ? '€\\u00A0$amount' : '$code\\u00A0$amount';
  }
""",
        """  if (MizanI18n.isDutch) {
    return code == 'EUR' ? '€\\u00A0$amount' : '$code\\u00A0$amount';
  }
  if (MizanI18n.isPolish) {
    if (code == 'PLN') return '$amount\\u00A0zł';
    return '$amount\\u00A0$code';
  }
""",
    )
    replace_once(
        path,
        """  const nlMonths = [
    'jan',
    'feb',
    'mrt',
    'apr',
    'mei',
    'jun',
    'jul',
    'aug',
    'sep',
    'okt',
    'nov',
    'dec',
  ];
""",
        """  const nlMonths = [
    'jan',
    'feb',
    'mrt',
    'apr',
    'mei',
    'jun',
    'jul',
    'aug',
    'sep',
    'okt',
    'nov',
    'dec',
  ];
  const plMonths = [
    'sty',
    'lut',
    'mar',
    'kwi',
    'maj',
    'cze',
    'lip',
    'sie',
    'wrz',
    'paź',
    'lis',
    'gru',
  ];
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isDutch) {
    return '${value.day} ${nlMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isDutch) {
    return '${value.day} ${nlMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isPolish) {
    return '${value.day} ${plMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        path,
        """  const nlMonths = [
    'januari',
    'februari',
    'maart',
    'april',
    'mei',
    'juni',
    'juli',
    'augustus',
    'september',
    'oktober',
    'november',
    'december',
  ];
""",
        """  const nlMonths = [
    'januari',
    'februari',
    'maart',
    'april',
    'mei',
    'juni',
    'juli',
    'augustus',
    'september',
    'oktober',
    'november',
    'december',
  ];
  const plMonths = [
    'styczeń',
    'luty',
    'marzec',
    'kwiecień',
    'maj',
    'czerwiec',
    'lipiec',
    'sierpień',
    'wrzesień',
    'październik',
    'listopad',
    'grudzień',
  ];
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isDutch) {
    return '${nlMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isDutch) {
    return '${nlMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isPolish) {
    return '${plMonths[value.month - 1]} ${value.year}';
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

    locale = Locale.parse("pl_PL")
    language_overrides = {
        "pt-BR": "portugalski (Brazylia)",
        "pt-PT": "portugalski (Portugalia)",
        "fil": "filipiński",
        "pl": "polski",
    }
    country_overrides = {
        "CI": "Wybrzeże Kości Słoniowej",
        "CD": "Demokratyczna Republika Konga",
        "CG": "Republika Konga",
        "CV": "Republika Zielonego Przylądka",
        "CZ": "Czechy",
        "KR": "Korea Południowa",
        "KP": "Korea Północna",
        "PS": "Palestyna",
        "ST": "Wyspy Świętego Tomasza i Książęca",
        "TL": "Timor Wschodni",
        "TR": "Turcja",
        "VA": "Watykan",
    }
    currency_overrides = {
        "BRL": "real brazylijski",
        "EUR": "euro",
        "GBP": "funt szterling",
        "PLN": "złoty polski",
        "TRY": "lira turecka",
        "USD": "dolar amerykański",
        "CVE": "escudo zielonoprzylądkowe",
        "MZN": "metical mozambicki",
        "STN": "dobra Wysp Świętego Tomasza i Książęcej",
        "XAF": "frank CFA BEAC",
        "XCD": "dolar wschodniokaraibski",
        "XCG": "gulden karaibski",
        "XOF": "frank CFA BCEAO",
        "XPF": "frank CFP",
        "ZWG": "Zimbabwe Gold",
    }

    languages_path = ROOT / "assets" / "data" / "languages_v1.json"
    languages = load_json(languages_path)
    for item in languages["items"]:  # type: ignore[index]
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing Polish language name for {code}")
        item["namePl"] = name
    save_json(languages_path, languages)

    countries_path = ROOT / "assets" / "data" / "countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Polish country name for {code}")
        item["namePl"] = name
    save_json(countries_path, countries)

    currencies_path = ROOT / "assets" / "data" / "currencies_v1.json"
    currencies = load_json(currencies_path)
    common_aliases = {
        "USD": ("dolar amerykański", "dolary amerykańskie", "dolar USA"),
        "EUR": ("euro", "waluta europejska"),
        "GBP": ("funt brytyjski", "funt szterling"),
        "PLN": ("złoty", "złote", "złotych", "polski złoty"),
        "TRY": ("lira turecka", "liry tureckie"),
        "CHF": ("frank szwajcarski",),
    }
    for item in currencies["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Polish currency name for {code}")
        item["namePl"] = name
        aliases = item.setdefault("aliases", [])
        for alias in (name, name.casefold(), normal(name), *common_aliases.get(code, ())):
            if alias and alias not in aliases:
                aliases.append(alias)
    save_json(currencies_path, currencies)

def update_regressions() -> None:
    old_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl'}"
    new_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'}"
    old_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl'}"
    new_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'}"
    for root in (ROOT / "test", ROOT / "tools"):
        for path in root.rglob("*"):
            if path.suffix not in {".dart", ".py"} or path == Path(__file__):
                continue
            text = path.read_text(encoding="utf-8")
            changed = text.replace(old_plain, new_plain).replace(old_typed, new_typed)
            if changed != text:
                path.write_text(changed, encoding="utf-8")

def verify() -> None:
    english = english_pairs()
    polish = polish_pairs()
    english_keys = [key for key, _ in english]
    polish_keys = [key for key, _ in polish]
    failures: list[str] = []

    if len(english) != 791:
        failures.append(f"English reference map changed: {len(english)} keys")
    if len(polish) != 791:
        failures.append(f"Polish map must contain 791 values, found {len(polish)}")
    duplicates = sorted({key for key in polish_keys if polish_keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate Polish keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(polish_keys))
    extra = sorted(set(polish_keys) - set(english_keys))
    if missing or extra:
        failures.append(
            f"Polish/English key mismatch; missing={missing[:30]}, extra={extra[:30]}"
        )

    values = dict(polish)
    required_terms = {
        "Kredi kartı": "Karta kredytowa",
        "Ev kredisi": "Kredyt hipoteczny",
        "Son ödeme tarihi": "Termin płatności",
        "Gecikmede": "Po terminie",
        "Gelir": "Dochód",
        "Gider": "Wydatek",
        "Raporlar": "Raporty",
        "ONAYLIYORUM": "POTWIERDZAM",
    }
    for key, expected in required_terms.items():
        if values.get(key) != expected:
            failures.append(
                f"Native Polish terminology mismatch for {key!r}: {values.get(key)!r}"
            )

    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'pl'",
        "static bool get isPolish",
        "mizanPolish[visibleSource]",
        "translatePolishReviewedDynamic(",
        "'pl' => 'POTWIERDZAM'",
    ):
        if marker not in i18n:
            failures.append(f"Missing Polish runtime marker: {marker}")

    dynamic = POLISH_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("Pozostał 1 dzień", "wpisów", "_people(m[1]!)"):
        if marker not in dynamic:
            failures.append(f"Missing Polish dynamic grammar marker: {marker}")

    for filename, expected_count in (
        ("languages_v1.json", 29),
        ("countries_v1.json", 161),
        ("currencies_v1.json", 154),
    ):
        payload = load_json(ROOT / "assets" / "data" / filename)
        items = payload.get("items", [])
        if len(items) != expected_count:
            failures.append(f"{filename} item count changed: {len(items)}")
        missing_names = [str(item.get("code")) for item in items if not item.get("namePl")]
        if missing_names:
            failures.append(f"{filename} missing namePl: {missing_names[:20]}")

    if failures:
        raise SystemExit("\n".join(failures))
    print(
        f"Polish locale verified: {len(polish)} static values, 29 languages, 161 countries, 154 currencies."
    )

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
