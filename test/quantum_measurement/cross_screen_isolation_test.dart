import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/model/bloch_sphere_model.dart';
import 'package:kratos/quantum_measurement/coins/model/coins_model.dart';
import 'package:kratos/quantum_measurement/common/qm_random.dart';
import 'package:kratos/quantum_measurement/photons/model/photons_model.dart';
import 'package:kratos/quantum_measurement/spin/model/spin_model.dart';

void main() {
  test('cross-screen models do not share mutable state', () {
    final coins = CoinsModel(random: SeededQmRandom(1));
    final photons = PhotonsModel(random: SeededQmRandom(2));
    final spin = SpinModel(random: SeededQmRandom(3));
    final bloch = BlochSphereModel(random: SeededQmRandom(4));

    coins.quantumScene.setUpProbability(0.11);
    photons.singlePhotonScene.preset = PolarizationPreset.vertical;
    spin.setAlphaSquared(0.22);
    bloch.setSpinState(BlochStateDirection.zMinus);

    // Mutating one screen must not alter another
    expect(coins.quantumScene.upProbability, 0.11);
    expect(photons.singlePhotonScene.preset, PolarizationPreset.vertical);
    expect(spin.alphaSquared, 0.22);
    expect(bloch.spinState, BlochStateDirection.zMinus);

    coins.reset();
    expect(photons.singlePhotonScene.preset, PolarizationPreset.vertical);
    expect(spin.alphaSquared, 0.22);
    expect(bloch.spinState, BlochStateDirection.zMinus);
  });
}
