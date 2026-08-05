#!/usr/bin/env python3
from pathlib import Path

path = Path(__file__).resolve().with_name('materialize_bengali_locale.py')
text = path.read_text(encoding='utf-8')
old = "    text = text.replace('if (MizanI18n.isHindi) {', 'if (MizanI18n.isHindi || MizanI18n.isBengali) {')\n"
new = """    text = text.replace(
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
if old not in text:
    if new in text:
        print('Bengali materializer grouping fix already applied.')
        raise SystemExit(0)
    raise SystemExit('Expected broad Hindi formatter replacement was not found.')
path.write_text(text.replace(old, new, 1), encoding='utf-8')
print('Scoped Bengali Indian-grouping integration without changing Hindi date branches.')
