/// Photon + motion states — mirrors Photon.ts / PhotonMotionState.ts
library;

import 'photon_scene_meters.dart';

class PhotonMotionState {
  PhotonMotionState({
    required this.position,
    required this.direction,
    required this.probability,
  });

  PhotonVec2 position;
  PhotonVec2 direction;
  double probability;

  PhotonVec2? travelPathIntersection(PhotonLineSegment line, double dt) {
    final end = position + direction.scaled(photonSpeedMetersPerSecond * dt);
    return lineSegmentIntersection(position, end, line.start, line.end);
  }

  void step(double dt) {
    position = position + direction.scaled(photonSpeedMetersPerSecond * dt);
  }
}

class PhotonParticle {
  PhotonParticle({
    required this.polarizationAngleDegrees,
    required PhotonVec2 initialPosition,
    required PhotonVec2 initialDirection,
  }) : possibleMotionStates = [
          PhotonMotionState(
            position: initialPosition,
            direction: initialDirection,
            probability: 1,
          ),
        ];

  final double polarizationAngleDegrees;
  final List<PhotonMotionState> possibleMotionStates;

  void addMotionState(
    PhotonVec2 position,
    PhotonVec2 direction,
    double probability,
  ) {
    assert(possibleMotionStates.length < 2);
    if (possibleMotionStates.length == 1) {
      possibleMotionStates[0].probability = 1 - probability;
    }
    possibleMotionStates.add(
      PhotonMotionState(
        position: position,
        direction: direction,
        probability: probability,
      ),
    );
  }

  void setMotionStateProbability(PhotonMotionState state, double probability) {
    final index = possibleMotionStates.indexOf(state);
    assert(index >= 0);
    possibleMotionStates[index].probability = probability;
    if (possibleMotionStates.length == 2) {
      possibleMotionStates[1 - index].probability = 1 - probability;
    }
  }

  void step(double dt) {
    for (final s in possibleMotionStates) {
      s.step(dt);
    }
  }
}

enum PhotonInteractionType { reflected, split, detectorReached, absorbed }

class PhotonInteraction {
  const PhotonInteraction.reflected({
    required this.reflectionPoint,
    required this.reflectionDirection,
  })  : type = PhotonInteractionType.reflected,
        splitPoint = null,
        splitUpProbability = null,
        detectorVertical = null;

  const PhotonInteraction.split({
    required this.splitPoint,
    required this.splitUpProbability,
  })  : type = PhotonInteractionType.split,
        reflectionPoint = null,
        reflectionDirection = null,
        detectorVertical = null;

  const PhotonInteraction.detectorReached({required this.detectorVertical})
      : type = PhotonInteractionType.detectorReached,
        reflectionPoint = null,
        reflectionDirection = null,
        splitPoint = null,
        splitUpProbability = null;

  const PhotonInteraction.absorbed()
      : type = PhotonInteractionType.absorbed,
        reflectionPoint = null,
        reflectionDirection = null,
        splitPoint = null,
        splitUpProbability = null,
        detectorVertical = null;

  final PhotonInteractionType type;
  final PhotonVec2? reflectionPoint;
  final PhotonVec2? reflectionDirection;
  final PhotonVec2? splitPoint;
  final double? splitUpProbability;
  final bool? detectorVertical;
}
