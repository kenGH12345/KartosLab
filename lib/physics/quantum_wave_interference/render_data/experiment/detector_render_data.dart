import '../../domain/detector_mode.dart';
import '../../domain/hit.dart';
import '../../domain/source_type.dart';
import '../../models/experiment_model.dart';
import 'fraunhofer_render_data.dart';

/// Bundle for Experiment front-facing / overhead detector painting.
class DetectorRenderData {
  const DetectorRenderData({
    required this.mode,
    required this.fraunhofer,
    required this.hits,
    required this.sourceType,
    required this.wavelengthNm,
    required this.brightness,
    required this.isEmitting,
    required this.scaleIndex,
  });

  final DetectorMode mode;
  final FraunhoferRenderData fraunhofer;
  final List<DetectorHit> hits;
  final SourceType sourceType;
  final double wavelengthNm;
  final double brightness;
  final bool isEmitting;
  final int scaleIndex;

  factory DetectorRenderData.fromModel(ExperimentModel model, {int intensitySamples = 256}) {
    final scene = model.scene;
    return DetectorRenderData(
      mode: scene.detectionMode,
      fraunhofer: FraunhoferRenderData.fromScene(
        scene,
        visibleHalfWidthM: model.visibleDetectorHalfWidthM,
        samples: intensitySamples,
      ),
      hits: scene.hits.hits,
      sourceType: scene.sourceType,
      wavelengthNm: scene.wavelengthNm,
      brightness: scene.screenBrightness,
      isEmitting: scene.isEmitting,
      scaleIndex: model.detectorScreenScaleIndex,
    );
  }
}
