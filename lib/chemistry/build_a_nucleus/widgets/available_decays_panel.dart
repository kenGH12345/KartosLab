/// Decay 右栏 Available Decays。
///
/// [已确认] `AvailableDecaysPanel.ts`：标题、五键全名 + IconFactory 图、
/// 分隔、图例；Undo 在面板外左侧。
library;

import 'package:flutter/material.dart';

import '../ban_constants.dart';
import '../controller/build_a_nucleus_controller.dart';
import '../data/decay_type.dart';
import 'ban_undo_button.dart';
import 'decay_type_icon.dart';

class AvailableDecaysPanel extends StatelessWidget {
  const AvailableDecaysPanel({super.key, required this.controller});

  final BuildANucleusController controller;

  /// 原版按钮写全名；符号只出现在旁侧示意图。
  static const labels = {
    NucleusDecayType.alphaDecay: 'α decay',
    NucleusDecayType.betaMinusDecay: 'β- decay',
    NucleusDecayType.betaPlusDecay: 'β+ decay',
    NucleusDecayType.protonEmission: 'Proton Emission',
    NucleusDecayType.neutronEmission: 'Neutron Emission',
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
            constraints.maxWidth.isFinite ? constraints.maxWidth : 322.0;
        final maxH =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 400.0;
        final pad = maxW < 72 ? 4.0 : 15.0;
        final innerW = (maxW - 2 * pad).clamp(32.0, 10000.0);
        final innerH = (maxH - 2 * pad).clamp(48.0, 10000.0);

        const titleH = 24.0;
        const legendH = 36.0;
        const sepH = 8.0;
        final extra = s.canUndoDecay ? 0 : 0;
        const rows = 5;
        final gaps = rows + extra;
        var spacing = BanConstants.availableDecaysSpacing;
        var buttonH = BanConstants.availableDecaysButtonHeight;
        var scroll = false;
        final needed =
            titleH + rows * buttonH + gaps * spacing + sepH + legendH;
        if (needed > innerH) {
          spacing = (spacing * innerH / needed).clamp(2.0, spacing);
          final leftover = innerH - titleH - gaps * spacing - sepH - legendH;
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
        final fontSize = (buttonH * 0.5).clamp(11.0, 18.0);
        final buttonW = innerW.clamp(32.0, 10000.0);

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
                fontSize: fontSize,
                enabled: s.isDecayEnabled(NucleusDecayType.values[i]),
                tooltip: _tooltips[NucleusDecayType.values[i]]!,
                onPressed: s.isDecayEnabled(NucleusDecayType.values[i])
                    ? () => controller.applyDecay(NucleusDecayType.values[i])
                    : null,
              ),
            ],
            SizedBox(height: spacing),
            const Divider(height: 8, thickness: 1, color: Color(0xFFCACACA)),
            const _DecayParticleLegend(),
          ],
        );

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

        final body = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.canUndoDecay) ...[
              Padding(
                padding: const EdgeInsets.only(top: 36, right: 8),
                child: BanUndoButton(onPressed: controller.undoDecay),
              ),
            ],
            Expanded(child: panel),
          ],
        );

        if (scroll) {
          return SizedBox(width: maxW, height: maxH, child: body);
        }
        return Align(alignment: Alignment.topCenter, child: body);
      },
    );
  }
}

class _DecayTypeButton extends StatelessWidget {
  const _DecayTypeButton({
    required this.type,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  final NucleusDecayType type;
  final double width;
  final double height;
  final double fontSize;
  final bool enabled;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const orange = Color(BanConstants.decayButtonColorValue);
    return SizedBox(
      width: width,
      height: height,
      child: Tooltip(
        message: tooltip,
        child: TextButton(
          key: ValueKey('ban_decay_${type.name}'),
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: enabled ? orange : orange.withValues(alpha: 0.35),
            disabledBackgroundColor: orange.withValues(alpha: 0.35),
            foregroundColor: enabled ? Colors.black : Colors.black54,
            disabledForegroundColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            minimumSize: Size(width, height),
            maximumSize: Size(width, height),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AvailableDecaysPanel.labels[type]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
              DecayTypeIcon(type: type, height: (height * 0.78).clamp(16, 30)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecayParticleLegend extends StatelessWidget {
  const _DecayParticleLegend();

  @override
  Widget build(BuildContext context) {
    return const FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        key: ValueKey('ban_decay_legend'),
        children: [
          _LegendDot(color: Color(BanConstants.protonColorValue), label: 'Proton'),
          SizedBox(width: 10),
          _LegendDot(color: Color(BanConstants.neutronColorValue), label: 'Neutron'),
          SizedBox(width: 10),
          _LegendDot(color: Color(BanConstants.electronColorValue), label: 'Electron'),
          SizedBox(width: 10),
          _LegendDot(color: Color(0xFF35B64A), label: 'Positron'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.4),
              radius: 1.6,
              colors: [Colors.white, color],
            ),
            border: Border.all(color: color, width: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
