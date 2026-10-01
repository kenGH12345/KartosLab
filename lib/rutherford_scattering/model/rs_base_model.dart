import '../rs_constants.dart';
import 'alpha_particle.dart';
import 'atom_space.dart';
import 'gun.dart';
import 'rs_geometry.dart';

/// Base model — port of PhET RSBaseModel.ts (Widget-free).
abstract class RsBaseModel {
  RsBaseModel() {
    gun = Gun(this);
  }

  late final Gun gun;

  double alphaParticleEnergy = RsConstants.defaultAlphaEnergy;
  bool running = true;
  int protonCount = RsConstants.defaultProtonCount;
  int neutronCount = RsConstants.defaultNeutronCount;
  bool userInteraction = false;
  bool showTraces = RsConstants.defaultShowTraces;

  final RsBounds2 bounds = const RsBounds2(
    -RsConstants.spaceNodeWidth / 4,
    -RsConstants.spaceNodeHeight / 4,
    RsConstants.spaceNodeWidth / 4,
    RsConstants.spaceNodeHeight / 4,
  );

  final List<AlphaParticle> particles = <AlphaParticle>[];
  final List<AtomSpace> atomSpaces = <AtomSpace>[];

  final double manualStepDt = RsConstants.manualStepDt;

  int _revision = 0;
  int get revision => _revision;

  void notifyChanged() => _revision++;

  AtomSpace getVisibleSpace() {
    for (final space in atomSpaces) {
      if (space.isVisible) return space;
    }
    throw StateError('No visible AtomSpace');
  }

  void addParticle(AlphaParticle alphaParticle) {
    particles.add(alphaParticle);
    getVisibleSpace().addParticle(alphaParticle);
    notifyChanged();
  }

  void removeParticle(AlphaParticle alphaParticle) {
    final visibleSpace = getVisibleSpace();
    visibleSpace.removeParticle(alphaParticle);
    for (final atom in visibleSpace.atoms) {
      atom.removeParticle(alphaParticle);
    }
    particles.remove(alphaParticle);
    notifyChanged();
  }

  void removeAllParticles() {
    final visibleSpace = getVisibleSpace();
    visibleSpace.removeAllParticles();
    for (final atom in visibleSpace.atoms) {
      atom.particles.clear();
    }
    particles.clear();
    notifyChanged();
  }

  /// Wire space error emitter → full remove.
  void wireSpace(AtomSpace space) {
    space.onParticleRemovedFromAtom = removeParticle;
  }

  void _moveParticles(double dt) {
    getVisibleSpace().moveParticles(dt);
  }

  void cullParticles() {
    final toRemove = particles
        .where((p) => !bounds.containsPoint(p.position))
        .toList();
    for (final p in toRemove) {
      removeParticle(p);
    }
  }

  void step(double dt) {
    if (running && !userInteraction && dt < 1) {
      gun.step(dt);
      _moveParticles(dt);
      cullParticles();
      notifyChanged();
    }
  }

  void manualStep() {
    if (!userInteraction) {
      gun.step(manualStepDt);
      _moveParticles(manualStepDt);
      cullParticles();
      notifyChanged();
    }
  }

  /// Setting controls that clear particles (PhET Multilink).
  void setAlphaParticleEnergy(double value) {
    alphaParticleEnergy =
        value.clamp(RsConstants.minAlphaEnergy, RsConstants.maxAlphaEnergy);
    removeAllParticles();
  }

  void setProtonCount(int value) {
    protonCount =
        value.clamp(RsConstants.minProtonCount, RsConstants.maxProtonCount);
    removeAllParticles();
  }

  void setNeutronCount(int value) {
    neutronCount =
        value.clamp(RsConstants.minNeutronCount, RsConstants.maxNeutronCount);
    removeAllParticles();
  }

  void setUserInteraction(bool value) {
    if (userInteraction == value) return;
    userInteraction = value;
    // PhET Multilink includes userInteraction → clears particles on any change.
    removeAllParticles();
  }

  void setGunOn(bool value) {
    gun.on = value;
    notifyChanged();
  }

  void setRunning(bool value) {
    running = value;
    notifyChanged();
  }

  void setShowTraces(bool value) {
    showTraces = value;
    notifyChanged();
  }

  void reset() {
    gun.reset();
    removeAllParticles();
    alphaParticleEnergy = RsConstants.defaultAlphaEnergy;
    running = true;
    userInteraction = false;
    protonCount = RsConstants.defaultProtonCount;
    neutronCount = RsConstants.defaultNeutronCount;
    showTraces = RsConstants.defaultShowTraces;
    notifyChanged();
  }
}
