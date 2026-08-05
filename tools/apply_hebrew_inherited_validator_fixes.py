#!/usr/bin/env python3
"""Remove obsolete exact-line assumptions from inherited RTL validators."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARABIC_BUILDER = ROOT / "tools/build_arabic_locale.py"


def main() -> None:
    text = ARABIC_BUILDER.read_text(encoding="utf-8")
    old = '        "final visibleUser = effective == \'ar\'",\n'
    new = '        "effective == \'ar\'",\n'
    if new in text and old not in text:
        print("Arabic bidi validator already accepts additional RTL languages.")
        return
    count = text.count(old)
    if count != 1:
        raise SystemExit(
            f"Expected one obsolete Arabic exact-line bidi marker, found {count}"
        )
    ARABIC_BUILDER.write_text(text.replace(old, new, 1), encoding="utf-8")
    print("Arabic bidi validator made extensible for Persian and Hebrew.")


if __name__ == "__main__":
    main()
