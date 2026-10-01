import 'dart:async';

import '../model/bam_collection_box.dart';
import '../model/bam_box_feedback_state.dart';
import '../model/bam_molecule.dart';

/// Schedules CollectionBoxNode.blink ticks. Owned by BamController.
///
/// Model emits acceptedMoleculeCreation → this starts FeedbackState blink →
/// onChanged → View reads borderBlinkOn / cueVisible.
class BamCollectionFeedbackDriver {
  BamCollectionFeedbackDriver({required this.onChanged});

  final void Function() onChanged;

  Timer? _timer;
  BamCollectionBox? _activeBox;

  void onAcceptedMoleculeCreation(BamCollectionBox box, BamMolecule molecule) {
    beginBlink(box, schedule: true);
  }

  void beginBlink(BamCollectionBox box, {bool schedule = true}) {
    cancel(restoreActive: true);
    box.feedback.beginBlink();
    _activeBox = box;
    onChanged();
    if (schedule) {
      _timer = Timer.periodic(
        const Duration(milliseconds: BamBoxFeedbackState.blinkDelayMs),
        (_) => step(),
      );
    }
  }

  /// Advance one blink frame (also used by tests without wall clock).
  void step() {
    final box = _activeBox;
    if (box == null) return;
    final cont = box.feedback.advanceTick();
    onChanged();
    if (!cont) {
      _timer?.cancel();
      _timer = null;
      _activeBox = null;
    }
  }

  /// Interrupt blinking (CollectionBoxNode.cancelBlinksInProgress).
  void cancel({bool restoreActive = true}) {
    _timer?.cancel();
    _timer = null;
    if (restoreActive && _activeBox != null) {
      _activeBox!.feedback.cancelBlink();
    }
    _activeBox = null;
  }

  void dispose() => cancel(restoreActive: true);
}
