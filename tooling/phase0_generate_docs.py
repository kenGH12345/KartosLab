#!/usr/bin/env python3
"""Generate PHASE 0 localization markdown docs from audit JSON."""
from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "requirements" / "localization"

raw = json.loads((OUT / "_phase0_raw.json").read_text(encoding="utf-8"))
summary = raw["summary"]
findings = raw["findings"]
modules = json.loads((OUT / "_phase0_modules.json").read_text(encoding="utf-8"))


def md_escape(s: str) -> str:
    return s.replace("|", "\\|").replace("\n", " ").replace("\r", "")


def camel(phrase: str) -> str:
    parts = re.findall(r"[A-Za-z0-9]+", phrase)
    if not parts:
        return "todo"
    return parts[0].lower() + "".join(p.capitalize() for p in parts[1:])


GLOSSARY = [
    ("resetAll", "Reset All", "全部重置", "global control", "统一；勿与「重置全部」混用"),
    ("reset", "Reset", "重置", "global control", ""),
    ("play", "Play", "播放", "time control", ""),
    ("pause", "Pause", "暂停", "time control", ""),
    ("normal", "Normal", "正常", "speed", "时间倍率"),
    ("slow", "Slow", "慢速", "speed", ""),
    ("fast", "Fast", "快速", "speed", ""),
    ("fastForward", "Fast Forward", "快进", "speed", ""),
    ("stopwatch", "Stopwatch", "秒表", "tool", ""),
    ("close", "Close", "关闭", "dialog", ""),
    ("ok", "OK", "确定", "dialog", ""),
    ("back", "Back", "返回", "navigation", ""),
    ("next", "Next", "下一步", "game/wizard", ""),
    ("tryAgain", "Try Again", "再试一次", "game", ""),
    ("showAnswer", "Show Answer", "显示答案", "game", ""),
    ("intro", "Intro", "介绍", "tab/screen", "全项目统一「介绍」"),
    ("lab", "Lab", "实验室", "tab/screen", ""),
    ("explore", "Explore", "探索", "tab/screen", ""),
    ("compare", "Compare", "比较", "tab/screen", ""),
    ("mystery", "Mystery", "神秘材料", "density", "Density 专用 tab"),
    ("game", "Game", "游戏", "tab/screen", ""),
    ("options", "Options", "选项", "panel", ""),
    ("values", "Values", "数值", "checkbox", ""),
    ("none", "None", "无", "slider extreme", ""),
    ("lots", "Lots", "很多", "slider extreme", ""),
    ("custom", "Custom", "自定义", "material/mode", ""),
    ("material", "Material", "材料", "density/buoyancy", ""),
    ("grid", "Grid", "网格", "view option", ""),
    ("path", "Path", "轨迹", "view option", ""),
    ("step", "Step", "步进", "time control", ""),
    ("ruler", "Ruler", "尺子", "toolbox", ""),
    ("measuringTape", "Measuring Tape", "卷尺", "toolbox", ""),
    ("graph", "Graph", "图像", "panel", ""),
    ("view", "View", "视图", "panel", ""),
    ("velocity", "Velocity", "速度", "physics", "矢量；与 speed 区分"),
    ("speed", "Speed", "速率", "physics", "标量；中学 UI 可标「速度」需统一决策"),
    ("acceleration", "Acceleration", "加速度", "physics", ""),
    ("force", "Force", "力", "physics", ""),
    ("netForce", "Net Force", "合力", "physics", ""),
    ("gravity", "Gravity", "重力", "physics control", "g；非「引力」除非万有引力语境"),
    ("gravityForce", "Gravity Force", "引力", "gravity-force-lab", "万有引力"),
    ("mass", "Mass", "质量", "physics", "勿与 weight 混译"),
    ("weight", "Weight", "重力", "physics", "受力语境；口语「重量」仅非科学标签"),
    ("density", "Density", "密度", "physics", ""),
    ("volume", "Volume", "体积", "physics", ""),
    ("pressure", "Pressure", "压强", "physics", "流体静力学用「压强」"),
    ("buoyancy", "Buoyancy", "浮力", "physics", ""),
    ("displacement", "Displacement", "位移", "kinematics", "浮力语境另用「排开体积」"),
    ("displacedVolume", "Displaced Volume", "排开体积", "buoyancy", ""),
    ("wavelength", "Wavelength", "波长", "waves", ""),
    ("frequency", "Frequency", "频率", "waves", ""),
    ("amplitude", "Amplitude", "振幅", "waves", ""),
    ("particle", "Particle", "粒子", "physics", ""),
    ("particles", "Particles", "粒子", "gas", ""),
    ("molecule", "Molecule", "分子", "chemistry", ""),
    ("atom", "Atom", "原子", "chemistry", ""),
    ("proton", "Proton", "质子", "chemistry", ""),
    ("neutron", "Neutron", "中子", "chemistry", ""),
    ("electron", "Electron", "电子", "chemistry", ""),
    ("electricField", "Electric Field", "电场", "physics", ""),
    ("voltage", "Voltage", "电压", "physics", ""),
    ("current", "Current", "电流", "physics", ""),
    ("resistance", "Resistance", "电阻", "physics", ""),
    ("energy", "Energy", "能量", "physics", ""),
    ("kineticEnergy", "Kinetic Energy", "动能", "physics", ""),
    ("potentialEnergy", "Potential Energy", "势能", "physics", ""),
    ("thermal", "Thermal", "热能", "efac", ""),
    ("mechanical", "Mechanical", "机械能", "efac", ""),
    ("electrical", "Electrical", "电能", "efac", ""),
    ("chemical", "Chemical", "化学能", "efac", ""),
    ("light", "Light", "光", "optics", "能量形式语境用「光能」"),
    ("friction", "Friction", "摩擦", "physics", "力语境「摩擦力」"),
    ("heat", "Heat", "加热", "control", ""),
    ("cool", "Cool", "冷却", "control", ""),
    ("centerOfMass", "Center of Mass", "质心", "physics", ""),
    ("intensity", "Intensity", "强度", "optics/waves", ""),
    ("symbol", "Symbol", "符号", "build-an-atom", ""),
    ("constantSize", "Constant Size", "恒定大小", "gravity force lab", ""),
    ("objectDensity", "Object Density", "物体密度", "buoyancy", ""),
    ("percentSubmerged", "% Submerged", "浸没百分比", "buoyancy", ""),
    ("water", "Water", "水", "material", ""),
    ("earth", "Earth", "地球", "astronomy", ""),
    ("jupiter", "Jupiter", "木星", "astronomy", ""),
    ("mars", "Mars", "火星", "astronomy", ""),
    ("cartesian", "Cartesian", "直角坐标", "vector", ""),
    ("polar", "Polar", "极坐标", "vector", ""),
    ("balanced", "Balanced", "已配平", "chemistry", ""),
    ("returnLid", "Return Lid", "放回盖子", "gas", ""),
    ("lightBulb", "Light Bulb", "灯泡", "circuit", ""),
    ("ph", "pH", "pH", "chemistry", "保留科学符号"),
    ("go", "Go!", "开始!", "forces", ""),
    ("return", "Return", "返回", "forces", ""),
    ("grab", "Grab", "抓取", "density a11y", ""),
    ("refresh", "Refresh", "刷新", "control", ""),
    ("configuration", "Configuration", "配置", "panel", ""),
    ("screenBrightness", "Screen Brightness", "屏幕亮度", "qwi", ""),
    ("sourceIntensity", "Source Intensity", "源强度", "qwi", ""),
    ("slitSeparation", "Slit Separation", "缝间距", "qwi", ""),
    ("barrierScreenDistance", "Barrier-Screen Distance", "障壁-屏距离", "qwi", ""),
    ("damping", "Damping", "阻尼", "woas", ""),
    ("tension", "Tension", "张力", "woas", ""),
    ("pulseWidth", "Pulse Width", "脉宽", "woas", ""),
    ("holdConstant", "Hold Constant", "保持恒定", "gas", ""),
    ("appliedForce", "Applied Force", "外力", "hookes-law", ""),
    ("diameter", "Diameter", "直径", "projectile", ""),
    ("dragCoefficient", "Drag Coefficient", "阻力系数", "projectile", ""),
    ("altitude", "Altitude", "海拔", "projectile", ""),
    ("bonding", "Bonding", "成键", "molecule-shapes", ""),
    ("lonePair", "Lone Pair", "孤对电子", "molecule-shapes", ""),
]

SIM_NAMES = [
    ("bending-light", "Bending Light", "光的折射"),
    ("wave-on-a-string", "Wave on a String", "绳波"),
    ("ohms-law", "Ohm's Law", "欧姆定律"),
    ("faradays-law", "Faraday's Law", "法拉第电磁感应定律"),
    ("under-pressure", "Under Pressure", "液体压强"),
    ("density", "Density", "密度"),
    ("buoyancy", "Buoyancy", "浮力"),
    ("collision-lab", "Collision Lab", "碰撞实验室"),
    ("vector-addition", "Vector Addition", "矢量加法"),
    ("projectile-motion", "Projectile Motion", "抛体运动"),
    ("pendulum-lab", "Pendulum Lab", "单摆实验室"),
    ("hookes-law", "Hooke's Law", "胡克定律"),
    ("friction", "Friction", "摩擦"),
    ("forces-and-motion-basics", "Forces and Motion: Basics", "力与运动"),
    ("gravity-force-lab", "Gravity Force Lab", "万有引力实验室"),
    ("gravity-force-lab-basics", "Gravity Force Lab: Basics", "万有引力实验室：基础"),
    ("gravity-and-orbits", "Gravity and Orbits", "引力与轨道"),
    ("keplers-laws", "Kepler's Laws", "开普勒定律"),
    ("my-solar-system", "My Solar System", "我的太阳系"),
    ("charges-and-fields", "Charges and Fields", "电荷与电场"),
    ("capacitor-lab-basics", "Capacitor Lab: Basics", "电容器实验室：基础"),
    ("cck-ac-virtual-lab", "Circuit Construction Kit: AC - Virtual Lab", "电路搭建工具包：交流虚拟实验室"),
    ("john-travoltage", "John Travoltage", "约翰·特拉伏特"),
    ("balloons-and-static-electricity", "Balloons and Static Electricity", "气球与静电"),
    ("resistance-in-a-wire", "Resistance in a Wire", "导线电阻"),
    ("waves-intro", "Waves Intro", "波导论"),
    ("normal-modes", "Normal Modes", "简正模式"),
    ("fourier-making-waves", "Fourier: Making Waves", "傅里叶：合成波"),
    ("energy-forms-and-changes", "Energy Forms and Changes", "能量形式与转化"),
    ("energy-skate-park", "Energy Skate Park", "能量滑板公园"),
    ("blackbody-spectrum", "Blackbody Spectrum", "黑体辐射光谱"),
    ("gases-intro", "Gases Intro", "气体导论"),
    ("gas-properties", "Gas Properties", "气体性质"),
    ("diffusion", "Diffusion", "扩散"),
    ("membrane-transport", "Membrane Transport", "膜转运"),
    ("masses-and-springs-basics", "Masses and Springs: Basics", "质量与弹簧：基础"),
    ("curve-fitting", "Curve Fitting", "曲线拟合"),
    ("plinko-probability", "Plinko Probability", "弹珠概率"),
    ("balancing-act", "Balancing Act", "平衡木"),
    ("rutherford-scattering", "Rutherford Scattering", "卢瑟福散射"),
    ("molecule-polarity", "Molecule Polarity", "分子极性"),
    ("molecule-shapes", "Molecule Shapes", "分子形状"),
    ("molecules-and-light", "Molecules and Light", "分子与光"),
    ("build-a-molecule", "Build a Molecule", "搭建分子"),
    ("build-an-atom", "Build an Atom", "构建原子"),
    ("build-a-nucleus", "Build a Nucleus", "构建原子核"),
    ("isotopes-and-atomic-mass", "Isotopes and Atomic Mass", "同位素与原子质量"),
    ("acid-base-solutions", "Acid-Base Solutions", "酸碱溶液"),
    ("ph-scale", "pH Scale", "pH 标度"),
    ("molarity", "Molarity", "摩尔浓度"),
    ("beers-law-lab", "Beer's Law Lab", "比尔定律实验室"),
    ("concentration", "Concentration", "浓度"),
    ("balancing-chemical-equations", "Balancing Chemical Equations", "化学方程式配平"),
    ("reactants-products-and-leftovers", "Reactants, Products and Leftovers", "反应物、生成物与剩余物"),
    ("states-of-matter", "States of Matter", "物质的状态"),
    ("color-vision", "Color Vision", "色觉"),
    ("quantum-measurement", "Quantum Measurement", "量子测量"),
    ("quantum-coin-toss", "Quantum Coin Toss", "量子抛硬币"),
    ("quantum-wave-interference", "Quantum Wave Interference", "量子波干涉"),
    ("sound", "Sound", "声波"),
    ("radio-waves", "Radio Waves", "无线电波"),
    ("wave-interference", "Wave Interference", "波的干涉"),
]

DRAFT_ZH = {e: zh for _, e, zh, *_ in GLOSSARY}
DRAFT_KEY = {e: k for k, e, *_ in GLOSSARY}


def write_inventory() -> None:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    home = summary["home"]
    lines: list[str] = []
    a = lines.append

    a("# LOCALIZATION_INVENTORY")
    a("")
    a(f"> PHASE 0 — Global Localization Audit · {now}")
    a(">")
    a("> **本阶段只扫描与盘点，未修改任何 Simulation Model / Physics / Renderer。**")
    a("> 扫描根目录：`lib/`。原始 PhET source（`phet/`、archaeology 树）**不翻译、不修改**。")
    a("")
    a("## 0. Executive Summary")
    a("")
    a("| Metric | Count |")
    a("|---|---:|")
    a(f"| Dart files scanned | {summary['files_scanned']} |")
    a(f"| User-visible string hits | {summary['total_string_hits']} |")
    a(f"| English | {summary['english_count']} |")
    a(f"| Chinese | {summary['chinese_count']} |")
    a(f"| Mixed-language | {summary['mixed_count']} |")
    a(f"| Accessibility-related | {summary['a11y_count']} |")
    a(f"| Scientific symbols / units | {summary['by_classification'].get('scientific_symbol', 0)} |")
    a(f"| Technical identifiers | {summary['by_classification'].get('technical', 0)} |")
    a(f"| Other / unclassified | {summary['by_classification'].get('other', 0)} |")
    a(f"| Existing `*strings*.dart` files | {len(summary['existing_strings_files'])} |")
    a(f"| `lib/l10n/` present | {'YES' if summary['has_lib_l10n'] else '**NO**'} |")
    a(
        f"| `.arb` / `flutter_localizations` | "
        f"{'YES' if summary['has_flutter_localizations_in_pubspec'] else '**NO**'} |"
    )
    a("")
    a("### Verdict (PHASE 0)")
    a("")
    a("- 用户可见文本 **以英文为主**（约 57% English hits），中文约 33%，混合约 3%。")
    a("- **不存在** 统一 Localization 层；仅有分散 `*Strings` 袋。")
    a("- Home 分类中文，但 Simulation 显示名大量仍为英文 → **混合语言入口**。")
    a("- Accessibility 字符串稀少且多为英文（如 `gfl_a11y_strings.dart`）。")
    a("- 字体：`main.dart` 有中文 fallback；大量 sim 硬编码 `Arial` → 需 Font substitution 审计（PHASE 后续）。")
    a("")
    a("## 1. Classification Totals")
    a("")
    a("| Classification | Count | Notes |")
    a("|---|---:|---|")
    notes = {
        "english": "需本地化",
        "chinese": "已中文（多为硬编码，未进统一 API）",
        "mixed": "中英混排 — 需清理",
        "scientific_symbol": "可保留单位/符号",
        "technical": "identifier / path 类",
        "other": "待人工复核",
        "brand": "品牌",
        "empty": "空",
    }
    for k, v in sorted(summary["by_classification"].items(), key=lambda x: -x[1]):
        a(f"| {k} | {v} | {notes.get(k, '')} |")
    a("")
    a("### Kind breakdown")
    a("")
    a("| Kind | Count |")
    a("|---|---:|")
    for k, v in sorted(summary["by_kind"].items(), key=lambda x: -x[1]):
        a(f"| `{k}` | {v} |")
    a("")
    a("## 2. Existing Localization Infrastructure")
    a("")
    a("| Item | Status |")
    a("|---|---|")
    a("| `lib/l10n/` / `KartosLocalization` | **Absent** |")
    a("| `.arb` / `gen_l10n` | **Absent** |")
    a("| `flutter_localizations` | **Absent** |")
    a("| Per-sim `*Strings` classes | **32 files** — de-facto bags, mostly English |")
    a("| Chinese hardcoding precedent | `ForcesStrings`, some Home/chem titles, `EspStrings.title` |")
    a("| Home categories | Mostly Chinese |")
    a("| Home sim titles | **Mixed** CN / EN / bilingual |")
    a("| A11y string bags | Sparse; Gravity Force Lab a11y still English |")
    a("| PhET original source | Out of scope (archaeology evidence) |")
    a("")
    a("### Existing `*strings*.dart` files")
    a("")
    for p in summary["existing_strings_files"]:
        a(f"- `{p}`")
    a("")
    a("## 3. Home vs Simulation")
    a("")
    a("| Scope | Hits | English | Chinese | Mixed |")
    a("|---|---:|---:|---:|---:|")
    a(
        f"| Home (`lib/screens/home_screen.dart`) | {home['home_hits']} | "
        f"{home['home_english']} | {home['home_chinese']} | {home['home_mixed']} |"
    )
    a(
        f"| All `lib/` | {summary['total_string_hits']} | {summary['english_count']} | "
        f"{summary['chinese_count']} | {summary['mixed_count']} |"
    )
    a("")
    a("**Home 观察：**")
    a("")
    a("- 学科/分组名基本中文；`englishName: Physics/Chemistry` 仍暴露英文。")
    a("- 卡片 title 大量引用各模块英文 `static const title`（`Bending Light`、`Pendulum Lab` 等）。")
    a("- 部分已中文（力与运动、密度、电路搭建、摩尔浓度、构建原子、浮力…）→ **入口混排**。")
    a("- 多处 subtitle 故意中英混排（`Single Bulb · RGB Bulbs`、`Model / To Scale`、`Intro / Laws`）。")
    a("")
    a("## 4. Top 20 Highest-Impact Files")
    a("")
    a("按 English + Mixed 命中数（优先迁移）：")
    a("")
    a("| Rank | File | EN+Mixed |")
    a("|---:|---|---:|")
    for i, (f, c) in enumerate(summary["top20_impact_files"], 1):
        a(f"| {i} | `{f}` | {c} |")
    a("")
    a("## 5. Per-Module Breakdown")
    a("")
    a("| Module | Total | English | Chinese | Mixed | A11y | Files |")
    a("|---|---:|---:|---:|---:|---:|---:|")
    for x in sorted(modules, key=lambda z: -(z["english"] + z["mixed"])):
        if x["total"] == 0:
            continue
        a(
            f"| `{x['module']}` | {x['total']} | {x['english']} | {x['chinese']} | "
            f"{x['mixed']} | {x['a11y']} | {x['files']} |"
        )
    a("")
    a("## 6. High-Frequency English Phrases")
    a("")
    a("| English Text | Occurrences | Suggested Key | Chinese (draft) | Status |")
    a("|---|---:|---|---|---|")
    for phrase, count in summary["top_english_phrases"][:50]:
        key = DRAFT_KEY.get(phrase, camel(phrase))
        zh = DRAFT_ZH.get(phrase, "（待定 · 见 glossary 扩展）")
        a(f"| {md_escape(phrase)} | {count} | `{key}` | {zh} | ENGLISH |")
    a("")
    a("## 7. Mixed-Language Samples")
    a("")
    a("| Text | Occurrences | Status |")
    a("|---|---:|---|")
    for phrase, count in summary["top_mixed_phrases"][:30]:
        a(f"| {md_escape(phrase)} | {count} | MIXED — needs cleanup |")
    a("")
    a("## 8. Inventory Sample Rows (EN/MIXED, first 200)")
    a("")
    a("| File | Location | English Text | User Visible | Context | Localization Key | Chinese | Status |")
    a("|---|---|---|---|---|---|---|---|")
    rows = [f for f in findings if f["classification"] in {"english", "mixed"}]
    rows = sorted(rows, key=lambda f: (f["file"], f["line"]))[:200]
    for f in rows:
        text = f["english_or_text"]
        key = DRAFT_KEY.get(text, camel(text) if len(text) < 40 else "todo")
        zh = DRAFT_ZH.get(text, "")
        ctx = "a11y" if f["is_a11y"] else ("strings" if f["is_strings_file"] else f["kind"])
        a(
            f"| `{f['file']}` | L{f['line']} | {md_escape(text)[:80]} | YES | {ctx} | "
            f"`{key}` | {zh or '（待定）'} | {f['classification'].upper()} |"
        )
    a("")
    a("完整机器可读清单：`requirements/localization/_phase0_raw.json`")
    a("")
    a("## 9. Recommended Implementation Batches")
    a("")
    a("见本文件末尾与 PHASE 0 总结。原则：**基础设施 → Home → Simulation 批次**，禁止一轮爆改 200+ 文件。")
    a("")
    a("### Batch 0 — Global infrastructure（不改 physics）")
    a("")
    a("1. 新建 `lib/l10n/` + `KartosLocalization` 接口（或等价）")
    a("2. 落地 glossary keys → zh_CN（后续可加 en）")
    a("3. 建立 `allowedEnglishTerms` whitelist + `test/localization/` 扫描规则（EN 未豁免 = FAIL）")
    a("4. 文档：`LOCALIZATION_ARCHITECTURE.md`（PHASE 1）")
    a("")
    a("### Batch 1 — Home + shared chrome")
    a("")
    a("- `lib/screens/home_screen.dart` 全中文 displayName")
    a("- 统一 sim `title`/`subtitle` 显示层（保留 registry id 英文）")
    a("- L0：`KratosResetAllButton` tooltip、`time_control_bar`、公共 dialog")
    a("- Golden：Home 中文真值目录 `goldens_zh/`；英文基线归档 `golden_baseline_english/`")
    a("")
    a("### Batch 2 — High-impact string bags（Top files）")
    a("")
    a("- `som_strings`, `keplers_laws_strings`, `pm_strings`, `gfl_a11y_strings`, `pl_strings`")
    a("- `gao_strings`, `cck_strings`, `my_solar_system_strings`, `ba_strings`, `collision_lab_strings`")
    a("- `quantum_measurement_strings`, `mp_strings`, `density_strings`, `efac_strings`, `rs_strings`")
    a("")
    a("### Batch 3 — Mechanics / Gravity / Vectors")
    a("")
    a("- forces（补齐残留英文 Go!/Return）、collision-lab、vector-addition、projectile、pendulum")
    a("- gravity-force-lab / basics、hookes-law、masses-and-springs、balancing-act、friction")
    a("")
    a("### Batch 4 — Fluids / Density / Buoyancy / Gas")
    a("")
    a("- density、buoyancy、under-pressure、gases-intro、gas-properties、diffusion、membrane-transport")
    a("")
    a("### Batch 5 — Circuits / EM / Electrostatics")
    a("")
    a("- ohms-law、resistance-in-a-wire、cck-ac、capacitor、charges-and-fields、faradays-law")
    a("- john-travoltage、balloons、magnet-and-compass")
    a("")
    a("### Batch 6 — Waves / Optics / Quantum")
    a("")
    a("- bending-light、wave-on-a-string、waves-intro、normal-modes、fourier、color-vision")
    a("- quantum-measurement、quantum-wave-interference、quantum-coin-toss、sound、radio-waves")
    a("")
    a("### Batch 7 — Chemistry")
    a("")
    a("- molarity、ph-scale、acid-base、build-an-atom/nucleus/molecule、isotopes")
    a("- molecule-polarity/shapes、molecules-and-light、states-of-matter、BCE、RPAL、beers/concentration")
    a("")
    a("### Batch 8 — Layout / Golden / Regression / Android")
    a("")
    a("- 中文诱发 overflow / clipping / tab 碰撞修复（LayoutSpec，禁止 page magic Positioned）")
    a("- `goldens_zh/` + 行为回归全跑；READY 状态按 sim 重验")
    a("")
    a("## 10. Hard-coded vs Strings-bag")
    a("")
    strings_hits = sum(1 for f in findings if f["is_strings_file"])
    hard = summary["total_string_hits"] - strings_hits
    a(f"- Hits inside `*strings*.dart`: **{strings_hits}**")
    a(f"- Hits outside strings bags (hard-coded UI / titles / tooltips…): **{hard}**")
    a("- 迁移时应：Widget 改消费 `loc.*`；禁止继续扩散「Widget 内直接中文硬编码」。")
    a("")
    a("## 11. Font Audit (preview)")
    a("")
    a("| Finding | Detail |")
    a("|---|---|")
    a("| App fallback | `main.dart` → Microsoft YaHei / PingFang SC / Noto Sans CJK SC / Arial |")
    a("| Bundled fonts in pubspec | **None**（fonts 段注释掉） |")
    a("| Sim hardcode | 大量 `fontFamily: 'Arial'`（QWI、Ohm、Molecule Polarity、Quantum Measurement…） |")
    a("| Risk | Arial 无中文 glyph → 依赖系统 fallback；baseline/字重可能偏移 → Layout Review 必需 |")
    a("| PHASE 0 action | 仅记录；不改字体实现 |")
    a("")
    a("---")
    a("")
    a("**PHASE 0 Status: AUDIT COMPLETE — NOT READY for user-facing Chinese release**")
    a("")

    (OUT / "LOCALIZATION_INVENTORY.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_glossary() -> None:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    lines: list[str] = []
    a = lines.append
    a("# LOCALIZATION_GLOSSARY")
    a("")
    a(f"> PHASE 0 draft · {now}")
    a(">")
    a("> 科学术语优先采用中国大陆中学/大学物理、化学教材标准译法。")
    a("> 同一英文词在不同语境可有不同译文，但必须在 Notes 中固定，禁止无故混用。")
    a("")
    a("## 1. Global / UI Controls")
    a("")
    a("| Key | English | Chinese | Context | Notes |")
    a("|---|---|---|---|---|")
    for row in GLOSSARY:
        if row[3] in {
            "global control",
            "time control",
            "speed",
            "dialog",
            "navigation",
            "game/wizard",
            "game",
            "tab/screen",
            "panel",
            "checkbox",
            "slider extreme",
            "view option",
            "toolbox",
            "control",
            "density a11y",
        } or row[0] in {
            "resetAll",
            "reset",
            "play",
            "pause",
            "normal",
            "slow",
            "fast",
            "fastForward",
            "stopwatch",
            "close",
            "ok",
            "back",
            "next",
            "tryAgain",
            "showAnswer",
            "intro",
            "lab",
            "explore",
            "compare",
            "mystery",
            "game",
            "options",
            "values",
            "none",
            "lots",
            "custom",
            "grid",
            "path",
            "step",
            "ruler",
            "measuringTape",
            "graph",
            "view",
            "go",
            "return",
            "grab",
            "refresh",
            "configuration",
        }:
            a(f"| `{row[0]}` | {row[1]} | {row[2]} | {row[3]} | {row[4]} |")
    a("")
    a("## 2. Physics / Chemistry Terms (consistency-critical)")
    a("")
    a("| Key | English | Chinese | Context | Notes |")
    a("|---|---|---|---|---|")
    for row in GLOSSARY:
        if row[3] in {
            "physics",
            "physics control",
            "gravity-force-lab",
            "kinematics",
            "buoyancy",
            "waves",
            "chemistry",
            "efac",
            "optics",
            "gas",
            "material",
            "astronomy",
            "vector",
            "circuit",
            "density/buoyancy",
            "density",
            "build-an-atom",
            "optics/waves",
            "qwi",
            "woas",
            "hookes-law",
            "projectile",
            "molecule-shapes",
        } or row[0] in {
            "force",
            "gravity",
            "mass",
            "weight",
            "density",
            "pressure",
            "volume",
            "buoyancy",
            "displacement",
            "wavelength",
            "frequency",
            "amplitude",
            "particle",
            "molecule",
            "atom",
            "electricField",
            "voltage",
            "current",
            "resistance",
            "energy",
        }:
            a(f"| `{row[0]}` | {row[1]} | {row[2]} | {row[3]} | {row[4]} |")
    a("")
    a("## 3. Simulation Display Names")
    a("")
    a("> registry / route id 保持英文 kebab-case；仅 displayName 中文。")
    a("")
    a("| Registry Key | English | Chinese | Context |")
    a("|---|---|---|---|")
    for rid, en, zh in SIM_NAMES:
        a(f"| `{rid}` | {en} | {zh} | sim title |")
    a("")
    a("## 4. Consistency Rules")
    a("")
    a("1. **Gravity vs Gravity Force**：控件「重力」= g；万有引力实验「引力」。")
    a("2. **Mass ≠ Weight**：质量 / 重力（重量）不得互换。")
    a("3. **Pressure**：流体静力学一律「压强」。")
    a("4. **Velocity / Speed**：术语表区分；UI 若中学简化，全项目统一一种。")
    a("5. **Reset All**：一律「全部重置」（对齐产品用语；与 L0 按钮配套）。")
    a("6. **Intro / Lab / Explore**：Tab 译名全项目统一，禁止同一 sim 内混用「入门/介绍」。")
    a("7. 数学公式与单位（`F=ma`、`kg`、`m³`、`Pa`）**不翻译**。")
    a("")
    a("---")
    a("")
    a("PHASE 0：本 glossary 为草稿，实施阶段按 source context 复核后冻结。")
    a("")
    (OUT / "LOCALIZATION_GLOSSARY.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_exceptions() -> None:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    lines: list[str] = []
    a = lines.append
    a("# LOCALIZATION_EXCEPTIONS")
    a("")
    a(f"> PHASE 0 · {now}")
    a(">")
    a("> 明确列出**允许保留英文**的类别与理由。Whitelist 必须显式登记；禁止为了过检测而批量塞入。")
    a("")
    a("## 1. Allowed categories (product rule §7)")
    a("")
    a("| Category | Examples | Why allowed |")
    a("|---|---|---|")
    a("| Code identifiers | `BuoyancyModel`, `QuantumMeasurement` | 非用户可见自然语言 |")
    a("| File / package names | `lib/bending_light/` | 工程标识 |")
    a("| Registry / route IDs | `bending-light`, `ohms-law` | 稳定 ID，禁止改名 |")
    a("| Git / debug / logs | `print('debug...')` | 开发者专用 |")
    a("| PhET source archaeology | `phet/`、原始 properties/JS | 证据链，禁止改成中文 |")
    a("| Scientific symbols / units | `kg`, `m³`, `Pa`, `N`, `°C`, `A`, `V`, `ρ`, `F=ma` | 非自然语言 |")
    a("| Brand / proper tech names | `PhET`（致谢对话框等必要时） | 品牌保留；UI 正文仍应中文说明 |")
    a("")
    a("## 2. Provisional `allowedEnglishTerms` (PHASE 0 draft)")
    a("")
    a("| Term | Scope | Justification | Review |")
    a("|---|---|---|---|")
    a("| `PhET` | about/credits | 品牌名 | keep |")
    a("| `KartosLab` / `Kratos` | about/title | 产品名 | keep |")
    a("| `pH` | chemistry UI | 国际通用科学符号 | keep |")
    a("| `RGB` | color-vision technical label | 通道缩写；旁注可用「红绿蓝」 | review in Batch 6 |")
    a("| `N-body` | astronomy subtitle | 专业缩写；建议改为「多体」 | prefer translate |")
    a("| `χ²` | curve-fitting | 统计符号 | keep |")
    a("| `VSEPR` | molecule-shapes | 理论缩写；可旁注中文全称 | review |")
    a("| `Planck` / `Wien` | blackbody subtitle | 科学家姓氏 | keep as proper nouns |")
    a("| `OK` | dialogs | 可译「确定」；若保留须登记 | prefer translate |")
    a("| `Go!` | forces net-force | 应译「开始!」 | **not allowed long-term** |")
    a("")
    a("## 3. Explicitly NOT exceptions")
    a("")
    a("以下**不得**因「太多英文」而加入 whitelist：")
    a("")
    a("- Simulation 显示名（`Bending Light`、`Pendulum Lab`…）")
    a("- 控制面板标签（`Mass`、`Gravity`、`Density`…）")
    a("- Tab 名（`Intro`、`Lab`、`Explore`…）")
    a("- `Reset All` / tooltips / semantic labels")
    a("- 游戏提示（`Try Again`、`Show Answer`）")
    a("- Home 上的 `Physics` / `Chemistry` englishName（应隐藏或改为可选）")
    a("")
    a("## 4. Source-only strings")
    a("")
    a("- `phet/` 与 archaeology 目录内英文：**Source-only**，不计入用户可见 FAIL。")
    a("- requirements / docs / test 描述性英文：非运行时 UI；localization FAIL 规则仅针对 `lib/` 用户路径（测试另建 `test/localization`）。")
    a("")
    a("## 5. Font substitution (related exception)")
    a("")
    a("- 原版语义字体常为 Arial/Helvetica；无中文 glyph 时允许系统 CJK fallback。")
    a("- 必须在后续 `LOCALIZATION_REPORT` 记录 Font substitution，并用 Golden/Android 验证。")
    a("- PHASE 0 不改字体实现。")
    a("")
    a("---")
    a("")
    a("PHASE 0：Exceptions 草稿已建立；实施阶段每增 whitelist 条目必须附理由。")
    a("")
    (OUT / "LOCALIZATION_EXCEPTIONS.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_phase0_status() -> None:
    """Short machine+human status file for the required final output block."""
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    text = f"""# GLOBAL LOCALIZATION PHASE 0 — STATUS

Generated: {now}

## Counts

| Item | Value |
|---|---:|
| Files Scanned | {summary['files_scanned']} |
| User-visible Strings | {summary['total_string_hits']} |
| English | {summary['english_count']} |
| Chinese | {summary['chinese_count']} |
| Mixed | {summary['mixed_count']} |
| Accessibility | {summary['a11y_count']} |
| Home hits | {summary['home']['home_hits']} (EN {summary['home']['home_english']} / ZH {summary['home']['home_chinese']} / MIX {summary['home']['home_mixed']}) |
| Simulation (rest of lib) | see inventory module table |
| Hard-coded (non-strings-file) | see inventory §10 |
| Existing localization infrastructure | 32 `*Strings` bags; **no** `lib/l10n`, **no** `.arb` |

## Files Modified (PHASE 0)

| File | Action |
|---|---|
| `requirements/localization/LOCALIZATION_INVENTORY.md` | **created** |
| `requirements/localization/LOCALIZATION_GLOSSARY.md` | **created** |
| `requirements/localization/LOCALIZATION_EXCEPTIONS.md` | **created** |
| `requirements/localization/_phase0_raw.json` | audit artifact |
| `requirements/localization/_phase0_summary.json` | audit artifact |
| `requirements/localization/_phase0_modules.json` | audit artifact |
| `tooling/phase0_localization_audit.py` | scanner (dev tooling) |
| `tooling/phase0_generate_docs.py` | doc generator (dev tooling) |

**Simulation Model / Physics / Renderer: 0 files modified.**

## Final Status

**NOT READY**

Reason: English-dominant UI; no unified localization layer; Home/Sim mixed language; no zh goldens yet.
"""
    (OUT / "PHASE_0_STATUS.md").write_text(text, encoding="utf-8")


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    write_inventory()
    write_glossary()
    write_exceptions()
    write_phase0_status()
    print("Wrote:")
    for name in (
        "LOCALIZATION_INVENTORY.md",
        "LOCALIZATION_GLOSSARY.md",
        "LOCALIZATION_EXCEPTIONS.md",
        "PHASE_0_STATUS.md",
    ):
        p = OUT / name
        print(f"  {p} ({p.stat().st_size} bytes)")
