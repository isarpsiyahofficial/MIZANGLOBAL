#!/usr/bin/env python3
from pathlib import Path

helper = Path('tools/patch_report_currency_pdf.py')
if not helper.exists():
    raise SystemExit('PDF currency helper missing')
code = compile(helper.read_text(encoding='utf-8'), str(helper), 'exec')
exec(code, {'__name__': '__main__'})
