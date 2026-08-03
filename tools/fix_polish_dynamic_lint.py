#!/usr/bin/env python3
"""Apply narrow Polish grammar and number-format corrections."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DYNAMIC = ROOT / "lib" / "l10n" / "mizan_pl_dynamic.dart"
FORMATTERS = ROOT / "lib" / "core" / "formatters.dart"


def fix_dynamic() -> int:
    text = DYNAMIC.read_text(encoding="utf-8")
    changed = 0

    for term in ("dzienny wydatek", "wpis wydatku", "nowy wpis"):
        pattern = re.compile(
            rf":\s*'\$\{{(_plural\(\s*value,\s*'{re.escape(term)}',.*?\))\}}';",
            re.DOTALL,
        )
        text, count = pattern.subn(
            lambda match: ": " + match.group(1) + ";",
            text,
            count=1,
        )
        changed += count

    helper = """String _remainingDays(String value) {
  if (value == '1') return 'Pozostał 1 dzień';
  final number = _number(value).abs();
  final lastTwo = number % 100;
  final last = number % 10;
  if (last >= 2 && last <= 4 && !(lastTwo >= 12 && lastTwo <= 14)) {
    return 'Pozostały $value dni';
  }
  return 'Pozostało $value dni';
}
"""
    anchor = "String _remaining(String value) => 'pozostało $value';\n"
    if "String _remainingDays(String value)" not in text:
        if anchor not in text:
            raise SystemExit("Polish remaining-days helper insertion point is missing")
        text = text.replace(anchor, anchor + helper, 1)
        changed += 1

    old_builder = (
        "(m, t) => m[1] == '1' ? 'Pozostał 1 dzień' "
        ": 'Pozostało ${_days(m[1]!)}',"
    )
    new_builder = "(m, t) => _remainingDays(m[1]!),"
    if old_builder in text:
        text = text.replace(old_builder, new_builder, 1)
        changed += 1
    elif new_builder not in text:
        raise SystemExit("Standalone Polish remaining-days builder is missing")

    DYNAMIC.write_text(text, encoding="utf-8")
    return changed


def fix_decimal_text() -> int:
    text = FORMATTERS.read_text(encoding="utf-8")
    old = """String decimalText(num value) {
  final rounded = value.toStringAsFixed(2);
  return rounded.endsWith('.00')
      ? rounded.substring(0, rounded.length - 3)
      : (MizanI18n.isEnglish ? rounded : rounded.replaceAll('.', ','));
}
"""
    new = """String decimalText(num value) {
  final rounded = value.toStringAsFixed(2);
  final hasDecimals = !rounded.endsWith('.00');
  final rawInteger = hasDecimals
      ? rounded.substring(0, rounded.length - 3)
      : rounded.substring(0, rounded.length - 3);
  var integerPart = rawInteger;
  if (MizanI18n.isPolish) {
    final negative = integerPart.startsWith('-');
    final digits = negative ? integerPart.substring(1) : integerPart;
    final grouped = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      grouped.write(digits[index]);
      final remaining = digits.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        grouped.write('\\u202F');
      }
    }
    integerPart = '${negative ? '-' : ''}${grouped.toString()}';
  }
  if (!hasDecimals) return integerPart;
  final decimalPart = rounded.substring(rounded.length - 2);
  if (MizanI18n.isEnglish) return '$rawInteger.$decimalPart';
  return '$integerPart,$decimalPart';
}
"""
    if old in text:
        FORMATTERS.write_text(text.replace(old, new, 1), encoding="utf-8")
        return 1
    if "if (MizanI18n.isPolish) {" in text and "final rawInteger =" in text:
        return 0
    raise SystemExit("decimalText implementation did not match the reviewed source")


changed = fix_dynamic() + fix_decimal_text()
print(f"Applied {changed} narrow Polish grammar/format corrections.")
