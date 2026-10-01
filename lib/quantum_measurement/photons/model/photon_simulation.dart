/// Spatial photon simulation engine — mirrors PhotonsExperimentSceneModel.stepForwardInTime.
library;

import 'dart:math' as math;

import '../../common/qm_random.dart';
import '../../common/system_type.dart';
import 'photon_particle.dart';
import 'photon_scene_meters.dart';
import 'photons_model.dart';

class PhotonsSpatialSimulation {
  PhotonsSpatialSimulation({
    required this.scene,
    required QmRandom random,
    PhotonsSceneMeters? meters,
  })  : _random = random,
        meters = meters ?? const PhotonsSceneMeters();

  final PhotonsExperimentSceneModel scene;
  final QmRandom _random;
  final PhotonsSceneMeters meters;

  final List<PhotonParticle> photons = [];
  double emissionRate = 0; // many-photons only; 0..200
  double _fractionalEmissionAccumulator = 0;

  int get verticalCount => scene.verticalDetectionCount;
  int get horizontalCount => scene.horizontalDetectionCount;

  void clearPhotons() {
    photons.clear();
    _fractionalEmissionAccumulator = 0;
  }

  void reset() {
    clearPhotons();
    emissionRate = 0;
    scene.reset();
  }

  double _currentPolarizationAngle() {
    return polarizationAngleDegrees(
      preset: scene.preset,
      customAngleDegrees: scene.customPolarizationAngle,
      randomForUnpolarized: _random,
    )!;
  }

  /// Single fire or one continuous emission unit — Laser.emitAPhoton.
  void emitAPhoton({double dt = 0}) {
    final yOffset =
        photonBeamWidthMeters / 2 * (1 - _random.nextDouble() * 2);
    final xOffset = dt * _random.nextDouble() * photonSpeedMetersPerSecond;
    final laser = meters.laser;
    photons.add(
      PhotonParticle(
        polarizationAngleDegrees: _currentPolarizationAngle(),
        initialPosition: PhotonVec2(laser.x + xOffset, laser.y + yOffset),
        initialDirection: PhotonVec2.right,
      ),
    );
  }

  void _laserStep(double dt) {
    if (scene.emissionMode != PhotonExperimentMode.manyPhotons) return;
    final photonsToEmit = emissionRate * dt;
    final whole = photonsToEmit.floor();
    for (var i = 0; i < whole; i++) {
      emitAPhoton(dt: dt);
    }
    _fractionalEmissionAccumulator += photonsToEmit - whole;
    while (_fractionalEmissionAccumulator >= 1) {
      emitAPhoton(dt: dt);
      _fractionalEmissionAccumulator -= 1;
    }
  }

  PhotonInteraction? _testPbs(PhotonMotionState state, PhotonParticle photon, double dt) {
    final hit = state.travelPathIntersection(meters.pbsSurface, dt);
    if (hit == null) return null;
    final radians = photon.polarizationAngleDegrees * math.pi / 180;
    final pReflect = 1 - math.pow(math.cos(radians), 2).toDouble();

    if (scene.photonBehaviorMode == SystemType.classical) {
      if (_random.nextDouble() <= pReflect) {
        return PhotonInteraction.reflected(
          reflectionPoint: hit,
          reflectionDirection: PhotonVec2.up,
        );
      }
      return null; // transmit: continue right
    }

    return PhotonInteraction.split(
      splitPoint: hit,
      splitUpProbability: pReflect,
    );
  }

  PhotonInteraction? _testMirror(PhotonMotionState state, double dt) {
    final hit = state.travelPathIntersection(meters.mirrorSurface, dt);
    if (hit == null) return null;
    return PhotonInteraction.reflected(
      reflectionPoint: hit,
      reflectionDirection: PhotonVec2.down,
    );
  }

  PhotonInteraction? _testDetector(
    PhotonMotionState state,
    double dt, {
    required PhotonVec2 position,
    required bool lookingUp,
    required bool vertical,
  }) {
    final detection = meters.detectorDetectionLine(position);
    final absorption = meters.detectorAbsorptionLine(
      position,
      lookingUp: lookingUp,
    );
    if (state.travelPathIntersection(absorption, dt) != null) {
      return const PhotonInteraction.absorbed();
    }
    if (state.travelPathIntersection(detection, dt) != null) {
      return PhotonInteraction.detectorReached(detectorVertical: vertical);
    }
    return null;
  }

  Map<PhotonMotionState, PhotonInteraction> _interactionsFor(
    PhotonParticle photon,
    double dt,
  ) {
    final map = <PhotonMotionState, PhotonInteraction>{};
    for (final state in photon.possibleMotionStates) {
      PhotonInteraction? found = _testPbs(state, photon, dt);
      found ??= _testMirror(state, dt);
      found ??= _testDetector(
        state,
        dt,
        position: meters.verticalDetector,
        lookingUp: true,
        vertical: true,
      );
      found ??= _testDetector(
        state,
        dt,
        position: meters.horizontalDetector,
        lookingUp: false,
        vertical: false,
      );
      if (found != null) map[state] = found;
    }
    return map;
  }

  /// Mirrors PhotonsExperimentSceneModel.stepForwardInTime.
  void stepForwardInTime(double dt) {
    _laserStep(dt);
    final toRemove = <PhotonParticle>[];

    for (final photon in List<PhotonParticle>.from(photons)) {
      final interactions = _interactionsFor(photon, dt);

      for (final state in List<PhotonMotionState>.from(photon.possibleMotionStates)) {
        if (toRemove.contains(photon)) break;
        final interaction = interactions[state];
        if (interaction == null) {
          state.step(dt);
          continue;
        }

        switch (interaction.type) {
          case PhotonInteractionType.reflected:
            final point = interaction.reflectionPoint!;
            final dist = PhotonVec2(
              point.x - state.position.x,
              point.y - state.position.y,
            ).length;
            final dtTo = (dist / photonSpeedMetersPerSecond).clamp(0.0, dt);
            state.step(dtTo);
            state.direction = interaction.reflectionDirection!;
            state.step(dt - dtTo);
            break;
          case PhotonInteractionType.split:
            final point = interaction.splitPoint!;
            final dist = PhotonVec2(
              point.x - state.position.x,
              point.y - state.position.y,
            ).length;
            final dtTo = (dist / photonSpeedMetersPerSecond).clamp(0.0, dt);
            state.step(dtTo);
            final pUp = interaction.splitUpProbability!;
            state.direction = PhotonVec2.up;
            state.probability = pUp;
            photon.addMotionState(
              state.position,
              PhotonVec2.right,
              1 - pUp,
            );
            for (final s in photon.possibleMotionStates) {
              s.step(dt - dtTo);
            }
            break;
          case PhotonInteractionType.detectorReached:
            final isVertical = interaction.detectorVertical!;
            if (_random.nextDouble() < state.probability) {
              photon.setMotionStateProbability(state, 1);
              if (isVertical) {
                scene.verticalDetectionCount =
                    math.min(scene.verticalDetectionCount + 1, 999);
              } else {
                scene.horizontalDetectionCount =
                    math.min(scene.horizontalDetectionCount + 1, 999);
              }
            } else {
              photon.setMotionStateProbability(state, 0);
            }
            state.step(dt);
            break;
          case PhotonInteractionType.absorbed:
            toRemove.add(photon);
            break;
        }
      }
    }

    for (final p in toRemove) {
      photons.remove(p);
    }
  }

  void step(double dt) {
    if (!scene.isPlaying) return;
    final scale = scene.slowMotion ? slowMotionTimeScale : 1.0;
    stepForwardInTime(dt * scale);
  }
}
