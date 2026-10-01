import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/model/waves_intro_model.dart';
import 'package:kratos/waves_intro/view/wave_render_visibility.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Water control → visualization', () {
    test('Graph checkbox toggles showGraph visual binding', () {
      final model = WavesIntroModel(kind: SceneKind.water, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      final vis = WaveRenderVisibility(model);
      expect(vis.showGraph, isFalse);
      model.setShowGraph(true);
      expect(model.showGraph, isTrue);
      expect(vis.showGraph, isTrue);
      model.setShowGraph(false);
      expect(vis.showGraph, isFalse);
    });

    test('Tape / Timer / Meter appear in play area via tools state', () {
      final model = WavesIntroModel(kind: SceneKind.water, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      final vis = WaveRenderVisibility(model);
      expect(vis.showMeasuringTape, isFalse);
      model.takeOutMeasuringTape();
      expect(vis.showMeasuringTape, isTrue);
      model.takeOutStopwatch();
      expect(vis.showStopwatch, isTrue);
      model.takeOutWaveMeter();
      expect(vis.showWaveMeter, isTrue);
      model.returnWaveMeter();
      expect(vis.showWaveMeter, isFalse);
    });

    test('Top/Side switches lattice vs water side visual', () {
      final model = WavesIntroModel(kind: SceneKind.water, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      model.pause();
      final vis = WaveRenderVisibility(model);
      expect(vis.showTopLattice, isTrue);
      expect(vis.showWaterSideView, isFalse);
      model.setViewpoint(Viewpoint.side);
      for (var i = 0; i < 40; i++) {
        model.stepWallTime(0.05);
      }
      expect(vis.showWaterSideView, isTrue);
      expect(vis.showWaves, isFalse);
    });
  });

  group('Sound Waves / Particles / Both', () {
    test('WAVES shows waves only', () {
      final model = WavesIntroModel(kind: SceneKind.sound, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      model.setSoundViewType(SoundViewType.waves);
      final vis = WaveRenderVisibility(model);
      expect(vis.showWaves, isTrue);
      expect(vis.showParticles, isFalse);
    });

    test('PARTICLES shows particles only', () {
      final model = WavesIntroModel(kind: SceneKind.sound, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      model.setSoundViewType(SoundViewType.particles);
      final vis = WaveRenderVisibility(model);
      expect(vis.showWaves, isFalse);
      expect(vis.showParticles, isTrue);
    });

    test('BOTH shows waves and particles', () {
      final model = WavesIntroModel(kind: SceneKind.sound, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      model.setSoundViewType(SoundViewType.both);
      final vis = WaveRenderVisibility(model);
      expect(vis.showWaves, isTrue);
      expect(vis.showParticles, isTrue);
    });
  });

  group('Light Screen visualization', () {
    test('Screen checkbox binds to showLightScreen visual', () {
      final model = WavesIntroModel(kind: SceneKind.light, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      final vis = WaveRenderVisibility(model);
      expect(vis.showLightScreen, isFalse);
      model.setShowScreen(true);
      expect(model.showScreen, isTrue);
      expect(vis.showLightScreen, isTrue);
      expect(vis.showLaser, isTrue);
      expect(vis.showWaves, isTrue);
    });
  });

  group('reset visibility', () {
    test('reset clears graph/screen/tools/soundView', () {
      final model = WavesIntroModel(kind: SceneKind.sound, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      model.setShowGraph(true);
      model.setSoundViewType(SoundViewType.both);
      model.takeOutWaveMeter();
      model.setSlowMotion(true);
      model.reset();
      final vis = WaveRenderVisibility(model);
      expect(vis.showGraph, isFalse);
      expect(vis.showWaveMeter, isFalse);
      expect(model.scene.soundViewType, SoundViewType.waves);
      expect(model.slowMotion, isFalse);
      expect(vis.showWaves, isTrue);
      expect(vis.showParticles, isFalse);
    });
  });

  group('screen-specific renderer flags', () {
    test('water has faucet not speaker/laser', () {
      final model = WavesIntroModel(kind: SceneKind.water, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      final vis = WaveRenderVisibility(model);
      expect(vis.showFaucet, isTrue);
      expect(vis.showSpeaker, isFalse);
      expect(vis.showLaser, isFalse);
    });

    test('sound has speaker', () {
      final model = WavesIntroModel(kind: SceneKind.sound, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      expect(WaveRenderVisibility(model).showSpeaker, isTrue);
    });

    test('light has laser', () {
      final model = WavesIntroModel(kind: SceneKind.light, autoTick: false)
        ..audio.platformEnabled = false;
      addTearDown(model.dispose);
      expect(WaveRenderVisibility(model).showLaser, isTrue);
    });
  });
}
