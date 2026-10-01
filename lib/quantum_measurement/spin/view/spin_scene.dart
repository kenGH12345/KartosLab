/// Shared Spin scene: prep | divider | measurement apparatus.
/// Layout mirrors SpinScreenView / SpinMeasurementArea / SpinStatePreparationArea.
library;

import 'package:flutter/material.dart';

import '../../common/qm_visual.dart';
import '../animation/spin_particle_simulation.dart';
import '../composer/spin_composer.dart';
import '../components/experiment_selector.dart';
import '../components/spin_controls.dart';
import '../components/spin_measurement_device.dart';
import '../components/spin_particle_renderer.dart';
import '../components/spin_source.dart';
import '../components/stern_gerlach_apparatus.dart';
import '../model/spin_model.dart';
import '../transform/spin_view_transform.dart';

class SpinScene extends StatelessWidget {
  const SpinScene({
    super.key,
    required this.model,
    required this.geometry,
    required this.simulation,
    required this.onChanged,
  });

  final SpinModel model;
  final SpinLayoutGeometry geometry;
  final SpinParticleSimulation simulation;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final config = geometry.config;
    final showBlockControls = !config.usingSingleApparatus &&
        config.sourceMode == SourceMode.continuous;
    final singleParticle = config.sourceMode == SourceMode.single;
    final t = geometry.transform;
    final mds = simulation.measurementDevices;

    // Prep column must stay strictly left of divider.
    final prepWidth =
        (geometry.dividerX - geometry.prepArea.left - 12).clamp(120.0, 280.0);

    // MD centers: model (md.x, 1.0) — above beam line (SpinModel.ts y=1)
    Offset mdView(int i) => t.physicsToView(SpinVec2(mds[i].modelX, 1.0));
    // Device Column: sphere(~160) + gap(20) + camera(42) ≈ 222; center ≈ 111
    const mdHalfW = 80.0;
    const mdCenterOffsetY = 111.0;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // ── Prep (left of divider only) ──
        Positioned(
          left: geometry.prepArea.left,
          top: geometry.prepArea.top,
          width: prepWidth,
          child: SpinPrepControls(model: model, onChanged: onChanged),
        ),

        // ── Divider ──
        Positioned(
          left: geometry.dividerRect.left,
          top: geometry.dividerRect.top,
          child: QmExperimentDividingLine(height: geometry.dividerRect.height),
        ),

        // ── Experiment selector ──
        Positioned(
          left: geometry.comboTopLeft.dx,
          top: geometry.comboTopLeft.dy,
          child: ExperimentSelector(
            value: model.experiment,
            onChanged: (e) {
              simulation.clear();
              model.applyExperiment(e);
              onChanged();
            },
          ),
        ),

        // ── Stern-Gerlach (SG) Measurements title ──
        Positioned(
          left: geometry.comboTopLeft.dx,
          top: geometry.comboTopLeft.dy + 44,
          child: const Text(
            'Stern-Gerlach (SG) Measurements',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // ── Measurement devices (single-particle) — flash on particle crossing ──
        if (singleParticle) ...[
          for (var i = 0; i < 2; i++)
            if (mds[i].active)
              Positioned(
                left: mdView(i).dx - mdHalfW,
                top: mdView(i).dy - mdCenterOffsetY,
                child: SpinMeasurementDevice(
                  polar: mds[i].polar,
                  azimuthal: mds[i].azimuthal,
                  flash: mds[i].cameraFlash,
                  stateVectorVisible: mds[i].stateVectorVisible,
                ),
              ),
          if (mds[2].active)
            Positioned(
              left: mdView(2).dx - mdHalfW,
              top: mdView(2).dy - mdCenterOffsetY,
              child: SpinMeasurementDevice(
                polar: mds[2].polar,
                azimuthal: mds[2].azimuthal,
                flash: mds[2].cameraFlash,
                stateVectorVisible: mds[2].stateVectorVisible,
              ),
            ),
        ],

        // ── Particle source (body centered on model point; label above) ──
        Positioned(
          left: geometry.sourceCenterView.dx - SpinSourceNode.bodySize.width / 2,
          top: geometry.sourceCenterView.dy -
              SpinSourceNode.bodySize.height / 2 -
              SpinSourceNode.labelAboveHeight,
          child: SpinSourceNode(
            sourceMode: model.sourceMode,
            particleAmount: model.particleAmount,
            onFireSingle: () {
              simulation.fireSingle();
              onChanged();
            },
            onSourceModeChanged: (m) {
              simulation.clear();
              model.setSourceMode(m);
              onChanged();
            },
            onParticleAmountChanged: (v) {
              model.particleAmount = v;
              onChanged();
            },
          ),
        ),

        // ── SG0 ──
        if (geometry.sg0.visible)
          Positioned(
            left: geometry.sg0.centerView.dx - geometry.sg0.sizeView.width / 2,
            top: geometry.sg0.centerView.dy - geometry.sg0.sizeView.height / 2,
            child: SternGerlachApparatus(
              geometry: geometry.sg0,
              blockingMode: model.sternGerlachs[0].blockingMode,
              showBlockerControls: showBlockControls,
              onBlockingChanged: (b) {
                simulation.clear();
                model.setBlockingMode(b);
                onChanged();
              },
              onOrientationChanged: (isZ) {
                model.setSgOrientation(0, isZ);
                onChanged();
              },
            ),
          ),

        if (geometry.sg1.visible)
          Positioned(
            left: geometry.sg1.centerView.dx - geometry.sg1.sizeView.width / 2,
            top: geometry.sg1.centerView.dy - geometry.sg1.sizeView.height / 2,
            child: SternGerlachApparatus(
              geometry: geometry.sg1,
              onOrientationChanged: (isZ) {
                model.setSgOrientation(1, isZ);
                onChanged();
              },
            ),
          ),

        if (geometry.sg2.visible)
          Positioned(
            left: geometry.sg2.centerView.dx - geometry.sg2.sizeView.width / 2,
            top: geometry.sg2.centerView.dy - geometry.sg2.sizeView.height / 2,
            child: SternGerlachApparatus(
              geometry: geometry.sg2,
              onOrientationChanged: (isZ) {
                model.setSgOrientation(2, isZ);
                onChanged();
              },
            ),
          ),

        if (geometry.showBlocker && geometry.blockerView != null)
          SpinBlockerView(
            center: geometry.blockerView!,
            blockUp: config.blockingMode == BlockingMode.blockUp,
          ),

        Positioned.fill(
          child: IgnorePointer(
            child: SpinParticleRenderer(
              particles: simulation.particles,
              transform: geometry.transform,
            ),
          ),
        ),
      ],
    );
  }
}
