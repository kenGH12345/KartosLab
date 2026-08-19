# 色觉单光源屏接入做中学探究抽屉（req-single-bulb-inquiry）

> 本文件用于记录里程碑、本轮目标、关键决策点。
> 与 spec/ 不同，plan.md 是「**当前在做什么**」的快速视图。

## 1. 总目标

让 color_vision 的 single_bulb（单光源滤光片）屏接入与 rgb_bulbs 屏一致的做中学探究工作流（InquiryDrawer + 进度条 + 记录/图表/结论），消除 PRD §5.5.3 声明与实现的差异 D3。

## 2. 里程碑

| 里程碑 | 完成标志 | 状态 |
|---|---|---|
| M1：需求定义清楚 | spec/ 文档完成 | done |
| M3：编码完成 | tasks 全 done（T-1~T-5 全 done @ 2026-08-19 15:04） | done |
| M4：测试通过 | 88/88 全绿落盘 + analyze 改动文件 0 新增 issue（test-report/ 双文件） | done |
| M5：评审通过 + 收尾 | verdict=tweak 修复落地 + spec/最终需求.md 生成（2026-08-19 15:30） | done |

## 3. 本轮目标（agile-vibe iteration 阶段使用）

完成 single_bulb_screen InquiryDrawer 接入 + 1 个探究场景 JSON，使 PRD §5.5.3 声明如实。

## 4. 关键决策点

- [x] single_bulb 屏是否需要新增带 inquiryTask 的场景 JSON → **是，新增至少 1 个**（现有 3 个 singleBulb 场景无 inquiryTask）
- [x] 是否含 predictions → **不含**（预测题仅 circuit/molarity 试点，PRD §10.7 后续扩展）→ 进度条 2 节点
- [x] 记录列选取 → bulbMode(param) + wavelength(param) + filter(param) + perceivedColor(reading)
- [x] 与 req-color-vision-layout-fix 冲突 → 改动正交，建议先完成布局修复再开发本需求

## 5. 关联资源

- PRD 审核报告: 主会话 2026-08-18 审核结论（差异 D3）
- 参考实现: `lib/color_vision/screens/rgb_bulbs_screen.dart`（同模块已接入范例）
- 关联需求: req-inquiry-learning / req-inquiry-extend / req-predictive-inquiry / req-color-vision-layout-fix
