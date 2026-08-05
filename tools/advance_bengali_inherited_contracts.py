#!/usr/bin/env python3
"""Advance inherited localization scope validators after Bengali integration."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGETS = (
    'validate_hindi_localization_scope.py',
    'validate_hebrew_localization_scope.py',
    'validate_persian_localization_scope.py',
    'validate_arabic_localization_scope.py',
    'validate_ukrainian_localization_scope.py',
)


def main() -> None:
    changed: list[str] = []
    for name in TARGETS:
        path = ROOT / 'tools' / name
        if not path.exists():
            raise SystemExit(f'Inherited scope validator missing: {name}')
        text = path.read_text(encoding='utf-8')
        updated = text
        match = re.search(
            r'EXPECTED_INTEGRATED_LANGUAGES\s*=\s*\{(?P<body>.*?)\n\}',
            updated,
            flags=re.DOTALL,
        )
        if match is None:
            raise SystemExit(f'Integrated-language set missing in {name}')
        body = match.group('body')
        if "'bn'" not in body:
            if "'he', 'hi'," in body:
                new_body = body.replace("'he', 'hi',", "'he', 'hi', 'bn',", 1)
            elif "'hi'," in body:
                new_body = body.replace("'hi',", "'hi', 'bn',", 1)
            else:
                new_body = body.rstrip() + " 'bn',"
            updated = updated[: match.start('body')] + new_body + updated[match.end('body') :]
        updated = updated.replace('Eighteen-language', 'Nineteen-language')
        updated = updated.replace('eighteen-language', 'nineteen-language')
        updated = updated.replace('18-language', '19-language')
        updated = updated.replace('18 languages', '19 languages')
        if updated != text:
            path.write_text(updated, encoding='utf-8')
            changed.append(name)
    print(
        'Advanced inherited scope validators: ' + ', '.join(changed)
        if changed
        else 'Inherited scope validators already accept the nineteen-language runtime.'
    )


if __name__ == '__main__':
    main()
