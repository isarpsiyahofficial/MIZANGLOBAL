#!/usr/bin/env python3
from pathlib import Path

helper = Path('tools/patch_report_currency_ui.py')
if not helper.exists():
    raise SystemExit('report currency helper missing')
exec(compile(helper.read_text(encoding='utf-8'), str(helper), 'exec'))
helper.unlink(missing_ok=True)
