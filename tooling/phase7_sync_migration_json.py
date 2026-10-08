# -*- coding: utf-8 -*-
"""Sync resources/localization/migration_status.json from Dart registry."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
dart = (ROOT / "lib/l10n/legacy/migration_status.dart").read_text(encoding="utf-8")
# Parse 'id': LocalizationMigrationStatus.xxx
pat = re.compile(
    r"'([^']+)':\s*LocalizationMigrationStatus\.(localized|verified|partial|notStarted)"
)
status_map = {
    "localized": "LOCALIZED",
    "verified": "VERIFIED",
    "partial": "PARTIAL",
    "notStarted": "NOT_STARTED",
}
out = {m.group(1): status_map[m.group(2)] for m in pat.finditer(dart)}
path = ROOT / "resources/localization/migration_status.json"
path.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"wrote {len(out)} modules → {path}")
