import 'dart:ui' show Offset;

import 'package:kratos/under_pressure/model/mass/mass_model.dart';
import 'package:kratos/under_pressure/model/pool/pool_scene_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';

/// Axis-aligned chamber region (source poolDimensions entries).
class ChamberRegion {
  const ChamberRegion({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  bool contains(double x, double y) =>
      x > x1 && x < x2 && y < y1 && y > y2;
}

/// Density / gravity accessors needed by MassModel (avoids circular import).
abstract class ChamberHost {
  double get fluidDensity;
  double get gravity;
  void notifyBarometersUpdate();
}

/// Source: `ChamberPoolModel.js`
class ChamberPoolModel implements PoolSceneModel {
  ChamberPoolModel({required this.host}) {
    poolDimensions = _buildDimensions();
    masses = [
      MassModel(
        chamber: this,
        mass: 500,
        x: _massOffset,
        y: maxY + _passageSize / 2,
        width: _passageSize,
        height: _passageSize,
      ),
      MassModel(
        chamber: this,
        mass: 250,
        x: _massOffset + _passageSize + _separation,
        y: maxY + _passageSize / 4,
        width: _passageSize,
        height: _passageSize / 2,
      ),
      MassModel(
        chamber: this,
        mass: 250,
        x: _massOffset + 2 * _passageSize + 2 * _separation,
        y: maxY + _passageSize / 4,
        width: _passageSize,
        height: _passageSize / 2,
      ),
    ];
  }

  static const double _passageSize = 0.5;
  static const double _rightOpeningWidth = 2.3;
  static const double _leftOpeningWidth = 0.5;
  static const double _chamberHeight = 1.3;
  static const double _leftChamberX = 1.55;
  static const double _leftChamberWidth = 2.8;
  static const double _rightChamberX = 6.27;
  static const double _rightChamberWidth = 1.1;
  static const double _massOffset = 1.35;
  static const double _separation = 0.03;

  /// Meters without load.
  static const double defaultHeight = 2.3;

  final ChamberHost host;

  late final Map<String, ChamberRegion> poolDimensions;
  late final List<MassModel> masses;

  double leftDisplacement = 0;
  double stackMass = 0;

  /// Source volumeProperty default 1 — not used for faucet/level math.
  double _volume = 1;

  final List<MassModel> stack = [];

  /// RIGHT_OPENING_WIDTH / LEFT_OPENING_WIDTH
  final double lengthRatio = _rightOpeningWidth / _leftOpeningWidth;

  /// default left opening water height
  final double leftWaterHeight = defaultHeight - _chamberHeight;

  /// Masses can't have y-coord more than this.
  final double maxY = 0.05;

  ChamberRegion get leftOpening => poolDimensions['leftOpening']!;
  ChamberRegion get rightOpening => poolDimensions['rightOpening']!;
  ChamberRegion get leftChamber => poolDimensions['leftChamber']!;

  static Map<String, ChamberRegion> _buildDimensions() {
    const maxHeight = UnderPressureConstants.maxPoolHeight;
    return {
      'leftChamber': ChamberRegion(
        x1: _leftChamberX,
        y1: -(maxHeight - _chamberHeight),
        x2: _leftChamberX + _leftChamberWidth,
        y2: -maxHeight,
      ),
      'rightChamber': ChamberRegion(
        x1: _rightChamberX,
        y1: -(maxHeight - _chamberHeight),
        x2: _rightChamberX + _rightChamberWidth,
        y2: -maxHeight,
      ),
      'horizontalPassage': ChamberRegion(
        x1: _leftChamberX + _leftChamberWidth,
        y1: -(maxHeight - _passageSize * 3 / 2),
        x2: _rightChamberX,
        y2: -(maxHeight - _passageSize / 2),
      ),
      'leftOpening': ChamberRegion(
        x1: _leftChamberX + _leftChamberWidth / 2 - _leftOpeningWidth / 2,
        y1: 0,
        x2: _leftChamberX + _leftChamberWidth / 2 + _leftOpeningWidth / 2,
        y2: -(maxHeight - _chamberHeight),
      ),
      'rightOpening': ChamberRegion(
        x1: _rightChamberX + _rightChamberWidth / 2 - _rightOpeningWidth / 2,
        y1: 0,
        x2: _rightChamberX + _rightChamberWidth / 2 + _rightOpeningWidth / 2,
        y2: -(maxHeight - _chamberHeight),
      ),
    };
  }

  @override
  double get volume => _volume;

  void pushToStack(MassModel mass) {
    if (stack.contains(mass)) return;
    stack.add(mass);
    stackMass += mass.mass;
    var maxVelocity = 0.0;
    for (final m in stack) {
      if (m.velocity > maxVelocity) maxVelocity = m.velocity;
    }
    for (final m in stack) {
      m.velocity = maxVelocity;
    }
    // Source MassStackNode.updateMassPositions on stack add.
    syncStackPositions();
  }

  void removeFromStack(MassModel mass) {
    if (!stack.remove(mass)) return;
    stackMass -= mass.mass;
    syncStackPositions();
  }

  /// Source `MassStackNode.updateMassPositions` — snap stacked masses into opening.
  void syncStackPositions() {
    var dy = 0.0;
    for (final massModel in stack) {
      massModel.position = Offset(
        leftOpening.x1 + massModel.width / 2,
        leftOpening.y2 +
            leftWaterHeight -
            leftDisplacement +
            dy +
            massModel.height / 2,
      );
      dy += massModel.height;
    }
  }

  @override
  void reset() {
    stack.clear();
    leftDisplacement = 0;
    stackMass = 0;
    _volume = 1;
    for (final mass in masses) {
      mass.reset();
    }
  }

  @override
  void step(double dt) {
    const nominalDt = 1 / 60;
    final limitedDt = dt < nominalDt * 3 ? dt : nominalDt * 3;

    const steps = 15;
    for (final mass in masses) {
      if (stack.contains(mass)) {
        for (var i = 0; i < steps; i++) {
          mass.step(limitedDt / steps);
        }
      } else {
        mass.step(limitedDt);
      }
    }

    if (stackMass != 0) {
      var minY = 0.0;
      for (final massModel in stack) {
        final bottom = massModel.position.dy - massModel.height / 2;
        if (bottom < minY) minY = bottom;
      }
      leftDisplacement =
          (leftOpening.y2 + leftWaterHeight - minY).clamp(0.0, double.infinity);
    } else {
      if (leftDisplacement >= 0) {
        leftDisplacement -= leftDisplacement / 10;
      } else {
        leftDisplacement = 0;
      }
    }
    host.notifyBarometersUpdate();
  }

  @override
  double getWaterHeightAboveY(double x, double y) {
    if (leftOpening.x1 < x &&
        x < leftOpening.x2 &&
        y > leftChamber.y2 + defaultHeight - leftDisplacement) {
      return 0;
    }
    return leftChamber.y2 +
        defaultHeight +
        leftDisplacement / lengthRatio -
        y;
  }

  @override
  bool isPointInsidePool(double x, double y) {
    for (final region in poolDimensions.values) {
      if (region.contains(x, y)) return true;
    }
    return false;
  }
}
