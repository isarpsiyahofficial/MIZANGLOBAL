from __future__ import annotations

from pathlib import Path


PATH = Path("tools/build_arabic_locale.py")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        return text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected one {label} marker; found {count}")
    return text.replace(old, new, 1)


def main() -> None:
    text = PATH.read_text(encoding="utf-8")

    old_verifier = '        "\'\\\\u2068${entry.value}\\\\u2069\'",\n'
    new_verifier = (
        '        "final visibleUser = effective == \'ar\'",\n'
        '        "result.replaceAll(entry.key, visibleUser)",\n'
    )
    text = replace_once(
        text,
        old_verifier,
        new_verifier,
        "Arabic bidi verifier",
    )

    old_user_template = r"          ? '\u2068${entry.value}\u2069'"
    new_user_template = r"          ? '\\u2068${entry.value}\\u2069'"
    text = replace_once(
        text,
        old_user_template,
        new_user_template,
        "Arabic user-text isolation template",
    )

    old_ltr_template = r"String _ltrIsolate(String value) => '\u2066$value\u2069';"
    new_ltr_template = r"String _ltrIsolate(String value) => '\\u2066$value\\u2069';"
    text = replace_once(
        text,
        old_ltr_template,
        new_ltr_template,
        "Arabic LTR isolation template",
    )

    PATH.write_text(text, encoding="utf-8")
    print(
        "Arabic builder prepared with format-independent verification and "
        "escaped bidi controls."
    )


if __name__ == "__main__":
    main()
