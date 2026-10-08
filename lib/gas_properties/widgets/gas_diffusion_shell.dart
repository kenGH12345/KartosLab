/// Legacy Gas Properties Diffusion shell.
///
/// **Product Diffusion tab** uses unmodified `lib/diffusion` via
/// [GasPropertiesDiffusionTab]. This file remains for older harnesses /
/// physics-controller experiments only.
library;

import 'package:flutter/material.dart';

import '../controller/gas_simulation_controller.dart';
import '../gas_properties_colors.dart';
import '../gas_properties_constants.dart';
import '../model/diffusion_model.dart';
import '../painters/shaded_sphere.dart';
import '../transform/gas_coordinate_transform.dart';
import 'package:kratos/gas_properties/gas_properties_strings.dart';

class GasDiffusionShell extends StatelessWidget {
  const GasDiffusionShell({
    super.key,
    required this.controller,
    required this.layoutScale,
  });

  final DiffusionSimulationController controller;
  final double layoutScale;

  @override
  Widget build(BuildContext context) {
    final scale = layoutScale;
    final w = GasLayoutPolicy.logicalWidth * scale;
    final h = GasLayoutPolicy.logicalHeight * scale;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final m = controller.model;
        return Material(
          color: const Color(GasPropertiesColors.screenBackground),
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiffusionPainter(
                      model: m,
                      centerOfMassVisible: controller.centerOfMassVisible,
                      flowVisible: controller.flowRateVisible,
                    ),
                  ),
                ),
                Positioned(
                  right: 16 * scale,
                  top: 16 * scale,
                  width: 240 * scale,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topRight,
                    child: _DiffusionControls(controller: controller),
                  ),
                ),
                Positioned(
                  left: 16 * scale,
                  bottom: 16 * scale,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.bottomLeft,
                    child: _DiffusionTiming(controller: controller),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DiffusionPainter extends CustomPainter {
  _DiffusionPainter({
    required this.model,
    required this.centerOfMassVisible,
    required this.flowVisible,
  });

  final DiffusionModel model;
  final bool centerOfMassVisible;
  final bool flowVisible;

  // Map diffusion container (0..16000, 0..8750) into view using diffusion MVT
  // with origin at bottom-right of container in view — adapt: place container
  // centered-ish via scale from width.
  static const _t = GasCoordinateTransform.diffusion;

  // Diffusion model uses left-origin; PhET uses bottom-right. Convert:
  // x_phet = x - width (so right wall at 0), y same.
  double _vx(double xLeftOrigin) =>
      _t.modelToViewX(xLeftOrigin - GasPropertiesConstants.diffusionWidth);
  double _vy(double y) => _t.modelToViewY(y);
  double _vs(double pm) => _t.modelToViewDelta(pm);

  @override
  void paint(Canvas canvas, Size size) {
    final c = model.container;
    final left = _vx(c.left);
    final right = _vx(c.right);
    final top = _vy(c.top);
    final bottom = _vy(c.bottom);

    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
      Paint()..color = const Color(0xFF0B1220),
    );
    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (c.hasDivider) {
      final dx = _vx(c.dividerX);
      canvas.drawLine(
        Offset(dx, top),
        Offset(dx, bottom),
        Paint()
          ..color = const Color(GasPropertiesColors.divider)
          ..strokeWidth = _vs(c.dividerThickness).clamp(2, 6),
      );
    }

    for (final p in model.particles1) {
      paintShadedSphere(
        canvas,
        Offset(_vx(p.x), _vy(p.y)),
        _vs(p.radius),
        mainColor: const Color(GasPropertiesColors.diffusionParticle1),
        highlightColor:
            const Color(GasPropertiesColors.diffusionParticle1Highlight),
      );
    }
    for (final p in model.particles2) {
      paintShadedSphere(
        canvas,
        Offset(_vx(p.x), _vy(p.y)),
        _vs(p.radius),
        mainColor: const Color(GasPropertiesColors.diffusionParticle2),
        highlightColor:
            const Color(GasPropertiesColors.diffusionParticle2Highlight),
      );
    }

    if (centerOfMassVisible) {
      void mark(double? x, Color color) {
        if (x == null) return;
        final vx = _vx(x);
        canvas.drawLine(
          Offset(vx, top),
          Offset(vx, bottom),
          Paint()
            ..color = color
            ..strokeWidth = 2,
        );
      }

      mark(model.centerOfMass1, const Color(GasPropertiesColors.diffusionParticle1));
      mark(model.centerOfMass2, const Color(GasPropertiesColors.diffusionParticle2));
    }

    if (flowVisible && !c.hasDivider) {
      final tp = TextPainter(
        text: TextSpan(
          text:
              '${GasPropertiesStrings.flow} ← ${model.flowRate1.leftFlowRate.toStringAsFixed(2)} / '
              '→ ${model.flowRate1.rightFlowRate.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(left + 8, bottom + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _DiffusionPainter oldDelegate) => true;
}

class _DiffusionControls extends StatelessWidget {
  const _DiffusionControls({required this.controller});
  final DiffusionSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _side(GasPropertiesStrings.left, m.leftSettings, m.leftData, true),
        const SizedBox(height: 8),
        _side(GasPropertiesStrings.right, m.rightSettings, m.rightData, false),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: m.numberOfParticles == 0
              ? null
              : () => controller.setHasDivider(!m.container.hasDivider),
          child: Text(
            m.container.hasDivider ? GasPropertiesStrings.removeDivider : GasPropertiesStrings.resetDivider,
          ),
        ),
        CheckboxListTile(
          dense: true,
          title: Text(GasPropertiesStrings.centerOfMass,
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          value: controller.centerOfMassVisible,
          onChanged: (v) =>
              controller.setCenterOfMassVisible(v ?? false),
        ),
        CheckboxListTile(
          dense: true,
          title: Text(GasPropertiesStrings.particleFlowRate,
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          value: controller.flowRateVisible,
          onChanged: (v) => controller.setFlowRateVisible(v ?? false),
        ),
        Row(
          children: [
            ChoiceChip(
              label: Text(GasPropertiesStrings.normal),
              selected: (m.clock.psPerSecond -
                          GasPropertiesConstants.normalPsPerSecond)
                      .abs() <
                  1e-9,
              onSelected: (_) => controller.setSlow(false),
            ),
            const SizedBox(width: 6),
            ChoiceChip(
              label: Text(GasPropertiesStrings.slow),
              selected: (m.clock.psPerSecond -
                          GasPropertiesConstants.slowPsPerSecond)
                      .abs() <
                  1e-9,
              onSelected: (_) => controller.setSlow(true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _side(
    String title,
    DiffusionSideSettings s,
    DiffusionSideData data,
    bool left,
  ) {
    return Material(
      color: const Color(GasPropertiesColors.panelFill),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          _row('N', s.numberOfParticles, (v) {
            if (left) {
              controller.setLeftCount(v);
            } else {
              controller.setRightCount(v);
            }
          }, 0, 200, 10),
          _row(GasPropertiesStrings.mass, s.mass, (v) {
            if (left) {
              controller.setLeftMass(v);
            } else {
              controller.setRightMass(v);
            }
          }, 4, 32, 1),
          _row(GasPropertiesStrings.radius, s.radius, (v) {
            if (left) {
              controller.setLeftRadius(v);
            } else {
              controller.setRightRadius(v);
            }
          }, 50, 250, 5),
          _row('T₀', s.initialTemperature, (v) {
            if (left) {
              controller.setLeftTemperature(v);
            } else {
              controller.setRightTemperature(v);
            }
          }, 50, 500, 50),
          Text(
            'T_avg: ${data.averageTemperatureK?.toStringAsFixed(0) ?? "—"} K',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
      ),
    );
  }

  Widget _row(
    String label,
    int value,
    ValueChanged<int> onChanged,
    int min,
    int max,
    int step,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged((value - step).clamp(min, max)),
          icon: const Icon(Icons.remove, size: 16, color: Colors.white54),
        ),
        Text('$value', style: const TextStyle(color: Colors.white, fontSize: 12)),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged((value + step).clamp(min, max)),
          icon: const Icon(Icons.add, size: 16, color: Colors.white54),
        ),
      ],
    );
  }
}

class _DiffusionTiming extends StatelessWidget {
  const _DiffusionTiming({required this.controller});
  final DiffusionSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final playing = controller.model.clock.isPlaying;
    return Row(
      children: [
        IconButton(
          onPressed: controller.togglePlayPause,
          icon: Icon(
            playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: Colors.white,
            size: 36,
          ),
        ),
        IconButton(
          onPressed: controller.stepOnce,
          icon: const Icon(Icons.skip_next, color: Colors.white70, size: 32),
        ),
        IconButton(
          onPressed: controller.reset,
          icon: const Icon(Icons.refresh, color: Colors.white70, size: 28),
        ),
      ],
    );
  }
}
