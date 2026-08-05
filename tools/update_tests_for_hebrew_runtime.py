#!/usr/bin/env python3
"""Advance inherited exact language-registry tests to the Hebrew final head."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

FILES = (
    ROOT / "test/english_localization_test.dart",
    ROOT / "test/portuguese_br_localization_test.dart",
    ROOT / "test/spanish_localization_test.dart",
    ROOT / "test/italian_final_head_test.dart",
)

TITLE_REPLACEMENTS = {
    "English remains enabled after Persian integration":
        "English remains enabled after Hebrew integration",
    "Brazilian Portuguese remains enabled after Persian integration":
        "Brazilian Portuguese remains enabled after Hebrew integration",
    "Spanish remains enabled after Persian integration":
        "Spanish remains enabled after Hebrew integration",
    "final Persian head exposes the complete sixteen-language runtime":
        "final Hebrew head exposes the complete seventeen-language runtime",
}

HEBREW_ASSERTIONS = """    expect(MizanI18n.isSupported('he'), isTrue);
    expect(MizanI18n.isSupported('he-IL'), isTrue);
    expect(MizanI18n.isSupported('iw-IL'), isTrue);
    expect(MizanI18n.normalizeLanguageTag('he_IL'), 'he');
    expect(MizanI18n.normalizeLanguageTag('iw_IL'), 'he');
"""


def update(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    original = text

    for old, new in TITLE_REPLACEMENTS.items():
        if old in text:
            text = text.replace(old, new, 1)

    if "      'he',\n" not in text:
        marker = "      'fa',\n"
        count = text.count(marker)
        if count != 1:
            raise SystemExit(
                f"Expected one final Persian registry entry in {path.relative_to(ROOT)}; "
                f"found {count}"
            )
        text = text.replace(marker, marker + "      'he',\n", 1)

    if "MizanI18n.isSupported('he-IL')" not in text:
        marker = "    expect(MizanI18n.isSupported('fa-IR'), isTrue);\n"
        count = text.count(marker)
        if count != 1:
            raise SystemExit(
                f"Expected one Persian assertion anchor in {path.relative_to(ROOT)}; "
                f"found {count}"
            )
        text = text.replace(marker, marker + HEBREW_ASSERTIONS, 1)

    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = [str(path.relative_to(ROOT)) for path in FILES if update(path)]
    print(
        "Hebrew inherited registry tests updated: "
        + (", ".join(changed) if changed else "already current")
    )


if __name__ == "__main__":
    main()
