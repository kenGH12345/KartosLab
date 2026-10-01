import 'dart:math' as math;

import '../ba_shared_constants.dart';
import 'ba_vector2.dart';

/// Mass identity for visual / catalog (Phase 1 model; no assets loaded).
enum BaMassType {
  sodaBottle,
  smallBucket,
  tinyRock,
  fireExtinguisher,
  flowerPot,
  puppy,
  television,
  smallTrashCan,
  pottedPlant,
  cinderBlock,
  tire,
  largeBucket,
  boy,
  mediumBucket,
  smallRock,
  girl,
  mediumRock,
  largeTrashCan,
  crate,
  bigRock,
  woman,
  fireHydrant,
  man,
  barrel,
  brickStack,
  mystery,
  /// Generic test mass used by physics oracles.
  generic,
}

/// Catalog mass values (kg) from `js/common/model/masses/*`.
abstract final class BaMassCatalog {
  static const Map<BaMassType, double> massKg = {
    BaMassType.sodaBottle: 2,
    BaMassType.smallBucket: 3,
    BaMassType.tinyRock: 4,
    BaMassType.fireExtinguisher: 5,
    BaMassType.flowerPot: 5,
    BaMassType.puppy: 6,
    BaMassType.television: 10,
    BaMassType.smallTrashCan: 10,
    BaMassType.pottedPlant: 10,
    BaMassType.cinderBlock: 12,
    BaMassType.tire: 15,
    BaMassType.largeBucket: 15,
    BaMassType.boy: 20,
    BaMassType.mediumBucket: 20,
    BaMassType.smallRock: 30,
    BaMassType.girl: 30,
    BaMassType.mediumRock: 40,
    BaMassType.largeTrashCan: 40,
    BaMassType.crate: 45,
    BaMassType.bigRock: 45,
    BaMassType.woman: 60,
    BaMassType.fireHydrant: 60,
    BaMassType.man: 80,
    BaMassType.barrel: 90,
  };

  static const double brickMass = 5;
  static const double brickWidth = 0.2;
  static const double brickHeight = brickWidth / 3;

  /// Default (non-stanford) mystery masses A–H.
  static const List<double> mysteryMassValues = [
    20,
    5,
    15,
    10,
    3,
    50,
    25,
    7.5,
  ];

  static const List<double> mysteryHeights = [
    0.25,
    0.30,
    0.35,
    0.4,
    0.25,
    0.35,
    0.4,
    0.3,
  ];

  static const Map<BaMassType, double> defaultHeights = {
    BaMassType.fireExtinguisher: 0.5,
    BaMassType.smallTrashCan: 0.55,
    BaMassType.largeTrashCan: 0.7,
    BaMassType.sodaBottle: 0.4,
    BaMassType.boy: 1.1,
    BaMassType.girl: 1.3,
    BaMassType.woman: 1.65,
    BaMassType.man: 1.8,
    BaMassType.tinyRock: 0.15,
    BaMassType.smallRock: 0.25,
    BaMassType.mediumRock: 0.3,
    BaMassType.bigRock: 0.35,
    BaMassType.cinderBlock: 0.2,
    BaMassType.smallBucket: 0.25,
    BaMassType.mediumBucket: 0.35,
    BaMassType.largeBucket: 0.4,
    BaMassType.barrel: 0.55,
    BaMassType.puppy: 0.35,
    BaMassType.fireHydrant: 0.55,
    BaMassType.television: 0.4,
    BaMassType.crate: 0.5,
    BaMassType.flowerPot: 0.35,
    BaMassType.pottedPlant: 0.45,
    BaMassType.tire: 0.3,
  };
}

/// Source: `js/common/model/Mass.ts` (+ ImageMass / BrickStack middle point).
class BaMass {
  BaMass({
    required this.massValue,
    required BaVector2 initialPosition,
    required this.type,
    this.height = 0.5,
    this.isMystery = false,
    this.numBricks = 0,
    this.mysteryMassId,
    this.centerOfMassXOffset = 0,
  })  : _initialPosition = initialPosition,
        position = initialPosition;

  final double massValue;
  final BaMassType type;
  final double height;
  final bool isMystery;
  final int numBricks;
  final int? mysteryMassId;
  final double centerOfMassXOffset;
  final BaVector2 _initialPosition;

  BaVector2 position;
  double rotationAngle = 0;
  bool userControlled = false;
  bool onPlank = false;
  bool animating = false;

  BaVector2? animationDestination;
  BaVector2? animationMotionVector;
  double animationScale = 1;
  double expectedAnimationTime = 0;

  factory BaMass.fromType(
    BaMassType type,
    BaVector2 position, {
    bool isMystery = false,
  }) {
    final kg = BaMassCatalog.massKg[type];
    if (kg == null) {
      throw ArgumentError('No catalog mass for $type');
    }
    return BaMass(
      massValue: kg,
      initialPosition: position,
      type: type,
      height: BaMassCatalog.defaultHeights[type] ?? 0.5,
      isMystery: isMystery,
      centerOfMassXOffset: type == BaMassType.fireExtinguisher ? 0.03 : 0,
    );
  }

  factory BaMass.brickStack(int numBricks, BaVector2 position) {
    if (numBricks <= 0) {
      throw ArgumentError('Must have at least one brick');
    }
    return BaMass(
      massValue: numBricks * BaMassCatalog.brickMass,
      initialPosition: position,
      type: BaMassType.brickStack,
      height: numBricks * BaMassCatalog.brickHeight,
      numBricks: numBricks,
    );
  }

  factory BaMass.mystery(int mysteryMassId, BaVector2 position) {
    final values = BaMassCatalog.mysteryMassValues;
    if (mysteryMassId < 0 || mysteryMassId >= values.length) {
      throw RangeError('mysteryMassId out of range');
    }
    return BaMass(
      massValue: values[mysteryMassId],
      initialPosition: position,
      type: BaMassType.mystery,
      height: BaMassCatalog.mysteryHeights[mysteryMassId],
      isMystery: true,
      mysteryMassId: mysteryMassId,
    );
  }

  factory BaMass.generic(
    double massKg,
    BaVector2 position, {
    double height = 0.2,
  }) {
    return BaMass(
      massValue: massKg,
      initialPosition: position,
      type: BaMassType.generic,
      height: height,
    );
  }

  /// Clone for challenge factory (source `Mass.createCopy`).
  BaMass createCopy() {
    if (type == BaMassType.brickStack) {
      return BaMass.brickStack(numBricks, const BaVector2(0, 0));
    }
    if (type == BaMassType.mystery && mysteryMassId != null) {
      return BaMass.mystery(mysteryMassId!, const BaVector2(0, 0));
    }
    if (type == BaMassType.generic) {
      return BaMass.generic(massValue, const BaVector2(0, 0), height: height);
    }
    return BaMass.fromType(type, const BaVector2(0, 0), isMystery: isMystery);
  }

  BaVector2 getMiddlePoint() {
    if (type == BaMassType.brickStack) {
      final localCenter = BaVector2(
        BaMassCatalog.brickWidth / 2,
        height / 2,
      ).rotated(rotationAngle);
      return position.plus(localCenter);
    }
    return BaVector2(position.x, position.y + height / 2);
  }

  void reset() {
    userControlled = false;
    position = _initialPosition;
    rotationAngle = 0;
    onPlank = false;
    animating = false;
    animationScale = 1;
    animationDestination = null;
    animationMotionVector = null;
    expectedAnimationTime = 0;
  }

  void initiateAnimation() {
    final dest = animationDestination;
    if (dest == null) return;
    final velocity = math.max(
      position.distance(dest) / BaGeometry.maxRemovalAnimationDuration,
      BaGeometry.minAnimationVelocity,
    );
    expectedAnimationTime = position.distance(dest) / velocity;
    final angle = math.atan2(dest.y - position.y, dest.x - position.x);
    animationMotionVector = BaVector2(velocity, 0).rotated(angle);
    animating = true;
  }

  void step(double dt) {
    if (!animating) return;
    final dest = animationDestination!;
    final motion = animationMotionVector!;
    if (position.distance(dest) >= motion.magnitude * dt) {
      position = position.plus(motion.times(dt));
      animationScale = math.max(
        animationScale - (dt / expectedAnimationTime) * 0.9,
        0.1,
      );
    } else {
      position = dest;
      animating = false;
      animationScale = 1;
    }
  }
}
