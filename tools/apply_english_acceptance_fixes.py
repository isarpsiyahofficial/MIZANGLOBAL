from __future__ import annotations

import re
from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{label}: expected one occurrence, found {count}')
    return text.replace(old, new, 1)


def replace_idempotent(text: str, old: str, new: str, label: str) -> str:
    old_count = text.count(old)
    new_count = text.count(new)
    if old_count == 1 and new_count == 0:
        return text.replace(old, new, 1)
    if old_count == 0 and new_count == 1:
        return text
    raise SystemExit(
        f'{label}: expected either one old or one new occurrence, '
        f'found old={old_count}, new={new_count}'
    )


def update_l10n() -> None:
    path = Path('lib/l10n/mizan_i18n.dart')
    text = path.read_text(encoding='utf-8')
    exact_entry = "    'MİZAN Aylık Raporu': 'MİZAN Monthly Report',\n"
    if exact_entry not in text:
        anchor = "  static const Map<String, String> _english = <String, String>{\n"
        if text.count(anchor) != 1:
            raise SystemExit('English translation map anchor is missing or duplicated.')
        text = text.replace(anchor, anchor + exact_entry, 1)

    copy_replacements = {
        "'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.': 'You must type ONAYLIYORUM exactly to delete the category.'":
            "'Kategori silmek için tam olarak ONAYLIYORUM yazılmalı.': 'You must type I CONFIRM exactly to delete the category.'",
        "'ONAYLIYORUM': 'ONAYLIYORUM'":
            "'ONAYLIYORUM': 'I CONFIRM'",
        "'Şirket / Kurum': 'Company / Institution'":
            "'Şirket / Kurum': 'Company / Organization'",
        "'Ev kirası': 'Home rent'":
            "'Ev kirası': 'Residential rent'",
        "'Tek dönem': 'One-time period'":
            "'Tek dönem': 'One-time'",
        "'Tarih, gün adı, gider, kategori veya not yazabilirsiniz. Türkçe karakterler ve bitişik ifadeler eşleşir.': 'Search by date, weekday, expense, category, or note. Turkish characters and joined terms are supported.'":
            "'Tarih, gün adı, gider, kategori veya not yazabilirsiniz. Türkçe karakterler ve bitişik ifadeler eşleşir.': 'Search by date, weekday, expense, category, or note. Accented characters and concatenated terms are supported.'",
        "'Kalan ödeme yükü': 'Outstanding payment burden'":
            "'Kalan ödeme yükü': 'Outstanding payment obligations'",
        "'Gerçekleşen harcamaların dağılımı': 'Completed spending breakdown'":
            "'Gerçekleşen harcamaların dağılımı': 'Actual spending breakdown'",
        "'Gerçekleşen ödeme ayrıntıları': 'Completed payment details'":
            "'Gerçekleşen ödeme ayrıntıları': 'Recorded payment details'",
        "'Seçili kapsamda gerçekleşen ödeme bulunmuyor.': 'No completed payments were found within the selected scope.'":
            "'Seçili kapsamda gerçekleşen ödeme bulunmuyor.': 'No recorded payments were found within the selected scope.'",
        "'Seçili döneme taşınan gecikmiş kayıtlar ile dönemin açık ödeme yükü ayrıntılı gösterilir.': 'Shows overdue records carried into the selected period together with the period\\'s outstanding payment burden.'":
            "'Seçili döneme taşınan gecikmiş kayıtlar ile dönemin açık ödeme yükü ayrıntılı gösterilir.': 'Shows overdue records carried into the selected period together with the period\\'s outstanding payment obligations.'",
        "'Gelirden gerçekleşen ödemeler ve giderler sırayla düşülür.': 'Completed payments and expenses are deducted from income in sequence.'":
            "'Gelirden gerçekleşen ödemeler ve giderler sırayla düşülür.': 'Recorded payments and expenses are deducted from income in sequence.'",
        "'Seçili dönemde kalan ödeme yükü': 'Outstanding payment burden in the selected period'":
            "'Seçili dönemde kalan ödeme yükü': 'Outstanding payment obligations in the selected period'",
        "'Gecikmiş ödeme yükü': 'Overdue payment burden'":
            "'Gecikmiş ödeme yükü': 'Overdue payment obligations'",
        "'Yaklaşan ödeme yükü': 'Upcoming payment burden'":
            "'Yaklaşan ödeme yükü': 'Upcoming payment obligations'",
    }
    for index, (old, new) in enumerate(copy_replacements.items(), 1):
        text = replace_idempotent(text, old, new, f'copy replacement {index}')
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
    screen = replace_idempotent(
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
    controller = replace_idempotent(
        controller,
        old_check,
        new_check,
        'controller category confirmation check',
    )
    controller_path.write_text(controller, encoding='utf-8')


def update_installment_cycle_amount() -> None:
    path = Path('lib/models/mizan_models.dart')
    text = path.read_text(encoding='utf-8')
    text = replace_idempotent(
        text,
        '  double get scheduledPaymentAmount => dueAmountAt(DateTime.now());',
        '  double get scheduledPaymentAmount => plannedCycleAmount;',
        'rent scheduled payment amount',
    )
    path.write_text(text, encoding='utf-8')


def update_time_stable_expense_test() -> None:
    path = Path('test/ui_interaction_test.dart')
    text = path.read_text(encoding='utf-8')
    text = replace_idempotent(
        text,
        "import 'package:lefferion_prime_mizan/models/mizan_models.dart';\n",
        "import 'package:lefferion_prime_mizan/models/mizan_models.dart';\n"
        "import 'package:lefferion_prime_mizan/services/expense_browser_service.dart';\n",
        'expense browser test import',
    )
    text = replace_idempotent(
        text,
        "    final state = comprehensiveState(reference: DateTime(2026, 7, 24, 10))\n"
        "        .copyWith(\n",
        "    final today = dateOnly(DateTime.now());\n"
        "    final previousDay = today.subtract(const Duration(days: 1));\n"
        "    final state = comprehensiveState(reference: today).copyWith(\n",
        'expense search reference date',
    )
    text = replace_idempotent(
        text,
        '              spentAt: DateTime(2026, 7, 24),',
        '              spentAt: today,',
        'matching expense date',
    )
    text = replace_idempotent(
        text,
        '              spentAt: DateTime(2026, 7, 23),',
        '              spentAt: previousDay,',
        'nonmatching expense date',
    )
    text = replace_idempotent(
        text,
        "    final matchingDay = find.text('24.07.2026 Cuma');",
        "    final matchingDay = find.text(\n"
        "      const ExpenseBrowserService().dayLabel(today),\n"
        "    );",
        'expense day label',
    )
    path.write_text(text, encoding='utf-8')


if __name__ == '__main__':
    update_l10n()
    update_report_model_user_data()
    update_confirmation_flow()
    update_installment_cycle_amount()
    update_time_stable_expense_test()
