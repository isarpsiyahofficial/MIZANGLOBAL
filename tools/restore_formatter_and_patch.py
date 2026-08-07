#!/usr/bin/env python3
from pathlib import Path
import subprocess

BASELINE = 'd1b66a99a6f410b40f0794c834f185d01745dd21'
path = Path('lib/core/formatters.dart')
text = subprocess.check_output(
    ['git', 'show', f'{BASELINE}:lib/core/formatters.dart'],
    text=True,
)
old = """double parseMoney(String input) {
  var prepared = input;
"""
new = """double parseMoney(String input) {
  var prepared = input
      .replaceAll(
        RegExp(RegExp.escape(MizanI18n.currencyCode), caseSensitive: false),
        '',
      )
      .replaceAll('\\u2066', '')
      .replaceAll('\\u2067', '')
      .replaceAll('\\u2068', '')
      .replaceAll('\\u2069', '');
"""
if old not in text:
    raise SystemExit('verified parseMoney anchor missing')
text = text.replace(old, new, 1)
path.write_text(text, encoding='utf-8')
