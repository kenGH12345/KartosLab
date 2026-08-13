import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 九宫格屏幕适配布局——**所有 sim 的强制屏幕适配方案**。
///
/// 把整个可用屏幕划分为 3×3 的 9 个格子：
/// ```text
/// topLeft  topCenter  topRight
/// midLeft  center     midRight
/// bottomLeft bottomCenter bottomRight
/// ```
/// 尺寸规则（非等分）：
/// - 中间格（第 5 格）**面积至少占屏幕的 70%**（默认 [centerAreaRatio] = 0.7 ·
///   宽、高各取 `sqrt(面积比)`，下限由 [kMinCenterAreaRatio] 强制保证）。承载实验主画面。
/// - 其余 8 个周边格贴各自屏幕边缘，均分剩余空间（信息展示 / 交互控件由各 sim 自行安排）。
/// - 所有格子尺寸随视口自动计算（屏幕变则格子变）。
///
/// 格子内的内容应通过 [LayoutBuilder] 读取格子实际尺寸自适应渲染
/// （组件只负责分格，不约束内容尺寸）。
///
/// 工程约束自检：无 `Positioned` 绝对定位、无硬编码像素尺寸，
/// 中间格由 Row/Column 天然居中（80-kratos-sim-checklist L0-1/L0-3）。
class NineGridLayout extends StatelessWidget {
  const NineGridLayout({
    super.key,
    required this.center,
    this.topLeft,
    this.topCenter,
    this.topRight,
    this.midLeft,
    this.midRight,
    this.bottomLeft,
    this.bottomCenter,
    this.bottomRight,

    /// 底部横条（可选）· 横跨整个屏幕底部的控件条（如操作面板底部横排）。
    /// 默认放在底部行之下 · 高度由本组件自适应（`min(footerMaxHeight, 屏高×0.16)` ·
    /// 矮视口自动压缩）· 不参与 3×3 分格。
    this.footer,
    this.centerAreaRatio = kMinCenterAreaRatio,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
  });

  /// 中间格面积占屏幕的最小比例（强制下限 · 对应"至少 70%"）。
  static const double kMinCenterAreaRatio = 0.7;

  /// 底部横条最大高度（高视口封顶 · 矮视口按 `屏高×0.16` 压缩）。
  static const double _footerMaxHeight = 96;

  /// 中间格面积占屏面积比例，低于 [kMinCenterAreaRatio] 时强制抬升到下限。
  final double centerAreaRatio;

  /// 中间格（第 5 格）· 实验主画面。
  final Widget center;

  /// 顶部一行（左/中/右）。
  final Widget? topLeft;
  final Widget? topCenter;
  final Widget? topRight;

  /// 中间一行左右两格（中间是 [center]）。
  final Widget? midLeft;
  final Widget? midRight;

  /// 底部一行（左/中/右）。
  final Widget? bottomLeft;
  final Widget? bottomCenter;
  final Widget? bottomRight;

  /// 底部横条（可选）· 高度 = `min(96, 屏高×0.16)` · 内容自行处理横向滚动/自适应。
  final Widget? footer;

  /// 整体内边距（默认 0 · 边缘格保持贴边）。
  final EdgeInsetsGeometry padding;

  /// 背景色。
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final area = _clampArea(centerAreaRatio);
            // 宽、高各占 sqrt(面积比) → 中间格面积 = 面积比 × 屏面积
    final side = math.sqrt(area);
    // Major-2 评审修复：footer 高度从 centerH 扣除，
    // 避免 footer(0.16H) + center(0.837H) 占满屏高导致上下边格被压到近 0（AC-5.4）。
    final footerH = footer != null
        ? math.min(_footerMaxHeight, constraints.maxHeight * 0.16)
        : 0.0;
    final centerW = constraints.maxWidth * side;
    // 极端矮视口降级（req-panel-bottom-migrate 批次1 实证）：顶部/底部行低于 48px
    // （控件最小可操作高）时压缩 center，保证边格内容（TabBar/说明条/按钮）不溢出。
    // 正常视口 sideH ≥ 48 → 保持 70% 面积；仅 320×480 类极端视口 center 面积 < 70%。
    final idealCenterH = (constraints.maxHeight - footerH) * side;
    final sideH = (constraints.maxHeight - footerH - idealCenterH) / 2;
    const minSideH = 48.0;
    final centerH = sideH < minSideH
        ? constraints.maxHeight - footerH - 2 * minSideH
        : idealCenterH;
            return Column(
              children: [
                Expanded(
                  child: _buildRow([topLeft, topCenter, topRight], centerW),
                ),
                SizedBox(
                  height: centerH,
                  child: _buildRow([midLeft, center, midRight], centerW),
                ),
                Expanded(
                  child: _buildRow([
                    bottomLeft,
                    bottomCenter,
                    bottomRight,
                  ], centerW),
                ),
                if (footer != null)
                  SizedBox(
                    height: footerH,
                    child: footer,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _clampArea(double v) {
    // 单边上限 0.95 → 面积上限 0.9025
    const double maxArea = 0.95 * 0.95;
    if (v < kMinCenterAreaRatio) return kMinCenterAreaRatio;
    if (v > maxArea) return maxArea;
    return v;
  }

  Widget _buildRow(List<Widget?> cells, double centerWidth) {
    return Row(
      children: [
        Expanded(child: cells[0] ?? const SizedBox.shrink()),
        SizedBox(
          width: centerWidth,
          child: cells[1] ?? const SizedBox.shrink(),
        ),
        Expanded(child: cells[2] ?? const SizedBox.shrink()),
      ],
    );
  }
}
