#!/usr/bin/env python3
"""Export localization catalog JSON mirrors from PHASE 1 Dart tables (manual sync)."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "resources" / "localization" / "zh_CN"
OUT.mkdir(parents=True, exist_ok=True)

# Mirrors of Dart tables — keep in sync when adding keys.
COMMON = {
    "common.resetAll": {"en": "Reset All", "zh": "全部重置", "domain": "common", "status": "approved"},
    "common.reset": {"en": "Reset", "zh": "重置", "domain": "common", "status": "approved"},
    "common.play": {"en": "Play", "zh": "播放", "domain": "common", "status": "approved"},
    "common.pause": {"en": "Pause", "zh": "暂停", "domain": "common", "status": "approved"},
    "common.step": {"en": "Step", "zh": "步进", "domain": "common", "status": "approved"},
    "common.stepForward": {"en": "Step Forward", "zh": "前进一帧", "domain": "common", "status": "approved"},
    "common.back": {"en": "Back", "zh": "返回", "domain": "common", "status": "approved"},
    "common.close": {"en": "Close", "zh": "关闭", "domain": "common", "status": "approved"},
    "common.ok": {"en": "OK", "zh": "确定", "domain": "common", "status": "approved"},
}

HOME = {
    "home.appTitle": {"en": "Kratos Lab", "zh": "Kratos 仿真实验室", "domain": "home", "status": "approved"},
    "home.search": {"en": "Search simulations", "zh": "搜索实验", "domain": "home", "status": "approved"},
    "category.physics": {"en": "Physics", "zh": "物理", "domain": "category", "status": "approved"},
    "category.chemistry": {"en": "Chemistry", "zh": "化学", "domain": "category", "status": "approved"},
}

PHYSICS = {
    "physics.gravity": {"en": "Gravity", "zh": "重力", "domain": "physics", "status": "approved"},
    "physics.mass": {"en": "Mass", "zh": "质量", "domain": "physics", "status": "approved"},
    "physics.weight": {"en": "Weight", "zh": "重量", "domain": "physics", "status": "approved"},
    "physics.density": {"en": "Density", "zh": "密度", "domain": "physics", "status": "approved"},
    "physics.pressure": {"en": "Pressure", "zh": "压强", "domain": "physics", "status": "approved"},
    "physics.volume": {"en": "Volume", "zh": "体积", "domain": "physics", "status": "approved"},
}

A11Y = {
    "accessibility.resetAll": {"en": "Reset All", "zh": "全部重置", "domain": "accessibility", "status": "approved"},
    "accessibility.increaseMass": {"en": "Increase Mass", "zh": "增加质量", "domain": "accessibility", "status": "approved"},
    "accessibility.decreaseMass": {"en": "Decrease Mass", "zh": "减小质量", "domain": "accessibility", "status": "approved"},
}

META = {
    "defaultLocale": "zh-CN",
    "supportedLocales": ["zh-CN", "en"],
    "phase": 1,
    "note": "JSON is human-readable catalog; runtime source of truth is lib/l10n/* Dart tables.",
}

MIGRATION = {
    "home": "LOCALIZED",
    "shared-chrome": "LOCALIZED",
    "l10n-architecture": "LOCALIZED",
    "buoyancy": "NOT_STARTED",
    "quantum-measurement": "NOT_STARTED",
    "forces": "PARTIAL",
}

for name, data in (
    ("common.json", COMMON),
    ("home.json", HOME),
    ("physics.json", PHYSICS),
    ("accessibility.json", A11Y),
):
    (OUT / name).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

(ROOT / "resources" / "localization" / "meta.json").write_text(
    json.dumps(META, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
(ROOT / "resources" / "localization" / "migration_status.json").write_text(
    json.dumps(MIGRATION, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
print("exported", OUT)
