#!/usr/bin/env python3
"""Apply the first fail-closed corrections to the Italian terminology contract."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "tools/italian_native_terms.json"

payload = json.loads(CONTRACT.read_text(encoding="utf-8"))
# "pagamento" is native and required Italian, so it cannot be treated as
# Portuguese leakage merely because both languages share the same spelling.
portuguese_tokens = payload["forbiddenLeakageTokens"]["Portuguese"]
if "pagamento" in portuguese_tokens:
    portuguese_tokens.remove("pagamento")
CONTRACT.write_text(
    json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)

print("Italian native terminology contract review round 1 applied.")
