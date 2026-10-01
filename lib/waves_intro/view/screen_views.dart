import 'package:flutter/material.dart';

import '../model/scene_kind.dart';
import '../model/waves_intro_model.dart';
import '../painters/center_line_graph_painter.dart';
import '../painters/lattice_painter.dart';
import '../painters/light_screen_painter.dart';
import '../painters/sound_particles_painter.dart';
import '../painters/water_side_view_painter.dart';
import '../waves_intro_constants.dart';
import '../widgets/waves_intro_toolbox.dart';
import 'wave_render_visibility.dart';
import 'wave_source_nodes.dart';

/// Shared square simulation canvas — layers driven by [WaveRenderVisibility].
class WaveSimulationCanvas extends StatelessWidget {
  const WaveSimulationCanvas({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    final vis = WaveRenderVisibility(model);
    final scene = model.scene;
    const size = WavesIntroConstants.waveAreaViewSize;

    Color bg;
    if (vis.showWaterSideView) {
      bg = const Color(0xFFE0E0E0);
    } else if (vis.kind == SceneKind.light) {
      bg = Colors.black;
    } else if (vis.kind == SceneKind.sound) {
      bg = const Color(0xFF4A4A4A);
    } else {
      bg = const Color(0xFF58C0FA).withValues(alpha: 0.35);
    }

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: Colors.black38, width: 1.5),
        ),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (vis.showWaves)
                CustomPaint(
                  painter: LatticePainter(
                    lattice: scene.lattice,
                    kind: scene.config.kind,
                    wavelengthNm: scene.config.kind == SceneKind.light
                        ? scene.wavelength
                        : null,
                  ),
                ),
              if (vis.showParticles)
                CustomPaint(
                  painter: SoundParticlesPainter(
                    particles: scene.soundParticles,
                    waveAreaWidth: scene.config.waveAreaWidth,
                  ),
                ),
              if (vis.showWaterSideView)
                CustomPaint(
                  painter: WaterSideViewPainter(lattice: scene.lattice),
                ),
              if (vis.isRotating)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.18),
                  child: const Center(
                    child: Text('…', style: TextStyle(fontSize: 28, color: Colors.white70)),
                  ),
                ),
              // Scale indicator
              Positioned(
                left: 8,
                top: 6,
                child: Text(
                  _scaleLabel(scene.config),
                  style: TextStyle(
                    fontSize: 11,
                    color: vis.kind == SceneKind.light ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (vis.showFaucet)
                Positioned(
                  left: -8,
                  top: size * 0.5 - 40,
                  child: WaterFaucetSource(model: model),
                ),
              if (vis.showSpeaker)
                Positioned(
                  left: -12,
                  top: size * 0.5 - 35,
                  child: SoundSpeakerSource(model: model),
                ),
              if (vis.showLaser)
                Positioned(
                  left: -20,
                  top: size * 0.5 - 24,
                  child: LightLaserSource(model: model),
                ),
              if (vis.showWaterDrops)
                ...scene.waterDrops.map((d) {
                  final xFrac = (WavesIntroConstants.pointSourceHorizontal -
                          scene.lattice.dampX) /
                      (scene.lattice.width - 2 * scene.lattice.dampX);
                  return Positioned(
                    left: xFrac * size - 6,
                    top: WaterDropLayout.yToTop(d.y).clamp(0, size - 12),
                    child: Image.asset(
                      'assets/phet/waves_intro/water_drop.png',
                      width: 12 + d.amplitude * 0.4,
                      height: 12 + d.amplitude * 0.4,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF58C0FA),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              WavesIntroToolsOverlay(model: model),
            ],
          ),
        ),
      ),
    );
  }

  static String _scaleLabel(SceneConfig config) {
    switch (config.kind) {
      case SceneKind.water:
        return '↔ 1 cm';
      case SceneKind.sound:
        return '↔ 50 cm';
      case SceneKind.light:
        return '↔ 500 nm';
    }
  }
}

/// Water screen-specific view hierarchy.
class WaterScreenView extends StatelessWidget {
  const WaterScreenView({super.key, required this.model});
  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) => WaveSimulationCanvas(model: model);
}

/// Sound screen — Waves / Particles / Both via [WaveRenderVisibility].
class SoundScreenView extends StatelessWidget {
  const SoundScreenView({super.key, required this.model});
  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) => WaveSimulationCanvas(model: model);
}

/// Light screen — black field + laser + optional intensity screen.
class LightScreenView extends StatelessWidget {
  const LightScreenView({super.key, required this.model});
  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    final vis = WaveRenderVisibility(model);
    final scene = model.scene;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WaveSimulationCanvas(model: model),
        if (vis.showLightScreen) ...[
          const SizedBox(width: 6),
          SizedBox(
            width: LightScreenPainter.canvasWidth.toDouble(),
            height: WavesIntroConstants.waveAreaViewSize,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..setEntry(1, 0, -0.15),
              child: CustomPaint(
                painter: LightScreenPainter(
                  lattice: scene.lattice,
                  intensitySample: scene.intensitySample!,
                  baseColor: lightBaseColorFromWavelengthNm(scene.wavelength),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Graph strip under wave area — Control Graph → this visual.
class WaveGraphStrip extends StatelessWidget {
  const WaveGraphStrip({super.key, required this.model});
  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    if (!WaveRenderVisibility(model).showGraph) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: WavesIntroConstants.waveAreaViewSize,
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          border: Border.all(color: Colors.black26),
        ),
        child: CustomPaint(
          painter: CenterLineGraphPainter(lattice: model.scene.lattice),
        ),
      ),
    );
  }
}
