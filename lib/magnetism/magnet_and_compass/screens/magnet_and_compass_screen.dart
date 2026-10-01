import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/widgets/nine_grid_layout.dart';
import '../magnet_and_compass_constants.dart';
import '../model/magnetic_field.dart';
import '../model/magnet_canvas_mapping.dart';
import '../model/magnet_state.dart';
import '../painters/bar_magnet_painter.dart';
import '../painters/compass_painter.dart';
import '../painters/earth_glow_painter.dart';
import '../painters/field_needle_painter.dart';
import '../painters/vertical_magnet_painter.dart';
import '../widgets/control_panel.dart';
import '../widgets/field_meter.dart';

/// Magnet & Compass simulation screen.
///
/// Page chrome: KARTOSLAB [AppBar] + [NineGridLayout].
/// Experiment content lives in `center` as a [Stack] of [Positioned]
/// canvas objects (magnet / compass / field / earth / field meter) plus
/// the original top-right floating [MagnetControlPanel].
///
/// Canvas [Positioned] coordinates are relative to the NineGrid center
/// cell (LayoutBuilder size), not the full window — drag objects cannot
/// be placed in NineGrid edge slots.
///
/// Initial magnet / compass / field-meter positions use original
/// `MediaQuery` window fractions translated by the center slot origin
/// ([MagnetCanvasMapping]).
/// Sizes stay absolute pixels; [MagneticField] is unchanged.
class MagnetAndCompassScreen extends StatefulWidget {
  const MagnetAndCompassScreen({super.key});
  @override
  State<MagnetAndCompassScreen> createState() => _MagnetAndCompassScreenState();
}

class _MagnetAndCompassScreenState extends State<MagnetAndCompassScreen>
    with TickerProviderStateMixin {
  late MagnetState _state;

  late AnimationController _compassCtrl;
  double _compassVelocity = 0.0;

  bool _initialized = false;
  Size _canvasSize = Size.zero;
  Offset _canvasOriginInWindow = Offset.zero;

  @override
  void initState() {
    super.initState();
    _state = MagnetState(
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

  MagnetCanvasMapping _mapping(Size window, Size canvas) =>
      MagnetCanvasMapping(
        windowSize: window,
        canvasSize: canvas,
        canvasOriginInWindow: _canvasOriginInWindow,
      );

  void _syncCanvasSize(Size size, BuildContext canvasContext) {
    if (!mounted || !canvasContext.mounted) return;
    if (size.width <= 0 || size.height <= 0) return;
    final box = canvasContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final origin = box.localToGlobal(Offset.zero);
    final sizeChanged = _canvasSize != size;
    final originChanged = origin != _canvasOriginInWindow;
    if (!sizeChanged && !originChanged && _initialized) return;
    final window = MediaQuery.sizeOf(canvasContext);
    setState(() {
      _canvasSize = size;
      _canvasOriginInWindow = origin;
      if (!_initialized) {
        _initialized = true;
        final m = _mapping(window, size);
        _state = _state.copyWith(
          magnetPos: m.magnetCanvasPos,
          compassPos: m.compassCanvasPos,
          fieldMeterPos: m.fieldMeterCanvasPos,
        );
      }
    });
  }

  void _tickCompass() {
    if (!mounted) return;
    final b = MagneticField.compute(
      _state.compassPos,
      _state.magnetPos,
      _state.magnetAngle,
      kMagnetWidth / 2,
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
    final s = _canvasSize;
    if (s.width <= 0 || s.height <= 0) return;
    final m = _mapping(MediaQuery.sizeOf(context), s);
    setState(() {
      _compassVelocity = 0;
      _state = MagnetState(
        magnetPos: m.magnetCanvasPos,
        magnetAngle: 0,
        strength: 0.75,
        flipped: false,
        showField: true,
        seeInside: false,
        earthField: false,
        showCompass: true,
        showFieldMeter: false,
        compassPos: m.compassCanvasPos,
        compassAngle: 0,
        fieldMeterPos: m.fieldMeterCanvasPos,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(93, 0, 0, 0),
      appBar: AppBar(
        title: const Text('磁铁与罗盘', style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: NineGridLayout(
        center: _buildCenterCanvas(),
        bottomRight: _buildResetButton(),
      ),
    );
  }

  Widget _buildCenterCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _syncCanvasSize(size, context));

        return ColoredBox(
          color: const Color.fromARGB(93, 0, 0, 0),
          child: Stack(
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
                        magnetW: kMagnetWidth,
                        magnetH: kMagnetHeight,
                        skipCircle: _state.earthField,
                        circleCenter: _state.magnetPos,
                        circleRadius: kEarthRadius,
                      ),
                    ),
                  ),
                ),

              if (_state.earthField) _buildEarth(size) else _buildMagnet(size),

              if (_state.showCompass) _buildCompass(size),

              if (_state.showFieldMeter) _buildFieldMeter(size),

              // Original PhET top-right floating panel. Not a NineGrid edge
              // slot: 230px cannot fit the ~8% side cells. Not AppBar chrome.
              Positioned(
                top: 12,
                right: 12,
                child: MagnetControlPanel(
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildResetButton() {
    const d = 52.0;
    // Original SimulationPage: Positioned(right: 18, bottom: 18).
    // Stay in NineGrid.bottomRight. Shrink inset (and scale only if the
    // cell is shorter than 52) so the circle is not clipped.
    const wantInset = 18.0;
    return LayoutBuilder(
      builder: (context, c) {
        final fits = c.maxWidth >= d && c.maxHeight >= d;
        final padR = fits ? min(wantInset, max(0.0, c.maxWidth - d)) : 0.0;
        final padB = fits ? min(wantInset, max(0.0, c.maxHeight - d)) : 0.0;
        Widget button = GestureDetector(
          onTap: _reset,
          child: Container(
            width: d,
            height: d,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffe65100),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
        );
        if (!fits) {
          button = FittedBox(fit: BoxFit.contain, child: button);
        }
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: padR, bottom: padB),
            child: button,
          ),
        );
      },
    );
  }

  Widget _buildMagnet(Size screenSize) {
    final cx = _state.magnetPos.dx;
    final cy = _state.magnetPos.dy;
    return Positioned(
      left: cx - kMagnetWidth / 2,
      top: cy - kMagnetHeight / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) {
          final cur = _state.magnetPos;
          final nx = (cur.dx + d.delta.dx).clamp(kMagnetWidth / 2, screenSize.width - kMagnetWidth / 2);
          final ny = (cur.dy + d.delta.dy).clamp(kMagnetHeight / 2, screenSize.height - kMagnetHeight / 2);
          setState(() => _state = _state.copyWith(magnetPos: Offset(nx, ny)));
        },
        child: Transform.rotate(
          angle: _state.magnetAngle,
          child: SizedBox(
            width: kMagnetWidth,
            height: kMagnetHeight,
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
    const r = kEarthRadius;
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
                painter: const EarthGlowPainter(),
              ),
              SizedBox(
                width: mW,
                height: mH,
                child: CustomPaint(
                  painter: VerticalMagnetPainter(flipped: _state.flipped),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(Size screenSize) {
    const r = kCompassRadius;
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
    return FieldMeter(
      state: _state,
      screenSize: screenSize,
      onPositionChanged: (pos) =>
          setState(() => _state = _state.copyWith(fieldMeterPos: pos)),
    );
  }
}
