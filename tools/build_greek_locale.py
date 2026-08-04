#!/usr/bin/env python3
"""Build, integrate and verify the reviewed Greece-oriented Greek locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
GREEK = LIB / "l10n" / "mizan_el.dart"
GREEK_DYNAMIC = LIB / "l10n" / "mizan_el_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "el").glob("mizan_el_*.dart")))


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


def greek_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanGreek\w+)", source)
        if marker is None:
            raise SystemExit(f"Greek map marker missing: {path.relative_to(ROOT)}")
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
        "import 'mizan_ro_dynamic.dart';",
        "import 'mizan_ro_dynamic.dart';\nimport 'mizan_el.dart';\nimport 'mizan_el_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru'};",
    )
    replace_once(
        I18N,
        "  static bool get isRomanian => _languageTag == 'ro';\n",
        "  static bool get isRomanian => _languageTag == 'ro';\n  static bool get isGreek => _languageTag == 'el';\n",
    )
    replace_once(
        I18N,
        "    'ro' => 'CONFIRM',\n",
        "    'ro' => 'CONFIRM',\n    'el' => 'ΕΠΙΒΕΒΑΙΩΝΩ',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'ro' || normalized.startsWith('ro-')) return 'ro';\n",
        "    if (normalized == 'ro' || normalized.startsWith('ro-')) return 'ro';\n    if (normalized == 'el' || normalized.startsWith('el-')) return 'el';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'ro' ||\n        normalized.startsWith('ro-');\n",
        "        normalized == 'ro' ||\n        normalized.startsWith('ro-') ||\n        normalized == 'el' ||\n        normalized.startsWith('el-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanRomanian[visibleSource] ??
          translateRomanianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ro'),
          );
    }
""",
        """    } else if (effective == 'ro') {
      result =
          mizanRomanian[visibleSource] ??
          translateRomanianReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'ro'),
          );
    } else {
      result =
          mizanGreek[visibleSource] ??
          translateGreekReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'el'),
          );
    }
""",
    )

    main = LIB / "main.dart"
    replace_once(
        main,
        "          'ro' => const Locale('ro', 'RO'),\n",
        "          'ro' => const Locale('ro', 'RO'),\n          'el' => const Locale('el', 'GR'),\n",
    )
    replace_once(
        main,
        "          Locale('ro', 'RO'),\n",
        "          Locale('ro', 'RO'),\n          Locale('el', 'GR'),\n",
    )


def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(
        path,
        "    required this.nameRo,\n",
        "    required this.nameRo,\n    required this.nameEl,\n",
        3,
    )
    replace_all(
        path,
        "  final String nameRo;\n",
        "  final String nameRo;\n  final String nameEl;\n",
        3,
    )
    replace_all(
        path,
        "    nameRo: json['nameRo']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    nameRo: json['nameRo']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameEl: json['nameEl']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(
        path,
        "    'ro' => nameRo,\n",
        "    'ro' => nameRo,\n    'el' => nameEl,\n",
        3,
    )
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nameDe $nameIt $nameNl $namePl $nameRo $nameEl $nativeName'",
    )
    replace_once(
        path,
        "      nameRo,\n      ...symbols,",
        "      nameRo,\n      nameEl,\n      ...symbols,",
    )


def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        """  if (MizanI18n.isRomanian) {
    if (code == 'RON') return '$amount\\u00A0lei';
    return '$amount\\u00A0$code';
  }
""",
        """  if (MizanI18n.isRomanian) {
    if (code == 'RON') return '$amount\\u00A0lei';
    return '$amount\\u00A0$code';
  }
  if (MizanI18n.isGreek) {
    if (code == 'EUR') return '$amount\\u00A0€';
    return '$amount\\u00A0$code';
  }
""",
    )
    replace_once(
        path,
        "  if (MizanI18n.isPolish || MizanI18n.isRomanian) {\n",
        "  if (MizanI18n.isPolish || MizanI18n.isRomanian || MizanI18n.isGreek) {\n",
    )
    replace_once(
        path,
        "        grouped.write(MizanI18n.isRomanian ? '.' : '\\u202F');\n",
        "        grouped.write((MizanI18n.isRomanian || MizanI18n.isGreek) ? '.' : '\\u202F');\n",
    )
    replace_once(
        path,
        """  const roMonths = [
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
        """  const roMonths = [
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
  const elMonths = [
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
    )
    replace_once(
        path,
        """  if (MizanI18n.isRomanian) {
    return '${value.day} ${roMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isRomanian) {
    return '${value.day} ${roMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isGreek) {
    return '${value.day} ${elMonths[value.month - 1]} ${value.year}';
  }
""",
    )
    replace_once(
        path,
        """  const roMonths = [
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
        """  const roMonths = [
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
  const elMonths = [
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
    )
    replace_once(
        path,
        """  if (MizanI18n.isRomanian) {
    return '${roMonths[value.month - 1]} ${value.year}';
  }
""",
        """  if (MizanI18n.isRomanian) {
    return '${roMonths[value.month - 1]} ${value.year}';
  }
  if (MizanI18n.isGreek) {
    return '${elMonths[value.month - 1]} ${value.year}';
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

    locale = Locale.parse("el_GR")
    language_overrides = {
        "pt-BR": "Πορτογαλικά (Βραζιλία)",
        "pt-PT": "Πορτογαλικά (Πορτογαλία)",
        "fil": "Φιλιππινέζικα",
        "el": "Ελληνικά",
    }
    country_overrides = {
        "CI": "Ακτή Ελεφαντοστού",
        "CD": "Λαϊκή Δημοκρατία του Κονγκό",
        "CG": "Δημοκρατία του Κονγκό",
        "CV": "Πράσινο Ακρωτήριο",
        "CZ": "Τσεχία",
        "KR": "Νότια Κορέα",
        "KP": "Βόρεια Κορέα",
        "PS": "Παλαιστίνη",
        "ST": "Σάο Τομέ και Πρίνσιπε",
        "TL": "Ανατολικό Τιμόρ",
        "TR": "Τουρκία",
        "VA": "Βατικανό",
    }
    currency_overrides = {
        "BRL": "ρεάλ Βραζιλίας",
        "EUR": "ευρώ",
        "GBP": "λίρα στερλίνα",
        "RON": "ρουμανικό λέου",
        "TRY": "τουρκική λίρα",
        "USD": "δολάριο ΗΠΑ",
        "CVE": "εσκούδο Πράσινου Ακρωτηρίου",
        "MZN": "μετικάλ Μοζαμβίκης",
        "STN": "ντόμπρα Σάο Τομέ και Πρίνσιπε",
        "XAF": "φράγκο CFA BEAC",
        "XCD": "δολάριο Ανατολικής Καραϊβικής",
        "XCG": "γκίλντα Καραϊβικής",
        "XOF": "φράγκο CFA BCEAO",
        "XPF": "φράγκο CFP",
        "ZWG": "Zimbabwe Gold",
    }

    languages_path = ROOT / "assets" / "data" / "languages_v1.json"
    languages = load_json(languages_path)
    for item in languages["items"]:  # type: ignore[index]
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = language_overrides.get(code) or str(locale.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing Greek language name for {code}")
        item["nameEl"] = name
    save_json(languages_path, languages)

    countries_path = ROOT / "assets" / "data" / "countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Greek country name for {code}")
        item["nameEl"] = name
    save_json(countries_path, countries)

    currencies_path = ROOT / "assets" / "data" / "currencies_v1.json"
    currencies = load_json(currencies_path)
    common_aliases = {
        "USD": ("δολάριο", "δολάρια", "δολάριο ΗΠΑ", "αμερικανικό δολάριο"),
        "EUR": ("ευρώ", "ευρω", "ευρωπαϊκό νόμισμα"),
        "GBP": ("βρετανική λίρα", "λίρα στερλίνα", "στερλίνα"),
        "RON": ("λέου", "ρουμανικό λέου", "ρουμανικό νόμισμα"),
        "TRY": ("τουρκική λίρα", "τουρκικές λίρες"),
        "CHF": ("ελβετικό φράγκο",),
        "PLN": ("πολωνικό ζλότι", "ζλότι"),
        "JPY": ("ιαπωνικό γιεν", "γιεν"),
        "CNY": ("κινεζικό γουάν", "γουάν"),
        "RUB": ("ρωσικό ρούβλι", "ρούβλι"),
        "AED": ("ντιράμ ΗΑΕ", "ντιράμ Ηνωμένων Αραβικών Εμιράτων"),
    }
    for item in currencies["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing Greek currency name for {code}")
        item["nameEl"] = name
        aliases = item.setdefault("aliases", [])
        for alias in (name, name.casefold(), normal(name), *common_aliases.get(code, ())):
            if alias and alias not in aliases:
                aliases.append(alias)
    save_json(currencies_path, currencies)


def update_regressions() -> None:
    old_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro'}"
    new_plain = "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru'}"
    old_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro'}"
    new_typed = "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el', 'ru'}"
    old_runtime = (
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', "
        "'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro'};"
    )
    new_runtime = (
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', "
        "'pt-PT', 'fr', 'de', 'it', 'nl', 'pl', 'ro', 'el'};"
    )
    for root in (ROOT / "test", ROOT / "tools"):
        for path in root.rglob("*"):
            if path.suffix not in {".dart", ".py"} or path == Path(__file__):
                continue
            text = path.read_text(encoding="utf-8")
            changed = (
                text.replace(old_plain, new_plain)
                .replace(old_typed, new_typed)
                .replace(old_runtime, new_runtime)
            )
            if changed != text:
                path.write_text(changed, encoding="utf-8")

    for filename in (
        "english_localization_test.dart",
        "portuguese_br_localization_test.dart",
        "spanish_localization_test.dart",
        "italian_final_head_test.dart",
    ):
        path = ROOT / "test" / filename
        text = path.read_text(encoding="utf-8")
        text = text.replace(
            "      'ro',\n    });",
            "      'ro',\n      'el',\n    });",
        )
        ro_anchor = "    expect(MizanI18n.normalizeLanguageTag('ro_RO'), 'ro');\n"
        greek_assertions = (
            "    expect(MizanI18n.isSupported('el'), isTrue);\n"
            "    expect(MizanI18n.isSupported('el-GR'), isTrue);\n"
            "    expect(MizanI18n.normalizeLanguageTag('el_GR'), 'el');\n"
        )
        if ro_anchor in text and greek_assertions not in text:
            text = text.replace(ro_anchor, ro_anchor + greek_assertions, 1)
        if filename == "italian_final_head_test.dart":
            text = text.replace(
                "final Romanian head exposes the complete eleven-language runtime",
                "final Greek head exposes the complete twelve-language runtime",
            )
            nl_anchor = "    expect(MizanI18n.isSupported('nl-NL'), isTrue);\n"
            italian_greek = (
                "    expect(MizanI18n.normalizeLanguageTag('el_GR'), 'el');\n"
                "    expect(MizanI18n.isSupported('el-GR'), isTrue);\n"
            )
            if nl_anchor in text and italian_greek not in text:
                text = text.replace(nl_anchor, nl_anchor + italian_greek, 1)
        text = text.replace("after Romanian integration", "after Greek integration")
        path.write_text(text, encoding="utf-8")


def verify() -> None:
    english = english_pairs()
    greek = greek_pairs()
    english_keys = [key for key, _ in english]
    greek_keys = [key for key, _ in greek]
    failures: list[str] = []

    if len(english) != 791:
        failures.append(f"English reference map changed: {len(english)} keys")
    if len(greek) != 791:
        failures.append(f"Greek map must contain 791 values, found {len(greek)}")
    duplicates = sorted({key for key in greek_keys if greek_keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate Greek keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(greek_keys))
    extra = sorted(set(greek_keys) - set(english_keys))
    if missing or extra:
        failures.append(f"Greek/English key mismatch; missing={missing[:30]}, extra={extra[:30]}")

    values = dict(greek)
    required_terms = {
        "Ana sayfa": "Αρχική",
        "Kayıtlar": "Εγγραφές",
        "Giderler": "Έξοδα",
        "Raporlar": "Αναφορές",
        "Ayarlar": "Ρυθμίσεις",
        "Kredi kartı": "Πιστωτική κάρτα",
        "Ev kredisi": "Στεγαστικό δάνειο",
        "Çek": "Επιταγή",
        "Senet": "Γραμμάτιο",
        "Son ödeme tarihi": "Ημερομηνία λήξης",
        "Gecikmede": "Σε καθυστέρηση",
        "Fatura": "Λογαριασμός",
        "Gelir": "Εισόδημα",
        "Gider": "Δαπάνη",
        "Ödeme": "Πληρωμή",
        "ONAYLIYORUM": "ΕΠΙΒΕΒΑΙΩΝΩ",
    }
    for key, expected in required_terms.items():
        if values.get(key) != expected:
            failures.append(f"Native Greek terminology mismatch for {key!r}: {values.get(key)!r}")

    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'el'",
        "static bool get isGreek",
        "mizanGreek[visibleSource]",
        "translateGreekReviewedDynamic(",
        "'el' => 'ΕΠΙΒΕΒΑΙΩΝΩ'",
        "normalized.startsWith('el-')",
    ):
        if marker not in i18n:
            failures.append(f"Missing Greek runtime marker: {marker}")

    main = (LIB / "main.dart").read_text(encoding="utf-8")
    for marker in ("'el' => const Locale('el', 'GR')", "Locale('el', 'GR')"):
        if marker not in main:
            failures.append(f"Missing Greek Flutter locale marker: {marker}")

    dynamic = GREEK_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("Απομένει 1 ημέρα", "εγγραφές", "_people(m[1]!)"):
        if marker not in dynamic:
            failures.append(f"Missing Greek dynamic grammar marker: {marker}")

    formatter = (LIB / "core" / "formatters.dart").read_text(encoding="utf-8")
    for marker in ("MizanI18n.isGreek", "'$amount\\u00A0€'", "'Μάρτιος'", "'Μαρ'"):
        if marker not in formatter:
            failures.append(f"Missing Greek formatting marker: {marker}")

    catalog_model = (LIB / "global" / "global_catalog.dart").read_text(encoding="utf-8")
    if catalog_model.count("nameEl") < 15:
        failures.append("Greek catalog model fields are incomplete")

    for filename, expected_count in (
        ("languages_v1.json", 29),
        ("countries_v1.json", 161),
        ("currencies_v1.json", 154),
    ):
        payload = load_json(ROOT / "assets" / "data" / filename)
        items = payload.get("items", [])
        if len(items) != expected_count:
            failures.append(f"{filename} item count changed: {len(items)}")
        missing_names = [str(item.get("code")) for item in items if not item.get("nameEl")]
        if missing_names:
            failures.append(f"{filename} missing nameEl: {missing_names[:20]}")

    if failures:
        raise SystemExit("\n".join(failures))
    print(
        f"Greek locale verified: {len(greek)} static values, 29 languages, 161 countries, 154 currencies."
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
