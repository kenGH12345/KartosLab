import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/assets/esp_assets.dart';
import 'package:kratos/energy_skate_park/model/skater_image_set.dart';

/// Joist ScreenIcon — scaled tab thumbnail from PhET PNG assets.
///
/// Intro / Playground compose skater overlay per IntroScreenIcon.ts /
/// PlaygroundScreenIcon.ts.
class EspScreenTabIcon extends StatelessWidget {
  const EspScreenTabIcon.intro({super.key}) : _kind = _Kind.intro;

  const EspScreenTabIcon.measure({super.key}) : _kind = _Kind.measure;

  const EspScreenTabIcon.graphs({super.key}) : _kind = _Kind.graphs;

  const EspScreenTabIcon.playground({super.key}) : _kind = _Kind.playground;

  final _Kind _kind;

  static const double tabHeight = 28;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tabHeight,
      width: tabHeight * (548 / 374),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_kind) {
      case _Kind.intro:
        return _CompositeIcon(
          background: EspAssets.introScreenIcon,
          skaterAsset: SkaterImageSet.at(0).rightAsset,
          skaterTx: 95,
          skaterTy: 150,
          rotation: 1.1 * math.pi / 3,
          scale: 0.5,
        );
      case _Kind.measure:
        return Image.asset(EspAssets.measureScreenIcon, fit: BoxFit.cover);
      case _Kind.graphs:
        return Image.asset(EspAssets.graphsScreenIcon, fit: BoxFit.cover);
      case _Kind.playground:
        return _CompositeIcon(
          background: EspAssets.playgroundScreenIcon,
          skaterAsset: SkaterImageSet.at(7).rightAsset,
          skaterTx: 375,
          skaterTy: 110,
          rotation: -2 * math.pi / 3,
          scale: 0.5,
        );
    }
  }
}

enum _Kind { intro, measure, graphs, playground }

class _CompositeIcon extends StatelessWidget {
  const _CompositeIcon({
    required this.background,
    required this.skaterAsset,
    required this.skaterTx,
    required this.skaterTy,
    required this.rotation,
    required this.scale,
  });

  final String background;
  final String skaterAsset;
  final double skaterTx;
  final double skaterTy;
  final double rotation;
  final double scale;

  static const double _srcW = 548;
  static const double _srcH = 374;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sx = constraints.maxWidth / _srcW;
        final sy = constraints.maxHeight / _srcH;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(background, fit: BoxFit.cover),
            _SkaterOverlay(
              asset: skaterAsset,
              sx: sx,
              sy: sy,
              tx: skaterTx,
              ty: skaterTy,
              rotation: rotation,
              scale: scale,
            ),
          ],
        );
      },
    );
  }
}

class _SkaterOverlay extends StatelessWidget {
  const _SkaterOverlay({
    required this.asset,
    required this.sx,
    required this.sy,
    required this.tx,
    required this.ty,
    required this.rotation,
    required this.scale,
  });

  final String asset;
  final double sx;
  final double sy;
  final double tx;
  final double ty;
  final double rotation;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      frameBuilder: (context, child, frame, wasSync) {
        if (frame == null) return const SizedBox.shrink();
        return Transform(
          transform: Matrix4.identity()
            ..translateByDouble(tx * sx, ty * sy, 0, 1)
            ..rotateZ(rotation)
            ..scaleByDouble(scale * sx, scale * sy, 1, 1)
            ..translateByDouble(-30 * sx, -60 * sy, 0, 1),
          alignment: Alignment.topLeft,
          child: child,
        );
      },
    );
  }
}
