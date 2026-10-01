# AUDIO_ANALYSIS — Gravity Force Lab: Basics

**本地源码版本（唯一第一事实来源）**：`1.2.0-dev.0`  
**路径**：`phet sourses/gravity-force-lab-basics-main/gravity-force-lab-basics-main`  
**dependencies 注释**：`1.1.0-dev.41` · sha `244ba556…`  
**取证日期**：2026-09-05

---

## 结论

### **[源码确认：原版存在音效 → 待迁移]**

本地 Basics 的 `GFLBScreenView.js` **显式**接入 tambo + `gravity-force-lab` 的 sound generators。  
这不是根据完整版 “推测也有音效”，而是 Basics 自身源码中的 wiring。

当前 Flutter 无音效 → 属 **Functional Gap**，不是 “原版无声故省略”。

**禁止**向 Flutter 添加自制/近似音效；下一步必须继续取证 sibling 资源与 trigger，再进入 Functional Gap Closure 实现。

---

## 1. `sounds/` 目录（Basics 仓库内）

| 项 | 结果 |
|---|---|
| `gravity-force-lab-basics/.../sounds/` | **不存在** |
| `tsconfig.json` 含 `"sounds/**/*"` | 有模板路径，但仓库内无实际 sounds 文件 |
| 音频资源归属 | **[已确认]** 引用 sibling：`gravity-force-lab/sounds/…` 与 `tambo/sounds/…` |

---

## 2. Basics `assets/` 中的音频

| 项 | 结果 |
|---|---|
| `assets/` 内容 | 仅截图 PNG（screenshot*.png） |
| `.mp3` / `.wav` / `.ogg` | **无**（Basics 本仓库内） |

---

## 3. JS 关键词扫描（Basics `js/`）

| 关键词 | 出现 | 位置 |
|---|---|---|
| `sound` / sound generation | ✅ | `GFLBScreenView.js` |
| `SoundClip` | ✅（经 ContinuousPropertySoundClip / Mass*） | 依赖 GFL + tambo |
| `soundManager` | ✅ | `import soundManager from '../../../tambo/js/soundManager.js'` |
| `tambo` | ✅ | imports + `dependencies.json` + HTML |
| `audio!` | ❌ | Basics js 中未直接出现 |
| `sonification` | ❌ 字面；但有 ContinuousPropertySoundClip 力值连续发声 | 语义上有 |
| sound generator | ✅ | `MassSoundGenerator` / `MassBoundarySoundGenerator` / `ContinuousPropertySoundClip` |
| `nullSoundPlayer` | ✅ | `GFLBMassControl.js`（刻意静音 NumberPicker） |

---

## 4. dependencies / package

### `dependencies.json`

| 依赖 | 状态 |
|---|---|
| **`tambo`** | **[已确认]** 存在（sha `79ceb409…`） |
| `gravity-force-lab` | **[已确认]** 存在（提供 Mass*Sound + wav） |
| 其他专用 sound 包 | 无单独 “sound” 包；发声走 tambo |

### `package.json` → `phet.simFeatures`

```json
"supportsSound": true
```

**[已确认]** Basics 声明支持 Sound。

`phetLibs`：`inverse-square-law-common`, `gravity-force-lab`, `tappi`（振动，非音频）。

`gravity-force-lab-basics-main.js` 元数据含 `soundDesign: 'Ashton Morris'`。

---

## 5. 音效类别对照（以 Basics wiring 为准）

| 类别 | Basics 源码 | 判定 |
|---|---|---|
| **Force / 连续 sonification** | `ContinuousPropertySoundClip(model.forceProperty, …, saturatedSineLoopTrimmed_wav)` | **有** |
| **Mass interaction sound** | `MassSoundGenerator` ×2，`initialOutputLevel: 0.7` | **有** |
| **Drag → 边界音** | `MassBoundarySoundGenerator` left/right，`BOUNDARY_SOUNDS_LEVEL = 1` | **有** |
| **Slider sound** | Basics 用 NumberPicker，非 slider | **不适用** |
| **NumberPicker / mass control 步进音** | `valueChangedSoundPlayer: nullSoundPlayer` + `boundarySoundPlayer: nullSoundPlayer` | **[已确认] 故意关闭** |
| **Button sound（checkbox 等）** | Basics 未自定义；是否用 sun/joist 默认点击音 | **[待确认：共享控件默认]** |
| **Reset sound** | Reset 时 `this.forceSoundGenerator.reset()`；ResetAllButton 默认点击音 | **force 生成器 reset [已确认]**；按钮点击音 **[待确认]** |
| **Accessibility / Voicing** | `supportsVoicing: true` + 大量 voicing 字符串 | **语音描述，非 tambo 音效**；本次音效分析单列，不混为 “无声” |
| **自制拖拽摩擦音 / 碰撞音** | 无（边界音除外） | 不要发明 |

---

## 6. Build / HTML

| 文件 | 证据 |
|---|---|
| `gravity-force-lab-basics_en.html` | `"supportsSound": true`；preload/repo 列表含 **`tambo`** |
| 本仓库 HTML 内嵌 wav/mp3 base64 | 未在 Basics 薄 HTML 中发现完整音频 blob（音频在 sibling 打包进 all.html 构建产物） |
| 本地无 `_all.html` 完整构建产物 | **[待确认：缺本地 all 构建嵌入审计]**；不影响 “存在音效” 结论（js wiring 已足够） |

---

## 7. Basics 源码中的具体 wiring（摘录级）

来源：`js/view/GFLBScreenView.js`

1. **质量音** — `MassSoundGenerator(object1/2.valueProperty, MASS_RANGE, { initialOutputLevel: 0.7 })`
2. **力连续音** — `ContinuousPropertySoundClip(forceProperty, Range(minForce,maxForce), saturatedSineLoopTrimmed_wav, { initialOutputLevel: 0.2, playbackRateRange: 0.6–2.1, normalizationMappingExponent: 0.25, trimSilence: false })`
3. **边界音** — `MassBoundarySoundGenerator(object1,'left')` / `(object2,'right')`，level 1
4. **Reset** — `forceSoundGenerator.reset()`

来源：`js/view/GFLBMassControl.js`

- NumberPicker 显式 `nullSoundPlayer` → **不走**通用 picker 点击音。

---

## 8. 音频资源清单（依赖仓库；本地未克隆）

本地 **无** `gravity-force-lab` / `tambo` 克隆。下列按 Basics import + `dependencies.json` 锁定的 GFL sha `d8a2dc07…` 从公开源核对（**[辅助证据，非 Basics 树内文件]**）：

| Asset | 用途（Basics） |
|---|---|
| `gravity-force-lab/sounds/saturated-sine-loop-trimmed.wav` | 力值 ContinuousPropertySoundClip |
| `gravity-force-lab/sounds/rubber-band-v3.mp3` | MassSoundGenerator |
| `gravity-force-lab/sounds/scrunched-mass-collision-sonic-womp.mp3` | 内侧边界（MassBoundarySoundGenerator） |
| `tambo/sounds/boundary-reached.mp3` | 外侧边界 |

**[待确认 / Gap]**：完整 volume / mute / lifecycle / MassSoundGenerator 与 `resetInProgressProperty` 参数签名对齐，需在本地补齐 sibling 源码后二次核对（当前 GFLB 调用传 3 参，GFL 该 sha 构造器可见 4 参——实现迁移前必须对齐实际可运行版本）。

---

## 9. 与 Flutter 现状

| 项 | 状态 |
|---|---|
| Flutter GFLB | **无音效** |
| 分类 | **migration introduced gap**（相对原版有声） |
| 正确标签 | **[源码确认：原版存在音效 → 待迁移]** |
| 错误标签 | ~~[源码一致：原版无音效]~~ · ~~有意省略 Sound~~ |

本次 **未** 修改 Physics / Model / UI。

---

## 10. 下一步（Functional Gap Closure · 音效）

在改代码前继续取证并落地：

1. 克隆/对齐本地 `gravity-force-lab@d8a2dc07` + `tambo@79ceb409`（或与 Basics 可运行组合一致的版本）
2. 固定 asset：上述 wav/mp3 → `assets/phet/gravity_force_lab_basics/sounds/`
3. 记录每个 generator 的 trigger / volume / playbackRate / reset / mute
4. 对齐 MassSoundGenerator 构造参数与 Reset 时静音行为
5. 实现后更新 `FUNCTIONAL_GAP_CLOSURE.md` + `COMPLETION_REPORT.md`

**不要**发明新音色或按“物理直觉”重做 sonification。
