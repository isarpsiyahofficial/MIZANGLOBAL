#!/usr/bin/env python3
"""One-time deterministic patch for CLDR currency gaps in the pt-PT builder."""
from pathlib import Path

path = Path(__file__).with_name('build_pt_pt_locale.py')
source = path.read_text(encoding='utf-8')
marker = '        "XCG": "florim caribenho",\n'
if marker in source:
    print('Special pt-PT currency overrides are already present.')
    raise SystemExit(0)
needle = '        "STN": "dobra de São Tomé e Príncipe",\n'
if source.count(needle) != 1:
    raise SystemExit('Could not locate pt-PT currency override insertion point')
replacement = needle + (
    '        "XAF": "franco CFA da África Central",\n'
    '        "XCD": "dólar das Caraíbas Orientais",\n'
    '        "XCG": "florim caribenho",\n'
    '        "XOF": "franco CFA da África Ocidental",\n'
    '        "XPF": "franco CFP",\n'
    '        "ZWG": "ouro do Zimbabué",\n'
)
path.write_text(source.replace(needle, replacement, 1), encoding='utf-8')
print('Added fixed pt-PT names for currencies missing from CLDR.')
