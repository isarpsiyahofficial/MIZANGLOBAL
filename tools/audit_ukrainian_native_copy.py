from __future__ import annotations

import re
from collections import Counter

from build_ukrainian_locale import ukrainian_pairs


REQUIRED_TERMS = {
    "Ana sayfa": "Головна",
    "Kayıtlar": "Записи",
    "Giderler": "Витрати",
    "Raporlar": "Звіти",
    "Ayarlar": "Налаштування",
    "Kaydet": "Зберегти",
    "Sil": "Видалити",
    "Ödeme": "Платіж",
    "Gider": "Витрата",
    "Gelir": "Дохід",
    "Fatura": "Рахунок",
    "Abonelik": "Підписка",
    "Kredi kartı": "Кредитна картка",
    "Ev kredisi": "Іпотечний кредит",
    "KMH hesabı": "Рахунок з овердрафтом",
    "Çek": "Банківський чек",
    "Senet": "Боргова розписка",
    "Gecikmede": "Прострочено",
    "Son ödeme tarihi": "Строк оплати",
    "ONAYLIYORUM": "ПІДТВЕРДЖУЮ",
}

ALLOWED_IDENTICAL = {
    "MİZAN GLOBAL",
    "LEFFERION PRIME - MIZAN",
    "LEFFERION PRIME - MİZAN",
    "IBAN",
}

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

RUSSIAN_LEAKS = (
    "настройки",
    "платёж",
    "платежи",
    "расходы",
    "доходы",
    "счёт",
    "отчёт",
    "просрочено",
    "уведомление",
    "сохранить",
    "удалить",
    "подтверждаю",
)

RUSSIAN_ONLY_LETTERS = re.compile(r"[ыэёъЫЭЁЪ]")
UKRAINIAN_SIGNAL = re.compile(r"[іїєґІЇЄҐ]")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    pairs = ukrainian_pairs()
    require(len(pairs) == 791, f"Expected 791 Ukrainian values, found {len(pairs)}")

    values = dict(pairs)
    require(len(values) == 791, "Ukrainian source contains duplicate keys")

    for source, expected in REQUIRED_TERMS.items():
        require(
            values.get(source) == expected,
            f"Binding Ukrainian terminology mismatch for {source!r}: {values.get(source)!r}",
        )

    identical = [
        source
        for source, value in pairs
        if source == value and source not in ALLOWED_IDENTICAL
    ]
    require(not identical, f"Untranslated Ukrainian static values: {identical[:30]}")

    russian_letters = [
        (source, value) for source, value in pairs if RUSSIAN_ONLY_LETTERS.search(value)
    ]
    require(
        not russian_letters,
        f"Russian-only letters leaked into Ukrainian: {russian_letters[:15]}",
    )

    lowered = [(source, value, value.casefold()) for source, value in pairs]
    for fragment in TURKISH_LEAKS:
        hits = [(source, value) for source, value, folded in lowered if fragment in folded]
        require(not hits, f"Turkish UI copy leaked ({fragment}): {hits[:10]}")
    for fragment in RUSSIAN_LEAKS:
        hits = [(source, value) for source, value, folded in lowered if fragment in folded]
        require(not hits, f"Russian UI copy leaked ({fragment}): {hits[:10]}")

    ukrainian_signal_count = sum(bool(UKRAINIAN_SIGNAL.search(value)) for _, value in pairs)
    require(
        ukrainian_signal_count >= 300,
        f"Ukrainian orthographic signal is unexpectedly weak: {ukrainian_signal_count}",
    )

    repeated = Counter(value for _, value in pairs)
    suspicious_repetition = [
        (value, count)
        for value, count in repeated.items()
        if count >= 6 and value not in {"Не вказано", "Записів немає."}
    ]
    require(
        not suspicious_repetition,
        f"Suspiciously repeated Ukrainian translations: {suspicious_repetition[:10]}",
    )

    notification_fallback = values[
        "Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır."
    ]
    require(
        "приблизне планування" in notification_fallback,
        "Ukrainian notification copy contradicts the Android inexact fallback",
    )
    require(
        "не використовує" not in notification_fallback.casefold(),
        "Stale no-fallback notification wording leaked into Ukrainian",
    )

    print(
        "Ukrainian native-copy audit passed: 791/791 values, binding terminology, "
        "orthography, language purity and notification semantics verified."
    )


if __name__ == "__main__":
    main()
