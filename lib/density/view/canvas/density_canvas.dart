import 'package:flutter/material.dart';

import '../../controller/density_controller.dart';
import '../../density_strings.dart';
import '../../render/density_mvt.dart';
import '../../render/density_render_data.dart';
import '../painters/scale_painter.dart';

class DensityCanvas extends StatelessWidget {
  const DensityCanvas({super.key, required this.controller});

  final DensityController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final mvt = DensityMvt.fit(size);
        final data = controller.renderData(mvt);
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) => controller.pointerDown(e.localPosition, mvt),
          onPointerMove: (e) => controller.pointerMove(e.localPosition, mvt),
          onPointerUp: (_) => controller.pointerUp(),
          onPointerCancel: (_) => controller.pointerUp(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: DensityScenePainter(data),
                size: size,
              ),
              for (final cube in data.cubes)
                _CubeSemantics(mvt: mvt, cube: cube),
            ],
          ),
        );
      },
    );
  }
}

class _CubeSemantics extends StatelessWidget {
  const _CubeSemantics({required this.mvt, required this.cube});

  final DensityMvt mvt;
  final DensityCubeView cube;

  @override
  Widget build(BuildContext context) {
    final rect = mvt.cubeFrontRect(cube.center, cube.volume);
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Semantics(
        button: true,
        label: DensityStrings.grabMass(cube.tag),
        child: const SizedBox.expand(),
      ),
    );
  }
}
