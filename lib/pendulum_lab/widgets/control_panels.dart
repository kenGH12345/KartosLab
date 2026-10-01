import 'package:flutter/material.dart';
import 'package:kratos/pendulum_lab/model/body.dart';
import 'package:kratos/pendulum_lab/model/energy_model.dart';
import 'package:kratos/pendulum_lab/model/lab_model.dart';
import 'package:kratos/pendulum_lab/model/pendulum_lab_model.dart';
import 'package:kratos/pendulum_lab/pl_colors.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';
import 'package:kratos/pendulum_lab/pl_strings.dart';
import 'package:kratos/pendulum_lab/widgets/pl_controls.dart';

class PendulumControlPanel extends StatelessWidget {
  const PendulumControlPanel({super.key, required this.model});

  final PendulumLabModel model;

  @override
  Widget build(BuildContext context) {
    final n = model.numberOfPendula;
    return PlPanel(
      width: PlConstants.rightContentWidth + PlConstants.panelXMargin * 2,
      child: Column(
        children: [
          _pendulumGroup(0),
          if (n == 2) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, thickness: 0.3, color: PlColors.separator),
            ),
            _pendulumGroup(1),
          ],
        ],
      ),
    );
  }

  Widget _pendulumGroup(int i) {
    final p = model.pendula[i];
    final color = PlColors.pendulumColors[i];
    return Column(
      children: [
        PendulumNumberControl(
          title: PlStrings.lengthTitle(i + 1),
          value: p.length,
          min: PlConstants.lengthMin,
          max: PlConstants.lengthMax,
          color: color,
          pattern: metersPattern,
          sliderConstrain: (v) => (v * 10).round() / 10,
          onChanged: (v) => model.setLength(i, v),
        ),
        const SizedBox(height: 14),
        PendulumNumberControl(
          title: PlStrings.massTitle(i + 1),
          value: p.mass,
          min: PlConstants.massMin,
          max: PlConstants.massMax,
          color: color,
          pattern: kgPattern,
          sliderConstrain: (v) => (v * 10).round() / 10,
          onChanged: (v) => model.setMass(i, v),
        ),
      ],
    );
  }
}

class GlobalControlPanel extends StatelessWidget {
  const GlobalControlPanel({
    super.key,
    required this.model,
    required this.hasGravityTweakers,
  });

  final PendulumLabModel model;
  final bool hasGravityTweakers;

  @override
  Widget build(BuildContext context) {
    final planetX = model.body == PlBody.planetX;
    return PlPanel(
      width: PlConstants.rightContentWidth + PlConstants.panelXMargin * 2,
      child: Column(
        children: [
          if (planetX)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                PlStrings.whatIsTheValueOfGravity,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontFamily: 'Arial'),
              ),
            ),
          PendulumNumberControl(
            title: PlStrings.gravity,
            value: model.gravity,
            min: PlConstants.gravityMin,
            max: PlConstants.gravityMax,
            color: PlColors.sliderTrack,
            pattern: gravityPattern,
            showDisplay: hasGravityTweakers && !planetX,
            showArrows: hasGravityTweakers,
            minTick: hasGravityTweakers ? '0' : PlStrings.none,
            maxTick: hasGravityTweakers ? '25' : PlStrings.lots,
            sliderPadding: hasGravityTweakers ? 0 : 8,
            sliderConstrain: (v) => (v * 2).round() / 2,
            onChanged: model.setGravity,
          ),
          const SizedBox(height: 5),
          DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFF999999)),
              ),
              child: DropdownButton<PlBody>(
                value: model.body,
                isDense: true,
                items: [
                  for (final b in PlBodyData.bodies)
                    DropdownMenuItem(
                      value: b,
                      child: Text(
                        b.title,
                        style: const TextStyle(fontSize: 12, fontFamily: 'Arial'),
                      ),
                    ),
                ],
                onChanged: (b) {
                  if (b != null) model.setBody(b);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          PendulumNumberControl(
            title: PlStrings.friction,
            value: PlConstants.frictionToSliderValue(model.friction),
            min: 0,
            max: 10,
            color: PlColors.thumbFill,
            pattern: (v) => v,
            showDisplay: false,
            showArrows: false,
            minTick: PlStrings.none,
            maxTick: PlStrings.lots,
            sliderPadding: 14,
            sliderConstrain: (v) => v.roundToDouble(),
            onChanged: (s) =>
                model.setFriction(PlConstants.sliderValueToFriction(s)),
          ),
        ],
      ),
    );
  }
}

class ToolsPanel extends StatelessWidget {
  const ToolsPanel({super.key, required this.model});

  final PendulumLabModel model;

  @override
  Widget build(BuildContext context) {
    return PlPanel(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlCheckbox(
            label: PlStrings.ruler,
            value: model.ruler.isVisible,
            onChanged: model.setRulerVisible,
          ),
          PlCheckbox(
            label: PlStrings.stopwatch,
            value: model.stopwatch.isVisible,
            onChanged: model.setStopwatchVisible,
          ),
          PlCheckbox(
            label: model.hasPeriodTimer
                ? PlStrings.periodTimer
                : PlStrings.periodTrace,
            value: model.isPeriodTraceVisible,
            onChanged: model.setPeriodTraceVisible,
          ),
        ],
      ),
    );
  }
}

class ArrowVisibilityPanel extends StatelessWidget {
  const ArrowVisibilityPanel({super.key, required this.model});

  final LabModel model;

  @override
  Widget build(BuildContext context) {
    return PlPanel(
      width: 180,
      child: Column(
        children: [
          PlCheckbox(
            label: PlStrings.velocity,
            value: model.isVelocityVisible,
            onChanged: model.setVelocityVisible,
            trailing: _miniArrow(PlColors.velocityArrow),
          ),
          PlCheckbox(
            label: PlStrings.acceleration,
            value: model.isAccelerationVisible,
            onChanged: model.setAccelerationVisible,
            trailing: _miniArrow(PlColors.accelerationArrow),
          ),
        ],
      ),
    );
  }

  Widget _miniArrow(Color color) {
    return CustomPaint(
      size: const Size(22, 10),
      painter: _MiniArrowPainter(color: color),
    );
  }
}

class _MiniArrowPainter extends CustomPainter {
  _MiniArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2 - 3)
      ..lineTo(size.width - 8, size.height / 2 - 3)
      ..lineTo(size.width - 8, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - 8, size.height)
      ..lineTo(size.width - 8, size.height / 2 + 3)
      ..lineTo(0, size.height / 2 + 3)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MiniArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

class EnergyGraphAccordion extends StatelessWidget {
  const EnergyGraphAccordion({
    super.key,
    required this.model,
  });

  final EnergyModel model;

  @override
  Widget build(BuildContext context) {
    final p = model.activeEnergyPendulum;
    final zoom = model.energyZoom;
    final expanded = model.isEnergyBoxExpanded;

    // AccordionBox title row (BOX_OPTIONS + TITLE_FONT).
    final titleRow = GestureDetector(
      onTap: () => model.setEnergyBoxExpanded(!expanded),
      child: Row(
        children: [
          CustomPaint(
            size: const Size(14, 14),
            painter: _ExpandPainter(expanded: expanded),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              PlStrings.energyGraph,
              style: TextStyle(fontSize: 14, fontFamily: 'Arial'),
            ),
          ),
        ],
      ),
    );

    if (!expanded) {
      return PlPanel(width: 160, child: titleRow);
    }

    // Source structure (EnergyGraphAccordionBox):
    //   AccordionBox[ title ] → VBox[ radios, Panel[ header, chart ],
    //                                 Row[ info, zoomOut, zoomIn ] ]
    // Chart height is filled by the parent (Expanded) so the accordion bottom
    // tracks the tools panel, like resizeEnergyGraphToFit().
    return PlPanel(
      width: 160, // aligned with tools panel (LEFT_CONTENT_ALIGN_GROUP)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleRow,
          if (model.numberOfPendula == 2) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                PlAquaRadio(
                  value: model.pendula[0],
                  groupValue: p,
                  onChanged: model.setActiveEnergyPendulum,
                  label: '1',
                ),
                const SizedBox(width: 20),
                PlAquaRadio(
                  value: model.pendula[1],
                  groupValue: p,
                  onChanged: model.setActiveEnergyPendulum,
                  label: '2',
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              // Inner Panel: PANEL_OPTIONS fill/cornerRadius/margins.
              decoration: BoxDecoration(
                color: PlColors.panelFill,
                borderRadius:
                    BorderRadius.circular(PlConstants.panelCornerRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    PlStrings.pendulumMass(p.index + 1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PlColors.pendulumColors[p.index],
                      fontFamily: 'Arial',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFBBBBBB), width: 0.5),
                      ),
                      padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _EnergyBarsPainter(
                                    ke: p.kineticEnergy,
                                    pe: p.potentialEnergy,
                                    thermal: p.thermalEnergy,
                                    zoom: zoom,
                                  ),
                                ),
                              ),
                              // clearThermalButton is the TE bar's labelNode
                              // in the source (MoveToTrashLegendButton).
                              Positioned(
                                left: constraints.maxWidth * 0.625 - 9,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: p.thermalEnergy == 0
                                      ? null
                                      : () => model.clearThermal(p),
                                  child: Opacity(
                                    opacity:
                                        p.thermalEnergy == 0 ? 0.35 : 1,
                                    child: CustomPaint(
                                      size: const Size(18, 16),
                                      painter: _TrashPainter(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showLegend(context),
                child: CustomPaint(
                  size: const Size(22, 22),
                  painter: _InfoPainter(),
                ),
              ),
              const Spacer(),
              _ZoomBtn(
                zoomIn: false,
                onTap: () => model.setEnergyZoom(
                  zoom / PlConstants.energyZoomMultiplier,
                ),
              ),
              const SizedBox(width: 10),
              _ZoomBtn(
                zoomIn: true,
                onTap: () => model.setEnergyZoom(
                  zoom * PlConstants.energyZoomMultiplier,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLegend(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          PlStrings.energyLegend,
          style: TextStyle(fontSize: 22, fontFamily: 'Arial'),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendRow(PlStrings.keAbbr, PlStrings.keName, PlColors.kineticEnergy),
            _LegendRow(PlStrings.peAbbr, PlStrings.peName, PlColors.potentialEnergy),
            _LegendRow(
              PlStrings.thermAbbr,
              PlStrings.thermName,
              PlColors.thermalEnergy,
            ),
            _LegendRow(PlStrings.totalAbbr, PlStrings.totalName, PlColors.totalEnergy),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow(this.abbr, this.name, this.color);

  final String abbr;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              abbr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Arial',
              ),
            ),
          ),
          Text(name, style: const TextStyle(fontSize: 16, fontFamily: 'Arial')),
        ],
      ),
    );
  }
}

class _EnergyBarsPainter extends CustomPainter {
  _EnergyBarsPainter({
    required this.ke,
    required this.pe,
    required this.thermal,
    required this.zoom,
  });

  final double ke;
  final double pe;
  final double thermal;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    // griddle BarChartNode: 4 labelled bars — KE / PE / TE / Total, where
    // Total STACKS [KE, PE, TE] (its label uses offScaleArrowFill #bbb).
    // TE's label is the clear-thermal trash button (rendered as a widget
    // overlay by the caller), so no text is painted for slot 2.
    const labels = [PlStrings.keAbbr, PlStrings.peAbbr, PlStrings.totalAbbr];
    final colW = size.width / 4;
    const labelH = 18.0;
    final barMax = size.height - labelH - 6;
    final barHalfW = colW * 0.35;

    canvas.drawLine(
      Offset(2, barMax),
      Offset(size.width - 2, barMax),
      Paint()
        ..color = const Color(0xFF666666)
        ..strokeWidth = 1,
    );

    void bar(double cx, double yBase, double h, Color color) {
      if (h <= 0) return;
      final rect = Rect.fromLTRB(cx - barHalfW, yBase - h, cx + barHalfW, yBase);
      canvas.drawRect(rect, Paint()..color = color);
      canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0xFF333333)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    void offScaleArrow(double cx) {
      final tip = Offset(cx, 2);
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 5, tip.dy + 8)
        ..lineTo(tip.dx + 5, tip.dy + 8)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFBBBBBB));
    }

    final scale = PlConstants.energyBarScale * zoom;
    final singles = [ke, pe, thermal];
    final singleColors = [
      PlColors.kineticEnergy,
      PlColors.potentialEnergy,
      PlColors.thermalEnergy,
    ];
    var clippedAny = false;
    for (var i = 0; i < 3; i++) {
      final rawH = singles[i] * scale;
      clippedAny = clippedAny || rawH > barMax;
      final h = rawH.clamp(0.0, barMax);
      final x = colW * i + colW / 2;
      bar(x, barMax, h, singleColors[i]);
      if (rawH > barMax) offScaleArrow(x);
      if (i == 2) continue; // TE label is the trash overlay
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'Arial',
            color: singleColors[i],
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - tp.height));
    }

    // Total bar: stacked KE + PE + TE from the baseline.
    final xTotal = colW * 3 + colW / 2;
    var yBase = barMax;
    final totalRaw = (ke + pe + thermal) * scale;
    for (var i = 0; i < 3; i++) {
      var h = singles[i] * scale;
      if (yBase - h < 0) h = yBase; // clip stack at chart top
      bar(xTotal, yBase, h, singleColors[i]);
      yBase -= h;
    }
    if (totalRaw > barMax) offScaleArrow(xTotal);
    final tp = TextPainter(
      text: const TextSpan(
        text: PlStrings.totalAbbr,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Arial',
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(xTotal - tp.width / 2, size.height - tp.height));
  }

  @override
  bool shouldRepaint(covariant _EnergyBarsPainter oldDelegate) => true;
}

class _TrashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = PlColors.thermalEnergy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    // lid
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.28),
      Offset(size.width * 0.8, size.height * 0.28),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.18),
      Offset(size.width * 0.65, size.height * 0.18),
      stroke,
    );
    // body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        size.width * 0.25,
        size.height * 0.32,
        size.width * 0.75,
        size.height * 0.88,
      ),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(body, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ZoomBtn extends StatelessWidget {
  const _ZoomBtn({required this.zoomIn, required this.onTap});

  final bool zoomIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: const Size(28, 28),
        painter: _ZoomPainter(zoomIn: zoomIn),
      ),
    );
  }
}

class _ZoomPainter extends CustomPainter {
  _ZoomPainter({required this.zoomIn});

  final bool zoomIn;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      13,
      Paint()..color = const Color(0xFF99CCFF),
    );
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(c.dx - 5, c.dy), Offset(c.dx + 5, c.dy), p);
    if (zoomIn) {
      canvas.drawLine(Offset(c.dx, c.dy - 5), Offset(c.dx, c.dy + 5), p);
    }
  }

  @override
  bool shouldRepaint(covariant _ZoomPainter oldDelegate) =>
      oldDelegate.zoomIn != zoomIn;
}

class _InfoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 10, Paint()..color = const Color(0xFF58ACDA));
    final tp = TextPainter(
      text: const TextSpan(
        text: 'i',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExpandPainter extends CustomPainter {
  _ExpandPainter({required this.expanded});

  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (expanded) {
      path
        ..moveTo(2, 4)
        ..lineTo(7, 10)
        ..lineTo(12, 4);
    } else {
      path
        ..moveTo(4, 2)
        ..lineTo(10, 7)
        ..lineTo(4, 12);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ExpandPainter oldDelegate) =>
      oldDelegate.expanded != expanded;
}
