import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import '../model/bam_atom.dart';
import '../model/bam_collection_box.dart';
import '../model/bam_kit.dart';
import '../model/bam_kit_collection.dart';
import '../model/bam_molecule.dart';
import '../model/bam_screen_model.dart';
import 'bam_collection_feedback_driver.dart';

/// ChangeNotifier wrapping BamScreenModel + drag interactions + collection feedback.
class BamController extends ChangeNotifier {
  BamController(this.model) {
    _feedbackDriver = BamCollectionFeedbackDriver(onChanged: notifyListeners);
    _wireCurrentCollection();
  }

  final BamScreenModel model;
  late final BamCollectionFeedbackDriver _feedbackDriver;

  BamPlayAtom? _draggingAtom;
  BamMolecule? _draggingMolecule;
  Offset _grabOffset = Offset.zero;
  bool _fromBucket = false;

  BamKitCollection get collection => model.currentCollection;
  BamKit? get kit => model.currentKit;
  BamPlayAtom? get draggingAtom => _draggingAtom;
  bool get draggingFromBucket => _fromBucket;
  BamCollectionFeedbackDriver get feedbackDriver => _feedbackDriver;

  void _wireCurrentCollection() {
    final c = collection;
    c.onCueOrFeedbackChanged = notifyListeners;
    c.wireAcceptedCreationListeners((box, molecule) {
      _feedbackDriver.onAcceptedMoleculeCreation(box, molecule);
    });
  }

  void _clearFeedbackForScreenSwitch() {
    _feedbackDriver.cancel(restoreActive: true);
    for (final box in collection.collectionBoxes) {
      box.feedback.cancelBlink();
    }
  }

  /// Start dragging an atom already in the play area (moves whole molecule).
  void startDragAtom(BamPlayAtom atom, {Offset? pointer}) {
    final k = kit;
    if (k == null) return;
    _draggingAtom = atom;
    atom.dragging = true;
    _draggingMolecule = k.getMolecule(atom);
    k.selectedAtom = atom;
    _grabOffset = Offset.zero;
    if (pointer != null) {
      if (_draggingMolecule != null && _draggingMolecule!.atoms.length > 1) {
        _draggingMolecule!.shiftPositionAndDestination(pointer - atom.position);
      } else {
        atom.setPositionAndDestination(pointer);
      }
    }
    notifyListeners();
  }

  /// Lift an atom from a kit bowl. It stays out of play until dropped on the
  /// canvas (PhET drag-from-bucket, not tap-to-spawn).
  void startDragFromBucket(BamPlayAtom atom, Offset worldPosition) {
    final k = kit;
    if (k == null) return;
    if (k.isContainedInBucket(atom)) {
      k.getBucketForElement(atom.element).removeParticle(atom);
    }
    _fromBucket = true;
    _draggingAtom = atom;
    atom.dragging = true;
    atom.setPositionAndDestination(worldPosition);
    k.selectedAtom = atom;
    _grabOffset = Offset.zero;
    notifyListeners();
  }

  void updateDrag(Offset worldPosition) {
    final atom = _draggingAtom;
    final molecule = _draggingMolecule;
    if (atom == null) return;
    final target = worldPosition - _grabOffset;

    if (molecule != null && molecule.atoms.length > 1) {
      final delta = target - atom.position;
      molecule.shiftPositionAndDestination(delta);
    } else {
      atom.setPositionAndDestination(target);
    }
    notifyListeners();
  }

  void endDrag(Offset worldPosition, {bool? droppedOnPlay}) {
    final atom = _draggingAtom;
    final k = kit;
    if (atom == null || k == null) {
      _clearDrag();
      notifyListeners();
      return;
    }
    atom.dragging = false;

    final onPlay = droppedOnPlay ??
        !model.collectionLayout.isInKitArea(worldPosition);

    if (_fromBucket && !onPlay) {
      k.recycleAtomIntoBuckets(atom, animate: false);
      _clearDrag();
      notifyListeners();
      return;
    }

    if (_fromBucket) {
      k.addAtomToPlay(atom);
    }

    if (collection.tryDropIntoCollectionBox(atom)) {
      _clearDrag();
      notifyListeners();
      return;
    }

    k.atomDropped(atom, droppedInKitArea: !onPlay);
    _clearDrag();
    notifyListeners();
  }

  /// Pointer released without leaving the kit (tap). Atom goes back in the bowl.
  void cancelDragToBucket() {
    final atom = _draggingAtom;
    final k = kit;
    if (atom == null || k == null) {
      _clearDrag();
      notifyListeners();
      return;
    }
    atom.dragging = false;
    final molecule = k.getMolecule(atom);
    if (molecule != null) {
      k.recycleMoleculeIntoBuckets(molecule);
    } else {
      k.recycleAtomIntoBuckets(atom);
    }
    _clearDrag();
    notifyListeners();
  }

  void _clearDrag() {
    _draggingAtom = null;
    _draggingMolecule = null;
    _grabOffset = Offset.zero;
    _fromBucket = false;
    kit?.selectedAtom = null;
  }

  void refill() {
    kit?.refill();
    notifyListeners();
  }

  /// Reset kits + boxes for current collection only (CollectionArea RefreshButton).
  void resetCollection() {
    _feedbackDriver.cancel(restoreActive: true);
    collection.resetKitsAndBoxes();
    notifyListeners();
  }

  void reset() {
    _feedbackDriver.cancel(restoreActive: true);
    model.reset();
    _wireCurrentCollection();
    notifyListeners();
  }

  void nextKit() {
    collection.selectNextKit();
    notifyListeners();
  }

  void previousKit() {
    collection.selectPreviousKit();
    notifyListeners();
  }

  void nextCollection() {
    if (model.hasNextCollection()) {
      _clearFeedbackForScreenSwitch();
      model.switchToNextCollection();
      _wireCurrentCollection();
      notifyListeners();
    }
  }

  void previousCollection() {
    if (model.hasPreviousCollection()) {
      _clearFeedbackForScreenSwitch();
      model.switchToPreviousCollection();
      _wireCurrentCollection();
      notifyListeners();
    }
  }

  void regenerateCollection() {
    _clearFeedbackForScreenSwitch();
    model.regenerate();
    _wireCurrentCollection();
    notifyListeners();
  }

  void breakBond(BamAtom a, BamAtom b) {
    kit?.breakBond(a, b);
    notifyListeners();
  }

  void breakMolecule(BamMolecule molecule) {
    kit?.breakMolecule(molecule);
    notifyListeners();
  }

  /// Collect first matching molecule into [box] (UI convenience).
  bool collectIntoBox(BamCollectionBox box) {
    final k = kit;
    if (k == null) return false;
    for (final m in List.of(k.molecules)) {
      if (box.willAllowMoleculeDrop(m)) {
        k.moleculePutInCollectionBox(m, box);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Hit-test play atoms (largest radius first).
  BamPlayAtom? hitTestPlayAtom(Offset world) {
    final k = kit;
    if (k == null) return null;
    BamPlayAtom? best;
    var bestR = -1.0;
    for (final atom in k.atomsInPlayArea) {
      if (!atom.visible) continue;
      final d = (atom.position - world).distance;
      // Visual atoms are ~0.62 px/pm; MVT is ~0.3, so hit ball is larger than covalent.
      final hitR = atom.covalentRadius * 2.2;
      if (d <= hitR && hitR > bestR) {
        best = atom;
        bestR = hitR;
      }
    }
    return best;
  }

  BamPlayAtom? hitTestBucketAtom(Offset world) {
    final k = kit;
    if (k == null) return null;
    for (final bucket in k.buckets) {
      for (final atom in bucket.particleList) {
        final d = (atom.position - world).distance;
        if (d <= atom.covalentRadius) return atom;
      }
    }
    return null;
  }

  /// Nearest bond within [threshold] of [world] (model units).
  ({BamPlayAtom a, BamPlayAtom b})? hitTestBond(
    Offset world, {
    double threshold = 40,
  }) {
    final k = kit;
    if (k == null) return null;
    ({BamPlayAtom a, BamPlayAtom b})? best;
    var bestDist = threshold;
    for (final molecule in k.molecules) {
      for (final bond in molecule.bonds) {
        final a = bond.a as BamPlayAtom;
        final b = bond.b as BamPlayAtom;
        if (!a.visible || !b.visible) continue;
        final d = _distanceToSegment(world, a.position, b.position);
        if (d < bestDist) {
          bestDist = d;
          best = (a: a, b: b);
        }
      }
    }
    return best;
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 < 1e-9) return (p - a).distance;
    var t = ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2;
    t = t.clamp(0.0, 1.0);
    final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (p - proj).distance;
  }

  @override
  void dispose() {
    _feedbackDriver.dispose();
    collection.onCueOrFeedbackChanged = null;
    super.dispose();
  }
}
