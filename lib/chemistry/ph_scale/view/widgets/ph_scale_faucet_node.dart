import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ph_scale_assets.dart';
import '../ph_scale_fonts.dart';

/// scenery-phet `FaucetNode` for pH Scale.
///
/// Origin = spout bottom-center. Water/Drain: scale 0.6 + horizontal flip.
///
/// Interaction (PhET `FaucetNode` + `PHScaleConstants.FAUCET_OPTIONS`):
/// - Drag shooter → flow follows track; release closes when [closeOnRelease].
/// - Tap (no drag) → [tapToDispense] burst for [tapToDispenseInterval].
class PhScaleFaucetNode extends StatefulWidget {
  const PhScaleFaucetNode({
    super.key,
    required this.position,
    required this.pipeMinX,
    required this.flowRate,
    required this.maxFlowRate,
    required this.enabled,
    required this.onFlowChanged,
    this.verticalPipeLength = 20,
    this.label,
    this.mirror = true,
    this.closeOnRelease = true,
    this.tapToDispenseEnabled = true,
    this.tapToDispenseAmount = 0.05,
    this.tapToDispenseInterval = const Duration(milliseconds: 333),
  });

  final Offset position;
  final double pipeMinX;
  final double flowRate;
  final double maxFlowRate;
  final bool enabled;
  final ValueChanged<double> onFlowChanged;
  final double verticalPipeLength;
  final String? label;
  final bool mirror;
  final bool closeOnRelease;

  /// PhET default + pH Scale: tap shooter without drag dispenses a burst.
  final bool tapToDispenseEnabled;

  /// Liters dispensed per tap (`PHScaleConstants.FAUCET_OPTIONS`).
  final double tapToDispenseAmount;

  /// Burst duration (`PHScaleConstants.FAUCET_OPTIONS` = 333 ms).
  final Duration tapToDispenseInterval;

  static const double scale = 0.6;

  static Rect layoutBounds({
    required Offset position,
    required double pipeMinX,
    required double verticalPipeLength,
    bool mirror = true,
  }) {
    final g = _Layout.compute(
      positionX: position.dx,
      pipeMinX: pipeMinX,
      verticalPipeLength: verticalPipeLength,
      mirror: mirror,
      flowFraction: 1, // worst-case shooter extent
    );
    return Rect.fromLTRB(
      position.dx + g.minX,
      position.dy + g.minY,
      position.dx + g.maxX,
      position.dy + g.maxY,
    );
  }

  @override
  State<PhScaleFaucetNode> createState() => _PhScaleFaucetNodeState();
}

class _Sprite {
  const _Sprite({
    required this.asset,
    required this.left,
    required this.top,
    required this.w,
    required this.h,
    required this.flipX,
  });

  final String asset;
  final double left, top, w, h;
  final bool flipX;
}

class _Layout {
  _Layout({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.sprites,
    required this.trackLeft,
    required this.trackTop,
    required this.trackW,
    required this.trackH,
    required this.spoutLeft,
    required this.spoutTop,
    required this.spoutW,
    required this.spoutH,
    required this.shooterHitLeft,
    required this.shooterHitRight,
  });

  final double minX, minY, maxX, maxY;
  final List<_Sprite> sprites;
  final double trackLeft, trackTop, trackW, trackH;
  final double spoutLeft, spoutTop, spoutW, spoutH;
  final double shooterHitLeft, shooterHitRight;

  static const _spoutW = 118.0, _spoutH = 64.0;
  static const _bodyW = 154.0, _bodyH = 84.0;
  static const _vertW = 85.0, _horizH = 84.0;
  static const _trackW = 106.0, _trackH = 46.0;
  static const _shaftW = 110.0, _shaftH = 22.0;
  static const _flangeW = 29.0, _flangeH = 56.0;
  static const _knobW = 73.0, _knobH = 120.0;
  static const _stop = 9.0;
  static const _spoutCx = 112.0;
  static const _hOverlap = 1.0, _vOverlap = 1.0;
  static const _trackYOff = 15.0;
  static const _shooterMin = 4.0, _shooterMax = 66.0, _shooterY = 16.0;
  static const _knobSc = 0.6;

  static _Layout compute({
    required double positionX,
    required double pipeMinX,
    required double verticalPipeLength,
    required bool mirror,
    required double flowFraction,
    bool enabled = true,
  }) {
    final sc = PhScaleFaucetNode.scale;
    final sx = mirror ? -sc : sc;
    final sy = sc;

    double mx(double x) => x * sx;
    double my(double y) => y * sy;
    double left(double a, double b) => math.min(mx(a), mx(b));
    double width(double a, double b) => (mx(b) - mx(a)).abs();

    final pipeLen = (positionX - pipeMinX).abs() / sc;
    final f = flowFraction.clamp(0.0, 1.0);
    final flangeAsset = enabled
        ? PhScaleAssets.faucetFlange
        : PhScaleAssets.faucetFlangeDisabled;
    final knobAsset = enabled
        ? PhScaleAssets.faucetKnob
        : PhScaleAssets.faucetKnobDisabled;

    // Native (FaucetNode.ts)
    const nSpoutL = -_spoutW / 2, nSpoutR = _spoutW / 2, nSpoutT = -_spoutH;
    final nVertH = verticalPipeLength + 2 * _vOverlap;
    const nVertL = -_vertW / 2, nVertR = _vertW / 2;
    final nVertB = nSpoutT + _vOverlap;
    final nVertT = nVertB - nVertH;
    final nBodyR = nVertR;
    final nBodyL = nBodyR - _bodyW;
    final nBodyB = nVertT + _vOverlap;
    final nBodyT = nBodyB - _bodyH;
    final nHorizW = pipeLen - _spoutCx + _hOverlap;
    final nHorizR = nBodyL + _hOverlap;
    final nHorizL = nHorizR - nHorizW;
    final nHorizT = nBodyT;
    final nTrackL = nBodyL;
    final nTrackR = nBodyL + _trackW;
    final nTrackB = nBodyT + _trackYOff;
    final nTrackT = nTrackB - _trackH;

    final nShaftL = nBodyL + _shooterMin + f * (_shooterMax - _shooterMin);
    final nShaftR = nShaftL + _shaftW;
    final nShaftCY = nTrackT + _shooterY;
    final nShaftT = nShaftCY - _shaftH / 2;
    final nStopL = nShaftL + 13;
    final nFlangeL = nShaftR - 1;
    final nFlangeR = nFlangeL + _flangeW;
    final nKnobL = nFlangeR - 8;
    final nKnobR = nKnobL + _knobW * _knobSc;
    final nKnobT = nShaftCY - (_knobH * _knobSc) / 2;
    final nFlangeT = nShaftCY - _flangeH / 2;

    _Sprite spr(String asset, double nl, double nr, double nt, double nh,
            {bool flip = true}) =>
        _Sprite(
          asset: asset,
          left: left(nl, nr),
          top: my(nt),
          w: width(nl, nr),
          h: nh * sy,
          flipX: mirror && flip,
        );

    final sprites = <_Sprite>[
      spr(PhScaleAssets.faucetHorizontalPipe, nHorizL, nHorizR, nHorizT, _horizH),
      spr(PhScaleAssets.faucetVerticalPipe, nVertL, nVertR, nVertT, nVertH,
          flip: false),
      spr(PhScaleAssets.faucetSpout, nSpoutL, nSpoutR, nSpoutT, _spoutH),
      spr(PhScaleAssets.faucetBody, nBodyL, nBodyR, nBodyT, _bodyH),
      spr(PhScaleAssets.faucetTrack, nTrackL, nTrackR, nTrackT, _trackH),
      spr(PhScaleAssets.faucetShaft, nShaftL, nShaftR, nShaftT, _shaftH),
      spr(PhScaleAssets.faucetStop, nStopL, nStopL + _stop,
          nShaftCY - _stop / 2, _stop),
      spr(flangeAsset, nFlangeL, nFlangeR, nFlangeT, _flangeH),
      spr(knobAsset, nKnobL, nKnobR, nKnobT, _knobH * _knobSc),
    ];

    final xs = [for (final s in sprites) ...[s.left, s.left + s.w]];
    final ys = [for (final s in sprites) ...[s.top, s.top + s.h]];

    return _Layout(
      minX: xs.reduce(math.min),
      minY: ys.reduce(math.min),
      maxX: xs.reduce(math.max),
      maxY: ys.reduce(math.max),
      sprites: sprites,
      trackLeft: left(nTrackL, nTrackR),
      trackTop: my(nTrackT),
      trackW: width(nTrackL, nTrackR),
      trackH: _trackH * sy,
      spoutLeft: left(nSpoutL, nSpoutR),
      spoutTop: my(nSpoutT),
      spoutW: width(nSpoutL, nSpoutR),
      spoutH: _spoutH * sy,
      shooterHitLeft: left(nShaftL, nKnobR),
      shooterHitRight: math.max(mx(nShaftL), mx(nKnobR)),
    );
  }
}

class _PhScaleFaucetNodeState extends State<PhScaleFaucetNode> {
  final GlobalKey _hitKey = GlobalKey();

  /// Pointer is down on the shooter hit strip.
  bool _pointerDown = false;

  /// True once the pointer moved enough to count as a drag (cancels tap).
  bool _didDrag = false;

  /// PhET `tapToDispenseIsArmed` — fire burst on release if no drag.
  bool _tapArmed = false;

  /// PhET `tapToDispenseIsRunning`.
  bool _tapRunning = false;

  Timer? _tapTimer;
  Offset? _downGlobal;

  /// Ignore sub-pixel jitter so a click still counts as tap.
  static const double _dragSlop = 4.0;

  double get _fraction => widget.maxFlowRate > 0
      ? (widget.flowRate / widget.maxFlowRate).clamp(0.0, 1.0)
      : 0.0;

  void _setFraction(double t) {
    if (!widget.enabled) return;
    widget.onFlowChanged(t.clamp(0.0, 1.0) * widget.maxFlowRate);
  }

  /// Map hit-local X → flow. Mirrored: left = open.
  void _applyHitLocalX(double localX, double width) {
    if (!widget.enabled || width <= 0) return;
    final raw = (localX / width).clamp(0.0, 1.0);
    final t = widget.mirror ? (1.0 - raw) : raw;
    _setFraction(t);
  }

  double get _tapFlowRate {
    final ms = widget.tapToDispenseInterval.inMilliseconds;
    if (ms <= 0) return widget.maxFlowRate;
    final rate = (widget.tapToDispenseAmount / ms) * 1000.0;
    return rate.clamp(0.0, widget.maxFlowRate);
  }

  void _endTapToDispense() {
    _tapTimer?.cancel();
    _tapTimer = null;
    if (_tapRunning) {
      _tapRunning = false;
      widget.onFlowChanged(0);
    }
  }

  void _startTapToDispense() {
    if (!widget.enabled || !widget.tapToDispenseEnabled) return;
    _endTapToDispense();
    _tapArmed = false;
    _tapRunning = true;
    widget.onFlowChanged(_tapFlowRate);
    _tapTimer = Timer(widget.tapToDispenseInterval, () {
      if (!mounted) return;
      _tapRunning = false;
      _tapTimer = null;
      widget.onFlowChanged(0);
    });
  }

  void _onPointerDown(PointerDownEvent e) {
    if (!widget.enabled) return;
    final box = _hitKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _pointerDown = true;
    _didDrag = false;
    _downGlobal = e.position;
    // Arm tap; do NOT set flow from knob X — closed knob sits at flow≈0.
    _tapArmed = widget.tapToDispenseEnabled;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (!_pointerDown || !widget.enabled) return;
    final box = _hitKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    if (!_didDrag) {
      final origin = _downGlobal;
      if (origin != null && (e.position - origin).distance < _dragSlop) {
        return;
      }
      _didDrag = true;
      _tapArmed = false;
      if (_tapRunning) _endTapToDispense();
    }

    final local = box.globalToLocal(e.position);
    _applyHitLocalX(local.dx, box.size.width);
  }

  void _finishPointer({required bool cancelled}) {
    if (!_pointerDown) return;
    _pointerDown = false;
    final armed = _tapArmed && !cancelled;
    final dragged = _didDrag;
    _tapArmed = false;
    _didDrag = false;
    _downGlobal = null;

    if (!widget.enabled) return;

    if (armed) {
      // Tap toggles: if already dispensing / open, stop; else start burst.
      if (_tapRunning || widget.flowRate != 0) {
        _endTapToDispense();
        widget.onFlowChanged(0);
      } else {
        _startTapToDispense();
      }
      return;
    }

    if (dragged && widget.closeOnRelease) {
      widget.onFlowChanged(0);
    }
  }

  void _onPointerUp(PointerUpEvent e) => _finishPointer(cancelled: false);

  void _onPointerCancel(PointerCancelEvent e) => _finishPointer(cancelled: true);

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = _Layout.compute(
      positionX: widget.position.dx,
      pipeMinX: widget.pipeMinX,
      verticalPipeLength: widget.verticalPipeLength,
      mirror: widget.mirror,
      flowFraction: _fraction,
      enabled: widget.enabled,
    );

    final stackW = g.maxX - g.minX;
    final stackH = g.maxY - g.minY;

    // Hit strip covering track + blue knob (shooter).
    final hitLeft = math.min(g.trackLeft, g.shooterHitLeft) - 16;
    final hitRight = math.max(g.trackLeft + g.trackW, g.shooterHitRight) + 16;
    final hitTop = g.trackTop - 36;
    final hitW = math.max(48.0, hitRight - hitLeft);
    final hitH = g.trackH + 80;

    final faucet = SizedBox(
      width: stackW,
      height: stackH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final s in g.sprites)
            Positioned(
              left: s.left - g.minX,
              top: s.top - g.minY,
              child: s.flipX
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(-1, 1, 1),
                      child: Image.asset(
                        s.asset,
                        width: s.w,
                        height: s.h,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                      ),
                    )
                  : Image.asset(
                      s.asset,
                      width: s.w,
                      height: s.h,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.medium,
                    ),
            ),
          if (_fraction > 0)
            Positioned(
              left: g.spoutLeft + g.spoutW * 0.38 - g.minX,
              top: g.spoutTop + g.spoutH - 2 - g.minY,
              child: IgnorePointer(
                child: Container(
                  width: 8 + 24 * _fraction,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(180, 224, 255, 255),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          Positioned(
            key: _hitKey,
            left: hitLeft - g.minX,
            top: hitTop - g.minY,
            width: hitW,
            height: hitH,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerCancel,
              // Tap = tapToDispense; drag = flow; release after drag = close.
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );

    final labelLeft = math.max(0.0, g.sprites.first.left - g.minX + 16);
    const labelH = 34.0;

    return Positioned(
      left: widget.position.dx + g.minX,
      top: widget.position.dy + g.minY - (widget.label != null ? labelH : 0),
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null)
              IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.only(left: labelLeft, bottom: 2),
                  child: Text(widget.label!, style: PhScaleFonts.waterLabel),
                ),
              ),
            faucet,
          ],
        ),
      ),
    );
  }
}
