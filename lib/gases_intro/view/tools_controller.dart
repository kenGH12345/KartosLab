import 'package:flutter/material.dart';

import '../model/ideal_gas_law_model.dart';

/// View-layer tool state (positions + stopwatch/collision counter UI).
///
/// Evidence:
/// - scenery-phet `Stopwatch` / gas-properties `GasPropertiesStopwatchNode`
/// - gas-properties `CollisionCounter` / `CollisionCounterNode`
///
/// Positions are **View** state (not Physics). Timing/counting mirrors PhET tool
/// models without editing IdealGasLawModel solvers — advances on sim steps by
/// reading [IdealGasLawModel.stopwatchPs] deltas + wall-collision frame counts.
class ToolsController extends ChangeNotifier {
  ToolsController();

  // —— Initial positions (view coords) ——
  // BaseModel stopwatchPosition (240, 15)
  // IdealGasLawModel CollisionCounter position (40, 15)
  static const Offset stopwatchHome = Offset(240, 15);
  static const Offset collisionHome = Offset(40, 15);

  static const double maxTimePs = 999.99; // GasPropertiesConstants.MAX_TIME
  static const List<int> samplePeriods = [5, 10, 20];

  Offset stopwatchPosition = stopwatchHome;
  Offset collisionPosition = collisionHome;

  bool stopwatchRunning = false;
  double stopwatchTimePs = 0;

  bool collisionRunning = false;
  int numberOfCollisions = 0;
  double _collisionTimeRunning = 0;
  int samplePeriodPs = 10; // default samplePeriods[1]

  /// Which tool is painted on top (moveToFront).
  ToolKind? frontTool;

  double _prevModelStopwatchPs = 0;
  bool _prevStopwatchVisible = false;
  bool _prevCollisionVisible = false;

  /// Approximate tool sizes for drag-bounds (content fits inside).
  static const Size stopwatchSize = Size(168, 92);
  static const Size collisionSize = Size(200, 168);

  void bringToFront(ToolKind kind) {
    if (frontTool == kind) return;
    frontTool = kind;
    notifyListeners();
  }

  void dragStopwatch(Offset physicalDelta, Rect logicalBounds, double layoutScale) {
    final s = layoutScale <= 0 ? 1.0 : layoutScale;
    final delta = Offset(physicalDelta.dx / s, physicalDelta.dy / s);
    stopwatchPosition = _clampPos(
      stopwatchPosition + delta,
      logicalBounds,
      stopwatchSize,
    );
    notifyListeners();
  }

  void dragCollision(Offset physicalDelta, Rect logicalBounds, double layoutScale) {
    final s = layoutScale <= 0 ? 1.0 : layoutScale;
    final delta = Offset(physicalDelta.dx / s, physicalDelta.dy / s);
    collisionPosition = _clampPos(
      collisionPosition + delta,
      logicalBounds,
      collisionSize,
    );
    notifyListeners();
  }

  Offset _clampPos(Offset pos, Rect bounds, Size size) {
    // DragBoundsProperty: keep entire node inside visible bounds.
    final minX = bounds.left;
    final minY = bounds.top;
    final maxX = bounds.right - size.width;
    final maxY = bounds.bottom - size.height;
    return Offset(
      pos.dx.clamp(minX, maxX < minX ? minX : maxX),
      pos.dy.clamp(minY, maxY < minY ? minY : maxY),
    );
  }

  void setStopwatchRunning(bool running) {
    stopwatchRunning = running;
    notifyListeners();
  }

  void resetStopwatchTime() {
    // StopwatchNode reset button: isRunning=false, time=0
    stopwatchRunning = false;
    stopwatchTimePs = 0;
    notifyListeners();
  }

  /// PlayResetButton toggles isRunning; CollisionCounter links reset count.
  void setCollisionRunning(bool running) {
    collisionRunning = running;
    numberOfCollisions = 0;
    _collisionTimeRunning = 0;
    notifyListeners();
  }

  void setSamplePeriod(int ps) {
    if (!samplePeriods.contains(ps) || ps == samplePeriodPs) return;
    samplePeriodPs = ps;
    // visibleProperty / samplePeriodProperty → stopAndResetCount
    collisionRunning = false;
    numberOfCollisions = 0;
    _collisionTimeRunning = 0;
    notifyListeners();
  }

  /// Called whenever [model] notifies (after tick / UI).
  void syncFromModel(IdealGasLawModel model) {
    var changed = false;

    // Visibility edges (Stopwatch hides → pause; Collision hides → stopAndReset)
    if (model.stopwatchVisible != _prevStopwatchVisible) {
      _prevStopwatchVisible = model.stopwatchVisible;
      if (!model.stopwatchVisible) {
        stopwatchRunning = false;
      } else {
        frontTool = ToolKind.stopwatch;
      }
      changed = true;
    }
    if (model.collisionCounterVisible != _prevCollisionVisible) {
      _prevCollisionVisible = model.collisionCounterVisible;
      if (!model.collisionCounterVisible) {
        collisionRunning = false;
        numberOfCollisions = 0;
        _collisionTimeRunning = 0;
      } else {
        frontTool = ToolKind.collision;
      }
      changed = true;
    }

    // Sim step detection via model stopwatch accumulator delta (View reads only).
    final modelSw = model.stopwatchPs;
    final dtPs = modelSw - _prevModelStopwatchPs;
    if (dtPs > 1e-9) {
      _prevModelStopwatchPs = modelSw;

      // Stopwatch.step(dt) → setTime only if isRunning
      if (model.stopwatchVisible && stopwatchRunning) {
        stopwatchTimePs = (stopwatchTimePs + dtPs).clamp(0.0, maxTimePs);
        if (stopwatchTimePs >= maxTimePs) {
          stopwatchRunning = false;
        }
        changed = true;
      }

      // CollisionCounter.step(dt) while isRunning
      if (model.collisionCounterVisible && collisionRunning) {
        numberOfCollisions +=
            model.collisionSolver.numberOfParticleContainerCollisions;
        _collisionTimeRunning += dtPs;
        if (_collisionTimeRunning >= samplePeriodPs) {
          // Save count across isRunning=false (source restores after toggle reset)
          final saved = numberOfCollisions;
          collisionRunning = false;
          numberOfCollisions = saved;
          _collisionTimeRunning = 0;
        }
        changed = true;
      }
    } else if (modelSw < _prevModelStopwatchPs - 1e-9) {
      // Model reset cleared stopwatchPs
      _prevModelStopwatchPs = modelSw;
    }

    if (changed) notifyListeners();
  }

  /// Full tool reset — mirrors Stopwatch.reset + CollisionCounter.reset.
  void reset() {
    stopwatchPosition = stopwatchHome;
    collisionPosition = collisionHome;
    stopwatchRunning = false;
    stopwatchTimePs = 0;
    collisionRunning = false;
    numberOfCollisions = 0;
    _collisionTimeRunning = 0;
    samplePeriodPs = 10;
    frontTool = null;
    _prevModelStopwatchPs = 0;
    // visibility is owned by IdealGasLawModel.reset()
    notifyListeners();
  }
}

enum ToolKind { stopwatch, collision }
