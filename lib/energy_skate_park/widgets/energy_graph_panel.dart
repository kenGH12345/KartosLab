import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kratos/energy_skate_park/assets/esp_assets.dart';
import 'package:kratos/energy_skate_park/controller/graphs_controller.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/model/graphs_model.dart';
import 'package:kratos/energy_skate_park/painters/energy_graph_painter.dart';

/// Page-level Energy Graph area (EnergyGraphAccordionBox.ts).
///
/// Horizontal layout: [checkboxes | y-label+zoom | plot]
/// Plot size: width = TRACK_WIDTH×mvtScale, height = GRAPH_HEIGHT(141).
/// Not an overlay — reserved above [PlayArea] in Graphs page layout.
class EnergyGraphPanel extends StatelessWidget {
  const EnergyGraphPanel({super.key, required this.controller});

  final GraphsController controller;

  /// Title bar + content margins (AccordionBox buttonYMargin/contentYMargin).
  static const double titleBarHeight = 28;
  static const double contentXMargin = 7;
  static const double contentYMargin = 3;
  static const double xLabelGap = 10;
  static const double xLabelHeight = 18;
  static const double checkboxColumnWidth = 92;
  static const double yLabelColumnWidth = 36;

  /// Expanded panel height from PhET geometry (plot + labels + title).
  static double get expandedHeight =>
      titleBarHeight +
      contentYMargin * 2 +
      EspConstants.energyGraphPlotHeight +
      xLabelGap +
      xLabelHeight +
      8;

  static double get collapsedHeight => titleBarHeight + 8;

  @override
  Widget build(BuildContext context) {
    final g = controller.graphsModel;
    final expanded = g.energyGraphExpanded;

    return Material(
      elevation: 2,
      color: EspColors.panelFill,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: EspColors.panelStroke),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.fromLTRB(
          contentXMargin,
          contentYMargin,
          contentXMargin,
          contentYMargin,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TitleBar(
              expanded: expanded,
              independent: g.independentVariable,
              onToggleExpand: () =>
                  controller.setEnergyGraphExpanded(!expanded),
              onIndependent: controller.setIndependentVariable,
              onClear: controller.clearEnergyData,
            ),
            if (expanded) ...[
              const SizedBox(height: 4),
              _ExpandedBody(controller: controller),
            ],
          ],
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({
    required this.expanded,
    required this.independent,
    required this.onToggleExpand,
    required this.onIndependent,
    required this.onClear,
  });

  final bool expanded;
  final GraphIndependentVariable independent;
  final VoidCallback onToggleExpand;
  final ValueChanged<GraphIndependentVariable> onIndependent;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: EnergyGraphPanel.titleBarHeight,
      child: Row(
        children: [
          // AccordionBox expand/collapse (sideLength 19).
          InkWell(
            onTap: onToggleExpand,
            child: CustomPaint(
              size: const Size(19, 19),
              painter: _ExpandButtonPainter(expanded: expanded),
            ),
          ),
          const SizedBox(width: 7),
          const Text(
            EspStrings.energyGraph,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (expanded) ...[
            _VariableSwitch(
              independent: independent,
              onChanged: onIndependent,
            ),
            const SizedBox(width: 8),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: EspStrings.clearEnergyData,
              onPressed: onClear,
              icon: SvgPicture.asset(
                EspAssets.eraserSvg,
                width: 20,
                height: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VariableSwitch extends StatelessWidget {
  const _VariableSwitch({
    required this.independent,
    required this.onChanged,
  });

  final GraphIndependentVariable independent;
  final ValueChanged<GraphIndependentVariable> onChanged;

  @override
  Widget build(BuildContext context) {
    final isPos = independent == GraphIndependentVariable.position;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          EspStrings.position,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isPos ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 40,
          height: 22,
          child: Transform.scale(
            scale: 0.65,
            child: Switch(
              value: !isPos,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => onChanged(
                v
                    ? GraphIndependentVariable.time
                    : GraphIndependentVariable.position,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          EspStrings.time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: !isPos ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _ExpandedBody extends StatelessWidget {
  const _ExpandedBody({required this.controller});

  final GraphsController controller;

  @override
  Widget build(BuildContext context) {
    final g = controller.graphsModel;
    final plotW = EspConstants.energyGraphPlotWidth;
    final plotH = EspConstants.energyGraphPlotHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Prefer PhET plot width; shrink only if column is narrower.
        final maxPlotW = (constraints.maxWidth -
                EnergyGraphPanel.checkboxColumnWidth -
                EnergyGraphPanel.yLabelColumnWidth -
                20)
            .clamp(200.0, plotW);
        final usedPlotW = maxPlotW < plotW ? maxPlotW : plotW;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: EnergyGraphPanel.checkboxColumnWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EnergyCheck(
                    label: EspStrings.kinetic,
                    color: EspColors.kineticEnergy,
                    value: g.kineticVisible,
                    onChanged: controller.setKineticVisible,
                  ),
                  _EnergyCheck(
                    label: EspStrings.potential,
                    color: EspColors.potentialEnergy,
                    value: g.potentialVisible,
                    onChanged: controller.setPotentialVisible,
                  ),
                  _EnergyCheck(
                    label: EspStrings.thermal,
                    color: EspColors.thermalEnergy,
                    value: g.thermalVisible,
                    onChanged: controller.setThermalVisible,
                  ),
                  _EnergyCheck(
                    label: EspStrings.total,
                    color: EspColors.totalEnergy,
                    value: g.totalVisible,
                    onChanged: controller.setTotalVisible,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: EnergyGraphPanel.yLabelColumnWidth,
              height: plotH +
                  EnergyGraphPanel.xLabelGap +
                  EnergyGraphPanel.xLabelHeight,
              child: Column(
                children: [
                  SizedBox(
                    height: plotH,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            EspStrings.energyAxis,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ZoomColumn(controller: controller),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: EnergyGraphPanel.xLabelGap +
                        EnergyGraphPanel.xLabelHeight,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: usedPlotW,
                  height: plotH,
                  child: GestureDetector(
                    onTapDown: (d) => _onPlotTap(d.localPosition, usedPlotW, g),
                    child: CustomPaint(
                      painter: EnergyGraphPainter(
                        samples: List.of(g.dataSamples),
                        independentVariable: g.independentVariable,
                        kineticVisible: g.kineticVisible,
                        potentialVisible: g.potentialVisible,
                        thermalVisible: g.thermalVisible,
                        totalVisible: g.totalVisible,
                        zoomIndex: g.energyGraphZoomIndex,
                        cursorIndex: g.cursorSampleIndex ??
                            (g.dataSamples.isEmpty
                                ? null
                                : g.dataSamples.length - 1),
                        padLeft: 4,
                        padRight: 4,
                        padTop: 4,
                        padBottom: 4,
                        drawOuterAxisLabels: false,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                const SizedBox(height: EnergyGraphPanel.xLabelGap),
                SizedBox(
                  height: EnergyGraphPanel.xLabelHeight,
                  width: usedPlotW,
                  child: Text(
                    g.independentVariable == GraphIndependentVariable.time
                        ? EspStrings.time
                        : EspStrings.position,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onPlotTap(Offset local, double chartW, GraphsModel g) {
    if (chartW <= 0) return;
    final t = (local.dx / chartW).clamp(0.0, 1.0);
    double xMin;
    double xMax;
    if (g.independentVariable == GraphIndependentVariable.time) {
      xMin = 0;
      xMax = EspConstants.maxPlottedTime;
      if (g.dataSamples.isNotEmpty) {
        final tMax =
            g.dataSamples.map((s) => s.time).reduce((a, b) => a > b ? a : b);
        if (tMax > xMax) {
          xMin = tMax - EspConstants.maxPlottedTime;
          xMax = tMax;
        }
      }
    } else {
      xMin = 0;
      xMax = 10;
    }
    controller.setCursorFromIndependentValue(xMin + t * (xMax - xMin));
  }
}

class _EnergyCheck extends StatelessWidget {
  const _EnergyCheck({
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (v) => onChanged(v ?? true),
            ),
          ),
          Container(width: 8, height: 8, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomColumn extends StatelessWidget {
  const _ZoomColumn({required this.controller});

  final GraphsController controller;

  @override
  Widget build(BuildContext context) {
    final g = controller.graphsModel;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ZoomBtn(
          onPressed: () =>
              controller.setEnergyGraphZoomIndex(g.energyGraphZoomIndex + 1),
          child: CustomPaint(
            size: const Size(18, 18),
            painter: _MagnifierPainter(zoomIn: true),
          ),
        ),
        const SizedBox(height: 7),
        _ZoomBtn(
          onPressed: () =>
              controller.setEnergyGraphZoomIndex(g.energyGraphZoomIndex - 1),
          child: CustomPaint(
            size: const Size(18, 18),
            painter: _MagnifierPainter(zoomIn: false),
          ),
        ),
      ],
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  const _ZoomBtn({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF6C9BD1), // PhetColorScheme.PHET_LOGO_BLUE-ish
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: child,
        ),
      ),
    );
  }
}

class _ExpandButtonPainter extends CustomPainter {
  _ExpandButtonPainter({required this.expanded});

  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(3),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFFE8E8E8));
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx - 4, c.dy), Offset(c.dx + 4, c.dy), paint);
    if (!expanded) {
      canvas.drawLine(Offset(c.dx, c.dy - 4), Offset(c.dx, c.dy + 4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExpandButtonPainter old) =>
      old.expanded != expanded;
}

class _MagnifierPainter extends CustomPainter {
  _MagnifierPainter({required this.zoomIn});

  final bool zoomIn;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.4, size.height * 0.4);
    const r = 5.0;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      Offset(c.dx + r * 0.7, c.dy + r * 0.7),
      Offset(size.width * 0.85, size.height * 0.85),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    final cross = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx - 2.5, c.dy), Offset(c.dx + 2.5, c.dy), cross);
    if (zoomIn) {
      canvas.drawLine(Offset(c.dx, c.dy - 2.5), Offset(c.dx, c.dy + 2.5), cross);
    }
  }

  @override
  bool shouldRepaint(covariant _MagnifierPainter old) => old.zoomIn != zoomIn;
}
