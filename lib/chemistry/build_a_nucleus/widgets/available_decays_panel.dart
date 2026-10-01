/// Decay 右栏 Available Decays 内部密度。
///
/// [已确认] 原版无独立 DecayTypeListNode / DecayButton 类。
/// 结构在 `AvailableDecaysPanel.ts`：Panel > VBox(标题行, 五键 VBox, 分隔, 图例)。
/// 本组件只复刻标题 + 五键内部关系；图例 / info / 322 宽属 [有意差异：NineGrid]。
library;

import 'package:flutter/material.dart';

import '../ban_constants.dart';
import '../controller/build_a_nucleus_controller.dart';
import '../data/decay_type.dart';

class AvailableDecaysPanel extends StatelessWidget {
  const AvailableDecaysPanel({super.key, required this.controller});

  final BuildANucleusController controller;

  /// [已确认] `BANDecayType.decaySymbol`。β± 用 +/- 区分（原版按钮写全名）。
  static const labels = {
    NucleusDecayType.alphaDecay: 'α',
    NucleusDecayType.betaMinusDecay: 'β-',
    NucleusDecayType.betaPlusDecay: 'β+',
    NucleusDecayType.protonEmission: 'p',
    NucleusDecayType.neutronEmission: 'n',
  };

  static const _tooltips = {
    NucleusDecayType.alphaDecay: 'α 衰变',
    NucleusDecayType.betaMinusDecay: 'β- 衰变',
    NucleusDecayType.betaPlusDecay: 'β+ 衰变',
    NucleusDecayType.protonEmission: '质子发射',
    NucleusDecayType.neutronEmission: '中子发射',
  };

  @override
  Widget build(BuildContext context) {
    final s = controller.state;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 80.0;
        final maxH =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 400.0;
        final pad = maxW < 72 ? 4.0 : 6.0;
        final innerW = (maxW - 2 * pad).clamp(32.0, 10000.0);
        final innerH = (maxH - 2 * pad).clamp(48.0, 10000.0);

        // [已确认] AvailableDecaysPanel TITLE_FONT = PhetFont(24)
        const titleH = 24.0;
        final extra = s.canUndoDecay ? 1 : 0;
        final rows = 5 + extra;
        // title→第一键 + 键与键（含 Undo）之间
        final gaps = rows;
        var spacing = BanConstants.availableDecaysSpacing;
        var buttonH = BanConstants.availableDecaysButtonHeight;
        var scroll = false;
        final needed = titleH + rows * buttonH + gaps * spacing;
        if (needed > innerH) {
          spacing = (spacing * innerH / needed).clamp(2.0, spacing);
          final leftover = innerH - titleH - gaps * spacing;
          final rawH = leftover / rows;
          if (rawH < BanConstants.availableDecaysButtonMinHeight) {
            buttonH = BanConstants.availableDecaysButtonMinHeight;
            scroll = true;
          } else {
            buttonH = rawH.clamp(
              BanConstants.availableDecaysButtonMinHeight,
              BanConstants.availableDecaysButtonHeight,
            );
          }
        }
        final symbolSize = (buttonH * 0.55).clamp(12.0, 20.0);
        // 边格 < 原版 BUTTON_CONTENT_WIDTH 145，拉满 innerW。
        final buttonW = innerW.clamp(
          32.0,
          BanConstants.availableDecaysButtonContentWidth,
        );

        final column = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const ValueKey('ban_available_decays_title'),
              height: titleH,
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available Decays',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing),
            for (var i = 0; i < NucleusDecayType.values.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              _DecayTypeButton(
                type: NucleusDecayType.values[i],
                width: buttonW,
                height: buttonH,
                symbolSize: symbolSize,
                enabled: s.isDecayEnabled(NucleusDecayType.values[i]),
                tooltip: _tooltips[NucleusDecayType.values[i]]!,
                onPressed: s.isDecayEnabled(NucleusDecayType.values[i])
                    ? () => controller.applyDecay(NucleusDecayType.values[i])
                    : null,
              ),
            ],
            if (s.canUndoDecay) ...[
              SizedBox(height: spacing),
              SizedBox(
                width: buttonW,
                height: buttonH,
                child: IconButton(
                  key: const ValueKey('ban_undo_decay'),
                  tooltip: '撤销衰变',
                  onPressed: controller.undoDecay,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: buttonW,
                    height: buttonH,
                  ),
                  icon: Icon(Icons.undo, size: (buttonH * 0.55).clamp(14.0, 18.0)),
                ),
              ),
            ],
          ],
        );

        // LayoutBuilder 在 Expanded 里是紧约束；Align 松开高度，面板按内容收缩。
        // [已确认] 原版 Panel 随内容增高（另含图例）；不整板 FittedBox 缩小。
        // 矮视口：定高 + 内部滚动，避免负尺寸 / overflow。
        final panel = DecoratedBox(
          key: const ValueKey('ban_available_decays_panel'),
          decoration: BoxDecoration(
            color:
                const Color(BanConstants.availableDecaysPanelBackgroundValue),
            border:
                Border.all(color: const Color(BanConstants.panelStrokeValue)),
            borderRadius:
                BorderRadius.circular(BanConstants.panelCornerRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: scroll ? SingleChildScrollView(child: column) : column,
          ),
        );
        if (scroll) {
          return SizedBox(width: maxW, height: maxH, child: panel);
        }
        return Align(alignment: Alignment.topCenter, child: panel);
      },
    );
  }
}

class _DecayTypeButton extends StatelessWidget {
  const _DecayTypeButton({
    required this.type,
    required this.width,
    required this.height,
    required this.symbolSize,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  final NucleusDecayType type;
  final double width;
  final double height;
  final double symbolSize;
  final bool enabled;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const orange = Color(BanConstants.decayButtonColorValue);
    return SizedBox(
      width: width,
      height: height,
      child: IconButton(
        key: ValueKey('ban_decay_${type.name}'),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: BoxConstraints.tightFor(width: width, height: height),
        style: IconButton.styleFrom(
          backgroundColor: enabled ? orange : orange.withValues(alpha: 0.35),
          disabledBackgroundColor: orange.withValues(alpha: 0.35),
          foregroundColor: enabled ? Colors.black : Colors.black54,
          disabledForegroundColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          minimumSize: Size(width, height),
          maximumSize: Size(width, height),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
        ),
        icon: Text(
          AvailableDecaysPanel.labels[type]!,
          style: TextStyle(
            fontSize: symbolSize,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
