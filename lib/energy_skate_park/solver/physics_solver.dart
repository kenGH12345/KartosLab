import 'dart:math' as math;

import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/skater_state.dart';
import 'package:kratos/energy_skate_park/model/track.dart';

bool _equalsEpsilon(double a, double b, double eps) => (a - b).abs() <= eps;

EspVec? _lineSegmentIntersection(
  double ax,
  double ay,
  double bx,
  double by,
  double cx,
  double cy,
  double dx,
  double dy,
) {
  final abx = bx - ax;
  final aby = by - ay;
  final cdx = dx - cx;
  final cdy = dy - cy;
  final denom = abx * cdy - aby * cdx;
  if (denom == 0) return null;
  final t = ((cx - ax) * cdy - (cy - ay) * cdx) / denom;
  final u = ((cx - ax) * aby - (cy - ay) * abx) / denom;
  if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
    return EspVec(ax + t * abx, ay + t * aby);
  }
  return null;
}

double _distToSegment(EspVec p, EspVec a, EspVec b) {
  final abx = b.x - a.x;
  final aby = b.y - a.y;
  final len2 = abx * abx + aby * aby;
  if (len2 == 0) return p.distance(a);
  var t = ((p.x - a.x) * abx + (p.y - a.y) * aby) / len2;
  t = t.clamp(0.0, 1.0);
  return p.distance(EspVec(a.x + t * abx, a.y + t * aby));
}

/// Core dynamics from EnergySkateParkModel.ts (thrust kept at 0).
class PhysicsSolver {
  PhysicsSolver({
    required this.getFriction,
    required this.getIsStickingToTrack,
    required this.getPhysicalTracks,
    this.trackChangePending = false,
  });

  final double Function() getFriction;
  final bool Function() getIsStickingToTrack;
  final List<Track> Function() getPhysicalTracks;

  /// When true, correctEnergy is skipped (track drag in progress).
  bool trackChangePending;

  final Curvature _curvatureTemp = Curvature();
  final Curvature _curvatureTemp2 = Curvature();

  // Thrust kept at zero for Phase 4.
  static const double thrustMagnitude = 0;

  SkaterState stepModel(double dt, SkaterState skaterState) {
    if (skaterState.userControlled) {
      return skaterState;
    } else if (skaterState.track != null) {
      return stepTrack(dt, skaterState);
    } else if (skaterState.positionY <= 0) {
      return stepGround(dt, skaterState);
    } else if (skaterState.positionY > 0) {
      return stepFreeFall(dt, skaterState, false);
    }
    return skaterState;
  }

  SkaterState stepGround(double dt, SkaterState skaterState) {
    final x0 = skaterState.positionX;
    final frictionMagnitude =
        (getFriction() == 0 || skaterState.getSpeed() < 1e-2)
            ? 0.0
            : getFriction() * skaterState.mass * skaterState.gravity;
    final acceleration =
        frictionMagnitude.abs() * (skaterState.velocityX > 0 ? -1 : 1) /
            skaterState.mass;

    var v1 = skaterState.velocityX + acceleration * dt;
    if (getFriction() != 0 && skaterState.getSpeed() < 1e-2) {
      v1 = v1 / 2;
    }
    final x1 = x0 + v1 * dt;
    final newPosition = EspVec(x1, 0);
    final originalEnergy = skaterState.getTotalEnergy();

    final updated = skaterState.updatePositionAngleUpVelocity(
      newPosition.x,
      newPosition.y,
      0,
      true,
      v1,
      0,
    );

    final newEnergy = updated.getTotalEnergy();
    final newKineticEnergy = updated.getKineticEnergy();
    final energyDifference = originalEnergy - newEnergy;
    final absEnergyDifference = energyDifference.abs();

    if (energyDifference < 0 && newKineticEnergy > absEnergyDifference) {
      final currentSpeed = v1.abs();
      final speedInExcessEnergy =
          math.sqrt(2 * absEnergyDifference / updated.mass);
      final newSpeed = currentSpeed - speedInExcessEnergy;
      final correctedV = v1 >= 0 ? newSpeed : -newSpeed;
      return skaterState.updatePositionAngleUpVelocity(
        newPosition.x,
        newPosition.y,
        0,
        true,
        correctedV,
        0,
      );
    } else {
      final newThermalEnergy = updated.thermalEnergy + energyDifference;
      return updated.updateThermalEnergy(math.max(0, newThermalEnergy));
    }
  }

  SkaterState switchToGround(
    SkaterState skaterState,
    double initialEnergy,
    EspVec proposedPosition,
    EspVec proposedVelocity,
    double dt,
  ) {
    final segment = const EspVec(1, 0);
    var newSpeed = segment.dot(proposedVelocity);
    final newKineticEnergy = 0.5 * newSpeed * newSpeed * skaterState.mass;
    final newPotentialEnergy =
        (-1) * skaterState.mass * skaterState.gravity * (0 - skaterState.referenceHeight);
    var newThermalEnergy = initialEnergy - newKineticEnergy - newPotentialEnergy;

    if (newThermalEnergy < 0) {
      final correctedState =
          correctThermalEnergy(skaterState, segment, proposedPosition);
      newSpeed = correctedState.getSpeed();
      newThermalEnergy = correctedState.thermalEnergy;
    }

    if (newThermalEnergy < 0) newThermalEnergy = 0;
    return skaterState.switchToGround(
      newThermalEnergy,
      newSpeed,
      0,
      proposedPosition.x,
      proposedPosition.y,
    );
  }

  SkaterState correctThermalEnergy(
    SkaterState skaterState,
    EspVec segment,
    EspVec proposedPosition,
  ) {
    final initialEnergy = skaterState.getTotalEnergy();
    final newPotentialEnergy = (-1) *
        skaterState.mass *
        skaterState.gravity *
        (proposedPosition.y - skaterState.referenceHeight);
    final newThermalEnergy = skaterState.thermalEnergy;
    var newKineticEnergy = initialEnergy - newPotentialEnergy - newThermalEnergy;
    if (newKineticEnergy < 0) newKineticEnergy = 0;

    final newSpeed = math.sqrt(2 * newKineticEnergy / skaterState.mass);
    final newVelocity = segment * newSpeed;

    var correctedState = skaterState.updateThermalEnergy(newThermalEnergy);
    correctedState =
        correctedState.updatePosition(proposedPosition.x, proposedPosition.y);
    correctedState = correctedState.updateUDVelocity(
      correctedState.parametricSpeed,
      newVelocity.x,
      newVelocity.y,
    );
    return correctedState;
  }

  SkaterState stepFreeFall(
    double dt,
    SkaterState skaterState,
    bool justLeft,
  ) {
    final initialEnergy = skaterState.getTotalEnergy();
    final acceleration = EspVec(0, skaterState.gravity);
    final proposedVelocity =
        skaterState.getVelocity() + acceleration * dt;
    final position = skaterState.getPosition();
    var proposedPosition = position + proposedVelocity * dt;

    if (position.x != proposedPosition.x || position.y != proposedPosition.y) {
      final physicalTracks = getPhysicalTracks();
      if (physicalTracks.isNotEmpty && !justLeft) {
        final newSkaterState = interactWithTracksWhileFalling(
          physicalTracks,
          skaterState,
          proposedPosition,
          initialEnergy,
          dt,
          proposedVelocity,
        );
        if (proposedPosition.y < 0 && newSkaterState.track == null) {
          proposedPosition = EspVec(proposedPosition.x, 0);
          return switchToGround(
            skaterState,
            initialEnergy,
            proposedPosition,
            proposedVelocity,
            dt,
          );
        }
        return newSkaterState;
      } else {
        return continueFreeFall(
          skaterState,
          initialEnergy,
          proposedPosition,
          proposedVelocity,
          dt,
        );
      }
    }
    return skaterState;
  }

  ({Track track, double parametricPosition, EspVec point})?
      getClosestTrackAndPositionAndParameter(
    EspVec position,
    List<Track> physicalTracks,
  ) {
    Track? closestTrack;
    double? bestU;
    EspVec? bestPoint;
    var closestDistance = double.infinity;
    for (final track in physicalTracks) {
      final bestMatch = track.getClosestPositionAndParameter(position);
      if (bestMatch.distance < closestDistance) {
        closestDistance = bestMatch.distance;
        closestTrack = track;
        bestU = bestMatch.parametricPosition;
        bestPoint = bestMatch.point;
      }
    }
    if (closestTrack != null) {
      return (
        track: closestTrack,
        parametricPosition: bestU!,
        point: bestPoint!,
      );
    }
    return null;
  }

  bool crossedTrack(
    ({Track track, double parametricPosition, EspVec point}) closest,
    double beforeX,
    double beforeY,
    double afterX,
    double afterY,
  ) {
    final track = closest.track;
    final parametricPosition = closest.parametricPosition;
    final trackPoint = closest.point;
    if (!track.isParameterInBounds(parametricPosition)) return false;

    final unitParallelVector = track.getUnitParallelVector(parametricPosition);
    final a = trackPoint + unitParallelVector * 100;
    final b = trackPoint + unitParallelVector * -100;
    return _lineSegmentIntersection(
          a.x,
          a.y,
          b.x,
          b.y,
          beforeX,
          beforeY,
          afterX,
          afterY,
        ) !=
        null;
  }

  SkaterState interactWithTracksWhileFalling(
    List<Track> physicalTracks,
    SkaterState skaterState,
    EspVec proposedPosition,
    double initialEnergy,
    double dt,
    EspVec proposedVelocity,
  ) {
    final a = getClosestTrackAndPositionAndParameter(
      skaterState.getPosition(),
      physicalTracks,
    );
    final averagePosition = EspVec(
      (skaterState.positionX + proposedPosition.x) / 2,
      (skaterState.positionY + proposedPosition.y) / 2,
    );
    final b =
        getClosestTrackAndPositionAndParameter(averagePosition, physicalTracks);
    final c = getClosestTrackAndPositionAndParameter(
      EspVec(proposedPosition.x, proposedPosition.y),
      physicalTracks,
    );

    if (a == null || b == null || c == null) {
      return continueFreeFall(
        skaterState,
        initialEnergy,
        proposedPosition,
        proposedVelocity,
        dt,
      );
    }

    final initialPosition = skaterState.getPosition();
    final distanceA = _distToSegment(a.point, initialPosition, proposedPosition);
    final distanceB = _distToSegment(b.point, initialPosition, proposedPosition);
    final distanceC = _distToSegment(c.point, initialPosition, proposedPosition);

    final closest = distanceA <= distanceB && distanceA <= distanceC
        ? a
        : (distanceC <= distanceA && distanceC <= distanceB ? c : b);

    final crossed = crossedTrack(
      closest,
      skaterState.positionX,
      skaterState.positionY,
      proposedPosition.x,
      proposedPosition.y,
    );

    final track = closest.track;
    final parametricPosition = closest.parametricPosition;
    final trackPoint = closest.point;

    if (crossed) {
      final normal = track.getUnitNormalVector(parametricPosition);
      final segment = normal.perpendicular;
      final beforeVector = skaterState.getPosition() - trackPoint;

      var newVelocity = segment * segment.dot(proposedVelocity);
      var newSpeed = newVelocity.magnitude;
      final newKineticEnergy =
          0.5 * skaterState.mass * newVelocity.magnitudeSquared;
      final newPosition = track.getPoint(parametricPosition);
      final newPotentialEnergy = -skaterState.mass *
          skaterState.gravity *
          (newPosition.y - skaterState.referenceHeight);
      var newThermalEnergy =
          initialEnergy - newKineticEnergy - newPotentialEnergy;

      if (newThermalEnergy < skaterState.thermalEnergy) {
        final correctedState =
            correctThermalEnergy(skaterState, segment, newPosition);
        newThermalEnergy = correctedState.thermalEnergy;
        newSpeed = correctedState.getSpeed();
        newVelocity = correctedState.getVelocity();
      }

      final pvMag = proposedVelocity.magnitude;
      final dot = pvMag > 0
          ? proposedVelocity.normalize().dot(segment)
          : 0.0;

      var parametricSpeed = (dot > 0 ? 1.0 : -1.0) * newSpeed;
      final isOnTopSideOfTrack = beforeVector.dot(normal) > 0;

      final unitParallelVector =
          track.getUnitParallelVector(parametricPosition);
      final newVelocityX = unitParallelVector.x * parametricSpeed;
      final newVelocityY = unitParallelVector.y * parametricSpeed;
      final velocityDotted =
          skaterState.velocityX * newVelocityX +
              skaterState.velocityY * newVelocityY;
      if (velocityDotted < -1e-6) {
        parametricSpeed = parametricSpeed * -1;
      }

      if (newThermalEnergy < 0) newThermalEnergy = 0;

      return skaterState.attachToTrack(
        newThermalEnergy,
        track,
        isOnTopSideOfTrack,
        parametricPosition,
        parametricSpeed,
        newVelocity.x,
        newVelocity.y,
        newPosition.x,
        newPosition.y,
      );
    }

    return continueFreeFall(
      skaterState,
      initialEnergy,
      proposedPosition,
      proposedVelocity,
      dt,
    );
  }

  SkaterState continueFreeFall(
    SkaterState skaterState,
    double initialEnergy,
    EspVec proposedPosition,
    EspVec proposedVelocity,
    double dt,
  ) {
    final y = (initialEnergy -
                0.5 *
                    skaterState.mass *
                    proposedVelocity.magnitudeSquared -
                skaterState.thermalEnergy) /
            (-1 * skaterState.mass * skaterState.gravity) +
        skaterState.referenceHeight;
    if (y <= 0) {
      return skaterState.strikeGround(
        skaterState.getKineticEnergy(),
        proposedPosition.x,
      );
    }
    return skaterState.continueFreeFall(
      proposedVelocity.x,
      proposedVelocity.y,
      proposedPosition.x,
      y,
    );
  }

  double getNetForceWithoutNormalX(SkaterState skaterState) =>
      getFrictionForceX(skaterState);

  double getNetForceWithoutNormalY(SkaterState skaterState) =>
      skaterState.mass * skaterState.gravity + getFrictionForceY(skaterState);

  double getFrictionForceX(SkaterState skaterState) {
    if (getFriction() == 0 || skaterState.getSpeed() < 1e-2) return 0;
    final magnitude =
        getFriction() * getNormalForce(skaterState).magnitude;
    final angleComponent =
        math.cos(skaterState.getVelocity().angle + math.pi);
    return magnitude * angleComponent;
  }

  double getFrictionForceY(SkaterState skaterState) {
    if (getFriction() == 0 || skaterState.getSpeed() < 1e-2) return 0;
    final magnitude =
        getFriction() * getNormalForce(skaterState).magnitude;
    return magnitude * math.sin(skaterState.getVelocity().angle + math.pi);
  }

  EspVec getNormalForce(SkaterState skaterState) {
    skaterState.getCurvature(_curvatureTemp2);
    final radiusOfCurvature = math.min(_curvatureTemp2.r, 100000);
    var netForceRadial = EspVec(0, skaterState.mass * skaterState.gravity);
    var curvatureDirection = getCurvatureDirection(
      _curvatureTemp2,
      skaterState.positionX,
      skaterState.positionY,
    );
    if (curvatureDirection.x.isNaN || curvatureDirection.y.isNaN) {
      curvatureDirection = netForceRadial.normalize();
    }
    final normalForce = skaterState.mass *
            skaterState.getSpeed() *
            skaterState.getSpeed() /
            radiusOfCurvature.abs() -
        netForceRadial.dot(curvatureDirection);
    final angle = curvatureDirection.angle;
    return EspVec(normalForce * math.cos(angle), normalForce * math.sin(angle));
  }

  EspVec getCurvatureDirection(Curvature curvature, double x2, double y2) {
    final v = EspVec(curvature.x - x2, curvature.y - y2);
    return (v.x != 0 || v.y != 0) ? v.normalize() : v;
  }

  double getCurvatureDirectionX(Curvature curvature, double x2, double y2) {
    final vx = curvature.x - x2;
    final vy = curvature.y - y2;
    return (vx != 0 || vy != 0) ? vx / math.sqrt(vx * vx + vy * vy) : vx;
  }

  double getCurvatureDirectionY(Curvature curvature, double x2, double y2) {
    final vx = curvature.x - x2;
    final vy = curvature.y - y2;
    return (vx != 0 || vy != 0) ? vy / math.sqrt(vx * vx + vy * vy) : vy;
  }

  SkaterState stepEuler(double dt, SkaterState skaterState) {
    final track = skaterState.track!;
    final origEnergy = skaterState.getTotalEnergy();
    final origLocX = skaterState.positionX;
    final origLocY = skaterState.positionY;
    var thermalEnergy = skaterState.thermalEnergy;
    var parametricSpeed = skaterState.parametricSpeed;
    var parametricPosition = skaterState.parametricPosition;

    final netForceX = getNetForceWithoutNormalX(skaterState);
    final netForceY = getNetForceWithoutNormalY(skaterState);
    final netForceMagnitude =
        math.sqrt(netForceX * netForceX + netForceY * netForceY);
    final netForceAngle = math.atan2(netForceY, netForceX);

    final a = netForceMagnitude *
        math.cos(track.getModelAngleAt(parametricPosition) - netForceAngle) /
        skaterState.mass;

    parametricSpeed += a * dt;
    parametricPosition += track.getParametricDistance(
      parametricPosition,
      parametricSpeed * dt + 0.5 * a * dt * dt,
    );
    final newPointX = track.getX(parametricPosition);
    final newPointY = track.getY(parametricPosition);
    final unitParallelVector = track.getUnitParallelVector(parametricPosition);
    final parallelUnitX = unitParallelVector.x;
    final parallelUnitY = unitParallelVector.y;
    var newVelocityX = parallelUnitX * parametricSpeed;
    var newVelocityY = parallelUnitY * parametricSpeed;

    if (parallelUnitX / parallelUnitY > 5 &&
        math.sqrt(
              newVelocityX * newVelocityX + newVelocityY * newVelocityY,
            ) <
            1e-2) {
      newVelocityX /= 2;
      newVelocityY /= 2;
    }

    final newState = skaterState.updateUUDVelocityPosition(
      parametricPosition,
      parametricSpeed,
      newVelocityX,
      newVelocityY,
      newPointX,
      newPointY,
    );

    if (getFriction() > 0) {
      final frictionForceX = getFrictionForceX(skaterState);
      final frictionForceY = getFrictionForceY(skaterState);
      final frictionForceMagnitude = math.sqrt(
        frictionForceX * frictionForceX + frictionForceY * frictionForceY,
      );
      final newPoint = EspVec(newPointX, newPointY);
      final therm = frictionForceMagnitude * newPoint.distanceXY(origLocX, origLocY);
      thermalEnergy += therm;
      final newTotalEnergy = newState.getTotalEnergy() + therm;

      if (thrustMagnitude == 0 && !trackChangePending) {
        if (newTotalEnergy < origEnergy) {
          thermalEnergy += (newTotalEnergy - origEnergy).abs();
        }
        if (newTotalEnergy > origEnergy) {
          if ((newTotalEnergy - origEnergy).abs() < therm) {
            // gained energy, would remove more than gained — leave thermal
          } else {
            thermalEnergy -= (newTotalEnergy - origEnergy).abs();
          }
        }
      }
      return newState
          .updateThermalEnergy(math.max(thermalEnergy, skaterState.thermalEnergy));
    }
    return newState;
  }

  SkaterState stepTrack(double dt, SkaterState skaterState) {
    skaterState.getCurvature(_curvatureTemp);
    final curvatureDirectionX = getCurvatureDirectionX(
      _curvatureTemp,
      skaterState.positionX,
      skaterState.positionY,
    );
    final curvatureDirectionY = getCurvatureDirectionY(
      _curvatureTemp,
      skaterState.positionX,
      skaterState.positionY,
    );

    final track = skaterState.track!;
    final unitNormalVector =
        track.getUnitNormalVector(skaterState.parametricPosition);
    final sideVectorX = skaterState.isOnTopSideOfTrack
        ? unitNormalVector.x
        : unitNormalVector.x * -1;
    final sideVectorY = skaterState.isOnTopSideOfTrack
        ? unitNormalVector.y
        : unitNormalVector.y * -1;

    final outsideCircle =
        sideVectorX * curvatureDirectionX + sideVectorY * curvatureDirectionY <
            0;

    final r = _curvatureTemp.r.abs();
    final centripetalForce = skaterState.mass *
        skaterState.parametricSpeed *
        skaterState.parametricSpeed /
        r;

    final netForceWithoutNormalX = getNetForceWithoutNormalX(skaterState);
    final netForceWithoutNormalY = getNetForceWithoutNormalY(skaterState);
    final netForceRadial = netForceWithoutNormalX * curvatureDirectionX +
        netForceWithoutNormalY * curvatureDirectionY;

    final leaveTrack = (netForceRadial < centripetalForce && outsideCircle) ||
        (netForceRadial > centripetalForce && !outsideCircle);

    if (leaveTrack && !getIsStickingToTrack()) {
      final freeSkater = skaterState.leaveTrack();
      final nudged = nudge(freeSkater, sideVectorX, sideVectorY, 1);
      return stepFreeFall(dt, nudged, true);
    }

    var newState = skaterState;
    const numDivisions = 4;
    for (var i = 0; i < numDivisions; i++) {
      newState = stepEuler(dt / numDivisions, newState);
    }

    final correctedState = correctEnergy(skaterState, newState);

    if (track.isParameterInBounds(correctedState.parametricPosition)) {
      if (correctedState.positionY <= 0) {
        final groundPosition = EspVec(correctedState.positionX, 0);
        return switchToGround(
          correctedState,
          correctedState.getTotalEnergy(),
          groundPosition,
          correctedState.getVelocity(),
          dt,
        );
      }
      return correctedState;
    }

    if (correctedState.parametricPosition > track.maxPoint &&
        track.slopeToGround) {
      var result = correctedState.switchToGround(
        correctedState.thermalEnergy,
        correctedState.getSpeed(),
        0,
        correctedState.positionX,
        0,
      );
      final energyDifference =
          result.getPotentialEnergy() - correctedState.getPotentialEnergy();
      if (energyDifference < 0) {
        final newKineticEnergy = result.getKineticEnergy() + -energyDifference;
        final adjustedSpeed = result.getSpeedFromEnergy(newKineticEnergy);
        final correctedV =
            result.velocityX >= 0 ? adjustedSpeed : -adjustedSpeed;
        result = result.updatePositionAngleUpVelocity(
          result.positionX,
          result.positionY,
          0,
          true,
          correctedV,
          0,
        );
      }
      return correctEnergy(skaterState, result);
    }

    final freeSkaterState = skaterState.updateTrackUD(null, 0);
    final nudgedState = nudge(freeSkaterState, sideVectorX, sideVectorY, -1);
    final freeFallState = stepFreeFall(dt, nudgedState, true);
    if (freeFallState.positionY == 0) {
      return switchToGround(
        freeFallState,
        freeFallState.getTotalEnergy(),
        freeFallState.getPosition(),
        nudgedState.getVelocity(),
        dt,
      );
    }
    return freeFallState;
  }

  SkaterState nudge(
    SkaterState freeSkater,
    double sideVectorX,
    double sideVectorY,
    double sign,
  ) {
    var state = freeSkater;
    final velocity = EspVec(state.velocityX, state.velocityY);
    final upVector = EspVec(sideVectorX, sideVectorY);
    if (velocity.magnitude > 0) {
      final blended = velocity.normalize().blend(upVector, 0.01 * sign);
      if (blended.magnitude > 0) {
        final revisedVelocity =
            blended.normalize() * velocity.magnitude;
        state = state.updateUDVelocity(
          0,
          revisedVelocity.x,
          revisedVelocity.y,
        );
        final origPosition = state.getPosition();
        final newPosition = origPosition + upVector * (sign * 1e-6);
        state = state.updatePosition(newPosition.x, newPosition.y);
        return state;
      }
    }
    return state;
  }

  SkaterState correctEnergyReduceVelocity(
    SkaterState skaterState,
    SkaterState targetState,
  ) {
    final newSkaterState = targetState.copy();
    final e0 = skaterState.getTotalEnergy();
    final mass = skaterState.mass;

    final unit = newSkaterState.track != null
        ? newSkaterState.track!
            .getUnitParallelVector(newSkaterState.parametricPosition)
        : newSkaterState.getVelocity().normalize();

    for (var i = 0; i < 100; i++) {
      final dv =
          (newSkaterState.getTotalEnergy() - e0) /
              (mass * newSkaterState.parametricSpeed);
      final newVelocity = newSkaterState.parametricSpeed - dv;
      newSkaterState.parametricSpeed = newVelocity;
      final result = unit * newVelocity;
      newSkaterState.velocityX = result.x;
      newSkaterState.velocityY = result.y;
      if (_equalsEpsilon(e0, newSkaterState.getTotalEnergy(), 1e-8)) break;
    }
    return newSkaterState;
  }

  double searchSplineForEnergy(
    SkaterState skaterState,
    double u0,
    double u1,
    double e0,
    int numSteps,
  ) {
    final da = (u1 - u0) / numSteps;
    var bestAlpha = (u1 + u0) / 2;
    final p = skaterState.track!.getPoint(bestAlpha);
    var bestDE = skaterState.updatePosition(p.x, p.y).getTotalEnergy();
    for (var i = 0; i < numSteps; i++) {
      final proposedAlpha = u0 + da * i;
      // Port of PhET quirk: uses bestAlpha (not proposedAlpha) for point sample.
      final p2 = skaterState.track!.getPoint(bestAlpha);
      final e = skaterState.updatePosition(p2.x, p2.y).getTotalEnergy();
      if ((e - e0).abs() <= bestDE.abs()) {
        bestDE = e - e0;
        bestAlpha = proposedAlpha;
      }
    }
    return bestAlpha;
  }

  SkaterState correctEnergy(SkaterState skaterState, SkaterState newState) {
    if (trackChangePending) return newState;
    final u0 = skaterState.parametricPosition;
    final e0 = skaterState.getTotalEnergy();
    if (!newState.getTotalEnergy().isFinite) {
      throw StateError('not finite');
    }
    final dE = newState.getTotalEnergy() - e0;
    if (dE.abs() < 1e-6) return newState;

    if (newState.getTotalEnergy() > e0) {
      if (newState.getKineticEnergy().abs() > dE.abs()) {
        return correctEnergyReduceVelocity(skaterState, newState);
      } else {
        const numRecursiveSearches = 10;
        final parametricPosition = newState.parametricPosition;
        var bestAlpha = (parametricPosition + u0) / 2.0;
        var da = (parametricPosition - u0).abs() / 2;
        for (var i = 0; i < numRecursiveSearches; i++) {
          const numSteps = 10;
          bestAlpha = searchSplineForEnergy(
            newState,
            bestAlpha - da,
            bestAlpha + da,
            e0,
            numSteps,
          );
          da = (((bestAlpha - da) - (bestAlpha + da)).abs()) / numSteps;
        }

        final point = newState.track!.getPoint(bestAlpha);
        final correctedState =
            newState.updateUPosition(bestAlpha, point.x, point.y);

        if (!_equalsEpsilon(e0, correctedState.getTotalEnergy(), 1e-8)) {
          if (correctedState.getKineticEnergy().abs() > dE.abs()) {
            return correctEnergyReduceVelocity(skaterState, correctedState);
          } else {
            if (newState.thermalEnergy > skaterState.thermalEnergy) {
              final increasedThermalEnergy =
                  newState.thermalEnergy - skaterState.thermalEnergy;
              if (increasedThermalEnergy > dE) {
                return newState.updateThermalEnergy(newState.thermalEnergy - dE);
              } else {
                final originalThermalEnergyState =
                    newState.updateThermalEnergy(skaterState.thermalEnergy);
                return correctEnergyReduceVelocity(
                  skaterState,
                  originalThermalEnergyState,
                );
              }
            }
            return correctedState;
          }
        }
        return correctedState;
      }
    } else {
      if (newState.track == null || newState.parametricSpeed == 0) {
        return newState;
      }
      final vSq = (2 /
              newState.mass *
              (e0 - newState.getPotentialEnergy() - newState.thermalEnergy))
          .abs();
      final v = math.sqrt(vSq);
      final newVelocity = v * (newState.parametricSpeed > 0 ? 1 : -1);
      final unitParallelVector =
          newState.track!.getUnitParallelVector(newState.parametricPosition);
      return newState.updateUDVelocity(
        newVelocity,
        unitParallelVector.x * newVelocity,
        unitParallelVector.y * newVelocity,
      );
    }
  }
}