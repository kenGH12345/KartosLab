import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/optics_solver.dart';
import '../models/optics_state.dart';

class OpticsScene extends StatelessWidget {
  const OpticsScene({
    super.key,
    required this.state,
    required this.solved,
    required this.onObjectMoved,
    required this.onStateChanged,
  });

  final OpticsState state;
  final SolvedOptics solved;
  final ValueChanged<double> onObjectMoved;
  final ValueChanged<OpticsState> onStateChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final projection = SceneProjection(size, state.zoom);
        final objectScreen = projection.toScreen(
          Offset(state.objectX, -state.objectHeight / 2),
        );
        final imageScreen = projection.toScreen(
          Offset(solved.imageX, -solved.imageHeight / 2),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: state.dragLocked
              ? null
              : (details) {
                  final world = projection.toWorld(details.localPosition);
                  onObjectMoved(world.dx);
                },
          child: Stack(
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: OpticsScenePainter(state: state, solved: solved),
                  ),
                ),
              ),
              _PencilOverlay(
                center: objectScreen,
                height: state.objectHeight * projection.scale,
                opacity: 1,
              ),
              if (!solved.isVirtual || state.showVirtualImage)
                _PencilOverlay(
                  center: imageScreen,
                  height: solved.imageHeight.abs() * projection.scale,
                  flipVertical: solved.imageHeight < 0,
                  opacity: solved.isVirtual ? 0.35 : 0.55,
                ),
              Positioned(
                left: 18,
                top: 16,
                child: _TopToolbar(state: state, onChanged: onStateChanged),
              ),
              Positioned(
                right: 18,
                top: 16,
                child: _ToolTray(state: state, onChanged: onStateChanged),
              ),
              Positioned(
                left: 18,
                bottom: 18,
                child: _ZoomButtons(state: state, onChanged: onStateChanged),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SceneProjection {
  SceneProjection(this.size, double zoom) : scale = _scaleFor(size, zoom);

  final Size size;
  final double scale;

  static double _scaleFor(Size size, double zoom) {
    final fit = math.min(size.width / 720, size.height / 420);
    return fit.clamp(0.75, 1.45) * zoom;
  }

  Offset get origin => Offset(size.width / 2, size.height * 0.55);

  Offset toScreen(Offset world) {
    return Offset(origin.dx + world.dx * scale, origin.dy + world.dy * scale);
  }

  Offset toWorld(Offset screen) {
    return Offset(
      (screen.dx - origin.dx) / scale,
      (screen.dy - origin.dy) / scale,
    );
  }
}

class OpticsScenePainter extends CustomPainter {
  const OpticsScenePainter({required this.state, required this.solved});

  final OpticsState state;
  final SolvedOptics solved;

  @override
  void paint(Canvas canvas, Size size) {
    final p = SceneProjection(size, state.zoom);
    final background = Paint()..color = const Color(0xFFF8FCFE);
    canvas.drawRect(Offset.zero & size, background);

    _drawAxis(canvas, p, size);
    if (state.showHorizontalRuler || state.showVerticalRuler) {
      _drawRulers(canvas, p);
    }
    _drawImagePlane(canvas, p);
    _drawElement(canvas, p);
    _drawFocalPoints(canvas, p);
    _drawRays(canvas, p, size);
    _drawObjectHandle(canvas, p);
    _drawSecondPoint(canvas, p);
    _drawLabels(canvas, p);
  }

  void _drawAxis(Canvas canvas, SceneProjection p, Size size) {
    final y = p.origin.dy;
    final paint = Paint()
      ..color = const Color(0xFF7A81CA)
      ..strokeWidth = 2;
    _drawDashedLine(
      canvas,
      Offset(0, y),
      Offset(size.width, y),
      paint,
      dash: 8,
    );
  }

  void _drawRulers(Canvas canvas, SceneProjection p) {
    final paint = Paint()
      ..color = const Color(0xFF6F7A27)
      ..strokeWidth = 1.2;
    final textStyle = const TextStyle(color: Color(0xFF48501D), fontSize: 10);
    if (state.showHorizontalRuler) {
      final a = p.toScreen(const Offset(-240, 74));
      final b = p.toScreen(const Offset(240, 74));
      final rect = Rect.fromLTRB(a.dx, a.dy, b.dx, a.dy + 24);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()..color = const Color(0xFFE5EC9A),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        paint..style = PaintingStyle.stroke,
      );
      paint.style = PaintingStyle.stroke;
      for (var x = -240; x <= 240; x += 20) {
        final top = p.toScreen(Offset(x.toDouble(), 74));
        canvas.drawLine(top, top + const Offset(0, 20), paint);
      }
      _paintText(canvas, '水平尺', rect.topLeft + const Offset(8, 5), textStyle);
    }
    if (state.showVerticalRuler) {
      final a = p.toScreen(const Offset(278, -115));
      final rect = Rect.fromLTWH(a.dx, a.dy, 26, 210 * p.scale);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()..color = const Color(0xFFE5EC9A),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        paint..style = PaintingStyle.stroke,
      );
      for (var y = -100; y <= 100; y += 20) {
        final left = p.toScreen(Offset(278, y.toDouble()));
        canvas.drawLine(left, left + const Offset(22, 0), paint);
      }
      _paintText(canvas, '竖尺', rect.topLeft + const Offset(4, 6), textStyle);
    }
  }

  void _drawImagePlane(Canvas canvas, SceneProjection p) {
    final canShow = !solved.isVirtual || state.showVirtualImage;
    if (!canShow) return;
    final x = solved.imageX.clamp(-330, 365);
    final top = p.toScreen(Offset(x.toDouble(), -58));
    final bottom = p.toScreen(Offset(x.toDouble(), 58));
    final frame = Rect.fromCenter(
      center: Offset(top.dx, (top.dy + bottom.dy) / 2),
      width: 44 * p.scale,
      height: 132 * p.scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, Radius.circular(2 * p.scale)),
      Paint()..color = const Color(0xFFB6DFF0).withValues(alpha: 0.36),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, Radius.circular(2 * p.scale)),
      Paint()
        ..color = const Color(0xFF7A8790).withValues(alpha: 0.52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawElement(Canvas canvas, SceneProjection p) {
    switch (state.mode) {
      case SimMode.lens:
        _drawLens(canvas, p);
      case SimMode.mirror:
        _drawMirror(canvas, p);
    }
  }

  void _drawLens(Canvas canvas, SceneProjection p) {
    final half = state.diameter / 2;
    final top = p.toScreen(Offset(0, -half));
    final bottom = p.toScreen(Offset(0, half));
    final width = state.lensKind == LensKind.convex
        ? 32 * p.scale
        : 38 * p.scale;
    final path = Path();
    if (state.lensKind == LensKind.convex) {
      path
        ..moveTo(top.dx, top.dy)
        ..cubicTo(
          top.dx + width,
          top.dy + 28 * p.scale,
          bottom.dx + width,
          bottom.dy - 28 * p.scale,
          bottom.dx,
          bottom.dy,
        )
        ..cubicTo(
          bottom.dx - width,
          bottom.dy - 28 * p.scale,
          top.dx - width,
          top.dy + 28 * p.scale,
          top.dx,
          top.dy,
        )
        ..close();
    } else {
      path
        ..moveTo(top.dx - width / 2, top.dy)
        ..cubicTo(
          top.dx + width / 3,
          top.dy + 26 * p.scale,
          top.dx + width / 3,
          bottom.dy - 26 * p.scale,
          bottom.dx - width / 2,
          bottom.dy,
        )
        ..lineTo(bottom.dx + width / 2, bottom.dy)
        ..cubicTo(
          top.dx - width / 3,
          bottom.dy - 26 * p.scale,
          top.dx - width / 3,
          top.dy + 26 * p.scale,
          top.dx + width / 2,
          top.dy,
        )
        ..close();
    }
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF7E86DE).withValues(alpha: 0.72),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF172554)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawMirror(Canvas canvas, SceneProjection p) {
    final half = state.diameter / 2;
    final top = p.toScreen(Offset(0, -half));
    final bottom = p.toScreen(Offset(0, half));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7
      ..color = const Color(0xFF1D4ED8);
    final backing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 11
      ..color = const Color(0xFFCBD5E1);
    final path = Path();
    switch (state.mirrorKind) {
      case MirrorKind.concave:
        path
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(
            top.dx + 26 * p.scale,
            p.origin.dy,
            bottom.dx,
            bottom.dy,
          );
      case MirrorKind.convex:
        path
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(
            top.dx - 26 * p.scale,
            p.origin.dy,
            bottom.dx,
            bottom.dy,
          );
      case MirrorKind.plane:
        path
          ..moveTo(top.dx, top.dy)
          ..lineTo(bottom.dx, bottom.dy);
    }
    canvas.drawPath(path, backing);
    canvas.drawPath(path, paint);
  }

  void _drawFocalPoints(Canvas canvas, SceneProjection p) {
    if (!state.showFocalPoints) return;
    final f = solved.focalLength;
    if (f.isFinite) {
      final positions = state.mode == SimMode.lens ? [-f, f] : [-f, f];
      for (final x in positions) {
        final center = p.toScreen(Offset(x.clamp(-380, 380).toDouble(), 0));
        _drawPoint(canvas, center, const Color(0xFFE9F438), 'F');
      }
    }
  }

  void _drawRays(Canvas canvas, SceneProjection p, Size size) {
    final rayPaint = Paint()
      ..color = const Color(0xFF071827)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final boundaryPaint = Paint()
      ..color = const Color(0xFF071827)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final virtualPaint = Paint()
      ..color = const Color(0xFF071827).withValues(alpha: 0.48)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;

    for (final ray in solved.rays) {
      final points = ray.points.map(p.toScreen).toList();
      final paint = ray.isBoundary ? boundaryPaint : rayPaint;
      for (var i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
      if (ray.virtualPoints.length > 1) {
        final virtual = ray.virtualPoints.map(p.toScreen).toList();
        for (var i = 0; i < virtual.length - 1; i++) {
          _drawDashedLine(canvas, virtual[i], virtual[i + 1], virtualPaint);
        }
      }
    }
  }

  void _drawObjectHandle(Canvas canvas, SceneProjection p) {
    final c = p.toScreen(Offset(state.objectX - 42, 0));
    final paint = Paint()
      ..color = state.dragLocked
          ? const Color(0xFF64748B)
          : const Color(0xFF22C55E)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c + const Offset(-16, 0), c + const Offset(16, 0), paint);
    canvas.drawLine(c + const Offset(0, -16), c + const Offset(0, 16), paint);
    canvas.drawCircle(c, 7, Paint()..color = Colors.white);
    canvas.drawCircle(c, 7, paint..style = PaintingStyle.stroke);
    paint.style = PaintingStyle.fill;
  }

  void _drawSecondPoint(Canvas canvas, SceneProjection p) {
    if (!state.showSecondPoint) return;
    final object = p.toScreen(
      Offset(state.objectX, -state.objectHeight * 0.65),
    );
    final image = p.toScreen(Offset(solved.imageX, -solved.imageHeight * 0.65));
    _drawPoint(canvas, object, const Color(0xFFE95737), '');
    if (!solved.isVirtual || state.showVirtualImage) {
      _drawPoint(canvas, image, const Color(0xFFE95737), '');
    }
  }

  void _drawLabels(Canvas canvas, SceneProjection p) {
    if (!state.showLabels) return;
    final style = const TextStyle(
      color: Color(0xFF123447),
      fontWeight: FontWeight.w700,
      fontSize: 13,
    );
    _paintText(
      canvas,
      '物体',
      p.toScreen(Offset(state.objectX - 26, -state.objectHeight - 28)),
      style,
    );
    if (!solved.isVirtual || state.showVirtualImage) {
      _paintText(
        canvas,
        solved.isVirtual ? '虚像' : '实像',
        p.toScreen(Offset(solved.imageX + 18, -solved.imageHeight - 18)),
        style,
      );
    }
    _paintText(
      canvas,
      state.mode.label,
      p.toScreen(const Offset(12, 56)),
      style,
    );
  }

  void _drawPoint(Canvas canvas, Offset center, Color color, String label) {
    canvas.drawCircle(center, 9, Paint()..color = color);
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..color = const Color(0xFF102033)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (label.isNotEmpty) {
      _paintText(
        canvas,
        label,
        center + const Offset(12, -18),
        const TextStyle(
          color: Color(0xFF102033),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  void _paintText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dash = 7,
    double gap = 6,
  }) {
    final delta = end - start;
    final distance = delta.distance;
    if (distance == 0) return;
    final direction = delta / distance;
    var drawn = 0.0;
    while (drawn < distance) {
      final segmentEnd = math.min(drawn + dash, distance);
      canvas.drawLine(
        start + direction * drawn,
        start + direction * segmentEnd,
        paint,
      );
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant OpticsScenePainter oldDelegate) {
    return oldDelegate.state != state || oldDelegate.solved != solved;
  }
}

class _PencilOverlay extends StatelessWidget {
  const _PencilOverlay({
    required this.center,
    required this.height,
    required this.opacity,
    this.flipVertical = false,
  });

  final Offset center;
  final double height;
  final double opacity;
  final bool flipVertical;

  @override
  Widget build(BuildContext context) {
    final clampedHeight = height.abs().clamp(34.0, 130.0);
    final width = clampedHeight * 0.27;
    return Positioned(
      left: center.dx - width / 2,
      top: center.dy - clampedHeight / 2,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scaleY: flipVertical ? -1 : 1,
              child: SvgPicture.asset(
                'assets/images/pencil.svg',
                width: width,
                height: clampedHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopToolbar extends StatelessWidget {
  const _TopToolbar({required this.state, required this.onChanged});

  final OpticsState state;
  final ValueChanged<OpticsState> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: ExcludeSemantics(
            child: SvgPicture.asset('assets/images/pencil.svg', width: 14),
          ),
          label: const Text('铅笔'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: () =>
              onChanged(state.copyWith(dragLocked: !state.dragLocked)),
          icon: Icon(
            state.dragLocked ? Icons.lock_rounded : Icons.open_with_rounded,
          ),
        ),
        if (state.mode == SimMode.lens)
          SegmentedButton<LensKind>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: LensKind.convex,
                icon: ExcludeSemantics(
                  child: SvgPicture.asset(
                    'assets/images/lens_convex.svg',
                    width: 20,
                  ),
                ),
                label: const Text('凸'),
              ),
              ButtonSegment(
                value: LensKind.concave,
                icon: ExcludeSemantics(
                  child: SvgPicture.asset(
                    'assets/images/lens_concave.svg',
                    width: 20,
                  ),
                ),
                label: const Text('凹'),
              ),
            ],
            selected: {state.lensKind},
            onSelectionChanged: (value) =>
                onChanged(state.copyWith(lensKind: value.first)),
          )
        else
          SegmentedButton<MirrorKind>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: MirrorKind.concave,
                icon: Icon(Icons.keyboard_arrow_right_rounded),
                label: Text('凹'),
              ),
              ButtonSegment(
                value: MirrorKind.convex,
                icon: Icon(Icons.keyboard_arrow_left_rounded),
                label: Text('凸'),
              ),
              ButtonSegment(
                value: MirrorKind.plane,
                icon: Icon(Icons.vertical_align_center_rounded),
                label: Text('平'),
              ),
            ],
            selected: {state.mirrorKind},
            onSelectionChanged: (value) =>
                onChanged(state.copyWith(mirrorKind: value.first)),
          ),
      ],
    );
  }
}

class _ToolTray extends StatelessWidget {
  const _ToolTray({required this.state, required this.onChanged});

  final OpticsState state;
  final ValueChanged<OpticsState> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        border: Border.all(color: const Color(0xFF90A4AE)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AssetToggle(
              semanticLabel: '水平尺',
              asset: 'assets/images/ruler.svg',
              selected: state.showHorizontalRuler,
              onPressed: () => onChanged(
                state.copyWith(showHorizontalRuler: !state.showHorizontalRuler),
              ),
            ),
            _AssetToggle(
              semanticLabel: '竖尺',
              asset: 'assets/images/ruler.svg',
              rotateQuarterTurns: 1,
              selected: state.showVerticalRuler,
              onPressed: () => onChanged(
                state.copyWith(showVerticalRuler: !state.showVerticalRuler),
              ),
            ),
            _AssetToggle(
              semanticLabel: '第二个物点',
              asset: 'assets/images/drop.svg',
              selected: state.showSecondPoint,
              onPressed: () => onChanged(
                state.copyWith(showSecondPoint: !state.showSecondPoint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetToggle extends StatelessWidget {
  const _AssetToggle({
    required this.semanticLabel,
    required this.asset,
    required this.selected,
    required this.onPressed,
    this.rotateQuarterTurns = 0,
  });

  final String semanticLabel;
  final String asset;
  final bool selected;
  final VoidCallback onPressed;
  final int rotateQuarterTurns;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      selected: selected,
      child: IconButton(
        isSelected: selected,
        selectedIcon: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFFE082),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ExcludeSemantics(
              child: RotatedBox(
                quarterTurns: rotateQuarterTurns,
                child: SvgPicture.asset(asset, width: 30, height: 30),
              ),
            ),
          ),
        ),
        icon: ExcludeSemantics(
          child: RotatedBox(
            quarterTurns: rotateQuarterTurns,
            child: SvgPicture.asset(asset, width: 30, height: 30),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons({required this.state, required this.onChanged});

  final OpticsState state;
  final ValueChanged<OpticsState> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          onPressed: state.zoom >= 1.3
              ? null
              : () => onChanged(state.copyWith(zoom: state.zoom + 0.1)),
          icon: const Icon(Icons.zoom_in_rounded),
        ),
        const SizedBox(height: 8),
        IconButton.filledTonal(
          onPressed: state.zoom <= 0.8
              ? null
              : () => onChanged(state.copyWith(zoom: state.zoom - 0.1)),
          icon: const Icon(Icons.zoom_out_rounded),
        ),
      ],
    );
  }
}
