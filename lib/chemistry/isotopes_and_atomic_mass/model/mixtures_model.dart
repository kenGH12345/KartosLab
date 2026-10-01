/// Mix Isotopes runtime model — PhET `MixturesModel.ts` + spatial particles.
///
/// Phase 5: counts / Nature / mode / save-restore.
/// Phase 6: MixParticle identity, bucket/chamber positions, drag contract.
///
/// NO Flutter UI.
library;

import 'dart:math';

import 'data/data.dart';
import 'iaam_vec2.dart';
import 'interactivity_mode.dart';
import 'mix_particle.dart';
import 'mixtures_constants.dart';
import 'sphere_bucket_layout.dart';

/// Snapshot of chamber quantities keyed by mass number for one (Z, mode).
typedef ChamberCounts = Map<int, int>;

class MixturesModel {
  MixturesModel({
    ElementRepository? elementRepository,
    IsotopeRepository? isotopeRepository,
    Random? random,
  })  : _elements = elementRepository ?? ElementRepository.instance,
        _isotopes = isotopeRepository ?? IsotopeRepository.instance,
        _random = random ?? Random() {
    _initForElement(kMixDefaultAtomicNumber);
  }

  final ElementRepository _elements;
  final IsotopeRepository _isotopes;
  final Random _random;

  int _revision = 0;
  int get revision => _revision;
  void _notify() => _revision++;

  int _nextParticleId = 1;

  late ElementData _selectedElement;
  InteractivityMode _interactivityMode = InteractivityMode.bucketsAndLargeAtoms;
  bool _showingNaturesMix = false;

  List<IsotopeData> _possibleIsotopes = <IsotopeData>[];

  /// Chamber particles (My Mix or Nature's Mix).
  final List<MixParticle> _chamberParticles = <MixParticle>[];

  /// Bucket particles (bucket mode My Mix only).
  final List<MixParticle> _bucketParticles = <MixParticle>[];

  /// `savedParticleStates[Z][mode]` — PhET saves PositionableAtom refs + positions.
  final Map<int, Map<InteractivityMode, List<SavedMixParticle>>> _savedStates =
      <int, Map<InteractivityMode, List<SavedMixParticle>>>{};

  MixParticle? _dragging;
  double grabOffsetX = 0;
  double grabOffsetY = 0;

  // ---- Accessors ----

  ElementData get selectedElement => _selectedElement;
  int get selectedAtomicNumber => _selectedElement.atomicNumber;
  InteractivityMode get interactivityMode => _interactivityMode;
  bool get showingNaturesMix => _showingNaturesMix;
  bool get isMyMix => !_showingNaturesMix;

  List<IsotopeData> get possibleIsotopes =>
      List<IsotopeData>.unmodifiable(_possibleIsotopes);

  List<MixParticle> get chamberParticles =>
      List<MixParticle>.unmodifiable(_chamberParticles);

  List<MixParticle> get bucketParticles =>
      List<MixParticle>.unmodifiable(_bucketParticles);

  MixParticle? get draggingParticle => _dragging;
  bool get isDragging => _dragging != null;

  int get totalIsotopeCount => _chamberParticles.length;

  int getIsotopeCount(int massNumber) {
    var n = 0;
    for (final p in _chamberParticles) {
      if (p.massNumber == massNumber) n++;
    }
    return n;
  }

  int getIsotopeCountFor(IsotopeData isotope) =>
      getIsotopeCount(isotope.massNumber);

  /// Bucket stock — derived from live bucket particles (not formula alone).
  int getBucketCount(int massNumber) {
    if (_showingNaturesMix) return 0;
    if (_interactivityMode != InteractivityMode.bucketsAndLargeAtoms) {
      return 0;
    }
    var n = 0;
    for (final p in _bucketParticles) {
      if (p.massNumber == massNumber) n++;
    }
    return n;
  }

  double getIsotopeProportion(int massNumber) {
    final total = totalIsotopeCount;
    if (total <= 0) return 0;
    return getIsotopeCount(massNumber) / total;
  }

  double get chamberAverageAtomicMass {
    final total = totalIsotopeCount;
    if (total <= 0) return 0;
    var sum = 0.0;
    for (final iso in _possibleIsotopes) {
      final c = getIsotopeCount(iso.massNumber);
      if (c > 0) sum += iso.atomicMass * c;
    }
    return sum / total;
  }

  double get displayedAverageAtomicMass {
    if (_showingNaturesMix) {
      return AtomInfoUtils.getStandardAtomicMass(selectedAtomicNumber);
    }
    return chamberAverageAtomicMass;
  }

  double get standardAtomicMass =>
      AtomInfoUtils.getStandardAtomicMass(selectedAtomicNumber);

  /// Chamber containment — PhET `TEST_CHAMBER_RECT.containsPoint`.
  bool isPositionInChamber(double x, double y) {
    return x >= kTestChamberMinX &&
        x <= kTestChamberMaxX &&
        y >= kTestChamberMinY &&
        y <= kTestChamberMaxY;
  }

  bool isParticleOverChamber(MixParticle p) =>
      isPositionInChamber(p.x, p.y);

  // ---- Bucket geometry (MixturesModel.addBuckets) ----

  IaamVec2 bucketPositionForIndex(int index) {
    final n = _possibleIsotopes.length;
    return IaamVec2(_controllerXOffset(index, n), kMixBucketY);
  }

  double _controllerXOffset(int controllerIndex, int numControllers) {
    late double interControllerDistanceX;
    late double controllerXOffset;
    if (numControllers < 4) {
      interControllerDistanceX = kTestChamberWidth / numControllers;
      controllerXOffset = kTestChamberMinX + interControllerDistanceX / 2;
    } else {
      interControllerDistanceX = (kTestChamberWidth * 1.10) / numControllers;
      controllerXOffset = -180;
    }
    return controllerXOffset + interControllerDistanceX * controllerIndex;
  }

  int _isotopeIndex(int massNumber) {
    for (var i = 0; i < _possibleIsotopes.length; i++) {
      if (_possibleIsotopes[i].massNumber == massNumber) return i;
    }
    return -1;
  }

  // ---- Element selection ----

  void selectElement(int atomicNumber) {
    if (atomicNumber < 1 || atomicNumber > kMixMaxAtomicNumber) {
      throw RangeError.range(
        atomicNumber,
        1,
        kMixMaxAtomicNumber,
        'atomicNumber',
      );
    }
    if (atomicNumber == selectedAtomicNumber) return;

    _cancelDrag();
    final previousZ = selectedAtomicNumber;
    if (!_showingNaturesMix) {
      _saveState(previousZ, _interactivityMode);
    }

    _initForElement(atomicNumber);
    _notify();
  }

  void _initForElement(int atomicNumber) {
    final element = _elements.getByAtomicNumber(atomicNumber);
    if (element == null) {
      throw StateError('No ElementData for Z=$atomicNumber');
    }
    _selectedElement = element;
    _updatePossibleIsotopes(atomicNumber);
    _clearAllParticles();

    if (_showingNaturesMix) {
      _applyNaturesMix();
    } else {
      _restoreState(atomicNumber, _interactivityMode);
      if (_interactivityMode == InteractivityMode.bucketsAndLargeAtoms) {
        _fillBuckets();
      }
    }
  }

  void _updatePossibleIsotopes(int atomicNumber) {
    _possibleIsotopes =
        _isotopes.getStableIsotopesSortedByMass(atomicNumber);
  }

  void _clearAllParticles() {
    _chamberParticles.clear();
    _bucketParticles.clear();
    _dragging = null;
    grabOffsetX = 0;
    grabOffsetY = 0;
  }

  // ---- Mode / Nature ----

  void setInteractivityMode(InteractivityMode mode) {
    if (mode == _interactivityMode) return;
    if (_showingNaturesMix) {
      _interactivityMode = mode;
      _notify();
      return;
    }

    _cancelDrag();
    final oldMode = _interactivityMode;
    _saveState(selectedAtomicNumber, oldMode);
    _clearAllParticles();
    _interactivityMode = mode;
    _restoreState(selectedAtomicNumber, mode);
    if (mode == InteractivityMode.bucketsAndLargeAtoms) {
      _fillBuckets();
    }
    _notify();
  }

  void setShowingNaturesMix(bool showing) {
    if (showing == _showingNaturesMix) return;
    _cancelDrag();

    if (showing) {
      _saveState(selectedAtomicNumber, _interactivityMode);
      _showingNaturesMix = true;
      _clearAllParticles();
      _applyNaturesMix();
      // Empty legend buckets (no particles) — PhET addBuckets empty.
    } else {
      _showingNaturesMix = false;
      _clearAllParticles();
      _restoreState(selectedAtomicNumber, _interactivityMode);
      if (_interactivityMode == InteractivityMode.bucketsAndLargeAtoms) {
        _fillBuckets();
      }
    }
    _notify();
  }

  void _applyNaturesMix() {
    final sorted = List<IsotopeData>.from(_possibleIsotopes)
      ..sort((a, b) {
        final ab = AtomInfoUtils.getNaturalAbundance(
          protonCount: b.atomicNumber,
          massNumber: b.massNumber,
          numDecimalPlaces: 10,
        );
        final aa = AtomInfoUtils.getNaturalAbundance(
          protonCount: a.atomicNumber,
          massNumber: a.massNumber,
          numDecimalPlaces: 10,
        );
        return ab.compareTo(aa);
      });

    for (final iso in sorted) {
      final abundance = AtomInfoUtils.getNaturalAbundance(
        protonCount: iso.atomicNumber,
        massNumber: iso.massNumber,
        numDecimalPlaces: kNaturesMixAbundanceDigits,
      );
      var n = roundSymmetric(kNumNaturesMixAtoms * abundance).toInt();
      if (n == 0) n = 1;
      for (var i = 0; i < n; i++) {
        final pos = _randomChamberPosition();
        _chamberParticles.add(_createParticle(
          iso.massNumber,
          kSmallIsotopeRadius,
          pos.x,
          pos.y,
          MixParticleContainer.chamber,
        ));
      }
    }
  }

  IaamVec2 _randomChamberPosition() {
    return IaamVec2(
      kTestChamberMinX + _random.nextDouble() * kTestChamberWidth,
      kTestChamberMinY + _random.nextDouble() * kTestChamberHeight,
    );
  }

  MixParticle _createParticle(
    int massNumber,
    double radius,
    double x,
    double y,
    MixParticleContainer container,
  ) {
    return MixParticle(
      id: _nextParticleId++,
      massNumber: massNumber,
      radius: radius,
      x: x,
      y: y,
      container: container,
    );
  }

  // ---- Bucket fill (PhET fillBuckets) ----

  void _fillBuckets() {
    assert(!_showingNaturesMix);
    assert(_interactivityMode == InteractivityMode.bucketsAndLargeAtoms);
    _bucketParticles.clear();

    for (var i = 0; i < _possibleIsotopes.length; i++) {
      final iso = _possibleIsotopes[i];
      final inChamber = getIsotopeCount(iso.massNumber);
      if (inChamber >= kNumLargeIsotopesPerBucket) continue;
      final toAdd = kNumLargeIsotopesPerBucket - inChamber;
      final bucketPos = bucketPositionForIndex(i);
      for (var j = 0; j < toAdd; j++) {
        final occupied = [
          for (final p in _bucketParticles)
            if (p.massNumber == iso.massNumber) p.destination,
        ];
        final slot = SphereBucketLayout.firstOpenPosition(
          bucketPosition: bucketPos,
          bucketWidth: kMixBucketWidth,
          sphereRadius: kLargeIsotopeRadius,
          occupiedDestinations: occupied,
        );
        _bucketParticles.add(_createParticle(
          iso.massNumber,
          kLargeIsotopeRadius,
          slot.x,
          slot.y,
          MixParticleContainer.bucket,
        ));
      }
    }
  }

  // ---- Quantity APIs (Phase 5 + spatial sync) ----

  bool setIsotopeQuantity(int massNumber, int quantity) {
    if (_showingNaturesMix) return false;
    if (!_isPossibleMassNumber(massNumber)) return false;
    _cancelDrag();
    final target = quantity.clamp(0, kSliderCapacity);
    var current = getIsotopeCount(massNumber);
    if (target == current) return true;

    if (target > current) {
      final add = target - current;
      for (var i = 0; i < add; i++) {
        final pos = _randomChamberPosition();
        final p = _createParticle(
          massNumber,
          kSmallIsotopeRadius,
          pos.x,
          pos.y,
          MixParticleContainer.chamber,
        );
        _addToChamber(p, clampInside: true);
      }
    } else {
      final remove = current - target;
      for (var i = 0; i < remove; i++) {
        _removeMatchingFromChamber(massNumber);
      }
    }
    _notify();
    return true;
  }

  /// Count-level bucket→chamber (preserves Phase 5 API; picks last bucket atom).
  bool moveBucketToChamber(int massNumber) {
    if (_showingNaturesMix) return false;
    if (_interactivityMode != InteractivityMode.bucketsAndLargeAtoms) {
      return false;
    }
    MixParticle? pick;
    for (final p in _bucketParticles.reversed) {
      if (p.massNumber == massNumber) {
        pick = p;
        break;
      }
    }
    if (pick == null) return false;
    _removeFromBucket(pick, relayout: true);
    final pos = _randomChamberPosition();
    pick.placeAt(pos.x, pos.y);
    _addToChamber(pick, clampInside: true);
    _notify();
    return true;
  }

  bool moveChamberToBucket(int massNumber) {
    if (_showingNaturesMix) return false;
    if (_interactivityMode != InteractivityMode.bucketsAndLargeAtoms) {
      return false;
    }
    final p = _removeMatchingFromChamber(massNumber);
    if (p == null) return false;
    _addToBucketNearest(p);
    _notify();
    return true;
  }

  // ---- Drag contract ----

  /// Begin drag. ParticleView `applyOffset: false` → grab offset 0.
  bool beginDrag(int particleId, double pointerX, double pointerY) {
    if (_dragging != null || _showingNaturesMix) return false;
    final p = _findParticle(particleId);
    if (p == null) return false;
    if (p.container == MixParticleContainer.bucket) {
      _removeFromBucket(p, relayout: true);
    } else if (p.container == MixParticleContainer.chamber) {
      _chamberParticles.remove(p);
      p.container = null;
    } else {
      return false;
    }
    grabOffsetX = 0;
    grabOffsetY = 0;
    p.isDragging = true;
    p.placeAt(pointerX, pointerY);
    _dragging = p;
    _notify();
    return true;
  }

  bool updateDrag(double pointerX, double pointerY) {
    final p = _dragging;
    if (p == null) return false;
    p.placeAt(pointerX - grabOffsetX, pointerY - grabOffsetY);
    _notify();
    return true;
  }

  /// End drag: chamber if over rect, else return to matching bucket.
  /// Returns true if captured by chamber.
  bool endDrag() {
    final p = _dragging;
    if (p == null) return false;
    p.isDragging = false;
    _dragging = null;
    grabOffsetX = 0;
    grabOffsetY = 0;

    final captured = isParticleOverChamber(p);
    if (captured) {
      _addToChamber(p, clampInside: true);
      if (_interactivityMode == InteractivityMode.bucketsAndLargeAtoms &&
          totalIsotopeCount <= 100) {
        _adjustForOverlapLight();
      }
    } else {
      if (_interactivityMode == InteractivityMode.bucketsAndLargeAtoms) {
        _addToBucketNearest(p);
      } else {
        // Slider mode: invalid drop removes particle (not in PhET slider drag —
        // only bucket mode has PositionableAtom drag). Put back in chamber at
        // random to avoid count loss if somehow dragged.
        final pos = _randomChamberPosition();
        p.placeAt(pos.x, pos.y);
        _addToChamber(p, clampInside: true);
      }
    }
    _notify();
    return captured;
  }

  void _cancelDrag() {
    final p = _dragging;
    if (p == null) return;
    p.isDragging = false;
    _dragging = null;
    grabOffsetX = 0;
    grabOffsetY = 0;
    // Bucket mode only has PositionableAtom drag (PhET). Return to nearest bucket slot.
    // Slider: put back in chamber so quantity APIs don't lose the atom.
    if (_interactivityMode == InteractivityMode.bucketsAndLargeAtoms &&
        _isPossibleMassNumber(p.massNumber)) {
      _addToBucketNearest(p);
    } else if (_isPossibleMassNumber(p.massNumber)) {
      final pos = _randomChamberPosition();
      p.placeAt(pos.x, pos.y);
      _addToChamber(p, clampInside: true);
    }
  }

  MixParticle? _findParticle(int id) {
    for (final p in _chamberParticles) {
      if (p.id == id) return p;
    }
    for (final p in _bucketParticles) {
      if (p.id == id) return p;
    }
    if (_dragging?.id == id) return _dragging;
    return null;
  }

  void _addToChamber(MixParticle p, {required bool clampInside}) {
    if (clampInside) {
      _clampInsideChamber(p);
    }
    p.container = MixParticleContainer.chamber;
    p.isDragging = false;
    _chamberParticles.add(p);
  }

  void _clampInsideChamber(MixParticle p) {
    // IsotopeTestChamber.addParticle protrusion logic (BUFFER=1).
    const buffer = 1.0;
    var x = p.x;
    var y = p.y;
    var protrusion = x + p.radius - kTestChamberMaxX + buffer;
    if (protrusion >= 0) {
      x -= protrusion;
    } else {
      protrusion = kTestChamberMinX + buffer - (x - p.radius);
      if (protrusion >= 0) x += protrusion;
    }
    protrusion = y + p.radius - kTestChamberMaxY + buffer;
    if (protrusion >= 0) {
      y -= protrusion;
    } else {
      protrusion = kTestChamberMinY + buffer - (y - p.radius);
      if (protrusion >= 0) y += protrusion;
    }
    p.placeAt(x, y);
  }

  MixParticle? _removeMatchingFromChamber(int massNumber) {
    for (var i = _chamberParticles.length - 1; i >= 0; i--) {
      if (_chamberParticles[i].massNumber == massNumber) {
        final p = _chamberParticles.removeAt(i);
        p.container = null;
        return p;
      }
    }
    return null;
  }

  void _removeFromBucket(MixParticle p, {required bool relayout}) {
    final ok = _bucketParticles.remove(p);
    assert(ok);
    p.container = null;
    // Dangling relayout skipped for Mix simplicity — fillBuckets rebuilds on
    // mode/element; nearestOpen handles returns. (PhET relayouts on remove.)
  }

  void _addToBucketNearest(MixParticle p) {
    final idx = _isotopeIndex(p.massNumber);
    if (idx < 0) return;
    final bucketPos = bucketPositionForIndex(idx);
    final occupied = [
      for (final o in _bucketParticles)
        if (o.massNumber == p.massNumber) o.destination,
    ];
    final slot = SphereBucketLayout.nearestOpenPosition(
      preferred: p.destination,
      bucketPosition: bucketPos,
      bucketWidth: kMixBucketWidth,
      sphereRadius: kLargeIsotopeRadius,
      occupiedDestinations: occupied,
    );
    p.placeAt(slot.x, slot.y);
    p.container = MixParticleContainer.bucket;
    p.isDragging = false;
    _bucketParticles.add(p);
  }

  /// Lightweight overlap nudge (subset of IsotopeTestChamber.adjustForOverlap).
  void _adjustForOverlapLight() {
    const minDistFactor = 1.0;
    for (var iter = 0; iter < 40; iter++) {
      var overlapped = false;
      for (var i = 0; i < _chamberParticles.length; i++) {
        final a = _chamberParticles[i];
        for (var j = i + 1; j < _chamberParticles.length; j++) {
          final b = _chamberParticles[j];
          final minD = (a.radius + b.radius) * minDistFactor;
          final d = a.position.distanceTo(b.position);
          if (d < minD && d > 1e-9) {
            overlapped = true;
            final nx = (a.x - b.x) / d;
            final ny = (a.y - b.y) / d;
            final push = (minD - d) / 2;
            a.placeAt(a.x + nx * push, a.y + ny * push);
            b.placeAt(b.x - nx * push, b.y - ny * push);
            _clampInsideChamber(a);
            _clampInsideChamber(b);
          } else if (d <= 1e-9) {
            overlapped = true;
            a.placeAt(a.x + 0.5, a.y);
            _clampInsideChamber(a);
          }
        }
      }
      if (!overlapped) break;
    }
  }

  bool _isPossibleMassNumber(int massNumber) {
    return _possibleIsotopes.any((i) => i.massNumber == massNumber);
  }

  // ---- Clear / Reset ----

  void clearTestChamber() {
    if (_showingNaturesMix) {
      throw StateError("Nature's mix should not be showing when clearing");
    }
    _cancelDrag();
    _chamberParticles.clear();
    _savedStates[selectedAtomicNumber]?.remove(_interactivityMode);
    if (_interactivityMode == InteractivityMode.bucketsAndLargeAtoms) {
      _fillBuckets();
    }
    _notify();
  }

  void reset() {
    _cancelDrag();
    for (final map in _savedStates.values) {
      map.clear();
    }
    _savedStates.clear();
    _interactivityMode = InteractivityMode.bucketsAndLargeAtoms;
    _showingNaturesMix = false;
    final alreadyDefault = selectedAtomicNumber == kMixDefaultAtomicNumber;
    _clearAllParticles();
    if (!alreadyDefault) {
      _initForElement(kMixDefaultAtomicNumber);
    } else {
      _updatePossibleIsotopes(kMixDefaultAtomicNumber);
      _fillBuckets();
    }
    _notify();
  }

  // ---- Save / restore ----

  void _saveState(int atomicNumber, InteractivityMode mode) {
    final map = _savedStates.putIfAbsent(
      atomicNumber,
      () => <InteractivityMode, List<SavedMixParticle>>{},
    );
    if (_chamberParticles.isNotEmpty) {
      map[mode] = [
        for (final p in _chamberParticles)
          SavedMixParticle(
            massNumber: p.massNumber,
            x: p.x,
            y: p.y,
            radius: p.radius,
          ),
      ];
    } else {
      map.remove(mode);
    }
  }

  void _restoreState(int atomicNumber, InteractivityMode mode) {
    _chamberParticles.clear();
    final saved = _savedStates[atomicNumber]?[mode];
    if (saved == null) return;
    final radius = mode == InteractivityMode.bucketsAndLargeAtoms
        ? kLargeIsotopeRadius
        : kSmallIsotopeRadius;
    for (final s in saved) {
      _chamberParticles.add(_createParticle(
        s.massNumber,
        s.radius > 0 ? s.radius : radius,
        s.x,
        s.y,
        MixParticleContainer.chamber,
      ));
    }
  }

  MixturesSnapshot snapshot() {
    final counts = <int, int>{};
    for (final p in _chamberParticles) {
      counts[p.massNumber] = (counts[p.massNumber] ?? 0) + 1;
    }
    return MixturesSnapshot(
      atomicNumber: selectedAtomicNumber,
      interactivityMode: _interactivityMode,
      showingNaturesMix: _showingNaturesMix,
      chamberCounts: counts,
      totalCount: totalIsotopeCount,
      chamberAverage: chamberAverageAtomicMass,
      displayedAverage: displayedAverageAtomicMass,
    );
  }
}

class MixturesSnapshot {
  const MixturesSnapshot({
    required this.atomicNumber,
    required this.interactivityMode,
    required this.showingNaturesMix,
    required this.chamberCounts,
    required this.totalCount,
    required this.chamberAverage,
    required this.displayedAverage,
  });

  final int atomicNumber;
  final InteractivityMode interactivityMode;
  final bool showingNaturesMix;
  final Map<int, int> chamberCounts;
  final int totalCount;
  final double chamberAverage;
  final double displayedAverage;

  @override
  bool operator ==(Object other) {
    if (other is! MixturesSnapshot) return false;
    if (other.atomicNumber != atomicNumber ||
        other.interactivityMode != interactivityMode ||
        other.showingNaturesMix != showingNaturesMix ||
        other.totalCount != totalCount ||
        other.chamberAverage != chamberAverage ||
        other.displayedAverage != displayedAverage) {
      return false;
    }
    if (other.chamberCounts.length != chamberCounts.length) return false;
    for (final e in chamberCounts.entries) {
      if (other.chamberCounts[e.key] != e.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        atomicNumber,
        interactivityMode,
        showingNaturesMix,
        totalCount,
        chamberAverage,
        displayedAverage,
      );
}
