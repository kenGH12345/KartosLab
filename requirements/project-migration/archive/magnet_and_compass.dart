// Magnet & Compass Simulation
// Migrated from lib/src/phet/magnet_and_compass/lib/main.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────
//  Simulation State
// ─────────────────────────────────────────────
class SimState {
  Offset magnetPos;
  double magnetAngle;
  double strength;
  bool flipped;
  bool showField;
  bool seeInside;
  bool earthField;
  bool showCompass;
  bool showFieldMeter;
  Offset compassPos;
  double compassAngle;
  Offset fieldMeterPos;

  SimState({
    required this.magnetPos,
    required this.magnetAngle,
    required this.strength,
    required this.flipped,
    required this.showField,
    required this.seeInside,
    required this.earthField,
    required this.showCompass,
    required this.showFieldMeter,
    required this.compassPos,
    required this.compassAngle,
    required this.fieldMeterPos,
  });

  SimState copyWith({
    Offset? magnetPos,
    double? magnetAngle,
    double? strength,
    bool? flipped,
    bool? showField,
    bool? seeInside,
    bool? earthField,
    bool? showCompass,
    bool? showFieldMeter,
    Offset? compassPos,
    double? compassAngle,
    Offset? fieldMeterPos,
  }) => SimState(
    magnetPos: magnetPos ?? this.magnetPos,
    magnetAngle: magnetAngle ?? this.magnetAngle,
    strength: strength ?? this.strength,
    flipped: flipped ?? this.flipped,
    showField: showField ?? this.showField,
    seeInside: seeInside ?? this.seeInside,
    earthField: earthField ?? this.earthField,
    showCompass: showCompass ?? this.showCompass,
    showFieldMeter: showFieldMeter ?? this.showFieldMeter,
    compassPos: compassPos ?? this.compassPos,
    compassAngle: compassAngle ?? this.compassAngle,
    fieldMeterPos: fieldMeterPos ?? this.fieldMeterPos,
  );
}

// ─────────────────────────────────────────────
//  Magnetic Field Calculation
// ─────────────────────────────────────────────
class MagneticField {
  static Offset compute(
    Offset p,
    Offset magnetPos,
    double angle,
    double halfLen,
    double strength,
    bool flipped,
    bool earthField,
  ) {
    if (earthField) {
      final sign = flipped ? 1.0 : -1.0;
      final earthHalfLen = halfLen * 0.65;
      final nPole = Offset(magnetPos.dx, magnetPos.dy + sign * earthHalfLen);
      final sPole = Offset(magnetPos.dx, magnetPos.dy - sign * earthHalfLen);
      final k = strength * 18000.0;

      final rN = p - nPole;
      final distN2 = (rN.dx * rN.dx + rN.dy * rN.dy).clamp(1.0, double.infinity);
      final distN = sqrt(distN2);
      final bN = Offset(rN.dx / (distN2 * distN), rN.dy / (distN2 * distN));

      final rS = p - sPole;
      final distS2 = (rS.dx * rS.dx + rS.dy * rS.dy).clamp(1.0, double.infinity);
      final distS = sqrt(distS2);
      final bS = Offset(-rS.dx / (distS2 * distS), -rS.dy / (distS2 * distS));

      return Offset((bN.dx + bS.dx) * k, (bN.dy + bS.dy) * k);
    }

    final sign = flipped ? -1.0 : 1.0;
    final nPole = Offset(
      magnetPos.dx + cos(angle) * halfLen * sign,
      magnetPos.dy + sin(angle) * halfLen * sign,
    );
    final sPole = Offset(
      magnetPos.dx - cos(angle) * halfLen * sign,
      magnetPos.dy - sin(angle) * halfLen * sign,
    );
    final k = strength * 18000.0;

    final rN = p - nPole;
    final distN2 = (rN.dx * rN.dx + rN.dy * rN.dy).clamp(1.0, double.infinity);
    final distN = sqrt(distN2);
    final bN = Offset(rN.dx / (distN2 * distN), rN.dy / (distN2 * distN));

    final rS = p - sPole;
    final distS2 = (rS.dx * rS.dx + rS.dy * rS.dy).clamp(1.0, double.infinity);
    final distS = sqrt(distS2);
    final bS = Offset(-rS.dx / (distS2 * distS), -rS.dy / (distS2 * distS));

    return Offset((bN.dx + bS.dx) * k, (bN.dy + bS.dy) * k);
  }

  static double magnitude(Offset b) => sqrt(b.dx * b.dx + b.dy * b.dy);
  static double fieldAngle(Offset b) => atan2(b.dy, b.dx);
}

// ─────────────────────────────────────────────
//  Simulation Page (public entry point)
// ─────────────────────────────────────────────
class MagnetAndCompassPage extends StatefulWidget {
  const MagnetAndCompassPage({super.key});
  @override
  State<MagnetAndCompassPage> createState() => _MagnetAndCompassPageState();
}

class _MagnetAndCompassPageState extends State<MagnetAndCompassPage>
    with TickerProviderStateMixin {
  late SimState _state;

  static const double _magnetW = 500.0;
  static const double _magnetH = 128.0;
  static const double _earthR = 180.0;
  static const double _compassR = 76.0;

  late AnimationController _compassCtrl;
  double _compassVelocity = 0.0;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _state = SimState(
      magnetPos: Offset.zero,
      magnetAngle: 0,
      strength: 0.75,
      flipped: false,
      showField: true,
      seeInside: false,
      earthField: false,
      showCompass: true,
      showFieldMeter: false,
      compassPos: Offset.zero,
      compassAngle: 0,
      fieldMeterPos: Offset.zero,
    );
    _compassCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..addListener(_tickCompass)
          ..repeat();
  }

  void _initPositions(Size s) {
    if (_initialized) return;
    _initialized = true;
    setState(() {
      _state = _state.copyWith(
        magnetPos: Offset(s.width * 0.42, s.height * 0.50),
        compassPos: Offset(s.width * 0.60, s.height * 0.66),
        fieldMeterPos: Offset(s.width * 0.28, s.height * 0.30),
      );
    });
  }

  void _tickCompass() {
    if (!mounted) return;
    final b = MagneticField.compute(
      _state.compassPos,
      _state.magnetPos,
      _state.magnetAngle,
      _magnetW / 2,
      _state.strength,
      _state.flipped,
      _state.earthField,
    );
    final target = MagneticField.fieldAngle(b);
    double diff = target - _state.compassAngle;
    while (diff > pi) {
      diff -= 2 * pi;
    }
    while (diff < -pi) {
      diff += 2 * pi;
    }
    _compassVelocity = _compassVelocity * 0.85 + diff * 0.08;
    setState(() {
      _state = _state.copyWith(
        compassAngle: _state.compassAngle + _compassVelocity,
      );
    });
  }

  @override
  void dispose() {
    _compassCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    if (!mounted) return;
    final s = MediaQuery.of(context).size;
    setState(() {
      _compassVelocity = 0;
      _state = SimState(
        magnetPos: Offset(s.width * 0.42, s.height * 0.50),
        magnetAngle: 0,
        strength: 0.75,
        flipped: false,
        showField: true,
        seeInside: false,
        earthField: false,
        showCompass: true,
        showFieldMeter: false,
        compassPos: Offset(s.width * 0.60, s.height * 0.66),
        compassAngle: 0,
        fieldMeterPos: Offset(s.width * 0.28, s.height * 0.30),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPositions(size));

    return Scaffold(
      backgroundColor: const Color.fromARGB(93, 0, 0, 0),
      body: Stack(
        children: [
          if (_state.showField)
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: FieldNeedlePainter(
                    magnetPos: _state.magnetPos,
                    magnetAngle: _state.magnetAngle,
                    strength: _state.strength,
                    flipped: _state.flipped,
                    earthField: _state.earthField,
                    magnetW: _magnetW,
                    magnetH: _magnetH,
                    skipCircle: _state.earthField,
                    circleCenter: _state.magnetPos,
                    circleRadius: _earthR,
                  ),
                ),
              ),
            ),

          if (_state.earthField) _buildEarth(size) else _buildMagnet(size),

          if (_state.showCompass) _buildCompass(size),

          if (_state.showFieldMeter) _buildFieldMeter(size),

          Positioned(
            top: 12,
            right: 12,
            child: _ControlPanel(
              state: _state,
              onStrengthChanged: (v) =>
                  setState(() => _state = _state.copyWith(strength: v)),
              onStrengthStep: (d) {
                final nv = (_state.strength + d).clamp(0.0, 1.0);
                setState(() => _state = _state.copyWith(strength: nv));
              },
              onShowFieldChanged: (v) =>
                  setState(() => _state = _state.copyWith(showField: v)),
              onSeeInsideChanged: (v) =>
                  setState(() => _state = _state.copyWith(seeInside: v)),
              onEarthFieldChanged: (v) =>
                  setState(() => _state = _state.copyWith(earthField: v)),
              onFlipPolarity: () => setState(
                () => _state = _state.copyWith(flipped: !_state.flipped),
              ),
              onShowCompassChanged: (v) =>
                  setState(() => _state = _state.copyWith(showCompass: v)),
              onShowFieldMeterChanged: (v) =>
                  setState(() => _state = _state.copyWith(showFieldMeter: v)),
            ),
          ),

          // Back button (top-left)
          Positioned(
            top: 12,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),

          Positioned(
            right: 18,
            bottom: 18,
            child: GestureDetector(
              onTap: _reset,
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffe65100),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                ),
                child: const Icon(Icons.refresh, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagnet(Size screenSize) {
    final cx = _state.magnetPos.dx;
    final cy = _state.magnetPos.dy;
    return Positioned(
      left: cx - _magnetW / 2,
      top: cy - _magnetH / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          final cur = _state.magnetPos;
          final nx = (cur.dx + d.delta.dx).clamp(_magnetW / 2, screenSize.width - _magnetW / 2);
          final ny = (cur.dy + d.delta.dy).clamp(_magnetH / 2, screenSize.height - _magnetH / 2);
          setState(() => _state = _state.copyWith(magnetPos: Offset(nx, ny)));
        },
        child: Transform.rotate(
          angle: _state.magnetAngle,
          child: SizedBox(
            width: _magnetW,
            height: _magnetH,
            child: CustomPaint(
              painter: BarMagnetPainter(
                seeInside: _state.seeInside,
                flipped: _state.flipped,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarth(Size screenSize) {
    const r = _earthR;
    const diameter = r * 2;
    final cx = _state.magnetPos.dx;
    final cy = _state.magnetPos.dy;
    const mW = 28.0;
    const mH = r * 1.1;

    return Positioned(
      left: cx - r,
      top: cy - r,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          final cur = _state.magnetPos;
          final nx = (cur.dx + d.delta.dx).clamp(r, screenSize.width - r);
          final ny = (cur.dy + d.delta.dy).clamp(r, screenSize.height - r);
          setState(() => _state = _state.copyWith(magnetPos: Offset(nx, ny)));
        },
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: SvgPicture.asset(
                  'assets/earth.svg',
                  width: diameter,
                  height: diameter,
                  fit: BoxFit.cover,
                ),
              ),
              CustomPaint(
                size: const Size(diameter, diameter),
                painter: _EarthGlowPainter(),
              ),
              SizedBox(
                width: mW,
                height: mH,
                child: CustomPaint(
                  painter: _VerticalMagnetPainter(flipped: _state.flipped),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(Size screenSize) {
    const r = _compassR;
    final cx = _state.compassPos.dx;
    final cy = _state.compassPos.dy;
    return Positioned(
      left: cx - r,
      top: cy - r,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          final cur = _state.compassPos;
          final nx = (cur.dx + d.delta.dx).clamp(r, screenSize.width - r);
          final ny = (cur.dy + d.delta.dy).clamp(r, screenSize.height - r);
          setState(() => _state = _state.copyWith(compassPos: Offset(nx, ny)));
        },
        child: SizedBox(
          width: r * 2,
          height: r * 2,
          child: CustomPaint(
            painter: CompassPainter(needleAngle: _state.compassAngle),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldMeter(Size screenSize) {
    const w = 260.0, h = 192.0;
    final b = MagneticField.compute(
      _state.fieldMeterPos,
      _state.magnetPos,
      _state.magnetAngle,
      _magnetW / 2,
      _state.strength,
      _state.flipped,
      _state.earthField,
    );
    final mag = MagneticField.magnitude(b);
    final deg = MagneticField.fieldAngle(b) * 180 / pi;
    final cx = _state.fieldMeterPos.dx;
    final cy = _state.fieldMeterPos.dy;

    return Positioned(
      left: cx - w / 2,
      top: cy - h / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          final cur = _state.fieldMeterPos;
          final nx = (cur.dx + d.delta.dx).clamp(w / 2, screenSize.width - w / 2);
          final ny = (cur.dy + d.delta.dy).clamp(h / 2, screenSize.height - h / 2);
          setState(() => _state = _state.copyWith(fieldMeterPos: Offset(nx, ny)));
        },
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xff0d2255).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.lightBlueAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.lightBlueAccent.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'B = ${mag.toStringAsFixed(3)} T',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'θ = ${deg.toStringAsFixed(1)}°',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                'Bx= ${b.dx.toStringAsFixed(3)}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Text(
                'By= ${b.dy.toStringAsFixed(3)}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const Spacer(),
              const Icon(Icons.gps_fixed, color: Colors.lightBlueAccent, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Earth Glow Painter
// ─────────────────────────────────────────────
class _EarthGlowPainter extends CustomPainter {
  const _EarthGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy);
    final c = Offset(cx, cy);

    canvas.drawCircle(c, r - 1,
      Paint()..color = const Color(0xff607d8b)..style = PaintingStyle.stroke..strokeWidth = 3.0);
    canvas.drawCircle(c, r - 2,
      Paint()..shader = RadialGradient(
        center: const Alignment(-0.45, -0.50),
        radius: 0.65,
        colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: r)));
  }

  @override
  bool shouldRepaint(_EarthGlowPainter o) => false;
}

// ─────────────────────────────────────────────
//  Vertical Magnet Painter
// ─────────────────────────────────────────────
class _VerticalMagnetPainter extends CustomPainter {
  final bool flipped;
  const _VerticalMagnetPainter({required this.flipped});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const r = 7.0;

    final topColor = flipped ? const Color(0xffe53935) : const Color(0xff3949ab);
    final botColor = flipped ? const Color(0xff3949ab) : const Color(0xffe53935);
    final topLabel = flipped ? 'N' : 'S';
    final botLabel = flipped ? 'S' : 'N';

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(3, 4, w - 2, h - 2), const Radius.circular(r)),
      Paint()..color = Colors.black54..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(0, 0, w, h / 2,
        topLeft: const Radius.circular(r), topRight: const Radius.circular(r)),
      Paint()..shader = LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        colors: [Color.lerp(topColor, Colors.black, 0.25)!, Color.lerp(topColor, Colors.white, 0.28)!, Color.lerp(topColor, Colors.black, 0.25)!],
      ).createShader(Rect.fromLTWH(0, 0, w, h / 2)));

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(0, h / 2, w, h,
        bottomLeft: const Radius.circular(r), bottomRight: const Radius.circular(r)),
      Paint()..shader = LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        colors: [Color.lerp(botColor, Colors.black, 0.25)!, Color.lerp(botColor, Colors.white, 0.28)!, Color.lerp(botColor, Colors.black, 0.25)!],
      ).createShader(Rect.fromLTWH(0, h / 2, w, h / 2)));

    canvas.drawLine(Offset(2, h / 2), Offset(w - 2, h / 2),
      Paint()..color = Colors.black45..strokeWidth = 1.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, 4), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.22));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(r)),
      Paint()..color = Colors.white30..style = PaintingStyle.stroke..strokeWidth = 1.2);

    _label(canvas, topLabel, Offset(w / 2, h * 0.25), 11);
    _label(canvas, botLabel, Offset(w / 2, h * 0.75), 11);
  }

  void _label(Canvas canvas, String t, Offset c, double fs) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: Colors.white, fontSize: fs, fontWeight: FontWeight.w900, shadows: const [Shadow(color: Colors.black54, blurRadius: 3)])),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_VerticalMagnetPainter o) => o.flipped != flipped;
}

// ─────────────────────────────────────────────
//  Bar Magnet Painter
// ─────────────────────────────────────────────
class BarMagnetPainter extends CustomPainter {
  final bool seeInside;
  final bool flipped;
  const BarMagnetPainter({required this.seeInside, required this.flipped});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const r = 14.0;

    final sColor = flipped ? const Color(0xffe53935) : const Color(0xff3949ab);
    final nColor = flipped ? const Color(0xff3949ab) : const Color(0xffe53935);
    final sLabel = flipped ? 'N' : 'S';
    final nLabel = flipped ? 'S' : 'N';

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 3, w - 2, h - 2), const Radius.circular(r)),
      Paint()..color = Colors.black45..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(0, 0, w / 2, h,
        topLeft: const Radius.circular(r), bottomLeft: const Radius.circular(r)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color.lerp(sColor, Colors.white, 0.28)!, sColor, Color.lerp(sColor, Colors.black, 0.22)!],
      ).createShader(Rect.fromLTWH(0, 0, w / 2, h)));

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(w / 2, 0, w, h,
        topRight: const Radius.circular(r), bottomRight: const Radius.circular(r)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color.lerp(nColor, Colors.white, 0.28)!, nColor, Color.lerp(nColor, Colors.black, 0.22)!],
      ).createShader(Rect.fromLTWH(w / 2, 0, w / 2, h)));

    canvas.drawLine(Offset(w / 2, 5), Offset(w / 2, h - 5),
      Paint()..color = Colors.black38..strokeWidth = 1.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(r, 2, w - r * 2, 5), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.20));

    if (seeInside) {
      final dp = Paint()..color = Colors.white.withValues(alpha: 0.18)..strokeWidth = 1.0;
      for (int i = 1; i < 10; i++) {
        canvas.drawLine(Offset(i * w / 10, 7), Offset(i * w / 10, h - 7), dp);
      }
      final ap = Paint()..color = Colors.white.withValues(alpha: 0.38)..strokeWidth = 1.4..strokeCap = StrokeCap.round;
      for (int i = 0; i < 8; i++) {
        final ax = (i + 0.5) * w / 8;
        final ay = h / 2;
        final dir = flipped ? -1.0 : 1.0;
        canvas.drawLine(Offset(ax - 8 * dir, ay), Offset(ax + 8 * dir, ay), ap);
        canvas.drawLine(Offset(ax + 8 * dir, ay), Offset(ax + 3 * dir, ay - 4), ap);
        canvas.drawLine(Offset(ax + 8 * dir, ay), Offset(ax + 3 * dir, ay + 4), ap);
      }
    }

    _label(canvas, sLabel, Offset(w * 0.24, h / 2), 22);
    _label(canvas, nLabel, Offset(w * 0.76, h / 2), 22);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(r)),
      Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _label(Canvas canvas, String t, Offset c, double fs) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: Colors.white, fontSize: fs, fontWeight: FontWeight.w900, shadows: const [Shadow(color: Colors.black54, blurRadius: 3)])),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(BarMagnetPainter o) => o.seeInside != seeInside || o.flipped != flipped;
}

// ─────────────────────────────────────────────
//  Field Needle Painter
// ─────────────────────────────────────────────
class FieldNeedlePainter extends CustomPainter {
  final Offset magnetPos;
  final double magnetAngle;
  final double strength;
  final bool flipped;
  final bool earthField;
  final double magnetW;
  final double magnetH;
  final bool skipCircle;
  final Offset circleCenter;
  final double circleRadius;

  const FieldNeedlePainter({
    required this.magnetPos,
    required this.magnetAngle,
    required this.strength,
    required this.flipped,
    required this.earthField,
    required this.magnetW,
    required this.magnetH,
    this.skipCircle = false,
    this.circleCenter = Offset.zero,
    this.circleRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 34;
    const rows = 19;
    final cw = size.width / cols;
    final ch = size.height / rows;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final px = (col + 0.5) * cw;
        final py = (row + 0.5) * ch;
        final p = Offset(px, py);

        if (!earthField) {
          final d = p - magnetPos;
          final ca = cos(-magnetAngle);
          final sa = sin(-magnetAngle);
          final lx = (d.dx * ca - d.dy * sa).abs();
          final ly = (d.dx * sa + d.dy * ca).abs();
          if (lx < magnetW / 2 + 5 && ly < magnetH / 2 + 5) continue;
        }

        if (skipCircle) {
          final d = p - circleCenter;
          if (d.dx * d.dx + d.dy * d.dy < circleRadius * circleRadius) continue;
        }

        final b = MagneticField.compute(p, magnetPos, magnetAngle, magnetW / 2, strength, flipped, earthField);
        final mag = MagneticField.magnitude(b);
        if (mag < 1e-6) continue;

        final angle = MagneticField.fieldAngle(b);
        final len = (log(1 + mag * 0.28) * 100).clamp(8.0, 36.0).toDouble();
        _drawNeedle(canvas, p, angle, len);
      }
    }
  }

  void _drawNeedle(Canvas canvas, Offset c, double angle, double len) {
    final half = len / 2;
    final hw = (len / 18.0 * 5.6).clamp(3.0, 5.6);
    final ca = cos(angle);
    final sa = sin(angle);
    final cp = cos(angle + pi / 2);
    final sp = sin(angle + pi / 2);

    final head = Offset(c.dx + ca * half, c.dy + sa * half);
    final tail = Offset(c.dx - ca * half, c.dy - sa * half);
    final left = Offset(c.dx + cp * hw, c.dy + sp * hw);
    final right = Offset(c.dx - cp * hw, c.dy - sp * hw);

    canvas.drawPath(
      Path()..moveTo(tail.dx, tail.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = const Color(0xffcccccc)..style = PaintingStyle.fill);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = const Color(0xffcc2222)..style = PaintingStyle.fill);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(tail.dx, tail.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 0.3);
  }

  @override
  bool shouldRepaint(FieldNeedlePainter o) => true;
}

// ─────────────────────────────────────────────
//  Compass Painter
// ─────────────────────────────────────────────
class CompassPainter extends CustomPainter {
  final double needleAngle;
  const CompassPainter({required this.needleAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 2.0;
    final c = Offset(cx, cy);

    canvas.drawCircle(c, r,
      Paint()..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        colors: const [Color(0xff4a4a4a), Color(0xff1a1a1a)],
      ).createShader(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(c, r,
      Paint()..color = const Color(0xff555555)..style = PaintingStyle.stroke..strokeWidth = 6.0);
    canvas.drawCircle(c, r - 5, Paint()..color = const Color(0xff1e1e1e));
    canvas.drawCircle(c, r - 5,
      Paint()..color = const Color(0xff444444)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    for (int i = 0; i < 72; i++) {
      final a = i * pi / 36;
      final isMaj = i % 18 == 0;
      final isMed = i % 9 == 0;
      final inner = isMaj ? r - 22 : isMed ? r - 16 : r - 10;
      canvas.drawLine(
        Offset(cx + inner * cos(a), cy + inner * sin(a)),
        Offset(cx + (r - 7.0) * cos(a), cy + (r - 7.0) * sin(a)),
        Paint()
          ..color = isMaj ? Colors.white : isMed ? Colors.white60 : Colors.white30
          ..strokeWidth = isMaj ? 3.6 : 1.8
          ..strokeCap = StrokeCap.round);
    }

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(needleAngle);

    final nl = r - 12.0;
    final nhw = 11.0;

    final whiteNeedle = Path()..moveTo(0, nl)..lineTo(nhw, 0)..lineTo(-nhw, 0)..close();
    canvas.drawPath(whiteNeedle,
      Paint()..shader = LinearGradient(
        begin: const Alignment(-1, 0), end: const Alignment(1, 0),
        colors: const [Color(0xffaaaaaa), Color(0xffffffff), Color(0xffaaaaaa)],
      ).createShader(Rect.fromLTWH(-nhw, 0, nhw * 2, nl)));
    canvas.drawPath(whiteNeedle,
      Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = 0.7);

    final redNeedle = Path()..moveTo(0, -nl)..lineTo(nhw, 0)..lineTo(-nhw, 0)..close();
    canvas.drawPath(redNeedle,
      Paint()..shader = LinearGradient(
        begin: const Alignment(-1, 0), end: const Alignment(1, 0),
        colors: const [Color(0xff990000), Color(0xffee3333), Color(0xff990000)],
      ).createShader(Rect.fromLTWH(-nhw, -nl, nhw * 2, nl)));
    canvas.drawPath(redNeedle,
      Paint()..color = Colors.red.shade900..style = PaintingStyle.stroke..strokeWidth = 0.7);

    canvas.restore();

    canvas.drawCircle(c, 12,
      Paint()..shader = RadialGradient(
        colors: [Colors.grey.shade300, Colors.grey.shade700],
      ).createShader(Rect.fromCircle(center: c, radius: 12)));
    canvas.drawCircle(c, 12,
      Paint()..color = Colors.white30..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(c, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CompassPainter o) => o.needleAngle != needleAngle;
}

// ─────────────────────────────────────────────
//  Control Panel
// ─────────────────────────────────────────────
class _ControlPanel extends StatelessWidget {
  final SimState state;
  final ValueChanged<double> onStrengthChanged;
  final ValueChanged<double> onStrengthStep;
  final ValueChanged<bool> onShowFieldChanged;
  final ValueChanged<bool> onSeeInsideChanged;
  final ValueChanged<bool> onEarthFieldChanged;
  final VoidCallback onFlipPolarity;
  final ValueChanged<bool> onShowCompassChanged;
  final ValueChanged<bool> onShowFieldMeterChanged;

  const _ControlPanel({
    required this.state,
    required this.onStrengthChanged,
    required this.onStrengthStep,
    required this.onShowFieldChanged,
    required this.onSeeInsideChanged,
    required this.onEarthFieldChanged,
    required this.onFlipPolarity,
    required this.onShowCompassChanged,
    required this.onShowFieldMeterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _card(children: [
            const Text('Bar Magnet',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Row(children: [
              const Text('Strength:', style: TextStyle(color: Colors.black87, fontSize: 12)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                child: Text('${(state.strength * 100).round()}%',
                  style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 2),
            Column(children: [
              Row(children: [
                const Text('0%', style: TextStyle(color: Colors.black54, fontSize: 9)),
                const Spacer(),
                const Text('50%', style: TextStyle(color: Colors.black54, fontSize: 9)),
                const Spacer(),
                const Text('100%', style: TextStyle(color: Colors.black54, fontSize: 9)),
              ]),
              Row(children: [
                _arrowBtn(Icons.arrow_left, () => onStrengthStep(-0.05)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blueAccent,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.lightBlue,
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(value: state.strength, onChanged: onStrengthChanged),
                  ),
                ),
                _arrowBtn(Icons.arrow_right, () => onStrengthStep(0.05)),
              ]),
            ]),
            const SizedBox(height: 2),
            _check('Magnetic Field (B)', state.showField, onShowFieldChanged),
            _check('See Inside', state.seeInside, onSeeInsideChanged),
            _check('Earth', state.earthField, onEarthFieldChanged),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFlipPolarity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4fc3f7),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: const Text('Flip Polarity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          _card(children: [
            Row(children: [
              SizedBox(
                width: 20, height: 20,
                child: Checkbox(
                  value: state.showCompass,
                  onChanged: (v) => onShowCompassChanged(v ?? false),
                  activeColor: Colors.blueAccent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(child: Text('Compass', style: TextStyle(color: Colors.black87, fontSize: 13))),
              SizedBox(width: 60, height: 22, child: CustomPaint(painter: _MiniCompassPreviewPainter())),
            ]),
            const SizedBox(height: 2),
            Row(children: [
              SizedBox(
                width: 20, height: 20,
                child: Checkbox(
                  value: state.showFieldMeter,
                  onChanged: (v) => onShowFieldMeterChanged(v ?? false),
                  activeColor: Colors.blueAccent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(child: Text('Field Meter', style: TextStyle(color: Colors.black87, fontSize: 13))),
              const Icon(Icons.add_circle_outline, color: Color(0xff5c35c8), size: 20),
            ]),
          ]),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff0f4f8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChange) {
    return Row(children: [
      SizedBox(
        width: 20, height: 20,
        child: Checkbox(
          value: value,
          onChanged: (v) => onChange(v ?? false),
          activeColor: Colors.blueAccent,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13)),
    ]);
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Icon(icon, size: 18, color: Colors.black54),
      ),
    );
  }
}

class _MiniCompassPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(cx, cy), cy - 1, Paint()..color = const Color(0xff2a2a2a));
    canvas.drawCircle(Offset(cx, cy), cy - 1,
      Paint()..color = const Color(0xff555555)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    const angle = 0.4;
    final nh = cy - 3;
    final nhw = 2.8;
    final ca = cos(angle - pi / 2);
    final sa = sin(angle - pi / 2);
    final cp = cos(angle);
    final sp = sin(angle);

    final head = Offset(cx + ca * nh, cy + sa * nh);
    final tail = Offset(cx - ca * nh, cy - sa * nh);
    final left = Offset(cx + cp * nhw, cy + sp * nhw);
    final right = Offset(cx - cp * nhw, cy - sp * nhw);

    canvas.drawPath(
      Path()..moveTo(tail.dx, tail.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = Colors.white70);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = Colors.redAccent);

    _t(canvas, 'S', Offset(3, cy), Colors.black54, 8);
    _t(canvas, 'N', Offset(size.width - 5, cy), Colors.black54, 8);
  }

  void _t(Canvas canvas, String t, Offset c, Color color, double fs) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: color, fontSize: fs, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_MiniCompassPreviewPainter o) => false;
}
