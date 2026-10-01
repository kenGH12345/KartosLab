import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/model/faucet/faucet_model.dart';
import 'package:kratos/under_pressure/model/pool/pool_with_faucets_model.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';

/// scenery-phet `FaucetNode` + `UnderPressureFaucetNode`.
///
/// Origin = spout bottom-center (= [FaucetModel.position]).
/// Structure matches KartosLab `PhScaleFaucetNode` (shaft → stop → flange →
/// knob@0.6). Interaction: **drag the blue knob only** for stepless flow;
/// tap does nothing; release keeps the current rate.
///
/// UP source options: `horizontalPipeLength`, `scale: faucet.scale`.
class UpFaucetNode extends StatefulWidget {
  const UpFaucetNode({
    super.key,
    required this.mvt,
    required this.faucet,
    required this.pipeLengthPx,
    required this.onFlowRate,
  });

  final UpMvt mvt;
  final FaucetModel faucet;

  /// Source `horizontalPipeLength` (unscaled native px before node scale).
  final double pipeLengthPx;
  final ValueChanged<double> onFlowRate;

  static const String _base = 'assets/simulations/under_pressure/images';

  @override
  State<UpFaucetNode> createState() => _UpFaucetNodeState();
}

class _Sprite {
  const _Sprite({
    required this.asset,
    required this.left,
    required this.top,
    required this.w,
    required this.h,
  });

  final String asset;
  final double left, top, w, h;
}

class _Layout {
  _Layout({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.sprites,
    required this.trackLeft,
    required this.knobLeft,
    required this.knobTop,
    required this.knobW,
    required this.knobH,
  });

  final double minX, minY, maxX, maxY;
  final List<_Sprite> sprites;
  final double trackLeft;
  /// Blue knob bounds (scaled, origin = spout bottom-center).
  final double knobLeft, knobTop, knobW, knobH;

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

  /// Default `FaucetNode` verticalPipeLength.
  static const verticalPipeLength = 43.0;

  static _Layout compute({
    required double scale,
    required double horizontalPipeLength,
    required double flowFraction,
    required bool enabled,
  }) {
    final sc = scale;
    final f = flowFraction.clamp(0.0, 1.0);
    final flangeAsset = enabled
        ? '${UpFaucetNode._base}/faucetFlange.png'
        : '${UpFaucetNode._base}/faucetFlangeDisabled.png';
    final knobAsset = enabled
        ? '${UpFaucetNode._base}/faucetKnob.png'
        : '${UpFaucetNode._base}/faucetKnobDisabled.png';

    // Native (FaucetNode.ts), origin = spout bottom-center
    const nSpoutL = -_spoutW / 2, nSpoutR = _spoutW / 2, nSpoutT = -_spoutH;
    final nVertH = verticalPipeLength + 2 * _vOverlap;
    const nVertL = -_vertW / 2, nVertR = _vertW / 2;
    final nVertB = nSpoutT + _vOverlap;
    final nVertT = nVertB - nVertH;
    final nBodyR = nVertR;
    final nBodyL = nBodyR - _bodyW;
    final nBodyB = nVertT + _vOverlap;
    final nBodyT = nBodyB - _bodyH;
    final nHorizW =
        (horizontalPipeLength - _spoutCx + _hOverlap).clamp(1.0, 4000.0);
    final nHorizR = nBodyL + _hOverlap;
    final nHorizL = nHorizR - nHorizW;
    final nHorizT = nBodyT;
    final nTrackL = nBodyL;
    final nTrackR = nBodyL + _trackW;
    final nTrackB = nBodyT + _trackYOff;
    final nTrackT = nTrackB - _trackH;

    // Shooter assembly relative to shaft (ShooterNode)
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

    _Sprite spr(String asset, double nl, double nr, double nt, double nh) =>
        _Sprite(
          asset: asset,
          left: nl * sc,
          top: nt * sc,
          w: (nr - nl).abs() * sc,
          h: nh * sc,
        );

    final sprites = <_Sprite>[
      spr('${UpFaucetNode._base}/faucetHorizontalPipe.png', nHorizL, nHorizR,
          nHorizT, _horizH),
      spr('${UpFaucetNode._base}/faucetVerticalPipe.png', nVertL, nVertR,
          nVertT, nVertH),
      spr('${UpFaucetNode._base}/faucetSpout.png', nSpoutL, nSpoutR, nSpoutT,
          _spoutH),
      spr('${UpFaucetNode._base}/faucetBody.png', nBodyL, nBodyR, nBodyT,
          _bodyH),
      spr('${UpFaucetNode._base}/faucetTrack.png', nTrackL, nTrackR, nTrackT,
          _trackH),
      spr('${UpFaucetNode._base}/faucetShaft.png', nShaftL, nShaftR, nShaftT,
          _shaftH),
      spr('${UpFaucetNode._base}/faucetStop.png', nStopL, nStopL + _stop,
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
      trackLeft: nTrackL * sc,
      knobLeft: nKnobL * sc,
      knobTop: nKnobT * sc,
      knobW: (_knobW * _knobSc) * sc,
      knobH: (_knobH * _knobSc) * sc,
    );
  }
}

class _UpFaucetNodeState extends State<UpFaucetNode> {
  FaucetModel get _f => widget.faucet;

  double get _fraction => _f.maxFlowRate > 0
      ? (_f.flowRate / _f.maxFlowRate).clamp(0.0, 1.0)
      : 0.0;

  void _setFraction(double t) {
    if (!_f.enabled) return;
    widget.onFlowRate(t.clamp(0.0, 1.0) * _f.maxFlowRate);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_f.enabled) return;
    final span =
        (_Layout._shooterMax - _Layout._shooterMin) * _f.scale;
    if (span <= 0) return;
    // Delta drag from the blue knob — no jump on press.
    _setFraction(_fraction + d.delta.dx / span);
  }

  @override
  Widget build(BuildContext context) {
    final origin = widget.mvt.modelToViewOffset(_f.position);
    final g = _Layout.compute(
      scale: _f.scale,
      horizontalPipeLength: widget.pipeLengthPx,
      flowFraction: _fraction,
      enabled: _f.enabled,
    );

    final stackW = g.maxX - g.minX;
    final stackH = g.maxY - g.minY;

    return Positioned(
      left: origin.dx + g.minX,
      top: origin.dy + g.minY,
      child: Opacity(
        opacity: _f.enabled ? 1 : 0.45,
        child: SizedBox(
          width: stackW,
          height: stackH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final s in g.sprites)
                Positioned(
                  left: s.left - g.minX,
                  top: s.top - g.minY,
                  child: Image.asset(
                    s.asset,
                    width: s.w,
                    height: s.h,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              // Hit target = blue knob only (not track / shaft / body).
              Positioned(
                left: g.knobLeft - g.minX,
                top: g.knobTop - g.minY,
                width: g.knobW,
                height: g.knobH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate:
                      _f.enabled ? _onDragUpdate : null,
                  child: MouseRegion(
                    cursor: _f.enabled
                        ? SystemMouseCursors.grab
                        : SystemMouseCursors.basic,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Source: `FaucetFluidNode` — stream from spout; height from pool volume.
class UpFaucetFluidNode extends StatelessWidget {
  const UpFaucetFluidNode({
    super.key,
    required this.mvt,
    required this.faucet,
    required this.pool,
    required this.fluidColor,
    required this.maxHeightPx,
  });

  final UpMvt mvt;
  final FaucetModel faucet;
  final PoolWithFaucetsModel pool;
  final Color fluidColor;
  final double maxHeightPx;

  @override
  Widget build(BuildContext context) {
    if (faucet.flowRate <= 0) return const SizedBox.shrink();
    final origin = mvt.modelToViewOffset(faucet.position);
    final viewWidth = mvt.modelToViewDeltaX(faucet.spoutWidth) *
        faucet.flowRate /
        faucet.maxFlowRate;
    final volumeFrac = pool.volume / pool.maxVolume;
    final currentHeight = maxHeightPx -
        mvt.modelToViewDeltaY(volumeFrac * pool.maxVolume).abs();
    if (currentHeight <= 0 || viewWidth <= 0) return const SizedBox.shrink();
    return Positioned(
      left: origin.dx - viewWidth / 2,
      top: origin.dy,
      width: viewWidth,
      height: currentHeight,
      child: ColoredBox(color: fluidColor),
    );
  }
}
