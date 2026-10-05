/// Kepler's Laws experiment screen.
///
/// Page chrome: KARTOSLAB AppBar (when not embedded) + NineGridLayout.
/// Orbit objects live in the center Stack with model coordinates.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/simulation_clock.dart';
import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../../common/widgets/nine_grid_layout.dart';
import '../controller/keplers_laws_controller.dart';
import '../keplers_laws_colors.dart';
import '../keplers_laws_constants.dart';
import '../keplers_laws_strings.dart';
import '../keplers_motion.dart';
import '../model/law_mode.dart';
import '../model/period_tracker.dart';
import '../model/target_orbit.dart';
import '../painters/bodies_painter.dart';
import '../painters/grid_painter.dart';
import '../painters/orbit_painter.dart';
import '../painters/period_tracker_painter.dart';
import '../painters/swept_area_painter.dart';
import '../painters/target_orbit_painter.dart';
import '../painters/vectors_painter.dart';
import '../render/keplers_mvt.dart';
import '../render/orbit_render_data.dart';
import '../widgets/distances_display.dart';
import '../widgets/keplers_law_thumbs.dart';
import '../widgets/keplers_overlays.dart';
import '../widgets/keplers_panels.dart';
import '../widgets/keplers_time_control.dart';
import '../widgets/measuring_tape.dart';

class KeplersLawsScreen extends StatefulWidget {
  const KeplersLawsScreen({
    super.key,
    required this.initialLaw,
    this.isAllLaws = false,
    this.embedded = false,
    this.controller,
  });

  final LawMode initialLaw;
  final bool isAllLaws;
  final bool embedded;
  final KeplersLawsController? controller;

  @override
  State<KeplersLawsScreen> createState() => _KeplersLawsScreenState();
}

class _KeplersLawsScreenState extends State<KeplersLawsScreen>
    with TickerProviderStateMixin {
  late final KeplersLawsController _controller;
  late final SimulationClock _clock;
  late final AnimationController _zoomCtrl;
  late final bool _ownsController;

  /// Which body handle is being dragged: `planet` or `velocity`.
  String? _dragKind;
  int _lastZoomLevel = 2;
  double _zoomFrom = KeplersLawsConstants.zoomScaleMax;
  double _zoomTo = KeplersLawsConstants.zoomScaleMax;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        KeplersLawsController(
          initialLaw: widget.initialLaw,
          isAllLaws: widget.isAllLaws,
        );
    _lastZoomLevel = _controller.zoomLevel;
    _zoomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _zoomCtrl.addListener(() {
      final t = Curves.easeInOutCubic.transform(_zoomCtrl.value);
      _controller.zoomScale = _zoomFrom + (_zoomTo - _zoomFrom) * t;
      if (mounted) setState(() {});
    });
    _controller.addListener(_onTick);
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) => _controller.tick(dt);
    _clock.play();
  }

  void _onTick() {
    if (_controller.zoomLevel != _lastZoomLevel) {
      final alreadyAtTarget =
          (_controller.zoomScale - _controller.targetZoomScale).abs() < 0.01;
      if (_controller.resetting || alreadyAtTarget) {
        _zoomCtrl.stop();
        _controller.zoomScale = _controller.targetZoomScale;
      } else {
        _animateZoom();
      }
      _lastZoomLevel = _controller.zoomLevel;
    }
    if (mounted) setState(() {});
  }

  /// [已确认] Animation duration 0.5, Easing.CUBIC_IN_OUT
  void _animateZoom() {
    _zoomFrom = _controller.zoomScale;
    _zoomTo = _controller.targetZoomScale;
    _zoomCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _zoomCtrl.dispose();
    _clock.dispose();
    _controller.removeListener(_onTick);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  OrbitRenderData _render(Size canvas) {
    final c = _controller;
    final mvt = KeplersMvt(
      center: Offset(canvas.width / 2, canvas.height / 2),
      scale: c.zoomScale,
    );
    return OrbitRenderData(
      mvt: mvt,
      a: c.engine.a,
      b: c.engine.b,
      c: c.engine.c,
      e: c.engine.e,
      w: c.engine.w,
      nu: c.engine.nu,
      allowed: c.engine.allowedOrbit,
      orbitType: c.engine.orbitType,
      sunPos: c.sun.position,
      planetPos: c.planet.position,
      sunRadius: c.sun.radius,
      planetRadius: c.planet.radius,
      velocity: c.planet.velocity,
      planetGravity: c.planet.gravityForce,
      sunGravity: c.sun.gravityForce,
      periodYears: c.engine.T,
      velocityArrowScale: c.velocityArrowScale,
      gravityArrowScale: c.gravityArrowScale,
      retrograde: c.engine.retrograde,
      periodTraceStart: c.periodTracker.periodTraceStart,
      periodTraceEnd: c.periodTracker.periodTraceEnd,
      periodTracking: c.periodTracker.trackingState,
      periodFadeOpacity: c.periodTracker.trackingState == TrackingState.fading
          ? (1 - c.periodTracker.fadingTime / KeplersLawsConstants.periodFadeDuration)
              .clamp(0.0, 1.0)
          : 1,
      afterPeriodThreshold: c.periodTracker.afterPeriodThreshold,
      targetOrbit: c.targetOrbit,
      showTargetOrbit: c.isSolarSystem &&
          !c.isSecondLaw &&
          c.targetOrbit != TargetOrbit.none,
      showAreaValues: c.visible.areaValuesVisible && c.isSecondLaw,
      showTimeValues: c.visible.timeValuesVisible && c.isSecondLaw,
      areas: [
        for (final a in c.engine.orbitalAreas)
          SweptAreaDraw(
            start: a.startPosition,
            end: a.endPosition,
            dot: a.dotPosition,
            fill: c.areaColor(a),
            active: a.active,
            alreadyEntered: a.alreadyEntered,
            inside: a.inside,
            completion: a.completion,
            sweptArea: a.sweptArea,
            durationYears: c.engine.T / c.periodDivisions,
            startAngle: a.startAngle,
            endAngle: a.endAngle,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Material(
      color: KeplersLawsColors.background,
      child: LayoutBuilder(
        builder: (context, page) {
          // Match NineGridLayout footer height so chrome sits above TimeControl.
          final footerH = math.min(96.0, page.maxHeight * 0.16);
          return Stack(
            children: [
              NineGridLayout(
                backgroundColor: KeplersLawsColors.background,
                topLeft: null,
                topRight: null,
                center: LayoutBuilder(
                  builder: (context, constraints) {
                    // NineGrid center width is tight but height is loose.
                    // Fill the cell so MVT origin == play-area visual center.
                    // [已确认] ScreenView layoutBounds: sun at mapping origin.
                    final size =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    final data = _render(size);
                    return SizedBox(
                      key: const ValueKey('keplers-play-area'),
                      width: size.width,
                      height: size.height,
                      child: _PlayArea(
                        data: data,
                        controller: _controller,
                        onDragStart: (kind, local) {
                          _dragKind = kind;
                          if (kind == 'planet') {
                            _controller.beginUserPosition();
                          } else {
                            _controller.beginUserVelocity();
                          }
                        },
                        onDragUpdate: (local) {
                          if (_dragKind == 'planet') {
                            _controller.setPlanetPosition(
                              data.mvt.toModel(local),
                            );
                          } else if (_dragKind == 'velocity') {
                            final modelTip = data.mvt.toModel(local);
                            final delta =
                                modelTip - _controller.planet.position;
                            _controller.setPlanetVelocity(
                              delta.times(1 / _controller.velocityArrowScale),
                            );
                          }
                        },
                        onDragEnd: () {
                          if (_dragKind == 'planet') {
                            _controller.endUserPosition();
                          } else if (_dragKind == 'velocity') {
                            _controller.endUserVelocity();
                          }
                          _dragKind = null;
                        },
                      ),
                    );
                  },
                ),
                footer: ColoredBox(
                  color: KeplersLawsColors.background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.isAllLaws)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: KeplersLawsRadioRow(
                              selected: _controller.selectedLaw,
                              onSelect: _controller.selectLaw,
                            ),
                          ),
                        KeplersTimeControl(controller: _controller),
                        Align(
                          alignment: Alignment.centerRight,
                          child: KratosResetAllButton(
                            onPressed: _controller.reset,
                            radius: 20.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Panels align to the ScreenView edges (AlignBox), not the
              // 70% NineGrid cell — otherwise the default planet at +2 AU
              // sits under the visibility accordion.
              Positioned(
                left: 8,
                top: 8,
                bottom: footerH + 8,
                width: 260,
                child: SingleChildScrollView(
                  child: KeplersMotion.fadeSize(
                    key: _controller.selectedLaw,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FirstLawSidePanel(controller: _controller),
                        SecondLawSidePanel(controller: _controller),
                        ThirdLawSidePanel(controller: _controller),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                bottom: footerH + 8,
                width: 230,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _zoomChip(_controller, zoomOut: true, level: 1),
                          const SizedBox(width: 4),
                          _zoomChip(_controller, zoomOut: false, level: 2),
                        ],
                      ),
                      VisibilityPanel(controller: _controller),
                    ],
                  ),
                ),
              ),
              YearsStopwatchOverlay(
                controller: _controller,
                area: Size(page.maxWidth, page.maxHeight),
                footerH: footerH,
              ),
            ],
          );
        },
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text('${KeplersLawsStrings.title} · ${_lawLabel()}'),
        backgroundColor: const Color(0xFF1A365D),
        foregroundColor: Colors.white,
      ),
      body: body,
    );
  }

  String _lawLabel() {
    switch (widget.initialLaw) {
      case LawMode.first:
        return widget.isAllLaws
            ? KeplersLawsStrings.allLaws
            : KeplersLawsStrings.firstLaw;
      case LawMode.second:
        return KeplersLawsStrings.secondLaw;
      case LawMode.third:
        return KeplersLawsStrings.thirdLaw;
    }
  }
}

class _PlayArea extends StatelessWidget {
  const _PlayArea({
    required this.data,
    required this.controller,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final OrbitRenderData data;
  final KeplersLawsController controller;
  final void Function(String kind, Offset local) onDragStart;
  final void Function(Offset local) onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final v = controller.visible;
    final planetView = data.mvt.toView(data.planetPos);
    final planetR = data.mvt.toViewDelta(data.planetRadius);

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(mvt: data.mvt, visible: v.gridVisible),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: TargetOrbitPainter(data: data),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: SweptAreaPainter(
              data: data,
              visible: controller.isSecondLaw,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: OrbitPainter(
              data: data,
              showAxes: v.axesVisible,
              showSemiaxes: v.semiaxesVisible,
              showFoci: v.fociVisible,
              showString: v.stringVisible,
              showEccentricity: v.eccentricityVisible,
              showSemiMajor: v.semiMajorAxisVisible,
              showPeriapsis: v.periapsisVisible,
              showApoapsis: v.apoapsisVisible,
              isFirstLaw: controller.isFirstLaw,
              isSecondLaw: controller.isSecondLaw,
              isThirdLaw: controller.isThirdLaw,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: PeriodTrackerPainter(
              data: data,
              visible: controller.isThirdLaw && v.periodVisible,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: BodiesPainter(data: data)),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: VectorsPainter(
              data: data,
              showVelocity: v.velocityVisible,
              showGravity: v.gravityVisible,
              showVelocityHandle: v.velocityVisible && !controller.alwaysCircular,
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (d) {
              final p = d.localPosition;
              final velTip = controller.planet.position +
                  data.velocity.times(data.velocityArrowScale);
              final velEnd = data.mvt.toView(velTip);
              final canDragVelocity = v.velocityVisible &&
                  !controller.alwaysCircular;
              if (canDragVelocity && (p - velEnd).distance < 28) {
                onDragStart('velocity', p);
              } else if ((p - planetView).distance < planetR + 16) {
                onDragStart('planet', p);
              }
            },
            onPanUpdate: (d) => onDragUpdate(d.localPosition),
            onPanEnd: (_) => onDragEnd(),
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          top: 8,
          child: IgnorePointer(
            child: Column(
              children: [
                OrbitalWarningBanner(controller: controller),
                DistancesDisplay(controller: controller, mvt: data.mvt),
              ],
            ),
          ),
        ),
        if (v.speedVisible)
          Positioned(
            left: planetView.dx - 40,
            top: planetView.dy + planetR + 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: const Color(0x80000000),
              child: Text(
                '${controller.planet.velocity.magnitude.toStringAsFixed(2)} km/s',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        if (controller.isGravityOffscale && v.gravityVisible)
          const Positioned(
            left: 8,
            right: 8,
            top: 36,
            child: Text(
              'Gravity force is too small to see; use the zoom slider.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        Positioned.fill(
          child: MeasuringTapeOverlay(controller: controller, mvt: data.mvt),
        ),
        PeriodTimerOverlay(controller: controller),
      ],
    );
  }
}

Widget _zoomChip(
  KeplersLawsController controller, {
  required bool zoomOut,
  required int level,
}) {
  final selected = controller.zoomLevel == level;
  return Material(
    color: zoomOut ? KeplersLawsColors.sun : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
      side: BorderSide(
        color: selected ? const Color(0xFF333333) : const Color(0xFF888888),
        width: selected ? 2 : 1,
      ),
    ),
    child: InkWell(
      onTap: () => controller.setZoomLevel(level),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: CustomPaint(
          size: const Size(22, 22),
          painter: _MagnifierPainter(plus: !zoomOut),
        ),
      ),
    ),
  );
}

class _MagnifierPainter extends CustomPainter {
  _MagnifierPainter({required this.plus});

  final bool plus;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.42), 6.5, stroke);
    canvas.drawLine(
      Offset(size.width * 0.62, size.height * 0.62),
      Offset(size.width * 0.88, size.height * 0.88),
      stroke,
    );
    final cx = size.width * 0.42;
    final cy = size.height * 0.42;
    canvas.drawLine(Offset(cx - 3.2, cy), Offset(cx + 3.2, cy), stroke);
    if (plus) {
      canvas.drawLine(Offset(cx, cy - 3.2), Offset(cx, cy + 3.2), stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _MagnifierPainter oldDelegate) =>
      oldDelegate.plus != plus;
}
