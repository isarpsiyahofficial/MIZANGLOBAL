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

old_override = "    'Yedekleri birleştir': 'ব্যাকআপ একত্র করুন',\n"
new_override = (
    "    'Yedekleri birleştir': 'ব্যাকআপ একত্র করুন',\n"
    "    'CSV yedeğini birleştir': 'CSV ব্যাকআপ একত্র করুন',\n"
)
if "'CSV yedeğini birleştir': 'CSV ব্যাকআপ একত্র করুন'" not in text:
    if old_override not in text:
        raise SystemExit('Expected generic backup-merge override was not found.')
    text = text.replace(old_override, new_override, 1)
    changed = True

old_required = "        'ব্যাকআপ একত্র করুন',\n"
new_required = "        'CSV ব্যাকআপ একত্র করুন',\n"
if old_required in text:
    text = text.replace(old_required, new_required, 1)
    changed = True
elif new_required not in text:
    raise SystemExit('Expected Bengali backup-merge requirement was not found.')

path.write_text(text, encoding='utf-8')
print(
    'Bengali materializer safety fixes applied.'
    if changed
    else 'Bengali materializer safety fixes already applied.'
)
