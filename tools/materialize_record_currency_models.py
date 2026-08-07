#!/usr/bin/env python3
from pathlib import Path
import subprocess

legacy_path = Path('lib/core/formatters_legacy.dart')
legacy = legacy_path.read_text(encoding='utf-8')
if 'String money(num value, {String? currencyCode}) {' not in legacy:
    old = 'String money(num value) {'
    if old not in legacy:
        raise SystemExit('legacy money signature missing')
    legacy = legacy.replace(old, 'String money(num value, {String? currencyCode}) {', 1)
old = '  final code = MizanI18n.currencyCode;'
new = "  final code = (currencyCode ?? MizanI18n.currencyCode).trim().toUpperCase();"
if new not in legacy:
    if old not in legacy:
        raise SystemExit('legacy currency anchor missing')
    legacy = legacy.replace(old, new, 1)
legacy_path.write_text(legacy, encoding='utf-8')

core_path = Path('lib/core/formatters.dart')
core = core_path.read_text(encoding='utf-8')
start = core.index('String money(')
end = core.index('\nString decimalText', start)
region = core[start:end]
if 'String money(num value, {String? currencyCode}) {' not in region:
    region = region.replace('String money(num value) {', 'String money(num value, {String? currencyCode}) {', 1)
if 'final code = (currencyCode ?? MizanI18n.currencyCode)' not in region:
    region = region.replace(
        "  if (!_usesNewLocaleFormatter) return legacy.money(value);\n  final safe = value.isFinite ? value.toDouble() : 0.0;",
        "  final code = (currencyCode ?? MizanI18n.currencyCode).trim().toUpperCase();\n  if (!_usesNewLocaleFormatter) {\n    return legacy.money(value, currencyCode: code);\n  }\n  final safe = value.isFinite ? value.toDouble() : 0.0;",
        1,
    )
region = region.replace('MizanI18n.currencyCode', 'code')
region = region.replace('(currencyCode ?? code)', '(currencyCode ?? MizanI18n.currencyCode)', 1)
region = region.replace('${code}', '$code')
core = core[:start] + region + core[end:]
helper = "\nString moneyForCurrency(num value, String currencyCode) =>\n    money(value, currencyCode: currencyCode);\n"
if 'String moneyForCurrency(' not in core:
    insert_at = core.index('\nString decimalText', start)
    core = core[:insert_at] + helper + core[insert_at:]
core_path.write_text(core, encoding='utf-8')

subprocess.run(['dart', 'format', str(legacy_path), str(core_path)], check=True)
