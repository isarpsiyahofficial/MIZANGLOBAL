#!/usr/bin/env python3
"""Verify and render the committed Brazilian Portuguese localization.

Machine translation bootstrap generation is deliberately disabled. The product
locale may be changed only through the reviewed patch files and the complete
localization quality pipeline.
"""
from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "lib/l10n/mizan_i18n.dart"
OUTPUT = ROOT / "lib/l10n/mizan_pt_br.dart"
FINAL_HEADER = "// REVIEWED PT-BR LOCALIZATION — 791/791 STATIC VALUES AUDITED."
HEADER = FINAL_HEADER
ENGLISH_MARKER = "static const Map<String, String> _english"
PORTUGUESE_MARKER = "const Map<String, String> mizanPortugueseBr"


def _skip_space_and_comments(text: str, index: int) -> int:
    while index < len(text):
        if text[index].isspace():
            index += 1
            continue
        if text.startswith("//", index):
            newline = text.find("\n", index)
            return len(text) if newline < 0 else _skip_space_and_comments(text, newline + 1)
        if text.startswith("/*", index):
            end = text.find("*/", index + 2)
            if end < 0:
                raise ValueError("Unterminated block comment in Dart map")
            index = end + 2
            continue
        return index
    return index


def _parse_dart_string(text: str, index: int) -> tuple[str, int]:
    raw = False
    if text.startswith("r'", index):
        raw = True
        index += 1
    if index >= len(text) or text[index] != "'":
        raise ValueError(f"Expected Dart string at offset {index}")
    index += 1
    chars: list[str] = []
    while index < len(text):
        char = text[index]
        if char == "'":
            return "".join(chars), index + 1
        if char == "\\" and not raw:
            index += 1
            if index >= len(text):
                raise ValueError("Unterminated escape in Dart string")
            escaped = text[index]
            chars.append(
                {
                    "n": "\n",
                    "r": "\r",
                    "t": "\t",
                    "b": "\b",
                    "f": "\f",
                    "v": "\v",
                }.get(escaped, escaped)
            )
            index += 1
            continue
        chars.append(char)
        index += 1
    raise ValueError("Unterminated Dart string")


def _parse_map(source: str, marker: str) -> list[tuple[str, str]]:
    marker_index = source.index(marker)
    start = source.index("{", marker_index) + 1
    end = source.index("\n  };", start)
    body = source[start:end]
    pairs: list[tuple[str, str]] = []
    index = 0
    while True:
        index = _skip_space_and_comments(body, index)
        if index >= len(body):
            break

        key, index = _parse_dart_string(body, index)
        index = _skip_space_and_comments(body, index)
        if index >= len(body) or body[index] != ":":
            raise ValueError(f"Expected ':' after key {key!r}")
        index += 1
        index = _skip_space_and_comments(body, index)

        parts: list[str] = []
        while index < len(body) and (
            body[index] == "'" or body.startswith("r'", index)
        ):
            part, index = _parse_dart_string(body, index)
            parts.append(part)
            index = _skip_space_and_comments(body, index)
        if not parts:
            raise ValueError(f"Expected value for key {key!r}")

        if index >= len(body) or body[index] != ",":
            raise ValueError(f"Expected ',' after value for key {key!r}")
        index += 1
        pairs.append((key, "".join(parts)))

    if len({key for key, _ in pairs}) != len(pairs):
        raise ValueError(f"Duplicate source keys in map {marker}")
    return pairs


def _parse_output_map(source: str) -> list[tuple[str, str]]:
    marker_index = source.index(PORTUGUESE_MARKER)
    start = source.index("{", marker_index) + 1
    end = source.index("\n};", start)
    body = source[start:end]
    synthetic = f"{ENGLISH_MARKER} = <String, String>{{{body}\n  }};"
    return _parse_map(synthetic, ENGLISH_MARKER)


def _dart_quote(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("$", "\\$")
        .replace("\r", "\\r")
        .replace("\n", "\\n")
    )
    return f"'{escaped}'"


def _render(pairs: Iterable[tuple[str, str]]) -> str:
    lines = [
        FINAL_HEADER,
        "// Deterministic product source; machine regeneration is disabled.",
        "// Changes require reviewed patches and the complete localization audit.",
        f"{PORTUGUESE_MARKER} = <String, String>{{",
    ]
    for key, value in pairs:
        lines.append(f"  {_dart_quote(key)}: {_dart_quote(value)},")
    lines.extend(["};", ""])
    return "\n".join(lines)


def _verify_output() -> None:
    if not OUTPUT.exists():
        raise SystemExit(f"Missing reviewed localization: {OUTPUT.relative_to(ROOT)}")
    source = OUTPUT.read_text(encoding="utf-8")
    if not source.startswith(FINAL_HEADER):
        raise SystemExit("The committed pt-BR localization is missing its final review marker")
    pairs = _parse_output_map(source)
    if len(pairs) != 791:
        raise SystemExit(f"Expected 791 reviewed entries, found {len(pairs)}")
    if any(not key or not value for key, value in pairs):
        raise SystemExit("Reviewed pt-BR map contains an empty key or value")
    print("Verified 791 structurally valid reviewed pt-BR entries")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--verify-only", action="store_true")
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    if args.force:
        raise SystemExit(
            "Machine regeneration is disabled for the reviewed pt-BR product source"
        )
    _verify_output()


if __name__ == "__main__":
    main()
