/// Mix Isotopes (Mixtures screen) model constants — from PhET MixturesModel.ts.
library;

/// `MAX_ATOMIC_NUMBER` for Mix screen.
const int kMixMaxAtomicNumber = 18;

/// Default selected element: Hydrogen.
const int kMixDefaultAtomicNumber = 1;

/// `NUM_LARGE_ISOTOPES_PER_BUCKET`.
const int kNumLargeIsotopesPerBucket = 10;

/// `NumericalIsotopeQuantityControl.CAPACITY`.
const int kSliderCapacity = 100;

/// `NUM_NATURES_MIX_ATOMS`.
const int kNumNaturesMixAtoms = 1000;

/// `LARGE_ISOTOPE_RADIUS` / `SMALL_ISOTOPE_RADIUS`.
const double kLargeIsotopeRadius = 10;
const double kSmallIsotopeRadius = 4;

/// Test chamber size (model units / picometers) — IsotopeTestChamber.SIZE.
const double kTestChamberWidth = 450;
const double kTestChamberHeight = 280;

/// Chamber rect centered at origin: [-W/2, -H/2, W, H].
const double kTestChamberMinX = -kTestChamberWidth / 2;
const double kTestChamberMaxX = kTestChamberWidth / 2;
const double kTestChamberMinY = -kTestChamberHeight / 2;
const double kTestChamberMaxY = kTestChamberHeight / 2;

/// MonoIsotopeBucket size / Y from MixturesModel.addBuckets.
const double kMixBucketWidth = 120;
const double kMixBucketHeight = 50;
const double kMixBucketY = -250;

/// NumericalIsotopeQuantityControl Y (`controllerYOffsetSlider`).
const double kMixSliderY = -238;

/// ControlIsotope / mode icon slider max width (empirically 99.75).
const double kMixMaxSliderWidth = 99.75;

/// Digits used when sampling Nature's Mix abundances.
const int kNaturesMixAbundanceDigits = 5;
