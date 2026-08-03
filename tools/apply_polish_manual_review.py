#!/usr/bin/env python3
"""Reconstruct and apply the deterministic native Polish review."""
from __future__ import annotations

import hashlib
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOLS = ROOT / "tools"
PARTS = TOOLS / "polish_finalizer_parts"
FINALIZER = TOOLS / "finalize_polish_copy.py"
BUILD = TOOLS / "build_polish_locale.py"
EXPECTED_SIZE = 19403
EXPECTED_SHA256 = "5be32768bc43b89b851d268dffcaeae396a33d6d230e0a2ad913833cf927432a"


def run(*args: str) -> None:
    subprocess.run(args, cwd=ROOT, check=True)


def main() -> None:
    files = sorted(PARTS.glob("part_*.txt"))
    if len(files) != 4:
        raise SystemExit(f"Expected 4 Polish review parts, found {len(files)}")
    payload = b"".join(path.read_bytes() for path in files)
    digest = hashlib.sha256(payload).hexdigest()
    if len(payload) != EXPECTED_SIZE or digest != EXPECTED_SHA256:
        raise SystemExit(
            "Polish review transport integrity failure: "
            f"size={len(payload)}, sha256={digest}"
        )
    FINALIZER.write_bytes(payload)

    build_source = BUILD.read_text(encoding="utf-8")
    old = 'for marker in ("Pozostał 1 dzień", "wpisów", "Wybrano 2 osoby"):'
    new = 'for marker in ("Pozostał 1 dzień", "wpisów", "_people(m[1]!)"):'
    if old in build_source:
        BUILD.write_text(build_source.replace(old, new, 1), encoding="utf-8")
    elif new not in build_source:
        raise SystemExit("Polish dynamic-grammar verification marker was not found")

    run(sys.executable, str(FINALIZER))
    run(sys.executable, str(BUILD))
    run(sys.executable, str(BUILD), "--verify")
    run(sys.executable, str(TOOLS / "audit_polish_native_copy.py"))
    print("Polish native review, runtime integration and catalogs verified.")


if __name__ == "__main__":
    main()
