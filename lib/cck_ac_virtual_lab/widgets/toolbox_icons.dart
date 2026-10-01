import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../cck_assets.dart';
import '../cck_colors.dart';
import '../cck_constants.dart';
import '../model/enums.dart';
import 'toolbox_catalog.dart';

/// Toolbox / view-radio glyphs. PNG items use extracted PhET assets.
class CckToolboxIcon extends StatelessWidget {
  const CckToolboxIcon({super.key, required this.spec, this.height = 28});

  final CckToolboxSpec spec;
  final double height;

  @override
  Widget build(BuildContext context) {
    final asset = _assetFor(spec);
    if (asset != null) {
      return Image.asset(
        asset,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    }
    return SizedBox(
      height: height,
      width: height * 1.8,
      child: CustomPaint(painter: _VectorIconPainter(spec.kind)),
    );
  }

  static String? _assetFor(CckToolboxSpec spec) {
    if (spec.kind == CckElementKind.battery) return CckAssets.battery;
    if (spec.kind == CckElementKind.lightBulb) return CckAssets.lightBulbMiddleIcon;
    if (spec.kind == CckElementKind.fuse) return CckAssets.fuse;
    if (spec.kind != CckElementKind.resistor) return null;
    return switch (spec.resistorKind) {
      CckResistorKind.coin => CckAssets.coin,
      CckResistorKind.paperClip => CckAssets.paperClip,
      CckResistorKind.pencil => CckAssets.pencil,
      CckResistorKind.thinPencil => CckAssets.thinPencil,
      CckResistorKind.eraser => CckAssets.eraser,
      CckResistorKind.dollarBill => CckAssets.dollar,
      CckResistorKind.resistor || null => CckAssets.resistor,
    };
  }
}

class _VectorIconPainter extends CustomPainter {
  _VectorIconPainter(this.kind);
  final CckElementKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case CckElementKind.wire:
        _wire(canvas, size);
      case CckElementKind.acSource:
        _ac(canvas, size);
      case CckElementKind.capacitor:
        _cap(canvas, size);
      case CckElementKind.inductor:
        _ind(canvas, size);
      case CckElementKind.switch_:
        _sw(canvas, size);
      default:
        _wire(canvas, size);
    }
  }

  void _wire(Canvas canvas, Size size) {
    final y = size.height / 2;
    final w = size.height * 0.45;
    final paint = Paint()
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        Offset(0, y - w / 2),
        Offset(0, y + w / 2),
        const [
          CckColors.wireStop0,
          CckColors.wireStop1,
          CckColors.wireStop2,
          CckColors.wireStop3,
        ],
        const [0, 0.2, 0.3, 1],
      );
    canvas.drawLine(Offset(4, y), Offset(size.width - 4, y), paint);
  }

  void _ac(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.height * 0.42;
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final sine = Path();
    var first = true;
    for (var x = 0.0; x < math.pi * 2; x += 0.12) {
      final px = c.dx + (x / math.pi - 1) * r * 0.7;
      final py = c.dy - math.sin(x) * r * 0.35;
      if (first) {
        sine.moveTo(px, py);
        first = false;
      } else {
        sine.lineTo(px, py);
      }
    }
    canvas.drawPath(
      sine,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _cap(Canvas canvas, Size size) {
    final y = size.height / 2;
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(2, y), Offset(size.width * 0.38, y), p);
    canvas.drawLine(Offset(size.width * 0.62, y), Offset(size.width - 2, y), p);
    canvas.drawLine(
      Offset(size.width * 0.38, 2),
      Offset(size.width * 0.38, size.height - 2),
      p,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, 2),
      Offset(size.width * 0.62, size.height - 2),
      p,
    );
  }

  void _ind(Canvas canvas, Size size) {
    final y = size.height / 2;
    final p = Paint()
      ..color = CckColors.inductorWire
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(2, y);
    const bumps = 4;
    final usable = size.width - 8;
    final r = usable / bumps / 2;
    path.lineTo(4, y);
    for (var i = 0; i < bumps; i++) {
      final cx = 4 + r * (2 * i + 1);
      path.arcTo(
        Rect.fromCircle(center: Offset(cx, y), radius: r),
        math.pi,
        -math.pi,
        false,
      );
    }
    path.lineTo(size.width - 2, y);
    canvas.drawPath(path, p);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
  }

  void _sw(Canvas canvas, Size size) {
    final y = size.height * 0.62;
    final p = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, y - 4),
        Offset(0, y + 4),
        const [CckColors.switchFill0, CckColors.switchFill2],
      )
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(3, y), Offset(size.width * 0.38, y), p);
    canvas.save();
    canvas.translate(size.width * 0.38, y);
    canvas.rotate(-math.pi / 4);
    canvas.drawLine(Offset.zero, Offset(size.width * 0.38, 0), p);
    canvas.restore();
    canvas.drawLine(Offset(size.width * 0.62, y), Offset(size.width - 3, y), p);
    canvas.drawCircle(Offset(size.width * 0.38, y), 3.2, Paint()..color = CckColors.switchHinge);
  }

  @override
  bool shouldRepaint(covariant _VectorIconPainter oldDelegate) =>
      oldDelegate.kind != kind;
}

class CckElectronBadge extends StatelessWidget {
  const CckElectronBadge({super.key, this.size = 14});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ElectronPainter(),
    );
  }
}

class _ElectronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 0.5;
    canvas.drawCircle(
      c,
      r + 0.4,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.drawCircle(
      c,
      r,
      Paint()..color = CckColors.electronBlue.withValues(alpha: 0.85),
    );
    canvas.drawLine(
      Offset(c.dx - r * 0.4, c.dy),
      Offset(c.dx + r * 0.4, c.dy),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CckConventionalArrowBadge extends StatelessWidget {
  const CckConventionalArrowBadge({super.key, this.size = 16});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 1.2, size),
      painter: _ArrowPainter(),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, size.height / 2)
      ..lineTo(0, 1)
      ..lineTo(0, size.height - 1)
      ..close();
    canvas.drawPath(path, Paint()..color = CckColors.conventionalArrowFill);
    canvas.drawPath(
      path,
      Paint()
        ..color = CckColors.conventionalArrowStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CckChartIcon extends StatelessWidget {
  const CckChartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF4A90C8),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: CustomPaint(painter: _MiniChartPainter()),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8F4FC),
    );
    final axis = Paint()
      ..color = Colors.black87
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(4, size.height - 4), Offset(size.width - 2, size.height - 4), axis);
    canvas.drawLine(Offset(4, 2), Offset(4, size.height - 4), axis);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CckSchematicBatteryIcon extends StatelessWidget {
  const CckSchematicBatteryIcon({super.key, this.height = 22});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height * 1.6,
      child: CustomPaint(painter: _SchematicBatteryPainter()),
    );
  }
}

class _SchematicBatteryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = CckConstants.schematicLineWidth / 2
      ..strokeCap = StrokeCap.square;
    final y = size.height / 2;
    canvas.drawLine(Offset(2, y), Offset(size.width * 0.38, y), p);
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.25),
      Offset(size.width * 0.38, size.height * 0.75),
      p,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, 2),
      Offset(size.width * 0.55, size.height - 2),
      p..strokeWidth = 2.2,
    );
    canvas.drawLine(Offset(size.width * 0.55, y), Offset(size.width - 2, y), p..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
