#!/usr/bin/env python3
"""Remove remaining machine copy and duplicated Bengali integration blocks."""
from __future__ import annotations

import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COPY_FILES = tuple(sorted((ROOT / 'lib/l10n/bn').glob('mizan_bn_*.dart'))) + (
    ROOT / 'lib/l10n/mizan_bn_dynamic.dart',
)
FORMATTERS = ROOT / 'lib/core/formatters.dart'
CATALOG = ROOT / 'lib/global/global_catalog.dart'

REPLACEMENTS = (
    ('অসামান্য পরিশোধ', 'অবশিষ্ট পরিশোধ'),
    ('কোন আয় তথ্য প্রদান করা হয়.', 'আয়ের কোনো তথ্য দেওয়া হয়নি।'),
    ('কোন আয় তথ্য প্রদান করা হয়।', 'আয়ের কোনো তথ্য দেওয়া হয়নি।'),
    ('কোন আয় তথ্য', 'আয়ের কোনো তথ্য'),
)

BENGALI_MONEY_BLOCK = """  if (MizanI18n.isBengali) {
    if (code == 'BDT') return '৳$amount';
    if (code == 'INR') return '₹$amount';
    return '$code\\u00A0$amount';
  }
"""
BENGALI_DECIMAL_BLOCK = """  if (MizanI18n.isBengali) {
    return _bengaliDigits('$integerPart.$decimalPart');
  }
"""
BENGALI_SHORT_DATE_BLOCK = """  if (MizanI18n.isBengali) {
    return _bengaliDigits(
      '${value.day} ${bnMonths[value.month - 1]} ${value.year}',
    );
  }
"""
BDT_PARSE_PAIR = """      .replaceAll('৳', '')
      .replaceAll('bdt', '')
"""


def collapse_adjacent(text: str, block: str) -> str:
    while block + block in text:
        text = text.replace(block + block, block)
    return text


def write_if_changed(path: Path, updated: str, changed: list[str]) -> None:
    original = path.read_text(encoding='utf-8')
    updated = unicodedata.normalize('NFC', updated)
    if updated != original:
        path.write_text(updated, encoding='utf-8')
        changed.append(str(path.relative_to(ROOT)))


def main() -> None:
    changed: list[str] = []
    for path in COPY_FILES:
        text = path.read_text(encoding='utf-8')
        updated = text
        for source, target in REPLACEMENTS:
            updated = updated.replace(source, target)
        write_if_changed(path, updated, changed)

    formatter_text = FORMATTERS.read_text(encoding='utf-8')
    formatter_text = collapse_adjacent(formatter_text, BENGALI_MONEY_BLOCK)
    formatter_text = collapse_adjacent(formatter_text, BENGALI_DECIMAL_BLOCK)
    formatter_text = collapse_adjacent(formatter_text, BENGALI_SHORT_DATE_BLOCK)
    formatter_text = collapse_adjacent(formatter_text, BDT_PARSE_PAIR)
    write_if_changed(FORMATTERS, formatter_text, changed)

    catalog_text = CATALOG.read_text(encoding='utf-8')
    while '$nameBn $nameBn' in catalog_text:
        catalog_text = catalog_text.replace('$nameBn $nameBn', '$nameBn')
    write_if_changed(CATALOG, catalog_text, changed)

    print(
        'Cleaned Bengali machine-copy and integration duplicates: '
        + ', '.join(changed)
        if changed
        else 'No Bengali machine-copy or integration duplicates found.'
    )


if __name__ == '__main__':
    main()
