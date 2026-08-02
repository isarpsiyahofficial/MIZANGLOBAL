#!/usr/bin/env python3
"""Apply and audit reviewed Brazilian Portuguese localization values."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

from generate_pt_br_localization_draft import (
    OUTPUT,
    _parse_output_map,
    _render,
    _verify_output,
)

ROOT = Path(__file__).resolve().parents[1]
PATCH_DIR = ROOT / "tools/pt_br_review"


def _load_review(
    pairs: list[tuple[str, str]],
) -> tuple[list[str], dict[str, str], set[str], list[Path]]:
    ordered_keys = [key for key, _ in pairs]
    values = dict(pairs)
    reviewed: set[str] = set()
    patch_files = sorted(PATCH_DIR.glob("*.json"))
    if not patch_files:
        raise SystemExit("No pt-BR review patch files found")

    for patch_file in patch_files:
        payload = json.loads(patch_file.read_text(encoding="utf-8"))
        if not isinstance(payload, dict):
            raise SystemExit(f"Patch must be a JSON object: {patch_file}")
        for key, value in payload.items():
            if key not in values:
                raise SystemExit(f"Unknown localization key in {patch_file}: {key}")
            if key in reviewed:
                raise SystemExit(f"Duplicate reviewed key across patches: {key}")
            if not isinstance(value, str) or not value.strip():
                raise SystemExit(f"Empty reviewed value in {patch_file}: {key}")
            values[key] = value
            reviewed.add(key)
    return ordered_keys, values, reviewed, patch_files


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--audit-only", action="store_true")
    parser.add_argument("--require-complete", action="store_true")
    args = parser.parse_args()

    source = OUTPUT.read_text(encoding="utf-8")
    pairs = _parse_output_map(source)
    ordered_keys, values, reviewed, patch_files = _load_review(pairs)
    missing = [key for key in ordered_keys if key not in reviewed]

    print(
        f"Reviewed pt-BR coverage: {len(reviewed)}/{len(ordered_keys)} "
        f"across {len(patch_files)} patch files"
    )
    if missing:
        print("Missing reviewed keys:")
        for key in missing:
            print(f"- {key}")
    else:
        print("Every static localization key has a reviewed pt-BR value.")

    if args.require_complete and missing:
        raise SystemExit(f"pt-BR native review is missing {len(missing)} keys")
    if args.audit_only:
        return

    OUTPUT.write_text(
        _render((key, values[key]) for key in ordered_keys),
        encoding="utf-8",
    )
    _verify_output()
    print(f"Applied {len(reviewed)} reviewed pt-BR values")


if __name__ == "__main__":
    main()
