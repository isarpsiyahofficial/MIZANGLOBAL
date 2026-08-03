#!/usr/bin/env python3
"""Replace the stalled translator wrapper with bounded parallel HTTP calls."""
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'tools' / 'generate_romanian_candidate.py'
text = path.read_text(encoding='utf-8')
text = text.replace(
    "import re\nimport time\nfrom pathlib import Path\n\nfrom deep_translator import GoogleTranslator\n",
    "import json\nimport re\nimport time\nfrom concurrent.futures import ThreadPoolExecutor, as_completed\nfrom pathlib import Path\nfrom urllib.parse import urlencode\nfrom urllib.request import Request, urlopen\n",
)
start = text.index('def translate_batch(')
end = text.index('\n\ndef source_parts()', start)
replacement = '''def translate_one(item: tuple[str, str]) -> tuple[str, str]:
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
'''
text = text[:start] + replacement + text[end:]
text = text.replace('    translator = GoogleTranslator(source="en", target="ro")\n', '')
old = '''        translated: list[tuple[str, str]] = []
        for start in range(0, len(source_items), 18):
            translated.extend(translate_batch(translator, source_items[start:start + 18]))
            time.sleep(0.25)
'''
new = '''        translated = translate_items(source_items)
'''
if old not in text:
    raise SystemExit('candidate generation loop target not found')
text = text.replace(old, new, 1)
path.write_text(text, encoding='utf-8')
print('Romanian candidate generator patched with bounded parallel requests.')
