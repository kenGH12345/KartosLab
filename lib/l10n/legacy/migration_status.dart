/// Per-module localization migration state.
enum LocalizationMigrationStatus {
  /// Fully on KartosLocalization for user-visible strings in scope.
  localized,

  /// Localized + A11y + ZH Golden + Behavior + Regression gates all PASS.
  verified,

  /// Some screens/strings migrated; legacy `*Strings` still dominate.
  partial,

  /// Not started — still English / legacy bags only.
  notStarted,
}

/// Registry of migration status for PHASE tracking.
class LocalizationMigrationRegistry {
  LocalizationMigrationRegistry._();

  static const Map<String, LocalizationMigrationStatus> statusByModule = {
    'l10n-architecture': LocalizationMigrationStatus.verified,
    'home': LocalizationMigrationStatus.verified,
    'shared-chrome': LocalizationMigrationStatus.verified,
    // PHASE 2 — mechanics / gravity / vector
    'forces': LocalizationMigrationStatus.verified,
    'collision-lab': LocalizationMigrationStatus.verified,
    'vector-addition': LocalizationMigrationStatus.verified,
    'projectile-motion': LocalizationMigrationStatus.verified,
    'pendulum-lab': LocalizationMigrationStatus.verified,
    'balancing-act': LocalizationMigrationStatus.verified,
    'friction': LocalizationMigrationStatus.verified,
    'hookes-law': LocalizationMigrationStatus.verified,
    'masses-and-springs-basics': LocalizationMigrationStatus.verified,
    'energy-skate-park': LocalizationMigrationStatus.verified,
    'gravity-force-lab': LocalizationMigrationStatus.verified,
    'gravity-force-lab-basics': LocalizationMigrationStatus.verified,
    'gravity-and-orbits': LocalizationMigrationStatus.verified,
    'keplers-laws': LocalizationMigrationStatus.verified,
    'my-solar-system': LocalizationMigrationStatus.verified,
    // PHASE 3 — fluids / density / buoyancy / gases
    'buoyancy': LocalizationMigrationStatus.verified,
    'density': LocalizationMigrationStatus.verified,
    'under-pressure': LocalizationMigrationStatus.verified,
    'gases-intro': LocalizationMigrationStatus.verified,
    'gas-properties': LocalizationMigrationStatus.verified,
    'diffusion': LocalizationMigrationStatus.verified,
    'membrane-transport': LocalizationMigrationStatus.verified,
    // PHASE 4 — electricity / circuits / EM
    'ohms-law': LocalizationMigrationStatus.verified,
    'resistance-in-a-wire': LocalizationMigrationStatus.verified,
    'cck-ac-virtual-lab': LocalizationMigrationStatus.verified,
    'capacitor-lab-basics': LocalizationMigrationStatus.verified,
    'charges-and-fields': LocalizationMigrationStatus.verified,
    'faradays-law': LocalizationMigrationStatus.verified,
    'john-travoltage': LocalizationMigrationStatus.verified,
    'balloons-and-static-electricity': LocalizationMigrationStatus.verified,
    'magnet-and-compass': LocalizationMigrationStatus.verified,
    // PHASE 5 — optics / waves / quantum
    'bending-light': LocalizationMigrationStatus.verified,
    'color-vision': LocalizationMigrationStatus.verified,
    'wave-on-a-string': LocalizationMigrationStatus.verified,
    'waves-intro': LocalizationMigrationStatus.verified,
    'normal-modes': LocalizationMigrationStatus.verified,
    'fourier-making-waves': LocalizationMigrationStatus.verified,
    'sound': LocalizationMigrationStatus.verified,
    'radio-waves': LocalizationMigrationStatus.verified,
    'quantum-measurement': LocalizationMigrationStatus.verified,
    'quantum-wave-interference': LocalizationMigrationStatus.verified,
    'quantum-coin-toss': LocalizationMigrationStatus.verified,
    // PHASE 6 — chemistry
    'molarity': LocalizationMigrationStatus.verified,
    'beers-law-lab': LocalizationMigrationStatus.verified,
    'ph-scale': LocalizationMigrationStatus.verified,
    'acid-base-solutions': LocalizationMigrationStatus.verified,
    'build-a-nucleus': LocalizationMigrationStatus.verified,
    'rutherford-scattering': LocalizationMigrationStatus.verified,
    'build-an-atom': LocalizationMigrationStatus.verified,
    'isotopes-and-atomic-mass': LocalizationMigrationStatus.verified,
    'build-a-molecule': LocalizationMigrationStatus.verified,
    'molecule-polarity': LocalizationMigrationStatus.verified,
    'molecule-shapes': LocalizationMigrationStatus.verified,
    'molecules-and-light': LocalizationMigrationStatus.verified,
    'reactants-products-and-leftovers': LocalizationMigrationStatus.verified,
    'balancing-chemical-equations': LocalizationMigrationStatus.verified,
    'states-of-matter': LocalizationMigrationStatus.verified,
    // PHASE 7B — Home remainder / global remediation
    'forces-and-motion-basics': LocalizationMigrationStatus.verified, // alias → forces
    'curve-fitting': LocalizationMigrationStatus.verified,
    'plinko-probability': LocalizationMigrationStatus.verified,
    'circuit': LocalizationMigrationStatus.verified,
    'optics': LocalizationMigrationStatus.verified,
    'wave-interference': LocalizationMigrationStatus.verified,
    'blackbody-spectrum': LocalizationMigrationStatus.verified,
    'energy-forms-and-changes': LocalizationMigrationStatus.verified,
    'concentration': LocalizationMigrationStatus.verified, // via Beers Law Lab tab
  };

  /// Modules in PHASE 2 scope (for scoped English-residue scanners).
  static const Set<String> phase2ModuleIds = {
    'forces',
    'collision-lab',
    'vector-addition',
    'projectile-motion',
    'pendulum-lab',
    'balancing-act',
    'friction',
    'hookes-law',
    'masses-and-springs-basics',
    'energy-skate-park',
    'gravity-force-lab',
    'gravity-force-lab-basics',
    'gravity-and-orbits',
    'keplers-laws',
    'my-solar-system',
  };

  /// Modules in PHASE 3 scope (fluids / density / buoyancy / gases).
  static const Set<String> phase3ModuleIds = {
    'density',
    'buoyancy',
    'under-pressure',
    'gases-intro',
    'gas-properties',
    'diffusion',
    'membrane-transport',
  };

  /// Modules in PHASE 4 scope (electricity / circuits / EM).
  static const Set<String> phase4ModuleIds = {
    'ohms-law',
    'resistance-in-a-wire',
    'cck-ac-virtual-lab',
    'capacitor-lab-basics',
    'charges-and-fields',
    'faradays-law',
    'john-travoltage',
    'balloons-and-static-electricity',
    'magnet-and-compass',
  };

  /// Modules in PHASE 5 scope (optics / waves / quantum).
  static const Set<String> phase5ModuleIds = {
    'bending-light',
    'color-vision',
    'wave-on-a-string',
    'waves-intro',
    'normal-modes',
    'fourier-making-waves',
    'sound',
    'radio-waves',
    'quantum-measurement',
    'quantum-wave-interference',
    'quantum-coin-toss',
  };

  /// Modules in PHASE 6 scope (chemistry).
  static const Set<String> phase6ModuleIds = {
    'molarity',
    'beers-law-lab',
    'ph-scale',
    'acid-base-solutions',
    'build-a-nucleus',
    'rutherford-scattering',
    'build-an-atom',
    'isotopes-and-atomic-mass',
    'build-a-molecule',
    'molecule-polarity',
    'molecule-shapes',
    'molecules-and-light',
    'reactants-products-and-leftovers',
    'balancing-chemical-equations',
    'states-of-matter',
  };

  static LocalizationMigrationStatus of(String moduleId) =>
      statusByModule[moduleId] ?? LocalizationMigrationStatus.notStarted;
}
