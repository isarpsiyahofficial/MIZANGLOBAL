from __future__ import annotations

from pathlib import Path


PATH = Path("tools/build_arabic_locale.py")


def main() -> None:
    text = PATH.read_text(encoding="utf-8")
    old = '        "\'\\\\u2068${entry.value}\\\\u2069\'",\n'
    new = (
        '        "final visibleUser = effective == \'ar\'",\n'
        '        "\\u2068",\n'
        '        "\\u2069",\n'
    )
    if new in text:
        print("Arabic builder already uses format-independent bidi verification.")
        return
    if text.count(old) != 1:
        raise SystemExit(
            f"Expected one Arabic bidi verifier marker; found {text.count(old)}"
        )
    PATH.write_text(text.replace(old, new, 1), encoding="utf-8")
    print("Arabic builder prepared with format-independent bidi verification.")


if __name__ == "__main__":
    main()
