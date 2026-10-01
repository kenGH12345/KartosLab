import '../abs_constants.dart';
import '../abs_math.dart';
import '../abs_particle.dart';
import '../abs_range.dart';
import '../particle_key.dart';

/// Abstract aqueous solution — PhET `AqueousSolution.ts`.
abstract class AqueousSolution {
  AqueousSolution({
    required AbsRangeWithValue strengthRange,
    required AbsRangeWithValue concentrationRange,
  })  : strengthRange = strengthRange,
        concentrationRange = concentrationRange,
        _strength = strengthRange.defaultValue,
        _concentration = concentrationRange.defaultValue,
        _strengthDefault = strengthRange.defaultValue,
        _concentrationDefault = concentrationRange.defaultValue {
    particles = buildParticles();
  }

  /// Order matches graph bar order and magnifying-glass z-order in source.
  late final List<AbsParticle> particles;

  final AbsRangeWithValue strengthRange;
  final AbsRangeWithValue concentrationRange;

  double _strength;
  double _concentration;
  final double _strengthDefault;
  final double _concentrationDefault;

  /// Acid/base ionization constant (Ka or Kb), or water/strong marker.
  double get strength => _strength;

  set strength(double value) {
    _strength = strengthRange.constrain(value);
  }

  /// Solute concentration C (mol/L). Water uses W as its concentration.
  double get concentration => _concentration;

  set concentration(double value) {
    _concentration = concentrationRange.constrain(value);
  }

  /// `pH = -log10([H3O+])` with source rounding from `AqueousSolution.ts`.
  double get pH {
    final value = AbsMath.pHFromH3O(getH3OConcentration());
    assert(AbsConstants.phRange.contains(value), 'pH out of range: $value');
    return value;
  }

  void reset() {
    _strength = _strengthDefault;
    _concentration = _concentrationDefault;
  }

  AbsParticle? particleWithKey(ParticleKey key) {
    for (final p in particles) {
      if (p.key == key) return p;
    }
    return null;
  }

  List<AbsParticle> buildParticles();

  double getSoluteConcentration();

  double getProductConcentration();

  double getH3OConcentration();

  double getOHConcentration();

  double getH2OConcentration();
}
