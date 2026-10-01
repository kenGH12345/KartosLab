import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/simulation_clock.dart';
import '../../common/widgets/kratos_reset_all_button.dart';
import '../famb_assets.dart';
import '../widgets/famb_picture.dart';
import '../model/famb_constants.dart';
import '../model/motion_model.dart';

enum MotionScreenStyleTab { motion, friction, acceleration }

MotionScreenStyle _toStyle(MotionScreenStyleTab t) {
  switch (t) {
    case MotionScreenStyleTab.motion:
      return MotionScreenStyle.motion;
    case MotionScreenStyleTab.friction:
      return MotionScreenStyle.friction;
    case MotionScreenStyleTab.acceleration:
      return MotionScreenStyle.acceleration;
  }
}

/// Shared Motion / Friction / Acceleration view (PhET MotionScreenView).
class MotionScreenV2 extends StatefulWidget {
  const MotionScreenV2({super.key, required this.style});
  final MotionScreenStyleTab style;

  @override
  State<MotionScreenV2> createState() => _MotionScreenV2State();
}

class _MotionScreenV2State extends State<MotionScreenV2>
    with TickerProviderStateMixin {
  static const double W = 981;
  static const double H = 604;
  static const double skyH = 362;
  static const double centerX = 490.5;

  late final MotionModel model;
  late final SimulationClock clock;

  ForceItem? dragging;
  Offset? dragPos;
  /// True when the current drag started from a toolbox slot (not the stack).
  bool _dragFromToolbox = false;

  static const double _boxH = 180;
  static const double _boxTop = H - _boxH - 10; // 414

  @override
  void initState() {
    super.initState();
    model = MotionModel(_toStyle(widget.style));
    clock = SimulationClock(fps: 60);
    clock.attach(this);
    clock.onTick = (dt, _) {
      model.step(dt);
      if (mounted) setState(() {});
    };
    clock.play();
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }

  int get _pusherFrame {
    final f = model.sim.appliedForce.abs();
    return math.min(30, (f / 500 * 30).round());
  }

  String get _pusherAsset {
    if (model.sim.fallen) return FambAssets.pusherFallen;
    if (model.sim.appliedForce.abs() < 1e-6) return FambAssets.pusherStanding;
    return FambAssets.pusher(_pusherFrame);
  }

  double get _stackViewX {
    // Map model meters to view: keep stack near center; background shifts.
    return centerX + model.sim.position * MotionConstants.positionScale;
  }

  void _resetAll() {
    setState(() {
      model.reset();
      clock.reset();
      if (!clock.isRunning) clock.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fill the tab body completely (no letterbox bars).
    return Material(
      color: const Color(0xFFD2B48C),
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: W,
            height: H,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _sky(),
                _mountains(),
                _clouds(),
                _track(),
                if (model.hasSkateboard) _skateboard(),
                _stack(),
                _pusher(),
                _forceArrows(),
                if (model.showSpeed) _speedometer(),
                if (model.showAcceleration && model.hasAccelerometer)
                  _accelerometer(),
                if (model.showStopwatch && model.hasStopwatch) _stopwatch(),
                _controlPanel(),
                _timeControls(),
                _bottomChrome(),
                _toolboxItemsLayer(),
                _stackHitLayer(),
                if (dragging != null) _dragGhost(),
                // Always mounted so the same pointer path receives move/up.
                _dragFollowLayer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Follow the pointer anywhere once a drag has started.
  Widget _dragFollowLayer() {
    return Positioned.fill(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: (e) {
          if (dragging == null || dragPos == null) return;
          setState(() => dragPos = dragPos! + e.localDelta);
        },
        onPointerUp: (_) {
          final item = dragging;
          if (item != null) _dropItem(item);
        },
        onPointerCancel: (_) {
          final item = dragging;
          if (item != null) _dropItem(item);
        },
      ),
    );
  }

  Widget _sky() => const Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: skyH,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6EC5EB), Color(0xFFB8E0F0)],
            ),
          ),
        ),
      );

  Widget _mountains() {
    final shift = -model.sim.position * MotionConstants.positionScale * 0.3;
    return Positioned(
      left: shift - 200,
      top: skyH - 120,
      height: 120,
      child: const FambPicture(
        FambAssets.mountains,
        height: 120,
        fit: BoxFit.fitHeight,
      ),
    );
  }

  Widget _clouds() {
    final shift = -model.sim.position * MotionConstants.positionScale * 0.15;
    return Stack(
      children: [
        Positioned(
          left: 80 + shift,
          top: 40,
          child: const FambPicture(FambAssets.cloud, width: 120),
        ),
        Positioned(
          left: 420 + shift * 0.7,
          top: 70,
          child: const FambPicture(FambAssets.cloud, width: 90),
        ),
      ],
    );
  }

  Widget _track() {
    if (model.hasSkateboard) {
      return Positioned(
        top: skyH,
        left: 0,
        right: 0,
        bottom: 160,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF8B5A2B),
            border: Border(top: BorderSide(color: Color(0xFF5D3A1A), width: 4)),
          ),
        ),
      );
    }
    // Friction / Acceleration: brick tile surface (PhET MovingBackgroundNode)
    return Positioned(
      top: skyH - 8,
      left: 0,
      right: 0,
      bottom: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 22,
            child: Image.asset(
              FambAssets.brickTile,
              repeat: ImageRepeat.repeatX,
              fit: BoxFit.fitHeight,
              gaplessPlayback: true,
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: const Color(0xFFA67C52),
              child: Opacity(
                opacity: 0.55,
                child: Image.asset(
                  FambAssets.brickTile,
                  repeat: ImageRepeat.repeat,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pusher() {
    final facingRight = model.sim.appliedForce >= 0;
    // PhET: stand beside the bottom stack item (half-width − inset).
    double delta = 55;
    if (model.stack.isNotEmpty) {
      final bottom = model.stack.first;
      final w = _stackSize(bottom, onStack: true).width;
      delta = w / 2 - 4;
    }
    final x = facingRight
        ? _stackViewX - delta - 90
        : _stackViewX + delta;
    return Positioned(
      left: x,
      top: skyH - 155,
      width: 100,
      height: 165,
      child: IgnorePointer(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(facingRight ? 1.0 : -1.0, 1, 1),
          child: Image.asset(
            _pusherAsset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }

  Widget _skateboard() {
    // PhET skateboard scale 0.75 → ~161×35
    return Positioned(
      left: _stackViewX - 80,
      top: skyH - 30,
      child: const FambPicture(
        FambAssets.skateboard,
        width: 214.6 * 0.75,
        height: 46.7 * 0.75,
        fit: BoxFit.fill,
      ),
    );
  }

  static const double _engagedScale = 1.3;

  /// Toolbox display size = intrinsic × imageScale × homeScale (PhET).
  Size _toolboxSize(ForceItem item) {
    final s = item.imageScale * item.homeScale;
    return Size(item.intrinsicWidth * s, item.intrinsicHeight * s);
  }

  /// Stack/play size; humans use sitting intrinsic when on stack.
  Size _stackSize(ForceItem item, {required bool onStack}) {
    final s = item.imageScale * _engagedScale;
    if (onStack && item.isHuman) {
      final w = item.sittingWidth ?? item.intrinsicWidth;
      final h = item.sittingHeight ?? item.intrinsicHeight;
      return Size(w * s, h * s);
    }
    return Size(item.intrinsicWidth * s, item.intrinsicHeight * s);
  }

  String _stackAsset(ForceItem item) {
    if (!item.isHuman) return item.assetPath;
    if (model.isItemStackedAbove(item) && item.holdingAssetPath != null) {
      return item.holdingAssetPath!;
    }
    return item.sittingAssetPath ?? item.assetPath;
  }

  Widget _stack() {
    final items = model.stack;
    double yBottom = model.hasSkateboard ? skyH - 28 : skyH - 4;
    final children = <Widget>[];
    for (final item in items) {
      if (identical(item, dragging)) continue;
      final sz = _stackSize(item, onStack: true);
      yBottom -= sz.height;
      final top = yBottom;
      children.add(
        Positioned(
          left: _stackViewX - sz.width / 2,
          top: top,
          width: sz.width,
          height: sz.height,
          child: IgnorePointer(
            child: item.isBucket
                ? Transform.rotate(
                    angle: (model.sim.acceleration * 0.025).clamp(-0.45, 0.45),
                    child: _itemImage(_stackAsset(item), sz),
                  )
                : _itemImage(_stackAsset(item), sz),
          ),
        ),
      );
      if (model.showMasses && item.massKnown) {
        children.add(
          Positioned(
            left: _stackViewX - 28,
            top: top + sz.height / 2 - 8,
            child: IgnorePointer(
              child: Text(
                '${item.mass.round()} kg',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [Shadow(color: Colors.white, blurRadius: 2)],
                ),
              ),
            ),
          ),
        );
      }
    }
    return Stack(clipBehavior: Clip.none, children: children);
  }

  /// Persistent hit target — survives setState after removeFromStack.
  Widget _stackHitLayer() {
    return Positioned(
      left: centerX - 140,
      top: 80,
      width: 280,
      height: skyH - 60,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (e) {
          if (dragging != null) return;
          final play = Offset(
            centerX - 140 + e.localPosition.dx,
            80 + e.localPosition.dy,
          );
          final hit = _pickStackAt(play);
          if (hit == null) return;
          setState(() {
            dragging = hit.item;
            _dragFromToolbox = false;
            dragPos = Offset(_stackViewX - hit.sz.width / 2, hit.top);
            model.removeFromStack(hit.item);
          });
        },
      ),
    );
  }

  ({ForceItem item, double top, Size sz})? _pickStackAt(Offset play) {
    double yBottom = model.hasSkateboard ? skyH - 28 : skyH - 4;
    final layouts = <({ForceItem item, double top, Size sz})>[];
    for (final item in model.stack) {
      if (identical(item, dragging)) continue;
      final sz = _stackSize(item, onStack: true);
      yBottom -= sz.height;
      layouts.add((item: item, top: yBottom, sz: sz));
    }
    for (var i = layouts.length - 1; i >= 0; i--) {
      final L = layouts[i];
      final rect = Rect.fromLTWH(
        _stackViewX - L.sz.width / 2,
        L.top,
        L.sz.width,
        L.sz.height,
      );
      if (rect.contains(play)) return L;
    }
    return null;
  }

  Widget _itemImage(String path, Size sz) {
    return FambPicture(
      path,
      width: sz.width,
      height: sz.height,
      fit: BoxFit.fill,
    );
  }

  void _dropItem(ForceItem item) {
    final pos = dragPos;
    final sz = _dragFromToolbox
        ? _toolboxSize(item)
        : _stackSize(item, onStack: false);
    setState(() {
      dragging = null;
      dragPos = null;
      _dragFromToolbox = false;
      if (pos == null) return;
      final cx = pos.dx + sz.width / 2;
      final cy = pos.dy + sz.height / 2;
      if ((cx - _stackViewX).abs() < 160 && cy < 350) {
        model.addToStack(item);
      }
    });
  }

  Widget _dragGhost() {
    final item = dragging!;
    final pos = dragPos!;
    final sz = _dragFromToolbox
        ? _toolboxSize(item)
        : _stackSize(item, onStack: false);
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      width: sz.width,
      height: sz.height,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.92,
          child: _itemImage(item.assetPath, sz),
        ),
      ),
    );
  }

  Widget _forceArrows() {
    final applied = model.sim.appliedForce;
    final friction = model.sim.frictionForce;
    final sum = model.sim.sumOfForces;
    final y = skyH - 180;
    return Stack(
      children: [
        if (model.showForce && applied.abs() > 1e-6)
          _arrow(
            applied,
            y,
            const Color(0xFFE36F1E),
            model.showValues ? '${applied.round()} N' : null,
          ),
        if (model.showForce &&
            model.hasFrictionSlider &&
            friction.abs() > 1e-6)
          _arrow(
            friction,
            y + 36,
            const Color(0xFFBF8B63),
            model.showValues ? '${friction.round()} N' : null,
          ),
        if (model.showSumOfForces && model.hasFrictionSlider)
          sum.abs() > 1e-6
              ? _arrow(
                  sum,
                  y - 40,
                  const Color(0xFF7DC673),
                  model.showValues ? '${sum.round()} N' : 'Sum of Forces',
                )
              : const Positioned(
                  left: centerX - 70,
                  top: skyH - 230,
                  child: Text(
                    'Sum of Forces = 0',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
      ],
    );
  }

  Widget _arrow(double force, double top, Color color, String? label) {
    final len = force.abs().clamp(0, 400).toDouble();
    final toLeft = force < 0;
    return Positioned(
      left: toLeft ? centerX - len : centerX,
      top: top,
      child: SizedBox(
        width: len,
        height: 32,
        child: CustomPaint(
          painter: _MotionArrowPainter(toLeft: toLeft, color: color),
          child: label == null
              ? null
              : Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _speedometer() {
    return Positioned(
      left: centerX - 55,
      top: 20,
      child: _MiniGauge(
        value: model.sim.speed,
        max: MotionConstants.maxSpeed,
        label: 'Speed',
      ),
    );
  }

  Widget _accelerometer() {
    return Positioned(
      left: centerX - 80,
      top: 95,
      child: _AccelMeter(acceleration: model.sim.acceleration),
    );
  }

  Widget _stopwatch() {
    final t = model.stopwatchElapsed;
    final mm = (t ~/ 60).toString().padLeft(2, '0');
    final ss = (t % 60).toStringAsFixed(2).padLeft(5, '0');
    return Positioned(
      right: 200,
      top: 20,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$mm:$ss',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(
                  () => model.stopwatchRunning = !model.stopwatchRunning,
                ),
                child: Text(model.stopwatchRunning ? 'Stop' : 'Start'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  model.stopwatchElapsed = 0;
                  model.stopwatchRunning = false;
                }),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlPanel() {
    return Positioned(
      right: 10,
      top: 10,
      child: Theme(
        data: Theme.of(context).copyWith(
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.all(Colors.white),
            checkColor: WidgetStateProperty.all(Colors.black),
            side: const BorderSide(color: Colors.black, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        child: Container(
        width: 170,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE3E980),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _cb(
              model.hasFrictionSlider ? 'Forces' : 'Force',
              model.showForce,
              (v) => setState(() => model.showForce = v),
              trailing: const Icon(Icons.arrow_right_alt,
                  color: Color(0xFFE36F1E), size: 18),
            ),
            if (model.hasFrictionSlider)
              _cb(
                'Sum of Forces',
                model.showSumOfForces,
                (v) => setState(() => model.showSumOfForces = v),
              ),
            _cb('Values', model.showValues,
                (v) => setState(() => model.showValues = v)),
            _cb('Masses', model.showMasses,
                (v) => setState(() => model.showMasses = v)),
            _cb(
              'Speed',
              model.showSpeed,
              (v) => setState(() => model.showSpeed = v),
              trailing: CustomPaint(
                size: const Size(22, 14),
                painter: _PanelSpeedIconPainter(),
              ),
            ),
            if (model.hasStopwatch)
              _cb(
                'Stopwatch',
                model.showStopwatch,
                (v) => setState(() => model.showStopwatch = v),
              ),
            if (model.hasAccelerometer)
              _cb(
                'Acceleration',
                model.showAcceleration,
                (v) => setState(() => model.showAcceleration = v),
              ),
            if (model.hasFrictionSlider) ...[
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Friction',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: model.sim.frictionCoeff,
                  min: 0,
                  max: MotionConstants.maxFriction,
                  divisions: 20,
                  activeColor: const Color(0xFF2196F3),
                  onChanged: (v) => setState(() => model.setFriction(v)),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('None', style: TextStyle(fontSize: 11)),
                  Text('Lots', style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _cb(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          ?trailing,
        ],
      ),
    );
  }

  Widget _timeControls() {
    final panelBottom = 10.0 + (model.hasFrictionSlider ? 250 : 155);
    return Positioned(
      right: 10,
      top: panelBottom,
      child: Row(
        children: [
          _roundBtn(
            color: const Color(0xFF42A5F5),
            size: 44,
            onTap: () => setState(() {
              model.isPlaying = !model.isPlaying;
            }),
            child: model.isPlaying
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ColoredBox(
                        color: Colors.white,
                        child: SizedBox(width: 5, height: 18),
                      ),
                      SizedBox(width: 5),
                      ColoredBox(
                        color: Colors.white,
                        child: SizedBox(width: 5, height: 18),
                      ),
                    ],
                  )
                : const Icon(Icons.play_arrow, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 8),
          _roundBtn(
            color: const Color(0xFFB0BEC5),
            size: 34,
            onTap: model.isPlaying ? null : () => setState(model.manualStep),
            child: const Icon(Icons.skip_next, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 8),
          KratosResetAllButton(onPressed: _resetAll, radius: 23),
        ],
      ),
    );
  }

  Widget _roundBtn({
    required Color color,
    required double size,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(child: child),
        ),
      ),
    );
  }

  /// Brown strip + toolbox backgrounds + applied-force control (no items).
  Widget _bottomChrome() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _boxH + 10,
          child: ColoredBox(color: Color(0xFFD2B48C)),
        ),
        Positioned(
          left: 10,
          top: _boxTop,
          width: 300,
          height: _boxH,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFE7E8E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: _boxTop,
          width: 300,
          height: _boxH,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFE7E8E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
        ),
        Positioned(
          left: 320,
          right: 320,
          top: _boxTop - 4,
          bottom: 4,
          child: _appliedForce(),
        ),
      ],
    );
  }

  /// Fixed PhET home positions. Visuals are IgnorePointer; each toolbox has
  /// one drag surface that picks the item whose center is nearest the tap
  /// (avoids wrong neighbor + no live “packing” jumps).
  Widget _toolboxItemsLayer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final item in model.toolboxItems)
          if (dragging != item)
            Positioned(
              left: item.homeX,
              top: item.homeY,
              width: _toolboxSize(item).width,
              height: _toolboxSize(item).height,
              child: IgnorePointer(
                child: _itemImage(item.assetPath, _toolboxSize(item)),
              ),
            ),
        _toolboxDragSurface(left: true),
        _toolboxDragSurface(left: false),
      ],
    );
  }

  Widget _toolboxDragSurface({required bool left}) {
    final leftX = left ? 10.0 : W - 10.0 - 300.0;
    return Positioned(
      left: leftX,
      top: _boxTop,
      width: 300,
      height: H - _boxTop,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (e) {
          if (dragging != null) return;
          final play = Offset(
            leftX + e.localPosition.dx,
            _boxTop + e.localPosition.dy,
          );
          final item = _pickToolboxItem(play, left: left);
          if (item == null) return;
          setState(() {
            dragging = item;
            _dragFromToolbox = true;
            dragPos = Offset(item.homeX, item.homeY);
          });
        },
      ),
    );
  }

  ForceItem? _pickToolboxItem(Offset play, {required bool left}) {
    ForceItem? best;
    var bestScore = double.infinity;
    for (final item in model.toolboxItems) {
      if (item.inLeftToolbox != left) continue;
      if (identical(item, dragging)) continue;
      final sz = _toolboxSize(item);
      final rect = Rect.fromLTWH(item.homeX, item.homeY, sz.width, sz.height);
      // Inflate slightly so taps on feet still count; score by distance to center.
      if (!rect.inflate(12).contains(play)) continue;
      final score = (play - rect.center).distanceSquared;
      if (score < bestScore) {
        bestScore = score;
        best = item;
      }
    }
    return best;
  }

  Widget _appliedForce() {
    final f = model.sim.appliedForce;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Applied Force',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _forceBtn('<<', -50),
                  _forceBtn('<', -1),
                  Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black54),
                    ),
                    child: Text(
                      '${f.round()} newtons',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  _forceBtn('>', 1),
                  _forceBtn('>>', 50),
                ],
              ),
              SizedBox(
                height: 36,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: f,
                    min: -500,
                    max: 500,
                    divisions: 1000,
                    activeColor: const Color(0xFF2196F3),
                    onChanged: (v) => setState(() => model.setAppliedForce(v)),
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('-500', style: TextStyle(fontSize: 11)),
                  Text('0', style: TextStyle(fontSize: 11)),
                  Text('500', style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _forceBtn(String label, double delta) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 36,
        height: 32,
        child: Material(
          color: const Color(0xFFCFD8DC),
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: () => setState(
              () => model.setAppliedForce(model.sim.appliedForce + delta),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MotionArrowPainter extends CustomPainter {
  _MotionArrowPainter({required this.toLeft, required this.color});
  final bool toLeft;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    const head = 28.0;
    final path = Path();
    if (toLeft) {
      path.moveTo(0, y);
      path.lineTo(head, 0);
      path.lineTo(head, y - 8);
      path.lineTo(size.width, y - 8);
      path.lineTo(size.width, y + 8);
      path.lineTo(head, y + 8);
      path.lineTo(head, size.height);
      path.close();
    } else {
      path.moveTo(size.width, y);
      path.lineTo(size.width - head, 0);
      path.lineTo(size.width - head, y - 8);
      path.lineTo(0, y - 8);
      path.lineTo(0, y + 8);
      path.lineTo(size.width - head, y + 8);
      path.lineTo(size.width - head, size.height);
      path.close();
    }
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(covariant _MotionArrowPainter old) =>
      old.toLeft != toLeft || old.color != color;
}

class _MiniGauge extends StatelessWidget {
  const _MiniGauge({
    required this.value,
    required this.max,
    required this.label,
  });
  final double value;
  final double max;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 110,
          height: 60,
          child: CustomPaint(
            painter: _NeedlePainter(value: value, max: max),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _NeedlePainter extends CustomPainter {
  _NeedlePainter({required this.value, required this.max});
  final double value;
  final double max;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height);
    final r = size.width * 0.4;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF455A64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final ratio = (value / max).clamp(0.0, 1.0);
    final a = math.pi + ratio * math.pi;
    canvas.drawLine(
      c,
      Offset(c.dx + (r - 6) * math.cos(a), c.dy + (r - 6) * math.sin(a)),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _NeedlePainter old) => old.value != value;
}

class _AccelMeter extends StatelessWidget {
  const _AccelMeter({required this.acceleration});
  final double acceleration;

  @override
  Widget build(BuildContext context) {
    // PhET scale ~4.22 maps ~10 m/s² to first tick.
    final needle = (acceleration * 4.22).clamp(-80.0, 80.0);
    return Column(
      children: [
        Container(
          width: 160,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black54),
          ),
          child: Stack(
            children: [
              const Center(child: Text('|', style: TextStyle(fontSize: 10))),
              Positioned(
                left: 80 + needle - 4,
                top: 2,
                child: Container(
                  width: 8,
                  height: 24,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${acceleration.toStringAsFixed(1)} m/s²',
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

class _PanelSpeedIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height);
    final r = size.height * 0.85;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      3.14159,
      3.14159,
      false,
      Paint()
        ..color = const Color(0xFF455A64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
