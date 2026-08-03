#!/usr/bin/env python3
"""Remove three redundant interpolations without changing Polish output."""
from __future__ import annotations

import re
from pathlib import Path

path = Path(__file__).resolve().parents[1] / "lib" / "l10n" / "mizan_pl_dynamic.dart"
text = path.read_text(encoding="utf-8")
terms = (
    "dzienny wydatek",
    "wpis wydatku",
    "nowy wpis",
)
changed = 0
for term in terms:
    pattern = re.compile(
        rf":\s*'\$\{{(_plural\(\s*value,\s*'{re.escape(term)}',.*?\))\}}';",
        re.DOTALL,
    )
    text, count = pattern.subn(lambda match: ": " + match.group(1) + ";", text, count=1)
    if count != 1:
        raise SystemExit(f"Expected exactly one formatted Polish lint target for {term!r}, found {count}")
    changed += count
path.write_text(text, encoding="utf-8")
print(f"Removed {changed} redundant Polish dynamic interpolations.")
