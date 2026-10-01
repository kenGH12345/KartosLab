/// PhET `WOASModel.ts` — native Dart port (Phase 1).
///
/// Source: wave-on-a-string 1.3.0-dev.0
///
/// Data flow:
/// ```
/// controls / drive input
///   → step(dt) → soft-limit dt → (if playing) accumulate
///   → manualStep → FRAME_DURATION slices
///   → drive left end (Manual / Oscillate / Pulse)
///   → when timeElapsed >= minDt(tension, speed): evolve()
///   → rotate yLast ← yNow ← yNext
///   → yDraw (post-evolve copy of yLast, or interpolate)
/// ```
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../woas_constants.dart';
import 'woas_end_type.dart';
import 'woas_mode.dart';
import 'woas_stopwatch.dart';
import 'woas_time_speed.dart';

/// Native Wave on a String model — faithful to PhET `WOASModel`.
class WoasModel extends ChangeNotifier {
  WoasModel() {
    _yLast = Float64List(numberOfBeads);
    _yNow = Float64List(numberOfBeads);
    _yNext = Float64List(numberOfBeads);
    _yDraw = Float64List(numberOfBeads);
    stopwatch = WoasStopwatch();
    resetAll();
  }

  // ── Wave buffers (source: yLast / yNow / yNext / yDraw) ──────────────
  late Float64List _yLast;
  late Float64List _yNow;
  late Float64List _yNext;
  late Float64List _yDraw;

  /// Read-only draw positions (model units). Length = [numberOfBeads].
  List<double> get drawPositions => List<double>.unmodifiable(_yDraw);

  /// Bead count (always 61).
  int get beadCount => numberOfBeads;

  double yLastAt(int i) => _yLast[i];
  double yNowAt(int i) => _yNow[i];
  double yNextAt(int i) => _yNext[i];
  double yDrawAt(int i) => _yDraw[i];

  // ── Control / mode state ─────────────────────────────────────────────
  WoasMode _waveMode = WoasMode.manual;
  WoasEndType _stringEndType = WoasEndType.fixedEnd;
  bool isPlaying = true;
  WoasTimeSpeed timeSpeed = WoasTimeSpeed.normal;

  bool rulersVisible = false;
  bool referenceLineVisible = false;
  bool wrenchArrowsVisible = true;

  /// Horizontal ruler top-left (view coords) — source default `(VIEW_ORIGIN_X-14, 117)`.
  double horizontalRulerX = viewOriginX - 14;
  double horizontalRulerY = 117;

  /// Vertical ruler bottom-left — source default `(13, 440)`.
  double verticalRulerX = 13;
  double verticalRulerY = 440;

  /// Reference line left position — source default `(-10, 120)`.
  double referenceLineX = -10;
  double referenceLineY = 120;

  double tension = defaultTension;
  double damping = defaultDamping;
  double frequencyHz = defaultFrequencyHz;
  double pulseWidthS = defaultPulseWidthS;

  /// Oscillator / pulse amplitude in **centimeters** (source UI units).
  /// Drive: `amplitudeCm * modelUnitsPerCm` → model units.
  double amplitudeCm = defaultAmplitudeCm;

  late final WoasStopwatch stopwatch;

  /// Elapsed since last `evolve` (interpolation), seconds.
  double timeElapsed = 0;

  /// Soft dt limiter state (`lastDtProperty`, default 0.03).
  double lastDt = defaultLastDt;

  /// Oscillator / pulse phase angle (radians).
  double angle = 0;

  bool pulsePending = false;
  double pulseSign = 1;
  bool isPulseActive = false;

  /// Target left-end Y in model units (`nextLeftYProperty`).
  double nextLeftY = 0;

  /// Accumulated dt waiting for `FRAME_DURATION` (`stepDtProperty`).
  double stepDt = 0;

  /// True when string is approximately flat (`isStringStillProperty`).
  bool isStringStill = true;

  int _flatInARow = 0;

  /// Last computed evolve coefficients (for tests / diagnostics).
  double alpha = 1;
  double beta = 0.05;

  WoasMode get waveMode => _waveMode;
  WoasEndType get stringEndType => _stringEndType;

  /// Left-most bead Y in cm (source `leftMostBeadYProperty` map).
  double get leftMostBeadYCm => -nextLeftY / modelUnitsPerCm;

  // ── Setters that mirror source lazyLink side-effects ─────────────────

  /// Source `waveModeProperty` — changing mode calls `manualRestart`.
  void setWaveMode(WoasMode mode) {
    if (mode == _waveMode) return;
    _waveMode = mode;
    restart();
    notifyListeners();
  }

  /// Source `stringEndTypeProperty` — switching to Fixed zeros endpoint.
  void setStringEndType(WoasEndType endType) {
    if (endType == _stringEndType) return;
    _stringEndType = endType;
    if (endType == WoasEndType.fixedEnd) {
      zeroOutEndPoint();
    } else {
      notifyListeners();
    }
  }

  void setTension(double value) {
    tension = value.clamp(tensionMin, tensionMax);
    notifyListeners();
  }

  void setDamping(double value) {
    damping = value.clamp(dampingMin, dampingMax);
    notifyListeners();
  }

  void setFrequencyHz(double value) {
    frequencyHz = value.clamp(frequencyMinHz, frequencyMaxHz);
    notifyListeners();
  }

  void setPulseWidthS(double value) {
    pulseWidthS = value.clamp(pulseWidthMinS, pulseWidthMaxS);
    notifyListeners();
  }

  void setAmplitudeCm(double value) {
    amplitudeCm = value.clamp(amplitudeMinCm, maxStartAmplitudeCm);
    notifyListeners();
  }

  void setPlaying(bool playing) {
    isPlaying = playing;
    notifyListeners();
  }

  void setTimeSpeed(WoasTimeSpeed speed) {
    timeSpeed = speed;
    notifyListeners();
  }

  void setRulersVisible(bool visible) {
    rulersVisible = visible;
    notifyListeners();
  }

  void setReferenceLineVisible(bool visible) {
    referenceLineVisible = visible;
    notifyListeners();
  }

  void setReferenceLineY(double y) {
    referenceLineY = y;
    notifyListeners();
  }

  void setStopwatchVisible(bool visible) {
    stopwatch.isVisible = visible;
    notifyListeners();
  }

  /// Manual wrench displacement in model units (`nextLeftYProperty`).
  ///
  /// Clamped to `± maxStartAmplitudeCm * modelUnitsPerCm`.
  /// Source wrench drag also forces `isPlaying = true`.
  void setManualDisplacement(double modelY, {bool resumePlayback = true}) {
    final maxY = maxStartAmplitudeCm * modelUnitsPerCm;
    nextLeftY = modelY.clamp(-maxY, maxY);
    if (resumePlayback) {
      isPlaying = true;
    }
    wrenchArrowsVisible = false;
    _notifyWaveChanged();
  }

  /// Convenience: set manual displacement from centimeters (source leftMostBeadY).
  void setManualDisplacementCm(double cm, {bool resumePlayback = true}) {
    setManualDisplacement(-cm * modelUnitsPerCm, resumePlayback: resumePlayback);
  }

  /// Source `manualPulse()`.
  void triggerPulse() {
    _yNow[0] = 0;
    angle = 0;
    pulseSign = 1;
    pulsePending = true;
    isPulseActive = false;
    notifyListeners();
  }

  // ── Clock ────────────────────────────────────────────────────────────

  /// Source `WOASModel.step(dt)`.
  void step(double dt) {
    // Soft-limit: if |dt - lastDt| > 0.3 * lastDt, move at most 30% toward new dt.
    if ((dt - lastDt).abs() > lastDt * 0.3) {
      dt = lastDt + ((dt - lastDt) < 0 ? -1 : 1) * lastDt * 0.3;
    }
    lastDt = dt;

    if (isPlaying) {
      stepDt += dt;
      if (stepDt >= frameDuration) {
        manualStep(stepDt);
        stepDt %= frameDuration;
      }
    }

    // Source always syncs nextLeftY ← yNow[0] at end of step.
    nextLeftY = _yNow[0];
  }

  /// Source `manualStep(dt?)` — FRAME_DURATION subdivision + drive + evolve.
  void manualStep([double? dtIn]) {
    var dt = (dtIn != null && dtIn > 0) ? dtIn : frameDuration;
    final speedMultiplier = timeSpeed.speedMultiplier;

    final startingLeftY = _yNow[0];
    final numSteps = (dt / frameDuration).floor();
    final perStepDelta =
        numSteps != 0 ? ((nextLeftY - startingLeftY) / numSteps) : 0.0;

    final minDt = minDtFor(tension: tension, speedMultiplier: speedMultiplier);

    while (dt >= frameDuration) {
      timeElapsed += frameDuration;
      stopwatch.step(frameDuration * speedMultiplier);

      if (_waveMode == WoasMode.oscillate) {
        angle = (angle +
                math.pi * 2 * frequencyHz * frameDuration * speedMultiplier) %
            (math.pi * 2);
        final y0 = amplitudeCm * modelUnitsPerCm * math.sin(-angle);
        _yDraw[0] = y0;
        _yNow[0] = y0;
      }

      if (_waveMode == WoasMode.pulse && pulsePending) {
        pulsePending = false;
        isPulseActive = true;
        _yNow[0] = 0;
      }

      if (_waveMode == WoasMode.pulse && isPulseActive) {
        final da = math.pi * frameDuration * speedMultiplier / pulseWidthS;
        if (angle + da >= math.pi / 2) {
          pulseSign = -1;
        }
        if (angle + da * pulseSign > 0) {
          angle = angle + da * pulseSign;
        } else {
          angle = 0;
          pulseSign = 1;
          isPulseActive = false;
        }
        final y0 = amplitudeCm *
            modelUnitsPerCm *
            (-angle / (math.pi / 2));
        _yDraw[0] = y0;
        _yNow[0] = y0;
      }

      if (_waveMode == WoasMode.manual) {
        _yNow[0] += perStepDelta;
      }

      if (timeElapsed >= minDt) {
        timeElapsed = timeElapsed % minDt;
        evolve();
        for (var i = 0; i < numberOfBeads; i++) {
          _yDraw[i] = _yLast[i];
        }
      } else {
        for (var i = 1; i < numberOfBeads; i++) {
          _yDraw[i] = _yLast[i] +
              ((_yNow[i] - _yLast[i]) * (timeElapsed / minDt));
        }
      }

      dt -= frameDuration;
    }

    _notifyWaveChanged();
  }

  /// Source `evolve()` — α=1 damped central-difference update + boundary.
  void evolve() {
    const dt = 1.0;
    const v = 1.0;
    const dx = dt * v;
    final b = damping * 0.2;

    beta = b * dt / 2; // = damping * 0.1
    alpha = v * dt / dx; // = 1

    _yNext[0] = _yNow[0];

    switch (_stringEndType) {
      case WoasEndType.fixedEnd:
        _yNow[lastIndex] = 0;
      case WoasEndType.looseEnd:
        _yNow[lastIndex] = _yNow[nextToLastIndex];
      case WoasEndType.noEnd:
        _yNow[lastIndex] = _yLast[nextToLastIndex];
    }

    final a = 1 / (beta + 1);
    final alphaSq = alpha * alpha;
    final c = 2 * (1 - alphaSq);

    for (var i = 1; i < lastIndex; i++) {
      _yNext[i] = a *
          ((beta - 1) * _yLast[i] +
              c * _yNow[i] +
              alphaSq * (_yNow[i + 1] + _yNow[i - 1]));
    }

    final oldNow = _yNow[lastIndex];
    final oldNext = _yNext[lastIndex];

    // Rotate array references (source: yLast ← yNow ← yNext ← old yLast).
    final oldArray = _yLast;
    _yLast = _yNow;
    _yNow = _yNext;
    _yNext = oldArray;

    _yNext[lastIndex] = oldNext;

    switch (_stringEndType) {
      case WoasEndType.fixedEnd:
        _yLast[lastIndex] = 0;
        _yNow[lastIndex] = 0;
      case WoasEndType.looseEnd:
        _yLast[lastIndex] = oldNow;
        _yNow[lastIndex] = _yNow[nextToLastIndex];
      case WoasEndType.noEnd:
        _yLast[lastIndex] = oldNow;
        _yNow[lastIndex] = _yLast[nextToLastIndex];
    }
  }

  /// Source `zeroOutEndPoint()`.
  void zeroOutEndPoint() {
    _yNow[lastIndex] = 0;
    _yDraw[lastIndex] = 0;
    _notifyWaveChanged();
  }

  /// Source `manualRestart()` — clears wave / phase / pulse; keeps controls.
  void restart() {
    angle = 0;
    timeElapsed = 0;
    isPulseActive = false;
    pulseSign = 1;
    pulsePending = false;

    for (var i = 0; i < numberOfBeads; i++) {
      _yDraw[i] = 0;
      _yNext[i] = 0;
      _yNow[i] = 0;
      _yLast[i] = 0;
    }

    nextLeftY = 0;
    _flatInARow = 0;
    isStringStill = true;
    _notifyWaveChanged();
  }

  /// Source `reset()` — Reset All.
  void resetAll() {
    _waveMode = WoasMode.manual;
    _stringEndType = WoasEndType.fixedEnd;
    timeSpeed = WoasTimeSpeed.normal;
    rulersVisible = false;
    referenceLineVisible = false;
    tension = defaultTension;
    damping = defaultDamping;
    frequencyHz = defaultFrequencyHz;
    pulseWidthS = defaultPulseWidthS;
    amplitudeCm = defaultAmplitudeCm;
    isPlaying = true;
    lastDt = defaultLastDt;
    horizontalRulerX = viewOriginX - 14;
    horizontalRulerY = 117;
    verticalRulerX = 13;
    verticalRulerY = 440;
    referenceLineX = -10;
    referenceLineY = 120;
    stopwatch.reset();
    wrenchArrowsVisible = true;
    stepDt = 0;
    restart();
  }

  // ── Test / diagnostic helpers ────────────────────────────────────────

  /// Seed bead buffers for numeric fixtures (does not notify).
  @visibleForTesting
  void debugSeedBead({
    required int index,
    double? yLast,
    double? yNow,
    double? yNext,
    double? yDraw,
  }) {
    assert(index >= 0 && index < numberOfBeads);
    if (yLast != null) _yLast[index] = yLast;
    if (yNow != null) _yNow[index] = yNow;
    if (yNext != null) _yNext[index] = yNext;
    if (yDraw != null) _yDraw[index] = yDraw;
  }

  @visibleForTesting
  void debugFillAll(double value) {
    for (var i = 0; i < numberOfBeads; i++) {
      _yLast[i] = value;
      _yNow[i] = value;
      _yNext[i] = value;
      _yDraw[i] = value;
    }
  }

  void _notifyWaveChanged() {
    _updateStringStill();
    notifyListeners();
  }

  /// Source `yNowChangedEmitter` flatness heuristic.
  void _updateStringStill() {
    const tolerance = 1e-2;
    const immediateTolerance = 1e-4;

    final start = _yNow[0];
    final end = _yNow[lastIndex];

    var isFlat = true;
    var isImmediateFlat = true;

    for (var i = 1; i < lastIndex; i++) {
      final flatY = linearMap(0, lastIndex.toDouble(), start, end, i.toDouble());
      final delta = (_yNow[i] - flatY).abs();
      if (delta > immediateTolerance) {
        isImmediateFlat = false;
      }
      if (delta > tolerance) {
        isFlat = false;
        break;
      }
    }

    if (isFlat) {
      _flatInARow++;
    } else {
      _flatInARow = 0;
    }

    isStringStill =
        isImmediateFlat || (isFlat && _flatInARow >= flatInARowForStill);
  }
}
