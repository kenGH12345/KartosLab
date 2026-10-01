# SESSION_REPORT — EFAC Intro/Systems 收尾（2026-09-11）

> req-id: `req-energy-forms-and-changes`  
> 范围：用户反馈驱动的 Intro/Systems 功能与视觉对齐  
> **sealed: conditional** — 工程可交付；像素级 BLOCKED D 仍不宣称完成

---

## 一句话结论

本轮把 Intro 加热器滑条/方块浸液、Systems 骑车加热与三能源（水阀/太阳/茶壶）补齐到可交互、可加热的可用状态；测试 **69 PASS**，`analyze` **0 error**。

---

## 本轮交付清单

### Intro

| 项 | 状态 | 说明 |
|---|---|---|
| HeaterCooler 竖滑条（红→蓝轨 + 青拇指 + Heat/Cool） | ✅ | 自定义 VSlider，对齐 `HeaterCoolerFront.ts` |
| 火焰/冰块从炉口上方冒出 | ✅ | PhET `setTranslation` 公式；画在 front 层防遮挡 |
| 方块可沉入烧杯液体 | ✅ | `Beaker.topSurface` 改为杯底内侧 `minY+MATERIAL_THICKNESS` |
| Pause/Step（无 Speed）+ Reset | ✅ | 对齐 Original reset |

### Systems

| 项 | 状态 | 说明 |
|---|---|---|
| 自行车下方曲柄速度拉动条 | ✅ | Panel + HSlider @ `centerY:110`，可点可拖 |
| 骑久烧杯升温 / 蒸汽 / Feed Me | ✅ | BeakerHeater 蓄热 5000 J/s；体力耗尽出 Feed Me |
| 太阳能板几何与锚点 | ✅ | 按 `SolarPanelNode.ts` 重排；自行车+太阳能板不发电 |
| 水阀源 | ✅ | 流量滑条 + 落水；驱动发电机桨轮 |
| 太阳源 | ✅ | 光线 + Clouds 竖滑条；需配太阳能板才发电 |
| 茶壶源 | ✅ | Heat-only 炉灶 + 蒸汽；驱动发电机 |

---

## 验证

```text
flutter test test/energy_forms_and_changes  → 69 PASS
flutter analyze lib/energy_forms_and_changes → 0 error（4 info）
```

---

## 仍 BLOCKED（不宣称视觉完成）

- `[BLOCKED D]` flame / ice / Faucet **像素级**保真（交互已可用）
- `[BLOCKED]` systems bike-reset Original 运行时截图缺失（不伪造 overlay）
- Systems 部分源节点为 PhET 布局对齐实现，细节动画（落水粒子、茶壶蒸汽粒子）为简化版

---

## 关键文件（本轮）

- `common/widgets/heater_cooler_control.dart` — VSlider + coolEnabled
- `common/model/beaker.dart` — topSurface = 杯底内侧
- `systems/widgets/biker_node.dart` — 曲柄滑条 + Feed Me
- `systems/widgets/beaker_heater_node.dart` — 真实蓄热温度计 + 蒸汽
- `systems/widgets/solar_panel_node.dart` — PhET 几何
- `systems/widgets/faucet_and_water_node.dart` — **新建**
- `systems/widgets/sun_energy_node.dart` — **新建**
- `systems/widgets/tea_kettle_node.dart` — **新建**
- `systems/model/systems_model.dart` — 蓄热 / 体力 / 轮转
- `systems/screens/systems_screen_body.dart` — 布局 + 三源接入
- `test/.../intro_model_test.dart` / `systems_model_test.dart` — 浸液/加热/耗能用例

---

## Final status

**CONDITIONAL CLOSE** — 用户确认的功能缺口已关闭；可进入产品验收。  
完整 visual seal 仍取决于是否接受 BLOCKED D / Original 缺口为 out-of-scope。

---

*2026-09-11 18:25 · session close report*
