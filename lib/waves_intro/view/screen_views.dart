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
      bg = const Color(0xFFE2E3E5);
    } else if (vis.kind == SceneKind.light) {
      bg = Colors.black;
    } else if (vis.kind == SceneKind.sound) {
      bg = const Color(WavesIntroConstants.soundWaveAreaFillArgb);
    } else {
      bg = const Color(WavesIntroConstants.waterLatticeBaseArgb);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: const Color(0xFF333333), width: 1),
              ),
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (vis.showWaves)
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: LatticePainter(
                            lattice: scene.lattice,
                            kind: scene.config.kind,
                            wavelengthNm: scene.config.kind == SceneKind.light
                                ? scene.wavelength
                                : null,
                          ),
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
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
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
                    if (vis.showGraph)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: size * 0.75 - 45,
                        height: 90,
                        child: WaveGraphStrip(model: model),
                      ),
                    WavesIntroToolsOverlay(model: model),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PhET LengthScaleIndicatorNode — above the wave area, left-aligned.
class LengthScaleIndicator extends StatelessWidget {
  const LengthScaleIndicator({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) {
    final vis = WaveRenderVisibility(model);
    return _ScaleBar(
      label: _scaleLabel(model.scene.config),
      light: vis.kind == SceneKind.light,
    );
  }

  static String _scaleLabel(SceneConfig config) {
    switch (config.kind) {
      case SceneKind.water:
        return '1 cm';
      case SceneKind.sound:
        return '50 cm';
      case SceneKind.light:
        return '500 nm';
    }
  }
}

class _ScaleBar extends StatelessWidget {
  const _ScaleBar({required this.label, required this.light});

  final String label;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : Colors.black87;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(36, 10),
          painter: _ScaleArrowPainter(color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ScaleArrowPainter extends CustomPainter {
  _ScaleArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.square;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    canvas.drawLine(const Offset(0, 1), Offset(0, size.height - 1), p);
    canvas.drawLine(
      Offset(size.width, 1),
      Offset(size.width, size.height - 1),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _ScaleArrowPainter old) => old.color != color;
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
    return SizedBox(
      width: vis.showLightScreen
          ? WavesIntroConstants.waveAreaViewSize +
              5 +
              LightScreenPainter.canvasWidth.toDouble()
          : WavesIntroConstants.waveAreaViewSize,
      height: WavesIntroConstants.waveAreaViewSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          WaveSimulationCanvas(model: model),
          if (vis.showLightScreen)
            Positioned(
              left: WavesIntroConstants.waveAreaViewSize + 5,
              top: 0,
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
      ),
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
    return CustomPaint(
      painter: CenterLineGraphPainter(lattice: model.scene.lattice),
    );
  }
}
