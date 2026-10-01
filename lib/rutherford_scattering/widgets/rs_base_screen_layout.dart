import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/rutherford_scattering/controller/rs_simulation_controller.dart';
import 'package:kratos/rutherford_scattering/painters/rs_observation_painter.dart';
import 'package:kratos/rutherford_scattering/rs_assets.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_constants.dart';
import 'package:kratos/rutherford_scattering/rs_layout.dart';
import 'package:kratos/rutherford_scattering/transform/rs_transform.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_control_panels.dart';
import 'package:kratos/rutherford_scattering/widgets/rs_gun_widget.dart';

/// Shared PhET layout at 1024×618 — geometry from [RsLayout].
class RsBaseScreenLayout extends StatelessWidget {
  const RsBaseScreenLayout({
    super.key,
    required this.controller,
    required this.mode,
    required this.particleStyle,
    required this.scaleLabel,
    required this.panels,
    this.beamColor = RsColors.atomBeam,
    this.plumPuddingImage,
    this.sceneRadio,
  });

  final RsSimulationController controller;
  final RsObservationMode mode;
  final RsParticleStyle particleStyle;
  final String scaleLabel;
  final List<Widget> panels;
  final Color beamColor;
  final ui.Image? plumPuddingImage;

  /// Left vertical Atomic/Nuclear selector (Rutherford Atom only).
  final Widget? sceneRadio;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RsColors.background,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: RsLayout.layoutW,
          height: RsLayout.layoutH,
          child: _LayoutBody(
            controller: controller,
            mode: mode,
            particleStyle: particleStyle,
            scaleLabel: scaleLabel,
            panels: panels,
            beamColor: beamColor,
            plumPuddingImage: plumPuddingImage,
            sceneRadio: sceneRadio,
          ),
        ),
      ),
    );
  }
}

class _LayoutBody extends StatelessWidget {
  const _LayoutBody({
    required this.controller,
    required this.mode,
    required this.particleStyle,
    required this.scaleLabel,
    required this.panels,
    required this.beamColor,
    required this.plumPuddingImage,
    required this.sceneRadio,
  });

  final RsSimulationController controller;
  final RsObservationMode mode;
  final RsParticleStyle particleStyle;
  final String scaleLabel;
  final List<Widget> panels;
  final Color beamColor;
  final ui.Image? plumPuddingImage;
  final Widget? sceneRadio;

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final transform = RsTransform(
      modelBounds: model.bounds,
      viewBounds: const Rect.fromLTWH(
        0,
        0,
        RsLayout.spaceSize,
        RsLayout.spaceSize,
      ),
    );

    return Stack(
      children: [
        // Dashed zoom lines (decorative only — must not steal taps)
        Positioned(
          left: 0,
          top: 0,
          width: RsLayout.layoutW,
          height: RsLayout.layoutH,
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ZoomLinesPainter(
                foilCenter: Offset(RsLayout.foilCenterX, RsLayout.foilCenterY),
                foilHalfH: RsLayout.foilH / 2,
                spaceLeft: RsLayout.spaceLeft,
                spaceTop: RsLayout.spaceTop,
                spaceBottom: RsLayout.spaceBottom,
              ),
            ),
          ),
        ),

        // Gun / beam / foil — above zoom lines so red button receives taps
        Positioned.fill(
          child: RsGunAssembly(
            gunOn: model.gun.on,
            onToggle: () => controller.setGunOn(!model.gun.on),
            beamColor: beamColor,
          ),
        ),

        // Left vertical scene radio
        if (sceneRadio != null)
          Positioned(
            left: RsLayout.sceneLeft,
            top: RsLayout.sceneTop,
            child: sceneRadio!,
          ),

        // Observation window
        Positioned(
          left: RsLayout.spaceLeft,
          top: RsLayout.spaceTop,
          width: RsLayout.spaceSize,
          height: RsLayout.spaceSize,
          child: IgnorePointer(
            child: CustomPaint(
              size: const Size(RsLayout.spaceSize, RsLayout.spaceSize),
              painter: RsObservationPainter(
                model: model,
                transform: transform,
                mode: mode,
                particleStyle: particleStyle,
                plumPuddingImage: plumPuddingImage,
                revision: model.revision,
              ),
            ),
          ),
        ),

        // Scale label
        Positioned(
          left: RsLayout.spaceLeft,
          top: RsLayout.scaleLabelTop,
          width: RsLayout.spaceSize,
          child: Text(
            scaleLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: RsColors.panelLabel,
              fontSize: 16,
            ),
          ),
        ),

        // Right control panels
        Positioned(
          left: RsLayout.panelLeft,
          top: RsLayout.panelTop,
          width: RsLayout.panelWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < panels.length; i++) ...[
                if (i > 0)
                  const SizedBox(height: RsConstants.panelVerticalMargin),
                panels[i],
              ],
            ],
          ),
        ),

        // Time controls
        Positioned(
          left: RsLayout.timeCenterX - 48,
          top: RsLayout.timeBottom - 46,
          child: RsTimeControls(controller: controller),
        ),

        // Reset All
        Positioned(
          left: RsLayout.resetRight - RsConstants.resetAllRadius * 2,
          top: RsLayout.resetBottom - RsConstants.resetAllRadius * 2,
          child: KratosResetAllButton(
            radius: RsConstants.resetAllRadius,
            onPressed: controller.reset,
          ),
        ),
      ],
    );
  }
}

class _ZoomLinesPainter extends CustomPainter {
  _ZoomLinesPainter({
    required this.foilCenter,
    required this.foilHalfH,
    required this.spaceLeft,
    required this.spaceTop,
    required this.spaceBottom,
  });

  final Offset foilCenter;
  final double foilHalfH;
  final double spaceLeft;
  final double spaceTop;
  final double spaceBottom;

  @override
  void paint(Canvas canvas, Size size) {
    _drawDashed(
      canvas,
      Offset(foilCenter.dx, foilCenter.dy - foilHalfH),
      Offset(spaceLeft, spaceTop),
    );
    _drawDashed(
      canvas,
      Offset(foilCenter.dx, foilCenter.dy + foilHalfH),
      Offset(spaceLeft, spaceBottom),
    );
  }

  void _drawDashed(Canvas canvas, Offset a, Offset b) {
    final paint = Paint()
      ..color = const Color(0xFF808080)
      ..strokeWidth = 1;
    const dash = 5.0;
    const gap = 5.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final start = a + dir * d;
      final end = a + dir * (d + dash).clamp(0, total);
      canvas.drawLine(start, end, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _ZoomLinesPainter oldDelegate) => false;
}

/// Loads plumPudding.png once for canvas drawing.
Future<ui.Image> loadRsPlumPuddingImage() async {
  final data = await rootBundle.load(RsAssets.plumPudding);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  return frame.image;
}
