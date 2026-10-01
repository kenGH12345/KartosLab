import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';
import 'package:kratos/energy_skate_park/widgets/measuring_tape.dart';
import 'package:kratos/energy_skate_park/widgets/phet_tool_icons.dart';

/// ToolboxPanel.ts — stopwatch & measuring tape icons from PhET geometry.
class ToolboxPanel extends StatelessWidget {
  const ToolboxPanel({
    super.key,
    required this.controller,
    required this.mvt,
    required this.playAreaSize,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.panelKey,
  });

  final EspController controller;
  final EspMvt mvt;
  final Size playAreaSize;
  final VoidCallback onDragStart;
  final void Function(Offset local, ToolboxTool tool) onDragUpdate;
  final VoidCallback onDragEnd;
  final Key? panelKey;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    return Material(
      key: panelKey,
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      color: EspColors.panelFill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: EspColors.panelStroke),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolIcon(
              label: EspStrings.stopwatch,
              hidden: model.stopwatchVisible,
              tool: ToolboxTool.stopwatch,
              onDragStart: onDragStart,
              onDragUpdate: onDragUpdate,
              onDragEnd: onDragEnd,
              child: const PhetStopwatchIcon(scale: 0.55),
            ),
            const SizedBox(width: 24),
            _ToolIcon(
              label: EspStrings.measuringTape,
              hidden: model.measuringTapeVisible,
              tool: ToolboxTool.measuringTape,
              onDragStart: onDragStart,
              onDragUpdate: onDragUpdate,
              onDragEnd: onDragEnd,
              child: const PhetMeasuringTapeAssetIcon(scale: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

enum ToolboxTool { stopwatch, measuringTape }

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({
    required this.label,
    required this.hidden,
    required this.tool,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  final String label;
  final bool hidden;
  final ToolboxTool tool;
  final VoidCallback onDragStart;
  final void Function(Offset local, ToolboxTool tool) onDragUpdate;
  final VoidCallback onDragEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: hidden ? 0.25 : 1,
      child: IgnorePointer(
        ignoring: hidden,
        child: GestureDetector(
          onPanStart: (_) => onDragStart(),
          onPanUpdate: (d) => onDragUpdate(d.localPosition, tool),
          onPanEnd: (_) => onDragEnd(),
          onTap: () {
            onDragStart();
            onDragUpdate(const Offset(200, 200), tool);
            onDragEnd();
          },
          child: Tooltip(
            message: label,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
