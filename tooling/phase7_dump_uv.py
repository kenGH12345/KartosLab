# -*- coding: utf-8 -*-
import json
from pathlib import Path

d = json.loads(Path("tooling/phase7_scan_raw.json").read_text(encoding="utf-8"))
uv = [r for r in d["rows"] if r["classification"] == "USER_VISIBLE_ENGLISH"]
Path("tooling/phase7_uv.txt").write_text(
    "\n".join(f"{r['module']}|{r['file']}:{r['line']}|{r['string']}" for r in uv),
    encoding="utf-8",
)
print("uv", len(uv))
