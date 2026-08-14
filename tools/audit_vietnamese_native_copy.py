#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PARTS = ("core", "dashboard", "records", "reports", "settings", "validation")
PAIR_RE = re.compile(r"'((?:\\.|[^'])*)'\s*:\s*'((?:\\.|[^'])*)'\s*,?", re.S)


def unescape(value: str) -> str:
    return value.replace("\\'", "'").replace("\\\\", "\\")


def read_map(prefix: str, part: str) -> dict[str, str]:
    path = ROOT / "lib" / "l10n" / prefix / f"mizan_{prefix}_{part}.dart"
    if not path.exists():
        raise AssertionError(f"missing localization part: {path.relative_to(ROOT)}")
    content = path.read_text(encoding="utf-8")
    pairs = [(unescape(k), unescape(v)) for k, v in PAIR_RE.findall(content)]
    if not pairs:
        raise AssertionError(f"no localization pairs found: {path.relative_to(ROOT)}")
    keys = [k for k, _ in pairs]
    if len(keys) != len(set(keys)):
        dupes = sorted({k for k in keys if keys.count(k) > 1})
        raise AssertionError(f"duplicate keys in {path.name}: {dupes[:10]}")
    return dict(pairs)


def main() -> int:
    reference: dict[str, str] = {}
    vietnamese: dict[str, str] = {}
    for part in PARTS:
        reference.update(read_map("id", part))
        vietnamese.update(read_map("vi", part))

    if len(reference) != 791:
        raise AssertionError(f"reference key count changed: {len(reference)} != 791")
    if len(vietnamese) != 791:
        raise AssertionError(f"Vietnamese static key count: {len(vietnamese)} != 791")
    if set(vietnamese) != set(reference):
        missing = sorted(set(reference) - set(vietnamese))
        extra = sorted(set(vietnamese) - set(reference))
        raise AssertionError(f"Vietnamese key mismatch; missing={missing[:8]} extra={extra[:8]}")

    empty = [k for k, v in vietnamese.items() if not v.strip()]
    if empty:
        raise AssertionError(f"empty Vietnamese values: {empty[:10]}")

    identical = [
        k for k, v in vietnamese.items()
        if v.strip() == k.strip()
        and k not in {
            "IBAN", "MİZAN", "PDF", "CSV", "Android", "WhatsApp",
            "LEFFERION PRIME - MIZAN", "LEFFERION PRIME - MİZAN",
        }
    ]
    if identical:
        raise AssertionError(f"untranslated source values: {identical[:15]}")

    joined = "\n".join(vietnamese.values())
    # Vietnamese UI copy must not contain unrelated-script system leakage.
    forbidden_scripts = {
        "Hangul": r"[\uac00-\ud7af]",
        "Kana": r"[\u3040-\u30ff]",
        "Arabic": r"[\u0600-\u06ff]",
        "Hebrew": r"[\u0590-\u05ff]",
        "Devanagari": r"[\u0900-\u097f]",
        "Bengali": r"[\u0980-\u09ff]",
        "Thai": r"[\u0e00-\u0e7f]",
        "Cyrillic": r"[\u0400-\u04ff]",
    }
    for name, pattern in forbidden_scripts.items():
        if re.search(pattern, joined):
            raise AssertionError(f"{name} script leaked into Vietnamese system copy")

    forbidden_lexemes = (
        "pengeluaran", "pengaturan", "utang", "tagihan", "cicilan",
        "notifikasi", "pengingat", "rekod", "perbelanjaan", "tetapan",
        "pemberitahuan", "mga tala", "mga gastusin", "mga setting",
    )
    lowered = joined.casefold()
    leaks = [word for word in forbidden_lexemes if word in lowered]
    if leaks:
        raise AssertionError(f"Indonesian/Malay/Filipino lexical leakage: {leaks}")

    must_have = (
        "thanh toán", "chi tiêu", "khoản nợ", "thông báo", "báo cáo",
        "thu nhập", "đến hạn", "cài đặt", "sao lưu",
    )
    missing_terms = [term for term in must_have if term not in lowered]
    if missing_terms:
        raise AssertionError(f"expected Vietnamese product terminology missing: {missing_terms}")

    dynamic = (ROOT / "lib" / "l10n" / "mizan_vi_dynamic.dart").read_text(encoding="utf-8")
    for marker in ("Còn", "Quá hạn", "Lời nhắc thanh toán", "Không thể lưu báo cáo PDF"):
        if marker not in dynamic:
            raise AssertionError(f"Vietnamese dynamic marker missing: {marker}")

    print("Vietnamese native-copy audit passed: 791/791 static values, dynamic grammar present, no cross-language script/lexical leakage.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as exc:
        print(f"VIETNAMESE AUDIT FAILED: {exc}", file=sys.stderr)
        raise SystemExit(1)
