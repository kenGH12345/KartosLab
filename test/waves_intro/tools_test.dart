import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/model/waves_intro_model.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  WavesIntroModel createModel(SceneKind kind) {
    final m = WavesIntroModel(kind: kind);
    m.audio.platformEnabled = false;
    return m;
  }

  test('measuring tape model length uses waveAreaWidth / viewWidth', () {
    final model = createModel(SceneKind.water);
    addTearDown(model.dispose);
    model.pause();
    model.takeOutMeasuringTape();
    model.setMeasuringTapeBase(const Offset(0, 0));
    model.setMeasuringTapeTip(
      Offset(WavesIntroConstants.waveAreaViewSize, 0),
    );
    final len = model.tools.measuringTapeModelLength(
      waveAreaWidth: model.scene.config.waveAreaWidth,
      waveAreaViewWidth: WavesIntroConstants.waveAreaViewSize,
    );
    expect(len, closeTo(model.scene.config.waveAreaWidth, 1e-9));
  });

  test('stopwatch advances with scene time when running', () {
    final model = createModel(SceneKind.sound);
    addTearDown(model.dispose);
    model.pause();
    model.takeOutStopwatch();
    model.tools.isStopwatchRunning = true;
    final period = 1 / WavesIntroConstants.eventRate;
    model.manualStep();
    expect(
      model.tools.stopwatchTime,
      closeTo(period * model.scene.config.timeScaleFactor, 1e-9),
    );
  });

  test('reset clears tools', () {
    final model = createModel(SceneKind.light);
    addTearDown(model.dispose);
    model.takeOutMeasuringTape();
    model.takeOutStopwatch();
    model.takeOutWaveMeter();
    model.reset();
    expect(model.tools.isMeasuringTapeInPlayArea, isFalse);
    expect(model.tools.isStopwatchVisible, isFalse);
    expect(model.tools.isWaveMeterInPlayArea, isFalse);
  });
}
