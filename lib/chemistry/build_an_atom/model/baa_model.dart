/// Exploration model for Atom / Symbol screens — PhET `BAAModel`.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/iaam_vec2.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/sphere_bucket_layout.dart';

import '../constants/baa_constants.dart';
import 'baa_particle.dart';
import 'electron_model.dart';
import 'number_atom.dart';
import 'particle_atom.dart';
import 'particle_bucket.dart';

/// Main interactive atom + three buckets. Pure domain; no Widgets.
class BAAModel extends ChangeNotifier {
  BAAModel() {
    _createParticlePool();
    layoutBuckets(animate: false, packFromScratch: true);
  }

  final ParticleAtom atom = ParticleAtom();
  final ElectronModel electronModel = ElectronModel();

  late final ParticleBucket protonBucket;
  late final ParticleBucket neutronBucket;
  late final ParticleBucket electronBucket;

  final List<BaaParticle> nucleons = <BaaParticle>[];
  final List<BaaParticle> electrons = <BaaParticle>[];

  /// Currently dragged particle (at most one).
  BaaParticle? draggingParticle;

  /// When true and nucleus unstable, [step] updates shake offset.
  bool animateNuclearInstability = false;

  double _nucleusJumpCountdown = BAAConstants.nucleusJumpPeriod;
  int _nucleusJumpCount = 0;
  bool _resetting = false;

  static const _jumpAngles = <double>[
    math.pi * 0.1,
    math.pi * 1.6,
    math.pi * 0.7,
    math.pi * 1.1,
    math.pi * 0.3,
  ];

  void _createParticlePool() {
    protonBucket = ParticleBucket(
      type: BaaParticleType.proton,
      maxCount: BAAConstants.maxProtons,
    );
    neutronBucket = ParticleBucket(
      type: BaaParticleType.neutron,
      maxCount: BAAConstants.maxNeutrons,
    );
    electronBucket = ParticleBucket(
      type: BaaParticleType.electron,
      maxCount: BAAConstants.maxElectrons,
    );

    var id = 0;
    for (var i = 0; i < BAAConstants.maxProtons; i++) {
      final p = BaaParticle(id: id++, type: BaaParticleType.proton);
      nucleons.add(p);
      protonBucket.addParticleFirstOpen(p);
    }
    for (var i = 0; i < BAAConstants.maxNeutrons; i++) {
      final p = BaaParticle(id: id++, type: BaaParticleType.neutron);
      nucleons.add(p);
      neutronBucket.addParticleFirstOpen(p);
    }
    for (var i = 0; i < BAAConstants.maxElectrons; i++) {
      final p = BaaParticle(id: id++, type: BaaParticleType.electron);
      electrons.add(p);
      electronBucket.addParticleFirstOpen(p);
    }
  }

  int get protonCount => atom.protonCount;
  int get neutronCount => atom.neutronCount;
  int get electronCount => atom.electronCount;
  int get atomicNumber => atom.atomicNumber;
  int get massNumber => atom.massNumber;
  int get charge => atom.charge;
  bool get nucleusStable => atom.nucleusStable;
  NumberAtom get numberAtom => atom.toNumberAtom();

  ParticleBucket bucketFor(BaaParticleType type) {
    switch (type) {
      case BaaParticleType.proton:
        return protonBucket;
      case BaaParticleType.neutron:
        return neutronBucket;
      case BaaParticleType.electron:
        return electronBucket;
    }
  }

  double _bucketX(BaaParticleType type) {
    switch (type) {
      case BaaParticleType.proton:
        return BAAConstants.protonBucketX;
      case BaaParticleType.neutron:
        return BAAConstants.neutronBucketX;
      case BaaParticleType.electron:
        return BAAConstants.electronBucketX;
    }
  }

  double _sphereRadius(BaaParticleType type) => type == BaaParticleType.electron
      ? BAAConstants.electronRadius
      : BAAConstants.nucleonRadius;

  /// Relayout bucket particles (SphereBucket triangular stack).
  ///
  /// * [packFromScratch] — initial / Reset: fill `firstOpen` slots in order.
  /// * otherwise — each particle keeps near its current seat via
  ///   `nearestOpenPosition` (drop into any nearby gap; no forced march along
  ///   a global re-pack path). Bottom layer claims seats first so supports exist.
  /// * [animate] — when true, only update destinations; [step] rolls balls in.
  void layoutBuckets({bool animate = true, bool packFromScratch = false}) {
    for (final type in BaaParticleType.values) {
      _layoutOneBucket(
        bucketFor(type),
        animate: animate,
        packFromScratch: packFromScratch,
      );
    }
  }

  void _layoutOneBucket(
    ParticleBucket bucket, {
    required bool animate,
    required bool packFromScratch,
  }) {
    final occupied = <IaamVec2>[];
    final bx = _bucketX(bucket.type);
    final by = BAAConstants.bucketYOffset;
    final r = _sphereRadius(bucket.type);
    final usable = bucket.type == BaaParticleType.electron ? 0.8 : 1.0;
    final bucketPos = IaamVec2(bx, by);

    final ordered = List<BaaParticle>.from(bucket.particles);
    if (!packFromScratch) {
      // Bottom → top (model +Y is up) so lower balls support upper gaps.
      ordered.sort((a, b) {
        final dy = a.y.compareTo(b.y);
        return dy != 0 ? dy : a.x.compareTo(b.x);
      });
    }

    for (final p in ordered) {
      final slot = packFromScratch
          ? SphereBucketLayout.firstOpenPosition(
              bucketPosition: bucketPos,
              bucketWidth: BAAConstants.bucketWidth,
              sphereRadius: r,
              occupiedDestinations: occupied,
              usableWidthProportion: usable,
            )
          : SphereBucketLayout.nearestOpenPosition(
              preferred: IaamVec2(p.x, p.y),
              bucketPosition: bucketPos,
              bucketWidth: BAAConstants.bucketWidth,
              sphereRadius: r,
              occupiedDestinations: occupied,
              usableWidthProportion: usable,
            );
      occupied.add(slot);
      p.setDestination(slot.x, slot.y);
      if (!animate && !p.isDragging) {
        p.placeAt(slot.x, slot.y);
      }
    }

    // Paint order: higher destination Y = on top of the pile.
    final byDest = List<BaaParticle>.from(bucket.particles)
      ..sort((a, b) => a.destY.compareTo(b.destY));
    for (var i = 0; i < byDest.length; i++) {
      byDest[i].zLayer = i;
    }
  }

  /// Begin drag: detach from current container.
  /// [modelX]/[modelY] should already include touch drag offset.
  void beginDrag(BaaParticle particle, {double? modelX, double? modelY}) {
    if (particle.container == BaaParticleContainer.bucket) {
      bucketFor(particle.type).removeParticle(particle);
      layoutBuckets();
    } else if (particle.container == BaaParticleContainer.atom) {
      atom.removeParticle(particle);
    }
    particle.isDragging = true;
    particle.container = null;
    particle.zLayer = 0; // drag layer on top
    draggingParticle = particle;
    if (modelX != null && modelY != null) {
      particle.placeAt(modelX, modelY);
    }
    notifyListeners();
  }

  void updateDrag(BaaParticle particle, double modelX, double modelY) {
    if (!particle.isDragging) return;
    particle.placeAt(modelX, modelY);
    notifyListeners();
  }

  /// End drag at model position ([x],[y]).
  void endDrag(BaaParticle particle, double x, double y) {
    particle.isDragging = false;
    particle.placeAt(x, y);
    draggingParticle = null;

    final bucket = bucketFor(particle.type);
    if (particle.isNucleon) {
      final d = particle.distanceTo(atom.atomX, atom.atomY);
      if (d < BAAConstants.nucleonCaptureRadius) {
        atom.addParticle(particle);
      } else {
        bucket.addParticleNearestOpen(particle);
        // Roll from release point into the packed slot.
        layoutBuckets(animate: true);
      }
    } else {
      final d = particle.distanceTo(atom.atomX, atom.atomY);
      if (d < BAAConstants.electronCaptureRadius) {
        atom.addParticle(particle);
      } else {
        bucket.addParticleNearestOpen(particle);
        layoutBuckets(animate: true);
      }
    }
    notifyListeners();
  }

  /// Convenience: move one particle from bucket into atom (non-drag API).
  bool addFromBucket(BaaParticleType type) {
    final bucket = bucketFor(type);
    final p = bucket.extractClosestParticle(atom.atomX, atom.atomY);
    if (p == null) return false;
    atom.addParticle(p);
    layoutBuckets();
    notifyListeners();
    return true;
  }

  bool removeToBucket(BaaParticle particle) {
    if (!atom.contains(particle)) return false;
    atom.removeParticle(particle);
    bucketFor(particle.type).addParticleNearestOpen(particle);
    layoutBuckets();
    notifyListeners();
    return true;
  }

  void setElectronModel(ElectronModelType type) {
    electronModel.type = type;
    notifyListeners();
  }

  void setAnimateNuclearInstability(bool value) {
    animateNuclearInstability = value;
    if (!value) {
      atom.nucleusOffsetX = 0;
      atom.nucleusOffsetY = 0;
      atom.reconfigureNucleus();
    }
    notifyListeners();
  }

  /// Clock tick: particle travel + optional nucleus shake.
  void step(double dt) {
    var changed = false;
    for (final p in [...nucleons, ...electrons]) {
      if (p.isDragging) continue;
      if ((p.x - p.destX).abs() > 1e-4 || (p.y - p.destY).abs() > 1e-4) {
        p.stepTowardDestination(dt, BAAConstants.defaultParticleSpeed);
        changed = true;
      }
    }

    if (!_resetting && !atom.nucleusStable && animateNuclearInstability) {
      _nucleusJumpCountdown -= dt;
      if (_nucleusJumpCountdown <= 0) {
        _nucleusJumpCountdown = BAAConstants.nucleusJumpPeriod;
        _nucleusJumpCount++;
        final angle = _jumpAngles[_nucleusJumpCount % _jumpAngles.length];
        final distances = <double>[
          BAAConstants.maxNucleusJump * 0.4,
          BAAConstants.maxNucleusJump * 0.8,
          BAAConstants.maxNucleusJump * 0.2,
          BAAConstants.maxNucleusJump * 0.9,
        ];
        final distance = distances[_nucleusJumpCount % distances.length];
        atom.nucleusOffsetX = distance * math.cos(angle);
        atom.nucleusOffsetY = distance * math.sin(angle);
        atom.reconfigureNucleus();
        changed = true;
      }
    } else if (atom.nucleusOffsetX != 0 || atom.nucleusOffsetY != 0) {
      atom.nucleusOffsetX = 0;
      atom.nucleusOffsetY = 0;
      atom.reconfigureNucleus();
      changed = true;
    }

    if (changed) notifyListeners();
  }

  void setAtomConfiguration(NumberAtom config) {
    _adjustCount(BaaParticleType.proton, config.protons);
    _adjustCount(BaaParticleType.neutron, config.neutrons);
    _adjustCount(BaaParticleType.electron, config.electrons);
    layoutBuckets();
    atom.snapAllToDestination();
    notifyListeners();
  }

  void _adjustCount(BaaParticleType type, int target) {
    final bucket = bucketFor(type);
    var current = switch (type) {
      BaaParticleType.proton => atom.protonCount,
      BaaParticleType.neutron => atom.neutronCount,
      BaaParticleType.electron => atom.electronCount,
    };
    while (current < target) {
      final p = bucket.extractClosestParticle(atom.atomX, atom.atomY);
      if (p == null) break;
      atom.addParticle(p);
      current++;
    }
    while (current > target) {
      final p = atom.extractParticle(type);
      if (p == null) break;
      bucket.addParticleFirstOpen(p);
      current--;
    }
  }

  void reset() {
    _resetting = true;
    draggingParticle = null;
    for (final p in [...nucleons, ...electrons]) {
      p.isDragging = false;
      p.electronShellIndex = null;
      p.zLayer = 0;
    }
    atom.clear();
    protonBucket.reset();
    neutronBucket.reset();
    electronBucket.reset();
    for (final p in nucleons) {
      if (p.isProton) {
        protonBucket.addParticleFirstOpen(p);
      } else {
        neutronBucket.addParticleFirstOpen(p);
      }
    }
    for (final e in electrons) {
      electronBucket.addParticleFirstOpen(e);
    }
    layoutBuckets(animate: false, packFromScratch: true);
    electronModel.reset();
    animateNuclearInstability = false;
    _nucleusJumpCountdown = BAAConstants.nucleusJumpPeriod;
    _nucleusJumpCount = 0;
    _resetting = false;
    notifyListeners();
  }
}
