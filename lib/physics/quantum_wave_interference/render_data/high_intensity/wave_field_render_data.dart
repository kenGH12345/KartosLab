import 'dart:typed_data';

import '../../domain/detector_mode.dart';
import '../../domain/hit.dart';
import '../../domain/source_type.dart';
import '../../domain/wave_display_mode.dart';
import '../../models/high_intensity_model.dart';
import '../../models/single_particles_model.dart';
import '../../render/common/screen_brightness_utils.dart';
import '../../render/high_intensity/wave_rasterizer.dart';

/// Precomputed RGBA wave field for HI rendering.
///
/// Sampling resolution defaults to solver grid (120×120). Display size is separate (420×385).
class WaveFieldRenderData {
  WaveFieldRenderData({
    required this.gridWidth,
    required this.gridHeight,
    required this.rgba,
    required this.displayMode,
    required this.sourceType,
    required this.wavelengthNm,
    required this.time,
    required this.isEmitting,
  });

  final int gridWidth;
  final int gridHeight;

  /// Length = gridWidth * gridHeight * 4 (RGBA bytes).
  final Uint8List rgba;
  final WaveDisplayMode displayMode;
  final SourceType sourceType;
  final double wavelengthNm;
  final double time;
  final bool isEmitting;

  /// Sample WaveKernel into an RGBA buffer — never called from [CustomPainter.paint] hot path
  /// without going through a controller-held cache.
  factory WaveFieldRenderData.sample(
    HighIntensitySceneModel scene, {
    double colorPower = WaveRasterizer.defaultColorPower,
    double amplitudeScale = 1,
  }) {
    final solver = scene.solver;
    final gw = solver.gridWidth;
    final gh = solver.gridHeight;
    final bytes = Uint8List(gw * gh * 4);
    final base = ScreenBrightnessUtils.getSceneColor(scene.sourceType, scene.wavelengthNm);
    final source = solver.createSource();
    final barrierFrac = solver.barrierFractionX;

    if (!scene.isEmitting || source.startTime == null) {
      // All vacuum
      return WaveFieldRenderData(
        gridWidth: gw,
        gridHeight: gh,
        rgba: bytes,
        displayMode: scene.waveDisplayMode,
        sourceType: scene.sourceType,
        wavelengthNm: scene.wavelengthNm,
        time: solver.time,
        isEmitting: scene.isEmitting,
      );
    }

    for (var gx = 0; gx < gw; gx++) {
      final fractionX = (gx + 0.5) / gw;
      final localPower = fractionX <= barrierFrac
          ? 1.0
          : _rampColorPower(fractionX, barrierFrac, colorPower);
      final x = (gx + 0.5) / gw * solver.regionWidth;
      for (var gy = 0; gy < gh; gy++) {
        // Model y: top of display = +regionHeight/2 (PhET wave region)
        final y = ((gh - 1 - gy) + 0.5) / gh * solver.regionHeight - solver.regionHeight / 2;
        final sample = solver.sampleAt(source, x, y);
        final color = WaveRasterizer.fieldSampleToColor(
          sample,
          scene.waveDisplayMode,
          base,
          amplitudeScale: amplitudeScale,
          colorPower: localPower,
        );
        final i = (gy * gw + gx) * 4;
        bytes[i] = (color.r * 255.0).round().clamp(0, 255);
        bytes[i + 1] = (color.g * 255.0).round().clamp(0, 255);
        bytes[i + 2] = (color.b * 255.0).round().clamp(0, 255);
        bytes[i + 3] = 255;
      }
    }

    return WaveFieldRenderData(
      gridWidth: gw,
      gridHeight: gh,
      rgba: bytes,
      displayMode: scene.waveDisplayMode,
      sourceType: scene.sourceType,
      wavelengthNm: scene.wavelengthNm,
      time: solver.time,
      isEmitting: scene.isEmitting,
    );
  }

  static double _rampColorPower(double fractionX, double barrierFrac, double fullPower) {
    const ramp = 0.2; // waveVisualizationColorPowerRampDistance
    final t = ((fractionX - barrierFrac) / ramp).clamp(0.0, 1.0);
    return 1 + (fullPower - 1) * t;
  }

  /// Sample Gaussian packet WaveKernel for Single Particles.
  factory WaveFieldRenderData.sampleSp(
    SingleParticlesSceneModel scene, {
    double colorPower = WaveRasterizer.defaultColorPower,
    double amplitudeScale = 1,
  }) {
    final solver = scene.solver;
    final gw = solver.gridWidth;
    final gh = solver.gridHeight;
    final bytes = Uint8List(gw * gh * 4);
    final base = ScreenBrightnessUtils.getSceneColor(scene.sourceType, scene.wavelengthNm);
    final source = solver.createSource();
    final barrierFrac = solver.barrierFractionX;

    if (!scene.isPacketActive || !source.isActive) {
      return WaveFieldRenderData(
        gridWidth: gw,
        gridHeight: gh,
        rgba: bytes,
        displayMode: scene.waveDisplayMode,
        sourceType: scene.sourceType,
        wavelengthNm: scene.wavelengthNm,
        time: solver.time,
        isEmitting: scene.isPacketActive,
      );
    }

    for (var gx = 0; gx < gw; gx++) {
      final fractionX = (gx + 0.5) / gw;
      final localPower = fractionX <= barrierFrac
          ? 1.0
          : _rampColorPower(fractionX, barrierFrac, colorPower);
      final x = (gx + 0.5) / gw * solver.regionWidth;
      for (var gy = 0; gy < gh; gy++) {
        final y = ((gh - 1 - gy) + 0.5) / gh * solver.regionHeight - solver.regionHeight / 2;
        final sample = solver.sampleAt(source, x, y);
        final color = WaveRasterizer.fieldSampleToColor(
          sample,
          scene.waveDisplayMode,
          base,
          amplitudeScale: amplitudeScale,
          colorPower: localPower,
        );
        final i = (gy * gw + gx) * 4;
        bytes[i] = (color.r * 255.0).round().clamp(0, 255);
        bytes[i + 1] = (color.g * 255.0).round().clamp(0, 255);
        bytes[i + 2] = (color.b * 255.0).round().clamp(0, 255);
        bytes[i + 3] = 255;
      }
    }

    return WaveFieldRenderData(
      gridWidth: gw,
      gridHeight: gh,
      rgba: bytes,
      displayMode: scene.waveDisplayMode,
      sourceType: scene.sourceType,
      wavelengthNm: scene.wavelengthNm,
      time: solver.time,
      isEmitting: scene.isPacketActive,
    );
  }
}

/// SP detector column — instantaneous PDF + accumulated hits (Hits mode only).
class SpDetectorRenderData {
  const SpDetectorRenderData({
    required this.pdf,
    required this.hits,
    required this.brightness,
    required this.isPacketActive,
    required this.sourceType,
    required this.wavelengthNm,
  });

  final List<double> pdf;
  final List<DetectorHit> hits;
  final double brightness;
  final bool isPacketActive;
  final SourceType sourceType;
  final double wavelengthNm;

  factory SpDetectorRenderData.fromScene(SingleParticlesSceneModel scene) {
    return SpDetectorRenderData(
      pdf: scene.detectorPdf,
      hits: scene.hits.hits,
      brightness: scene.screenBrightness,
      isPacketActive: scene.isPacketActive,
      sourceType: scene.sourceType,
      wavelengthNm: scene.wavelengthNm,
    );
  }
}

/// HI detector column render data from time-averaged PDF (not Fraunhofer).
class HiDetectorRenderData {
  const HiDetectorRenderData({
    required this.pdf,
    required this.hits,
    required this.formationFactor,
    required this.brightness,
    required this.isEmitting,
    required this.sourceType,
    required this.wavelengthNm,
    required this.detectionMode,
  });

  final List<double> pdf;
  final List<DetectorHit> hits;
  final double formationFactor;
  final double brightness;
  final bool isEmitting;
  final SourceType sourceType;
  final double wavelengthNm;
  final DetectorMode detectionMode;

  factory HiDetectorRenderData.fromScene(HighIntensitySceneModel scene) {
    return HiDetectorRenderData(
      pdf: scene.detectorPdf,
      hits: scene.hits.hits,
      formationFactor: scene.detectorPatternFormationFactor,
      brightness: scene.screenBrightness,
      isEmitting: scene.isEmitting,
      sourceType: scene.sourceType,
      wavelengthNm: scene.wavelengthNm,
      detectionMode: scene.detectionMode,
    );
  }
}
