import 'famb_constants.dart';
import 'forces_simulation.dart';

/// Screen style for shared MotionModel (PhET MotionScreen style string).
enum MotionScreenStyle { motion, friction, acceleration }

/// Movable stack item — masses / homes from PhET MotionModel item constructors.
class ForceItem {
  ForceItem({
    required this.id,
    required this.mass,
    required this.assetPath,
    required this.homeX,
    required this.homeY,
    required this.imageScale,
    this.homeScale = 1.0,
    this.sittingAssetPath,
    this.holdingAssetPath,
    this.intrinsicWidth = 100,
    this.intrinsicHeight = 100,
    this.sittingWidth,
    this.sittingHeight,
    this.massKnown = true,
    this.isHuman = false,
    this.isBucket = false,
    this.inLeftToolbox = false,
  });

  final String id;
  final double mass;
  final String assetPath;
  final String? sittingAssetPath;
  final String? holdingAssetPath;

  /// PhET toolbox home (top-left of node), layout coords.
  final double homeX;
  final double homeY;
  final double imageScale;
  final double homeScale;
  final double intrinsicWidth;
  final double intrinsicHeight;
  final double? sittingWidth;
  final double? sittingHeight;

  final bool massKnown;
  final bool isHuman;
  final bool isBucket;
  final bool inLeftToolbox;

  ForceItem copy() => ForceItem(
        id: id,
        mass: mass,
        assetPath: assetPath,
        sittingAssetPath: sittingAssetPath,
        holdingAssetPath: holdingAssetPath,
        homeX: homeX,
        homeY: homeY,
        imageScale: imageScale,
        homeScale: homeScale,
        intrinsicWidth: intrinsicWidth,
        intrinsicHeight: intrinsicHeight,
        sittingWidth: sittingWidth,
        sittingHeight: sittingHeight,
        massKnown: massKnown,
        isHuman: isHuman,
        isBucket: isBucket,
        inLeftToolbox: inLeftToolbox,
      );
}

const _assetRoot = 'assets/simulations/forces_and_motion_basics/images';

/// Catalog builders per screen (PhET MotionModel item list + home positions).
List<ForceItem> buildCatalog(MotionScreenStyle style) {
  final accelerometer = style == MotionScreenStyle.acceleration;
  final isTrashCanPresent = style != MotionScreenStyle.acceleration;

  const leftmostItemXLeft = 23.0;
  const crate1Spacing = 106.0;
  const crate2Spacing = 90.0;

  final leftmostItemXRight =
      accelerometer ? (isTrashCanPresent ? 678.0 : 685.0) : 689.0;
  final manSpacing =
      accelerometer ? (isTrashCanPresent ? 47.0 : 55.0) : 61.0;
  final trashSpacing =
      isTrashCanPresent ? (accelerometer ? 53.0 : 66.0) : 0.0;
  final mysterySpacing =
      accelerometer ? (isTrashCanPresent ? 51.0 : 65.0) : 72.0;
  final bucketSpacing = isTrashCanPresent ? 63.0 : 75.0;

  final fridge = ForceItem(
    id: 'fridge',
    mass: 200,
    assetPath: '$_assetRoot/fridge.svg',
    homeX: leftmostItemXLeft,
    homeY: 443,
    imageScale: 0.5,
    homeScale: 1.1,
    intrinsicWidth: 162.9,
    intrinsicHeight: 253.8,
    inLeftToolbox: true,
  );
  final crate1 = ForceItem(
    id: 'crate1',
    mass: 50,
    assetPath: '$_assetRoot/crate.svg',
    homeX: leftmostItemXLeft + crate1Spacing,
    homeY: 507,
    imageScale: 0.5,
    intrinsicWidth: 151,
    intrinsicHeight: 151,
    inLeftToolbox: true,
  );
  final crate2 = ForceItem(
    id: 'crate2',
    mass: 50,
    assetPath: '$_assetRoot/crate.svg',
    homeX: leftmostItemXLeft + crate1Spacing + crate2Spacing,
    homeY: 507,
    imageScale: 0.5,
    intrinsicWidth: 151,
    intrinsicHeight: 151,
    inLeftToolbox: true,
  );
  final girl = ForceItem(
    id: 'girl',
    mass: 40,
    assetPath: '$_assetRoot/usa/usaGirlStanding.svg',
    sittingAssetPath: '$_assetRoot/usa/usaGirlSitting.svg',
    holdingAssetPath: '$_assetRoot/usa/usaGirlHolding.svg',
    homeX: leftmostItemXRight,
    homeY: 465,
    imageScale: 0.6,
    homeScale: 1.0,
    intrinsicWidth: 65,
    intrinsicHeight: 196,
    sittingWidth: 88,
    sittingHeight: 126,
    isHuman: true,
  );
  final man = ForceItem(
    id: 'man',
    mass: 80,
    assetPath: '$_assetRoot/usa/usaManStanding.svg',
    sittingAssetPath: '$_assetRoot/usa/usaManSitting.svg',
    holdingAssetPath: '$_assetRoot/usa/usaManHolding.svg',
    homeX: leftmostItemXRight + manSpacing,
    homeY: 428,
    imageScale: 0.6,
    homeScale: 0.92,
    intrinsicWidth: 83,
    intrinsicHeight: 280,
    sittingWidth: 107,
    sittingHeight: 161,
    isHuman: true,
  );
  final trash = ForceItem(
    id: 'trash',
    mass: 100,
    assetPath: '$_assetRoot/trashCan.svg',
    homeX: leftmostItemXRight + manSpacing + trashSpacing,
    homeY: 496,
    imageScale: 0.5,
    homeScale: 1.0,
    intrinsicWidth: 93.1,
    intrinsicHeight: 172,
  );
  final mystery = ForceItem(
    id: 'mystery',
    mass: 50,
    assetPath: '$_assetRoot/mysteryObject01.svg',
    homeX: leftmostItemXRight + manSpacing + trashSpacing + mysterySpacing,
    homeY: 513,
    imageScale: 0.5,
    homeScale: 1.0,
    intrinsicWidth: 118,
    intrinsicHeight: 137,
    massKnown: false,
  );
  final bucket = ForceItem(
    id: 'bucket',
    mass: 100,
    assetPath: '$_assetRoot/waterBucket.svg',
    homeX: leftmostItemXRight +
        manSpacing +
        trashSpacing +
        mysterySpacing +
        bucketSpacing,
    homeY: 548 - 35,
    imageScale: 0.5,
    homeScale: 1.0,
    intrinsicWidth: 135.34,
    intrinsicHeight: 137.35,
    isBucket: true,
  );

  switch (style) {
    case MotionScreenStyle.motion:
    case MotionScreenStyle.friction:
      return [fridge, crate1, crate2, girl, man, trash, mystery];
    case MotionScreenStyle.acceleration:
      return [fridge, crate1, crate2, girl, man, mystery, bucket];
  }
}

/// Shared Motion / Friction / Acceleration model.
class MotionModel {
  MotionModel(this.style) : sim = ForcesSimulation() {
    catalog = buildCatalog(style);
    switch (style) {
      case MotionScreenStyle.motion:
        sim.frictionCoeff = 0;
        break;
      case MotionScreenStyle.friction:
      case MotionScreenStyle.acceleration:
        sim.frictionCoeff = MotionConstants.defaultFrictionHalf;
        break;
    }
    // PhET starts with crate1 on the stack.
    final crate1 = catalog.firstWhere((i) => i.id == 'crate1');
    stack.add(crate1);
    _syncMass();
    sim.updateForces();
  }

  final MotionScreenStyle style;
  final ForcesSimulation sim;

  late final List<ForceItem> catalog;
  final List<ForceItem> stack = [];

  bool isPlaying = true;

  bool showForce = true;
  bool showSumOfForces = false;
  bool showValues = false;
  bool showMasses = false;
  bool showSpeed = false;
  bool showAcceleration = false;
  bool showStopwatch = false;

  double pusherPosition = MotionConstants.pusherHomePosition;

  bool stopwatchRunning = false;
  double stopwatchElapsed = 0;

  bool get hasSkateboard => style == MotionScreenStyle.motion;
  bool get hasAccelerometer => style == MotionScreenStyle.acceleration;
  bool get hasFrictionSlider => style != MotionScreenStyle.motion;
  bool get hasStopwatch => style != MotionScreenStyle.acceleration;

  double get totalMass => stack.fold(0, (s, i) => s + i.mass);

  List<ForceItem> get toolboxItems =>
      catalog.where((i) => !stack.contains(i)).toList();

  /// PhET: human raises arms when another item is stacked above them.
  bool isItemStackedAbove(ForceItem item) {
    final i = stack.indexOf(item);
    return i >= 0 && i < stack.length - 1;
  }

  void _syncMass() {
    sim.mass = totalMass;
    if (stack.isEmpty) {
      sim.velocity = 0;
      sim.acceleration = 0;
      sim.appliedForce = 0;
    }
    sim.updateForces();
  }

  bool addToStack(ForceItem item) {
    if (stack.contains(item)) return false;
    if (stack.length >= MotionConstants.maxStack) {
      final bottom = stack.removeAt(0);
      assert(catalog.contains(bottom));
    }
    stack.add(item);
    _syncMass();
    return true;
  }

  void removeFromStack(ForceItem item) {
    stack.remove(item);
    _syncMass();
  }

  void setAppliedForce(double f) => sim.setAppliedForce(f);

  void setFriction(double mu) {
    if (!hasFrictionSlider) return;
    sim.setFriction(mu);
  }

  void step(double dt) {
    if (isPlaying) {
      sim.stepModel(dt);
      if (stopwatchRunning && hasStopwatch) {
        stopwatchElapsed += dt;
        if (stopwatchElapsed > 3599.99) stopwatchElapsed = 3599.99;
      }
    } else {
      sim.updateForces();
    }
  }

  void manualStep() {
    sim.updateForces();
    sim.manualStep();
    if (stopwatchRunning && hasStopwatch) {
      stopwatchElapsed += MotionConstants.dt;
    }
  }

  void reset() {
    stack.clear();
    final crate1 = catalog.firstWhere((i) => i.id == 'crate1');
    stack.add(crate1);
    sim.frictionCoeff = style == MotionScreenStyle.motion
        ? 0
        : MotionConstants.defaultFrictionHalf;
    sim.resetDynamics();
    _syncMass();
    isPlaying = true;
    showForce = true;
    showSumOfForces = false;
    showValues = false;
    showMasses = false;
    showSpeed = false;
    showAcceleration = false;
    showStopwatch = false;
    stopwatchRunning = false;
    stopwatchElapsed = 0;
    pusherPosition = MotionConstants.pusherHomePosition;
  }
}
