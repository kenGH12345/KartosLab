import 'package:flutter/material.dart';

import '../controller/masb_controller.dart';
import '../masb_constants.dart';
import '../model/masb_model.dart';
import '../painters/spring_mass_painter.dart';
import '../transform/masb_coordinate_transform.dart';
import 'draggable_ruler_overlay.dart';
import 'spring_system_controls.dart';

/// Round-1 simulation viewport: full-bleed cream surface + shared layout scale.
///
/// Does not change physics / drag / clock — only shell sizing & background.
class SimulationWorkspace extends StatelessWidget {
  const SimulationWorkspace({super.key, required this.controller});

  final MasbController controller;

  static const Color _cream = Color(MasbConstants.simBackgroundArgb);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final fit = MasbLayoutPolicy.fitScale(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            final size = MasbLayoutPolicy.physicalSize(fit);
            final transform = MasbCoordinateTransform(
              originX: MasbConstantsMvt.originX(fit),
              originY: MasbConstantsMvt.originY(fit),
              scale: MasbConstantsMvt.scale(fit),
            );

            // Full available area = cream viewport (no gray inset card / no
            // white letterbox around a smaller ColoredBox).
            return ColoredBox(
              color: _cream,
              child: Center(
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (e) {
                          final local = e.localPosition;
                          final m = transform.viewToModel(local);
                          controller.beginDrag(m.dx, m.dy);
                        },
                        onPointerMove: (e) {
                          final local = e.localPosition;
                          final m = transform.viewToModel(local);
                          controller.updateDrag(m.dx, m.dy);
                        },
                        onPointerUp: (_) => controller.endDrag(),
                        onPointerCancel: (_) => controller.endDrag(),
                        child: CustomPaint(
                          painter: SpringMassPainter(
                            model: controller.model,
                            transform: transform,
                          ),
                          size: size,
                        ),
                      ),
                      SpringSystemControlsOverlay(
                        controller: controller,
                        transform: transform,
                      ),
                      if (controller.model.scene == MasbScene.stretch)
                        DraggableRulerOverlay(
                          transform: transform,
                          workspaceSize: size,
                          visible: true,
                          resetToken: controller.rulerResetToken,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Shared MVT scale factors (physics model units unchanged).
class MasbConstantsMvt {
  static double scale(double fit) => MasbConstants.mvtScale * fit;
  static double originX(double fit) => MasbConstants.mvtOffsetX * fit;
  static double originY(double fit) => MasbConstants.mvtOffsetY * fit;
}
