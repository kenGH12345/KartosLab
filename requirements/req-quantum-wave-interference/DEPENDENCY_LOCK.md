# Quantum Wave Interference — Dependency Lock

Date: 2026-09-28  
Source of truth: `phet sourses/quantum-wave-interference-main/quantum-wave-interference-main/dependencies.json`  
Local `package.json` version: **1.0.0-dev.5**  
`dependencies.json` comment header: `# quantum-wave-interference 1.0.0-dev.2 Fri May 01 2026 …`（注释版本落后于 package.json；**实现以本地源码 + 下列 SHA 为准**）

> 禁止以 `latest` / `main` / `current` 作为实现依据。升级必须重新锁 SHA。

---

## Quantum Wave Interference (sim)

| Field | Value |
|---|---|
| version | `1.0.0-dev.5` |
| commit (dependencies.json) | `d9ee906473cf4ae2ece4f18b65f715e46249dd86` |
| branch (lock file) | `main` |
| local path | `phet sourses/quantum-wave-interference-main/quantum-wave-interference-main` |
| git in local tree | **no**（zip extract）；SHA 取自 `dependencies.json` |
| official URL | https://phet.colorado.edu/sims/html/quantum-wave-interference/latest/quantum-wave-interference_all.html |

---

## Locked framework dependencies

`dependencies.json` 将下列全部依赖锁到同一 SHA：

**`d9ee906473cf4ae2ece4f18b65f715e46249dd86`**

| Repo | SHA | Local status |
|---|---|---|
| assert | `d9ee906…` | **MISSING** |
| axon | `d9ee906…` | **MISSING** |
| brand | `d9ee906…` | **MISSING** |
| chipper | `d9ee906…` | **MISSING** |
| dot | `d9ee906…` | **MISSING** |
| joist | `d9ee906…` | **MISSING** |
| kite | `d9ee906…` | **MISSING** |
| perennial-alias | `d9ee906…` | **MISSING** |
| phet-core | `d9ee906…` | **MISSING** |
| phet-io | `d9ee906…` | **MISSING** |
| phet-io-sim-specific | `d9ee906…` | **MISSING** |
| phet-io-wrappers | `d9ee906…` | **MISSING** |
| phetcommon | `d9ee906…` | **MISSING** |
| phetmarks | `d9ee906…` | **MISSING** |
| quantum-wave-interference | `d9ee906…` | **PRESENT**（本 sim） |
| query-string-machine | `d9ee906…` | **MISSING** |
| scenery | `d9ee906…` | **MISSING** |
| scenery-phet | `d9ee906…` | **PRESENT BUT WRONG SHA** — 本地 `phet sourses/scenery-phet` 的 `dependencies.json` 标注为 2020-10-23 旧快照，**不得**当作本 sim 实现依据 |
| sherpa | `d9ee906…` | **MISSING** |
| studio | `d9ee906…` | **MISSING** |
| sun | `d9ee906…` | **MISSING** |
| tambo | `d9ee906…` | **MISSING** |
| tandem | `d9ee906…` | **MISSING** |
| twixt | `d9ee906…` | **MISSING** |
| utterance-queue | `d9ee906…` | **MISSING** |

---

## Flutter port dependency policy

| Need | Policy |
|---|---|
| 数值 / Model / Solver | **仅依赖本 sim 源码**（`js/common/model/*`, screen models）。算法自包含，不需要运行 PhET chipper 构建链。 |
| VisibleColor / TimeSpeed / MeasuringTape / Stopwatch / shared sounds | 需要对照时，按锁 SHA 检出对应 repo；**禁止**使用本地过期 `scenery-phet`。 |
| tambo / sharedSoundPlayers | 本 sim 自定义音频仅 `snapshotCaptured.mp3`；其余为 shared hooks（见 `AUDIO_MAP.md`）。 |
| KartosLab L0 | Reset All → `KratosResetAllButton`；测量尺 / 时间控件优先查 `lib/common/` 已有复用。 |

### Checkout commands（需要时执行；PHASE 0 不强制全量 clone）

```bash
# Example — clone one missing dep at locked SHA
git clone https://github.com/phetsims/dot.git "phet sourses/dot"
cd "phet sourses/dot" && git checkout d9ee906473cf4ae2ece4f18b65f715e46249dd86
```

优先检出（Phase 1 可能交叉对照）：`dot`, `axon`, `scenery-phet`, `tambo`, `joist`。

---

## Phase 1 dependency resolution (2026-09-28)

| Need | Resolution |
|---|---|
| `Complex` / math | **Ported** → `lib/physics/.../numerics/complex.dart`（未 clone `dot`） |
| `dotRandom` | 由可注入 `QwiRandom` / `SeededQwiRandom` 替代 |
| `VisibleColor` / MeasuringTape / tambo | Phase 1 **不需要**（无 UI） |
| Framework repos | 仍 MISSING；**未执行 clone**（算法自包含于 QWI TS） |

锁 SHA 仍为：`d9ee906473cf4ae2ece4f18b65f715e46249dd86`

---

## Doc drift warning

`doc/model.md` 中 High Intensity / Single Particles 的 slit-separation 范围与源码不一致。  
**以 TypeScript 源码为准**（见 `NUMERICAL_MODEL.md` / `CONTROL_MAP.md`）。