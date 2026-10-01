import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ba_colors.dart';
import '../../ba_mvt.dart';
import '../../ba_shared_constants.dart';
import '../../model/ba_enums.dart';
import '../../model/ba_vector2.dart';
import '../../model/plank.dart';

/// Procedural scene: sky/ground, fulcrum, columns, plank, attachment bar.
class BaBalanceScenePainter extends CustomPainter {
  BaBalanceScenePainter({
    required this.mvt,
    required this.plank,
    required this.columnState,
  });

  final BaModelViewTransform mvt;
  final Plank plank;
  final ColumnState columnState;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    if (columnState == ColumnState.doubleColumns) {
      _paintColumn(canvas, -BaGeometry.supportColumnX);
      _paintColumn(canvas, BaGeometry.supportColumnX);
    } else if (columnState == ColumnState.singleColumn) {
      _paintTiltedColumn(canvas);
    }
    _paintFulcrum(canvas);
    _paintAttachmentAndPlank(canvas);
  }

  /// Source: `TiltedSupportColumn` @ x=1.8, top angled at −maxTiltAngle.
  void _paintTiltedColumn(Canvas canvas) {
    const centerX = 1.8;
    const columnWidth = 0.35;
    final height = BaGeometry.plankHeight +
        centerX * math.tan(BaGeometry.maxTiltAngle);
    final topAngle = -BaGeometry.maxTiltAngle;
    final left = centerX - columnWidth / 2;
    final right = centerX + columnWidth / 2;
    final leftTopY = height - columnWidth / 2 * math.tan(-topAngle);
    final rightTopY = height + columnWidth / 2 * math.tan(-topAngle);
    final pts = <Offset>[
      mvt.modelToView(BaVector2(left, 0)),
      mvt.modelToView(BaVector2(left, leftTopY)),
      mvt.modelToView(BaVector2(right, rightTopY)),
      mvt.modelToView(BaVector2(right, 0)),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    final bounds = path.getBounds();
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          BaColors.column0,
          BaColors.column0,
          BaColors.column1,
          BaColors.column1,
          BaColors.column2,
          BaColors.column2,
          BaColors.column3,
          BaColors.column3,
        ],
        stops: const [0, 0.15, 0.16, 0.3, 0.31, 0.8, 0.81, 1],
      ).createShader(bounds);
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintBackground(Canvas canvas, Size size) {
    final groundY = mvt.modelToViewY(0);
    final skyRect = Rect.fromLTRB(0, 0, size.width, groundY);
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [BaColors.skyTop, BaColors.skyBottom],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    final groundRect = Rect.fromLTRB(0, groundY, size.width, size.height);
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [BaColors.groundTop, BaColors.groundBottom],
      ).createShader(groundRect);
    canvas.drawRect(groundRect, groundPaint);
  }

  void _paintFulcrum(Canvas canvas) {
    final w = BaGeometry.fulcrumWidth;
    final h = BaGeometry.fulcrumHeight;
    final leg = BaGeometry.legThicknessFactor * w;
    // Model shape from Fulcrum.ts (Y up). Convert each vertex.
    final pts = <Offset>[
      mvt.modelToView(BaVector2(-w / 2, 0)),
      mvt.modelToView(BaVector2(-leg * 0.67, h + leg / 2)),
      mvt.modelToView(BaVector2(leg * 0.67, h + leg / 2)),
      mvt.modelToView(BaVector2(w / 2, 0)),
      mvt.modelToView(BaVector2(w / 2 - leg, 0)),
      mvt.modelToView(BaVector2(0, h - leg * 0.2)),
      mvt.modelToView(BaVector2(-w / 2 + leg, 0)),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = BaColors.fulcrumFill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintColumn(Canvas canvas, double centerX) {
    final left = centerX - BaGeometry.supportColumnWidth / 2;
    final right = centerX + BaGeometry.supportColumnWidth / 2;
    final top = BaGeometry.plankHeight;
    final bottom = 0.0;
    final tl = mvt.modelToView(BaVector2(left, top));
    final br = mvt.modelToView(BaVector2(right, bottom));
    final rect = Rect.fromPoints(tl, br);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          BaColors.column0,
          BaColors.column0,
          BaColors.column1,
          BaColors.column1,
          BaColors.column2,
          BaColors.column2,
          BaColors.column3,
          BaColors.column3,
        ],
        stops: const [0, 0.15, 0.16, 0.3, 0.31, 0.8, 0.81, 1],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintAttachmentAndPlank(Canvas canvas) {
    final pivot = mvt.modelToView(plank.pivotPoint);
    final barWidth = 5 * 1.5; // PIVOT_RADIUS * 1.5 in view px

    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    // Model positive tilt = left tip; view Y inverted → rotate by -tilt
    canvas.rotate(-plank.tiltAngle);

    final barLen = (mvt.modelToViewY(BaGeometry.plankHeight) -
            mvt.modelToViewY(BaGeometry.fulcrumHeight))
        .abs();
    final barRect = Rect.fromCenter(
      center: Offset(0, barLen / 2),
      width: barWidth,
      height: barLen,
    );
    canvas.drawRect(
      barRect,
      Paint()..color = BaColors.attachmentBarFill,
    );
    canvas.drawRect(
      barRect,
      Paint()
        ..color = BaColors.attachmentBarStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final halfL = BaGeometry.plankLength / 2;
    final pLeft = mvt.modelToViewX(-halfL) - pivot.dx;
    final pRight = mvt.modelToViewX(halfL) - pivot.dx;
    final pTop = mvt.modelToViewY(
          BaGeometry.plankHeight + BaGeometry.plankThickness,
        ) -
        pivot.dy;
    final pBottom = mvt.modelToViewY(BaGeometry.plankHeight) - pivot.dy;
    final plankRect = Rect.fromLTRB(pLeft, pTop, pRight, pBottom);

    for (final dist in plank.activeDropPositions) {
      final x = mvt.modelToViewX(dist) - pivot.dx;
      final hl = Rect.fromCenter(
        center: Offset(x, (pTop + pBottom) / 2),
        width: 12,
        height: (pBottom - pTop).abs(),
      );
      canvas.drawRect(hl, Paint()..color = Colors.white);
    }

    canvas.drawRect(plankRect, Paint()..color = BaColors.plankFill);
    canvas.drawRect(
      plankRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final tickDelta =
        mvt.modelToViewDeltaX(BaGeometry.interSnapToMarkerDistance);
    final leftEdgeX = mvt.modelToViewX(-halfL) - pivot.dx;
    for (var i = 0; i < BaGeometry.numSnapToPositions; i++) {
      final x = leftEdgeX + (i + 1) * tickDelta;
      final stroke = i % 2 == 0 ? 3.0 : 1.0;
      canvas.drawLine(
        Offset(x, pTop),
        Offset(x, pBottom),
        Paint()
          ..color = Colors.black
          ..strokeWidth = stroke,
      );
    }

    canvas.restore();

    canvas.drawCircle(pivot, 5, Paint()..color = BaColors.pivotFill);
    canvas.drawCircle(
      pivot,
      5,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(pivot, 1, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant BaBalanceScenePainter oldDelegate) {
    return oldDelegate.plank.tiltAngle != plank.tiltAngle ||
        oldDelegate.columnState != columnState ||
        oldDelegate.plank.activeDropPositions.length !=
            plank.activeDropPositions.length ||
        oldDelegate.plank.bottomCenterPosition != plank.bottomCenterPosition;
  }
}

/// Level indicator triangles. Source: LevelIndicatorNode.ts
class BaLevelIndicatorPainter extends CustomPainter {
  BaLevelIndicatorPainter({
    required this.mvt,
    required this.plank,
    required this.visible,
  });

  final BaModelViewTransform mvt;
  final Plank plank;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final surfaceY = plank.getPlankSurfaceCenter().y;
    final left = mvt.modelToView(
      BaVector2(plank.pivotPoint.x - BaGeometry.plankLength / 2, surfaceY),
    );
    final right = mvt.modelToView(
      BaVector2(plank.pivotPoint.x + BaGeometry.plankLength / 2, surfaceY),
    );
    final level = plank.tiltAngle.abs() < 1e-4;
    final fill = level ? BaColors.levelFill : BaColors.nonLevelFill;

    void drawArrow(Offset tip, bool pointLeft) {
      final path = Path();
      if (pointLeft) {
        path
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - 25, tip.dy - 10)
          ..lineTo(tip.dx - 20, tip.dy)
          ..lineTo(tip.dx - 25, tip.dy + 10)
          ..close();
      } else {
        path
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + 25, tip.dy - 10)
          ..lineTo(tip.dx + 20, tip.dy)
          ..lineTo(tip.dx + 25, tip.dy + 10)
          ..close();
      }
      canvas.drawPath(path, Paint()..color = fill);
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    drawArrow(Offset(left.dx - 5, left.dy), true);
    drawArrow(Offset(right.dx + 5, right.dy), false);
  }

  @override
  bool shouldRepaint(covariant BaLevelIndicatorPainter oldDelegate) {
    return oldDelegate.visible != visible ||
        oldDelegate.plank.tiltAngle != plank.tiltAngle;
  }
}

/// Simple force arrows when enabled.
class BaForceVectorsPainter extends CustomPainter {
  BaForceVectorsPainter({
    required this.mvt,
    required this.plank,
    required this.visible,
  });

  final BaModelViewTransform mvt;
  final Plank plank;
  final bool visible;

  static const double _scale = 0.23; // PositionedVectorNode scaling factor

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    for (final fv in plank.forceVectors) {
      if (fv.isObfuscated) continue;
      final origin = mvt.modelToView(fv.origin);
      final tip = mvt.modelToView(
        BaVector2(
          fv.origin.x + fv.vector.x * _scale,
          fv.origin.y + fv.vector.y * _scale,
        ),
      );
      final paint = Paint()
        ..color = BaColors.forceArrow
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(origin, tip, paint);
      // Arrow head
      final angle = math.atan2(tip.dy - origin.dy, tip.dx - origin.dx);
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(
          tip.dx - 10 * math.cos(angle - 0.4),
          tip.dy - 10 * math.sin(angle - 0.4),
        )
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(
          tip.dx - 10 * math.cos(angle + 0.4),
          tip.dy - 10 * math.sin(angle + 0.4),
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BaForceVectorsPainter oldDelegate) {
    return oldDelegate.visible != visible ||
        oldDelegate.plank.forceVectors.length != plank.forceVectors.length ||
        oldDelegate.plank.tiltAngle != plank.tiltAngle;
  }
}
