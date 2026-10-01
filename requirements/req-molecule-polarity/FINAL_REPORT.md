# Molecule Polarity — Final Report

**Final Status: READY（已结项）**  
**Req:** `req-molecule-polarity`  
**Closed:** 2026-09-15  
**Source:** PhET molecule-polarity **2.1.0-dev.0**（本地 SoT）

---

## 1. 一句话结论

Flutter 原生复刻 **Molecule Polarity**（Two Atoms / Three Atoms / Real Molecules）已通过 Final Gate，接入 KartosLab Home，可交付使用。

---

## 2. Final Gate

| Gate | Result |
|---|---|
| P0 | **0** |
| P1 | **0** |
| Compilation | PASS |
| Tests | **40 PASS** |
| Errors / Warnings | **0 / 0** |
| Infos | **4**（`use_super_parameters`）→ **CLEAN_WITH_INFO** |
| Chemistry / Model | PASS |
| Behavior | PASS |
| Interaction | PASS |
| Visual（Simulation content） | **PASS** |
| Assets | PASS（Substituted visual = **0**） |
| Lifecycle / Reset | PASS（含 3D + elastic Reset） |
| Browser QA | PASS |
| Home | **Wired** · open → interact → back → reopen PASS |

### Visual Gate（判定口径）

```
Full-frame Diff:
  contains known global shell + framing delta
  Two ≈22.5% · Real ≈16.3%  ← 非失败标准

Simulation-content Visual Gate:
  PASS（无 P1；残余 = P2 / A / A′）
```

详见：`VISUAL_GATE.md` · `DIFF_ATTRIBUTION.md` · `BROWSER_QA.md`

---

## 3. 交付范围

### Screens

| Tab | 能力 |
|---|---|
| **Two Atoms** | EN 滑条、偶极、部分电荷、表面色、E-field、拖转、hints、Reset |
| **Three Atoms** | 键角、bond / molecular dipoles、E-field、Reset |
| **Real Molecules** | 原版 `all_molecules.json` mesh、ESP/Density、选择器、偶极、旋转、Reset |

### Home 入口

```
Home → 化学 → 分子极性 → MoleculePolarityHome
```

### 代码 / 资源

| 路径 | 说明 |
|---|---|
| `lib/chemistry/molecule_polarity/**` | Model · Controller · Screens · Painters · Widgets |
| `assets/simulations/molecule_polarity/all_molecules.json` | 原版 mesh / ESP / density |
| `assets/simulations/molecule_polarity/realMoleculesScreenIcon.png` | 原版 tab icon |
| `test/chemistry/molecule_polarity/**` | Model / Widget / Visual capture / Home nav |
| `requirements/req-molecule-polarity/` | Spec · ASSET_MAP · Visual QA · Gate 文档 |

### 收口后 polish

- `MpResetAllButton`：对齐 scenery-phet `ThreeDAppearanceStrategy`（球面高光 + 阴影 + `elasticOut` 回弹）

---

## 4. Diff Attribution 摘要

| Class | 内容 | 处置 |
|---|---|---|
| **A** | KartosLab / PhET navbar · global shell | **不修改** |
| **A′** | 取景差（ORIGINAL 含 PhET 底栏；Flutter capture 为 layoutBounds） | 记为 framing，非内容 P1 |
| **B** | Simulation content | 已修 EN / Dipole icon / ToggleSwitch / mesh / AquaRadio / ComboBox 等；残余 P2 |

---

## 5. 已知 P2（不阻塞）

- EN 文案分行 / 1–2px 间距
- Real mesh Canvas 投影 vs WebGL 平滑度 / F 原子色调微差
- 整帧 Diff % 受 shell + framing 主导

---

## 6. 验证命令（复现）

```bash
flutter test test/chemistry/molecule_polarity
flutter analyze lib/chemistry/molecule_polarity lib/screens/home_screen.dart
```

预期：Tests **40 PASS**；Analyze **0 Error / 0 Warning / 4 Info**。

---

## 7. 相关文档索引

| 文档 | 用途 |
|---|---|
| `STATUS.md` | 状态快照 |
| `VISUAL_GATE.md` | 内容区 Visual Gate 清单 |
| `DIFF_ATTRIBUTION.md` | A/B 归因 |
| `BROWSER_QA.md` | 对照原版交互 |
| `ASSET_MAP.md` | 原版资源映射（Substituted=0） |
| `PHASE_0_*` / `PHASE_1_*` | 源码勘察与特性规格 |
| `visual-qa/{ORIGINAL,FLUTTER,DIFF}/` | 最终截图矩阵 |
| `process.txt` | 过程日志 |
| `meta.yaml` | phase=`3.close` · status=`done` |

---

## 8. 结项声明

**req-molecule-polarity 已关闭。**  
Final Status = **READY** · Home 已接入 · 无待办 P0/P1。
