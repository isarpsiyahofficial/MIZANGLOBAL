#!/usr/bin/env python3
"""Apply reviewed German singular-verb agreement to dynamic system copy."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DYNAMIC = ROOT / "lib/l10n/mizan_de_dynamic.dart"
TEST = ROOT / "test/german_localization_test.dart"


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    if text.count(old) != 1:
        raise SystemExit(
            f"Expected one review target in {path.relative_to(ROOT)}, found {text.count(old)}"
        )
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


replace_once(
    DYNAMIC,
    """    (m, t) => 'Bis ${m[1]} verbleiben ${_days(m[2]!)}',""",
    """    (m, t) => m[2] == '1'
        ? 'Bis ${m[1]} verbleibt 1 Tag'
        : 'Bis ${m[1]} verbleiben ${_days(m[2]!)}',""",
)
replace_once(
    DYNAMIC,
    """    (m, t) =>
        '${_items(m[1]!)} aus dem Benachrichtigungsplan konnten nicht in Android geschrieben werden. Erster Fehler: ${m[2]}',""",
    """    (m, t) => m[1] == '1'
        ? '1 Eintrag aus dem Benachrichtigungsplan konnte nicht in Android geschrieben werden. Erster Fehler: ${m[2]}'
        : '${_items(m[1]!)} aus dem Benachrichtigungsplan konnten nicht in Android geschrieben werden. Erster Fehler: ${m[2]}',""",
)
replace_once(
    DYNAMIC,
    """    (m, t) =>
        'Der Benachrichtigungsplan konnte nicht geprüft werden; in Android fehlen ${_items(m[1]!)}.',""",
    """    (m, t) => m[1] == '1'
        ? 'Der Benachrichtigungsplan konnte nicht geprüft werden; in Android fehlt 1 Eintrag.'
        : 'Der Benachrichtigungsplan konnte nicht geprüft werden; in Android fehlen ${_items(m[1]!)}.',""",
)

replace_once(
    TEST,
    """    expect(MizanI18n.text('3 gün kaldı'), 'Noch 3 Tage');
""",
    """    expect(MizanI18n.text('3 gün kaldı'), 'Noch 3 Tage');
    expect(
      MizanI18n.text('Miete için 1 gün kaldı'),
      'Bis Miete verbleibt 1 Tag',
    );
    expect(
      MizanI18n.text('Miete için 2 gün kaldı'),
      'Bis Miete verbleiben 2 Tage',
    );
""",
)
replace_once(
    TEST,
    """    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      '2 neue Einträge wurden hinzugefügt; vorhandene Daten blieben erhalten.',
    );
""",
    """    expect(
      MizanI18n.text('2 yeni kayıt eklendi; mevcut veriler korundu.'),
      '2 neue Einträge wurden hinzugefügt; vorhandene Daten blieben erhalten.',
    );
    expect(
      MizanI18n.text(
        'Bildirim planındaki 1 kayıt Android sistemine yazılamadı. İlk hata: X',
      ),
      '1 Eintrag aus dem Benachrichtigungsplan konnte nicht in Android geschrieben werden. Erster Fehler: X',
    );
    expect(
      MizanI18n.text(
        'Bildirim planı doğrulanamadı; Android tarafında 1 kayıt eksik kaldı.',
      ),
      'Der Benachrichtigungsplan konnte nicht geprüft werden; in Android fehlt 1 Eintrag.',
    );
""",
)

print("German dynamic native review round 2 applied.")
