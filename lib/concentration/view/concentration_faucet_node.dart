import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../concentration_assets.dart';
import '../audio/concentration_audio.dart';
import 'concentration_layout.dart';

/// scenery-phet `FaucetNode` adapted for BLL — scale 0.75, pipe from left.
class ConcentrationFaucetNode extends StatefulWidget {
  const ConcentrationFaucetNode({
    super.key,
    required this.position,
    required this.pipeMinX,
    required this.flowRate,
    required this.maxFlowRate,
    required this.enabled,
    required this.onFlowChanged,
    this.closeOnRelease = true,
    this.audio,
  });

  final Offset position;
  final double pipeMinX;
  final double flowRate;
  final double maxFlowRate;
  final bool enabled;
  final ValueChanged<double> onFlowChanged;
  final bool closeOnRelease;
  final ConcentrationAudio? audio;

  static const double scale = ConcentrationLayout.faucetScale;

  @override
  State<ConcentrationFaucetNode> createState() =>
      _ConcentrationFaucetNodeState();
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
    required this.shooterHitLeft,
    required this.shooterHitRight,
    required this.shooterHitTop,
    required this.shooterHitBottom,
  });

  final double minX, minY, maxX, maxY;
  final List<_Sprite> sprites;
  final double shooterHitLeft, shooterHitRight, shooterHitTop, shooterHitBottom;
}

class _FaucetGeom {
  static const spoutW = 118.0, spoutH = 64.0;
  static const bodyW = 154.0, bodyH = 84.0;
  static const vertW = 85.0, horizH = 84.0;
  static const trackW = 106.0, trackH = 46.0;
  static const shaftW = 110.0, shaftH = 22.0;
  static const flangeW = 29.0, flangeH = 56.0;
  static const knobW = 73.0, knobH = 120.0;
  static const stop = 9.0;
  static const spoutCx = 112.0;
  static const hOverlap = 1.0, vOverlap = 1.0;
  static const trackYOff = 15.0;
  static const shooterMin = 4.0, shooterMax = 66.0, shooterY = 16.0;
  static const knobSc = 0.6;
  static const verticalPipeLength = 20.0;

  static _Layout compute({
    required double positionX,
    required double pipeMinX,
    required double flowFraction,
    required bool enabled,
  }) {
    const sc = ConcentrationFaucetNode.scale;

    final pipeLen = (positionX - pipeMinX).abs() / sc;
    final f = flowFraction.clamp(0.0, 1.0);
    final flangeAsset = enabled
        ? ConcentrationAssets.faucetFlange
        : ConcentrationAssets.faucetFlangeDisabled;
    final knobAsset = enabled
        ? ConcentrationAssets.faucetKnob
        : ConcentrationAssets.faucetKnobDisabled;

    const nSpoutL = -spoutW / 2, nSpoutR = spoutW / 2, nSpoutT = -spoutH;
    const nVertH = verticalPipeLength + 2 * vOverlap;
    const nVertL = -vertW / 2, nVertR = vertW / 2;
    const nVertB = nSpoutT + vOverlap;
    const nVertT = nVertB - nVertH;
    const nBodyR = nVertR;
    const nBodyL = nBodyR - bodyW;
    const nBodyB = nVertT + vOverlap;
    const nBodyT = nBodyB - bodyH;
    final nHorizW = pipeLen - spoutCx + hOverlap;
    final nHorizR = nBodyL + hOverlap;
    final nHorizL = nHorizR - nHorizW;
    const nHorizT = nBodyT;
    const nTrackL = nBodyL;
    const nTrackR = nBodyL + trackW;
    const nTrackB = nBodyT + trackYOff;
    const nTrackT = nTrackB - trackH;

    final nShaftL = nBodyL + shooterMin + f * (shooterMax - shooterMin);
    final nShaftR = nShaftL + shaftW;
    const nShaftCY = nTrackT + shooterY;
    const nShaftT = nShaftCY - shaftH / 2;
    final nStopL = nShaftL + 13;
    final nFlangeL = nShaftR - 1;
    final nFlangeR = nFlangeL + flangeW;
    final nKnobL = nFlangeR - 8;
    final nKnobR = nKnobL + knobW * knobSc;
    final nKnobT = nShaftCY - (knobH * knobSc) / 2;
    final nFlangeT = nShaftCY - flangeH / 2;

    _Sprite spr(String asset, double nl, double nr, double nt, double nh) =>
        _Sprite(
          asset: asset,
          left: nl * sc,
          top: nt * sc,
          w: (nr - nl) * sc,
          h: nh * sc,
        );

    final sprites = <_Sprite>[
      spr(ConcentrationAssets.faucetHorizontalPipe, nHorizL, nHorizR, nHorizT,
          horizH),
      spr(ConcentrationAssets.faucetVerticalPipe, nVertL, nVertR, nVertT, nVertH),
      spr(ConcentrationAssets.faucetSpout, nSpoutL, nSpoutR, nSpoutT, spoutH),
      spr(ConcentrationAssets.faucetBody, nBodyL, nBodyR, nBodyT, bodyH),
      spr(ConcentrationAssets.faucetTrack, nTrackL, nTrackR, nTrackT, trackH),
      spr(ConcentrationAssets.faucetShaft, nShaftL, nShaftR, nShaftT, shaftH),
      spr(ConcentrationAssets.faucetStop, nStopL, nStopL + stop,
          nShaftCY - stop / 2, stop),
      spr(flangeAsset, nFlangeL, nFlangeR, nFlangeT, flangeH),
      spr(knobAsset, nKnobL, nKnobR, nKnobT, knobH * knobSc),
    ];

    final xs = [for (final s in sprites) ...[s.left, s.left + s.w]];
    final ys = [for (final s in sprites) ...[s.top, s.top + s.h]];

    return _Layout(
      minX: xs.reduce(math.min),
      minY: ys.reduce(math.min),
      maxX: xs.reduce(math.max),
      maxY: ys.reduce(math.max),
      sprites: sprites,
      shooterHitLeft: math.min(nShaftL, nKnobL) * sc,
      shooterHitRight: math.max(nShaftR, nKnobR) * sc,
      shooterHitTop: nKnobT * sc,
      shooterHitBottom: (nKnobT + knobH * knobSc) * sc,
    );
  }
}

class _ConcentrationFaucetNodeState extends State<ConcentrationFaucetNode> {
  double get _fraction => widget.maxFlowRate > 0
      ? (widget.flowRate / widget.maxFlowRate).clamp(0.0, 1.0)
      : 0.0;

  void _setFraction(double t) {
    if (!widget.enabled) return;
    widget.onFlowChanged(t.clamp(0.0, 1.0) * widget.maxFlowRate);
  }

  @override
  Widget build(BuildContext context) {
    final layout = _FaucetGeom.compute(
      positionX: widget.position.dx,
      pipeMinX: widget.pipeMinX,
      flowFraction: _fraction,
      enabled: widget.enabled,
    );

    return Positioned(
      left: widget.position.dx + layout.minX,
      top: widget.position.dy + layout.minY,
      width: layout.maxX - layout.minX,
      height: layout.maxY - layout.minY,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.55,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final s in layout.sprites)
              Positioned(
                left: s.left - layout.minX,
                top: s.top - layout.minY,
                width: s.w,
                height: s.h,
                child: Image.asset(s.asset, fit: BoxFit.fill, filterQuality: FilterQuality.medium),
              ),
            Positioned(
              left: layout.shooterHitLeft - layout.minX,
              top: layout.shooterHitTop - layout.minY,
              width: layout.shooterHitRight - layout.shooterHitLeft,
              height: layout.shooterHitBottom - layout.shooterHitTop,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) {
                  if (!widget.enabled) return;
                  widget.audio?.onDragStart();
                },
                onHorizontalDragUpdate: (d) {
                  if (!widget.enabled) return;
                  final trackW = (_FaucetGeom.shooterMax - _FaucetGeom.shooterMin) *
                      ConcentrationFaucetNode.scale;
                  _setFraction(_fraction + d.delta.dx / trackW);
                },
                onHorizontalDragEnd: (_) {
                  if (widget.closeOnRelease) {
                    _setFraction(0);
                    // Source FaucetNode: release sound when closeOnRelease zeros flow.
                    widget.audio?.onFaucetClosed();
                  } else {
                    widget.audio?.onDragEnd();
                  }
                },
                onHorizontalDragCancel: () {
                  if (widget.closeOnRelease) _setFraction(0);
                  widget.audio?.onDragEnd(interrupted: true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fluid stream scaffold — `FaucetFluidNode.ts` (inactive when flowRate == 0).
class FaucetFluidNode extends StatelessWidget {
  const FaucetFluidNode({
    super.key,
    required this.position,
    required this.flowRate,
    required this.maxFlowRate,
    required this.spoutWidth,
    required this.height,
    required this.color,
  });

  final Offset position;
  final double flowRate;
  final double maxFlowRate;
  final double spoutWidth;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (flowRate <= 0 || maxFlowRate <= 0) return const SizedBox.shrink();
    final w = spoutWidth * (flowRate / maxFlowRate);
    return Positioned(
      left: position.dx - w / 2,
      top: position.dy,
      width: w,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Color.lerp(color, Colors.black, 0.25)!),
        ),
      ),
    );
  }
}
