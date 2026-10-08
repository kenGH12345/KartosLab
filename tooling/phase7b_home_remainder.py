# -*- coding: utf-8 -*-
"""Phase 7B — Home remainder vs migration_status."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
hd = (ROOT / "lib/screens/home_disciplines.dart").read_text(encoding="utf-8")
ids = re.findall(r"id:\s*'([^']+)'", hd)
ms = json.loads(
    (ROOT / "resources/localization/migration_status.json").read_text(encoding="utf-8")
)
st = (ROOT / "lib/l10n/namespaces/sim_titles_l10n.dart").read_text(encoding="utf-8")
alias = {"forces-and-motion-basics": "forces"}

# Known bag Chinese status probes
BAGS = {
    "curve-fitting": "lib/curve_fitting/curve_fitting_strings.dart",
    "plinko-probability": "lib/plinko_probability/plinko_strings.dart",
    "blackbody-spectrum": "lib/blackbody_spectrum/blackbody_spectrum_strings.dart",
    "energy-forms-and-changes": "lib/energy_forms_and_changes/efac_strings.dart",
    "circuit": None,
    "optics": None,
    "wave-interference": None,
    "concentration": None,
}


def title_zh(rid: str) -> str:
    m = re.search(rf"'{re.escape(rid)}':\s*\[\s*'([^']*)'", st)
    return m.group(1) if m else "?"


def bag_is_zh(path: str | None) -> str:
    if path is None:
        return "CHECK_INLINE"
    p = ROOT / path
    if not p.exists():
        return "NO_BAG"
    t = p.read_text(encoding="utf-8")
    # first title const
    m = re.search(r"static const String title\s*=\s*'([^']*)'", t)
    if not m:
        return "NO_TITLE"
    title = m.group(1)
    if re.search(r"[\u4e00-\u9fff]", title):
        return f"ZH:{title}"
    return f"EN:{title}"


rows = []
for i in ids:
    mapped = alias.get(i, i)
    status = ms.get(mapped) or ms.get(i)
    if status:
        action = "ALREADY LOCALIZED"
        zh = "Home title ZH via loc.sim; module LOCALIZED"
        if i != mapped:
            zh += f" (alias→{mapped})"
    else:
        bag = bag_is_zh(BAGS.get(i))
        if bag.startswith("EN:"):
            action = "MIGRATE"
            zh = f"Home title ZH; in-sim bag {bag}"
        elif bag.startswith("ZH:"):
            action = "ALREADY LOCALIZED"
            zh = f"bag {bag} but missing migration_status"
        else:
            action = "MIGRATE"
            zh = f"status unknown ({bag})"
    rows.append((i, mapped, zh, action))

out = ROOT / "tooling/phase7b_home_remainder_raw.txt"
out.write_text(
    "\n".join(f"{a}|{b}|{c}|{d}" for a, b, c, d in rows), encoding="utf-8"
)
print("home", len(ids))
print("remainder_migrate", [r[0] for r in rows if r[3] == "MIGRATE"])
print("already", sum(1 for r in rows if r[3] == "ALREADY LOCALIZED"))
