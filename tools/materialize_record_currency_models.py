#!/usr/bin/env python3
from pathlib import Path

helper_path = Path('tools/patch_report_currency_ui.py')
if not helper_path.exists():
    raise SystemExit('report currency helper missing')
code = compile(helper_path.read_text(encoding='utf-8'), str(helper_path), 'exec')
exec(code, {'__name__': '__main__'})
helper_path.unlink(missing_ok=True)
