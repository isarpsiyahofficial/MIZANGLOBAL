#!/usr/bin/env python3
"""Audit every non-catalogue user-facing language surface in one pass."""

from __future__ import annotations

import re
from pathlib import Path
import sys

from audit_cross_language_leaks import (
    LANGUAGE_ORDER,
    LETTER,
    L10N,
    RELATED_PROFILE_PAIRS,
    ROOT,
    SCRIPT_RANGES,
    branded,
    load_maps,
    parse_pairs,
    profile_findings,
    words,
)


def _outer_block(path: Path, marker: str) -> str:
    source = path.read_text(encoding="utf-8")
    marker_index = source.index(marker)
    opening = source.index("{", marker_index)
    closing = _matching(source, opening, "{", "}")
    return source[opening + 1 : closing]


def _matching(source: str, opening: int, left: str, right: str) -> int:
    depth = 0
    quote: str | None = None
    escaped = False
    for index in range(opening, len(source)):
        char = source[index]
        if quote is not None:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
            continue
        if char in ("'", '"'):
            quote = char
        elif char == left:
            depth += 1
        elif char == right:
            depth -= 1
            if depth == 0:
                return index
    raise ValueError(f"unterminated {left}{right} block")


def _top_level_blocks(source: str) -> dict[str, str]:
    blocks: dict[str, str] = {}
    index = 0
    depth = 0
    while index < len(source):
        char = source[index]
        if char == "'":
            end = index + 1
            escaped = False
            while end < len(source):
                current = source[end]
                if escaped:
                    escaped = False
                elif current == "\\":
                    escaped = True
                elif current == "'":
                    break
                end += 1
            if depth == 0:
                key = source[index + 1 : end]
                cursor = end + 1
                while cursor < len(source) and source[cursor].isspace():
                    cursor += 1
                if cursor < len(source) and source[cursor] == ":":
                    cursor += 1
                    while cursor < len(source) and source[cursor].isspace():
                        cursor += 1
                    if cursor < len(source) and source[cursor] == "{":
                        closing = _matching(source, cursor, "{", "}")
                        blocks[key] = source[cursor + 1 : closing]
                        index = closing + 1
                        continue
            index = end + 1
            continue
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
        index += 1
    return blocks


def _language_first(path: Path, marker: str) -> dict[str, dict[str, str]]:
    return {
        tag: parse_pairs(block)
        for tag, block in _top_level_blocks(_outer_block(path, marker)).items()
    }


def _key_first(path: Path, marker: str) -> dict[str, dict[str, str]]:
    result = {tag: {} for tag in LANGUAGE_ORDER}
    for key, block in _top_level_blocks(_outer_block(path, marker)).items():
        for tag, value in parse_pairs(block).items():
            if tag in result:
                result[tag][key] = value
    return result


def _language_lists(path: Path, marker: str) -> dict[str, dict[str, str]]:
    outer = _outer_block(path, marker)
    result: dict[str, dict[str, str]] = {}
    for tag in LANGUAGE_ORDER:
        match = re.search(rf"'{re.escape(tag)}'\s*:\s*\[", outer)
        if match is None:
            continue
        opening = outer.index("[", match.start())
        closing = _matching(outer, opening, "[", "]")
        values = re.findall(r"'((?:\\.|[^'\\])*)'", outer[opening + 1 : closing])
        result[tag] = {str(index): value for index, value in enumerate(values)}
    return result


def _surface_findings(
    name: str,
    surface: dict[str, dict[str, str]],
) -> list[str]:
    findings: list[str] = []
    expected_tags = set(LANGUAGE_ORDER)
    if set(surface) != expected_tags:
        findings.append(
            f"{name}: language mismatch; missing={sorted(expected_tags - set(surface))}"
        )
        return findings

    reference = set(surface["en"])
    for tag, catalogue in surface.items():
        if set(catalogue) != reference:
            findings.append(f"{name}/{tag}: key mismatch")
            continue
        for key, value in catalogue.items():
            clean = value.strip()
            if not clean:
                findings.append(f"{name}/{tag}/{key}: empty value")
                continue
            if tag not in ("tr", "en") and len(words(clean)) >= 3:
                if clean == surface["en"][key].strip():
                    findings.append(f"{name}/{tag}/{key}: English fallback")
                if clean == surface["tr"][key].strip():
                    findings.append(f"{name}/{tag}/{key}: Turkish fallback")

    for tag, script_range in SCRIPT_RANGES.items():
        script = re.compile(f"[{script_range}]")
        for key, value in surface[tag].items():
            if len(words(value)) < 4 or branded(value):
                continue
            scrubbed = re.sub(
                r"(?:LEFFERION|PRIME|M[İI]ZAN|PRO|Premium|CSV|PDF|Android|"
                r"Google Play|IBRAHIM|\d+)",
                "",
                value,
                flags=re.IGNORECASE,
            )
            letters = LETTER.findall(scrubbed)
            if letters and len(script.findall(scrubbed)) / len(letters) < 0.35:
                findings.append(f"{name}/{tag}/{key}: target-script ratio below 35%")

    for left_index, left in enumerate(LANGUAGE_ORDER[1:]):
        for right in LANGUAGE_ORDER[left_index + 2 :]:
            if frozenset((left, right)) in RELATED_PROFILE_PAIRS:
                continue
            right_values = {
                value.strip()
                for value in surface[right].values()
                if len(words(value)) >= 5 and not branded(value)
            }
            for key, value in surface[left].items():
                if len(words(value)) >= 5 and value.strip() in right_values:
                    findings.append(
                        f"{name}/{left}/{right}/{key}: identical long sentence"
                    )
    return findings


def main() -> int:
    monetization = ROOT / "lib" / "monetization" / "monetization_strings.dart"
    surfaces = {
        "legal-consent": _language_first(
            ROOT / "lib" / "legal" / "legal_consent_strings.dart", "_values"
        ),
        "monetization": _language_first(monetization, "_values"),
        "monetization-supplemental": _key_first(monetization, "_supplemental"),
        "offline-gate": _language_lists(
            ROOT / "lib" / "monetization" / "offline_gate_strings.dart",
            "_values",
        ),
    }

    findings: list[str] = []
    for name, surface in surfaces.items():
        findings.extend(_surface_findings(name, surface))

    combined = load_maps()
    for tag in LANGUAGE_ORDER:
        for name, surface in surfaces.items():
            combined[tag].update(
                {f"aux:{name}:{key}": value for key, value in surface[tag].items()}
            )
    findings.extend(
        finding for finding in profile_findings(combined) if "aux:" in finding
    )

    print(
        "auxiliary-surfaces="
        + ", ".join(
            f"{name}:{len(surface['en'])}x{len(surface)}"
            for name, surface in surfaces.items()
        )
    )
    if findings:
        print(f"auxiliary language audit failed with {len(findings)} finding(s):")
        for finding in findings:
            print(f"- {finding}")
        return 1
    print("auxiliary language audit passed for all 29 languages")
    return 0


if __name__ == "__main__":
    sys.exit(main())
