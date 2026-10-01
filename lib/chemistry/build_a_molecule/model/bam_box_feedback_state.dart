/// Collection-box success feedback (cue + blink).
/// Timing from CollectionBoxNode.blink() in PhET build-a-molecule.
class BamBoxFeedbackState {
  /// CollectionBoxNode: blinkLengthInSeconds = 1.3
  static const double blinkLengthSeconds = 1.3;

  /// CollectionBoxNode: blinkDelayInMs = 100
  static const int blinkDelayMs = 100;

  /// floor(1.3 * 1000 / 100) == 13
  static int get blinkTickCount =>
      (blinkLengthSeconds * 1000 / blinkDelayMs).floor();

  /// Cue arrow visible (CollectionBox.cueVisibilityProperty).
  bool cueVisible = false;

  /// Current blink frame: true → blue border (MOLECULE_COLLECTION_BOX_BORDER_BLINK).
  bool borderBlinkOn = false;

  /// True while a blink sequence is in progress.
  bool isBlinking = false;

  int _countsRemaining = 0;

  /// Start blink sequence (CollectionBoxNode.blink). Cancels any in-progress blink.
  void beginBlink() {
    cancelBlink();
    isBlinking = true;
    borderBlinkOn = false;
    _countsRemaining = blinkTickCount;
  }

  /// One timer tick (100ms). Returns whether another tick should be scheduled.
  ///
  /// PhET: decrement counts; if 0 restore graphics; else toggle on/off stroke.
  bool advanceTick() {
    if (!isBlinking) return false;
    _countsRemaining--;
    if (_countsRemaining <= 0) {
      isBlinking = false;
      borderBlinkOn = false;
      _countsRemaining = 0;
      return false;
    }
    borderBlinkOn = !borderBlinkOn;
    return true;
  }

  void cancelBlink() {
    isBlinking = false;
    _countsRemaining = 0;
    borderBlinkOn = false;
  }

  void reset() {
    cueVisible = false;
    cancelBlink();
  }
}
