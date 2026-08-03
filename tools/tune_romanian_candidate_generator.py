#!/usr/bin/env python3
"""Make Romanian candidate generation resilient without accepting partial output."""
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'tools' / 'generate_romanian_candidate.py'
text = path.read_text(encoding='utf-8')
old_override_tail = '    "Günlük": "Zilnic",\n}'
new_override_tail = (
    '    "Günlük": "Zilnic",\n'
    '    "Kalan ödeme ayrıntıları": "Detalii despre plățile rămase",\n'
    '}'
)
if old_override_tail in text:
    text = text.replace(old_override_tail, new_override_tail, 1)
old_start = '    key, original = item\n    protected_text, tokens = protect(original)\n'
new_start = (
    '    key, original = item\n'
    '    if key in KEY_OVERRIDES:\n'
    '        return key, KEY_OVERRIDES[key]\n'
    '    protected_text, tokens = protect(original)\n'
)
if old_start in text:
    text = text.replace(old_start, new_start, 1)
text = text.replace('    for attempt in range(4):\n', '    for attempt in range(8):\n')
text = text.replace('ThreadPoolExecutor(max_workers=12)', 'ThreadPoolExecutor(max_workers=6)')
path.write_text(text, encoding='utf-8')
print('Romanian generator tuned: direct overrides, 8 retries, 6 workers.')
