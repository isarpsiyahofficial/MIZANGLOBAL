#!/usr/bin/env python3
"""Strict native-copy and source-purity audit for the Persian locale."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from build_persian_locale import BIDI_CONTROLS, FORBIDDEN_PERSIAN, persian_pairs, verify  # noqa: E402

ALLOWED_IDENTICAL = {
    "MİZAN GLOBAL",
    "LEFFERION PRIME - MIZAN",
    "LEFFERION PRIME - MİZAN",
    "IBAN",
}
BANNED_VISIBLE = (
    "settings",
    "payment",
    "expense",
    "настройки",
    "платеж",
    "налаштування",
    "إعدادات",
    "الدفعات",
    "المصروفات",
)


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    verify()
    pairs = persian_pairs()
    identical = [key for key, value in pairs if key == value and key not in ALLOWED_IDENTICAL]
    if identical:
        fail(f"Untranslated Turkish Persian values remain: {identical[:30]}")

    joined = "\n".join(value for _, value in pairs)
    visible_hits = [word for word in BANNED_VISIBLE if word.casefold() in joined.casefold()]
    if visible_hits:
        fail(f"Other-language visible product copy leaked into Persian: {visible_hits}")
    if any(char in joined for char in FORBIDDEN_PERSIAN):
        fail("Arabic/Urdu character variants leaked into Persian static values")
    if any(char in joined for char in BIDI_CONTROLS):
        fail("Literal bidi controls leaked into Persian static values")

    persian_letter_values = sum(
        1 for _, value in pairs if re.search(r"[\u067e\u0686\u0698\u06a9\u06af\u06cc]", value)
    )
    if persian_letter_values < 200:
        fail(f"Too few Persian-specific reviewed values: {persian_letter_values}")
    if joined.count("\u200c") < 20:
        fail("Persian copy contains too little reviewed ZWNJ usage")

    dynamic = (ROOT / "lib/l10n/mizan_fa_dynamic.dart").read_text(encoding="utf-8")
    for marker in (
        "enum _PersianPlural { one, other }",
        "String _persianDigits",
        "یک روز باقی مانده",
        "روز باقی مانده",
        "translatePersianReviewedDynamic",
    ):
        if marker not in dynamic:
            fail(f"Persian dynamic grammar marker is missing: {marker}")
    print(
        f"Persian native-copy audit passed: {len(pairs)}/791 values, "
        f"{persian_letter_values} Persian-specific values, ZWNJ and language-purity checks."
    )


if __name__ == "__main__":
    main()
