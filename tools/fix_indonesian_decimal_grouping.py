#!/usr/bin/env python3
from pathlib import Path

path = Path('lib/core/formatters.dart')
text = path.read_text(encoding='utf-8')

old_condition = """  } else if (MizanI18n.isPolish ||
      MizanI18n.isRomanian ||
"""
new_condition = """  } else if (MizanI18n.isIndonesian ||
      MizanI18n.isPolish ||
      MizanI18n.isRomanian ||
"""
if old_condition not in text:
    raise SystemExit('decimalText grouping condition anchor not found')
text = text.replace(old_condition, new_condition, 1)

old_separator = """              : ((MizanI18n.isRomanian || MizanI18n.isGreek)
                    ? '.'
"""
new_separator = """              : ((MizanI18n.isIndonesian ||
                        MizanI18n.isRomanian ||
                        MizanI18n.isGreek)
                    ? '.'
"""
if old_separator not in text:
    raise SystemExit('decimalText group separator anchor not found')
text = text.replace(old_separator, new_separator, 1)

path.write_text(text, encoding='utf-8')
