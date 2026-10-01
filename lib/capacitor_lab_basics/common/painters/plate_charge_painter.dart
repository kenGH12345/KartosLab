import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../render/circuit_render_data.dart';
import '../transform/yaw_pitch_mvt.dart';

/// Plate charges — `scenery-phet/.../PlateChargeNode.js`
///
/// Top plate polarity = POSITIVE, bottom = NEGATIVE (`CapacitorNode`).
class PlateChargePainter extends CustomPainter {
  PlateChargePainter({
    required this.data,
    required this.isTopPlate,
    YawPitchMvt? mvt,
  })  : mvt = mvt ?? YawPitchMvt(),
        polarityPositive = isTopPlate;

  final CircuitRenderData data;
  final bool isTopPlate;
  final bool polarityPositive;
  final YawPitchMvt mvt;

  static const int minCharges = 1;
  static const int maxCharges = 625;
  static const double chargeW = 7;
  static const double chargeH = 2;

  /// `PhetColorScheme.RED_COLORBLIND`
  static const Color positiveColor = Color(0xFFE50000);
  static const Color negativeColor = Color(0xFF0000FF);

  @override
  void paint(Canvas canvas, Size size) {
    if (!data.plateChargesVisible) return;
    final n = numberOfCharges(data.plateCharge, data.maxPlateCharge);
    if (n <= 0) return;

    final faceY = isTopPlate ? data.topPlateFaceY : data.bottomPlateFaceY;
    final zMargin = mvt.viewToModelXY(chargeW, 0).x;
    final gridWidth = data.plateWidth;
    final gridDepth = data.plateDepth - (2 * zMargin);
    final grid = gridSize(n, gridWidth, gridDepth);
    final columns = grid.$1;
    final rows = grid.$2;
    if (columns <= 0 || rows <= 0) return;

    final dx = gridWidth / columns;
    final dz = gridDepth / rows;
    final xOffset = dx / 2;
    final zOffset = dz / 2;
    final showPositive = _isPositivelyCharged();

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final x = -data.plateWidth / 2 + xOffset + column * dx;
        var z = -(gridDepth / 2) + (zMargin / 2) + zOffset + row * dz;
        if (n == 1) {
          z -= dz / 6;
        }
        final center = mvt.modelToViewXYZ(
          data.capacitorX + x,
          faceY,
          data.capacitorZ + z,
        );
        if (showPositive) {
          _drawPositive(canvas, center);
        } else {
          _drawNegative(canvas, center);
        }
      }
    }
  }

  bool _isPositivelyCharged() {
    final q = data.plateCharge;
    return (q >= 0 && polarityPositive) || (q < 0 && !polarityPositive);
  }

  /// `PlateChargeNode.getNumberOfCharges`
  static int numberOfCharges(double plateCharge, double maxPlateCharge) {
    final absCharge = plateCharge.abs();
    if (maxPlateCharge <= 0 || !maxPlateCharge.isFinite) {
      return absCharge > 0 ? minCharges : 0;
    }
    var n = (maxCharges * (absCharge / maxPlateCharge)).round();
    if (absCharge > 0 && n < minCharges) n = minCharges;
    return math.min(maxCharges, n);
  }

  /// `PlateChargeNode.getGridSize`
  static (int columns, int rows) gridSize(
    int numberOfObjects,
    double width,
    double height,
  ) {
    if (numberOfObjects <= 0 || width <= 0 || height <= 0) return (0, 0);
    final alpha = math.sqrt(numberOfObjects / width / height);
    var columns = (width * alpha).round();
    final rows1 = (height * alpha).round();
    final rows2 =
        columns == 0 ? numberOfObjects : (numberOfObjects / columns).round();
    var rows = rows1;
    if (rows1 != rows2) {
      final error1 = (numberOfObjects - rows1 * columns).abs();
      final error2 = (numberOfObjects - rows2 * columns).abs();
      rows = error1 < error2 ? rows1 : rows2;
    }
    if (columns == 0) {
      columns = 1;
      rows = numberOfObjects;
    } else if (rows == 0) {
      rows = 1;
      columns = numberOfObjects;
    }
    return (columns, rows);
  }

  void _drawPositive(Canvas canvas, Offset p) {
    final paint = Paint()..color = positiveColor;
    canvas.drawRect(
      Rect.fromCenter(center: p, width: chargeW, height: chargeH),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: p, width: chargeH, height: chargeW),
      paint,
    );
  }

  void _drawNegative(Canvas canvas, Offset p) {
    final paint = Paint()..color = negativeColor;
    canvas.drawRect(
      Rect.fromLTWH(p.dx - chargeW / 2, p.dy, chargeW, chargeH),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant PlateChargePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.isTopPlate != isTopPlate;
}

/// E-field lines between plates — `scenery-phet/.../EFieldNode.js`
class EFieldPainter extends CustomPainter {
  EFieldPainter({
    required this.data,
    YawPitchMvt? mvt,
  }) : mvt = mvt ?? YawPitchMvt();

  final CircuitRenderData data;
  final YawPitchMvt mvt;

  static const double spacingConstant = 0.0258;

  @override
  void paint(Canvas canvas, Size size) {
    if (!data.electricFieldVisible) return;
    final e = data.effectiveEField;
    final lineSpacing = _lineSpacing(e);
    if (lineSpacing <= 0) return;

    final plateWidth = data.plateWidth;
    final plateDepth = data.plateDepth;
    final plateSeparation = data.plateSeparation;
    final length = mvt.modelToViewDeltaXYZ(0, plateSeparation, 0).dy;
    final directionDown = e >= 0;

    final path = Path();
    var x = lineSpacing / 2;
    while (x <= plateWidth / 2) {
      var z = lineSpacing / 2;
      while (z <= plateDepth / 2) {
        _addLine(
          path,
          mvt.modelToViewXYZ(
            data.capacitorX + x,
            data.capacitorY,
            data.capacitorZ + z,
          ),
          length,
          directionDown,
        );
        _addLine(
          path,
          mvt.modelToViewXYZ(
            data.capacitorX - x,
            data.capacitorY,
            data.capacitorZ + z,
          ),
          length,
          directionDown,
        );
        _addLine(
          path,
          mvt.modelToViewXYZ(
            data.capacitorX + x,
            data.capacitorY,
            data.capacitorZ - z,
          ),
          length,
          directionDown,
        );
        _addLine(
          path,
          mvt.modelToViewXYZ(
            data.capacitorX - x,
            data.capacitorY,
            data.capacitorZ - z,
          ),
          length,
          directionDown,
        );
        z += lineSpacing;
      }
      x += lineSpacing;
    }

    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fill = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, stroke);
    canvas.drawPath(path, fill);
  }

  double _lineSpacing(double effectiveEField) {
    if (effectiveEField == 0) return 0;
    return spacingConstant / math.sqrt(effectiveEField.abs());
  }

  void _addLine(Path path, Offset position, double length, bool down) {
    path.moveTo(position.dx, position.dy - length / 2 - 3);
    path.lineTo(position.dx, position.dy + length / 2 - 3);
    const w = 6.0;
    const h = 7.0;
    const xOffset = 1 / 4;
    // EFieldNode: UP uses position.x - xOffset; DOWN uses + xOffset
    final arrowCenter = down ? position.dx + xOffset : position.dx - xOffset;
    if (!down) {
      path
        ..moveTo(arrowCenter, position.dy - h / 2)
        ..lineTo(arrowCenter + w / 2, position.dy + h / 2)
        ..lineTo(arrowCenter - w / 2, position.dy + h / 2)
        ..close();
    } else {
      path
        ..moveTo(arrowCenter, position.dy + h / 2)
        ..lineTo(arrowCenter - w / 2, position.dy - h / 2)
        ..lineTo(arrowCenter + w / 2, position.dy - h / 2)
        ..close();
    }
  }

  @override
  bool shouldRepaint(covariant EFieldPainter oldDelegate) =>
      oldDelegate.data != data;
}
