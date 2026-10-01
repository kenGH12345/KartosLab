import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

void main() {
  test('wavelength = waveSpeed / frequency for water', () {
    final c = SceneConfig.water;
    final f = c.defaultFrequency;
    expect(
      WavesIntroConstants.wavelength(waveSpeedValue: c.waveSpeed, frequency: f),
      closeTo(c.waveSpeed / f, 1e-12),
    );
  });

  test('wavelength = waveSpeed / frequency for sound', () {
    final c = SceneConfig.sound;
    final f = c.defaultFrequency;
    expect(
      WavesIntroConstants.wavelength(waveSpeedValue: c.waveSpeed, frequency: f),
      closeTo(c.waveSpeed / f, 1e-12),
    );
  });

  test('wavelength = waveSpeed / frequency for light', () {
    final c = SceneConfig.light;
    final f = c.defaultFrequency;
    expect(
      WavesIntroConstants.wavelength(waveSpeedValue: c.waveSpeed, frequency: f),
      closeTo(c.waveSpeed / f, 1e-12),
    );
  });

  test('scene defaults match WavesModel midpoints', () {
    expect(SceneConfig.water.defaultFrequency, closeTo(0.625, 1e-12));
    expect(
      SceneConfig.sound.defaultFrequency,
      closeTo((0.22 + 0.44) / 2, 1e-12),
    );
  });
}
