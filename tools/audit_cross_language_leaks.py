#!/usr/bin/env python3
"""Audit all MIZAN UI catalogues for cross-language leakage.

This intentionally does not rely on a small forbidden-word list. It combines
catalogue/key integrity, source fallbacks, exact sentence collisions, Unicode
script consistency, and a leave-one-out character n-gram language profile.
Malay is evaluated after the same Indonesian-to-Malay conversion used at
runtime, so an unchanged Indonesian sentence fails the audit.
"""

from __future__ import annotations

import ast
from collections import Counter
import itertools
import math
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"

PAIR = re.compile(
    r"'((?:\\.|[^'\\])*)'\s*:\s*'((?:\\.|[^'\\])*)'", re.DOTALL
)
REPLACEMENT = re.compile(
    r"\('((?:\\.|[^'\\])*)',\s*'((?:\\.|[^'\\])*)'\)"
)
WORD = re.compile(r"\w+", re.UNICODE)
LETTER = re.compile(r"[^\W\d_]", re.UNICODE)

LANGUAGE_ORDER = (
    "tr",
    "en",
    "es",
    "pt-BR",
    "pt-PT",
    "fr",
    "de",
    "it",
    "nl",
    "pl",
    "ro",
    "el",
    "ru",
    "uk",
    "ar",
    "fa",
    "he",
    "hi",
    "bn",
    "ur",
    "id",
    "ms",
    "fil",
    "vi",
    "th",
    "sw",
    "zh",
    "ja",
    "ko",
)

DIRECT_MAPS = {
    "en": (
        L10N / "mizan_i18n_legacy.dart",
        "static const Map<String, String> _english",
    ),
    "es": (L10N / "mizan_es.dart", "mizanSpanish"),
    "pt-BR": (L10N / "mizan_pt_br.dart", "mizanPortugueseBr"),
    "pt-PT": (L10N / "mizan_pt_pt.dart", "mizanPortuguesePt"),
}

DIRECTORIES = {
    "fr": "fr",
    "de": "de",
    "it": "it",
    "nl": "nl",
    "pl": "pl",
    "ro": "ro",
    "el": "el",
    "ru": "ru",
    "uk": "uk",
    "ar": "ar",
    "fa": "fa",
    "he": "he",
    "hi": "hi",
    "bn": "bn",
    "ur": "ur",
    "id": "id",
    "fil": "fil",
    "vi": "vi",
    "th": "th",
    "sw": "sw",
    "zh": "zh",
    "ja": "ja",
    "ko": "ko",
}

SCRIPT_RANGES = {
    "el": r"\u0370-\u03ff\u1f00-\u1fff",
    "ru": r"\u0400-\u052f",
    "uk": r"\u0400-\u052f",
    "ar": r"\u0600-\u06ff\u0750-\u077f",
    "fa": r"\u0600-\u06ff\u0750-\u077f",
    "he": r"\u0590-\u05ff",
    "hi": r"\u0900-\u097f",
    "bn": r"\u0980-\u09ff",
    "ur": r"\u0600-\u06ff\u0750-\u077f",
    "th": r"\u0e00-\u0e7f",
    "zh": r"\u3400-\u4dbf\u4e00-\u9fff",
    "ja": r"\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff",
    "ko": r"\u1100-\u11ff\uac00-\ud7af",
}

LATIN_PROFILE_LANGUAGES = (
    "en",
    "es",
    "pt-BR",
    "pt-PT",
    "fr",
    "de",
    "it",
    "nl",
    "pl",
    "ro",
    "id",
    "ms",
    "fil",
    "vi",
    "sw",
)

SOURCE_EQUAL_ALLOWLIST = {
    "LEFFERION PRIME - MIZAN",
    "LEFFERION PRIME - MİZAN",
    "MİZAN GLOBAL",
    "MİZAN full backup",
}

RELATED_PROFILE_PAIRS = {
    frozenset(("pt-BR", "pt-PT")),
    frozenset(("id", "ms")),
}


def decode(value: str) -> str:
    try:
        return ast.literal_eval("'" + value + "'")
    except (SyntaxError, ValueError):
        return value.replace(r"\'", "'").replace(r"\n", "\n")


def map_block(path: Path, marker: str) -> str:
    source = path.read_text(encoding="utf-8")
    marker_index = source.index(marker)
    opening = source.index("{", marker_index)
    depth = 0
    quoted = False
    escaped = False
    for index in range(opening, len(source)):
        char = source[index]
        if quoted:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == "'":
                quoted = False
            continue
        if char == "'":
            quoted = True
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[opening + 1 : index]
    raise ValueError(f"unterminated map in {path}")


def parse_pairs(source: str) -> dict[str, str]:
    return {decode(key): decode(value) for key, value in PAIR.findall(source)}


def directory_map(tag: str) -> dict[str, str]:
    result: dict[str, str] = {}
    directory = L10N / DIRECTORIES[tag]
    for path in sorted(directory.glob("mizan_*.dart")):
        if path.name.endswith("_catalog.dart"):
            continue
        result.update(parse_pairs(path.read_text(encoding="utf-8")))
    return result


def replace_token(value: str, source: str, target: str) -> str:
    pattern = re.compile(
        rf"(?<![^\W_]){re.escape(source)}(?![^\W_])", re.UNICODE
    )
    return pattern.sub(target, value)


def malay_map(indonesian: dict[str, str]) -> dict[str, str]:
    source = (L10N / "mizan_ms.dart").read_text(encoding="utf-8")
    overrides_source = source.split("const _keyOverrides", 1)[1].split(
        "const _phraseReplacements", 1
    )[0]
    overrides = parse_pairs(overrides_source)
    replacements_source = source.split("const _phraseReplacements", 1)[1]
    replacements = [
        (decode(left), decode(right))
        for left, right in REPLACEMENT.findall(replacements_source)
    ]
    result: dict[str, str] = {}
    for key, value in indonesian.items():
        if key in overrides:
            result[key] = overrides[key]
            continue
        converted = value
        for left, right in replacements:
            converted = replace_token(converted, left, right)
        result[key] = converted
    return result


def load_maps() -> dict[str, dict[str, str]]:
    maps: dict[str, dict[str, str]] = {}
    for tag, (path, marker) in DIRECT_MAPS.items():
        maps[tag] = parse_pairs(map_block(path, marker))
    for tag in DIRECTORIES:
        maps[tag] = directory_map(tag)
    maps["ms"] = malay_map(maps["id"])
    maps["tr"] = {key: key for key in maps["id"]}
    return {tag: maps[tag] for tag in LANGUAGE_ORDER}


def words(value: str) -> list[str]:
    return WORD.findall(value)


def branded(value: str) -> bool:
    return value in SOURCE_EQUAL_ALLOWLIST or bool(
        re.fullmatch(r"(?:LEFFERION|PRIME|M[İI]ZAN|PRO|CSV|PDF|Android|"
                     r"WhatsApp|ISO|IBAN|URL|SHA-256|UTF-8|AES-256|GCM|"
                     r"Argon2id|RFC 4180|Google Play|Google Wallet|IBRAHIM|"
                     r"[\d\W_])+", value, re.IGNORECASE)
    )


def normalized(value: str) -> str:
    value = value.lower()
    value = re.sub(
        r"(?:lefferion|prime|m[İi]zan|pro|csv|pdf|android|whatsapp|iso|"
        r"iban|https?\S+)",
        " ",
        value,
    )
    return " " + re.sub(r"[^\wÀ-ž]+", " ", value, flags=re.UNICODE) + " "


def trigrams(value: str) -> list[str]:
    value = normalized(value)
    return [value[index : index + 3] for index in range(len(value) - 2)]


def profile_findings(maps: dict[str, dict[str, str]]) -> list[str]:
    models = {
        tag: Counter(
            gram for value in maps[tag].values() for gram in trigrams(value)
        )
        for tag in LATIN_PROFILE_LANGUAGES
    }
    vocabulary = set().union(*(set(model) for model in models.values()))
    vocabulary_size = len(vocabulary)
    totals = {tag: sum(model.values()) for tag, model in models.items()}

    def score(grams: list[str], tag: str, own_value: bool = False) -> float:
        removal = Counter(grams) if own_value else Counter()
        denominator = max(1, totals[tag] - sum(removal.values()))
        denominator += 0.1 * vocabulary_size
        total = 0.0
        for gram in grams:
            count = max(0, models[tag][gram] - removal[gram])
            total += math.log((count + 0.1) / denominator)
        return total / max(1, len(grams))

    findings: list[str] = []
    for tag in LATIN_PROFILE_LANGUAGES:
        for key, value in maps[tag].items():
            grams = trigrams(value)
            alphabetic_words = [
                word for word in words(normalized(value)) if any(char.isalpha() for char in word)
            ]
            if len(alphabetic_words) < 8 or not grams:
                continue
            own_score = score(grams, tag, own_value=True)
            foreign_score, foreign_tag = max(
                (score(grams, candidate), candidate)
                for candidate in LATIN_PROFILE_LANGUAGES
                if candidate != tag
            )
            if (
                foreign_score - own_score > 0.12
                and frozenset((tag, foreign_tag)) not in RELATED_PROFILE_PAIRS
            ):
                findings.append(
                    f"{tag}: language-profile points to {foreign_tag}: "
                    f"{key!r} => {value!r}"
                )
    return findings


def audit(maps: dict[str, dict[str, str]]) -> list[str]:
    findings: list[str] = []
    reference = set(maps["tr"])
    if len(LANGUAGE_ORDER) != 29 or set(maps) != set(LANGUAGE_ORDER):
        findings.append("runtime audit must contain exactly the authoritative 29 tags")
    if len(reference) != 791:
        findings.append(f"reference key count is {len(reference)}, expected 791")

    for tag, catalogue in maps.items():
        if set(catalogue) != reference:
            missing = sorted(reference - set(catalogue))[:5]
            extra = sorted(set(catalogue) - reference)[:5]
            findings.append(f"{tag}: key mismatch; missing={missing}, extra={extra}")
        empty = [key for key, value in catalogue.items() if not value.strip()]
        if empty:
            findings.append(f"{tag}: empty values: {empty[:5]}")
        if tag == "tr":
            continue
        for key, value in catalogue.items():
            if (
                value.strip() == key.strip()
                and key not in SOURCE_EQUAL_ALLOWLIST
                and len(words(key)) >= 3
            ):
                findings.append(f"{tag}: Turkish source fallback: {key!r}")

    for tag, script_range in SCRIPT_RANGES.items():
        script = re.compile(f"[{script_range}]")
        for key, value in maps[tag].items():
            if len(words(value)) < 4 or branded(value):
                continue
            scrubbed = re.sub(
                r"(?:LEFFERION|PRIME|M[İI]ZAN|PRO|CSV|PDF|Android|WhatsApp|"
                r"ISO|IBAN|URL|SHA-256|UTF-8|Google Play|Google Wallet|"
                r"IBRAHIM|AES-256|GCM|Argon2id|RFC 4180)",
                "",
                value,
                flags=re.IGNORECASE,
            )
            letters = LETTER.findall(scrubbed)
            if letters and len(script.findall(scrubbed)) / len(letters) < 0.35:
                findings.append(
                    f"{tag}: target-script ratio below 35%: {key!r} => {value!r}"
                )

    for left, right in itertools.combinations(LANGUAGE_ORDER[1:], 2):
        if frozenset((left, right)) == frozenset(("pt-BR", "pt-PT")):
            continue
        right_values = {value for value in maps[right].values() if len(words(value)) >= 5}
        for key, value in maps[left].items():
            if len(words(value)) < 5 or branded(value):
                continue
            if value in right_values:
                findings.append(
                    f"{left}/{right}: identical long sentence: {key!r} => {value!r}"
                )

    findings.extend(profile_findings(maps))
    return findings


def main() -> int:
    maps = load_maps()
    findings = audit(maps)
    print(
        "catalogues="
        + ", ".join(f"{tag}:{len(maps[tag])}" for tag in LANGUAGE_ORDER)
    )
    if findings:
        print(f"cross-language audit failed with {len(findings)} finding(s):")
        for finding in findings:
            print(f"- {finding}")
        return 1
    print("cross-language audit passed for all 29 languages")
    return 0


if __name__ == "__main__":
    sys.exit(main())
