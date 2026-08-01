#!/usr/bin/env python3
"""Apply reviewed Brazilian Portuguese values to the generated localization map."""
from __future__ import annotations

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


def main() -> None:
    source = OUTPUT.read_text(encoding="utf-8")
    pairs = _parse_output_map(source)
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

    OUTPUT.write_text(
        _render((key, values[key]) for key in ordered_keys),
        encoding="utf-8",
    )
    _verify_output()
    print(
        f"Applied {len(reviewed)} reviewed pt-BR values from "
        f"{len(patch_files)} patch files"
    )


if __name__ == "__main__":
    main()
