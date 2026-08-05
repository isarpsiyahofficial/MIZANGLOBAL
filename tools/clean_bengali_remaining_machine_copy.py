#!/usr/bin/env python3
"""Remove the last machine-translated Bengali fragments from product copy."""
from __future__ import annotations

import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = tuple(sorted((ROOT / 'lib/l10n/bn').glob('mizan_bn_*.dart'))) + (
    ROOT / 'lib/l10n/mizan_bn_dynamic.dart',
)

REPLACEMENTS = (
    ('অসামান্য পরিশোধ', 'অবশিষ্ট পরিশোধ'),
    ('কোন আয় তথ্য প্রদান করা হয়.', 'আয়ের কোনো তথ্য দেওয়া হয়নি।'),
    ('কোন আয় তথ্য প্রদান করা হয়।', 'আয়ের কোনো তথ্য দেওয়া হয়নি।'),
    ('কোন আয় তথ্য', 'আয়ের কোনো তথ্য'),
)


def main() -> None:
    changed: list[str] = []
    for path in FILES:
        text = path.read_text(encoding='utf-8')
        updated = text
        for source, target in REPLACEMENTS:
            updated = updated.replace(source, target)
        updated = unicodedata.normalize('NFC', updated)
        if updated != text:
            path.write_text(updated, encoding='utf-8')
            changed.append(str(path.relative_to(ROOT)))
    print(
        'Removed remaining Bengali machine-copy fragments: ' + ', '.join(changed)
        if changed
        else 'No remaining Bengali machine-copy fragments found.'
    )


if __name__ == '__main__':
    main()
