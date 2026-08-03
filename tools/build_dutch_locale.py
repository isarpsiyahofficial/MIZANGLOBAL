#!/usr/bin/env python3
"""Build, integrate and verify the reviewed Netherlands-oriented Dutch locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
DUTCH = LIB / "l10n" / "mizan_nl.dart"
DUTCH_DYNAMIC = LIB / "l10n" / "mizan_nl_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "nl").glob("mizan_nl_*.dart")))


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


def dutch_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanDutch\w+)", source)
        if marker is None:
            raise SystemExit(f"Dutch map marker missing: {path.relative_to(ROOT)}")
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
        "import 'mizan_it_dynamic.dart';",
        "import 'mizan_it_dynamic.dart';\nimport 'mizan_nl.dart';\nimport 'mizan_nl_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl'};",
    )
    replace_once(
        I18N,
        "  static bool get isItalian => _languageTag == 'it';\n",
        "  static bool get isItalian => _languageTag == 'it';\n  static bool get isDutch => _languageTag == 'nl';\n",
    )
    replace_once(
        I18N,
        "    'it' => 'CONFERMO',\n",
        "    'it' => 'CONFERMO',\n    'nl' => 'IK BEVESTIG',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'it' || normalized.startsWith('it-')) return 'it';\n",
        "    if (normalized == 'it' || normalized.startsWith('it-')) return 'it';\n    if (normalized == 'nl' || normalized.startsWith('nl-')) return 'nl';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'it' ||\n        normalized.startsWith('it-');\n",
        "        normalized == 'it' ||\n        normalized.startsWith('it-') ||\n        normalized == 'nl' ||\n        normalized.startsWith('nl-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanItalian[visibleSource] ??
          translateItalianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'it'),
          );
    }
""",
        """    } else if (effective == 'it') {
      result =
          mizanItalian[visibleSource] ??
          translateItalianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'it'),
          );
    } else {
      result =
          mizanDutch[visibleSource] ??
          translateDutchReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'nl'),
          );
    }
""",
    )

    main = LIB / "main.dart"
    replace_once(
        main,
        "          'it' => const Locale('it', 'IT'),\n",
        "          'it' => const Locale('it', 'IT'),\n          'nl' => const Locale('nl', 'NL'),\n",
    )
    replace_once(
        main,
        "          Locale('it', 'IT'),\n",
        "          Locale('it', 'IT'),\n          Locale('nl', 'NL'),\n",
    )


def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(
        path,
        "    required this.nameIt,\n",
        "    required this.nameIt,\n    required this.nameNl,\n",
        3,
    )
    replace_all(
        path,
        "  final String nameIt;\n",
        "  final String nameIt;\n  final String nameNl;\n",
        3,
    )
    replace_all(
        path,
        "    nameIt: json['nameIt']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameIt: json['nameIt']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameNl: json['nameNl']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(
        path,
        "    'it' => nameIt,\n",
        "    'it' => nameIt,\n    'nl' => nameNl,\n",
        3,
    )
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $nativeName'",
    )
    replace_once(
        path,
        "      nameIt,\n      ...symbols,",
        "      nameIt,\n      nameNl,\n      ...symbols,",
    )


def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        """  if (MizanI18n.isFrench || MizanI18n.isGerman || MizanI18n.isItalian) {
    return code == 'EUR' ? '$amount\\u00A0€' : '$amount\\u00A0$code';
  }
""",
        """  if (MizanI18n.isDutch) {
    return code == 'EUR' ? '€\\u00A0$amount' : '$code\\u00A0$amount';
  }
  if (MizanI18n.isFrench || MizanI18n.isGerman || MizanI18n.isItalian) {
    return code == 'EUR' ? '$amount\\u00A0€' : '$amount\\u00A0$code';
  }
""",
    )
    replace_once(
        path,
        """  const itMonths = [
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
  if (MizanI18n.isEnglish) {
""",
        """  const itMonths = [
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
  const nlMonths = [
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
  if (MizanI18n.isEnglish) {
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isItalian) {
    return '${value.day} ${itMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isItalian) {
    return '${value.day} ${itMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isDutch) {
    return '${value.day} ${nlMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        path,
        """  const itMonths = [
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
  if (MizanI18n.isEnglish) {
""",
        """  const itMonths = [
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
  const nlMonths = [
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
  if (MizanI18n.isEnglish) {
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isItalian) {
    return '${itMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isItalian) {
    return '${itMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isDutch) {
    return '${nlMonths[value.month - 1]} ${value.year}';
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

    locale = Locale.parse("nl_NL")
    language_overrides = {
        "pt-BR": "Portugees (Brazilië)",
        "pt-PT": "Portugees (Portugal)",
        "fil": "Filipijns",
        "nl": "Nederlands",
    }
    country_overrides = {
        "CI": "Ivoorkust",
        "CD": "Congo-Kinshasa",
        "CG": "Congo-Brazzaville",
        "CV": "Kaapverdië",
        "CZ": "Tsjechië",
        "KR": "Zuid-Korea",
        "KP": "Noord-Korea",
        "PS": "Palestijnse gebieden",
        "ST": "Sao Tomé en Principe",
        "TL": "Oost-Timor",
        "TR": "Turkije",
        "VA": "Vaticaanstad",
    }
    currency_overrides = {
        "BRL": "Braziliaanse real",
        "EUR": "euro",
        "GBP": "Britse pond",
        "TRY": "Turkse lira",
        "USD": "Amerikaanse dollar",
        "CVE": "Kaapverdische escudo",
        "MZN": "Mozambikaanse metical",
        "STN": "Santomese dobra",
        "XAF": "CFA-frank BEAC",
        "XCD": "Oost-Caribische dollar",
        "XCG": "Caribische gulden",
        "XOF": "CFA-frank BCEAO",
        "XPF": "CFP-frank",
        "ZWG": "Zimbabwe Gold",
    }

    languages_path = ROOT / "assets" / "data" / "languages_v1.json"
    languages = load_json(languages_path)
    for item in languages["items"]:  # type: ignore[index]
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing Dutch language name for {code}")
        item["nameNl"] = name
    save_json(languages_path, languages)

    countries_path = ROOT / "assets" / "data" / "countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Dutch country name for {code}")
        item["nameNl"] = name
    save_json(countries_path, countries)

    currencies_path = ROOT / "assets" / "data" / "currencies_v1.json"
    currencies = load_json(currencies_path)
    common_aliases = {
        "USD": ("Amerikaanse dollar", "Amerikaanse dollars", "US dollar"),
        "EUR": ("euro", "Europese munt"),
        "GBP": ("Britse pond", "pond sterling"),
        "TRY": ("Turkse lira", "Turkse lira's"),
        "CHF": ("Zwitserse frank",),
    }
    for item in currencies["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Dutch currency name for {code}")
        item["nameNl"] = name
        aliases = item.setdefault("aliases", [])
        for alias in (name, name.casefold(), normal(name), *common_aliases.get(code, ())):
            if alias and alias not in aliases:
                aliases.append(alias)
    save_json(currencies_path, currencies)


def update_regressions() -> None:
    old_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it'}"
    new_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl'}"
    old_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it'}"
    new_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl'}"
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
    dutch = dutch_pairs()
    english_keys = [key for key, _ in english]
    dutch_keys = [key for key, _ in dutch]
    failures: list[str] = []

    if len(english) != 791:
        failures.append(f"English reference map changed: {len(english)} keys")
    if len(dutch) != 791:
        failures.append(f"Dutch map must contain 791 values, found {len(dutch)}")
    duplicates = sorted({key for key in dutch_keys if dutch_keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate Dutch keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(dutch_keys))
    extra = sorted(set(dutch_keys) - set(english_keys))
    if missing or extra:
        failures.append(
            f"Dutch/English key mismatch; missing={missing[:30]}, extra={extra[:30]}"
        )

    values = dict(dutch)
    required_terms = {
        "Kredi kartı": "Creditcard",
        "Ev kredisi": "Hypotheek",
        "Son ödeme tarihi": "Vervaldatum",
        "Gecikmede": "Achterstallig",
        "Gelir": "Inkomst",
        "Gider": "Uitgave",
        "Raporlar": "Rapporten",
        "ONAYLIYORUM": "IK BEVESTIG",
    }
    for key, expected in required_terms.items():
        if values.get(key) != expected:
            failures.append(
                f"Native Dutch terminology mismatch for {key!r}: {values.get(key)!r}"
            )

    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'nl'",
        "static bool get isDutch",
        "mizanDutch[visibleSource]",
        "translateDutchReviewedDynamic(",
        "'nl' => 'IK BEVESTIG'",
    ):
        if marker not in i18n:
            failures.append(f"Missing Dutch runtime marker: {marker}")

    dynamic = DUTCH_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("Nog 1 dag", "registraties", "geselecteerd"):
        if marker not in dynamic:
            failures.append(f"Missing Dutch dynamic grammar marker: {marker}")

    for filename, expected_count in (
        ("languages_v1.json", 29),
        ("countries_v1.json", 161),
        ("currencies_v1.json", 154),
    ):
        payload = load_json(ROOT / "assets" / "data" / filename)
        items = payload.get("items", [])
        if len(items) != expected_count:
            failures.append(f"{filename} item count changed: {len(items)}")
        missing_names = [str(item.get("code")) for item in items if not item.get("nameNl")]
        if missing_names:
            failures.append(f"{filename} missing nameNl: {missing_names[:20]}")

    if failures:
        raise SystemExit("\n".join(failures))
    print(
        f"Dutch locale verified: {len(dutch)} static values, 29 languages, 161 countries, 154 currencies."
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
