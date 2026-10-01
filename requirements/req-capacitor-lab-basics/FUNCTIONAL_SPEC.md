# FUNCTIONAL_SPEC — Capacitor Lab: Basics（用户规格存档）

> 来源：产品功能规格（2026-09-14）  
> **本文件不能替代本地 PhET 源码。** 最终行为以  
> `phet sourses/capacitor-lab-basics-main/capacitor-lab-basics-main` 为准。  
> 复核结果：`FUNCTIONAL_SPEC_AUDIT.md`

## 用途

* 功能复核 · 交互修复 · Model/View 对照  
* 电表功能 · 双屏行为 · Visual QA  

## 核心数据流（摘要）

**Capacitance:** Battery → Circuit → Capacitor → Charge/V/C/Field → Graphs/Viz → Voltmeter  

**Light Bulb:** Battery → Charge → Switch → Bulb RC Discharge → Current/Brightness/Energy → Graphs + Voltmeter  

**Voltmeter:** Toolbox → Body/Probe → Tip Hit → Circuit Position → Potential → Red−Black → Reading/`?`  

## 判定标签

`[源码一致]` `[行为一致]` `[视觉已对齐]` `[视觉近似]` `[有意差异]` `[待确认]` `[BLOCKED]`

完整 §1–§53 与验收步骤见对话规格原文；审计映射见 `FUNCTIONAL_SPEC_AUDIT.md`。
