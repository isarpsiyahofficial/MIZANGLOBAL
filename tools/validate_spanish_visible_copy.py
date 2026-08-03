#!/usr/bin/env python3
"""Reject foreign-language catalog names from Spanish-visible picker rows."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
picker = (root / 'lib/widgets/global_picker_dialog.dart').read_text(
    encoding='utf-8',
)
failures: list[str] = []

if '.nativeName' in picker:
    failures.append(
        'Picker rows must not display native names; native names remain search-only aliases.'
    )

required = (
    'titleOf: (item) => item.nameFor(MizanI18n.languageTag)',
    'subtitleOf: (item) => item.code.toUpperCase()',
    'titleOf: (item) => item.nameFor(MizanI18n.languageTag)',
    'subtitleOf: (item) => item.code',
    "titleOf: (item) => '${item.code} · ${item.nameFor(MizanI18n.languageTag)}'",
)
for fragment in required:
    if fragment not in picker:
        failures.append(f'Missing selected-language picker rendering: {fragment}')

if picker.count('matches: (item, query) => item.matches(query)') != 2:
    failures.append(
        'Language and country search must keep their multilingual alias matching.'
    )
if 'matches: (item, query) => catalog.currencyMatches(item, query)' not in picker:
    failures.append(
        'Currency search must preserve multilingual aliases while prioritizing exact ISO codes.'
    )

if failures:
    print('Spanish visible-copy validation failed:')
    for failure in failures:
        print(f'- {failure}')
    raise SystemExit(1)

print(
    'Spanish visible-copy validation passed: native/English aliases remain searchable '
    'but picker rows render only selected-language names and stable codes/symbols; '
    'exact ISO currency codes take precedence.'
)
