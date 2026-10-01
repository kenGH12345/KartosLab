import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../assets/qwi_assets.dart';
import '../../constants/qwi_constants.dart';
import '../../data/ruler_data.dart';
import 'qwi_typography.dart';

/// Draggable Measuring Tape — scenery-phet MeasuringTapeNode semantics + original PNG.
///
/// Display-only: never mutates wavelength / slits / solver / probability.
class QwiMeasuringTapeOverlay extends StatefulWidget {
  const QwiMeasuringTapeOverlay({
    super.key,
    required this.state,
    required this.waveRect,
    required this.regionWidthM,
    required this.onChanged,
  });

  final MeasuringTapeState state;
  final Rect waveRect;

  /// Physical region width (meters) for μm/nm unit selection.
  final double regionWidthM;
  final VoidCallback onChanged;

  @override
  State<QwiMeasuringTapeOverlay> createState() => _QwiMeasuringTapeOverlayState();
}

class _QwiMeasuringTapeOverlayState extends State<QwiMeasuringTapeOverlay> {
  static const double _baseScale = 0.65;
  static const double _crosshair = 5;
  static const Color _crosshairColor = Color(0xFFE05F20);
  static const Color _lineColor = Color(0xFF555555);

  bool get _useNm => widget.regionWidthM < 1e-6;

  double get _multiplier =>
      widget.regionWidthM / QwiConstants.waveRegionWidth * (_useNm ? 1e9 : 1e6);

  Offset get _base => Offset(
        widget.waveRect.left + widget.state.startX * widget.waveRect.width,
        widget.waveRect.top + widget.state.startY * widget.waveRect.height,
      );

  Offset get _tip => Offset(
        widget.waveRect.left + widget.state.endX * widget.waveRect.width,
        widget.waveRect.top + widget.state.endY * widget.waveRect.height,
      );

  double get _pixelLength => (_tip - _base).distance;

  double get _measuredValue => _pixelLength * _multiplier;

  String get _unitLabel => _useNm ? 'nm' : 'μm';

  void _setBase(Offset global, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }
    final local = box.globalToLocal(global);
    widget.state.startX = ((local.dx - widget.waveRect.left) / widget.waveRect.width).clamp(0.0, 1.0);
    widget.state.startY = ((local.dy - widget.waveRect.top) / widget.waveRect.height).clamp(0.0, 1.0);
    widget.state.unitIsNanometer = _useNm;
    widget.onChanged();
  }

  void _setTip(Offset global, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }
    final local = box.globalToLocal(global);
    widget.state.endX = ((local.dx - widget.waveRect.left) / widget.waveRect.width).clamp(0.0, 1.0);
    widget.state.endY = ((local.dy - widget.waveRect.top) / widget.waveRect.height).clamp(0.0, 1.0);
    widget.state.unitIsNanometer = _useNm;
    widget.onChanged();
  }

  void _nudgeBody(Offset delta) {
    final dx = delta.dx / widget.waveRect.width;
    final dy = delta.dy / widget.waveRect.height;
    widget.state.startX = (widget.state.startX + dx).clamp(0.0, 1.0);
    widget.state.startY = (widget.state.startY + dy).clamp(0.0, 1.0);
    widget.state.endX = (widget.state.endX + dx).clamp(0.0, 1.0);
    widget.state.endY = (widget.state.endY + dy).clamp(0.0, 1.0);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.visible) {
      return const SizedBox.shrink();
    }
    final base = _base;
    final tip = _tip;
    final angle = math.atan2(tip.dy - base.dy, tip.dx - base.dx);
    final label = '${_measuredValue.toStringAsFixed(2)} $_unitLabel';

    return Stack(
      key: const Key('qwi_measuring_tape'),
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _TapeLinePainter(base: base, tip: tip, color: _lineColor),
          ),
        ),
        Positioned(
          left: (base.dx + tip.dx) / 2 - 36,
          top: (base.dy + tip.dy) / 2 - 28,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x99FFFFFF),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(label, style: QwiTypography.labelBold(12)),
          ),
        ),
        // Tape body image at base
        Positioned(
          left: base.dx - 18 * _baseScale,
          top: base.dy - 18 * _baseScale,
          child: Transform.rotate(
            angle: angle,
            alignment: Alignment.center,
            child: GestureDetector(
              key: const Key('qwi_tape_base'),
              onPanUpdate: (d) => _nudgeBody(d.delta),
              child: Image.asset(
                QwiAssets.measuringTape,
                width: 36 * _baseScale,
                height: 36 * _baseScale,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
        // Tip handle
        Positioned(
          left: tip.dx - 12,
          top: tip.dy - 12,
          width: 24,
          height: 24,
          child: GestureDetector(
            key: const Key('qwi_tape_tip'),
            onPanUpdate: (d) {
              final next = tip + d.delta;
              _setTip(
                (context.findRenderObject() as RenderBox).localToGlobal(next),
                context,
              );
            },
            child: CustomPaint(painter: _TipPainter(angle: angle)),
          ),
        ),
        // Base crosshair drag
        Positioned(
          left: base.dx - _crosshair,
          top: base.dy - _crosshair,
          width: _crosshair * 2,
          height: _crosshair * 2,
          child: GestureDetector(
            onPanUpdate: (d) {
              final next = base + d.delta;
              _setBase(
                (context.findRenderObject() as RenderBox).localToGlobal(next),
                context,
              );
            },
            child: CustomPaint(painter: _CrosshairPainter(color: _crosshairColor)),
          ),
        ),
      ],
    );
  }
}

class _TapeLinePainter extends CustomPainter {
  _TapeLinePainter({required this.base, required this.tip, required this.color});

  final Offset base;
  final Offset tip;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _TapeLinePainter oldDelegate) =>
      oldDelegate.base != base || oldDelegate.tip != tip;
}

class _CrosshairPainter extends CustomPainter {
  _CrosshairPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..color = color
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, c.dy), Offset(size.width, c.dy), p);
    canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, size.height), p);
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) => false;
}

class _TipPainter extends CustomPainter {
  _TipPainter({required this.angle});

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      8,
      Paint()
        ..color = const Color(0x66E05F20)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      c,
      8,
      Paint()
        ..color = const Color(0xFFE05F20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final p = Paint()
      ..color = const Color(0xFFE05F20)
      ..strokeWidth = 2;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    canvas.drawLine(const Offset(-5, 0), const Offset(5, 0), p);
    canvas.drawLine(const Offset(0, -5), const Offset(0, 5), p);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TipPainter oldDelegate) => oldDelegate.angle != angle;
}
