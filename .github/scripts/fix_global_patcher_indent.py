from pathlib import Path

path = Path('.github/scripts/apply_global_record_income_backup_patch.py')
text = path.read_text(encoding='utf-8')
old_enum = '"    monthly(\'Aylık\');"'
new_enum = '"  monthly(\'Aylık\');"'
old_replacement = '"    monthly(\'Aylık\'),\\n    yearly(\'Yıllık\');"'
new_replacement = '"  monthly(\'Aylık\'),\\n  yearly(\'Yıllık\');"'
if text.count(old_enum) != 1 or text.count(old_replacement) != 1:
    raise SystemExit('patcher enum indentation source no longer matches expected text')
text = text.replace(old_enum, new_enum, 1).replace(old_replacement, new_replacement, 1)
path.write_text(text, encoding='utf-8')
print('corrected patcher enum indentation')
