#!/usr/bin/env python3
"""Build and verify the reviewed France-oriented French locale."""
from __future__ import annotations

import argparse
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
I18N = LIB / "l10n" / "mizan_i18n.dart"
FRENCH = LIB / "l10n" / "mizan_fr.dart"
FRENCH_DYNAMIC = LIB / "l10n" / "mizan_fr_dynamic.dart"
PARTS = tuple(sorted((LIB / "l10n" / "fr").glob("mizan_fr_*.dart")))


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
    source = I18N.read_text(encoding="utf-8")
    return parse_map(source, "static const Map<String, String> _english")


def french_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanFrench\w+)", source)
        if marker is None:
            raise SystemExit(f"French map marker missing: {path.relative_to(ROOT)}")
        result.extend(parse_map(source, marker.group(0)))
    return result


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    if text.count(old) != 1:
        raise SystemExit(
            f"Expected one integration target in {path.relative_to(ROOT)}: {old[:100]!r}"
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
        "import 'mizan_pt_pt_dynamic.dart';",
        "import 'mizan_pt_pt_dynamic.dart';\nimport 'mizan_fr.dart';\nimport 'mizan_fr_dynamic.dart';",
    )
    replace_once(
        I18N,
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT'};",
        "static const supportedLanguageTags = <String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl'};",
    )
    replace_once(
        I18N,
        "  static bool get isPortuguesePt => _languageTag == 'pt-PT';\n",
        "  static bool get isPortuguesePt => _languageTag == 'pt-PT';\n  static bool get isFrench => _languageTag == 'fr';\n",
    )
    replace_once(
        I18N,
        "    'pt-PT' => 'CONFIRMO',\n",
        "    'pt-PT' => 'CONFIRMO',\n    'fr' => 'JE CONFIRME',\n",
    )
    replace_once(
        I18N,
        "    if (normalized == 'pt-pt') return 'pt-PT';\n",
        "    if (normalized == 'pt-pt') return 'pt-PT';\n    if (normalized == 'fr' || normalized.startsWith('fr-')) return 'fr';\n",
    )
    replace_once(
        I18N,
        "        normalized == 'pt-pt';\n",
        "        normalized == 'pt-pt' ||\n        normalized == 'fr' ||\n        normalized.startsWith('fr-');\n",
    )
    replace_once(
        I18N,
        """    } else {
      result =
          mizanPortuguesePt[visibleSource] ??
          translatePortuguesePtReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pt-PT'),
          );
    }
""",
        """    } else if (effective == 'pt-PT') {
      result =
          mizanPortuguesePt[visibleSource] ??
          translatePortuguesePtReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'pt-PT'),
          );
    } else {
      result =
          mizanFrench[visibleSource] ??
          translateFrenchReviewedDynamic(
            visibleSource,
            (value) => text(value, languageTag: 'fr'),
          );
    }
""",
    )

    main = LIB / "main.dart"
    replace_once(
        main,
        "          Locale('pt', 'PT'),\n",
        "          Locale('pt', 'PT'),\n          Locale('fr'),\n",
    )


def integrate_catalog_model() -> None:
    path = LIB / "global" / "global_catalog.dart"
    replace_all(
        path,
        "    required this.namePtPt,\n",
        "    required this.namePtPt,\n    required this.nameFr,\n",
        3,
    )
    replace_all(
        path,
        "  final String namePtPt;\n",
        "  final String namePtPt;\n  final String nameFr;\n",
        3,
    )
    replace_all(
        path,
        "    namePtPt: json['namePtPt']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        "    namePtPt: json['namePtPt']?.toString() ?? json['nameEn']?.toString() ?? '',\n    nameFr: json['nameFr']?.toString() ?? json['nameEn']?.toString() ?? '',\n",
        3,
    )
    replace_all(
        path,
        "    'pt-PT' => namePtPt,\n",
        "    'pt-PT' => namePtPt,\n    'fr' => nameFr,\n",
        3,
    )
    replace_once(
        path,
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt'",
        "'$code $nativeName $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr'",
    )
    replace_once(
        path,
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nativeName'",
        "'$code $nameTr $nameEn $nameEs $namePtBr $namePtPt $nameFr $nativeName'",
    )
    replace_once(
        path,
        "      namePtPt,\n      ...symbols,",
        "      namePtPt,\n      nameFr,\n      ...symbols,",
    )


def integrate_formatters() -> None:
    path = LIB / "core" / "formatters.dart"
    replace_once(
        path,
        """  final groupSeparator = MizanI18n.isEnglish
      ? ','
      : (MizanI18n.isPortuguesePt ? ' ' : '.');
""",
        """  final groupSeparator = MizanI18n.isEnglish
      ? ','
      : (MizanI18n.isFrench
            ? '\\u202F'
            : (MizanI18n.isPortuguesePt ? ' ' : '.'));
""",
    )
    replace_once(
        path,
        """  if (MizanI18n.isPortuguesePt && code == 'EUR') {
    return '$amount €';
  }
  return '$code $amount';
""",
        """  if (MizanI18n.isPortuguesePt && code == 'EUR') {
    return '$amount €';
  }
  if (MizanI18n.isFrench) {
    return code == 'EUR' ? '$amount\\u00A0€' : '$amount\\u00A0$code';
  }
  return '$code $amount';
""",
    )
    replace_once(
        path,
        """  const ptBrMonths = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
""",
        """  const ptBrMonths = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  const frMonths = [
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
    )
    replace_once(
        path,
        """  final months = MizanI18n.isSpanish
      ? esMonths
      : ((MizanI18n.isPortugueseBr || MizanI18n.isPortuguesePt)
            ? ptBrMonths
            : trMonths);
""",
        """  final months = MizanI18n.isSpanish
      ? esMonths
      : (MizanI18n.isFrench
            ? frMonths
            : ((MizanI18n.isPortugueseBr || MizanI18n.isPortuguesePt)
                  ? ptBrMonths
                  : trMonths));
""",
    )
    replace_once(
        path,
        """  const ptBrMonths = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
""",
        """  const ptBrMonths = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  const frMonths = [
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
    )
    replace_once(
        path,
        """  if (MizanI18n.isSpanish) {
    return '${esMonths[value.month - 1]} de ${value.year}';
  }
""",
        """  if (MizanI18n.isSpanish) {
    return '${esMonths[value.month - 1]} de ${value.year}';
  }
  if (MizanI18n.isFrench) {
    return '${frMonths[value.month - 1]} ${value.year}';
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

    locale = Locale.parse("fr_FR")
    language_overrides = {
        "pt-BR": "portugais (Brésil)",
        "pt-PT": "portugais (Portugal)",
        "fil": "filipino",
        "fr": "français",
    }
    country_overrides = {
        "CI": "Côte d’Ivoire",
        "CD": "République démocratique du Congo",
        "CG": "République du Congo",
        "CV": "Cap-Vert",
        "CZ": "Tchéquie",
        "KR": "Corée du Sud",
        "KP": "Corée du Nord",
        "PS": "Territoires palestiniens",
        "ST": "Sao Tomé-et-Principe",
        "TL": "Timor oriental",
        "TR": "Turquie",
        "VA": "Cité du Vatican",
    }
    currency_overrides = {
        "BRL": "réal brésilien",
        "EUR": "euro",
        "GBP": "livre sterling",
        "TRY": "livre turque",
        "USD": "dollar des États-Unis",
        "CVE": "escudo cap-verdien",
        "MZN": "metical mozambicain",
        "STN": "dobra de Sao Tomé-et-Principe",
        "XAF": "franc CFA (BEAC)",
        "XCD": "dollar des Caraïbes orientales",
        "XCG": "florin caribéen",
        "XOF": "franc CFA (BCEAO)",
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
            raise SystemExit(f"Missing French language name for {code}")
        item["nameFr"] = name
    save_json(languages_path, languages)

    countries_path = ROOT / "assets" / "data" / "countries_v1.json"
    countries = load_json(countries_path)
    for item in countries["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = country_overrides.get(code) or str(locale.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing French country name for {code}")
        item["nameFr"] = name
    save_json(countries_path, countries)

    currencies_path = ROOT / "assets" / "data" / "currencies_v1.json"
    currencies = load_json(currencies_path)
    for item in currencies["items"]:  # type: ignore[index]
        code = str(item["code"])
        name = currency_overrides.get(code) or str(locale.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing French currency name for {code}")
        item["nameFr"] = name
        aliases = item.setdefault("aliases", [])
        common_french_aliases = {
            "USD": (
                "dollar américain",
                "dollar americain",
                "dollar États-Unis",
                "dollar etats unis",
                "dollar etats",
                "dollar US",
            ),
            "EUR": ("monnaie européenne", "monnaie europeenne"),
            "GBP": ("livre anglaise", "pound sterling"),
            "TRY": ("lira turque", "livre de Turquie"),
        }
        for alias in (
            name,
            name.casefold(),
            normal(name),
            *common_french_aliases.get(code, ()),
        ):
            if alias and alias not in aliases:
                aliases.append(alias)
    save_json(currencies_path, currencies)


def update_regressions() -> None:
    for root in (ROOT / "test", ROOT / "tools"):
        for path in root.rglob("*"):
            if path.suffix not in {".dart", ".py"} or path == Path(__file__):
                continue
            text = path.read_text(encoding="utf-8")
            text = text.replace(
                "{'tr', 'en', 'es', 'pt-BR', 'pt-PT'}",
                "{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl'}",
            )
            text = text.replace(
                "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT'}",
                "<String>{'tr', 'en', 'es', 'pt-BR', 'pt-PT', 'fr', 'de', 'it', 'nl'}",
            )
            if path.suffix == ".py" and "lib/l10n/mizan_fr.dart" not in text:
                anchor = '"lib/l10n/mizan_pt_pt_dynamic.dart",'
                if anchor in text:
                    additions = "\n".join(
                        [
                            anchor,
                            '        "lib/l10n/mizan_fr.dart",',
                            '        "lib/l10n/mizan_fr_dynamic.dart",',
                            '        "lib/l10n/fr/mizan_fr_core.dart",',
                            '        "lib/l10n/fr/mizan_fr_validation.dart",',
                            '        "lib/l10n/fr/mizan_fr_dashboard.dart",',
                            '        "lib/l10n/fr/mizan_fr_records.dart",',
                            '        "lib/l10n/fr/mizan_fr_reports.dart",',
                            '        "lib/l10n/fr/mizan_fr_settings.dart",',
                        ]
                    )
                    text = text.replace(anchor, additions)
            path.write_text(text, encoding="utf-8")


def verify() -> None:
    english = english_pairs()
    french = french_pairs()
    english_keys = [key for key, _ in english]
    french_keys = [key for key, _ in french]
    failures: list[str] = []

    if len(english) != 791:
        failures.append(f"English reference map changed: {len(english)} keys")
    if len(french) != 791:
        failures.append(f"French map must contain 791 values, found {len(french)}")
    duplicates = sorted({key for key in french_keys if french_keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate French keys: {duplicates[:20]}")
    missing = sorted(set(english_keys) - set(french_keys))
    extra = sorted(set(french_keys) - set(english_keys))
    if missing or extra:
        failures.append(f"French/English key mismatch; missing={missing[:20]}, extra={extra[:20]}")

    values = dict(french)
    required = {
        "Ana sayfa": "Accueil",
        "Kayıtlar": "Dossiers",
        "Giderler": "Dépenses",
        "Raporlar": "Rapports",
        "Ayarlar": "Paramètres",
        "Kaydet": "Enregistrer",
        "Sil": "Supprimer",
        "Gelir": "Revenu",
        "Abonelik": "Abonnement",
        "Ev kredisi": "Crédit immobilier",
        "KMH hesabı": "Compte avec découvert autorisé",
        "ONAYLIYORUM": "JE CONFIRME",
    }
    for key, expected in required.items():
        if values.get(key) != expected:
            failures.append(f"Native French terminology mismatch for {key!r}: {values.get(key)!r}")

    forbidden = re.compile(
        r"\b(?:Ayarlar|Kaydet|Sil|Giderler|Raporlar|Gelir|Abonelik|"
        r"Settings|Save|Delete|Expenses|Reports|Income|Subscription|"
        r"Configurações|Guardar|Eliminar|Despesas|Rendimentos|Subscrição|"
        r"Inicio|Registros|Gastos|Ajustes|Ingresos|Suscripción)\b",
        re.IGNORECASE,
    )
    leaks = [(key, value) for key, value in french if forbidden.search(value)]
    if leaks:
        failures.append(f"Foreign-language leakage in French values: {leaks[:20]}")
    empty = [key for key, value in french if not value.strip()]
    if empty:
        failures.append(f"Empty French values: {empty[:20]}")

    i18n = I18N.read_text(encoding="utf-8")
    for marker in (
        "'fr'",
        "static bool get isFrench",
        "mizanFrench[visibleSource]",
        "translateFrenchReviewedDynamic(",
        "'fr' => 'JE CONFIRME'",
    ):
        if marker not in i18n:
            failures.append(f"Missing French runtime marker: {marker}")
    dynamic = FRENCH_DYNAMIC.read_text(encoding="utf-8")
    for marker in ("Il reste", "1er", "sélectionnée", "nouveaux éléments"):
        if marker not in dynamic:
            failures.append(f"Missing French dynamic grammar marker: {marker}")

    for filename, expected_count in (
        ("languages_v1.json", 29),
        ("countries_v1.json", 161),
        ("currencies_v1.json", 154),
    ):
        payload = load_json(ROOT / "assets" / "data" / filename)
        items = payload["items"]  # type: ignore[index]
        if payload.get("count") != expected_count or len(items) != expected_count:
            failures.append(f"Unexpected catalog size: {filename}")
        missing_names = [item.get("code") for item in items if not str(item.get("nameFr", "")).strip()]
        if missing_names:
            failures.append(f"Missing nameFr in {filename}: {missing_names[:20]}")

    if failures:
        print("French localization verification failed:")
        for failure in failures:
            print(f"- {failure}")
        raise SystemExit(1)
    print("French verification passed: 791/791 static values, dynamic grammar, runtime and catalogs")


def build() -> None:
    # Validate the manually reviewed source before mutating product files.
    english = english_pairs()
    french = french_pairs()
    if len(english) != 791 or len(french) != 791:
        print(f"Pre-integration key counts: English={len(english)}, French={len(french)}")
        missing = sorted(set(key for key, _ in english) - set(key for key, _ in french))
        extra = sorted(set(key for key, _ in french) - set(key for key, _ in english))
        print(f"Missing French keys: {missing}")
        print(f"Extra French keys: {extra}")
        raise SystemExit(1)
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
