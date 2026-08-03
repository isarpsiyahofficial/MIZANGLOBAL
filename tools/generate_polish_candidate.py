#!/usr/bin/env python3
"""Generate a complete Polish static-copy candidate from the reviewed English map.

This is only a candidate generator. Native-language audit and manual review remain
mandatory before the locale can be integrated into the product runtime.
"""
from __future__ import annotations

import re
import time
from pathlib import Path

from deep_translator import GoogleTranslator

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"
I18N = L10N / "mizan_i18n.dart"
DUTCH_DIR = L10N / "nl"
POLISH_DIR = L10N / "pl"


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
            raise ValueError("spread maps cannot be parsed")
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


def english_map() -> dict[str, str]:
    pairs = parse_map(
        I18N.read_text(encoding="utf-8"),
        "static const Map<String, String> _english",
    )
    if len(pairs) != 791:
        raise SystemExit(f"English reference must contain 791 values, found {len(pairs)}")
    return dict(pairs)


PROTECTED_RE = re.compile(
    r"MİZAN(?: GLOBAL)?|https?://\S+|\b[A-Z]{2,5}\b|\$\{[^}]+\}|\$[A-Za-z_][A-Za-z0-9_]*|\{[^{}]+\}"
)


def protect(text: str) -> tuple[str, list[str]]:
    tokens: list[str] = []

    def repl(match: re.Match[str]) -> str:
        tokens.append(match.group(0))
        return f"KEEPX{len(tokens) - 1}X"

    return PROTECTED_RE.sub(repl, text), tokens


def restore(text: str, tokens: list[str]) -> str:
    for index, token in enumerate(tokens):
        text = text.replace(f"KEEPX{index}X", token)
        text = text.replace(f"KEEPX {index} X", token)
    return text


def dart_quote(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("$", "\\$")
        .replace("\r", "\\r")
        .replace("\n", "\\n")
        .replace("\t", "\\t")
    )
    return f"'{escaped}'"


KEY_OVERRIDES = {
    "MİZAN Aylık Raporu": "Raport miesięczny MİZAN",
    "Aktif": "Aktywne",
    "Yaklaşıyor": "Zbliża się termin",
    "Gecikmede": "Po terminie",
    "Tamamlandı": "Zakończone",
    "Pasif": "Nieaktywne",
    "KMH hesabı": "Kredyt w rachunku bieżącym",
    "Kredi kartı": "Karta kredytowa",
    "Kredi": "Kredyt",
    "Araç kredisi": "Kredyt samochodowy",
    "Ev kredisi": "Kredyt hipoteczny",
    "Nakit avans": "Wypłata gotówki z karty",
    "Taksitli nakit avans": "Wypłata gotówki na raty",
    "Özel borç türü": "Własny rodzaj zadłużenia",
    "Son ödeme tarihi": "Termin płatności",
    "Her ayın belirli günü": "Stały dzień miesiąca",
    "Taksit ödemesi": "Płatność raty",
    "Borç kapama": "Spłata zadłużenia",
    "Kısmi ödeme": "Płatność częściowa",
    "Gelir": "Dochód",
    "Gider": "Wydatek",
    "Giderler": "Wydatki",
    "Raporlar": "Raporty",
    "Ayarlar": "Ustawienia",
    "Ana sayfa": "Pulpit",
    "Kayıtlar": "Rejestry",
    "Kaydet": "Zapisz",
    "Vazgeç": "Anuluj",
    "Sil": "Usuń",
    "Düzenle": "Edytuj",
    "Ekle": "Dodaj",
    "Kapat": "Zamknij",
    "Devam et": "Dalej",
    "Geri": "Wstecz",
    "Tamam": "Gotowe",
    "Onayla": "Potwierdź",
    "ONAYLIYORUM": "POTWIERDZAM",
    "Dil seç": "Wybierz język",
    "Ülke seç": "Wybierz kraj",
    "Para birimi seç": "Wybierz walutę",
    "Uygulama dili": "Język aplikacji",
    "Ülke / borç bölgesi": "Kraj / region zadłużenia",
    "Varsayılan para birimi": "Waluta domyślna",
    "Kurulumu tamamla": "Zakończ konfigurację",
    "MİZAN GLOBAL": "MİZAN GLOBAL",
}


def normalize_candidate(key: str, value: str) -> str:
    value = value.strip()
    replacements = {
        "rekord": "wpis",
        "Rekord": "Wpis",
        "powiadomienie o płatności": "przypomnienie o płatności",
        "Powiadomienie o płatności": "Przypomnienie o płatności",
    }
    for old, new in replacements.items():
        value = value.replace(old, new)
    return KEY_OVERRIDES.get(key, value)


def translate_batch(
    translator: GoogleTranslator,
    items: list[tuple[str, str]],
) -> list[tuple[str, str]]:
    protected = [protect(value) for _, value in items]
    texts = [value for value, _ in protected]
    translated: list[str]
    for attempt in range(4):
        try:
            result = translator.translate_batch(texts)
            translated = [str(value) for value in result]
            break
        except Exception:
            if attempt == 3:
                translated = []
                for text in texts:
                    for single_attempt in range(4):
                        try:
                            translated.append(str(translator.translate(text)))
                            break
                        except Exception:
                            if single_attempt == 3:
                                raise
                            time.sleep(1.5 * (single_attempt + 1))
                break
            time.sleep(2.0 * (attempt + 1))
    output: list[tuple[str, str]] = []
    for (key, _), candidate, (_, tokens) in zip(items, translated, protected, strict=True):
        output.append((key, normalize_candidate(key, restore(candidate, tokens))))
    return output


def source_parts() -> list[tuple[Path, str, list[str]]]:
    result: list[tuple[Path, str, list[str]]] = []
    for path in sorted(DUTCH_DIR.glob("mizan_nl_*.dart")):
        source = path.read_text(encoding="utf-8")
        marker_match = re.search(r"const Map<String, String> (mizanDutch\w+)", source)
        if marker_match is None:
            raise SystemExit(f"Map marker missing in {path}")
        keys = [key for key, _ in parse_map(source, marker_match.group(0))]
        suffix = path.name.removeprefix("mizan_nl_").removesuffix(".dart")
        map_name = "mizanPolish" + suffix.title().replace("_", "")
        result.append((Path(f"mizan_pl_{suffix}.dart"), map_name, keys))
    return result


def write_part(path: Path, map_name: str, pairs: list[tuple[str, str]]) -> None:
    lines = [
        "// POLISH LOCALIZATION CANDIDATE — MANUAL NATIVE REVIEW REQUIRED.",
        f"const Map<String, String> {map_name} = <String, String>{{",
    ]
    for key, value in pairs:
        lines.append(f"  {dart_quote(key)}: {dart_quote(value)},")
    lines.append("};")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_index(parts: list[tuple[Path, str, list[str]]]) -> None:
    imports = [f"import 'pl/{path.name}';" for path, _, _ in parts]
    spreads = [f"  ...{map_name}," for _, map_name, _ in parts]
    content = "\n".join(
        [
            *imports,
            "",
            "// POLISH LOCALIZATION CANDIDATE — 791/791 STATIC VALUES.",
            "// User-authored content is never translated.",
            "const Map<String, String> mizanPolish = <String, String>{",
            *spreads,
            "};",
            "",
        ]
    )
    (L10N / "mizan_pl.dart").write_text(content, encoding="utf-8")


def main() -> None:
    english = english_map()
    parts = source_parts()
    POLISH_DIR.mkdir(parents=True, exist_ok=True)
    translator = GoogleTranslator(source="en", target="pl")

    total = 0
    for output_name, map_name, keys in parts:
        source_items = [(key, english[key]) for key in keys]
        translated: list[tuple[str, str]] = []
        for start in range(0, len(source_items), 20):
            translated.extend(translate_batch(translator, source_items[start : start + 20]))
            time.sleep(0.15)
        write_part(POLISH_DIR / output_name, map_name, translated)
        total += len(translated)

    write_index(parts)
    if total != 791:
        raise SystemExit(f"Polish candidate must contain 791 values, found {total}")
    print(f"Generated Polish candidate: {total}/791 static values")


if __name__ == "__main__":
    main()
