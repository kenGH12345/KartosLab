/// Make Isotopes runtime model — PhET `IsotopesModel.ts` + spatial particle state.
///
/// Phase 2: counts / isotope resolution / jump countdown.
/// Phase 3: particle identity, positions, drag contract, reconfigure, jump translate.
///
/// NO Flutter UI / gestures / painters.
library;

import 'dart:math' as math;

import 'data/data.dart';
import 'iaam_vec2.dart';
import 'make_isotopes_constants.dart';
import 'nucleon_particle.dart';
import 'nucleus_reconfigure.dart';
import 'sphere_bucket_layout.dart';

/// Runtime model for the Isotopes (Make) screen.
class MakeIsotopesModel {
  MakeIsotopesModel({
    ElementRepository? elementRepository,
    IsotopeRepository? isotopeRepository,
  })  : _elements = elementRepository ?? ElementRepository.instance,
        _isotopes = isotopeRepository ?? IsotopeRepository.instance {
    _initializeForElement(kMakeIsotopesDefaultAtomicNumber);
  }

  final ElementRepository _elements;
  final IsotopeRepository _isotopes;

  int _revision = 0;
  int get revision => _revision;
  void _notify() => _revision++;

  int _nextParticleId = 1;

  late ElementData _selectedElement;

  /// Model-space atom center (`ParticleAtom.positionProperty`). Default (0,0);
  /// View may later move this onto the scale.
  double atomX = kDefaultAtomX;
  double atomY = kDefaultAtomY;

  /// Unstable jump offset (`nucleusOffsetProperty`).
  double nucleusOffsetX = 0;
  double nucleusOffsetY = 0;

  double _nucleusJumpCountdown = kNucleusJumpPeriod;
  int _nucleusJumpCount = 0;

  final List<NucleonParticle> _protons = <NucleonParticle>[];
  final List<NucleonParticle> _nucleusNeutrons = <NucleonParticle>[];
  final List<NucleonParticle> _bucketNeutrons = <NucleonParticle>[];

  /// Neutrons currently free (mid-drag, container cleared). At most one.
  NucleonParticle? _draggingNeutron;

  /// PhET ParticleView: `applyOffset: false` → mouse grab offset is zero.
  /// Stored for contract completeness / touch offset later.
  double grabOffsetX = 0;
  double grabOffsetY = 0;

  IaamVec2 get bucketPosition =>
      const IaamVec2(kNeutronBucketX, kNeutronBucketY);

  IaamVec2 get atomPosition => IaamVec2(atomX, atomY);

  IaamVec2 get nucleusCenter =>
      IaamVec2(atomX + nucleusOffsetX, atomY + nucleusOffsetY);

  // ---- Accessors (Phase 2 compatible) ----

  ElementData get selectedElement => _selectedElement;

  int get protonCount => _protons.length;

  int get electronCount => protonCount;

  int get neutronCount => _nucleusNeutrons.length;

  int get bucketNeutronCount => _bucketNeutrons.length;

  /// All neutrons owned by this screen (bucket + nucleus + mid-drag).
  int get totalNeutronCount =>
      _nucleusNeutrons.length +
      _bucketNeutrons.length +
      (_draggingNeutron != null ? 1 : 0);

  int get massNumber => protonCount + neutronCount;

  IsotopeData? get currentIsotope =>
      _isotopes.find(protonCount, massNumber);

  IsotopeId get currentIsotopeId => IsotopeId(protonCount, massNumber);

  double get atomicMass =>
      AtomInfoUtils.getIsotopeAtomicMass(protonCount, neutronCount);

  double get naturalAbundance {
    final iso = currentIsotope;
    if (iso == null) return 0;
    return iso.naturalAbundance;
  }

  double naturalAbundanceRounded(int decimalPlaces) {
    return AtomInfoUtils.getNaturalAbundance(
      protonCount: protonCount,
      massNumber: massNumber,
      numDecimalPlaces: decimalPlaces,
    );
  }

  bool get isStable {
    if (massNumber <= 0) return true;
    return AtomInfoUtils.isStable(protonCount, neutronCount);
  }

  bool get isUnstable => !isStable;

  bool get existsInTraceAmounts => AtomInfoUtils.existsInTraceAmounts(
        protonCount: protonCount,
        massNumber: massNumber,
      );

  List<NucleonParticle> get protons =>
      List<NucleonParticle>.unmodifiable(_protons);

  List<NucleonParticle> get nucleusNeutrons =>
      List<NucleonParticle>.unmodifiable(_nucleusNeutrons);

  List<NucleonParticle> get bucketNeutrons =>
      List<NucleonParticle>.unmodifiable(_bucketNeutrons);

  NucleonParticle? get draggingNeutron => _draggingNeutron;

  bool get isDragging => _draggingNeutron != null;

  // ---- Element selection ----

  void selectElement(int atomicNumber) {
    if (atomicNumber < 1 || atomicNumber > kMakeIsotopesMaxAtomicNumber) {
      throw RangeError.range(
        atomicNumber,
        1,
        kMakeIsotopesMaxAtomicNumber,
        'atomicNumber',
      );
    }
    if (atomicNumber == _selectedElement.atomicNumber) {
      return;
    }
    _initializeForElement(atomicNumber);
    _notify();
  }

  void _initializeForElement(int atomicNumber) {
    final element = _elements.getByAtomicNumber(atomicNumber);
    if (element == null) {
      throw StateError('No ElementData for Z=$atomicNumber');
    }
    _selectedElement = element;
    _clearAllParticles();
    _resetJumpState();

    // PhET initializeParticles: protons, most-common neutrons, electrons,
    // moveAllParticlesToDestination, then 4 bucket neutrons via firstOpen.
    for (var i = 0; i < atomicNumber; i++) {
      final p = _createParticle(NucleonKind.proton);
      _protons.add(p);
      p.container = NeutronContainer.nucleus;
    }
    final mostCommon = element.mostCommonNeutronCount;
    for (var i = 0; i < mostCommon; i++) {
      final n = _createParticle(NucleonKind.neutron);
      _nucleusNeutrons.add(n);
      n.container = NeutronContainer.nucleus;
    }
    reconfigureNucleus();

    for (var i = 0; i < kDefaultNeutronsInBucket; i++) {
      final n = _createParticle(NucleonKind.neutron);
      _addNeutronToBucketFirstOpen(n);
    }
  }

  NucleonParticle _createParticle(NucleonKind kind) {
    return NucleonParticle(id: _nextParticleId++, kind: kind);
  }

  void _clearAllParticles() {
    _protons.clear();
    _nucleusNeutrons.clear();
    _bucketNeutrons.clear();
    _draggingNeutron = null;
    grabOffsetX = 0;
    grabOffsetY = 0;
  }

  void _resetJumpState() {
    _nucleusJumpCountdown = kNucleusJumpPeriod;
    _nucleusJumpCount = 0;
    _setNucleusOffset(0, 0);
  }

  // ---- Nucleus reconfigure ----

  /// shred `ParticleAtom.reconfigureNucleus` — snaps destinations (Phase 3
  /// has no flight animation).
  void reconfigureNucleus() {
    NucleusReconfigure.reconfigure(
      protons: _protons,
      neutrons: _nucleusNeutrons,
      nucleonRadius: kNucleonRadius,
      centerX: atomX + nucleusOffsetX,
      centerY: atomY + nucleusOffsetY,
    );
  }

  // ---- Bucket helpers ----

  List<IaamVec2> _bucketOccupied() =>
      [for (final p in _bucketNeutrons) p.destination];

  void _addNeutronToBucketFirstOpen(NucleonParticle n) {
    final pos = SphereBucketLayout.firstOpenPosition(
      bucketPosition: bucketPosition,
      bucketWidth: kNeutronBucketWidth,
      sphereRadius: kNucleonRadius,
      occupiedDestinations: _bucketOccupied(),
    );
    n.placeAt(pos.x, pos.y);
    n.container = NeutronContainer.bucket;
    n.isDragging = false;
    _bucketNeutrons.add(n);
  }

  void _addNeutronToBucketNearestOpen(NucleonParticle n) {
    final pos = SphereBucketLayout.nearestOpenPosition(
      preferred: n.destination,
      bucketPosition: bucketPosition,
      bucketWidth: kNeutronBucketWidth,
      sphereRadius: kNucleonRadius,
      occupiedDestinations: _bucketOccupied(),
    );
    n.placeAt(pos.x, pos.y);
    n.container = NeutronContainer.bucket;
    n.isDragging = false;
    _bucketNeutrons.add(n);
  }

  void _removeFromBucket(NucleonParticle n, {bool skipLayout = false}) {
    final removed = _bucketNeutrons.remove(n);
    assert(removed);
    n.container = null;
    if (!skipLayout) {
      _relayoutBucketNeutrons();
    }
  }

  void _relayoutBucketNeutrons() {
    // SphereBucket.relayoutBucketParticles — collapse dangling stacks.
    var moved = true;
    while (moved) {
      moved = false;
      for (final p in List<NucleonParticle>.from(_bucketNeutrons)) {
        final others = [
          for (final o in _bucketNeutrons)
            if (o.id != p.id) o.destination,
        ];
        final bottomY = bucketPosition.y +
            SphereBucketLayout.defaultVerticalOffset(kNucleonRadius);
        final onBottom = p.destY == bottomY;
        if (onBottom) continue;
        var support = 0;
        for (final o in others) {
          if (o.y < p.destY &&
              o.distanceTo(p.destination) < kNucleonRadius * 3) {
            support++;
          }
        }
        if (support < 2) {
          final dest = SphereBucketLayout.nearestOpenPosition(
            preferred: p.destination,
            bucketPosition: bucketPosition,
            bucketWidth: kNeutronBucketWidth,
            sphereRadius: kNucleonRadius,
            occupiedDestinations: others,
          );
          p.placeAt(dest.x, dest.y);
          moved = true;
          break;
        }
      }
    }
  }

  void _addToNucleus(NucleonParticle n) {
    assert(n.kind == NucleonKind.neutron);
    n.container = NeutronContainer.nucleus;
    n.isDragging = false;
    _nucleusNeutrons.add(n);
    reconfigureNucleus();
  }

  void _removeFromNucleus(NucleonParticle n) {
    final removed = _nucleusNeutrons.remove(n);
    assert(removed);
    n.container = null;
    reconfigureNucleus();
  }

  // ---- Count-level transfers (Phase 2 API) ----

  /// Move one bucket neutron → nucleus (identity preserved). No auto-refill.
  bool addNeutron() {
    if (_bucketNeutrons.isEmpty) return false;
    final wasStable = isStable;
    final n = _bucketNeutrons.last;
    _removeFromBucket(n, skipLayout: false);
    _addToNucleus(n);
    _onStabilityMaybeChanged(wasStable);
    _notify();
    return true;
  }

  /// Move one nucleus neutron → bucket (nearest open).
  bool removeNeutron() {
    if (_nucleusNeutrons.isEmpty) return false;
    final wasStable = isStable;
    final n = _nucleusNeutrons.last;
    _removeFromNucleus(n);
    _addNeutronToBucketNearestOpen(n);
    _onStabilityMaybeChanged(wasStable);
    _notify();
    return true;
  }

  // ---- Drag contract ----

  /// Begin dragging [neutronId]. Removes from container (atom or bucket).
  ///
  /// PhET: `isDragging=true` → `container.removeParticle`.
  /// ParticleView uses `applyOffset: false` → center snaps to [pointerX/Y].
  bool beginDrag(int neutronId, double pointerX, double pointerY) {
    if (_draggingNeutron != null) return false;
    final n = _findNeutron(neutronId);
    if (n == null) return false;

    final wasStable = isStable;
    if (n.container == NeutronContainer.bucket) {
      _removeFromBucket(n);
    } else if (n.container == NeutronContainer.nucleus) {
      _removeFromNucleus(n);
    } else {
      return false;
    }

    // applyOffset:false → grab offset 0; particle center = pointer.
    grabOffsetX = 0;
    grabOffsetY = 0;
    n.isDragging = true;
    n.zLayer = 0;
    n.placeAt(pointerX, pointerY);
    _draggingNeutron = n;
    _onStabilityMaybeChanged(wasStable);
    _notify();
    return true;
  }

  /// Update dragged neutron position (model coords). Does not change counts.
  bool updateDrag(double pointerX, double pointerY) {
    final n = _draggingNeutron;
    if (n == null) return false;
    n.placeAt(pointerX - grabOffsetX, pointerY - grabOffsetY);
    _notify();
    return true;
  }

  /// End drag: capture if distance(particle, atom) < 100, else bucket nearest.
  ///
  /// PhET `placeNucleon`: compares `particle.position` to `particleAtom.position`
  /// (not nucleusOffset center).
  bool endDrag() {
    final n = _draggingNeutron;
    if (n == null) return false;

    final wasStable = isStable;
    n.isDragging = false;
    _draggingNeutron = null;

    final dist = n.position.distanceTo(atomPosition);
    final captured = dist < kNucleonCaptureRadius;
    if (captured) {
      _addToNucleus(n);
    } else {
      _addNeutronToBucketNearestOpen(n);
    }
    grabOffsetX = 0;
    grabOffsetY = 0;
    _onStabilityMaybeChanged(wasStable);
    _notify();
    return captured;
  }

  /// Phase 2 helper: start drag of any bucket neutron without pointer.
  bool beginDragFromBucket() {
    if (_bucketNeutrons.isEmpty || _draggingNeutron != null) return false;
    final n = _bucketNeutrons.last;
    return beginDrag(n.id, n.x, n.y);
  }

  /// Phase 2 helper: start drag of any nucleus neutron without pointer.
  bool beginDragFromNucleus() {
    if (_nucleusNeutrons.isEmpty || _draggingNeutron != null) return false;
    final n = _nucleusNeutrons.last;
    return beginDrag(n.id, n.x, n.y);
  }

  /// Phase 2 helper: place free neutron by distance (ignores actual XY).
  /// Caller must have begun a drag so one free neutron exists.
  bool placeNeutronAtDistance(double distanceToNucleus) {
    final n = _draggingNeutron;
    if (n == null) return false;

    final wasStable = isStable;
    n.isDragging = false;
    _draggingNeutron = null;

    final captured = distanceToNucleus < kNucleonCaptureRadius;
    if (captured) {
      // Align particle near atom so reconfigure has a consistent start.
      n.placeAt(atomX, atomY);
      _addToNucleus(n);
    } else {
      _addNeutronToBucketNearestOpen(n);
    }
    grabOffsetX = 0;
    grabOffsetY = 0;
    _onStabilityMaybeChanged(wasStable);
    _notify();
    return captured;
  }

  bool canCaptureNeutronAtDistance(double distanceToNucleus) {
    return distanceToNucleus < kNucleonCaptureRadius;
  }

  bool canCaptureNeutronAtOffset(double dx, double dy) {
    return canCaptureNeutronAtDistance(math.sqrt(dx * dx + dy * dy));
  }

  /// Capture test using current dragged particle position vs atom position.
  bool canCaptureDraggingNeutron() {
    final n = _draggingNeutron;
    if (n == null) return false;
    return canCaptureNeutronAtDistance(n.position.distanceTo(atomPosition));
  }

  NucleonParticle? _findNeutron(int id) {
    for (final n in _nucleusNeutrons) {
      if (n.id == id) return n;
    }
    for (final n in _bucketNeutrons) {
      if (n.id == id) return n;
    }
    if (_draggingNeutron?.id == id) return _draggingNeutron;
    return null;
  }

  void _onStabilityMaybeChanged(bool wasStable) {
    if (wasStable != isStable) {
      _resetJumpState();
    }
  }

  // ---- Unstable jump ----

  /// Advance jump + (future) particle flight. Translates nucleus nucleons when
  /// `nucleusOffset` changes — shred `ParticleAtom.nucleusOffsetProperty.link`.
  void step(double dt) {
    if (!isUnstable) return;

    _nucleusJumpCountdown -= dt;
    if (_nucleusJumpCountdown > 0) return;

    _nucleusJumpCountdown = kNucleusJumpPeriod;
    if (nucleusOffsetX == 0 && nucleusOffsetY == 0) {
      _nucleusJumpCount++;
      final angle = kJumpAngles[_nucleusJumpCount % kJumpAngles.length];
      final distance = kJumpDistances[_nucleusJumpCount % kJumpDistances.length];
      _setNucleusOffset(
        math.cos(angle) * distance,
        math.sin(angle) * distance,
      );
    } else {
      _setNucleusOffset(0, 0);
    }
    _notify();
  }

  void _setNucleusOffset(double x, double y) {
    final dx = x - nucleusOffsetX;
    final dy = y - nucleusOffsetY;
    if (dx == 0 && dy == 0) {
      nucleusOffsetX = x;
      nucleusOffsetY = y;
      return;
    }
    nucleusOffsetX = x;
    nucleusOffsetY = y;
    _translateNucleusParticles(dx, dy);
  }

  void _translateNucleusParticles(double dx, double dy) {
    for (final p in _protons) {
      _translateParticle(p, dx, dy);
    }
    for (final n in _nucleusNeutrons) {
      _translateParticle(n, dx, dy);
    }
  }

  void _translateParticle(NucleonParticle p, double dx, double dy) {
    // PhET: if position==destination, move both; else only destination.
    if (p.x == p.destX && p.y == p.destY) {
      p.placeAt(p.x + dx, p.y + dy);
    } else {
      p.setDestination(p.destX + dx, p.destY + dy);
    }
  }

  /// Move atom center (View will call when electron cloud repositions).
  void setAtomPosition(double x, double y) {
    final dx = x - atomX;
    final dy = y - atomY;
    atomX = x;
    atomY = y;
    if (dx != 0 || dy != 0) {
      _translateNucleusParticles(dx, dy);
    }
    _notify();
  }

  // ---- Reset ----

  void reset() {
    final alreadyDefault =
        _selectedElement.atomicNumber == kMakeIsotopesDefaultAtomicNumber;
    if (!alreadyDefault) {
      _initializeForElement(kMakeIsotopesDefaultAtomicNumber);
    } else {
      final mostCommon = AtomInfoUtils.getNumNeutronsInMostCommonIsotope(
        kMakeIsotopesDefaultAtomicNumber,
      );
      if (neutronCount != mostCommon ||
          bucketNeutronCount != kDefaultNeutronsInBucket ||
          _draggingNeutron != null) {
        _initializeForElement(kMakeIsotopesDefaultAtomicNumber);
      } else {
        _resetJumpState();
      }
    }
    _notify();
  }

  MakeIsotopesSnapshot snapshot() {
    return MakeIsotopesSnapshot(
      atomicNumber: protonCount,
      nucleusNeutronCount: neutronCount,
      bucketNeutronCount: bucketNeutronCount,
      massNumber: massNumber,
      atomicMass: atomicMass,
      naturalAbundance: naturalAbundance,
      isStable: isStable,
    );
  }
}

class MakeIsotopesSnapshot {
  const MakeIsotopesSnapshot({
    required this.atomicNumber,
    required this.nucleusNeutronCount,
    required this.bucketNeutronCount,
    required this.massNumber,
    required this.atomicMass,
    required this.naturalAbundance,
    required this.isStable,
  });

  final int atomicNumber;
  final int nucleusNeutronCount;
  final int bucketNeutronCount;
  final int massNumber;
  final double atomicMass;
  final double naturalAbundance;
  final bool isStable;

  @override
  bool operator ==(Object other) =>
      other is MakeIsotopesSnapshot &&
      other.atomicNumber == atomicNumber &&
      other.nucleusNeutronCount == nucleusNeutronCount &&
      other.bucketNeutronCount == bucketNeutronCount &&
      other.massNumber == massNumber &&
      other.atomicMass == atomicMass &&
      other.naturalAbundance == naturalAbundance &&
      other.isStable == isStable;

  @override
  int get hashCode => Object.hash(
        atomicNumber,
        nucleusNeutronCount,
        bucketNeutronCount,
        massNumber,
        atomicMass,
        naturalAbundance,
        isStable,
      );
}
