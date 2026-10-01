import 'package:flutter/material.dart';

import '../../domain/source_type.dart';
import '../common/qwi_layout.dart';
import 'experiment_controller.dart';

/// Overhead emitter (PhET `OverheadEmitterNode` / scenery-phet `LaserPointerNode`).
///
/// Body + nozzle + red sticky button; origin visually at nozzle tip for beam alignment.
class ExperimentSourceView extends StatelessWidget {
  const ExperimentSourceView({super.key, required this.controller});

  final ExperimentController controller;

  // OverheadEmitterNode: SOURCE_SCALE = OVERHEAD_SCALE * 1.15
  static const double _sourceScale = QwiLayout.overheadElementScale * 1.15;
  static const double _bodyW = 88;
  static const double _bodyH = 40;
  static const double _nozzleW = 16;

  @override
  Widget build(BuildContext context) {
    final emitting = controller.scene.isEmitting;
    final isPhoton = controller.scene.sourceType == SourceType.photons;
    final beamColor = isPhoton
        ? _photonColor(controller.scene.wavelengthNm)
        : const Color(0xFFCCCCCC);

    final emitterW = (_bodyW + _nozzleW) * _sourceScale;
    final emitterH = _bodyH * _sourceScale;
    final left = QwiLayout.experiment.sourcePanel.centerX - emitterW / 2;

    // Align body centerY with overhead beamY.
    final overheadH = QwiLayout.frontFacingRowTop - QwiLayout.detectorScaleBarBand;
    final beamY = overheadH * QwiLayout.overheadBeamYFraction;
    final labelGap = 10 * QwiLayout.overheadElementScale;
    final labelStyle = const TextStyle(
      fontFamily: 'Arial',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    return Positioned(
      left: left,
      top: 0,
      width: emitterW,
      height: overheadH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: beamY - emitterH / 2 - labelGap - 18,
            width: emitterW,
            child: Text(
              _sourceLabel(controller.scene.sourceType),
              textAlign: TextAlign.center,
              style: labelStyle,
            ),
          ),
          Positioned(
            left: 0,
            top: beamY - emitterH / 2,
            child: GestureDetector(
              key: const Key('qwi_emitter'),
              onTap: controller.toggleEmitting,
              child: CustomPaint(
                size: Size(emitterW, emitterH),
                painter: _EmitterPainter(
                  emitting: emitting,
                  beamColor: beamColor,
                  isPhoton: isPhoton,
                  sourceScale: _sourceScale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _sourceLabel(SourceType type) {
    switch (type) {
      case SourceType.photons:
        return 'Photon Source';
      case SourceType.electrons:
        return 'Electron Source';
      case SourceType.neutrons:
        return 'Neutron Source';
      case SourceType.heliumAtoms:
        return 'Helium Atom Source';
    }
  }

  Color _photonColor(double nm) {
    if (nm < 450) return const Color(0xFF7F00FF);
    if (nm < 495) return const Color(0xFF0000FF);
    if (nm < 570) return const Color(0xFF00FF00);
    if (nm < 590) return const Color(0xFFFFFF00);
    if (nm < 620) return const Color(0xFFFF7F00);
    return const Color(0xFFFF0000);
  }
}

class _EmitterPainter extends CustomPainter {
  _EmitterPainter({
    required this.emitting,
    required this.beamColor,
    required this.isPhoton,
    required this.sourceScale,
  });

  final bool emitting;
  final Color beamColor;
  final bool isPhoton;
  final double sourceScale;

  @override
  void paint(Canvas canvas, Size size) {
    // LaserPointerNode: origin at nozzle tip (right); body left of nozzle.
    final bodyW = 88 * sourceScale;
    final bodyH = 40 * sourceScale;
    final nozzleW = 16 * sourceScale;
    final nozzleH = 32 * sourceScale;
    final buttonR = 14 * sourceScale;
    const corner = 5.0;

    final cy = size.height / 2;
    final nozzleLeft = bodyW - corner; // overlap to hide corner radius
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, cy - bodyH / 2, bodyW, bodyH),
      const Radius.circular(corner),
    );
    final nozzleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(nozzleLeft, cy - nozzleH / 2, nozzleW + corner, nozzleH),
      const Radius.circular(3),
    );

    // Default photon palette (LaserPointerNode defaults); matter uses cooler metal.
    final top = isPhoton ? const Color(0xFFAAAAAA) : const Color(0xFF6478B4);
    final mid = isPhoton ? const Color(0xFFF5F5F5) : const Color(0xFFC8D0E8);
    final bot = isPhoton ? const Color(0xFF282828) : const Color(0xFF283048);

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, mid, bot],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final nozzlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, mid, bot],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(nozzleRect.outerRect);
    canvas.drawRRect(nozzleRect, nozzlePaint);
    canvas.drawRRect(
      nozzleRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Red sticky toggle (PhET baseColor: red).
    final btnCenter = Offset(bodyW / 2, cy);
    final btnFill = emitting ? const Color(0xFFE53935) : const Color(0xFFC62828);
    canvas.drawCircle(btnCenter, buttonR, Paint()..color = btnFill);
    // Soft highlight
    canvas.drawCircle(
      btnCenter.translate(-buttonR * 0.25, -buttonR * 0.25),
      buttonR * 0.35,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      btnCenter,
      buttonR,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (emitting) {
      final tipX = nozzleLeft + nozzleW + corner;
      final beam = Path()
        ..moveTo(tipX, cy - 5)
        ..lineTo(size.width + 12, cy - 8)
        ..lineTo(size.width + 12, cy + 8)
        ..lineTo(tipX, cy + 5)
        ..close();
      canvas.drawPath(beam, Paint()..color = beamColor.withValues(alpha: 0.55));
    }
  }

  @override
  bool shouldRepaint(covariant _EmitterPainter oldDelegate) {
    return oldDelegate.emitting != emitting ||
        oldDelegate.beamColor != beamColor ||
        oldDelegate.isPhoton != isPhoton ||
        oldDelegate.sourceScale != sourceScale;
  }
}
