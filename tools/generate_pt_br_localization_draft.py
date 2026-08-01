#!/usr/bin/env python3
"""Generate a reviewable Brazilian Portuguese localization draft.

The generated locale is intentionally NOT wired into runtime. Product enablement
must happen only after native-language review, dynamic grammar coverage, catalog
purity checks, Flutter tests, and release builds all pass.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "lib/l10n/mizan_es.dart"
OUTPUT = ROOT / "lib/l10n/mizan_pt_br.dart"
MODEL_NAME = "Helsinki-NLP/opus-mt-es-pt"
HEADER = "// GENERATED PT-BR REVIEW DRAFT — DO NOT ENABLE BEFORE NATIVE AUDIT."
SPANISH_MARKER = "const Map<String, String> mizanSpanish"
PORTUGUESE_MARKER = "const Map<String, String> mizanPortugueseBr"


def _skip_space_and_comments(text: str, index: int) -> int:
    while index < len(text):
        if text[index].isspace() or text[index] == ",":
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
    end = source.index("\n};", start)
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
        while index < len(body) and (body[index] == "'" or body.startswith("r'", index)):
            part, index = _parse_dart_string(body, index)
            parts.append(part)
            index = _skip_space_and_comments(body, index)
        if not parts:
            raise ValueError(f"Expected value for key {key!r}")
        pairs.append((key, "".join(parts)))
    if len({key for key, _ in pairs}) != len(pairs):
        raise ValueError(f"Duplicate source keys in map {marker}")
    return pairs


_PROTECTED = re.compile(
    r"MİZAN|Android|CSV|PDF|ISO|SHA-256|CONFIRMO|ONAYLIYORUM|I CONFIRM|"
    r"\b(?:TRY|USD|EUR|AED|GBP|JPY|CNY|KRW|BRL)\b|"
    r"__MIZAN_USER_\d+__|https?://\S+|\b\d+(?:[.,]\d+)?\b"
)


def _protect(value: str) -> tuple[str, list[str]]:
    kept: list[str] = []

    def replace(match: re.Match[str]) -> str:
        token = f"ZXKEEP{len(kept)}QZ"
        kept.append(match.group(0))
        return token

    return _PROTECTED.sub(replace, value), kept


def _restore(value: str, kept: list[str]) -> str:
    for index, original in enumerate(kept):
        value = value.replace(f"ZXKEEP{index}QZ", original)
    return value


def _brazilianize(value: str) -> str:
    replacements = {
        "ficheiro": "arquivo",
        "ficheiros": "arquivos",
        "ecrã": "tela",
        "ecrãs": "telas",
        "telemóvel": "celular",
        "telemóveis": "celulares",
        "utilizador": "usuário",
        "utilizadores": "usuários",
        "aplicação": "aplicativo",
        "aplicações": "aplicativos",
        "definições": "configurações",
        "factura": "fatura",
        "facturas": "faturas",
        "registo": "registro",
        "registos": "registros",
        "eliminar": "excluir",
        "Elimine": "Exclua",
        "Guardar": "Salvar",
        "guardar": "salvar",
    }
    for source, target in replacements.items():
        value = re.sub(rf"\b{re.escape(source)}\b", target, value)
    return value


def _translate(values: list[str], batch_size: int) -> list[str]:
    from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
    model = AutoModelForSeq2SeqLM.from_pretrained(MODEL_NAME)
    translated: list[str] = []
    for offset in range(0, len(values), batch_size):
        batch = values[offset : offset + batch_size]
        protected_batch: list[str] = []
        kept_batch: list[list[str]] = []
        for value in batch:
            protected, kept = _protect(value)
            protected_batch.append(protected)
            kept_batch.append(kept)
        encoded = tokenizer(
            protected_batch,
            return_tensors="pt",
            padding=True,
            truncation=True,
            max_length=512,
        )
        generated = model.generate(
            **encoded,
            max_length=640,
            num_beams=5,
            early_stopping=True,
        )
        decoded = tokenizer.batch_decode(generated, skip_special_tokens=True)
        for candidate, kept in zip(decoded, kept_batch, strict=True):
            translated.append(_brazilianize(_restore(candidate.strip(), kept)))
        print(f"Translated {min(offset + len(batch), len(values))}/{len(values)}")
    return translated


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
        HEADER,
        "// Generated from the verified Spanish key set using an offline model.",
        "// Every value still requires Brazilian Portuguese native review.",
        "typedef PortugueseBrTextTranslator = String Function(String source);",
        "",
        f"{PORTUGUESE_MARKER} = <String, String>{{",
    ]
    for key, value in pairs:
        lines.append(f"  {_dart_quote(key)}: {_dart_quote(value)},")
    lines.extend(
        [
            "};",
            "",
            "String translatePortugueseBrDynamic(",
            "  String source,",
            "  PortugueseBrTextTranslator translate,",
            ") {",
            "  // Dynamic grammar is added and audited before runtime enablement.",
            "  return source;",
            "}",
            "",
        ]
    )
    return "\n".join(lines)


def _verify_output() -> None:
    if not OUTPUT.exists():
        raise SystemExit(f"Missing generated draft: {OUTPUT.relative_to(ROOT)}")
    pairs = _parse_map(OUTPUT.read_text(encoding="utf-8"), PORTUGUESE_MARKER)
    if len(pairs) != 791:
        raise SystemExit(f"Expected 791 generated entries, found {len(pairs)}")
    if any(not key or not value for key, value in pairs):
        raise SystemExit("Generated pt-BR map contains an empty key or value")
    print("Verified 791 structurally valid pt-BR review entries")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--verify-only", action="store_true")
    parser.add_argument("--batch-size", type=int, default=12)
    args = parser.parse_args()

    if args.verify_only:
        _verify_output()
        return

    if OUTPUT.exists() and HEADER in OUTPUT.read_text(encoding="utf-8") and not args.force:
        print(f"Draft already exists: {OUTPUT.relative_to(ROOT)}")
        _verify_output()
        return

    pairs = _parse_map(SOURCE.read_text(encoding="utf-8"), SPANISH_MARKER)
    if len(pairs) != 791:
        raise SystemExit(f"Expected 791 Spanish keys, found {len(pairs)}")
    translated = _translate([value for _, value in pairs], args.batch_size)
    if len(translated) != len(pairs):
        raise SystemExit("Translation result count changed")
    rendered = _render(zip((key for key, _ in pairs), translated, strict=True))
    OUTPUT.write_text(rendered, encoding="utf-8")
    _verify_output()
    print(f"Generated {OUTPUT.relative_to(ROOT)} with {len(pairs)} review entries")


if __name__ == "__main__":
    main()
