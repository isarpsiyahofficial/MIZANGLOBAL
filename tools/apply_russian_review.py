#!/usr/bin/env python3
"""Apply the locked native Russian review corrections to the 791-line candidate."""
from __future__ import annotations
import hashlib, json, re
from build_russian_locale import ROOT, english_pairs, parse_map

REVIEW = ROOT / 'tools/russian_review.json'
PARTS = tuple(sorted((ROOT / 'lib/l10n/ru').glob('mizan_ru_*.dart')))
INDEX = ROOT / 'lib/l10n/mizan_ru.dart'
LOCKED_CANDIDATE_SHA = '59a4a2482d376b5bd71e5fc513e9c86d55bfc4362593c3de540402e6418e9357'
LOCKED_FINAL_SHA = '946cb76773f5783296b3e7ab50b168f50a2001e106daf0a9a834a2b0f404283a'

def quote(value: str) -> str:
    value = (value.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
             .replace('\r', '\\r').replace('\n', '\\n').replace('\t', '\\t'))
    return f"'{value}'"

def main() -> None:
    payload = json.loads(REVIEW.read_text(encoding='utf-8'))
    corrections = payload.get('corrections', {})
    english = dict(english_pairs())
    candidate: dict[str, str] = {}
    parsed = []
    for path in PARTS:
        source = path.read_text(encoding='utf-8')
        match = re.search(r'const Map<String, String> (mizanRussian\w+)', source)
        if not match:
            raise SystemExit(f'Russian map marker missing: {path}')
        pairs = parse_map(source, match.group(0))
        parsed.append((path, match.group(1), pairs))
        candidate.update(pairs)
    digest = hashlib.sha256(
        json.dumps(candidate, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode()
    ).hexdigest()
    if digest not in {LOCKED_CANDIDATE_SHA, LOCKED_FINAL_SHA}:
        raise SystemExit(f'Locked Russian source SHA mismatch: {digest}')
    already_reviewed = digest == LOCKED_FINAL_SHA
    expected_count = int(payload.get('count', 0))
    expected_corrected = int(payload.get('corrected', -1))
    expected_accepted = int(payload.get('accepted', -1))
    if expected_count != 791 or len(candidate) != 791 or set(candidate) != set(english):
        raise SystemExit(f'Russian review coverage mismatch: candidate={len(candidate)}, expected={expected_count}')
    if len(corrections) != expected_corrected or expected_accepted != 791 - expected_corrected:
        raise SystemExit(
            f'Russian review decision-count mismatch: corrected={len(corrections)}/{expected_corrected}, '
            f'accepted={expected_accepted}'
        )
    if not set(corrections).issubset(english):
        raise SystemExit('Russian corrections contain unknown source keys')
    for key, value in corrections.items():
        if not isinstance(value, str) or not value.strip():
            raise SystemExit(f'Invalid Russian correction: {key!r}')
    total = 0
    for path, map_name, pairs in parsed:
        lines = [
            '// REVIEWED RUSSIAN LOCALIZATION — RUSSIA-ORIENTED NATIVE COPY.',
            f'const Map<String, String> {map_name} = <String, String>{{',
        ]
        for key, original in pairs:
            lines.append(f'  {quote(key)}: {quote(corrections.get(key, original))},')
        lines.extend(['};', ''])
        path.write_text('\n'.join(lines), encoding='utf-8')
        total += len(pairs)
    text = INDEX.read_text(encoding='utf-8')
    text = text.replace(
        '// MACHINE-GENERATED RUSSIAN REVIEW CANDIDATE — NOT RUNTIME-APPROVED.',
        '// REVIEWED RUSSIAN LOCALIZATION — 791/791 STATIC VALUES.',
    )
    INDEX.write_text(text, encoding='utf-8')
    final_values: dict[str, str] = {}
    for path in PARTS:
        source = path.read_text(encoding='utf-8')
        match = re.search(r'const Map<String, String> (mizanRussian\w+)', source)
        if not match:
            raise SystemExit(f'Russian map marker missing after review: {path}')
        final_values.update(parse_map(source, match.group(0)))
    final_digest = hashlib.sha256(
        json.dumps(final_values, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode()
    ).hexdigest()
    if final_digest != LOCKED_FINAL_SHA:
        raise SystemExit(f'Locked Russian final SHA mismatch after review: {final_digest}')
    action = 'Verified already-reviewed' if already_reviewed else 'Applied locked native'
    print(
        f'{action} Russian review: {total}/791 values; '
        f'{expected_corrected} corrected, {expected_accepted} accepted after manual inspection; '
        f'final sha256={final_digest}.'
    )

if __name__ == '__main__':
    main()
