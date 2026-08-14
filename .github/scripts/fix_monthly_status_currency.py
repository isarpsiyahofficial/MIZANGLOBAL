from pathlib import Path

path = Path('lib/services/monthly_payment_status_service.dart')
text = path.read_text(encoding='utf-8')
old = """      sourceId: record.sourceId,
      bankId: record.bankId,
"""
new = """      sourceId: record.sourceId,
      currencyCode: record.currencyCode,
      bankId: record.bankId,
"""
if text.count(old) != 1:
    raise SystemExit(f'expected one RecordReference reconstruction without currency, found {text.count(old)}')
path.write_text(text.replace(old, new, 1), encoding='utf-8')
print('preserved currencyCode while rebuilding monthly RecordReference timing')
