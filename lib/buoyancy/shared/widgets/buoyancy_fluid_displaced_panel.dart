import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/material/buoyancy_gravity.dart';
import '../../domain/material/buoyancy_material.dart';
import '../../physics/constants.dart';
import '../../buoyancy_strings.dart';
import 'buoyancy_accordion_stub.dart';

/// Source: `FluidDisplacedAccordionBox.ts` + scenery-phet `BeakerNode.ts`.
///
/// Accordion content: BeakerNode + volume NumberDisplay + scale icon + force readout.
/// Polls [displacedLiters]/[fluid]/[gravity] each frame so values stay live
/// while [BuoyancyPlayArea] ticks physics without rebuilding the parent overlay.
class BuoyancyFluidDisplacedPanel extends StatefulWidget {
  const BuoyancyFluidDisplacedPanel({
    super.key,
    required this.displacedLiters,
    required this.fluid,
    required this.gravity,
    required this.expanded,
    required this.onToggle,
    this.maxBeakerVolumeLiters = 10,
  });

  final ValueGetter<double> displacedLiters;
  final ValueGetter<BuoyancyMaterial> fluid;
  final ValueGetter<BuoyancyGravity> gravity;
  final bool expanded;
  final VoidCallback onToggle;

  /// Lab `maxBlockVolume` = 10 L.
  final double maxBeakerVolumeLiters;

  static const double contentWidth = 105;
  static const double beakerHeight = contentWidth * 0.55;
  static const double yRadiusOfEnds = contentWidth * 0.12;
  static const double solutionVisibleThreshold = 0.001;

  @override
  State<BuoyancyFluidDisplacedPanel> createState() =>
      _BuoyancyFluidDisplacedPanelState();
}

class _BuoyancyFluidDisplacedPanelState extends State<BuoyancyFluidDisplacedPanel>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) setState(() {});
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liters =
        widget.displacedLiters().clamp(0.0, widget.maxBeakerVolumeLiters);
    final formatted = liters.toStringAsFixed(2);
    final level = formatted == '0.00'
        ? 0.0
        : math.max(
            BuoyancyFluidDisplacedPanel.solutionVisibleThreshold,
            liters / widget.maxBeakerVolumeLiters,
          );
    final fluid = widget.fluid();
    final gravity = widget.gravity();
    final solution = _fluidColor(fluid);
    final weightN = (fluid.density /
            BuoyancyPhysicsConstants.litersInCubicMeter) *
        gravity.value *
        liters;

    const scaleIconH = 42.0;
    final beakerH = BuoyancyFluidDisplacedPanel.beakerHeight;
    final yR = BuoyancyFluidDisplacedPanel.yRadiusOfEnds;
    final contentW = BuoyancyFluidDisplacedPanel.contentWidth;
    final totalH = beakerH + yR + scaleIconH - 8;

    return BuoyancyAccordionStub(
      title: BuoyancyStrings.fluidDisplaced,
      expanded: widget.expanded,
      onToggle: widget.onToggle,
      child: SizedBox(
        width: contentW + 8,
        height: totalH + 8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 4,
              top: 0,
              child: CustomPaint(
                size: Size(contentW, beakerH + yR),
                painter: _BeakerPainter(
                  level: level.clamp(0.0, 1.0),
                  solution: solution,
                ),
              ),
            ),
            Positioned(
              right: 6,
              top: beakerH * 0.72,
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  '$formatted L',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: beakerH + yR - 13,
              child: Center(
                child: Image.asset(
                  'assets/buoyancy/images/fluid_displaced_scale_icon.png',
                  width: contentW * 0.85,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: beakerH + yR + scaleIconH * 0.38,
              child: Center(
                child: Text(
                  weightN < 0.05
                      ? '0.0 N'
                      : '${weightN.toStringAsFixed(1)} N',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `DensityBuoyancyCommonColors` fluid fills (alpha from source defaults).
Color _fluidColor(BuoyancyMaterial m) {
  switch (m.id) {
    case 'gasoline':
      return const Color.fromARGB(102, 230, 255, 0);
    case 'oil':
      return const Color.fromARGB(102, 180, 230, 20);
    case 'water':
      return const Color.fromARGB(102, 0, 128, 255);
    case 'seawater':
      return const Color.fromARGB(102, 0, 150, 255);
    case 'honey':
      return const Color.fromARGB(128, 238, 170, 0);
    case 'mercury':
      return const Color.fromARGB(204, 219, 206, 202);
    case 'fluidA':
      return const Color.fromARGB(153, 255, 255, 80);
    case 'fluidB':
      return const Color.fromARGB(153, 80, 255, 255);
    case 'fluidC':
      return const Color.fromARGB(153, 255, 128, 255);
    case 'fluidD':
      return const Color.fromARGB(153, 128, 255, 255);
    case 'fluidE':
      return const Color.fromARGB(153, 255, 128, 128);
    case 'fluidF':
      return const Color.fromARGB(153, 128, 255, 128);
    default:
      final t = ((m.density - 500) / 1500).clamp(0.0, 1.0);
      return Color.lerp(
            const Color.fromARGB(102, 128, 192, 255),
            const Color.fromARGB(153, 0, 48, 128),
            t,
          ) ??
          const Color.fromARGB(102, 0, 128, 255);
  }
}

/// Cylinder beaker with elliptical ends — scenery-phet `BeakerNode`.
class _BeakerPainter extends CustomPainter {
  _BeakerPainter({required this.level, required this.solution});

  final double level;
  final Color solution;

  static const double beakerW = BuoyancyFluidDisplacedPanel.contentWidth;
  static const double beakerH = BuoyancyFluidDisplacedPanel.beakerHeight;
  static const double yR = BuoyancyFluidDisplacedPanel.yRadiusOfEnds;
  static const int numberOfTicks = 9;
  static const int majorModulus = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final topY = yR;
    final botY = yR + beakerH;
    final xR = beakerW / 2;
    final topOval = Rect.fromCenter(
      center: Offset(cx, topY),
      width: beakerW,
      height: yR * 2,
    );
    final botOval = Rect.fromCenter(
      center: Offset(cx, botY),
      width: beakerW,
      height: yR * 2,
    );

    // Empty back fill
    final body = Path()
      ..moveTo(cx - xR, topY)
      ..lineTo(cx - xR, botY)
      ..arcTo(botOval, math.pi, -math.pi, false)
      ..lineTo(cx + xR, topY)
      ..arcTo(topOval, 0, -math.pi, false)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0x22FFFFFF));

    if (level > 0) {
      final solTop = botY - level * beakerH;
      final solTopOval = Rect.fromCenter(
        center: Offset(cx, solTop),
        width: beakerW,
        height: yR * 2,
      );
      final solBody = Path()
        ..moveTo(cx - xR, solTop)
        ..lineTo(cx - xR, botY)
        ..arcTo(botOval, math.pi, -math.pi, false)
        ..lineTo(cx + xR, solTop)
        ..close();
      canvas.drawPath(solBody, Paint()..color = solution);
      canvas.drawOval(
        solTopOval,
        Paint()..color = Color.lerp(solution, Colors.white, 0.35)!,
      );
      canvas.drawOval(
        botOval,
        Paint()..color = solution.withValues(alpha: 0.45),
      );
    }

    final stroke = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Front outline: left wall → bottom front arc → right wall
    final front = Path()
      ..moveTo(cx - xR, topY)
      ..lineTo(cx - xR, botY)
      ..arcTo(botOval, math.pi, -math.pi, false)
      ..lineTo(cx + xR, topY);
    canvas.drawPath(front, stroke);
    canvas.drawOval(topOval, stroke);

    // Glare strip
    final glare = Path()
      ..moveTo(cx - xR * 0.6, topY + beakerH * 0.05)
      ..lineTo(cx - xR * 0.6, botY - beakerH * 0.1)
      ..lineTo(cx - xR * 0.5, botY - beakerH * 0.05)
      ..lineTo(cx - xR * 0.5, topY)
      ..close();
    canvas.drawPath(glare, Paint()..color = const Color(0x55FFFFFF));

    // Ticks
    final tickPaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1;
    for (var i = 1; i <= numberOfTicks; i++) {
      final t = i / (numberOfTicks + 1);
      final y = botY - t * beakerH;
      final major = i % majorModulus == 0;
      final len = major ? 14.0 : 7.0;
      canvas.drawLine(
        Offset(cx + xR - 1, y),
        Offset(cx + xR - 1 - len, y),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BeakerPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.solution != solution;
}
