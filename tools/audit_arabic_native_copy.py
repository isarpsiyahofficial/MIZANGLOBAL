from __future__ import annotations

import re
from collections import Counter

from build_arabic_locale import arabic_pairs


REQUIRED_TERMS = {
    "Ana sayfa": "الصفحة الرئيسية",
    "Kayıtlar": "السجلات",
    "Giderler": "المصروفات",
    "Raporlar": "التقارير",
    "Ayarlar": "الإعدادات",
    "Kaydet": "حفظ",
    "Sil": "حذف",
    "Ödeme": "دفعة",
    "Gider": "مصروف",
    "Gelir": "دخل",
    "Fatura": "فاتورة",
    "Abonelik": "اشتراك",
    "Kredi kartı": "بطاقة ائتمان",
    "Ev kredisi": "قرض سكني",
    "KMH hesabı": "حساب سحب على المكشوف",
    "Çek": "شيك مصرفي",
    "Senet": "سند لأمر",
    "Gecikmede": "متأخر",
    "Son ödeme tarihi": "تاريخ الاستحقاق",
    "ONAYLIYORUM": "أؤكد",
}

ALLOWED_IDENTICAL = {
    "MİZAN GLOBAL",
    "LEFFERION PRIME - MIZAN",
    "LEFFERION PRIME - MİZAN",
    "IBAN",
}

ARABIC_SCRIPT = re.compile(r"[\u0600-\u06FF]")
HEBREW_SCRIPT = re.compile(r"[\u0590-\u05FF]")
PERSIAN_URDU_ONLY = re.compile(r"[پچژگکھیےٹڈڑںھۂۃۀ]")

TURKISH_LEAKS = (
    "ana sayfa",
    "kayıtlar",
    "giderler",
    "raporlar",
    "ayarlar",
    "kaydet",
    "vazgeç",
    "ödeme",
    "borç",
    "fatura",
    "abonelik",
    "gecikme",
    "bildirim",
    "kalan tutar",
    "kişi seçin",
    "bulunmuyor",
    "boş bırakılamaz",
    "sıfırdan büyük",
)

OTHER_LANGUAGE_LEAKS = (
    "settings",
    "payments",
    "expenses",
    "reports",
    "настройки",
    "платежи",
    "расходы",
    "звіти",
    "налаштування",
    "پرداخت",
    "تنظیمات",
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    pairs = arabic_pairs()
    require(len(pairs) == 791, f"Expected 791 Arabic values, found {len(pairs)}")
    values = dict(pairs)
    require(len(values) == 791, "Arabic source contains duplicate keys")

    for source, expected in REQUIRED_TERMS.items():
        require(
            values.get(source) == expected,
            f"Binding Arabic terminology mismatch for {source!r}: {values.get(source)!r}",
        )

    identical = [
        source
        for source, value in pairs
        if source == value and source not in ALLOWED_IDENTICAL
    ]
    require(not identical, f"Untranslated Arabic static values: {identical[:30]}")

    bad_script = [
        (source, value)
        for source, value in pairs
        if HEBREW_SCRIPT.search(value) or PERSIAN_URDU_ONLY.search(value)
    ]
    require(
        not bad_script,
        f"Hebrew/Persian/Urdu script leaked into Arabic: {bad_script[:15]}",
    )

    lowered = [(source, value, value.casefold()) for source, value in pairs]
    for fragment in (*TURKISH_LEAKS, *OTHER_LANGUAGE_LEAKS):
        hits = [(source, value) for source, value, folded in lowered if fragment in folded]
        require(not hits, f"Other-language UI copy leaked ({fragment}): {hits[:10]}")

    arabic_signal_count = sum(bool(ARABIC_SCRIPT.search(value)) for _, value in pairs)
    require(
        arabic_signal_count >= 780,
        f"Arabic orthographic coverage is unexpectedly weak: {arabic_signal_count}",
    )

    repeated = Counter(value for _, value in pairs)
    suspicious_repetition = [
        (value, count)
        for value, count in repeated.items()
        if count >= 7 and value not in {"غير محدد", "لا توجد سجلات."}
    ]
    require(
        not suspicious_repetition,
        f"Suspiciously repeated Arabic translations: {suspicious_repetition[:10]}",
    )

    fallback = values[
        "Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır."
    ]
    require(
        "جدولة تقريبية" in fallback,
        "Arabic notification copy contradicts the Android inexact fallback",
    )
    require(
        "لا يستخدم" not in fallback,
        "Stale no-fallback notification wording leaked into Arabic",
    )

    print(
        "Arabic native-copy audit passed: 791/791 values, binding terminology, "
        "Modern Standard Arabic script purity and notification semantics verified."
    )


if __name__ == "__main__":
    main()
