import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

/// Parameter min / default / max from source NumberProperty ranges.
void main() {
  test('control range table matches source', () {
    final m = WoasModel();
    expect(m.amplitudeCm, defaultAmplitudeCm);
    expect(amplitudeMinCm, 0);
    expect(maxStartAmplitudeCm, 1.3);

    expect(m.frequencyHz, defaultFrequencyHz);
    expect(frequencyMinHz, 0);
    expect(frequencyMaxHz, 3);

    expect(m.pulseWidthS, defaultPulseWidthS);
    expect(pulseWidthMinS, 0.2);
    expect(pulseWidthMaxS, 1.0);

    expect(m.damping, defaultDamping);
    expect(dampingMin, 0);
    expect(dampingMax, 1);

    expect(m.tension, defaultTension);
    expect(tensionMin, 0.2);
    expect(tensionMax, 0.8);
  });

  test('setters clamp to source ranges', () {
    final m = WoasModel();
    m.setAmplitudeCm(-1);
    expect(m.amplitudeCm, 0);
    m.setAmplitudeCm(9);
    expect(m.amplitudeCm, 1.3);
    m.setFrequencyHz(-1);
    expect(m.frequencyHz, 0);
    m.setFrequencyHz(9);
    expect(m.frequencyHz, 3);
    m.setPulseWidthS(0);
    expect(m.pulseWidthS, 0.2);
    m.setPulseWidthS(9);
    expect(m.pulseWidthS, 1.0);
    m.setDamping(-1);
    expect(m.damping, 0);
    m.setDamping(2);
    expect(m.damping, 1);
    m.setTension(0);
    expect(m.tension, 0.2);
    m.setTension(1);
    expect(m.tension, 0.8);
  });
}
