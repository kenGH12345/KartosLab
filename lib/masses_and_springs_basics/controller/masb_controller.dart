import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../model/masb_model.dart';

/// Ticker → model.step. Avoids whole-tree setState; listeners rebuild selectively.
class MasbController extends ChangeNotifier {
  MasbController({MasbModel? model, bool autoTick = true})
      : model = model ?? MasbModel() {
    _ticker = Ticker(_onTick);
    if (autoTick) {
      _ticker.start();
    }
  }

  final MasbModel model;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  bool get isTicking => _ticker.isActive;

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.25) {
      notifyListeners();
      return;
    }
    model.step(dt);
    notifyListeners();
  }

  void play() {
    model.playing = true;
    notifyListeners();
  }

  void pause() {
    model.playing = false;
    notifyListeners();
  }

  void togglePlayPause() {
    if (model.playing) {
      pause();
    } else {
      play();
    }
  }

  void reset() {
    model.reset();
    rulerResetToken++;
    notifyListeners();
  }

  bool beginDrag(double modelX, double modelY) {
    final ok = model.beginDrag(modelX, modelY);
    if (ok) notifyListeners();
    return ok;
  }

  void updateDrag(double modelX, double modelY) {
    if (model.draggingMass == null) return;
    model.updateDrag(modelX, modelY);
    notifyListeners();
  }

  void endDrag() {
    if (model.draggingMass == null) return;
    model.endDrag();
    notifyListeners();
  }

  /// PhET `Spring.springConstantProperty` via SpringControlPanel slider (3–12 N/m).
  void setSpringConstant(double kNewtonsPerMeter) {
    model.setSpringConstant(kNewtonsPerMeter);
    notifyListeners();
  }

  void setSpringConstantAt(int springIndex, double kNewtonsPerMeter) {
    model.setSpringConstantAt(springIndex, kNewtonsPerMeter);
    notifyListeners();
  }

  void stopSpringAt(int springIndex) {
    model.stopSpringAt(springIndex);
    notifyListeners();
  }

  void setGravity(double g) {
    model.setGravity(g);
    notifyListeners();
  }

  void setBody(MasbBody body) {
    model.setBody(body);
    notifyListeners();
  }

  void setNaturalLengthVisible(bool v) {
    model.setNaturalLengthVisible(v);
    notifyListeners();
  }

  void setEquilibriumPositionVisible(bool v) {
    model.setEquilibriumPositionVisible(v);
    notifyListeners();
  }

  void setMovableLineVisible(bool v) {
    model.setMovableLineVisible(v);
    notifyListeners();
  }

  /// Lab `MassValueControlPanel` — kg of attached adjustable mass.
  void setAttachedMassKg(double kg) {
    model.setAttachedMassKg(kg);
    notifyListeners();
  }

  void setVelocityVectorVisible(bool v) {
    model.velocityVectorVisible = v;
    notifyListeners();
  }

  void setAccelerationVectorVisible(bool v) {
    model.accelerationVectorVisible = v;
    notifyListeners();
  }

  void setPeriodTraceVisible(bool v) {
    model.setPeriodTraceVisible(v);
    notifyListeners();
  }

  /// Bumped on reset so Stretch ruler returns to default (PhET resetAll).
  int rulerResetToken = 0;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
