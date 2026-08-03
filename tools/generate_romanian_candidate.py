#!/usr/bin/env python3
"""Generate a complete Romanian static-copy candidate from the reviewed English map.

Candidate output is never integrated automatically. Native review, terminology audit,
dynamic grammar review, full regression and release gates remain mandatory.
"""
from __future__ import annotations

import json
import re
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"
I18N = L10N / "mizan_i18n.dart"
SOURCE_DIR = L10N / "pl"
ROMANIAN_DIR = L10N / "ro"


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
    r"MİZAN(?: GLOBAL)?|LEFFERION PRIME|https?://\S+|\b(?:CSV|PDF|IBAN|ISO|Android|WhatsApp|TRY|RON|USD|EUR)\b|\$\{[^}]+\}|\$[A-Za-z_][A-Za-z0-9_]*|\{[^{}]+\}"
)


def protect(text: str) -> tuple[str, list[str]]:
    tokens: list[str] = []

    def repl(match: re.Match[str]) -> str:
        tokens.append(match.group(0))
        return f"KEEPX{len(tokens) - 1}X"

    return PROTECTED_RE.sub(repl, text), tokens


def restore(text: str, tokens: list[str]) -> str:
    for index, token in enumerate(tokens):
        for marker in (f"KEEPX{index}X", f"KEEPX {index} X", f"KEEPX{index} X"):
            text = text.replace(marker, token)
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
    "MİZAN Aylık Raporu": "Raport lunar MİZAN",
    "Aktif": "Activ",
    "Yaklaşıyor": "Scadență apropiată",
    "Gecikmede": "Restant",
    "Tamamlandı": "Finalizat",
    "Pasif": "Inactiv",
    "KMH hesabı": "Cont cu descoperit de cont",
    "Kredi kartı": "Card de credit",
    "Kredi": "Credit",
    "Araç kredisi": "Credit auto",
    "Ev kredisi": "Credit ipotecar",
    "Nakit avans": "Avans în numerar",
    "Taksitli nakit avans": "Avans în numerar în rate",
    "Özel borç türü": "Tip personalizat de datorie",
    "Son ödeme tarihi": "Data scadenței",
    "Her ayın belirli günü": "O anumită zi a fiecărei luni",
    "Taksit ödemesi": "Plata ratei",
    "Borç kapama": "Achitarea datoriei",
    "Kısmi ödeme": "Plată parțială",
    "Gelir": "Venit",
    "Gider": "Cheltuială",
    "Giderler": "Cheltuieli",
    "Raporlar": "Rapoarte",
    "Ayarlar": "Setări",
    "Ana sayfa": "Prezentare generală",
    "Kayıtlar": "Înregistrări",
    "Kaydet": "Salvează",
    "Vazgeç": "Anulează",
    "Sil": "Șterge",
    "Düzenle": "Editează",
    "Ekle": "Adaugă",
    "Kapat": "Închide",
    "Devam et": "Continuă",
    "Geri": "Înapoi",
    "Tamam": "Gata",
    "Onayla": "Confirmă",
    "ONAYLIYORUM": "CONFIRM",
    "Dil seç": "Selectează limba",
    "Ülke seç": "Selectează țara",
    "Para birimi seç": "Selectează moneda",
    "Uygulama dili": "Limba aplicației",
    "Ülke / borç bölgesi": "Țară / regiune a datoriei",
    "Varsayılan para birimi": "Monedă implicită",
    "Kurulumu tamamla": "Finalizează configurarea",
    "MİZAN GLOBAL": "MİZAN GLOBAL",
    "Fatura": "Factură",
    "Abonelik": "Abonament",
    "Kira": "Chirie",
    "Banka borcu": "Datorie bancară",
    "Şahıs borcu": "Datorie personală",
    "Ödeme": "Plată",
    "Ödemeler": "Plăți",
    "Bildirim": "Notificare",
    "Bildirimler": "Notificări",
    "Hatırlatma": "Memento",
    "Notlar": "Note",
    "Kategoriler": "Categorii",
    "Geçmiş": "Istoric",
    "Bugün": "Astăzi",
    "Aylık": "Lunar",
    "Yıllık": "Anual",
    "Haftalık": "Săptămânal",
    "Günlük": "Zilnic",
}


def normalize_candidate(key: str, value: str) -> str:
    value = value.strip()
    replacements = {
        "înregistrare de plată": "înregistrare de plată",
        "record": "înregistrare",
        "Record": "Înregistrare",
        "backup": "copie de siguranță",
        "Backup": "Copie de siguranță",
        "scadentă": "scadență",
        "Scadentă": "Scadență",
    }
    for old, new in replacements.items():
        value = value.replace(old, new)
    return KEY_OVERRIDES.get(key, value)


def translate_one(item: tuple[str, str]) -> tuple[str, str]:
    key, original = item
    protected_text, tokens = protect(original)
    query = urlencode({
        "client": "gtx",
        "sl": "en",
        "tl": "ro",
        "dt": "t",
        "q": protected_text,
    })
    url = f"https://translate.googleapis.com/translate_a/single?{query}"
    last_error: Exception | None = None
    for attempt in range(4):
        try:
            request = Request(
                url,
                headers={"User-Agent": "Mozilla/5.0 MIZAN-l10n/1.0"},
            )
            with urlopen(request, timeout=18) as response:
                payload = json.loads(response.read().decode("utf-8"))
            translated = "".join(
                str(part[0]) for part in payload[0] if part and part[0]
            )
            return key, normalize_candidate(key, restore(translated, tokens))
        except Exception as error:
            last_error = error
            time.sleep(0.8 * (attempt + 1))
    raise RuntimeError(f"Romanian translation failed for {key!r}: {last_error}")


def translate_items(items: list[tuple[str, str]]) -> list[tuple[str, str]]:
    results: dict[str, str] = {}
    with ThreadPoolExecutor(max_workers=12) as executor:
        futures = {executor.submit(translate_one, item): item[0] for item in items}
        for completed, future in enumerate(as_completed(futures), start=1):
            key, value = future.result()
            results[key] = value
            if completed % 50 == 0 or completed == len(items):
                print(
                    f"Romanian candidate progress: {completed}/{len(items)}",
                    flush=True,
                )
    return [(key, results[key]) for key, _ in items]


def source_parts() -> list[tuple[Path, str, list[str]]]:
    result: list[tuple[Path, str, list[str]]] = []
    for path in sorted(SOURCE_DIR.glob("mizan_pl_*.dart")):
        source = path.read_text(encoding="utf-8")
        marker_match = re.search(r"const Map<String, String> (mizanPolish\w+)", source)
        if marker_match is None:
            raise SystemExit(f"Map marker missing in {path}")
        keys = [key for key, _ in parse_map(source, marker_match.group(0))]
        suffix = path.name.removeprefix("mizan_pl_").removesuffix(".dart")
        map_name = "mizanRomanian" + suffix.title().replace("_", "")
        result.append((Path(f"mizan_ro_{suffix}.dart"), map_name, keys))
    return result


def write_part(path: Path, map_name: str, pairs: list[tuple[str, str]]) -> None:
    lines = [
        "// ROMANIAN LOCALIZATION CANDIDATE — MANUAL NATIVE REVIEW REQUIRED.",
        f"const Map<String, String> {map_name} = <String, String>{{",
    ]
    for key, value in pairs:
        lines.append(f"  {dart_quote(key)}: {dart_quote(value)},")
    lines.append("};")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_index(parts: list[tuple[Path, str, list[str]]]) -> None:
    imports = [f"import 'ro/{path.name}';" for path, _, _ in parts]
    spreads = [f"  ...{map_name}," for _, map_name, _ in parts]
    content = "\n".join([
        *imports,
        "",
        "// ROMANIAN LOCALIZATION CANDIDATE — 791/791 STATIC VALUES.",
        "// User-authored content is never translated.",
        "const Map<String, String> mizanRomanian = <String, String>{",
        *spreads,
        "};",
        "",
    ])
    (L10N / "mizan_ro.dart").write_text(content, encoding="utf-8")


def main() -> None:
    english = english_map()
    parts = source_parts()
    ROMANIAN_DIR.mkdir(parents=True, exist_ok=True)
    total = 0
    for output_name, map_name, keys in parts:
        source_items = [(key, english[key]) for key in keys]
        translated = translate_items(source_items)
        write_part(ROMANIAN_DIR / output_name, map_name, translated)
        total += len(translated)
    write_index(parts)
    if total != 791:
        raise SystemExit(f"Romanian candidate must contain 791 values, found {total}")
    print(f"Generated Romanian candidate: {total}/791 static values")


if __name__ == "__main__":
    main()
