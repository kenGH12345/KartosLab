import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../som_constants.dart';
import 'atom_pair.dart';
import 'atom_type.dart';
import 'force_display_mode.dart';
import 'interaction_strength_table.dart';
import 'lj_potential_calculator.dart';
import 'motion_atom.dart';
import 'sigma_table.dart';

/// Time-speed multipliers — PhET DualAtomModel.
enum InteractionTimeSpeed {
  normal,
  slow,
}

/// Two-atom LJ model along x — PhET `DualAtomModel`.
class DualAtomModel extends ChangeNotifier {
  DualAtomModel({
    bool enableHeterogeneousMolecules = false,
  })  : validAtomPairs = enableHeterogeneousMolecules
            ? AtomPair.values
            : AtomPair.reducedPairs {
    fixedAtom = MotionAtom(initialAtomType: AtomType.neon);
    movableAtom = MotionAtom(initialAtomType: AtomType.neon);
    ljPotentialCalculator = LjPotentialCalculator(
      SomConstants.minSigma,
      SomConstants.minEpsilon,
    );
    _applyAtomPair(atomPair);
  }

  static const double normalMotionTimeMultiplier = 2;
  static const double slowMotionTimeMultiplier = 0.5;
  static const double maxTimeStep = 0.005;
  static const double minForceJitterThreshold = 1e-30;
  static const double amuToKg = 1.6605402e-27;

  final List<AtomPair> validAtomPairs;

  late final MotionAtom fixedAtom;
  late final MotionAtom movableAtom;
  late final LjPotentialCalculator ljPotentialCalculator;

  double adjustableAtomInteractionStrength = 100;
  double adjustableAtomDiameter =
      SomConstants.adjustableAttractionDefaultRadius * 2;

  bool motionPaused = false;
  bool isPlaying = true;
  InteractionTimeSpeed timeSpeed = InteractionTimeSpeed.normal;
  AtomPair atomPair = AtomPair.neonNeon;
  ForceDisplayMode forcesDisplayMode = ForceDisplayMode.hidden;
  bool forcesExpanded = false;
  bool movementHintVisible = true;

  double attractiveForce = 0;
  double repulsiveForce = 0;

  double residualTime = 0;

  void setAtomPair(AtomPair pair) {
    if (!validAtomPairs.contains(pair)) {
      throw ArgumentError('Atom pair $pair is not valid for this model');
    }
    if (atomPair == pair) return;
    atomPair = pair;
    _applyAtomPair(pair);
    notifyListeners();
  }

  void _applyAtomPair(AtomPair pair) {
    fixedAtom.setAtomType(pair.fixedAtomType);
    movableAtom.setAtomType(pair.movableAtomType);
    ljPotentialCalculator.setSigma(
      SigmaTable.getSigma(fixedAtom.getType(), movableAtom.getType()),
    );
    ljPotentialCalculator.setEpsilon(
      InteractionStrengthTable.getInteractionPotential(
        fixedAtom.getType(),
        movableAtom.getType(),
      ),
    );
    if (pair == AtomPair.adjustable) {
      setEpsilon(adjustableAtomInteractionStrength);
      setAdjustableAtomSigma(adjustableAtomDiameter);
    }
    resetMovableAtomPos();
    updateForces();
  }

  void setAdjustableAtomSigma(double sigma) {
    if (fixedAtom.getType() != AtomType.adjustable ||
        movableAtom.getType() != AtomType.adjustable) {
      return;
    }
    var s = sigma;
    if (s > SomConstants.maxSigma) {
      s = SomConstants.maxSigma;
    } else if (s < SomConstants.minSigma) {
      s = SomConstants.minSigma;
    }
    if (s == ljPotentialCalculator.getSigma()) return;
    adjustableAtomDiameter = s;
    ljPotentialCalculator.setSigma(s);
    fixedAtom.radius = s / 2;
    movableAtom.radius = s / 2;
    movableAtom.setPosition(ljPotentialCalculator.getMinimumForceDistance(), 0);
    notifyListeners();
  }

  double getSigma() => ljPotentialCalculator.getSigma();

  void setEpsilon(double epsilon) {
    var e = epsilon;
    if (e < SomConstants.minEpsilon) {
      e = SomConstants.minEpsilon;
    } else if (e > SomConstants.maxEpsilon) {
      e = SomConstants.maxEpsilon;
    }
    if (fixedAtom.getType() == AtomType.adjustable &&
        movableAtom.getType() == AtomType.adjustable) {
      adjustableAtomInteractionStrength = e;
      ljPotentialCalculator.setEpsilon(e);
      notifyListeners();
    }
  }

  double getEpsilon() => ljPotentialCalculator.getEpsilon();

  void setMotionPaused(bool paused) {
    motionPaused = paused;
    movableAtom.setVx(0);
    notifyListeners();
  }

  void setPlaying(bool playing) {
    isPlaying = playing;
    notifyListeners();
  }

  void setTimeSpeed(InteractionTimeSpeed speed) {
    timeSpeed = speed;
    notifyListeners();
  }

  void setForcesDisplayMode(ForceDisplayMode mode) {
    forcesDisplayMode = mode;
    notifyListeners();
  }

  void setForcesExpanded(bool expanded) {
    forcesExpanded = expanded;
    notifyListeners();
  }

  void toggleForcesExpanded() {
    forcesExpanded = !forcesExpanded;
    notifyListeners();
  }

  /// Approximate PhET off-canvas check using layout bounds (not window scale).
  bool get isMovableAtomOffCanvas {
    // SomInteractionTransform.originX=145, scale=0.25; layoutW=834
    final viewX = 145.0 + movableAtom.getX() * 0.25;
    return viewX > 834 - 40;
  }

  void reset() {
    adjustableAtomInteractionStrength = 100;
    motionPaused = false;
    atomPair = AtomPair.neonNeon;
    isPlaying = true;
    timeSpeed = InteractionTimeSpeed.normal;
    adjustableAtomDiameter =
        SomConstants.adjustableAttractionDefaultRadius * 2;
    forcesDisplayMode = ForceDisplayMode.hidden;
    forcesExpanded = false;
    movementHintVisible = true;
    residualTime = 0;
    fixedAtom.reset();
    movableAtom.reset();
    _applyAtomPair(atomPair);
    notifyListeners();
  }

  void resetMovableAtomPos() {
    movableAtom.setPosition(ljPotentialCalculator.getMinimumForceDistance(), 0);
    movableAtom.setVx(0);
    movableAtom.setAx(0);
  }

  void step(double dt) {
    if (!isPlaying) return;
    final multiplier = timeSpeed == InteractionTimeSpeed.slow
        ? slowMotionTimeMultiplier
        : normalMotionTimeMultiplier;
    stepInternal(dt * multiplier);
  }

  void stepInternal(double dt) {
    var numInternalModelIterations = 1;
    var modelTimeStep = dt;

    if (dt > maxTimeStep) {
      numInternalModelIterations = (dt / maxTimeStep).floor();
      residualTime += dt - (numInternalModelIterations * maxTimeStep);
      modelTimeStep = maxTimeStep;
    }

    if (residualTime > modelTimeStep) {
      numInternalModelIterations++;
      residualTime -= modelTimeStep;
    }

    for (var i = 0; i < numInternalModelIterations; i++) {
      updateAtomMotion(modelTimeStep);
    }
    notifyListeners();
  }

  void updateForces() {
    var distance = math.sqrt(
      movableAtom.position.x * movableAtom.position.x +
          movableAtom.position.y * movableAtom.position.y,
    );

    final minDistance = (fixedAtom.radius + movableAtom.radius) / 8;
    if (distance < minDistance) {
      distance = minDistance;
    }

    attractiveForce = ljPotentialCalculator.getAttractiveLjForce(distance);
    repulsiveForce = ljPotentialCalculator.getRepulsiveLjForce(distance);

    if (movableAtom.getVx().abs() == 0) {
      if ((distance - ljPotentialCalculator.getMinimumForceDistance()).abs() <
          movableAtom.radius) {
        final totalForceMagnitude = (attractiveForce - repulsiveForce).abs();
        if (totalForceMagnitude > 0 &&
            totalForceMagnitude < minForceJitterThreshold) {
          final averageForce = (attractiveForce + repulsiveForce) / 2;
          attractiveForce = averageForce;
          repulsiveForce = averageForce;
        }
      }
    }
  }

  void updateAtomMotion(double dt) {
    updateForces();
    final massKg = movableAtom.mass * amuToKg;
    final acceleration = (repulsiveForce - attractiveForce) / massKg;
    movableAtom.setAx(acceleration);

    if (!motionPaused) {
      final newVelocity = movableAtom.getVx() + (acceleration * dt);
      movableAtom.setVx(newVelocity);
      final xPos = movableAtom.getX() + (movableAtom.getVx() * dt);
      movableAtom.setPosition(xPos, 0);
    }
  }

  /// Drag movable atom to [x] (pm); pauses motion while dragging.
  void dragMovableAtomTo(double x) {
    setMotionPaused(true);
    final minX = (fixedAtom.radius + movableAtom.radius) / 8;
    movableAtom.setPosition(math.max(x, minX), 0);
    updateForces();
    notifyListeners();
  }

  void endDrag() {
    setMotionPaused(false);
    // PhET HandNode drag end hides the movement hint.
    movementHintVisible = false;
  }

  @override
  void dispose() {
    fixedAtom.dispose();
    movableAtom.dispose();
    super.dispose();
  }
}
