#!/usr/bin/env python3
"""Verify and install the reviewed Romanian integration bundle parts."""
from __future__ import annotations

import base64
import hashlib
import io
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PART_DIR = ROOT / "tools" / "romanian_bundle"
PART_HASHES = (
    "12f27cf2729a118bca00da6979eb560c92de5cd969d5ed68f8a5a51b2961e71c",
    "1f764e84d90ab74f2ea80bf2693992f6aff7085306ba576d7de783ab693a8df9",
    "87bca7261aca12ce7c202611f71c1e1db053959fdaf71b6e33025b4084bed554",
    "53b3f7e478aa28fd20b0424631afe43b4efbdeaa62aea998aa6f9ac17051faf9",
    "e6a3151f5f7920825c033d5765f250830d667be09e4c314452a83dd5cf90424b",
)
BUNDLE_HASH = "2a71c0cc2fe21f11377e95fbbee53bf9a2fa38b66f9b396ff20101208370a17a"


def main() -> None:
    encoded_parts: list[str] = []
    for index, expected in enumerate(PART_HASHES):
        path = PART_DIR / f"part{index:02d}.b64"
        data = path.read_bytes()
        actual = hashlib.sha256(data).hexdigest()
        if actual != expected:
            raise SystemExit(
                f"Romanian bundle part {index:02d} digest mismatch: "
                f"expected={expected} actual={actual} bytes={len(data)}"
            )
        encoded_parts.append(data.decode("ascii"))
        print(f"Romanian bundle part {index:02d} verified: {actual}")

    raw = base64.b64decode("".join(encoded_parts), validate=True)
    actual_bundle = hashlib.sha256(raw).hexdigest()
    if actual_bundle != BUNDLE_HASH:
        raise SystemExit(
            f"Romanian integration bundle digest mismatch: "
            f"expected={BUNDLE_HASH} actual={actual_bundle}"
        )

    root = ROOT.resolve()
    with tarfile.open(fileobj=io.BytesIO(raw), mode="r:gz") as archive:
        for member in archive.getmembers():
            target = (ROOT / member.name).resolve()
            if target != root and root not in target.parents:
                raise SystemExit(f"Unsafe Romanian bundle path: {member.name}")
        archive.extractall(ROOT)
    print(f"Romanian integration bundle installed: sha256={actual_bundle}")


if __name__ == "__main__":
    main()
