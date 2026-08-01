from __future__ import annotations

import re
from pathlib import Path


def replace_value_idempotent(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        return text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected one old value, found {count}')
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

    value_replacements = (
        (
            'You must type ONAYLIYORUM exactly to delete the category.',
            'You must type I CONFIRM exactly to delete the category.',
        ),
        ("'ONAYLIYORUM': 'ONAYLIYORUM'", "'ONAYLIYORUM': 'I CONFIRM'"),
        ('Company / Institution', 'Company / Organization'),
        ('Home rent', 'Residential rent'),
        ('One-time period', 'One-time'),
        (
            'Search by date, weekday, expense, category, or note. Turkish characters and joined terms are supported.',
            'Search by date, weekday, expense, category, or note. Accented characters and concatenated terms are supported.',
        ),
        ('Outstanding payment burden', 'Outstanding payment obligations'),
        ('Completed spending breakdown', 'Actual spending breakdown'),
        ('Completed payment details', 'Recorded payment details'),
        (
            'No completed payments were found within the selected scope.',
            'No recorded payments were found within the selected scope.',
        ),
        (
            "period\\'s outstanding payment burden.",
            "period\\'s outstanding payment obligations.",
        ),
        (
            'Completed payments and expenses are deducted from income in sequence.',
            'Recorded payments and expenses are deducted from income in sequence.',
        ),
        (
            'Outstanding payment burden in the selected period',
            'Outstanding payment obligations in the selected period',
        ),
        ('Overdue payment burden', 'Overdue payment obligations'),
        ('Upcoming payment burden', 'Upcoming payment obligations'),
    )
    for index, (old, new) in enumerate(value_replacements, 1):
        text = replace_value_idempotent(
            text,
            old,
            new,
            f'English copy value {index}',
        )
    path.write_text(text, encoding='utf-8')


def update_report_model_user_data() -> None:
    path = Path('lib/services/report_service.dart')
    text = path.read_text(encoding='utf-8')
    simple_wrapper = re.compile(
        r'MizanI18n\.user\(([A-Za-z_][A-Za-z0-9_.]*)\)'
    )
    text = simple_wrapper.sub(r'\1', text)

    allowed_composite_fragments = {
        '${person.name} · ${bank.userWrittenName} · ${debt.displayKind}',
        '${person.name} · ${debt.creditorType.label} · ${debt.displayCreditor}',
        '${person.name} · ${bill.institutionName}',
        '${person.name} · ${subscription.providerName}',
        '${person.name} · ${rent.receiverName}',
    }
    remaining = text.count('MizanI18n.user(')
    missing = sorted(
        fragment for fragment in allowed_composite_fragments if fragment not in text
    )
    if remaining != len(allowed_composite_fragments) or missing:
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
    if old_validator in screen:
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
        screen = screen.replace(old_validator, new_validator, 1)
    required_screen_fragments = (
        'final expectedConfirmation = MizanI18n.isEnglish',
        "? 'I CONFIRM'",
        'You must type I CONFIRM exactly.',
    )
    missing_screen = [item for item in required_screen_fragments if item not in screen]
    if missing_screen:
        raise SystemExit(
            f'English confirmation validator is incomplete: {missing_screen}'
        )
    screen_path.write_text(screen, encoding='utf-8')

    controller_path = Path('lib/controllers/mizan_controller.dart')
    controller = controller_path.read_text(encoding='utf-8')
    old_check = """    if (confirmation.trim() != 'ONAYLIYORUM') {
      throw ArgumentError(
        'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.',
      );
    }"""
    if old_check in controller:
        new_check = """    final expectedConfirmation =
        MizanI18n.normalizeLanguageTag(_state.appLanguageTag) == 'en'
        ? 'I CONFIRM'
        : 'ONAYLIYORUM';
    if (confirmation.trim() != expectedConfirmation) {
      throw ArgumentError(
        'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.',
      );
    }"""
        controller = controller.replace(old_check, new_check, 1)
    required_controller_fragments = (
        'final expectedConfirmation =',
        "MizanI18n.normalizeLanguageTag(_state.appLanguageTag) == 'en'",
        "? 'I CONFIRM'",
        'confirmation.trim() != expectedConfirmation',
    )
    missing_controller = [
        item for item in required_controller_fragments if item not in controller
    ]
    if missing_controller:
        raise SystemExit(
            f'Controller confirmation guard is incomplete: {missing_controller}'
        )
    controller_path.write_text(controller, encoding='utf-8')


def update_installment_cycle_amount() -> None:
    path = Path('lib/models/mizan_models.dart')
    text = path.read_text(encoding='utf-8')
    old = '  double get scheduledPaymentAmount => dueAmountAt(DateTime.now());'
    new = '  double get scheduledPaymentAmount => plannedCycleAmount;'
    text = replace_value_idempotent(
        text,
        old,
        new,
        'rent scheduled payment amount',
    )
    path.write_text(text, encoding='utf-8')


def update_time_stable_expense_test() -> None:
    path = Path('test/ui_interaction_test.dart')
    text = path.read_text(encoding='utf-8')
    import_line = (
        "import 'package:lefferion_prime_mizan/services/expense_browser_service.dart';"
    )
    if import_line not in text:
        anchor = "import 'package:lefferion_prime_mizan/models/mizan_models.dart';\n"
        if text.count(anchor) != 1:
            raise SystemExit('Expense browser test import anchor is invalid.')
        text = text.replace(anchor, f'{anchor}{import_line}\n', 1)

    old_reference = (
        '    final state = comprehensiveState(reference: DateTime(2026, 7, 24, 10))\n'
        '        .copyWith(\n'
    )
    if old_reference in text:
        text = text.replace(
            old_reference,
            '    final today = dateOnly(DateTime.now());\n'
            '    final previousDay = today.subtract(const Duration(days: 1));\n'
            '    final state = comprehensiveState(reference: today).copyWith(\n',
            1,
        )
        text = text.replace(
            '              spentAt: DateTime(2026, 7, 24),',
            '              spentAt: today,',
            1,
        )
        text = text.replace(
            '              spentAt: DateTime(2026, 7, 23),',
            '              spentAt: previousDay,',
            1,
        )
        text = text.replace(
            "    final matchingDay = find.text('24.07.2026 Cuma');",
            '    final matchingDay = find.text(\n'
            '      const ExpenseBrowserService().dayLabel(today),\n'
            '    );',
            1,
        )
    required_fragments = (
        'final today = dateOnly(DateTime.now());',
        'final previousDay = today.subtract(const Duration(days: 1));',
        'spentAt: today,',
        'spentAt: previousDay,',
        'const ExpenseBrowserService().dayLabel(today)',
    )
    missing = [item for item in required_fragments if item not in text]
    if missing:
        raise SystemExit(f'Time-stable expense test is incomplete: {missing}')
    path.write_text(text, encoding='utf-8')


if __name__ == '__main__':
    update_l10n()
    update_report_model_user_data()
    update_confirmation_flow()
    update_installment_cycle_amount()
    update_time_stable_expense_test()
