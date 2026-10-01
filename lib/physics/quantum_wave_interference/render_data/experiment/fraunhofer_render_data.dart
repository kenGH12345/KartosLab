import '../../domain/slit_configuration.dart';
import '../../domain/source_type.dart';
import '../../models/experiment_model.dart';
import '../../numerics/fraunhofer_solver.dart';

/// Immutable Fraunhofer intensity samples for Experiment detector / graph.
///
/// Produced only from [FraunhoferSolver] — never from UI presets.
class FraunhoferRenderData {
  const FraunhoferRenderData({
    required this.normalizedPositions,
    required this.intensities,
    required this.sourceType,
    required this.wavelengthNm,
    required this.effectiveWavelengthM,
    required this.slitSeparationMm,
    required this.slitWidthMm,
    required this.screenDistanceM,
    required this.slitConfiguration,
    required this.fullScreenHalfWidthM,
    required this.visibleHalfWidthM,
    required this.screenBrightness,
    required this.sourceStrength,
    required this.isEmitting,
  });

  final List<double> normalizedPositions;
  final List<double> intensities;
  final SourceType sourceType;
  final double wavelengthNm;
  final double effectiveWavelengthM;
  final double slitSeparationMm;
  final double slitWidthMm;
  final double screenDistanceM;
  final SlitConfiguration slitConfiguration;
  final double fullScreenHalfWidthM;
  final double visibleHalfWidthM;
  final double screenBrightness;
  final double sourceStrength;
  final bool isEmitting;

  /// Sample intensity across the **visible** zoom window (normalized to full detector).
  factory FraunhoferRenderData.fromScene(
    ExperimentSceneModel scene, {
    required double visibleHalfWidthM,
    int samples = 256,
  }) {
    final half = scene.fullScreenHalfWidthM;
    final positions = <double>[];
    final intensities = <double>[];
    for (var i = 0; i < samples; i++) {
      final t = (i + 0.5) / samples;
      // Visible window: [-visibleHalf, +visibleHalf]
      final physical = (t - 0.5) * 2 * visibleHalfWidthM;
      final normalized = physical / half;
      positions.add(normalized);
      intensities.add(scene.intensityAtPhysicalX(physical));
    }
    return FraunhoferRenderData(
      normalizedPositions: positions,
      intensities: intensities,
      sourceType: scene.sourceType,
      wavelengthNm: scene.wavelengthNm,
      effectiveWavelengthM: scene.effectiveWavelengthM,
      slitSeparationMm: scene.slitSeparationMm,
      slitWidthMm: scene.slitWidthMm,
      screenDistanceM: scene.screenDistanceM,
      slitConfiguration: scene.slitConfiguration,
      fullScreenHalfWidthM: half,
      visibleHalfWidthM: visibleHalfWidthM,
      screenBrightness: scene.screenBrightness,
      sourceStrength: scene.sourceStrength,
      isEmitting: scene.isEmitting,
    );
  }

  double intensityAtNormalized(double normalizedY) {
    final physical = normalizedY * fullScreenHalfWidthM;
    return FraunhoferSolver.getExactDetectorIntensity(
      FraunhoferOptions(
        positionOnScreenM: physical,
        effectiveWavelengthM: effectiveWavelengthM,
        screenDistanceM: screenDistanceM,
        slitWidthM: slitWidthMm * 1e-3,
        slitSeparationM: slitSeparationMm * 1e-3,
        slitSetting: slitConfiguration,
      ),
    );
  }
}
