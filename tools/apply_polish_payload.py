#!/usr/bin/env python3
"""Apply the reviewed Polish integration support payload."""
from __future__ import annotations

import base64
import io
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHUNK_DIR = ROOT / "tools" / "polish_payload"
payload = "".join(
    path.read_text(encoding="utf-8").strip()
    for path in sorted(CHUNK_DIR.glob("chunk_*.txt"))
)
raw = base64.b64decode(payload, validate=True)
with tarfile.open(fileobj=io.BytesIO(raw), mode="r:gz") as archive:
    for member in archive.getmembers():
        target = (ROOT / member.name).resolve()
        if ROOT.resolve() not in target.parents and target != ROOT.resolve():
            raise SystemExit(f"Unsafe payload path: {member.name}")
    archive.extractall(ROOT)
print("Applied reviewed Polish integration support payload.")
