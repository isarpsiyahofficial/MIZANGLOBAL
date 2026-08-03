#!/usr/bin/env python3
"""Generate a fail-closed Greek review candidate from the 791 English source values.

The result is deliberately not connected to runtime. It is only an inspection
candidate and must be replaced by the locked native review before integration.
"""
from __future__ import annotations

import concurrent.futures
import hashlib
import json
import random
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
I18N = ROOT / "lib" / "l10n" / "mizan_i18n.dart"
ROMANIAN_DIR = ROOT / "lib" / "l10n" / "ro"
GREEK_DIR = ROOT / "lib" / "l10n" / "el"
GREEK_INDEX = ROOT / "lib" / "l10n" / "mizan_el.dart"
MANIFEST = ROOT / "tools" / "greek_candidate_manifest.json"
TARGET = "el"
ENDPOINT = "https://translate.googleapis.com/translate_a/single"
MAX_WORKERS = 5
ATTEMPTS = 6
TIMEOUT_SECONDS = 25

PROTECTED = re.compile(
    r"(?:LEFFERION PRIME|MİZAN|ISO 4217|Google Play|Android|PDF|CSV|Pro|"
    r"USD|EUR|TRY|GBP|CHF|JPY|CNY|RUB|PLN|RON|AED|SAR|KWD|QAR|BHD|OMR|"
    r"\b\d+(?:[.,]\d+)?\b|https?://\S+|[\w.+-]+@[\w.-]+\.[A-Za-z]{2,})"
)


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
            raise ValueError("spread maps cannot be parsed as source maps")
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


def english_pairs() -> list[tuple[str, str]]:
    return parse_map(
        I18N.read_text(encoding="utf-8"),
        "static const Map<String, String> _english",
    )


def part_key_groups() -> list[tuple[str, list[str]]]:
    groups: list[tuple[str, list[str]]] = []
    for path in sorted(ROMANIAN_DIR.glob("mizan_ro_*.dart")):
        source = path.read_text(encoding="utf-8")
        marker = re.search(r"const Map<String, String> (mizanRomanian\w+)", source)
        if marker is None:
            raise SystemExit(f"Romanian part marker missing: {path.relative_to(ROOT)}")
        keys = [key for key, _ in parse_map(source, marker.group(0))]
        suffix = path.stem.removeprefix("mizan_ro_")
        groups.append((suffix, keys))
    return groups


def protect(value: str) -> tuple[str, dict[str, str]]:
    replacements: dict[str, str] = {}

    def repl(match: re.Match[str]) -> str:
        token = f"ZXQ{len(replacements):03d}QXZ"
        replacements[token] = match.group(0)
        return token

    return PROTECTED.sub(repl, value), replacements


def restore(value: str, replacements: dict[str, str]) -> str:
    restored = value
    for token, original in replacements.items():
        restored = restored.replace(token, original)
        restored = restored.replace(token.lower(), original)
    missing = [token for token in replacements if token in restored or token.lower() in restored]
    if missing:
        raise ValueError(f"protected tokens not restored: {missing}")
    return restored


def translate_once(value: str) -> str:
    protected, replacements = protect(value)
    query = urllib.parse.urlencode(
        {
            "client": "gtx",
            "sl": "en",
            "tl": TARGET,
            "dt": "t",
            "q": protected,
        }
    )
    request = urllib.request.Request(
        f"{ENDPOINT}?{query}",
        headers={
            "User-Agent": "Mozilla/5.0 MIZAN-GLOBAL-Greek-Localization-Audit/1.0",
            "Accept": "application/json",
        },
    )
    with urllib.request.urlopen(request, timeout=TIMEOUT_SECONDS) as response:
        payload = json.loads(response.read().decode("utf-8"))
    segments = payload[0]
    translated = "".join(segment[0] for segment in segments if segment and segment[0])
    translated = restore(translated, replacements).strip()
    if not translated:
        raise ValueError("empty translation")
    return translated


def translate(value: str) -> str:
    last_error: Exception | None = None
    for attempt in range(1, ATTEMPTS + 1):
        try:
            return translate_once(value)
        except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, ValueError, json.JSONDecodeError) as exc:
            last_error = exc
            if attempt == ATTEMPTS:
                break
            delay = min(18.0, 1.4 ** attempt + random.random())
            time.sleep(delay)
    raise RuntimeError(f"translation failed after {ATTEMPTS} attempts: {value!r}: {last_error}")


def quote(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("$", "\\$")
        .replace("\r", "\\r")
        .replace("\n", "\\n")
        .replace("\t", "\\t")
    )
    return f"'{escaped}'"


def write_part(suffix: str, pairs: list[tuple[str, str]]) -> Path:
    class_suffix = "".join(piece.capitalize() for piece in suffix.split("_"))
    map_name = f"mizanGreek{class_suffix}"
    path = GREEK_DIR / f"mizan_el_{suffix}.dart"
    lines = [
        "// MACHINE-GENERATED GREEK REVIEW CANDIDATE — NOT RUNTIME-APPROVED.",
        f"const Map<String, String> {map_name} = <String, String>{{",
    ]
    for key, value in pairs:
        lines.append(f"  {quote(key)}: {quote(value)},")
    lines.extend(["};", ""])
    path.write_text("\n".join(lines), encoding="utf-8")
    return path


def write_index(part_paths: list[Path]) -> None:
    imports = [f"import 'el/{path.name}';" for path in part_paths]
    spread_names = []
    for path in part_paths:
        suffix = path.stem.removeprefix("mizan_el_")
        class_suffix = "".join(piece.capitalize() for piece in suffix.split("_"))
        spread_names.append(f"  ...mizanGreek{class_suffix},")
    GREEK_INDEX.write_text(
        "\n".join(
            [
                "// MACHINE-GENERATED GREEK REVIEW CANDIDATE — NOT RUNTIME-APPROVED.",
                *imports,
                "",
                "const Map<String, String> mizanGreek = <String, String>{",
                *spread_names,
                "};",
                "",
            ]
        ),
        encoding="utf-8",
    )


def main() -> None:
    pairs = english_pairs()
    if len(pairs) != 791 or len(dict(pairs)) != 791:
        raise SystemExit(f"English source coverage changed: {len(pairs)} values")
    english = dict(pairs)
    groups = part_key_groups()
    grouped_keys = [key for _, keys in groups for key in keys]
    if len(grouped_keys) != 791 or set(grouped_keys) != set(english):
        missing = sorted(set(english) - set(grouped_keys))
        extra = sorted(set(grouped_keys) - set(english))
        raise SystemExit(f"part-key coverage mismatch: missing={missing[:8]} extra={extra[:8]}")

    unique_values = sorted(set(english.values()))
    translations: dict[str, str] = {}
    failures: list[str] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_value = {executor.submit(translate, value): value for value in unique_values}
        completed = 0
        for future in concurrent.futures.as_completed(future_to_value):
            value = future_to_value[future]
            try:
                translations[value] = future.result()
            except Exception as exc:  # noqa: BLE001 - fail closed with exact source
                failures.append(f"{value!r}: {exc}")
            completed += 1
            if completed % 50 == 0 or completed == len(unique_values):
                print(f"Greek candidate progress: {completed}/{len(unique_values)} unique values")
    if failures:
        raise SystemExit("\n".join(failures))
    if len(translations) != len(unique_values):
        raise SystemExit("candidate translation coverage incomplete")

    GREEK_DIR.mkdir(parents=True, exist_ok=True)
    part_paths: list[Path] = []
    candidate: dict[str, str] = {}
    for suffix, keys in groups:
        part_pairs = [(key, translations[english[key]]) for key in keys]
        candidate.update(part_pairs)
        part_paths.append(write_part(suffix, part_pairs))
    write_index(part_paths)

    if len(candidate) != 791 or set(candidate) != set(english):
        raise SystemExit("written Greek candidate coverage mismatch")
    digest = hashlib.sha256(
        json.dumps(candidate, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    ).hexdigest()
    MANIFEST.write_text(
        json.dumps(
            {
                "status": "review-candidate-only",
                "sourceLanguage": "en",
                "targetLanguage": "el-GR",
                "count": len(candidate),
                "uniqueSourceValues": len(unique_values),
                "sha256": digest,
                "runtimeIntegrated": False,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"Greek candidate generated: {len(candidate)}/791 values; sha256={digest}")


if __name__ == "__main__":
    main()
