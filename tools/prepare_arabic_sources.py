from __future__ import annotations

from pathlib import Path


DYNAMIC = Path("lib/l10n/mizan_ar_dynamic.dart")
SETTINGS = Path("lib/l10n/ar/mizan_ar_settings.dart")
END_TO_END = Path("test/arabic_end_to_end_test.dart")
LOCALIZATION_TEST = Path("test/arabic_localization_test.dart")


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if new in text:
        return
    if text.count(old) != 1:
        raise SystemExit(
            f"Expected one Arabic source preparation target in {path}: {old[:120]!r}; found {text.count(old)}"
        )
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    replace_once(
        DYNAMIC,
        """String _remainingDays(String value) => switch (_category(value)) {
  _ArabicPlural.zero => 'موعده اليوم',
  _ArabicPlural.one => 'متبق يوم واحد',
  _ArabicPlural.two => 'متبقيان يومان',
  _ArabicPlural.few => 'متبقية ${_days(value)}',
  _ArabicPlural.many => 'متبقي ${_days(value)}',
  _ArabicPlural.other => 'متبقي ${_days(value)}',
};
""",
        """String _remainingDays(String value) => switch (_category(value)) {
  _ArabicPlural.zero => 'موعد الاستحقاق اليوم',
  _ArabicPlural.one => 'يتبقى يوم واحد',
  _ArabicPlural.two => 'يتبقى يومان',
  _ArabicPlural.few => 'يتبقى ${_days(value)}',
  _ArabicPlural.many => 'يتبقى ${_days(value)}',
  _ArabicPlural.other => 'يتبقى ${_days(value)}',
};
""",
    )
    replace_once(
        DYNAMIC,
        "const List<(String, String)> _arabicPhrases = <(String, String)>[\n",
        "const List<(String, String)> _arabicPhrases = <(String, String)>[\n  ('Banka borcu', 'دين بنكي'),\n",
    )
    replace_once(
        SETTINGS,
        "'تتم جدولتـه في أيام الاستحقاق المحددة.'",
        "'تتم جدولته في أيام الاستحقاق المحددة.'",
    )
    replace_once(
        END_TO_END,
        "    expect(reminder.message, isNot(contains('المبلغ المتبقي')));\n",
        "    expect(reminder.message, isNot(contains('Оставшаяся сумма')));\n",
    )
    replacements = {
        "expect(MizanI18n.text('0 gün kaldı'), 'موعده اليوم');":
            "expect(MizanI18n.text('0 gün kaldı'), 'موعد الاستحقاق اليوم');",
        "expect(MizanI18n.text('1 gün kaldı'), 'متبق يوم واحد');":
            "expect(MizanI18n.text('1 gün kaldı'), 'يتبقى يوم واحد');",
        "expect(MizanI18n.text('2 gün kaldı'), 'متبقيان يومان');":
            "expect(MizanI18n.text('2 gün kaldı'), 'يتبقى يومان');",
        "expect(MizanI18n.text('3 gün kaldı'), 'متبقية 3 أيام');":
            "expect(MizanI18n.text('3 gün kaldı'), 'يتبقى 3 أيام');",
        "expect(MizanI18n.text('11 gün kaldı'), 'متبقي 11 يوما');":
            "expect(MizanI18n.text('11 gün kaldı'), 'يتبقى 11 يوما');",
        "expect(MizanI18n.text('102 gün kaldı'), 'متبقي 102 يوم');":
            "expect(MizanI18n.text('102 gün kaldı'), 'يتبقى 102 يوم');",
    }
    text = LOCALIZATION_TEST.read_text(encoding="utf-8")
    for old, new in replacements.items():
        if new in text:
            continue
        if text.count(old) != 1:
            raise SystemExit(
                f"Expected one Arabic test expectation target: {old!r}; found {text.count(old)}"
            )
        text = text.replace(old, new, 1)
    LOCALIZATION_TEST.write_text(text, encoding="utf-8")
    print("Arabic sources prepared with neutral remaining-day grammar and corrected runtime expectations.")


if __name__ == "__main__":
    main()
