from __future__ import annotations

import re
from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected one occurrence, found {count}')
    return text.replace(old, new, 1)


def update_l10n() -> None:
    path = Path('lib/l10n/mizan_i18n.dart')
    text = path.read_text(encoding='utf-8')
    exact_entry = "    'MİZAN Aylık Raporu': 'MİZAN Monthly Report',\n"
    if exact_entry not in text:
        anchor = "  static const Map<String, String> _english = <String, String>{\n"
        if text.count(anchor) != 1:
            raise SystemExit('English translation map anchor is missing or duplicated.')
        text = text.replace(anchor, anchor + exact_entry, 1)

    text = text.replace(
        "'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.': "
        "'You must type ONAYLIYORUM exactly to delete the category.'",
        "'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.': "
        "'You must type I CONFIRM exactly to delete the category.'",
    )
    text = text.replace(
        "'ONAYLIYORUM': 'ONAYLIYORUM'",
        "'ONAYLIYORUM': 'I CONFIRM'",
    )
    path.write_text(text, encoding='utf-8')


def update_report_model_user_data() -> None:
    path = Path('lib/services/report_service.dart')
    text = path.read_text(encoding='utf-8')
    simple_wrapper = re.compile(
        r'MizanI18n\.user\(([A-Za-z_][A-Za-z0-9_.]*)\)'
    )
    text = simple_wrapper.sub(r'\1', text)

    allowed_composites = {
        "MizanI18n.user('${person.name} · ${bank.userWrittenName} · ${debt.displayKind}')",
        "MizanI18n.user('${person.name} · ${debt.creditorType.label} · ${debt.displayCreditor}')",
        "MizanI18n.user('${person.name} · ${bill.institutionName}')",
        "MizanI18n.user('${person.name} · ${subscription.providerName}')",
        "MizanI18n.user('${person.name} · ${rent.receiverName}')",
    }
    remaining = text.count('MizanI18n.user(')
    missing = sorted(item for item in allowed_composites if item not in text)
    if remaining != len(allowed_composites) or missing:
        raise SystemExit(
            'Unexpected user-protection markers remain in report model data: '
            f'count={remaining}, missing={missing}'
        )
    path.write_text(text, encoding='utf-8')


def update_confirmation_flow() -> None:
    screen_path = Path('lib/screens/expenses_screen.dart')
    screen = screen_path.read_text(encoding='utf-8')
    old_validator = """                  validator: (value) => value?.trim() == 'ONAYLIYORUM'
                      ? null
                      : 'Tam olarak ONAYLIYORUM yazılmalı.',"""
    new_validator = """                  validator: (value) {
                    final expectedConfirmation = MizanI18n.isEnglish
                        ? 'I CONFIRM'
                        : 'ONAYLIYORUM';
                    if (value?.trim() == expectedConfirmation) {
                      return null;
                    }
                    return MizanI18n.isEnglish
                        ? 'You must type I CONFIRM exactly.'
                        : 'Tam olarak ONAYLIYORUM yazılmalı.';
                  },"""
    screen = replace_once(
        screen,
        old_validator,
        new_validator,
        'expense category confirmation validator',
    )
    screen_path.write_text(screen, encoding='utf-8')

    controller_path = Path('lib/controllers/mizan_controller.dart')
    controller = controller_path.read_text(encoding='utf-8')
    old_check = """    if (confirmation.trim() != 'ONAYLIYORUM') {
      throw ArgumentError(
        'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.',
      );
    }"""
    new_check = """    final expectedConfirmation =
        MizanI18n.normalizeLanguageTag(_state.appLanguageTag) == 'en'
        ? 'I CONFIRM'
        : 'ONAYLIYORUM';
    if (confirmation.trim() != expectedConfirmation) {
      throw ArgumentError(
        'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.',
      );
    }"""
    controller = replace_once(
        controller,
        old_check,
        new_check,
        'controller category confirmation check',
    )
    controller_path.write_text(controller, encoding='utf-8')


if __name__ == '__main__':
    update_l10n()
    update_report_model_user_data()
    update_confirmation_flow()
