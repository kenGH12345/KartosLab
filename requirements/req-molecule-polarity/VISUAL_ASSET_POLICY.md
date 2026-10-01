# VISUAL_ASSET_POLICY — Molecule Polarity

遵循 `.codebuddy/rules/85-phet-original-assets.mdc`：

1. 唯一位图：`realMoleculesScreenIcon.png` → 必须 `Image.asset` 复用  
2. 原子/键/偶极/极板/表面云：源码为 Scenery Path → Flutter Canvas 等价重建  
3. 禁止 Material Icons / Emoji 冒充 PhET 控件（Reset All 使用 ResetShape 自绘）  
4. Real Molecules 3D 表面 mesh：暂不伪造截图；待 mesh 端口  
5. Final QA：`Substituted Assets = 0`
