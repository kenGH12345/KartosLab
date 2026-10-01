/// BlochSphereView — wraps CustomPainter; no model mutation.
library;

import 'package:flutter/material.dart';

import '../projection/bloch_projection.dart';
import 'bloch_sphere_painter.dart';

class BlochSphereView extends StatelessWidget {
  const BlochSphereView({
    super.key,
    required this.center,
    required this.polar,
    required this.azimuthal,
    this.scale = 1.0,
    this.drawKets = false,
    this.drawAngleIndicators = true,
    this.drawAxesLabels = true,
    this.stateVectorScale = 1.0,
    this.stateVectorVisible = true,
  });

  final Offset center;
  final double polar;
  final double azimuthal;
  final double scale;
  final bool drawKets;
  final bool drawAngleIndicators;
  final bool drawAxesLabels;
  final double stateVectorScale;
  final bool stateVectorVisible;

  @override
  Widget build(BuildContext context) {
    final r = blochSphereRadius * scale;
    // Local bounds expanded ~1.5R like source expandBounds.
    final side = r * 3.2;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(side, side),
        painter: BlochSpherePainter(
          input: BlochSpherePaintInput(
            center: Offset(side / 2, side / 2),
            polar: polar,
            azimuthal: azimuthal,
            scale: scale,
            drawKets: drawKets,
            drawAngleIndicators: drawAngleIndicators,
            drawAxesLabels: drawAxesLabels,
            stateVectorScale: stateVectorScale,
            stateVectorVisible: stateVectorVisible,
          ),
        ),
      ),
    );
  }
}

/// Positions a BlochSphereView so its visual center matches [designCenter].
class PositionedBlochSphere extends StatelessWidget {
  const PositionedBlochSphere({
    super.key,
    required this.designCenter,
    required this.polar,
    required this.azimuthal,
    this.scale = 1.0,
    this.drawKets = false,
    this.drawAngleIndicators = true,
    this.drawAxesLabels = true,
  });

  final Offset designCenter;
  final double polar;
  final double azimuthal;
  final double scale;
  final bool drawKets;
  final bool drawAngleIndicators;
  final bool drawAxesLabels;

  @override
  Widget build(BuildContext context) {
    final r = blochSphereRadius * scale;
    final side = r * 3.2;
    return Positioned(
      left: designCenter.dx - side / 2,
      top: designCenter.dy - side / 2,
      child: BlochSphereView(
        center: Offset(side / 2, side / 2),
        polar: polar,
        azimuthal: azimuthal,
        scale: scale,
        drawKets: drawKets,
        drawAngleIndicators: drawAngleIndicators,
        drawAxesLabels: drawAxesLabels,
      ),
    );
  }
}
