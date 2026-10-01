import 'dart:math' as math;

import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/track.dart';

/// Immutable-ish snapshot for physics (SkaterState.ts). Fields are mutable
/// for correctEnergyReduceVelocity which mutates a protected clone.
class SkaterState {
  SkaterState({
    this.gravity = -9.8,
    this.referenceHeight = 0,
    this.mass = 60,
    this.track,
    this.angle = 0,
    this.isOnTopSideOfTrack = true,
    this.parametricPosition = 0,
    this.parametricSpeed = 0,
    this.userControlled = false,
    this.thermalEnergy = 0,
    this.positionX = 0,
    this.positionY = 0,
    this.velocityX = 0,
    this.velocityY = 0,
  });

  factory SkaterState.from(SkaterState source) => SkaterState(
        gravity: source.gravity,
        referenceHeight: source.referenceHeight,
        mass: source.mass,
        track: source.track,
        angle: source.angle,
        isOnTopSideOfTrack: source.isOnTopSideOfTrack,
        parametricPosition: source.parametricPosition,
        parametricSpeed: source.parametricSpeed,
        userControlled: source.userControlled,
        thermalEnergy: source.thermalEnergy,
        positionX: source.positionX,
        positionY: source.positionY,
        velocityX: source.velocityX,
        velocityY: source.velocityY,
      );

  double gravity;
  double referenceHeight;
  double mass;
  Track? track;
  double angle;
  bool isOnTopSideOfTrack;
  double parametricPosition;
  double parametricSpeed;
  bool userControlled;
  double thermalEnergy;
  double positionX;
  double positionY;
  double velocityX;
  double velocityY;

  double getTotalEnergy() =>
      0.5 * mass * (velocityX * velocityX + velocityY * velocityY) -
      mass * gravity * (positionY - referenceHeight) +
      thermalEnergy;

  double getKineticEnergy() =>
      0.5 * mass * (velocityX * velocityX + velocityY * velocityY);

  /// PE = -m * g * (y - href) with g signed negative.
  double getPotentialEnergy() =>
      -mass * gravity * (positionY - referenceHeight);

  void getCurvature(Curvature curvature) {
    track!.getCurvature(parametricPosition, curvature);
  }

  double getAngle() => angle;

  double getSpeed() =>
      math.sqrt(velocityX * velocityX + velocityY * velocityY);

  EspVec getVelocity() => EspVec(velocityX, velocityY);

  EspVec getPosition() => EspVec(positionX, positionY);

  double getSpeedFromEnergy(double kineticEnergy) =>
      math.sqrt(2 * kineticEnergy.abs() / mass);

  SkaterState copy() => SkaterState.from(this);

  SkaterState leaveTrack() {
    final state = copy();
    state.parametricSpeed = 0;
    state.track = null;
    return state;
  }

  SkaterState updateThermalEnergy(double thermalEnergy) {
    assert(thermalEnergy >= 0);
    final state = copy();
    state.thermalEnergy = thermalEnergy;
    return state;
  }

  SkaterState attachToTrack(
    double thermalEnergy,
    Track track,
    bool isOnTopSideOfTrack,
    double parametricPosition,
    double parametricSpeed,
    double velocityX,
    double velocityY,
    double positionX,
    double positionY,
  ) {
    assert(thermalEnergy >= 0);
    final state = copy();
    state.thermalEnergy = thermalEnergy;
    state.track = track;
    state.isOnTopSideOfTrack = isOnTopSideOfTrack;
    state.parametricPosition = parametricPosition;
    state.parametricSpeed = parametricSpeed;
    state.velocityX = velocityX;
    state.velocityY = velocityY;
    state.positionX = positionX;
    state.positionY = positionY;
    return state;
  }

  SkaterState switchToGround(
    double thermalEnergy,
    double velocityX,
    double velocityY,
    double positionX,
    double positionY,
  ) {
    assert(thermalEnergy >= 0);
    final state = copy();
    state.thermalEnergy = thermalEnergy;
    state.track = null;
    state.isOnTopSideOfTrack = true;
    state.angle = 0;
    state.velocityX = velocityX;
    state.velocityY = velocityY;
    state.positionX = positionX;
    state.positionY = positionY;
    return state;
  }

  SkaterState strikeGround(double thermalEnergy, double positionX) {
    assert(thermalEnergy >= 0);
    final state = copy();
    state.thermalEnergy = thermalEnergy;
    state.positionX = positionX;
    state.positionY = 0;
    state.velocityX = 0;
    state.velocityY = 0;
    state.angle = 0;
    state.isOnTopSideOfTrack = true;
    return state;
  }

  SkaterState updateTrackUD(Track? track, double parametricSpeed) {
    final state = copy();
    state.track = track;
    state.parametricSpeed = parametricSpeed;
    return state;
  }

  SkaterState updateUUDVelocityPosition(
    double parametricPosition,
    double parametricSpeed,
    double velocityX,
    double velocityY,
    double positionX,
    double positionY,
  ) {
    final state = copy();
    state.parametricPosition = parametricPosition;
    state.parametricSpeed = parametricSpeed;
    state.velocityX = velocityX;
    state.velocityY = velocityY;
    state.positionX = positionX;
    state.positionY = positionY;
    return state;
  }

  SkaterState updatePositionAngleUpVelocity(
    double positionX,
    double positionY,
    double angle,
    bool isOnTopSideOfTrack,
    double velocityX,
    double velocityY,
  ) {
    final state = copy();
    state.angle = angle;
    state.isOnTopSideOfTrack = isOnTopSideOfTrack;
    state.velocityX = velocityX;
    state.velocityY = velocityY;
    state.positionX = positionX;
    state.positionY = positionY;
    return state;
  }

  SkaterState updateUPosition(
    double parametricPosition,
    double positionX,
    double positionY,
  ) {
    final state = copy();
    state.parametricPosition = parametricPosition;
    state.positionX = positionX;
    state.positionY = positionY;
    return state;
  }

  SkaterState updatePosition(double positionX, double positionY) {
    final state = copy();
    state.positionX = positionX;
    state.positionY = positionY;
    return state;
  }

  SkaterState updateUDVelocity(
    double parametricSpeed,
    double velocityX,
    double velocityY,
  ) {
    final state = copy();
    state.parametricSpeed = parametricSpeed;
    state.velocityX = velocityX;
    state.velocityY = velocityY;
    return state;
  }

  SkaterState continueFreeFall(
    double velocityX,
    double velocityY,
    double positionX,
    double positionY,
  ) {
    final state = copy();
    state.velocityX = velocityX;
    state.velocityY = velocityY;
    state.positionX = positionX;
    state.positionY = positionY;
    return state;
  }
}