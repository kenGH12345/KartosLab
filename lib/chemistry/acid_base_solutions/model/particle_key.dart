/// Particle keys from PhET `js/common/model/solutions/Particle.ts`.
enum ParticleKey {
  a,
  b,
  bh,
  h2o,
  h3o,
  ha,
  m,
  moh,
  oh,
}

extension ParticleKeyName on ParticleKey {
  /// Tandem / Map key string matching TypeScript `ParticleKey`.
  String get keyName {
    switch (this) {
      case ParticleKey.a:
        return 'A';
      case ParticleKey.b:
        return 'B';
      case ParticleKey.bh:
        return 'BH';
      case ParticleKey.h2o:
        return 'H2O';
      case ParticleKey.h3o:
        return 'H3O';
      case ParticleKey.ha:
        return 'HA';
      case ParticleKey.m:
        return 'M';
      case ParticleKey.moh:
        return 'MOH';
      case ParticleKey.oh:
        return 'OH';
    }
  }
}
