#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

from babel import Locale

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets" / "data"
OUT = ROOT / "lib" / "l10n" / "vi" / "mizan_vi_catalog.dart"
VI = Locale.parse("vi")


def items(name: str) -> list[dict]:
    payload = json.loads((DATA / name).read_text(encoding="utf-8"))
    return list(payload["items"])


def dart(value: str) -> str:
    return value.replace("\\", "\\\\").replace("'", "\\'")


def language_name(code: str) -> str:
    # Babel/CLDR is the independent source for static Vietnamese catalog labels.
    try:
        loc = Locale.parse(code.replace("-", "_"))
        value = loc.get_display_name(VI)
    except Exception as exc:
        raise RuntimeError(f"No CLDR Vietnamese language name for {code}: {exc}") from exc
    value = (value or "").strip()
    if not value or value.casefold() == code.casefold():
        raise RuntimeError(f"Unresolved Vietnamese language name: {code} -> {value!r}")
    return value[0].upper() + value[1:] if value else value


def territory_name(code: str) -> str:
    value = str(VI.territories.get(code, "")).strip()
    if not value or value.casefold() == code.casefold():
        raise RuntimeError(f"Unresolved Vietnamese territory name: {code} -> {value!r}")
    return value


def currency_name(code: str) -> str:
    value = str(VI.currencies.get(code, "")).strip()
    if not value or value.casefold() == code.casefold():
        raise RuntimeError(f"Unresolved Vietnamese currency name: {code} -> {value!r}")
    return value


def emit_map(name: str, pairs: list[tuple[str, str]]) -> str:
    rows = [f"  '{dart(code)}': '{dart(value)}'," for code, value in pairs]
    return f"const Map<String, String> {name} = <String, String>{{\n" + "\n".join(rows) + "\n};\n"


def main() -> None:
    languages = items("languages_v1.json")
    countries = items("countries_v1.json")
    currencies = items("currencies_v1.json")
    assert len(languages) == 29, len(languages)
    assert len(countries) == 161, len(countries)
    assert len(currencies) == 154, len(currencies)

    language_pairs = [(row["code"], language_name(row["code"])) for row in languages]
    country_pairs = [(row["code"], territory_name(row["code"])) for row in countries]
    currency_pairs = [(row["code"], currency_name(row["code"])) for row in currencies]

    for label, pairs, expected in (
        ("languages", language_pairs, 29),
        ("countries", country_pairs, 161),
        ("currencies", currency_pairs, 154),
    ):
        if len(pairs) != expected or len({code for code, _ in pairs}) != expected:
            raise RuntimeError(f"Vietnamese {label} catalog cardinality/uniqueness failure")
        if any(not value.strip() for _, value in pairs):
            raise RuntimeError(f"Vietnamese {label} catalog contains an empty label")

    content = (
        "// GENERATED FROM PINNED CLDR DATA THROUGH BABEL FOR VIETNAMESE.\n"
        "// OFFLINE RUNTIME DATA: 29 languages / 161 countries / 154 currencies.\n\n"
        + emit_map("vietnameseLanguageNames", language_pairs)
        + "\n"
        + emit_map("vietnameseCountryNames", country_pairs)
        + "\n"
        + emit_map("vietnameseCurrencyNames", currency_pairs)
    )
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(content, encoding="utf-8")
    print(f"Wrote {OUT.relative_to(ROOT)}: {len(language_pairs)}/{len(country_pairs)}/{len(currency_pairs)}")


if __name__ == "__main__":
    main()
