#!/usr/bin/env python3
"""Use the native Polish period label in report and shared monthly selectors."""
from pathlib import Path

path = Path(__file__).resolve().parents[1] / "lib" / "l10n" / "pl" / "mizan_pl_core.dart"
text = path.read_text(encoding="utf-8")
old = "  'Aylık': 'Co miesiąc',"
new = "  'Aylık': 'Miesięcznie',"
count = text.count(old)
if count == 1:
    path.write_text(text.replace(old, new, 1), encoding="utf-8")
elif new not in text:
    raise SystemExit(f"Expected one monthly Polish label, found {count}")
print("Polish monthly period label verified as Miesięcznie.")
