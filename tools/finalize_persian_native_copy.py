#!/usr/bin/env python3
"""Apply the final reviewed Iranian Persian copy corrections deterministically."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REPLACEMENTS: dict[str, tuple[tuple[str, str], ...]] = {
    "lib/l10n/fa/mizan_fa_core.dart": (
        ("'پیش‌پرداخت نقدی'", "'برداشت نقدی'"),
        ("'پیش‌پرداخت نقدی اقساطی'", "'برداشت نقدی اقساطی'"),
        ("'نگه‌داری یا خدمات'", "'نگهداری یا خدمات'"),
        ("'نتیجه مطابقی پیدا نشد.'", "'نتیجه‌ای مطابق جست‌وجو پیدا نشد.'"),
    ),
    "lib/l10n/fa/mizan_fa_dashboard.dart": (
        (
            "'برای این رکورد یادداشتی وجود ندارد. یادداشت‌ها جدا از توضیحات پرداخت نگه‌داری می‌شوند.'",
            "'برای این رکورد یادداشتی وجود ندارد. یادداشت‌ها جدا از توضیحات پرداخت نگهداری می‌شوند.'",
        ),
        ("'خودرو، خوراک، 23.07.2026، پنج‌شنبه…'", "'خودرو، ماست، 23.07.2026، پنج‌شنبه…'"),
        (
            "'پرداخت‌های تکرارشونده خدمات دیجیتال، عضویت، بیمه، آموزش و نگه‌داری در بازه‌های مشخص'",
            "'پرداخت‌های تکرارشونده خدمات دیجیتال، عضویت، بیمه، آموزش و نگهداری در بازه‌های مشخص'",
        ),
    ),
    "lib/l10n/fa/mizan_fa_records.dart": (
        ("'مالک رکورد'", "'صاحب رکورد'"),
        ("'مجموع پرداخت'", "'مجموع پرداخت‌ها'"),
        ("'افزودن محصول بدهی'", "'افزودن محصول اعتباری'"),
        ("'ویرایش محصول بدهی'", "'ویرایش محصول اعتباری'"),
        ("'روز تأخیر دستی فعلی'", "'تعداد روزهای تأخیر دستی فعلی'"),
        ("'روز تأخیر دستی جدید (اختیاری)'", "'تعداد روزهای تأخیر دستی جدید (اختیاری)'"),
        ("'مالک یا دریافت‌کننده'", "'موجر یا دریافت‌کننده'"),
        ("'اطلاعات بانک (ورودی کاربر)'", "'اطلاعات بانک (واردشده توسط کاربر)'"),
    ),
    "lib/l10n/fa/mizan_fa_reports.dart": (
        ("'جزئیات پرداخت‌های نزدیک'", "'جزئیات پرداخت‌های نزدیک به سررسید'"),
        ("'تعهد پرداخت نزدیک'", "'تعهدات پرداخت نزدیک به سررسید'"),
    ),
    "lib/l10n/fa/mizan_fa_settings.dart": (
        ("'رکورد شخصی وجود ندارد.'", "'هیچ شخصی ثبت نشده است.'"),
    ),
    "lib/l10n/fa/mizan_fa_validation.dart": (
        ("'سقف استفاده‌شده'", "'مبلغ استفاده‌شده از سقف'"),
    ),
    "lib/l10n/mizan_fa_dynamic.dart": (
        ("'تعهد پرداخت نزدیک'", "'تعهدات پرداخت نزدیک به سررسید'"),
    ),
}


def apply() -> None:
    changed: list[str] = []
    for relative, replacements in REPLACEMENTS.items():
        path = ROOT / relative
        text = path.read_text(encoding="utf-8")
        original = text
        for old, new in replacements:
            old_count = text.count(old)
            new_count = text.count(new)
            if old_count == 0:
                if new_count == 0:
                    raise SystemExit(
                        f"Persian final-copy value is missing in {relative}: {old!r} -> {new!r}"
                    )
                continue
            if old_count != 1:
                raise SystemExit(
                    f"Expected exactly one Persian final-copy value in {relative}; "
                    f"found {old_count}: {old!r}"
                )
            text = text.replace(old, new, 1)
        if text != original:
            path.write_text(text, encoding="utf-8")
            changed.append(relative)
    print(
        "Persian final native-copy corrections applied: "
        + (", ".join(changed) if changed else "already current")
    )


if __name__ == "__main__":
    apply()
