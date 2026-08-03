#!/usr/bin/env python3
"""Teach the legacy pt-BR source validator about exact-ISO currency matching."""
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'tools' / 'validate_portuguese_br_localization.py'
text = path.read_text(encoding='utf-8')
old = """if picker_source.count("matches: (item, query) => item.matches(query)") != 3:
    failures.append("all picker searches must retain multilingual aliases")
"""
new = """if picker_source.count("matches: (item, query) => item.matches(query)") != 2:
    failures.append("language and country picker searches must retain multilingual aliases")
if "matches: (item, query) => catalog.currencyMatches(item, query)" not in picker_source:
    failures.append(
        "currency picker must retain multilingual aliases while prioritizing exact ISO codes"
    )
"""
if old in text:
    path.write_text(text.replace(old, new, 1), encoding='utf-8')
elif new not in text:
    raise SystemExit('pt-BR picker validation block did not match the reviewed source')
print('pt-BR validator now accepts exact-ISO currency precedence and alias search.')
