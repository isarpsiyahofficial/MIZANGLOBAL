#!/usr/bin/env python3
"""Apply final reviewed Israeli Hebrew product-copy corrections deterministically."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPLACEMENTS: dict[str, tuple[tuple[str, str], ...]] = {
    "lib/l10n/he/mizan_he_core.dart": (
        (
            "'הרשאת התזמון המדויק של Android כבויה. MİZAN משתמש בתזמון משוער; למסירה בשעה ובדקה המדויקות יש להפעיל את ההרשאה.'",
            "'הרשאת התזמון המדויק של Android כבויה. MİZAN משתמש בתזמון משוער; כדי לעבור לתזמון מדויק ולמסירה בשעה ובדקה שנבחרו, יש להפעיל את ההרשאה.'",
        ),
    ),
}


def main() -> None:
    changed: list[str] = []
    for relative, replacements in REPLACEMENTS.items():
        path = ROOT / relative
        text = path.read_text(encoding="utf-8")
        original = text
        for old, new in replacements:
            if new in text:
                continue
            count = text.count(old)
            if count != 1:
                raise SystemExit(
                    f"Expected one Hebrew final-copy target in {relative}; found {count}: {old!r}"
                )
            text = text.replace(old, new, 1)
        if text != original:
            path.write_text(text, encoding="utf-8")
            changed.append(relative)
    print(
        "Hebrew final native-copy corrections applied: "
        + (", ".join(changed) if changed else "already current")
    )


if __name__ == "__main__":
    main()
