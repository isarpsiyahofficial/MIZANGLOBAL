#!/usr/bin/env python3
"""Apply fail-closed English singular/plural fixes to the generated runtime.

The legacy English runtime predates the stricter native-language gates and used
plural nouns for every numeric dynamic string. French integration rebuilds the
runtime deterministically, so this patch is run immediately after that build
and is committed with the generated product source.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
I18N = ROOT / "lib" / "l10n" / "mizan_i18n.dart"

REPLACEMENTS: tuple[tuple[str, str], ...] = (
    (
        "(m) => '${m[1]} open records · ${m[2]}',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"open record\" : \"open records\"} · ${m[2]}',",
    ),
    (
        "(m) => '${m[1]} daily expenses · ${m[2]} payments',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"daily expense\" : \"daily expenses\"} · ${m[2]} ${m[2] == '1' ? \"payment\" : \"payments\"}',",
    ),
    (
        "(m) => '${m[1]} days · ${m[2]} records · ${m[3]}',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"day\" : \"days\"} · ${m[2]} ${m[2] == '1' ? \"record\" : \"records\"} · ${m[3]}',",
    ),
    (
        "(m) => '${m[1]} payments · ${m[2]}',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"payment\" : \"payments\"} · ${m[2]}',",
    ),
    (
        "(m) => '${m[1]} expenses · ${m[2]}',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"expense\" : \"expenses\"} · ${m[2]}',",
    ),
    (
        "(m) => '${m[1]} expense records',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"expense record\" : \"expense records\"}',",
    ),
    (
        "(m) => '${m[1]} is due in ${m[2]} days',",
        "(m) => '${m[1]} is due in ${m[2]} ${m[2] == '1' ? \"day\" : \"days\"}',",
    ),
    (
        "(m) => '${m[1]} is ${m[2]} days overdue',",
        "(m) => '${m[1]} is ${m[2]} ${m[2] == '1' ? \"day\" : \"days\"} overdue',",
    ),
    (
        "'${m[1]} entries in the notification schedule could not be written to Android. First error: ${m[2]}',",
        "'${m[1]} ${m[1] == '1' ? \"entry\" : \"entries\"} in the notification schedule could not be written to Android. First error: ${m[2]}',",
    ),
    (
        "'The notification schedule could not be verified; ${m[1]} entries are missing on Android.',",
        "'The notification schedule could not be verified; ${m[1]} ${m[1] == '1' ? \"entry is\" : \"entries are\"} missing on Android.',",
    ),
    (
        "(m) => '${m[1]} days remaining',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"day\" : \"days\"} remaining',",
    ),
    (
        "(m) => '${m[1]} days overdue',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"day\" : \"days\"} overdue',",
    ),
    (
        "(m) => 'Payment is ${m[1]} days overdue.',",
        "(m) => 'Payment is ${m[1]} ${m[1] == '1' ? \"day\" : \"days\"} overdue.',",
    ),
    (
        "_LocalizedPattern(RegExp(r'^(\\d+) kayıt$'), (m) => '${m[1]} records'),",
        "_LocalizedPattern(RegExp(r'^(\\d+) kayıt$'), (m) => '${m[1]} ${m[1] == '1' ? \"record\" : \"records\"}'),",
    ),
    (
        "_LocalizedPattern(RegExp(r'^(\\d+) ödeme$'), (m) => '${m[1]} payments'),",
        "_LocalizedPattern(RegExp(r'^(\\d+) ödeme$'), (m) => '${m[1]} ${m[1] == '1' ? \"payment\" : \"payments\"}'),",
    ),
    (
        "_LocalizedPattern(RegExp(r'^(\\d+) gider$'), (m) => '${m[1]} expenses'),",
        "_LocalizedPattern(RegExp(r'^(\\d+) gider$'), (m) => '${m[1]} ${m[1] == '1' ? \"expense\" : \"expenses\"}'),",
    ),
    (
        "(m) => '${m[1]} · ${m[2]} records',",
        "(m) => '${m[1]} · ${m[2]} ${m[2] == '1' ? \"record\" : \"records\"}',",
    ),
    (
        "_LocalizedPattern(RegExp(r'^(.+) gün$'), (m) => '${m[1]} days'),",
        "_LocalizedPattern(RegExp(r'^(.+) gün$'), (m) => '${m[1]} ${m[1] == '1' ? \"day\" : \"days\"}'),",
    ),
    (
        "_LocalizedPattern(RegExp(r'^(.+) ay$'), (m) => '${m[1]} months'),",
        "_LocalizedPattern(RegExp(r'^(.+) ay$'), (m) => '${m[1]} ${m[1] == '1' ? \"month\" : \"months\"}'),",
    ),
    (
        "(m) => '${m[1]} people selected',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"person selected\" : \"people selected\"}',",
    ),
    (
        "(m) => '${m[1]} new records were added; existing data was preserved.',",
        "(m) => '${m[1]} ${m[1] == '1' ? \"new record was\" : \"new records were\"} added; existing data was preserved.',",
    ),
)


def main() -> None:
    text = I18N.read_text(encoding="utf-8")
    changed = 0
    for old, new in REPLACEMENTS:
        if new in text:
            continue
        count = text.count(old)
        if count != 1:
            raise SystemExit(
                f"Expected one English grammar target, found {count}: {old[:100]!r}"
            )
        text = text.replace(old, new, 1)
        changed += 1

    I18N.write_text(text, encoding="utf-8")

    remaining = [old for old, new in REPLACEMENTS if old in text and new not in text]
    if remaining:
        raise SystemExit(f"English grammar targets remain: {remaining!r}")
    print(
        f"English dynamic grammar verified: {len(REPLACEMENTS)} singular/plural patterns; "
        f"{changed} updated."
    )


if __name__ == "__main__":
    main()
