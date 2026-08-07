#!/usr/bin/env python3
from pathlib import Path

path = Path('lib/core/formatters.dart')
text = path.read_text(encoding='utf-8')
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
      .replaceAll('\\u2069', '');
"""
if new in text:
    raise SystemExit(0)
if old not in text:
    raise SystemExit('parseMoney anchor missing')
path.write_text(text.replace(old, new, 1), encoding='utf-8')
