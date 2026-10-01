/// InteractiveIsotopeNode — cloud, nucleons, bucket, labels, neutron drag.
library;

import 'package:flutter/material.dart';

import '../controller/make_isotopes_controller.dart';
import '../iaam_constants.dart';
import '../model/make_isotopes_constants.dart';
import '../model/nucleon_particle.dart';
import '../painters/electron_cloud_painter.dart';
import '../painters/nucleon_ball_painter.dart';
import '../painters/neutron_bucket_painter.dart';
import '../transform/iaam_transform.dart';
import 'sim_coord_scope.dart';

class MakeIsotopePlayArea extends StatelessWidget {
  const MakeIsotopePlayArea({
    super.key,
    required this.controller,
    required this.transform,
  });

  final MakeIsotopesController controller;
  final IaamTransform transform;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final atomView = transform.modelToView(m.atomX, m.atomY);
    final cloudR = electronCloudRadiusFor(m.electronCount);
    final nucleonR = transform.modelToViewDelta(IaamConstants.nucleonRadius);

    final bucketView = transform.modelToView(kNeutronBucketX, kNeutronBucketY);
    final bucketW = transform.modelToViewDelta(kNeutronBucketWidth);
    final bucketH = transform.modelToViewDelta(kNeutronBucketHeight);

    // Stability / element name offsets from InteractiveIsotopeNode maps.
    final z = m.protonCount;
    const nameOffset = <int, double>{
      1: 35, 2: 35, 3: 40, 4: 42, 5: 44,
      6: 47, 7: 47, 8: 50, 9: 50, 10: 50,
    };
    const stableOffset = <int, double>{
      1: 30, 2: 35, 3: 40, 4: 42, 5: 44,
      6: 47, 7: 47, 8: 50, 9: 50, 10: 50,
    };
    final nameDy = nameOffset[z] ?? 50;
    final stableDy = stableOffset[z] ?? 50;

    final isotopeLabel = '${m.selectedElement.name}-${m.massNumber}';
    final stability =
        m.protonCount > 0 ? (m.isStable ? 'Stable' : 'Unstable') : '';

    // Collect drawable nucleons sorted by zLayer (higher = further back).
    final nucleons = <NucleonParticle>[
      ...m.protons,
      ...m.nucleusNeutrons,
      ...m.bucketNeutrons,
      if (m.draggingNeutron != null) m.draggingNeutron!,
    ]..sort((a, b) => b.zLayer.compareTo(a.zLayer));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // My Isotope label
        Positioned(
          left: atomView.dx - 50,
          top: atomView.dy - cloudR - 28,
          width: 100,
          child: const Text(
            'My Isotope',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // Electron cloud
        Positioned(
          left: atomView.dx - cloudR,
          top: atomView.dy - cloudR,
          width: cloudR * 2,
          height: cloudR * 2,
          child: IgnorePointer(
            child: CustomPaint(
              painter: ElectronCloudPainter(radius: cloudR),
            ),
          ),
        ),

        // Element name
        Positioned(
          left: atomView.dx - 40,
          top: atomView.dy - nameDy - 8,
          width: 80,
          child: Text(
            isotopeLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // Stable / Unstable
        Positioned(
          left: atomView.dx - 40,
          top: atomView.dy + stableDy - 6,
          width: 80,
          child: Text(
            stability,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),

        // Bucket hole (behind particles)
        Positioned(
          left: bucketView.dx - bucketW / 2,
          top: bucketView.dy - bucketH * 0.15,
          width: bucketW,
          height: bucketH,
          child: IgnorePointer(
            child: CustomPaint(
              painter: NeutronBucketPainter(
                layer: BucketPaintLayer.hole,
                width: bucketW,
                height: bucketH,
              ),
            ),
          ),
        ),

        // Nucleons (protons + neutrons) with drag on neutrons
        ...nucleons.map((p) {
          final v = transform.modelToView(p.x, p.y);
          final isNeutron = p.kind == NucleonKind.neutron;
          final color = isNeutron
              ? NucleonBallPainter.colorForNeutron()
              : NucleonBallPainter.colorForProton();
          final diameter = nucleonR * 2;
          return Positioned(
            left: v.dx - nucleonR,
            top: v.dy - nucleonR,
            width: diameter,
            height: diameter,
            child: isNeutron
                ? _DraggableNeutron(
                    particleId: p.id,
                    controller: controller,
                    transform: transform,
                    radius: nucleonR,
                    color: color,
                  )
                : IgnorePointer(
                    child: CustomPaint(
                      painter: _SingleNucleonPainter(color: color),
                    ),
                  ),
          );
        }),

        // Bucket front (in front of particles in bucket region)
        Positioned(
          left: bucketView.dx - bucketW / 2,
          top: bucketView.dy - bucketH * 0.15,
          width: bucketW,
          height: bucketH,
          child: IgnorePointer(
            child: CustomPaint(
              painter: NeutronBucketPainter(
                layer: BucketPaintLayer.front,
                width: bucketW,
                height: bucketH,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SingleNucleonPainter extends CustomPainter {
  _SingleNucleonPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    NucleonBallPainter.paint(canvas, c, size.width / 2, color);
  }

  @override
  bool shouldRepaint(covariant _SingleNucleonPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DraggableNeutron extends StatelessWidget {
  const _DraggableNeutron({
    required this.particleId,
    required this.controller,
    required this.transform,
    required this.radius,
    required this.color,
  });

  final int particleId;
  final MakeIsotopesController controller;
  final IaamTransform transform;
  final double radius;
  final Color color;

  Offset _viewInSim(BuildContext context, Offset global) {
    final scope = context.findAncestorStateOfType<SimCoordScopeState>();
    if (scope == null) return global;
    return scope.globalToSim(global);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        final viewPos = _viewInSim(context, details.globalPosition);
        final model = transform.viewToModel(viewPos.dx, viewPos.dy);
        controller.beginDrag(particleId, model.dx, model.dy);
      },
      onPanUpdate: (details) {
        final viewPos = _viewInSim(context, details.globalPosition);
        final model = transform.viewToModel(viewPos.dx, viewPos.dy);
        controller.updateDrag(model.dx, model.dy);
      },
      onPanEnd: (_) => controller.endDrag(),
      onPanCancel: () => controller.endDrag(),
      child: CustomPaint(
        painter: _SingleNucleonPainter(color: color),
      ),
    );
  }
}
