#!/usr/bin/env python3
"""Apply deterministic analyzer-safe shapes to the generated Hebrew runtime."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
I18N = ROOT / "lib/l10n/mizan_i18n.dart"
DYNAMIC = ROOT / "lib/l10n/mizan_he_dynamic.dart"


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    count = text.count(old)
    if count != 1:
        raise SystemExit(
            f"Expected exactly one Hebrew lint target in {path.relative_to(ROOT)}; "
            f"found {count}: {old!r}"
        )
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    replace_once(
        I18N,
        "    if (normalized == 'he' || normalized.startsWith('he-') || normalized == 'iw' || normalized.startsWith('iw-')) return 'he';\n",
        "    if (normalized == 'he' ||\n        normalized.startsWith('he-') ||\n        normalized == 'iw' ||\n        normalized.startsWith('iw-')) {\n      return 'he';\n    }\n",
    )
    replace_once(
        DYNAMIC,
        """String _people(String value) => _count(
  value,
  zero: 'ללא אנשים',
  one: 'אדם אחד',
  two: 'שני אנשים',
  otherUnit: 'אנשים',
);
""",
        "",
    )
    print("Hebrew generated runtime lint shapes applied")


if __name__ == "__main__":
    main()
