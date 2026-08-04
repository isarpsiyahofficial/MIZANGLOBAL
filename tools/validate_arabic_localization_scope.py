from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCOPE_PATH = ROOT / "tools" / "arabic_localization_scope.json"
TERMS_PATH = ROOT / "tools" / "arabic_product_terms.json"
LANGUAGES_PATH = ROOT / "assets" / "data" / "languages_v1.json"

ARABIC_SCRIPT = re.compile(r"[\u0600-\u06FF]")
HEBREW_SCRIPT = re.compile(r"[\u0590-\u05FF]")
PERSIAN_URDU_ONLY = re.compile(r"[پچژگکھیےٹڈڑںھۂۃۀ]")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    scope = json.loads(SCOPE_PATH.read_text(encoding="utf-8"))
    terms = json.loads(TERMS_PATH.read_text(encoding="utf-8"))
    catalog = json.loads(LANGUAGES_PATH.read_text(encoding="utf-8"))

    require(scope["locale"] == "ar", "Arabic product language tag must remain ar.")
    require(
        scope["referenceLocale"] == "ar-SA",
        "Arabic reference locale must remain ar-SA until runtime formats are reviewed.",
    )
    require(scope["nativeName"] == "العربية", "Arabic native name is incorrect.")
    require(scope["textDirection"] == "rtl", "Arabic must be an RTL interface.")
    require(
        scope["staticSourceTextCount"] == 791,
        "Arabic review scope must cover all 791 source texts.",
    )
    require(
        scope["cardinalPluralCategories"]
        == ["zero", "one", "two", "few", "many", "other"],
        "Arabic cardinal plural categories are incomplete or reordered.",
    )
    require(
        scope["grammaticalNumbers"] == ["singular", "dual", "plural"],
        "Arabic singular/dual/plural coverage is incomplete.",
    )
    require(
        set(scope["grammaticalGenders"]) == {"masculine", "feminine"},
        "Arabic grammatical gender coverage is incomplete.",
    )

    bidi = scope["digitAndBidiPolicy"]
    require(bidi["mustNeverBeReversedManually"] is True, "Manual RTL reversal must remain forbidden.")
    required_ltr = {
        "ISO language codes",
        "ISO country codes",
        "ISO 4217 currency codes",
        "IBAN",
        "phone numbers",
        "record identifiers",
        "file names",
        "clock times",
        "user-authored Latin text",
    }
    require(
        required_ltr.issubset(set(bidi["mustRemainLTR"])),
        "Arabic bidi isolation coverage is incomplete.",
    )
    require(
        "byte-for-byte" in bidi["userAuthoredText"],
        "Arabic scope must preserve user-authored text byte-for-byte.",
    )

    items = catalog["items"]
    codes = [item["code"] for item in items]
    require(catalog["count"] == len(items), "Language catalog count does not match items.")
    for code in ("uk", "ar", "fa"):
        require(code in codes, f"Language catalog entry is missing: {code}")
    require(
        codes.index("ar") == codes.index("uk") + 1,
        "Arabic must remain the immediate catalog successor to Ukrainian.",
    )
    require(
        codes.index("fa") == codes.index("ar") + 1,
        "Persian must remain the immediate catalog successor to Arabic.",
    )
    arabic = items[codes.index("ar")]
    require(arabic["nativeName"] == "العربية", "Catalog Arabic native name is incorrect.")
    require(arabic["nameTr"] == "Arapça", "Catalog Turkish Arabic name is incorrect.")
    require(arabic["nameEn"] == "Arabic", "Catalog English Arabic name is incorrect.")
    require(
        len(arabic["countryCodes"]) >= 20,
        "Arabic catalog country coverage is unexpectedly narrow.",
    )

    product_terms = terms["terms"]
    require(terms["locale"] == "ar", "Arabic terminology locale is incorrect.")
    require(len(product_terms) >= 70, "Arabic bootstrap terminology must contain at least 70 contextual terms.")
    sources = [entry["source"] for entry in product_terms]
    translations = [entry["arabic"] for entry in product_terms]
    require(len(sources) == len(set(sources)), "Arabic terminology contains duplicate source terms.")
    for entry in product_terms:
        source = entry["source"].strip()
        translation = entry["arabic"].strip()
        context = entry["context"].strip()
        require(source, "Arabic terminology contains an empty source term.")
        require(translation, f"Arabic terminology is empty for {source!r}.")
        require(context, f"Arabic terminology has no product context for {source!r}.")
        require(
            ARABIC_SCRIPT.search(translation) is not None,
            f"Arabic terminology does not contain Arabic script for {source!r}: {translation!r}",
        )
        require(
            HEBREW_SCRIPT.search(translation) is None,
            f"Hebrew script leaked into Arabic terminology for {source!r}: {translation!r}",
        )
        require(
            PERSIAN_URDU_ONLY.search(translation) is None,
            f"Persian/Urdu-specific letters leaked into Arabic terminology for {source!r}: {translation!r}",
        )

    required_terms = {
        "Ana sayfa": "الصفحة الرئيسية",
        "Kayıtlar": "السجلات",
        "Giderler": "المصروفات",
        "Raporlar": "التقارير",
        "Ayarlar": "الإعدادات",
        "Ödeme": "دفعة",
        "Borç": "دين",
        "Fatura": "فاتورة",
        "Abonelik": "اشتراك",
        "Gecikmede": "متأخر",
        "Son ödeme tarihi": "تاريخ الاستحقاق",
        "Bildirim izni": "إذن الإشعارات",
        "Dakik bildirim izni": "إذن التنبيهات الدقيقة",
    }
    term_map = {entry["source"]: entry["arabic"] for entry in product_terms}
    for source, expected in required_terms.items():
        require(
            term_map.get(source) == expected,
            f"Binding Arabic terminology mismatch for {source!r}: {term_map.get(source)!r}",
        )

    areas = set(scope["requiredProductAreas"])
    for required in {
        "rtl-layout",
        "visual-baselines",
        "notifications",
        "reports",
        "charts",
        "pdf",
        "csv",
        "storage",
        "country-language-currency-pickers",
        "release-artifacts",
    }:
        require(required in areas, f"Missing Arabic acceptance area: {required}")

    rules = "\n".join(scope["mandatoryQualityRules"])
    for phrase in (
        "all 791",
        "six Arabic cardinal plural categories",
        "Flutter RTL directionality",
        "bidirectional isolation",
        "byte-for-byte",
        "fourteen integrated languages",
        "overdue-day",
        "background-notification",
    ):
        require(phrase in rules, f"Arabic binding quality rule is missing: {phrase}")

    require(len(set(translations)) >= 65, "Arabic terminology is suspiciously repetitive.")
    print(
        "Arabic localization scope verified: catalog order, RTL/bidi policy, 791 texts, "
        "six plural categories and contextual product terminology are locked."
    )


if __name__ == "__main__":
    main()
