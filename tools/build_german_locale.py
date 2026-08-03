#!/usr/bin/env python3
"""Build and verify the reviewed Germany-oriented German locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
GERMAN = LIB / "l10n" / "mizan_de.dart"
GERMAN_DYNAMIC = LIB / "l10n" / "mizan_de_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "de").glob("mizan_de_*.dart")))


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


def german_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanGerman\w+)", source)
        if marker is None:
            raise SystemExit(f"German map marker missing: {path.relative_to(ROOT)}")
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
        "import 'mizan_fr_dynamic.dart';",
        "import 'mizan_fr_dynamic.dart';\nimport 'mizan_de.dart';\nimport 'mizan_de_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'};",
    )
    replace_once(
        I18N,
        "  static bool get isFrench => _languageTag == 'fr';\n",
        "  static bool get isFrench => _languageTag == 'fr';\n  static bool get isGerman => _languageTag == 'de';\n",
    )
    replace_once(
        I18N,
        "    'fr' => 'JE CONFIRME',\n",
        "    'fr' => 'JE CONFIRME',\n    'de' => 'ICH BESTÄTIGE',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'fr' || normalized.startsWith('fr-')) return 'fr';\n",
        "    if (normalized == 'fr' || normalized.startsWith('fr-')) return 'fr';\n    if (normalized == 'de' || normalized.startsWith('de-')) return 'de';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'fr' ||\n        normalized.startsWith('fr-');\n",
        "        normalized == 'fr' ||\n        normalized.startsWith('fr-') ||\n        normalized == 'de' ||\n        normalized.startsWith('de-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanFrench[visibleSource] ??
          translateFrenchReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'fr'),
          );
    }
""",
        """    } else if (effective == 'fr') {
      result =
          mizanFrench[visibleSource] ??
          translateFrenchReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'fr'),
          );
    } else {
      result =
          mizanGerman[visibleSource] ??
          translateGermanReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'de'),
          );
    }
""",
    )

    main = LIB / "main.dart"
    replace_once(
        main,
        "          'pt-PT' => const Locale('pt', 'PT'),\n",
        "          'pt-PT' => const Locale('pt', 'PT'),\n          'de' => const Locale('de', 'DE'),\n",
    )
    replace_once(
        main,
        "          Locale('fr'),\n",
        "          Locale('fr'),\n          Locale('de', 'DE'),\n",
    )


def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(
        path,
        "    required this.nameFr,\n",
        "    required this.nameFr,\n    required this.nameDe,\n",
        3,
    )
    replace_all(
        path,
        "  final String nameFr;\n",
        "  final String nameFr;\n  final String nameDe;\n",
        3,
    )
    replace_all(
        path,
        "    nameFr: json['nameFr']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameFr: json['nameFr']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameDe: json['nameDe']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(
        path,
        "    'fr' => nameFr,\n",
        "    'fr' => nameFr,\n    'de' => nameDe,\n",
        3,
    )
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nativeName'",
    )
    replace_once(
        path,
        "      nameFr,\n      ...symbols,",
        "      nameFr,\n      nameDe,\n      ...symbols,",
    )


def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        """  if (MizanI18n.isFrench) {
    return code == 'EUR' ? '$amount\\u00A0€' : '$amount\\u00A0$code';
  }
""",
        """  if (MizanI18n.isFrench || MizanI18n.isGerman) {
    return code == 'EUR' ? '$amount\\u00A0€' : '$amount\\u00A0$code';
  }
""",
    )
    replace_once(
        path,
        """  const frMonths = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
""",
        """  const frMonths = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  const deMonths = [
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
    )
    replace_once(
        path,
        """  if (MizanI18n.isEnglish) {
    return '${enMonths[value.month - 1]} ${value.day}, ${value.year}';
  }
""",
        """  if (MizanI18n.isEnglish) {
    return '${enMonths[value.month - 1]} ${value.day}, ${value.year}';
  }
  if (MizanI18n.isGerman) {
    return '${value.day}. ${deMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        path,
        """  const frMonths = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
""",
        """  const frMonths = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  const deMonths = [
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
    )
    replace_once(
        path,
        """  if (MizanI18n.isFrench) {
    return '${frMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isFrench) {
    return '${frMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isGerman) {
    return '${deMonths[value.month - 1]} ${value.year}';
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

    locale = Locale.parse("de_DE")
    language_overrides = {
        "pt-BR": "Portugiesisch (Brasilien)",
        "pt-PT": "Portugiesisch (Portugal)",
        "fil": "Filipino",
        "de": "Deutsch",
    }
    country_overrides = {
        "CI": "Côte d’Ivoire",
        "CD": "Demokratische Republik Kongo",
        "CG": "Republik Kongo",
        "CV": "Cabo Verde",
        "CZ": "Tschechien",
        "KR": "Südkorea",
        "KP": "Nordkorea",
        "PS": "Palästinensische Gebiete",
        "ST": "São Tomé und Príncipe",
        "TL": "Timor-Leste",
        "TR": "Türkei",
        "VA": "Vatikanstadt",
    }
    currency_overrides = {
        "BRL": "Brasilianischer Real",
        "EUR": "Euro",
        "GBP": "Britisches Pfund",
        "TRY": "Türkische Lira",
        "USD": "US-Dollar",
        "CVE": "Cabo-Verde-Escudo",
        "MZN": "Mosambikanischer Metical",
        "STN": "São-toméischer Dobra",
        "XAF": "CFA-Franc (BEAC)",
        "XCD": "Ostkaribischer Dollar",
        "XCG": "Karibischer Gulden",
        "XOF": "CFA-Franc (BCEAO)",
        "XPF": "CFP-Franc",
        "ZWG": "Zimbabwe Gold",
    }

    languages_path = ROOT / "assets" / "data" / "languages_v1.json"
    languages = load_json(languages_path)
    for item in languages["items"]:  # type: ignore[index]
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing German language name for {code}")
        item["nameDe"] = name
    save_json(languages_path, languages)

    countries_path = ROOT / "assets" / "data" / "countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing German country name for {code}")
        item["nameDe"] = name
    save_json(countries_path, countries)

    currencies_path = ROOT / "assets" / "data" / "currencies_v1.json"
    currencies = load_json(currencies_path)
    for item in currencies["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing German currency name for {code}")
        item["nameDe"] = name
        aliases = item.setdefault("aliases", [])
        common_aliases = {
            "USD": (
                "US Dollar",
                "US-Dollar",
                "amerikanischer Dollar",
                "Dollar USA",
            ),
            "EUR": ("Euro", "europäische Währung", "europaeische Waehrung"),
            "GBP": ("Pfund Sterling", "britisches Pfund"),
            "TRY": ("Türkische Lira", "türkische Lire", "Tuerkische Lira"),
            "CHF": ("Schweizer Franken",),
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
    old_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr'}"
    new_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'}"
    old_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr'}"
    new_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'}"
    for root in (ROOT / "test", ROOT / "tools"):
        for path in root.rglob("*"):
            if path.suffix not in {".dart", ".py"} or path == Path(__file__):
                continue
            text = path.read_text(encoding="utf-8")
            text = text.replace(old_plain, new_plain).replace(old_typed, new_typed)
            # Locale-builder file lists are maintained explicitly. Generic text
            # injection is forbidden because quoted examples can resemble real entries.
            path.write_text(text, encoding="utf-8")


def verify() -> None:
    english = english_pairs()
    german = german_pairs()
    english_keys = [key for key, _ in english]
    german_keys = [key for key, _ in german]
    failures: list[str] = []

    if len(english) != 791:
        failures.append(f"English reference map changed: {len(english)} keys")
    if len(german) != 791:
        failures.append(f"German map must contain 791 values, found {len(german)}")
    duplicates = sorted({key for key in german_keys if german_keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate German keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(german_keys))
    extra = sorted(set(german_keys) - set(english_keys))
    if missing or extra:
        failures.append(
            f"German/English key mismatch; missing={missing[:20]}, extra={extra[:20]}"
        )

    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'de'",
        "static bool get isGerman",
        "mizanGerman[visibleSource]",
        "translateGermanReviewedDynamic(",
        "'de' => 'ICH BESTÄTIGE'",
    ):
        if marker not in i18n:
            failures.append(f"Missing German runtime marker: {marker}")
    dynamic = GERMAN_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("Noch", "Einträge", "ausgewählt", "ICH BESTÄTIGE"):
        if marker not in dynamic and marker != "ICH BESTÄTIGE":
            failures.append(f"Missing German dynamic grammar marker: {marker}")

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
            item.get("code") for item in items if not str(item.get("nameDe", "")).strip()
        ]
        if missing_names:
            failures.append(f"Missing nameDe in {filename}: {missing_names[:20]}")

    if failures:
        print("German localization verification failed:")
        for failure in failures:
            print(f"- {failure}")
        raise SystemExit(1)
    print(
        "German verification passed: 791/791 static values, dynamic grammar, runtime and catalogs"
    )


def build() -> None:
    english = english_pairs()
    german = german_pairs()
    if len(english) != 791 or len(german) != 791:
        raise SystemExit(
            f"Pre-integration key counts invalid: English={len(english)}, German={len(german)}"
        )
    missing = sorted(set(key for key, _ in english) - set(key for key, _ in german))
    extra = sorted(set(key for key, _ in german) - set(key for key, _ in english))
    if missing or extra:
        raise SystemExit(f"German source key mismatch; missing={missing}, extra={extra}")
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
