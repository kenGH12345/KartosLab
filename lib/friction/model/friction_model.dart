import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:flutter/foundation.dart';

import '../friction_constants.dart';
import 'atom.dart';

/// One schema entry in a book atom layer (from FrictionModel.js).
class AtomLayerSchema {
  const AtomLayerSchema({
    this.offset = 0,
    required this.num,
    this.canShearOff = false,
  });

  final double offset;
  final int num;
  final bool canShearOff;
}

/// Port of PhET `FrictionModel.js`.
class FrictionModel extends ChangeNotifier {
  FrictionModel({
    this.width = FrictionConstants.layoutWidth,
    this.height = FrictionConstants.layoutHeight,
    math.Random? random,
  }) : _random = random ?? math.Random() {
    _buildAtoms();
    _topBookDragBounds = Rect.fromLTRB(
      -FrictionConstants.maxXDisplacement,
      FrictionConstants.minYPosition,
      FrictionConstants.maxXDisplacement,
      _distanceBetweenBooks,
    );
  }

  final double width;
  final double height;
  final math.Random _random;

  // --- Layer structures (exact PhET TOP/BOTTOM_BOOK_ATOM_STRUCTURE) ---

  static const List<List<AtomLayerSchema>> topBookAtomStructure = [
    [AtomLayerSchema(num: 30)],
    [AtomLayerSchema(offset: 0.5, num: 29, canShearOff: true)],
    [AtomLayerSchema(num: 29, canShearOff: true)],
    [
      AtomLayerSchema(offset: 0.5, num: 5, canShearOff: true),
      AtomLayerSchema(offset: 6.5, num: 8, canShearOff: true),
      AtomLayerSchema(offset: 15.5, num: 5, canShearOff: true),
      AtomLayerSchema(offset: 21.5, num: 5, canShearOff: true),
      AtomLayerSchema(offset: 27.5, num: 1, canShearOff: true),
    ],
    [
      AtomLayerSchema(offset: 3, num: 2, canShearOff: true),
      AtomLayerSchema(offset: 8, num: 1, canShearOff: true),
      AtomLayerSchema(offset: 12, num: 2, canShearOff: true),
      AtomLayerSchema(offset: 17, num: 2, canShearOff: true),
      AtomLayerSchema(offset: 24, num: 2, canShearOff: true),
    ],
  ];

  static const List<List<AtomLayerSchema>> bottomBookAtomStructure = [
    [AtomLayerSchema(num: 29)],
    [AtomLayerSchema(offset: 0.5, num: 28)],
    [AtomLayerSchema(num: 29)],
  ];

  static int get numberOfShearableAtoms {
    var n = 0;
    for (final row in topBookAtomStructure) {
      for (final s in row) {
        if (s.canShearOff) n += s.num;
      }
    }
    return n;
  }

  // --- State ---

  double _vibrationAmplitude = FrictionConstants.vibrationAmplitudeMin;
  Offset _topBookPosition = Offset.zero;
  double _distanceBetweenBooks = FrictionConstants.initialAtomSpacingYBooks;
  late Rect _topBookDragBounds;
  int _atomRowsToShearOff = topBookAtomStructure.length - 1;
  bool _hint = true;
  bool _successfullyInteractedWith = false;
  int _numberOfAtomsShearedOff = 0;
  double _scheduledShearingAmount = 0;

  final List<FrictionAtom> atoms = [];
  final List<List<FrictionAtom>> shearableAtomsByRow = [];

  /// Fired when an atom shears off (for audio).
  VoidCallback? onShearedOff;

  /// Fired when contact transitions false→true (for contact sound).
  VoidCallback? onContactStarted;

  bool _wasInContact = false;

  // --- Getters ---

  double get vibrationAmplitude => _vibrationAmplitude;
  Offset get topBookPosition => _topBookPosition;
  double get distanceBetweenBooks => _distanceBetweenBooks;
  Rect get topBookDragBounds => _topBookDragBounds;
  int get atomRowsToShearOff => _atomRowsToShearOff;
  bool get hint => _hint;
  bool get successfullyInteractedWith => _successfullyInteractedWith;
  int get numberOfAtomsShearedOff => _numberOfAtomsShearedOff;

  bool get contact => _distanceBetweenBooks.floor() <= 0;

  double get bookDraggingScaleFactor =>
      FrictionConstants.bookDraggingScaleFactor;

  double get thermometerFraction {
    final t = _vibrationAmplitude;
    final minT = FrictionConstants.thermometerMinTemp;
    final maxT = FrictionConstants.thermometerMaxTemp;
    return ((t - minT) / (maxT - minT)).clamp(0.0, 1.0);
  }

  // --- Mutations ---

  void setTopBookPosition(Offset next, {double? heatingDistanceX}) {
    final clamped = Offset(
      next.dx.clamp(_topBookDragBounds.left, _topBookDragBounds.right),
      next.dy.clamp(_topBookDragBounds.top, _topBookDragBounds.bottom),
    );
    _applyTopBookPosition(clamped, heatingDistanceX: heatingDistanceX);
  }

  /// Apply a model-space delta (used by drag / keyboard).
  ///
  /// [heatingDistanceX] overrides `|delta.x|` for friction heating only.
  /// Macro book drag uses a small position delta (gentle atom motion) but
  /// passes PhET-amplified distance so temperature / shear stay correct.
  void moveTopBookBy(Offset delta, {double? heatingDistanceX}) {
    setTopBookPosition(
      _topBookPosition + delta,
      heatingDistanceX: heatingDistanceX,
    );
  }

  void _applyTopBookPosition(Offset newPosition, {double? heatingDistanceX}) {
    final oldPosition = _topBookPosition;
    if (newPosition == oldPosition && heatingDistanceX == null) return;

    _hint = false;
    final delta = newPosition - oldPosition;
    _topBookPosition = newPosition;

    if (delta != Offset.zero) {
      for (final atom in atoms) {
        atom.onTopBookMoved(delta);
      }
      _distanceBetweenBooks -= delta.dy;
    }

    final nowContact = contact;
    if (nowContact && !_wasInContact) {
      onContactStarted?.call();
    }
    _wasInContact = nowContact;

    if (nowContact) {
      final dx = heatingDistanceX ?? delta.dx.abs();
      if (dx > 0) {
        final newValue =
            _vibrationAmplitude + dx * FrictionConstants.heatingMultiplier;
        _vibrationAmplitude =
            math.min(newValue, FrictionConstants.vibrationAmplitudeMax);
        _checkSuccessfulInteraction();
        if (_vibrationAmplitude > FrictionConstants.amplitudeShearOff) {
          tryToShearOff();
        }
      }
    }

    notifyListeners();
  }

  void _checkSuccessfulInteraction() {
    if (!_successfullyInteractedWith &&
        _vibrationAmplitude > FrictionConstants.amplitudeSettledThreshold) {
      _successfullyInteractedWith = true;
    }
  }

  void step(double dt) {
    if (dt <= 0) return;

    for (final atom in atoms) {
      atom.step(dt, _random);
    }

    // Cool (and apply pending shear-off cooling from prior frame).
    var amplitude = _vibrationAmplitude - _scheduledShearingAmount;
    amplitude = math.max(
      FrictionConstants.vibrationAmplitudeMin,
      amplitude * (1 - dt * FrictionConstants.coolingRate),
    );
    _vibrationAmplitude = amplitude;
    _scheduledShearingAmount = 0;

    // PhET: vibrationAmplitudeProperty.link → tryToShearOff whenever amp > limit.
    // Fires every step while hot (not only on drag), so atoms rapidly break away.
    if (_vibrationAmplitude > FrictionConstants.amplitudeShearOff) {
      tryToShearOff();
    }

    notifyListeners();
  }

  void tryToShearOff() {
    if (_atomRowsToShearOff <= 0) return;

    final currentRow = shearableAtomsByRow[_atomRowsToShearOff - 1];
    if (currentRow.isEmpty) return;

    final notYet = currentRow.where((a) => !a.isShearedOff).toList();
    if (notYet.isEmpty) return;

    final atom = notYet[_random.nextInt(notYet.length)];
    atom.shearOff(_random);
    _numberOfAtomsShearedOff += 1;
    onShearedOff?.call();
    _scheduledShearingAmount += FrictionConstants.shearOffAmplitudeReduction;

    final fullySheared = currentRow.every((a) => a.isShearedOff);
    if (fullySheared) {
      _atomRowsToShearOff -= 1;
      _distanceBetweenBooks += FrictionConstants.initialAtomSpacingY;
      _topBookDragBounds = Rect.fromLTRB(
        _topBookDragBounds.left,
        _topBookDragBounds.top,
        _topBookDragBounds.right,
        _topBookDragBounds.bottom + FrictionConstants.initialAtomSpacingY,
      );
    }
  }

  void hideHint() {
    if (!_hint) return;
    _hint = false;
    notifyListeners();
  }

  void reset() {
    _vibrationAmplitude = FrictionConstants.vibrationAmplitudeMin;
    _topBookPosition = Offset.zero;
    _distanceBetweenBooks = FrictionConstants.initialAtomSpacingYBooks;
    _topBookDragBounds = Rect.fromLTRB(
      -FrictionConstants.maxXDisplacement,
      FrictionConstants.minYPosition,
      FrictionConstants.maxXDisplacement,
      _distanceBetweenBooks,
    );
    _atomRowsToShearOff = topBookAtomStructure.length - 1;
    _successfullyInteractedWith = false;
    _hint = true;
    _numberOfAtomsShearedOff = 0;
    _scheduledShearingAmount = 0;
    _wasInContact = false;
    for (final atom in atoms) {
      atom.reset();
    }
    notifyListeners();
  }

  void _buildAtoms() {
    final magH = FrictionConstants.magnifierWindowHeight;
    final dist = FrictionConstants.initialAtomSpacingYBooks;
    final spacingY = FrictionConstants.atomSpacingY;

    for (var i = 0; i < topBookAtomStructure.length; i++) {
      _addAtomRow(
        topBookAtomStructure[i],
        FrictionConstants.defaultRowStartX,
        magH / 3 - dist + spacingY * i,
        isTopAtom: true,
      );
    }

    for (var i = 0; i < bottomBookAtomStructure.length; i++) {
      _addAtomRow(
        bottomBookAtomStructure[i],
        FrictionConstants.defaultRowStartX,
        2 * magH / 3 + spacingY * i,
        isTopAtom: false,
      );
    }
  }

  void _addAtomRow(
    List<AtomLayerSchema> layerDescription,
    double rowStartX,
    double rowYPos, {
    required bool isTopAtom,
  }) {
    var canShearOff = false;
    final shearableRow = <FrictionAtom>[];

    for (final schema in layerDescription) {
      canShearOff = schema.canShearOff;
      for (var n = 0; n < schema.num; n++) {
        final atom = FrictionAtom(
          initialPosition: Offset(
            rowStartX +
                (schema.offset + n) * FrictionConstants.initialAtomSpacingX,
            rowYPos,
          ),
          model: this,
          isTopAtom: isTopAtom,
        );
        atoms.add(atom);
        if (canShearOff) {
          shearableRow.add(atom);
        }
      }
    }
    if (canShearOff) {
      shearableAtomsByRow.add(shearableRow);
    }
  }
}
