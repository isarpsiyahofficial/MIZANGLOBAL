#!/usr/bin/env python3
"""Apply the final reviewed Iranian Persian copy corrections deterministically."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REPLACEMENTS: dict[str, tuple[tuple[str, str], ...]] = {
    "lib/l10n/fa/mizan_fa_core.dart": (
        ("'Nakit avans': 'پیش‌پرداخت نقدی',", "'Nakit avans': 'برداشت نقدی',"),
        (
            "'Taksitli nakit avans': 'پیش‌پرداخت نقدی اقساطی',",
            "'Taksitli nakit avans': 'برداشت نقدی اقساطی',",
        ),
        ("'Bakım / servis': 'نگه‌داری یا خدمات',", "'Bakım / servis': 'نگهداری یا خدمات',"),
        (
            "'Eşleşen sonuç bulunamadı.': 'نتیجه مطابقی پیدا نشد.',",
            "'Eşleşen sonuç bulunamadı.': 'نتیجه‌ای مطابق جست‌وجو پیدا نشد.',",
        ),
    ),
    "lib/l10n/fa/mizan_fa_dashboard.dart": (
        (
            "'برای این رکورد یادداشتی وجود ندارد. یادداشت‌ها جدا از توضیحات پرداخت نگه‌داری می‌شوند.',",
            "'برای این رکورد یادداشتی وجود ندارد. یادداشت‌ها جدا از توضیحات پرداخت نگهداری می‌شوند.',",
        ),
        (
            "'خودرو، خوراک، 23.07.2026، پنج‌شنبه…',",
            "'خودرو، ماست، 23.07.2026، پنج‌شنبه…',",
        ),
        (
            "'پرداخت‌های تکرارشونده خدمات دیجیتال، عضویت، بیمه، آموزش و نگه‌داری در بازه‌های مشخص',",
            "'پرداخت‌های تکرارشونده خدمات دیجیتال، عضویت، بیمه، آموزش و نگهداری در بازه‌های مشخص',",
        ),
    ),
    "lib/l10n/fa/mizan_fa_records.dart": (
        ("'Kayıt sahibi': 'مالک رکورد',", "'Kayıt sahibi': 'صاحب رکورد',"),
        ("'Toplam ödeme': 'مجموع پرداخت',", "'Toplam ödeme': 'مجموع پرداخت‌ها',"),
        ("'Borç ürünü ekle': 'افزودن محصول بدهی',", "'Borç ürünü ekle': 'افزودن محصول اعتباری',"),
        (
            "'Borç ürününü düzenle': 'ویرایش محصول بدهی',",
            "'Borç ürününü düzenle': 'ویرایش محصول اعتباری',",
        ),
        (
            "'Güncel manuel gecikme günü': 'روز تأخیر دستی فعلی',",
            "'Güncel manuel gecikme günü': 'تعداد روزهای تأخیر دستی فعلی',",
        ),
        (
            "'Yeni manuel gecikme günü (opsiyonel)': 'روز تأخیر دستی جدید (اختیاری)',",
            "'Yeni manuel gecikme günü (opsiyonel)': 'تعداد روزهای تأخیر دستی جدید (اختیاری)',",
        ),
        ("'Ev sahibi / alıcı': 'مالک یا دریافت‌کننده',", "'Ev sahibi / alıcı': 'موجر یا دریافت‌کننده',"),
        (
            "'Banka bilgisi (kullanıcı girişi)': 'اطلاعات بانک (ورودی کاربر)',",
            "'Banka bilgisi (kullanıcı girişi)': 'اطلاعات بانک (واردشده توسط کاربر)',",
        ),
    ),
    "lib/l10n/fa/mizan_fa_reports.dart": (
        (
            "'Yaklaşan ödeme ayrıntıları': 'جزئیات پرداخت‌های نزدیک',",
            "'Yaklaşan ödeme ayrıntıları': 'جزئیات پرداخت‌های نزدیک به سررسید',",
        ),
        (
            "'Yaklaşan ödeme yükü': 'تعهد پرداخت نزدیک',",
            "'Yaklaşan ödeme yükü': 'تعهدات پرداخت نزدیک به سررسید',",
        ),
    ),
    "lib/l10n/fa/mizan_fa_settings.dart": (
        (
            "'Kişi kaydı bulunmuyor.': 'رکورد شخصی وجود ندارد.',",
            "'Kişi kaydı bulunmuyor.': 'هیچ شخصی ثبت نشده است.',",
        ),
    ),
    "lib/l10n/fa/mizan_fa_validation.dart": (
        ("'Kullanılan limit': 'سقف استفاده‌شده',", "'Kullanılan limit': 'مبلغ استفاده‌شده از سقف',"),
    ),
    "lib/l10n/mizan_fa_dynamic.dart": (
        ("('Yaklaşan ödeme yükü', 'تعهد پرداخت نزدیک'),", "('Yaklaşan ödeme yükü', 'تعهدات پرداخت نزدیک به سررسید'),"),
    ),
}


def apply() -> None:
    changed: list[str] = []
    for relative, replacements in REPLACEMENTS.items():
        path = ROOT / relative
        text = path.read_text(encoding="utf-8")
        original = text
        for old, new in replacements:
            if new in text:
                continue
            count = text.count(old)
            if count != 1:
                raise SystemExit(
                    f"Expected exactly one Persian final-copy target in {relative}; "
                    f"found {count}: {old!r}"
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
