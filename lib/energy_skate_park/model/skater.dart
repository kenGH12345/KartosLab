import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/skater_state.dart';
import 'package:kratos/energy_skate_park/model/track.dart';

/// Mutable skater model (Skater.ts Properties subset).
class Skater extends ChangeNotifier {
  Skater({
    this.mass = EspConstants.defaultSkaterMass,
    this.gravityMagnitude = EspConstants.earthGravity,
  });

  Track? track;
  double parametricPosition = 0;
  double parametricSpeed = 0;
  bool isOnTopSideOfTrack = true;
  double gravityMagnitude;
  double get gravity => -gravityMagnitude;
  double referenceHeight = 0;
  double positionX = 3.5;
  double positionY = 0;
  double mass;
  String direction = 'left';
  double velocityX = 0;
  double velocityY = 0;
  bool userControlled = false;
  double kineticEnergy = 0;
  double potentialEnergy = 0;
  double thermalEnergy = 0;
  double totalEnergy = 0;
  double angle = 0;
  double startingPositionX = 3.5;
  double startingPositionY = 0;
  double startingU = 0;
  bool startingUp = true;
  Track? startingTrack;
  double startingAngle = 0;

  EspVec get position => EspVec(positionX, positionY);
  EspVec get velocity => EspVec(velocityX, velocityY);

  void updateEnergy() {
    kineticEnergy = 0.5 * mass * (velocityX * velocityX + velocityY * velocityY);
    potentialEnergy = -mass * (positionY - referenceHeight) * gravity;
    totalEnergy = kineticEnergy + potentialEnergy + thermalEnergy;
  }

  void setFromSkaterState(SkaterState state) {
    track = state.track;
    positionX = state.positionX;
    positionY = state.positionY;
    velocityX = state.velocityX;
    velocityY = state.velocityY;
    parametricPosition = state.parametricPosition;
    parametricSpeed = state.parametricSpeed;
    thermalEnergy = state.thermalEnergy;
    isOnTopSideOfTrack = state.isOnTopSideOfTrack;
    mass = state.mass;
    gravityMagnitude = state.gravity.abs();
    referenceHeight = state.referenceHeight;
    if (track != null && !state.userControlled) {
      angle = track!.getViewAngleAt(state.parametricPosition) +
          (state.isOnTopSideOfTrack ? 0 : math.pi);
    } else {
      angle = state.angle;
    }
    updateEnergy();
    notifyListeners();
  }

  SkaterState toSkaterState() => SkaterState(
        gravity: gravity,
        referenceHeight: referenceHeight,
        mass: mass,
        track: track,
        angle: angle,
        isOnTopSideOfTrack: isOnTopSideOfTrack,
        parametricPosition: parametricPosition,
        parametricSpeed: parametricSpeed,
        userControlled: userControlled,
        thermalEnergy: thermalEnergy,
        positionX: positionX,
        positionY: positionY,
        velocityX: velocityX,
        velocityY: velocityY,
      );

  void clearThermal() {
    thermalEnergy = 0;
    updateEnergy();
    notifyListeners();
  }

  void reset() {
    track = null;
    parametricPosition = 0;
    parametricSpeed = 0;
    isOnTopSideOfTrack = true;
    positionX = 3.5;
    positionY = 0;
    direction = 'left';
    velocityX = 0;
    velocityY = 0;
    userControlled = false;
    thermalEnergy = 0;
    angle = 0;
    startingPositionX = 3.5;
    startingPositionY = 0;
    startingU = 0;
    startingUp = true;
    startingTrack = null;
    startingAngle = 0;
    mass = EspConstants.defaultSkaterMass;
    gravityMagnitude = EspConstants.earthGravity;
    referenceHeight = 0;
    updateEnergy();
    notifyListeners();
  }

  void returnToStartingPosition() {
    if (startingTrack != null && track == startingTrack) {
      parametricPosition = startingU;
      angle = startingAngle;
      isOnTopSideOfTrack = startingUp;
      parametricSpeed = 0;
    } else {
      track = null;
      angle = startingAngle;
    }
    positionX = startingPositionX;
    positionY = startingPositionY;
    velocityX = 0;
    velocityY = 0;
    clearThermal();
  }
}