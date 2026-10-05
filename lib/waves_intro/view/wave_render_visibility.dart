import '../model/scene_kind.dart';
import '../model/waves_intro_model.dart';

/// Single source of truth for Control → Visualization binding.
///
/// Derived only from [WavesIntroModel] — no second boolean in Widgets.
/// Evidence: WavesScreenView multilink @ lock `31ebfd7`.
class WaveRenderVisibility {
  WaveRenderVisibility(this.model);

  final WavesIntroModel model;

  SceneKind get kind => model.scene.config.kind;

  bool get showTopLattice => model.showTopLattice;

  bool get showWaterSideView => model.showWaterSideView;

  bool get isRotating => model.isRotating;

  /// Lattice / pressure / light wave field.
  /// Sound: visible unless PARTICLES-only.
  bool get showWaves {
    if (!showTopLattice) return false;
    if (kind != SceneKind.sound) return true;
    final t = model.scene.soundViewType;
    return t == SoundViewType.waves || t == SoundViewType.both;
  }

  /// Sound particles layer.
  bool get showParticles {
    if (kind != SceneKind.sound || !showTopLattice) return false;
    final t = model.scene.soundViewType;
    return t == SoundViewType.particles || t == SoundViewType.both;
  }

  /// Light projection screen column — [已确认] showScreenProperty.
  bool get showLightScreen =>
      kind == SceneKind.light &&
      model.showScreen &&
      model.scene.intensitySample != null;

  /// Center-line graph under wave area.
  bool get showGraph => model.showGraph && showTopLattice;

  bool get showFaucet => kind == SceneKind.water && !isRotating;

  bool get showSpeaker => kind == SceneKind.sound && !isRotating;

  bool get showLaser => kind == SceneKind.light && !isRotating;

  bool get showWaterDrops => kind == SceneKind.water;

  bool get showMeasuringTape => model.tools.isMeasuringTapeInPlayArea;

  bool get showStopwatch => model.tools.isStopwatchVisible;

  bool get showWaveMeter => model.tools.isWaveMeterInPlayArea;
}
