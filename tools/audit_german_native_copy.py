#!/usr/bin/env python3
"""Independent fail-closed native-language audit for German product copy."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "tools" / "german_native_terms.json"
PARTS = tuple(sorted((ROOT / "lib" / "l10n" / "de").glob("mizan_de_*.dart")))


def skip(source: str, index: int) -> int:
    while index < len(source):
        if source[index].isspace():
            index += 1
            continue
        if source.startswith("//", index):
            newline = source.find("\n", index)
            index = len(source) if newline < 0 else newline + 1
            continue
        if source.startswith("/*", index):
            end = source.find("*/", index + 2)
            if end < 0:
                raise ValueError("unterminated block comment")
            index = end + 2
            continue
        break
    return index


def dart_string(source: str, index: int) -> tuple[str, int]:
    raw = False
    if source.startswith("r'", index):
        raw = True
        index += 1
    if index >= len(source) or source[index] != "'":
        raise ValueError(f"expected Dart string at {index}")
    index += 1
    chars: list[str] = []
    while index < len(source):
        char = source[index]
        if char == "'":
            return "".join(chars), index + 1
        if char == "\\" and not raw:
            index += 1
            if index >= len(source):
                raise ValueError("unterminated escape")
            escaped = source[index]
            chars.append({"n": "\n", "r": "\r", "t": "\t"}.get(escaped, escaped))
            index += 1
            continue
        chars.append(char)
        index += 1
    raise ValueError("unterminated Dart string")


def parse_map(source: str, marker: str) -> list[tuple[str, str]]:
    marker_index = source.index(marker)
    start = source.index("{", marker_index) + 1
    end = source.find("\n};", start)
    if end < 0:
        end = source.find("\n  };", start)
    if end < 0:
        raise ValueError(f"map closing brace not found after {marker!r}")
    body = source[start:end]
    result: list[tuple[str, str]] = []
    index = 0
    while True:
        index = skip(body, index)
        if index >= len(body):
            break
        if body.startswith("...", index):
            raise ValueError("spread maps cannot be audited as source maps")
        key, index = dart_string(body, index)
        index = skip(body, index)
        if index >= len(body) or body[index] != ":":
            raise ValueError(f"expected ':' after {key!r}")
        index = skip(body, index + 1)
        parts: list[str] = []
        while index < len(body) and (body[index] == "'" or body.startswith("r'", index)):
            part, index = dart_string(body, index)
            parts.append(part)
            index = skip(body, index)
        if index >= len(body) or body[index] != ",":
            raise ValueError(f"expected ',' after {key!r}")
        result.append((key, "".join(parts)))
        index += 1
    return result


def german_pairs() -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    if not PARTS:
        raise SystemExit("No German localization source parts were found.")
    for path in PARTS:
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanGerman\w+)", source)
        if marker is None:
            raise SystemExit(f"German map marker missing: {path.relative_to(ROOT)}")
        result.extend(parse_map(source, marker.group(0)))
    return result


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    pairs = german_pairs()
    keys = [key for key, _ in pairs]
    values = dict(pairs)
    failures: list[str] = []

    if len(pairs) != 791:
        failures.append(f"German source must contain 791 values, found {len(pairs)}")
    duplicates = sorted({key for key in keys if keys.count(key) > 1})
    if duplicates:
        failures.append(f"Duplicate German keys: {duplicates[:20]}")
    empty = [key for key, value in pairs if not value.strip()]
    if empty:
        failures.append(f"Empty German values: {empty[:20]}")

    for key, expected in contract["requiredTerms"].items():
        if values.get(key) != expected:
            failures.append(
                f"Native German terminology mismatch: {key!r} -> {values.get(key)!r}; "
                f"expected {expected!r}"
            )

    for language, tokens in contract["forbiddenLeakageTokens"].items():
        escaped = sorted((re.escape(token) for token in tokens), key=len, reverse=True)
        pattern = re.compile(r"(?<![\wÄÖÜäöüß])(?:" + "|".join(escaped) + r")(?![\wÄÖÜäöüß])", re.IGNORECASE)
        for key, value in pairs:
            if pattern.search(value):
                failures.append(f"{language} leakage in {key!r}: {value!r}")

    informal = re.compile(
        r"(?<![\wÄÖÜäöüß])(?:du|dich|dir|dein|deine|deinen|deinem|deiner|euch)(?![\wÄÖÜäöüß])",
        re.IGNORECASE,
    )
    for key, value in pairs:
        if informal.search(value):
            failures.append(f"Informal German register in {key!r}: {value!r}")
        if "  " in value:
            failures.append(f"Double space in {key!r}: {value!r}")
        if "..." in value:
            failures.append(f"Use the ellipsis character instead of three dots in {key!r}: {value!r}")

    for key, value in pairs:
        is_control = len(key) <= 20 and not any(mark in key for mark in ".?!:…")
        if is_control and len(value) > 48:
            failures.append(
                f"German control copy is too long for narrow layouts: {key!r} -> {value!r}"
            )

    for key, value in pairs:
        folded = value.casefold()
        for phrase in contract["forbiddenCalques"]:
            if phrase.casefold() in folded:
                failures.append(f"Non-native German calque in {key!r}: {phrase!r}")

    if failures:
        print("Native German audit failed:")
        for failure in failures:
            print(f"- {failure}")
        raise SystemExit(1)

    print(
        "Native German audit passed: 791/791 coverage, terminology, formal register, "
        "leakage, typography, calques and compact-control copy checked."
    )


if __name__ == "__main__":
    main()
