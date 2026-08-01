#!/usr/bin/env python3
"""Add committed Brazilian Portuguese display names to the global catalogs.

Babel/CLDR is used only as a deterministic generation source. The resulting
names are written into the repository so runtime remains completely offline.
"""
from __future__ import annotations

import json
import unicodedata
from pathlib import Path
from typing import Any

from babel import Locale

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets/data"
LOCALE = Locale.parse("pt_BR")

COUNTRY_OVERRIDES = {
    "CI": "Costa do Marfim",
    "CD": "República Democrática do Congo",
    "CG": "República do Congo",
    "CV": "Cabo Verde",
    "CZ": "Tchéquia",
    "GQ": "Guiné Equatorial",
    "KR": "Coreia do Sul",
    "KP": "Coreia do Norte",
    "PS": "Territórios Palestinos",
    "ST": "São Tomé e Príncipe",
    "TL": "Timor-Leste",
    "TR": "Turquia",
    "VA": "Cidade do Vaticano",
}

LANGUAGE_OVERRIDES = {
    "tr": "turco",
    "en": "inglês",
    "es": "espanhol",
    "pt-BR": "português (Brasil)",
    "pt-PT": "português (Portugal)",
    "fr": "francês",
    "de": "alemão",
    "it": "italiano",
    "nl": "neerlandês",
    "pl": "polonês",
    "ro": "romeno",
    "el": "grego",
    "ru": "russo",
    "uk": "ucraniano",
    "ar": "árabe",
    "fa": "persa",
    "he": "hebraico",
    "hi": "híndi",
    "bn": "bengali",
    "ur": "urdu",
    "id": "indonésio",
    "ms": "malaio",
    "fil": "filipino",
    "vi": "vietnamita",
    "th": "tailandês",
    "sw": "suaíli",
    "zh": "chinês",
    "ja": "japonês",
    "ko": "coreano",
}

CURRENCY_OVERRIDES = {
    "BRL": "real brasileiro",
    "CVE": "escudo cabo-verdiano",
    "EUR": "euro",
    "GBP": "libra esterlina",
    "MZN": "metical moçambicano",
    "STN": "dobra são-tomense",
    "TRY": "lira turca",
    "USD": "dólar americano",
    "XAF": "franco CFA da África Central",
    "XCD": "dólar do Caribe Oriental",
    "XCG": "florim caribenho",
    "XOF": "franco CFA da África Ocidental",
    "XPF": "franco CFP",
    "ZWG": "ouro do Zimbábue",
}


def _load(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _save(path: Path, payload: dict[str, Any]) -> None:
    path.write_text(
        json.dumps(payload, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )


def _normalize(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value.casefold())
    return "".join(char for char in decomposed if not unicodedata.combining(char))


def _append_alias(item: dict[str, Any], value: str) -> None:
    aliases = item.setdefault("aliases", [])
    candidates = [value, value.casefold(), _normalize(value)]
    for candidate in candidates:
        if candidate and candidate not in aliases:
            aliases.append(candidate)


def generate_languages() -> None:
    path = DATA / "languages_v1.json"
    payload = _load(path)
    items = payload.get("items", [])
    if payload.get("count") != 29 or len(items) != 29:
        raise SystemExit("Unexpected language catalog size")
    for item in items:
        code = str(item["code"])
        base = code.split("-", 1)[0]
        name = LANGUAGE_OVERRIDES.get(code) or str(LOCALE.languages.get(base) or "")
        if not name:
            raise SystemExit(f"Missing pt-BR language name for {code}")
        item["namePtBr"] = name
    _save(path, payload)


def generate_countries() -> None:
    path = DATA / "countries_v1.json"
    payload = _load(path)
    items = payload.get("items", [])
    if payload.get("count") != 161 or len(items) != 161:
        raise SystemExit("Unexpected country catalog size")
    for item in items:
        code = str(item["code"])
        name = COUNTRY_OVERRIDES.get(code) or str(LOCALE.territories.get(code) or "")
        if not name:
            raise SystemExit(f"Missing pt-BR country name for {code}")
        item["namePtBr"] = name
    _save(path, payload)


def generate_currencies() -> None:
    path = DATA / "currencies_v1.json"
    payload = _load(path)
    items = payload.get("items", [])
    if payload.get("count") != 154 or len(items) != 154:
        raise SystemExit("Unexpected currency catalog size")
    for item in items:
        code = str(item["code"])
        name = CURRENCY_OVERRIDES.get(code) or str(LOCALE.currencies.get(code) or "")
        if not name:
            raise SystemExit(f"Missing pt-BR currency name for {code}")
        item["namePtBr"] = name
        _append_alias(item, name)
    _save(path, payload)


def main() -> None:
    generate_languages()
    generate_countries()
    generate_currencies()
    print("Generated fixed pt-BR names for 29 languages, 161 countries and 154 currencies")


if __name__ == "__main__":
    main()
