import 'dart:math' as math;

import '../membrane_transport_constants.dart';
import 'membrane_transport_model.dart';
import 'mt_random.dart';
import 'mt_vec2.dart';
import 'particle.dart';
import 'proteins/ligand_gated_channel.dart';
import 'proteins/sodium_glucose_cotransporter.dart';
import 'proteins/sodium_potassium_pump.dart';
import 'proteins/transport_protein.dart';
import 'slot.dart';
import 'solute_type.dart';
import 'transport_protein_type.dart';

enum CrossingDirection { inward, outward }

enum MembraneSide { inside, outside }

/// Particle behavior FSM — PhET particleModes (Phase 2).
abstract class ParticleMode {
  void step(double dt, MtParticle particle, MembraneTransportModel model);

  Slot? get slot => null;
}

class RandomWalkMode extends ParticleMode {
  RandomWalkMode({
    required this.currentDirection,
    required this.timeUntilNextDirection,
    required this.timeElapsedSinceMembraneCrossing,
  });

  MtVec2 currentDirection;
  double timeUntilNextDirection;
  double timeElapsedSinceMembraneCrossing;

  static RandomWalkMode create(
    MtRandom random, {
    bool allowImmediateInteraction = true,
  }) {
    return RandomWalkMode(
      currentDirection: randomUnit(random),
      timeUntilNextDirection: sampleStraight(random),
      timeElapsedSinceMembraneCrossing: allowImmediateInteraction
          ? MembraneTransportConstants.crossingCooldown
          : 0,
    );
  }

  static MtVec2 randomUnit(MtRandom random) {
    final angle = random.nextDouble() * 2 * math.pi;
    return MtVec2(math.cos(angle), math.sin(angle));
  }

  static double sampleStraight(MtRandom random) {
    return MembraneTransportConstants.clamp(
      random.boxMuller(0.1, 0.2),
      0.01,
      1,
    );
  }

  @override
  void step(double dt, MtParticle particle, MembraneTransportModel model) {
    timeUntilNextDirection -= dt;
    timeElapsedSinceMembraneCrossing += dt;

    if (timeUntilNextDirection <= 0) {
      currentDirection = randomUnit(model.random);
      timeUntilNextDirection = sampleStraight(model.random);
    }

    final isOutside = particle.position.y > 0;
    particle.position.x +=
        currentDirection.x * dt * MembraneTransportConstants.typicalSpeed;
    particle.position.y +=
        currentDirection.y * dt * MembraneTransportConstants.typicalSpeed;

    if (_attemptProteinInteraction(particle, model, isOutside)) return;
    if (_attemptMembraneInteraction(particle, model, isOutside)) return;

    final bounds = isOutside
        ? MtBounds(
            MembraneTransportConstants.membraneMinX,
            MembraneTransportConstants.outsideMinY,
            MembraneTransportConstants.membraneMaxX,
            MembraneTransportConstants.outsideMaxY,
          )
        : MtBounds(
            MembraneTransportConstants.membraneMinX,
            MembraneTransportConstants.insideMinY,
            MembraneTransportConstants.membraneMaxX,
            MembraneTransportConstants.insideMaxY,
          );

    _handleHorizontalWrap(particle, bounds);
    _handleVerticalBounce(particle, bounds, model);
  }

  bool _attemptProteinInteraction(
    MtParticle particle,
    MembraneTransportModel model,
    bool outsideOfCell,
  ) {
    for (final slot in model.membraneSlots) {
      final protein = slot.transportProtein;
      if (protein == null) continue;

      var capture = MembraneTransportConstants.captureRadius;
      if (particle.type == ParticleType.atp) capture *= 2;

      if (particle.position.distanceTo(MtVec2(slot.position, 0)) < capture &&
          timeElapsedSinceMembraneCrossing >
              MembraneTransportConstants.crossingCooldown) {
        if (_handleProtein(particle, slot, protein, model, outsideOfCell)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _handleProtein(
    MtParticle particle,
    Slot slot,
    TransportProtein protein,
    MembraneTransportModel model,
    bool outsideOfCell,
  ) {
    if (_handlePassiveGate(particle, slot, protein, outsideOfCell, model)) {
      return true;
    }

    if (particle.isLigand && outsideOfCell && protein is LigandGatedChannel) {
      final expected = particle.type == ParticleType.triangleLigand
          ? TransportProteinType.sodiumIonLigandGatedChannel
          : TransportProteinType.potassiumIonLigandGatedChannel;
      if (slot.transportProteinType == expected &&
          protein.isAvailableForBinding()) {
        protein.bindLigand(particle, model.isPlaying);
        return true;
      }
    }

    if (protein is SodiumGlucoseCotransporter) {
      return _handleCotransporter(particle, slot, protein, model);
    }
    if (protein is SodiumPotassiumPump) {
      return _handlePump(particle, slot, protein as SodiumPotassiumPump, model);
    }
    return false;
  }

  bool _handlePassiveGate(
    MtParticle particle,
    Slot slot,
    TransportProtein protein,
    bool outsideOfCell,
    MembraneTransportModel model,
  ) {
    final solute = particle.type.asSolute;
    if (solute == null) return false;
    if (!MembraneTransportModel.canMoveThroughPassiveTransport(particle.type)) {
      return false;
    }
    final location =
        outsideOfCell ? MembraneSide.outside : MembraneSide.inside;
    if (!protein.isAvailableForPassiveTransport(solute, location)) {
      return false;
    }
    final type = slot.transportProteinType!;
    final ok = (particle.type == ParticleType.sodiumIon &&
            isSodiumPassiveGate(type)) ||
        (particle.type == ParticleType.potassiumIon &&
            isPotassiumPassiveGate(type));
    if (!ok) return false;

    final mouthY = outsideOfCell
        ? MembraneTransportConstants.membraneMaxY
        : MembraneTransportConstants.membraneMinY;
    particle.mode = MovingThroughProteinMode(
      slot: slot,
      direction: outsideOfCell
          ? CrossingDirection.inward
          : CrossingDirection.outward,
      targetXOffset: 0,
    );
    // Nudge toward mouth first for visual continuity
    particle.position.x = slot.position;
    particle.position.y = mouthY;
    return true;
  }

  bool _handleCotransporter(
    MtParticle particle,
    Slot slot,
    SodiumGlucoseCotransporter protein,
    MembraneTransportModel model,
  ) {
    if (protein.coState != SodiumGlucoseState.openToOutsideAwaitingParticles) {
      return false;
    }
    if (particle.position.y <= 0) return false;
    if (model.countSolutes(SoluteType.sodiumIon, MembraneSide.outside) <=
        model.countSolutes(SoluteType.sodiumIon, MembraneSide.inside)) {
      return false;
    }

    if (particle.type == ParticleType.sodiumIon) {
      final sites = protein.availableSodiumSites(model);
      if (sites.isEmpty) return false;
      particle.mode = WaitingInCotransporterMode(
        slot: slot,
        site: model.random.sample(sites),
      );
      return true;
    }
    if (particle.type == ParticleType.glucose &&
        protein.isGlucoseSiteOpen(model)) {
      particle.mode =
          WaitingInCotransporterMode(slot: slot, site: 'center');
      return true;
    }
    return false;
  }

  bool _handlePump(
    MtParticle particle,
    Slot slot,
    SodiumPotassiumPump protein,
    MembraneTransportModel model,
  ) {
    if (particle.type == ParticleType.sodiumIon &&
        protein.pumpState == SodiumPotassiumState.openToInsideEmpty &&
        particle.position.y < 0) {
      final sites = protein.openSodiumSites(model);
      if (sites.isEmpty) return false;
      particle.mode =
          WaitingInPumpMode(slot: slot, site: model.random.sample(sites));
      return true;
    }
    if (particle.type == ParticleType.atp &&
        protein.pumpState == SodiumPotassiumState.openToInsideSodiumBound &&
        particle.position.y < 0) {
      particle.mode = WaitingInPumpMode(slot: slot, site: 'atp');
      protein.pumpState = SodiumPotassiumState.openToInsideSodiumAndATPBound;
      return true;
    }
    if (particle.type == ParticleType.potassiumIon &&
        protein.pumpState ==
            SodiumPotassiumState.openToOutsideAwaitingPotassium &&
        particle.position.y > 0) {
      final sites = protein.openPotassiumSites(model);
      if (sites.isEmpty) return false;
      particle.mode =
          WaitingInPumpMode(slot: slot, site: model.random.sample(sites));
      return true;
    }
    return false;
  }

  bool _attemptMembraneInteraction(
    MtParticle particle,
    MembraneTransportModel model,
    bool outsideOfCell,
  ) {
    const membrane = MtBounds(
      MembraneTransportConstants.membraneMinX,
      MembraneTransportConstants.membraneMinY,
      MembraneTransportConstants.membraneMaxX,
      MembraneTransportConstants.membraneMaxY,
    );
    if (!membrane.intersects(particle.bounds)) return false;

    if (particle.type.isGas) {
      final location =
          outsideOfCell ? MembraneSide.outside : MembraneSide.inside;
      final solute = particle.type.asSolute!;
      final shouldCross = model.shouldApplyBiasForGasses(solute)
          ? model.checkGradientForCrossing(solute, location)
          : model.random.nextDouble() <
              MembraneTransportConstants.gasNearEquilibriumCrossProbability;
      if (shouldCross) {
        particle.mode = PassiveDiffusionMode(
          direction: outsideOfCell
              ? CrossingDirection.inward
              : CrossingDirection.outward,
        );
        return true;
      }
    }

    if (outsideOfCell) {
      final overlap =
          MembraneTransportConstants.membraneMaxY - particle.bounds.minY;
      particle.position.y += overlap + 1e-6;
      currentDirection.y = currentDirection.y.abs();
    } else {
      final overlap =
          particle.bounds.maxY - MembraneTransportConstants.membraneMinY;
      particle.position.y -= overlap + 1e-6;
      currentDirection.y = -currentDirection.y.abs();
    }
    return true;
  }

  void _handleHorizontalWrap(MtParticle particle, MtBounds region) {
    final b = particle.bounds;
    final w = particle.dimension.width;
    const eps = 1e-6;
    if (b.maxX < region.minX) {
      particle.position.x = region.maxX + w / 2 - eps;
    } else if (b.minX > region.maxX) {
      particle.position.x = region.minX - w / 2 + eps;
    }
  }

  void _handleVerticalBounce(
    MtParticle particle,
    MtBounds region,
    MembraneTransportModel model,
  ) {
    final b = particle.bounds;
    final dilated = region.dilated(particle.dimension.height - 1e-6);
    var bounce = false;
    if (b.minY < dilated.minY) {
      bounce = true;
      particle.position.y += dilated.minY - b.minY;
      currentDirection.y = currentDirection.y.abs();
    } else if (b.maxY > dilated.maxY) {
      bounce = true;
      particle.position.y -= b.maxY - dilated.maxY;
      currentDirection.y = -currentDirection.y.abs();
    }
    if (bounce) {
      particle.position.x =
          model.random.nextDoubleBetween(region.minX, region.maxX);
    }
  }
}

class PassiveDiffusionMode extends ParticleMode {
  PassiveDiffusionMode({required this.direction});

  final CrossingDirection direction;

  @override
  void step(double dt, MtParticle particle, MembraneTransportModel model) {
    final sign = direction == CrossingDirection.inward ? -1.0 : 1.0;
    final beforeOutside = particle.position.y > 0;

    particle.position.y += sign *
        (MembraneTransportConstants.typicalSpeed * 2 / 3) *
        dt *
        model.random.nextDoubleBetween(0.1, 2);
    particle.position.x += model.random.nextDoubleBetween(-2, 2) *
        (MembraneTransportConstants.typicalSpeed * 5 / 3) *
        dt;

    final afterOutside = particle.position.y > 0;
    if (beforeOutside != afterOutside) {
      model.recordCrossing(
        particle,
        afterOutside ? CrossingDirection.outward : CrossingDirection.inward,
        slot: null,
      );
    }

    final halfH = particle.dimension.height / 2;
    if (direction == CrossingDirection.inward &&
        particle.position.y + halfH < MembraneTransportConstants.membraneMinY) {
      final dir = MtVec2(
        model.random.nextDoubleBetween(-1, 1),
        model.random.nextDoubleBetween(-1, 0),
      ).normalized();
      particle.moveInDirection(dir, RandomWalkMode.sampleStraight(model.random));
    }
    if (direction == CrossingDirection.outward &&
        particle.position.y - halfH > MembraneTransportConstants.membraneMaxY) {
      final dir = MtVec2(
        model.random.nextDoubleBetween(-1, 1),
        model.random.nextDoubleBetween(0, 1),
      ).normalized();
      particle.moveInDirection(dir, RandomWalkMode.sampleStraight(model.random));
    }
  }
}

class MovingThroughProteinMode extends ParticleMode {
  MovingThroughProteinMode({
    required this.slot,
    required this.direction,
    this.targetXOffset = 0,
  });

  @override
  final Slot slot;
  final CrossingDirection direction;
  final double targetXOffset;

  @override
  void step(double dt, MtParticle particle, MembraneTransportModel model) {
    final sign = direction == CrossingDirection.inward ? -1.0 : 1.0;
    final beforeOutside = particle.position.y > 0;

    particle.position.y += sign *
        (MembraneTransportConstants.typicalSpeed * 2 / 3) *
        dt *
        model.random.nextDoubleBetween(0.1, 2);
    particle.position.x += model.random.nextDoubleBetween(-2, 2) *
            (MembraneTransportConstants.typicalSpeed * 5 / 3) *
            dt +
        targetXOffset * dt * 0.1;

    final afterOutside = particle.position.y > 0;
    if (beforeOutside != afterOutside) {
      model.recordCrossing(
        particle,
        afterOutside ? CrossingDirection.outward : CrossingDirection.inward,
        slot: slot,
      );
    }

    final halfH = particle.dimension.height / 2;
    if (direction == CrossingDirection.inward &&
        particle.position.y + halfH < MembraneTransportConstants.membraneMinY) {
      particle.moveInDirection(
        MtVec2(
          model.random.nextDoubleBetween(-1, 1),
          model.random.nextDoubleBetween(-1, 0),
        ).normalized(),
        RandomWalkMode.sampleStraight(model.random),
      );
    }
    if (direction == CrossingDirection.outward &&
        particle.position.y - halfH > MembraneTransportConstants.membraneMaxY) {
      particle.moveInDirection(
        MtVec2(
          model.random.nextDoubleBetween(-1, 1),
          model.random.nextDoubleBetween(0, 1),
        ).normalized(),
        RandomWalkMode.sampleStraight(model.random),
      );
    }
  }
}

class WaitingInPumpMode extends ParticleMode {
  WaitingInPumpMode({required this.slot, required this.site});

  @override
  final Slot slot;
  final String site;

  @override
  void step(double dt, MtParticle particle, MembraneTransportModel model) {
    // Hold position at site — pump drives transitions.
  }
}

class WaitingInCotransporterMode extends ParticleMode {
  WaitingInCotransporterMode({required this.slot, required this.site});

  @override
  final Slot slot;
  final String site;

  @override
  void step(double dt, MtParticle particle, MembraneTransportModel model) {}
}

class LigandBoundMode extends ParticleMode {
  LigandBoundMode({required this.channel});

  final LigandGatedChannel channel;

  @override
  Slot? get slot => channel.slotOrNull;

  @override
  void step(double dt, MtParticle particle, MembraneTransportModel model) {
    particle.position.set(channel.bindingPosition);
  }
}

class UserControlledMode extends ParticleMode {
  @override
  void step(double dt, MtParticle particle, MembraneTransportModel model) {}
}
