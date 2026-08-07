#!/usr/bin/env python3
from pathlib import Path

path = Path('lib/controllers/mizan_controller.dart')
text = path.read_text(encoding='utf-8')

old_hash = """    var hash = Object.hash(\n      state.notificationsEnabled,\n      state.notificationSoundMode,\n      state.notificationVibrationEnabled,\n    );"""
new_hash = """    var hash = Object.hash(\n      state.notificationsEnabled,\n      state.notificationSoundMode,\n      state.notificationVibrationEnabled,\n      MizanI18n.normalizeLanguageTag(state.appLanguageTag),\n    );"""
if old_hash not in text:
    if new_hash not in text:
        raise SystemExit('notification fingerprint anchor not found')
else:
    text = text.replace(old_hash, new_hash, 1)

old_commit = """        recentCurrencyCodes: recent,\n      ),\n      reschedule: false,\n    );\n    if (language != previousLanguage) {"""
new_commit = """        recentCurrencyCodes: recent,\n      ),\n      reschedule: language != previousLanguage,\n    );\n    if (language != previousLanguage) {"""
if old_commit not in text:
    if new_commit not in text:
        raise SystemExit('global preference commit anchor not found')
else:
    text = text.replace(old_commit, new_commit, 1)

path.write_text(text, encoding='utf-8')
