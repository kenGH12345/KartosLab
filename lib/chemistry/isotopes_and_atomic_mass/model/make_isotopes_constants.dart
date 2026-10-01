/// Make Isotopes (Isotopes screen) model constants — from PhET IsotopesModel.ts.
library;

/// Screen 1 interactive periodic table max Z (`ExpandedPeriodicTableNode(..., 10)`).
const int kMakeIsotopesMaxAtomicNumber = 10;

/// Default selected element: Hydrogen.
const int kMakeIsotopesDefaultAtomicNumber = 1;

/// Neutrons placed in the bucket on each element init (`DEFAULT_NUM_NEUTRONS_IN_BUCKET`).
const int kDefaultNeutronsInBucket = 4;

/// Nucleon capture radius in model units (`NUCLEON_CAPTURE_RADIUS`).
const double kNucleonCaptureRadius = 100;

/// Unstable nucleus jump period in seconds (`NUCLEUS_JUMP_PERIOD`).
const double kNucleusJumpPeriod = 0.1;

/// Max jump distance = `ShredConstants.NUCLEON_RADIUS * 0.5` (NUCLEON_RADIUS = 10).
const double kMaxNucleusJump = 5.0;

/// Empirically chosen jump angles from IsotopesModel.ts.
const List<double> kJumpAngles = <double>[
  0.3141592653589793, // Math.PI * 0.1
  5.026548245743669, // Math.PI * 1.6
  2.199114857512855, // Math.PI * 0.7
  3.4557519189487724, // Math.PI * 1.1
  0.9424777960769379, // Math.PI * 0.3
];

/// Empirically chosen jump distances from IsotopesModel.ts.
final List<double> kJumpDistances = <double>[
  kMaxNucleusJump * 0.4,
  kMaxNucleusJump * 0.8,
  kMaxNucleusJump * 0.2,
  kMaxNucleusJump * 0.9,
];

/// Neutron bucket model position (`NEUTRON_BUCKET_POSITION`).
const double kNeutronBucketX = -220;
const double kNeutronBucketY = -180;

/// Neutron bucket size (`BUCKET_SIZE`).
const double kNeutronBucketWidth = 130;
const double kNeutronBucketHeight = 60;

/// shred `ShredConstants.NUCLEON_RADIUS` (model / screen units ≈ px).
const double kNucleonRadius = 10;

/// Default `ParticleAtom.position` before View places atom on the scale.
/// IsotopeAtomNode later updates this from electron-cloud bounds.
const double kDefaultAtomX = 0;
const double kDefaultAtomY = 0;
