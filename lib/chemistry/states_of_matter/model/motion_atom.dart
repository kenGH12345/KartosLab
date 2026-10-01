import 'package:flutter/material.dart';

import '../som_constants.dart';
import 'atom_type.dart';
import 'som_vec2.dart';

/// Atom with position / velocity / acceleration — PhET `MotionAtom`.
class MotionAtom extends ChangeNotifier {
  MotionAtom({
    required AtomType initialAtomType,
    double initialX = 0,
    double initialY = 0,
  })  : _atomType = initialAtomType,
        _initialAtomType = initialAtomType,
        _initX = initialX,
        _initY = initialY,
        position = SomVec2(initialX, initialY),
        velocity = SomVec2(0, 0),
        acceleration = SomVec2(0, 0) {
    _applyAtomType(initialAtomType);
  }

  AtomType _atomType;
  AtomType get atomType => _atomType;

  final AtomType _initialAtomType;
  final double _initX;
  final double _initY;

  double radius = 0;
  double mass = 0;
  Color color = Colors.white;
  double epsilon = 0;

  final SomVec2 position;
  final SomVec2 velocity;
  final SomVec2 acceleration;

  void setAtomType(AtomType type) {
    if (_atomType == type) return;
    _atomType = type;
    _applyAtomType(type);
    notifyListeners();
  }

  void _applyAtomType(AtomType type) {
    final attrs = SomConstants.attributesFor(type);
    mass = attrs.mass;
    color = attrs.color;
    // Keep adjustable radius if already customized via setAdjustableAtomSigma.
    if (type != AtomType.adjustable || radius == 0) {
      radius = attrs.radius;
    }
  }

  void setPosition(double x, double y) {
    position.setXY(x, y);
    notifyListeners();
  }

  double getX() => position.x;
  double getY() => position.y;
  double getVx() => velocity.x;
  double getVy() => velocity.y;
  double getAx() => acceleration.x;
  double getAy() => acceleration.y;

  void setVx(double vx) {
    velocity.x = vx;
    notifyListeners();
  }

  void setVy(double vy) {
    velocity.y = vy;
    notifyListeners();
  }

  void setAx(double ax) {
    acceleration.x = ax;
    notifyListeners();
  }

  void setAy(double ay) {
    acceleration.y = ay;
    notifyListeners();
  }

  AtomType getType() => _atomType;

  void reset() {
    _atomType = _initialAtomType;
    radius = 0;
    _applyAtomType(_initialAtomType);
    position.setXY(_initX, _initY);
    velocity.setXY(0, 0);
    acceleration.setXY(0, 0);
    notifyListeners();
  }
}
