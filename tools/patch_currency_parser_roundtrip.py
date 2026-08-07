#!/usr/bin/env python3
from pathlib import Path

path = Path('lib/core/formatters.dart')
text = path.read_text(encoding='utf-8')

old_start = """double parseMoney(String input) {
  var prepared = input;
"""
new_start = """double parseMoney(String input) {
  var prepared = input
      .replaceAll(
        RegExp(RegExp.escape(MizanI18n.currencyCode), caseSensitive: false),
        '',
      )
      .replaceAll('\\u2066', '')
      .replaceAll('\\u2069', '');
"""
if old_start in text:
    text = text.replace(old_start, new_start, 1)
elif new_start not in text:
    raise SystemExit('parseMoney start anchor missing')

old_end = """  return legacy.parseMoney(prepared);
}
"""
new_end = """  if (_usesNewLocaleFormatter) {
    prepared = prepared
        .replaceAll('\\u00A0', '')
        .replaceAll('\\u202F', '')
        .replaceAll(RegExp(r'[\\u2066-\\u2069\\s]'), '');
    if (MizanI18n.isIndonesian || MizanI18n.isVietnamese) {
      prepared = prepared.replaceAll('.', '').replaceAll(',', '.');
    } else {
      prepared = prepared.replaceAll(',', '');
    }
    final parsed = double.tryParse(prepared);
    if (parsed != null && parsed.isFinite) return parsed;
  }
  return legacy.parseMoney(input);
}
"""
if old_end in text:
    text = text.replace(old_end, new_end, 1)
elif new_end not in text:
    raise SystemExit('parseMoney end anchor missing')

path.write_text(text, encoding='utf-8')
