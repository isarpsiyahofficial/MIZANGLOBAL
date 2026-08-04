from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCOPE_PATH = ROOT / "tools" / "ukrainian_localization_scope.json"
TERMS_PATH = ROOT / "tools" / "ukrainian_native_terms.json"
LANGUAGES_PATH = ROOT / "assets" / "data" / "languages_v1.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    scope = json.loads(SCOPE_PATH.read_text(encoding="utf-8"))
    terms_data = json.loads(TERMS_PATH.read_text(encoding="utf-8"))
    catalog = json.loads(LANGUAGES_PATH.read_text(encoding="utf-8"))

    require(scope["locale"] == "uk-UA", "Ukrainian locale must be uk-UA.")
    require(scope["languageCode"] == "uk", "Ukrainian language code must be uk.")
    require(scope["nativeName"] == "Українська", "Native name must be Українська.")
    require(
        scope["staticSourceTextCount"] == 791,
        "Ukrainian review scope must cover all 791 source texts.",
    )
    require(
        scope["cardinalPluralCategories"] == ["one", "few", "many", "other"],
        "Ukrainian cardinal plural categories are incomplete or reordered.",
    )
    require(
        set(scope["grammaticalCases"])
        == {
            "nominative",
            "vocative",
            "accusative",
            "genitive",
            "locative",
            "dative",
            "instrumental",
        },
        "Ukrainian grammatical case coverage is incomplete.",
    )
    require(
        set(scope["grammaticalGenders"])
        == {"masculine", "feminine", "neuter"},
        "Ukrainian grammatical gender coverage is incomplete.",
    )

    items = catalog["items"]
    codes = [item["code"] for item in items]
    require(catalog["count"] == len(items), "Language catalog count does not match items.")
    require("ru" in codes and "uk" in codes, "Russian/Ukrainian catalog entries are missing.")
    require(
        codes.index("uk") == codes.index("ru") + 1,
        "Ukrainian must remain the immediate catalog successor to Russian.",
    )
    ukrainian = items[codes.index("uk")]
    require(ukrainian["nativeName"] == "Українська", "Catalog native name is incorrect.")
    require(ukrainian["nameTr"] == "Ukraynaca", "Turkish catalog name is incorrect.")
    require(ukrainian["nameEn"] == "Ukrainian", "English catalog name is incorrect.")
    require(ukrainian["countryCodes"] == ["UA"], "Ukrainian country mapping must be UA.")

    areas = set(scope["requiredProductAreas"])
    for required in {
        "notifications",
        "reports",
        "charts",
        "pdf",
        "csv",
        "storage",
        "country-language-currency-pickers",
    }:
        require(required in areas, f"Missing Ukrainian acceptance area: {required}")

    rules = "\n".join(scope["mandatoryQualityRules"])
    require("Russian" in rules, "Russian-to-Ukrainian language purity rule is missing.")
    require("byte-for-byte" in rules, "User-entered text preservation rule is missing.")
    require("runtime activation" in rules, "Premature activation block is missing.")

    require(terms_data["locale"] == "uk-UA", "Glossary locale must be uk-UA.")
    terms = terms_data["terms"]
    require(len(terms) >= 40, "Initial Ukrainian glossary must contain at least 40 reviewed terms.")
    sources = [entry["source"] for entry in terms]
    translations = [entry["uk"] for entry in terms]
    require(len(sources) == len(set(sources)), "Initial glossary contains duplicate source terms.")
    require(
        all(entry["context"].strip() for entry in terms),
        "Every Ukrainian glossary item must include a usage context.",
    )
    require(
        all(re.search(r"[А-ЩЬЮЯЄІЇҐа-щьюяєіїґ]", value) for value in translations),
        "Every initial Ukrainian term must contain Ukrainian Cyrillic text.",
    )
    require(
        all("ы" not in value.lower() and "э" not in value.lower() and "ъ" not in value.lower() for value in translations),
        "Russian-only Cyrillic letters were found in the Ukrainian glossary.",
    )
    for mandatory in {
        "Платіж",
        "Борг",
        "Прострочено",
        "Сповіщення",
        "Звіти",
        "Налаштування",
    }:
        require(mandatory in translations, f"Missing reviewed Ukrainian core term: {mandatory}")

    print(
        "Ukrainian localization start verified: catalog order, 791-text scope, "
        "plural/case/gender rules and the initial native product glossary are locked."
    )


if __name__ == "__main__":
    main()
