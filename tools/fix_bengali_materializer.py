#!/usr/bin/env python3
from pathlib import Path

path = Path(__file__).resolve().with_name('materialize_bengali_locale.py')
text = path.read_text(encoding='utf-8')
changed = False

old_grouping = "    text = text.replace('if (MizanI18n.isHindi) {', 'if (MizanI18n.isHindi || MizanI18n.isBengali) {')\n"
new_grouping = """    text = text.replace(
        \"\"\"  if (MizanI18n.isHindi) {
    grouped.write(_groupIndianDigits(integerPart));
\"\"\",
        \"\"\"  if (MizanI18n.isHindi || MizanI18n.isBengali) {
    grouped.write(_groupIndianDigits(integerPart));
\"\"\",
    )
    text = text.replace(
        \"\"\"  if (MizanI18n.isHindi) {
    final negative = integerPart.startsWith('-');
\"\"\",
        \"\"\"  if (MizanI18n.isHindi || MizanI18n.isBengali) {
    final negative = integerPart.startsWith('-');
\"\"\",
    )
"""
if old_grouping in text:
    text = text.replace(old_grouping, new_grouping, 1)
    changed = True
elif new_grouping not in text:
    raise SystemExit('Expected broad Hindi formatter replacement was not found.')

old_script_range = "    (0x0900, 0x097F),\n"
new_script_ranges = "    (0x0900, 0x0963),\n    (0x0966, 0x097F),\n"
if old_script_range in text:
    text = text.replace(old_script_range, new_script_ranges, 1)
    changed = True
elif new_script_ranges not in text:
    raise SystemExit('Expected Devanagari script range was not found.')

path.write_text(text, encoding='utf-8')
print(
    'Bengali materializer safety fixes applied.'
    if changed
    else 'Bengali materializer safety fixes already applied.'
)
