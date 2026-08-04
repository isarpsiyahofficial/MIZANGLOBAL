from __future__ import annotations

from pathlib import Path


PATH = Path("lib/l10n/mizan_uk_dynamic.dart")


def main() -> None:
    text = PATH.read_text(encoding="utf-8")
    unused = """String _people(String value) =>
    _plural(value, 'людина', 'людини', 'людей');
"""
    if unused in text:
        if text.count(unused) != 1:
            raise SystemExit("unused Ukrainian people helper is not unique")
        text = text.replace(unused, "", 1)
    elif "String _people(" in text:
        raise SystemExit("unrecognized Ukrainian people helper formatting")
    PATH.write_text(text, encoding="utf-8")
    print("Ukrainian Dart sources prepared without unused helpers.")


if __name__ == "__main__":
    main()
