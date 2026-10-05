/// Celestial body with path + rewind — port of `Body.ts` (model fields only).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../gao_constants.dart';
import 'body_state.dart';
import 'body_type.dart';
import 'gao_vec.dart';
import 'mode_config.dart';

class GaoBody {
  GaoBody.fromConfig(BodyConfiguration config)
      : type = config.type,
        tickMass = config.mass,
        tickLabel = config.tickLabel,
        massSettable = config.massSettable,
        massReadoutBelow = config.massReadoutBelow,
        pathLengthBuffer = config.pathLengthBuffer,
        pathLengthLimit = GaoConstants.pathLengthLimit,
        touchDilation = config.touchDilation,
        rotationPeriod = config.rotationPeriod,
        isMovable = config.isMovable,
        labelAngle = config.resolvedLabelAngle,
        _initialPosition = GaoVec(config.x, config.y),
        _initialVelocity = GaoVec(config.vx, config.vy),
        _initialMass = config.mass,
        _initialDiameter = config.radius * 2,
        _fallbackMaxPathLength = config.maxPathLength ?? 1400000000 {
    position = _initialPosition.copy();
    velocity = _initialVelocity.copy();
    mass = _initialMass;
    diameter = _initialDiameter;
    _computeMaxPathLength();
    saveRewindState();
  }

  final GaoBodyType type;
  final double tickMass;
  final String tickLabel;
  final bool massSettable;
  final bool massReadoutBelow;
  final double pathLengthBuffer;
  final double pathLengthLimit;
  final double touchDilation;
  final double? rotationPeriod;
  final double labelAngle;
  bool isMovable;

  late GaoVec position;
  late GaoVec velocity;
  final GaoVec acceleration = GaoVec.zero();
  final GaoVec force = GaoVec.zero();
  late double mass;
  late double diameter;
  double rotation = 0;
  bool isCollided = false;
  int clockTicksSinceExplosion = 0;
  bool userControlled = false;

  final List<GaoVec> path = [];
  double modelPathLength = 0;
  late double maxPathLength;

  GaoVec? _rewindPosition;
  GaoVec? _rewindVelocity;
  GaoVec? _rewindForce;
  double? _rewindMass;
  bool? _rewindCollided;
  double? _rewindRotation;

  final GaoVec _initialPosition;
  final GaoVec _initialVelocity;
  final double _initialMass;
  final double _initialDiameter;
  final double _fallbackMaxPathLength;
  final GaoVec previousPosition = GaoVec.zero();

  double get radius => diameter / 2;
  double get speed => velocity.magnitude;

  /// `PathsCanvasNode.paintCanvas` — `context.strokeStyle = body.color.toCSS()`.
  Color get pathColor {
    switch (type) {
      case GaoBodyType.star:
        return GaoConstants.starPath;
      case GaoBodyType.planet:
        return GaoConstants.planetPath;
      case GaoBodyType.moon:
        return GaoConstants.moonPath;
      case GaoBodyType.satellite:
        return GaoConstants.satellitePath;
    }
  }

  void _computeMaxPathLength() {
    final dist = _initialPosition.magnitude;
    if (dist < 1000) {
      maxPathLength = _fallbackMaxPathLength;
    } else {
      maxPathLength = 0.85 * 2 * math.pi * dist + pathLengthBuffer;
    }
  }

  BodyState toBodyState() => BodyState(
        type: type,
        position: position.copy(),
        velocity: velocity.copy(),
        acceleration: acceleration.copy(),
        mass: mass,
        exploded: isCollided,
        rotation: rotation,
        rotationPeriod: rotationPeriod,
      );

  void updateFromModel(BodyState state) {
    if (isCollided) return;
    if (isMovable && !userControlled) {
      position.setFrom(state.position);
      velocity.setFrom(state.velocity);
    }
    acceleration.setFrom(state.acceleration);
    force.setXY(
      state.acceleration.x * state.mass,
      state.acceleration.y * state.mass,
    );
    rotation = state.rotation;
  }

  void storePreviousPosition() => previousPosition.setFrom(position);

  void modelStepped() {
    if (!userControlled && !isCollided && isMovable) {
      addPathPoint();
    }
  }

  void addPathPoint() {
    path.add(position.copy());
    if (path.length > 2) {
      modelPathLength += (path[path.length - 1] - path[path.length - 2]).magnitude;
    }
    while (modelPathLength > maxPathLength || path.length > pathLengthLimit) {
      if (path.length < 2) break;
      final loss = (path[1] - path[0]).magnitude;
      path.removeAt(0);
      modelPathLength -= loss;
    }
  }

  void clearPath() {
    path.clear();
    modelPathLength = 0;
  }

  bool collidesWith(GaoBody other) {
    final dx = position.x - other.position.x;
    final dy = position.y - other.position.y;
    final distance = math.sqrt(dx * dx + dy * dy);
    return distance < radius + other.radius;
  }

  void saveRewindState() {
    _rewindPosition = position.copy();
    _rewindVelocity = velocity.copy();
    _rewindForce = force.copy();
    _rewindMass = mass;
    _rewindCollided = isCollided;
    _rewindRotation = rotation;
  }

  void rewind() {
    if (_rewindPosition != null) position.setFrom(_rewindPosition!);
    if (_rewindVelocity != null) velocity.setFrom(_rewindVelocity!);
    if (_rewindForce != null) force.setFrom(_rewindForce!);
    if (_rewindMass != null) mass = _rewindMass!;
    if (_rewindCollided != null) isCollided = _rewindCollided!;
    if (_rewindRotation != null) rotation = _rewindRotation!;
    clearPath();
  }

  bool get hasDeviatedFromRewind {
    if (_rewindPosition == null) return false;
    return !position.equalsApprox(_rewindPosition!) ||
        !velocity.equalsApprox(_rewindVelocity!) ||
        mass != _rewindMass ||
        isCollided != _rewindCollided;
  }

  void resetAll() {
    position.setFrom(_initialPosition);
    velocity.setFrom(_initialVelocity);
    acceleration.setXY(0, 0);
    force.setXY(0, 0);
    mass = _initialMass;
    diameter = _initialDiameter;
    isCollided = false;
    clockTicksSinceExplosion = 0;
    rotation = 0;
    clearPath();
    saveRewindState();
  }
}
