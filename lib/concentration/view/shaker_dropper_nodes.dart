import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../concentration_assets.dart';
import '../audio/concentration_audio.dart';
import '../model/concentration_model.dart';
import '../model/solute_form.dart';
import 'concentration_layout.dart';

/// Shaker image node — `ShakerNode.ts` + `SoundDragListener` grab/release.
class ShakerNode extends StatelessWidget {
  const ShakerNode({
    super.key,
    required this.model,
    required this.label,
    this.audio,
  });

  final ConcentrationModel model;
  final String label;
  final ConcentrationAudio? audio;

  static const double imageScale = ConcentrationLayout.shakerImageScale;

  @override
  Widget build(BuildContext context) {
    if (model.soluteForm != SoluteForm.solid) {
      return const SizedBox.shrink();
    }

    final pos = model.shaker.position;
    final orientation = model.shaker.orientation;

    // Approximate scaled image footprint for hit testing
    const baseW = 180.0;
    const baseH = 70.0;

    return Positioned(
      left: pos.dx - baseW / 2,
      top: pos.dy - baseH / 2,
      width: baseW,
      height: baseH,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => audio?.onDragStart(),
        onPanUpdate: (d) {
          model.setShakerPosition(model.shaker.position + d.delta);
        },
        onPanEnd: (_) => audio?.onDragEnd(),
        onPanCancel: () => audio?.onDragEnd(interrupted: true),
        child: Transform.rotate(
          angle: orientation - math.pi,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: imageScale,
                child: Image.asset(
                  ConcentrationAssets.shaker,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dropper — scenery-phet `EyeDropperNode` assets; fixed position.
class DropperNode extends StatelessWidget {
  const DropperNode({
    super.key,
    required this.model,
    required this.label,
    required this.fluidColor,
  });

  final ConcentrationModel model;
  final String label;
  final Color fluidColor;

  static const double tipWidth = 15;
  static const double glassWidth = 46;
  static const double glassMinY = -124;
  static const double glassMaxY = -18;

  @override
  Widget build(BuildContext context) {
    if (model.soluteForm != SoluteForm.solution) {
      return const SizedBox.shrink();
    }

    final pos = model.dropper.position;
    const imgH = 150.0;
    const imgW = 60.0;

    return Positioned(
      left: pos.dx - imgW / 2,
      top: pos.dy - imgH,
      width: imgW,
      height: imgH + 10,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: (imgW - glassWidth) / 2,
            top: imgH + glassMinY,
            width: glassWidth,
            height: glassMaxY - glassMinY,
            child: ColoredBox(
              color: model.dropper.isEmpty
                  ? Colors.transparent
                  : fluidColor.withValues(alpha: 0.85),
            ),
          ),
          Image.asset(
            ConcentrationAssets.eyeDropperBackground,
            width: imgW,
            height: imgH,
            fit: BoxFit.contain,
          ),
          Image.asset(
            ConcentrationAssets.eyeDropperForeground,
            width: imgW,
            height: imgH,
            fit: BoxFit.contain,
          ),
          Positioned(
            top: 36,
            child: Transform.rotate(
              angle: -math.pi / 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            child: Listener(
              onPointerDown: (_) {
                if (model.dropper.enabled) {
                  model.setDropperDispensing(true);
                }
              },
              onPointerUp: (_) => model.setDropperDispensing(false),
              onPointerCancel: (_) => model.setDropperDispensing(false),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: model.dropper.enabled
                      ? const Color(0xFFE53935)
                      : Colors.grey,
                  border: Border.all(color: Colors.black54, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
