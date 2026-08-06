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
    exact_sets: list[str] = []
    unchanged_without_set: list[str] = []
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
        if match is not None:
            exact_sets.append(name)
            body = match.group('body')
            if "'bn'" not in body:
                if "'he', 'hi'," in body:
                    new_body = body.replace("'he', 'hi',", "'he', 'hi', 'bn',", 1)
                elif "'hi'," in body:
                    new_body = body.replace("'hi',", "'hi', 'bn',", 1)
                else:
                    new_body = body.rstrip() + " 'bn',"
                updated = (
                    updated[: match.start('body')]
                    + new_body
                    + updated[match.end('body') :]
                )
        else:
            unchanged_without_set.append(name)
        updated = updated.replace('Eighteen-language', 'Nineteen-language')
        updated = updated.replace('eighteen-language', 'nineteen-language')
        updated = updated.replace('18-language', '19-language')
        updated = updated.replace('18 languages', '19 languages')
        if updated != text:
            path.write_text(updated, encoding='utf-8')
            changed.append(name)

    if not exact_sets:
        raise SystemExit('No inherited exact runtime set was found to advance')
    print(
        'Advanced inherited scope validators: ' + ', '.join(changed)
        if changed
        else 'Inherited exact runtime validators already accept Bengali.'
    )
    if unchanged_without_set:
        print(
            'Validators without an exact supported-language set remain unchanged: '
            + ', '.join(unchanged_without_set)
        )


if __name__ == '__main__':
    main()
