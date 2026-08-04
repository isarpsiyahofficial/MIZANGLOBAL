from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCOPE_PATH = ROOT / "tools" / "ukrainian_localization_scope.json"
LANGUAGES_PATH = ROOT / "assets" / "data" / "languages_v1.json"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    scope = json.loads(SCOPE_PATH.read_text(encoding="utf-8"))
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

    print(
        "Ukrainian localization scope verified: catalog order, 791 texts, "
        "plural/case/gender rules and product acceptance areas are locked."
    )


if __name__ == "__main__":
    main()
