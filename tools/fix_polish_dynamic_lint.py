#!/usr/bin/env python3
"""Remove three redundant interpolations without changing Polish output."""
from pathlib import Path

path = Path(__file__).resolve().parents[1] / "lib" / "l10n" / "mizan_pl_dynamic.dart"
text = path.read_text(encoding="utf-8")
replacements = {
    ": '${_plural(value, 'dzienny wydatek', 'dzienne wydatki', 'dziennych wydatków')}';": ": _plural(value, 'dzienny wydatek', 'dzienne wydatki', 'dziennych wydatków');",
    ": '${_plural(value, 'wpis wydatku', 'wpisy wydatków', 'wpisów wydatków')}';": ": _plural(value, 'wpis wydatku', 'wpisy wydatków', 'wpisów wydatków');",
    ": '${_plural(value, 'nowy wpis', 'nowe wpisy', 'nowych wpisów')}';": ": _plural(value, 'nowy wpis', 'nowe wpisy', 'nowych wpisów');",
}
for old, new in replacements.items():
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected exactly one Polish lint target, found {count}: {old}")
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
print("Removed three redundant Polish dynamic interpolations.")
