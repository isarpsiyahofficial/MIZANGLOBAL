from __future__ import annotations

from pathlib import Path


PATH = Path("tools/apply_runtime_reliability_fixes.py")


def main() -> None:
    text = PATH.read_text(encoding="utf-8")

    early_guard = """    if \"MizanI18n.isUkrainian\" in text:
        for fragment in (
            \"MizanI18n.isRussian || MizanI18n.isUkrainian\",
            \"MizanI18n.isPolish ? '\\\\u202F' : '\\\\u00A0'\",
        ):
            if fragment not in text:
                raise SystemExit(
                    f\"lib/core/formatters.dart: missing Ukrainian-aware reliability fragment {fragment!r}\"
                )
        return

"""
    anchor = '    money_old = r"""'
    if early_guard not in text:
        if text.count(anchor) != 1:
            raise SystemExit("runtime reliability formatter anchor is not unique")
        text = text.replace(anchor, early_guard + anchor, 1)

    old_required = '            "MizanI18n.isRussian\\n                  ? \'\\\\u00A0\'",\n'
    new_required = '            "MizanI18n.isRussian || MizanI18n.isUkrainian",\n'
    if old_required in text:
        if text.count(old_required) != 1:
            raise SystemExit("runtime reliability required-fragment anchor is not unique")
        text = text.replace(old_required, new_required, 1)
    elif new_required not in text:
        raise SystemExit("runtime reliability required fragment is missing")

    PATH.write_text(text, encoding="utf-8")
    print("Runtime reliability verifier prepared for Russian and Ukrainian formatters.")


if __name__ == "__main__":
    main()
