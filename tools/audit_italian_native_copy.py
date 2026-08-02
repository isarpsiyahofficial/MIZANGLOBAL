#!/usr/bin/env python3
"""Fail-closed native-language audit for the reviewed Italian product copy."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "tools/italian_native_terms.json"
ITALIAN_CORE = ROOT / "lib/l10n/it/mizan_it_core.dart"
GERMAN_CORE = ROOT / "lib/l10n/de/mizan_de_core.dart"


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


def parse_map(path: Path, marker: str) -> list[tuple[str, str]]:
    source = path.read_text(encoding="utf-8")
    marker_index = source.index(marker)
    start = source.index("{", marker_index) + 1
    end = source.find("\n};", start)
    if end < 0:
        raise ValueError(f"map closing brace not found in {path.relative_to(ROOT)}")
    body = source[start:end]
    result: list[tuple[str, str]] = []
    index = 0
    while True:
        index = skip(body, index)
        if index >= len(body):
            break
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


contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
italian = parse_map(ITALIAN_CORE, "const Map<String, String> mizanItalianCore")
german = parse_map(GERMAN_CORE, "const Map<String, String> mizanGermanCore")
values = dict(italian)
failures: list[str] = []

italian_keys = [key for key, _ in italian]
german_keys = [key for key, _ in german]
if len(italian_keys) != len(set(italian_keys)):
    failures.append("duplicate keys in Italian core source")
if set(italian_keys) != set(german_keys):
    missing = sorted(set(german_keys) - set(italian_keys))
    extra = sorted(set(italian_keys) - set(german_keys))
    failures.append(
        f"Italian/German core key mismatch; missing={missing[:20]}, extra={extra[:20]}"
    )
empty = [key for key, value in italian if not value.strip()]
if empty:
    failures.append(f"empty Italian values: {empty[:20]}")

required_terms: dict[str, str] = contract["requiredTerms"]
for key, expected in required_terms.items():
    if key in values and values[key] != expected:
        failures.append(
            f"native terminology mismatch: {key!r} -> {values[key]!r}; expected {expected!r}"
        )

for language, tokens in contract["forbiddenLeakageTokens"].items():
    for key, value in italian:
        folded = value.casefold()
        for token in tokens:
            pattern = re.compile(rf"(?<!\w){re.escape(token.casefold())}(?!\w)")
            if pattern.search(folded):
                failures.append(f"{language} leakage in {key!r}: {token!r}")

informal = re.compile(
    r"(?<!\w)(?:tu|ti|te|tuo|tua|tuoi|tue|clicca|tocca)(?!\w)",
    re.IGNORECASE,
)
straight_apostrophe = re.compile(r"[A-Za-zÀ-ÖØ-öø-ÿ]'[A-Za-zÀ-ÖØ-öø-ÿ]")
for key, value in italian:
    if informal.search(value):
        failures.append(f"informal register in {key!r}: {value!r}")
    if straight_apostrophe.search(value):
        failures.append(f"straight apostrophe in {key!r}: {value!r}")
    if "  " in value:
        failures.append(f"double space in {key!r}: {value!r}")
    is_compact_control = len(key) <= 22 and not any(mark in key for mark in ".?!:…")
    if is_compact_control and len(value) > 48:
        failures.append(f"Italian control copy too long: {key!r} -> {value!r}")

for key, value in italian:
    folded = value.casefold()
    for phrase in contract["forbiddenCalques"]:
        if phrase.casefold() in folded:
            failures.append(f"non-native Italian calque in {key!r}: {phrase!r}")

if failures:
    print("Native Italian core audit failed:")
    for failure in failures:
        print(f"- {failure}")
    raise SystemExit(1)

print(
    "Native Italian core audit passed: exact key parity, terminology, formal register, "
    "typography, leakage and compact-control copy checked."
)
