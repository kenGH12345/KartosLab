import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bending_light_constants.dart';
import '../model/bl_vec2.dart';
import '../model/prism_geometry.dart';
import '../model/wire_geometry.dart';
import '../phet_font.dart';
import '../transform/bl_mvt.dart';
import '../screens/stage_scale.dart';
import 'intensity_meter_widget.dart';
import 'prism_knob.dart';
import 'probe_glyph.dart';
import 'wave_view.dart';

/// Toolbox icon for `ProtractorNode` at scale 0.24.
class ProtractorToolboxIcon extends StatelessWidget {
  const ProtractorToolboxIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    return Image.asset(
      'assets/simulations/bending_light/protractor.png',
      width: 302 * 0.24 * view,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Toolbox copy of `IntensityMeterNode` at scale 0.45.
class IntensityToolboxIcon extends StatelessWidget {
  const IntensityToolboxIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntensityMeterGraphic(outerScale: 0.45);
  }
}

class IntensityMeterGraphic extends StatelessWidget {
  const IntensityMeterGraphic({super.key, this.outerScale = 1});

  final double outerScale;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    const bodyScale = 0.6;
    const bodyW = 150.0 * bodyScale;
    const bodyH = 95.0 * bodyScale;
    final probe = ProbeGlyph(color: const Color(0xFF008541), scale: 0.6 * view);
    final probeCenter = Offset(bodyW / 2 + 90, bodyH / 2 - 20) * view;
    final probeLeft = probeCenter.dx - probe.sensorOrigin.dx;
    final probeTop = probeCenter.dy - probe.sensorOrigin.dy;
    final unscaledW = math.max(bodyW * view, probeLeft + probe.width);
    final unscaledH = math.max(bodyH * view, probeTop + probe.height);
    return SizedBox(
      width: unscaledW * outerScale,
      height: unscaledH * outerScale,
      child: FittedBox(
        alignment: Alignment.topLeft,
        fit: BoxFit.fill,
        child: SizedBox(
          width: unscaledW,
          height: unscaledH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(probeCenter.dx + 8 * view, bodyH * view),
                painter: _IntensityWirePainter(
                  start: Offset(bodyW * view, (bodyH - 12) * view),
                  end: Offset(
                    probeCenter.dx,
                    probeCenter.dy + probe.centerBottomDy,
                  ),
                ),
              ),
              const Positioned(
                left: 0,
                top: 0,
                child: _IntensityBody(scale: bodyScale),
              ),
              Positioned(
                left: probeLeft,
                top: probeTop,
                child: probe,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntensityBody extends StatelessWidget {
  const _IntensityBody({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return IntensityMeterBody(scale: scale);
  }
}

/// Placed and toolbox `IntensityMeterNode` body. Unscaled size is 150×95.
class IntensityMeterBody extends StatelessWidget {
  const IntensityMeterBody({super.key, this.scale = 0.6, this.reading = '—'});

  final double scale;
  final String reading;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    final width = 150 * scale * view;
    final height = 95 * scale * view;
    return CustomPaint(
      size: Size(width, height),
      painter: _IntensityFacePainter(reading: reading, unit: scale * view),
    );
  }
}

class _IntensityFacePainter extends CustomPainter {
  const _IntensityFacePainter({this.reading = '—', this.unit = 1});

  final String reading;
  final double unit;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    canvas.save();
    canvas.scale(unit);
    const size = Size(150, 95);
    final outer = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(5));
    canvas.drawRRect(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF06974C), Color(0xFF00773A)],
          stops: [0, 0.6],
        ).createShader(Offset.zero & size),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF408260), Color(0xFF005127)],
        ).createShader(Offset.zero & size),
    );
    final inner = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width - 10,
      height: size.height - 10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(5)),
      Paint()..color = const Color(0xFF008541),
    );
    final value = Rect.fromLTWH((size.width - 120) / 2, 10, 120, 38);
    paintShadedRectangle(
      canvas,
      RRect.fromRectAndRadius(value, const Radius.circular(5)),
      base: const Color(0xFFFFFFFF),
      lightSourceRight: true,
      lightSourceBottom: true,
    );
    final title = TextPainter(
      text: TextSpan(text: 'Intensity', style: PhetFont.of(24, color: Colors.white)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 15);
    title.paint(canvas, Offset((size.width - title.width) / 2, inner.bottom - title.height - 3));
    final valueText = TextPainter(
      text: TextSpan(text: reading, style: PhetFont.of(25, color: Colors.black)),
      textDirection: TextDirection.ltr,
    )..layout();
    valueText.paint(
      canvas,
      Offset(value.center.dx - valueText.width / 2, value.center.dy - valueText.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IntensityFacePainter oldDelegate) =>
      oldDelegate.reading != reading || oldDelegate.unit != unit;
}

class _IntensityWirePainter extends CustomPainter {
  _IntensityWirePainter({required this.start, required this.end});

  final Offset start;
  final Offset end;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(start.dx + 25, start.dy, end.dx, end.dy - 25, end.dx, end.dy);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF808080),
    );
  }

  @override
  bool shouldRepaint(covariant _IntensityWirePainter oldDelegate) =>
      oldDelegate.start != start || oldDelegate.end != end;
}

/// Toolbox `VelocitySensorNode`: body scale 0.7, then node scale 1.2.
class VelocityToolboxIcon extends StatelessWidget {
  const VelocityToolboxIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const VelocitySensorGraphic(nodeScale: 1.2);
  }
}

class VelocitySensorGraphic extends StatelessWidget {
  const VelocitySensorGraphic({super.key, this.nodeScale = 1});

  final double nodeScale;

  static const double bodyScale = 0.7;

  /// `MoreToolsScreenView` placed `VelocitySensorNode` option `scale: 2`.
  /// Toolbox icons use [nodeScale] 1.2 instead. Do not mix them.
  static const double placedNodeScale = 2;

  @override
  Widget build(BuildContext context) {
    const w = 62.0 * bodyScale;
    const h = 37.0 * bodyScale;
    return SizedBox(
      width: w * nodeScale,
      height: h * nodeScale,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.fill,
        child: CustomPaint(
          size: const Size(w, h),
          painter: _VelocityBodyPainter(),
        ),
      ),
    );
  }
}

class _VelocityBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(0, 18.5 * VelocitySensorGraphic.bodyScale);
    canvas.scale(VelocitySensorGraphic.bodyScale);
    final triangle = Path()
      ..moveTo(0, 0)
      ..lineTo(8, -7.5)
      ..lineTo(8, 7.5)
      ..close();
    canvas.drawPath(triangle, Paint()..color = const Color(0xFFCF8702));
    canvas.drawPath(
      triangle,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF844702),
    );
    const bodyRect = Rect.fromLTWH(6, -18.5, 54, 37);
    final body = RRect.fromRectAndRadius(bodyRect, const Radius.circular(7.5));
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8B04E),
            Color(0xFFD4961C),
            Color(0xFFCF8702),
            Color(0xFFBA7902),
            Color(0xFF915E01),
          ],
          stops: [0, 0.1, 0.6, 0.9, 1],
        ).createShader(bodyRect),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF844702),
    );
    paintShadedRectangle(
      canvas,
      RRect.fromRectAndRadius(const Rect.fromLTWH(13.5, -15.5, 39, 14.5), const Radius.circular(3)),
      base: const Color(0xFFFFFFFF),
      lightSourceRight: true,
      lightSourceBottom: true,
    );
    final title = TextPainter(
      text: TextSpan(text: 'Speed', style: PhetFont.of(10)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 46);
    title.paint(canvas, Offset(33 - title.width / 2, 6));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Toolbox `WaveSensorNode` at scale 0.4.
class WaveToolboxIcon extends StatelessWidget {
  const WaveToolboxIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const WaveSensorGraphic(outerScale: 0.4);
  }
}

class WaveSensorGraphic extends StatelessWidget {
  const WaveSensorGraphic({super.key, this.outerScale = 1});

  final double outerScale;

  static const probe1 = ProbeGlyph(
    color: Color.fromARGB(255, 92, 93, 95),
    radius: 43,
    innerRadius: 32,
    handleWidth: 40,
    handleHeight: 30,
    handleCornerRadius: 9,
    scale: 0.35,
    crosshairs: true,
  );
  static const probe2 = ProbeGlyph(
    color: Color.fromARGB(255, 204, 206, 208),
    radius: 43,
    innerRadius: 32,
    handleWidth: 40,
    handleHeight: 30,
    handleCornerRadius: 9,
    scale: 0.35,
    crosshairs: true,
  );

  /// Two `WireNode` cubics in body-local coordinates. Body top-left is (0, 0).
  static List<CubicWire> wires() {
    const bodyW = 135.0 * 0.93;
    const bodyH = 100.0 * 0.93;
    final mvt = BlMvt.moreTools();
    const body = BlVec2(-0.0000172, -0.00000605);
    final p1 = mvt.modelToViewDelta(const BlVec2(-0.00001932, -0.0000052) - body);
    final p2 = mvt.modelToViewDelta(const BlVec2(-0.0000198, -0.0000062) - body);
    final center = Offset(bodyW / 2, bodyH / 2);
    final start = Offset(bodyW - 2, bodyH - (1 - 0.82) * bodyH);
    Offset end(Offset delta, ProbeGlyph probe) =>
        center + delta + Offset(0, probe.centerBottomDy);
    return [
      CubicWire.between(
        start: BlVec2(start.dx, start.dy),
        startNormal: CubicWire.bodyNormal,
        end: BlVec2(end(p1, probe1).dx, end(p1, probe1).dy),
        endNormal: CubicWire.sensorNormal,
      ),
      CubicWire.between(
        start: BlVec2(start.dx, start.dy),
        startNormal: CubicWire.bodyNormal,
        end: BlVec2(end(p2, probe2).dx, end(p2, probe2).dy),
        endNormal: CubicWire.sensorNormal,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const bodyW = 135.0 * 0.93;
    const bodyH = 100.0 * 0.93;
    final mvt = BlMvt.moreTools();
    const body = BlVec2(-0.0000172, -0.00000605);
    final p1 = mvt.modelToViewDelta(const BlVec2(-0.00001932, -0.0000052) - body);
    final p2 = mvt.modelToViewDelta(const BlVec2(-0.0000198, -0.0000062) - body);
    final center = Offset(bodyW / 2, bodyH / 2);
    final wires = WaveSensorGraphic.wires();
    final probes = [
      (center + p1, probe1),
      (center + p2, probe2),
    ];
    var minX = 0.0;
    var minY = 0.0;
    var maxX = bodyW;
    var maxY = bodyH;
    void grow(Offset p) {
      minX = math.min(minX, p.dx);
      minY = math.min(minY, p.dy);
      maxX = math.max(maxX, p.dx);
      maxY = math.max(maxY, p.dy);
    }
    for (final wire in wires) {
      grow(Offset(wire.start.x, wire.start.y));
      grow(Offset(wire.end.x, wire.end.y));
      grow(Offset(wire.control1.x, wire.control1.y));
      grow(Offset(wire.control2.x, wire.control2.y));
    }
    for (final item in probes) {
      final origin = item.$1 - item.$2.sensorOrigin;
      grow(origin);
      grow(origin + Offset(item.$2.width, item.$2.height));
    }
    final shift = Offset(-minX, -minY);
    final size = Size(maxX - minX, maxY - minY);
    Offset moved(Offset p) => p + shift;
    return SizedBox(
      width: size.width * outerScale,
      height: size.height * outerScale,
      child: FittedBox(
        alignment: Alignment.topLeft,
        fit: BoxFit.fill,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: shift.dx,
                top: shift.dy,
                width: bodyW,
                height: bodyH,
                child: const CustomPaint(painter: WaveSensorBodyPainter()),
              ),
              WaveWire(
                wire: _shiftWire(wires[0], shift),
                color: const Color.fromARGB(255, 88, 89, 91),
              ),
              WaveWire(
                wire: _shiftWire(wires[1], shift),
                color: const Color.fromARGB(255, 147, 149, 152),
              ),
              for (final item in probes)
                Positioned(
                  left: moved(item.$1 - item.$2.sensorOrigin).dx,
                  top: moved(item.$1 - item.$2.sensorOrigin).dy,
                  child: item.$2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

CubicWire _shiftWire(CubicWire wire, Offset shift) {
  BlVec2 move(BlVec2 p) => BlVec2(p.x + shift.dx, p.y + shift.dy);
  return CubicWire(move(wire.start), move(wire.control1), move(wire.control2), move(wire.end));
}

/// `PrismNode` icon. Prototype geometry through the prisms transform, height 55.
class PrismToolboxIcon extends StatelessWidget {
  const PrismToolboxIcon({
    super.key,
    required this.typeName,
    required this.fill,
  });

  final String typeName;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    final geo = prismIconGeometry(typeName);
    final knob = geo.knob;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: geo.size * view,
          painter: _PrismSourcePainter(geo, fill, view),
        ),
        if (knob != null)
          Positioned(
            left: knob.topLeft.dx * view,
            top: knob.topLeft.dy * view,
            width: knob.width * view,
            height: knob.height * view,
            child: Transform.rotate(
              angle: knob.angle,
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/simulations/bending_light/knob.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
      ],
    );
  }
}

class PrismIconGeometry {
  const PrismIconGeometry(
    this.path,
    this.size,
    this.rotationCenter,
    this.typeName, {
    this.knob,
  });

  final Path path;
  final Size size;
  final Offset rotationCenter;
  final String typeName;
  final PrismKnobPlacement? knob;
}

PrismIconGeometry prismIconGeometry(String typeName) {
  final mvt = BlMvt.prisms();
  final entry = PrismPrototypes.createAll().firstWhere((e) => e.$2 == typeName);
  final shape = entry.$1;
  final path = Path();
  if (shape is CircleShape) {
    final c = mvt.worldToScreen(shape.center);
    final r = shape.radius * mvt.scale;
    path.addOval(Rect.fromCircle(center: c, radius: r));
  } else if (shape is SemiCircleShape) {
    final r = shape.radius * mvt.scale;
    final a0 = mvt.worldToScreen(shape.points[0]);
    final a1 = mvt.worldToScreen(shape.points[1]);
    path
      ..moveTo(a0.dx, a0.dy)
      ..lineTo(a1.dx, a1.dy)
      ..arcToPoint(a0, radius: Radius.circular(r), clockwise: false)
      ..close();
  } else if (shape is PolygonShape) {
    final pts = [for (final p in shape.points) mvt.worldToScreen(p)];
    path.moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
  }
  final bounds = path.getBounds();
  final scale = bounds.height == 0 ? 1.0 : 55 / bounds.height;
  final shifted = path.shift(Offset(-bounds.left, -bounds.top));
  final scaled = shifted.transform(Matrix4.diagonal3Values(scale, scale, 1).storage);
  final center = mvt.worldToScreen(shape.getRotationCenter());
  final localCenter = Offset((center.dx - bounds.left) * scale, (center.dy - bounds.top) * scale);
  final reference = shape.getReferencePoint();
  PrismKnobPlacement? knob;
  if (reference != null) {
    final raw = placePrismKnob(
      reference: mvt.worldToScreen(reference),
      rotationCenter: center,
    );
    knob = PrismKnobPlacement(
      topLeft: Offset(
        (raw.topLeft.dx - bounds.left) * scale,
        (raw.topLeft.dy - bounds.top) * scale,
      ),
      width: raw.width * scale,
      height: raw.height * scale,
      angle: raw.angle,
    );
  }
  return PrismIconGeometry(
    scaled,
    Size(bounds.width * scale, 55),
    localCenter,
    typeName,
    knob: knob,
  );
}

class _PrismSourcePainter extends CustomPainter {
  _PrismSourcePainter(this.geo, this.fill, this.view);

  final PrismIconGeometry geo;
  final Color fill;
  final double view;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(view);
    canvas.drawPath(
      geo.path,
      Paint()..color = fill.withValues(alpha: BendingLightConstants.prismNodeAlpha),
    );
    canvas.drawPath(
      geo.path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF808080),
    );
    canvas.restore();
  }

  @override
  bool? hitTest(Offset position) {
    if (view == 0) return false;
    return geo.path.contains(position / view);
  }

  @override
  bool shouldRepaint(covariant _PrismSourcePainter oldDelegate) =>
      oldDelegate.geo.typeName != geo.typeName ||
      oldDelegate.fill != fill ||
      oldDelegate.view != view;
}
