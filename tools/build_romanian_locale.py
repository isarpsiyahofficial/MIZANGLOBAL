#!/usr/bin/env python3
"""Build, integrate and verify the reviewed Romania-oriented Romanian locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
ROMANIAN = LIB / "l10n" / "mizan_ro.dart"
ROMANIAN_DYNAMIC = LIB / "l10n" / "mizan_ro_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "ro").glob("mizan_ro_*.dart")))


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


def romanian_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanRomanian\w+)", source)
        if marker is None:
            raise SystemExit(f"Romanian map marker missing: {path.relative_to(ROOT)}")
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
        "import 'mizan_pl_dynamic.dart';",
        "import 'mizan_pl_dynamic.dart';\nimport 'mizan_ro.dart';\nimport 'mizan_ro_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'};",
    )
    replace_once(
        I18N,
        "  static bool get isPolish => _languageTag == 'pl';\n",
        "  static bool get isPolish => _languageTag == 'pl';\n  static bool get isRomanian => _languageTag == 'ro';\n",
    )
    replace_once(
        I18N,
        "    'pl' => 'POTWIERDZAM',\n",
        "    'pl' => 'POTWIERDZAM',\n    'ro' => 'CONFIRM',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'pl' || normalized.startsWith('pl-')) return 'pl';\n",
        "    if (normalized == 'pl' || normalized.startsWith('pl-')) return 'pl';\n    if (normalized == 'ro' || normalized.startsWith('ro-')) return 'ro';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'pl' ||\n        normalized.startsWith('pl-');\n",
        "        normalized == 'pl' ||\n        normalized.startsWith('pl-') ||\n        normalized == 'ro' ||\n        normalized.startsWith('ro-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanPolish[visibleSource] ??
          translatePolishReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pl'),
          );
    }
""",
        """    } else if (effective == 'pl') {
      result =
          mizanPolish[visibleSource] ??
          translatePolishReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pl'),
          );
    } else {
      result =
          mizanRomanian[visibleSource] ??
          translateRomanianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ro'),
          );
    }
""",
    )

    main = LIB / "main.dart"
    replace_once(
        main,
        "          'pl' => const Locale('pl', 'PL'),\n",
        "          'pl' => const Locale('pl', 'PL'),\n          'ro' => const Locale('ro', 'RO'),\n",
    )
    replace_once(
        main,
        "          Locale('pl', 'PL'),\n",
        "          Locale('pl', 'PL'),\n          Locale('ro', 'RO'),\n",
    )

def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(
        path,
        "    required this.namePl,\n",
        "    required this.namePl,\n    required this.nameRo,\n",
        3,
    )
    replace_all(
        path,
        "  final String namePl;\n",
        "  final String namePl;\n  final String nameRo;\n",
        3,
    )
    replace_all(
        path,
        "    namePl: json['namePl']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    namePl: json['namePl']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameRo: json['nameRo']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(
        path,
        "    'pl' => namePl,\n",
        "    'pl' => namePl,\n    'ro' => nameRo,\n",
        3,
    )
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nativeName'",
    )
    replace_once(
        path,
        "      namePl,\n      ...symbols,",
        "      namePl,\n      nameRo,\n      ...symbols,",
    )

def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        """  if (MizanI18n.isPolish) {
    if (code == 'PLN') return '$amount\\u00A0zł';
    return '$amount\\u00A0$code';
  }
""",
        """  if (MizanI18n.isPolish) {
    if (code == 'PLN') return '$amount\\u00A0zł';
    return '$amount\\u00A0$code';
  }
  if (MizanI18n.isRomanian) {
    if (code == 'RON') return '$amount\\u00A0lei';
    return '$amount\\u00A0$code';
  }
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isPolish) {
    final negative = integerPart.startsWith('-');
    final digits = negative ? integerPart.substring(1) : integerPart;
    final grouped = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      grouped.write(digits[index]);
      final remaining = digits.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        grouped.write('\\u202F');
      }
    }
    integerPart = '${negative ? '-' : ''}${grouped.toString()}';
  }
""",
        """  if (MizanI18n.isPolish || MizanI18n.isRomanian) {
    final negative = integerPart.startsWith('-');
    final digits = negative ? integerPart.substring(1) : integerPart;
    final grouped = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      grouped.write(digits[index]);
      final remaining = digits.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        grouped.write(MizanI18n.isRomanian ? '.' : '\\u202F');
      }
    }
    integerPart = '${negative ? '-' : ''}${grouped.toString()}';
  }
""",
    )
    replace_once(
        path,
        """  const plMonths = [
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
        """  const plMonths = [
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
  const roMonths = [
    'ian.',
    'feb.',
    'mar.',
    'apr.',
    'mai',
    'iun.',
    'iul.',
    'aug.',
    'sept.',
    'oct.',
    'nov.',
    'dec.',
  ];
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isPolish) {
    return '${value.day} ${plMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isPolish) {
    return '${value.day} ${plMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isRomanian) {
    return '${value.day} ${roMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        path,
        """  const plMonths = [
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
        """  const plMonths = [
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
  const roMonths = [
    'ianuarie',
    'februarie',
    'martie',
    'aprilie',
    'mai',
    'iunie',
    'iulie',
    'august',
    'septembrie',
    'octombrie',
    'noiembrie',
    'decembrie',
  ];
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isPolish) {
    return '${plMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isPolish) {
    return '${plMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isRomanian) {
    return '${roMonths[value.month - 1]} ${value.year}';
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

    locale = Locale.parse("ro_RO")
    language_overrides = {
        "pt-BR": "portugheză (Brazilia)",
        "pt-PT": "portugheză (Portugalia)",
        "fil": "filipineză",
        "ro": "română",
    }
    country_overrides = {
        "CI": "Coasta de Fildeș",
        "CD": "Republica Democratică Congo",
        "CG": "Republica Congo",
        "CV": "Capul Verde",
        "CZ": "Cehia",
        "KR": "Coreea de Sud",
        "KP": "Coreea de Nord",
        "PS": "Palestina",
        "ST": "São Tomé și Príncipe",
        "TL": "Timorul de Est",
        "TR": "Turcia",
        "VA": "Vatican",
    }
    currency_overrides = {
        "BRL": "real brazilian",
        "EUR": "euro",
        "GBP": "liră sterlină",
        "RON": "leu românesc",
        "TRY": "liră turcească",
        "USD": "dolar american",
        "CVE": "escudo capverdian",
        "MZN": "metical mozambican",
        "STN": "dobra din São Tomé și Príncipe",
        "XAF": "franc CFA BEAC",
        "XCD": "dolar est-caraibian",
        "XCG": "gulden caraibian",
        "XOF": "franc CFA BCEAO",
        "XPF": "franc CFP",
        "ZWG": "Zimbabwe Gold",
    }

    languages_path = ROOT / "assets" / "data" / "languages_v1.json"
    languages = load_json(languages_path)
    for item in languages["items"]:  # type: ignore[index]
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing Romanian language name for {code}")
        item["nameRo"] = name
    save_json(languages_path, languages)

    countries_path = ROOT / "assets" / "data" / "countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Romanian country name for {code}")
        item["nameRo"] = name
    save_json(countries_path, countries)

    currencies_path = ROOT / "assets" / "data" / "currencies_v1.json"
    currencies = load_json(currencies_path)
    common_aliases = {
        "USD": ("dolar american", "dolari americani", "dolar SUA"),
        "EUR": ("euro", "monedă europeană"),
        "GBP": ("liră britanică", "liră sterlină"),
        "RON": ("leu", "lei", "leu românesc", "lei românești"),
        "TRY": ("liră turcească", "lire turcești"),
        "CHF": ("franc elvețian",),
    }
    for item in currencies["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Romanian currency name for {code}")
        item["nameRo"] = name
        aliases = item.setdefault("aliases", [])
        for alias in (name, name.casefold(), normal(name), *common_aliases.get(code, ())):
            if alias and alias not in aliases:
                aliases.append(alias)
    save_json(currencies_path, currencies)

def update_regressions() -> None:
    old_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl'}"
    new_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'}"
    old_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl'}"
    new_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru', 'uk'}"
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
    romanian = romanian_pairs()
    english_keys = [key for key, _ in english]
    romanian_keys = [key for key, _ in romanian]
    failures: list[str] = []

    if len(english) != 791:
        failures.append(f"English reference map changed: {len(english)} keys")
    if len(romanian) != 791:
        failures.append(f"Romanian map must contain 791 values, found {len(romanian)}")
    duplicates = sorted({key for key in romanian_keys if romanian_keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate Romanian keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(romanian_keys))
    extra = sorted(set(romanian_keys) - set(english_keys))
    if missing or extra:
        failures.append(
            f"Romanian/English key mismatch; missing={missing[:30]}, extra={extra[:30]}"
        )

    values = dict(romanian)
    required_terms = {
        "Ana sayfa": "Prezentare generală",
        "Kayıtlar": "Înregistrări",
        "Kredi kartı": "Card de credit",
        "Ev kredisi": "Credit ipotecar",
        "Son ödeme tarihi": "Data scadenței",
        "Gecikmede": "Restant",
        "Gelir": "Venit",
        "Gider": "Cheltuială",
        "Raporlar": "Rapoarte",
        "ONAYLIYORUM": "CONFIRM",
    }
    for key, expected in required_terms.items():
        if values.get(key) != expected:
            failures.append(
                f"Native Romanian terminology mismatch for {key!r}: {values.get(key)!r}"
            )

    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'ro'",
        "static bool get isRomanian",
        "mizanRomanian[visibleSource]",
        "translateRomanianReviewedDynamic(",
        "'ro' => 'CONFIRM'",
    ):
        if marker not in i18n:
            failures.append(f"Missing Romanian runtime marker: {marker}")

    dynamic = ROMANIAN_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("A mai rămas 1 zi", "înregistrări", "_people(m[1]!)"):
        if marker not in dynamic:
            failures.append(f"Missing Romanian dynamic grammar marker: {marker}")

    for filename, expected_count in (
        ("languages_v1.json", 29),
        ("countries_v1.json", 161),
        ("currencies_v1.json", 154),
    ):
        payload = load_json(ROOT / "assets" / "data" / filename)
        items = payload.get("items", [])
        if len(items) != expected_count:
            failures.append(f"{filename} item count changed: {len(items)}")
        missing_names = [str(item.get("code")) for item in items if not item.get("nameRo")]
        if missing_names:
            failures.append(f"{filename} missing nameRo: {missing_names[:20]}")

    if failures:
        raise SystemExit("\n".join(failures))
    print(
        f"Romanian locale verified: {len(romanian)} static values, 29 languages, 161 countries, 154 currencies."
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
