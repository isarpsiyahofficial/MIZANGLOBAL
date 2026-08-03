#!/usr/bin/env python3
"""Independent native-language audit for all reviewed Italian product copy."""
from __future__ import annotations

import json
import re
from pathlib import Path

from build_italian_locale import ROOT, italian_pairs

CONTRACT = ROOT / "tools/italian_native_terms.json"
contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
pairs = italian_pairs()
values = dict(pairs)
failures: list[str] = []

if len(pairs) != 791:
    failures.append(f"Italian source must contain 791 values, found {len(pairs)}")
keys = [key for key, _ in pairs]
if len(keys) != len(set(keys)):
    failures.append("duplicate keys in Italian source")
empty = [key for key, value in pairs if not value.strip()]
if empty:
    failures.append(f"empty Italian values: {empty[:20]}")

for key, expected in contract["requiredTerms"].items():
    if values.get(key) != expected:
        failures.append(
            f"native terminology mismatch: {key!r} -> {values.get(key)!r}; expected {expected!r}"
        )

for language, tokens in contract["forbiddenLeakageTokens"].items():
    for key, value in pairs:
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
for key, value in pairs:
    if informal.search(value):
        failures.append(f"informal register in {key!r}: {value!r}")
    if straight_apostrophe.search(value):
        failures.append(f"straight apostrophe in {key!r}: {value!r}")
    if "  " in value:
        failures.append(f"double space in {key!r}: {value!r}")
    is_compact_control = len(key) <= 22 and not any(mark in key for mark in ".?!:…")
    if is_compact_control and len(value) > 50:
        failures.append(f"Italian control copy too long: {key!r} -> {value!r}")

for key, value in pairs:
    folded = value.casefold()
    for phrase in contract["forbiddenCalques"]:
        if phrase.casefold() in folded:
            failures.append(f"non-native Italian calque in {key!r}: {phrase!r}")

if failures:
    print("Native Italian full audit failed:")
    for failure in failures:
        print(f"- {failure}")
    raise SystemExit(1)

print(
    "Native Italian full audit passed: 791 values, terminology, formal register, "
    "typography, leakage and compact-control copy checked."
)
