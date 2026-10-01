import 'dart:async';

import 'package:flutter/foundation.dart';

import '../curve_fitting_constants.dart';
import 'curve_model.dart';
import 'data_point.dart';
import 'data_set.dart';
import 'fit_type.dart';

/// Root model — PhET `CurveFittingModel` + ScreenView visibility flags.
///
/// **Drag performance / hit-test:** while any point is `dragging`, position
/// updates refit the curve and bump [paintEpoch] but do **not** call
/// [notifyListeners]. That avoids rebuilding the gesture widget tree mid-pan
/// (which cancels Flutter pan gestures — the DataPoint drag regression).
class CurveFittingModel extends ChangeNotifier {
  CurveFittingModel() {
    sliderValues = List<double>.from(CurveFittingConstants.defaultSliderValues);
    curve = CurveModel(dataSet: points, sliderValues: sliderValues);
    curve.updateFit();
  }

  /// Polynomial order: 1=linear, 2=quadratic, 3=cubic.
  int order = 1;

  FitType fitType = FitType.best;

  /// Ascending [d, c, b, a] = [a0, a1, a2, a3].
  late final List<double> sliderValues;

  final DataSet points = DataSet();

  late final CurveModel curve;

  /// Lightweight paint tick for curve / residuals / stats UI during drag.
  final ValueNotifier<int> paintEpoch = ValueNotifier<int>(0);

  // View flags (defaults from CurveFittingScreenView).
  bool curveVisible = false;
  bool residualsVisible = false;
  bool valuesVisible = false;
  bool equationExpanded = true;
  bool deviationsExpanded = true;

  bool get _anyDragging => points.points.any((p) => p.dragging);

  void setOrder(int value) {
    assert(value >= 1 && value <= 3);
    if (order == value) return;
    order = value;
    curve.order = value;
    _refitAndNotify();
  }

  void setFitType(FitType value) {
    if (fitType == value) return;
    fitType = value;
    curve.fitType = value;
    _refitAndNotify();
  }

  void setSliderValue(int index, double value) {
    assert(index >= 0 && index < 4);
    if (sliderValues[index] == value) return;
    sliderValues[index] = value;
    curve.bindSliders(sliderValues);
    _refitAndNotify();
  }

  void setCurveVisible(bool v) {
    if (curveVisible == v) return;
    curveVisible = v;
    notifyListeners();
  }

  void setResidualsVisible(bool v) {
    if (residualsVisible == v) return;
    residualsVisible = v;
    notifyListeners();
  }

  void setValuesVisible(bool v) {
    if (valuesVisible == v) return;
    valuesVisible = v;
    notifyListeners();
  }

  void setEquationExpanded(bool v) {
    if (equationExpanded == v) return;
    equationExpanded = v;
    notifyListeners();
  }

  void setDeviationsExpanded(bool v) {
    if (deviationsExpanded == v) return;
    deviationsExpanded = v;
    notifyListeners();
  }

  void addPoint(DataPoint point) {
    points.add(point);
    point.addListener(_onPointChanged);
    _refitCurve();
    paintEpoch.value++;
    // Defer structural rebuild so onPanStart is not cancelled mid-gesture.
    scheduleMicrotask(notifyListeners);
  }

  void removePoint(DataPoint point) {
    point.removeListener(_onPointChanged);
    points.remove(point);
    _refitAndNotify();
  }

  void _onPointChanged() {
    _refitCurve();
    paintEpoch.value++;
    // Structural ListenableBuilder rebuild cancels active pan gestures.
    if (!_anyDragging) {
      notifyListeners();
    }
  }

  void _refitCurve() {
    curve.order = order;
    curve.fitType = fitType;
    curve.bindSliders(sliderValues);
    curve.updateFit();
  }

  void _refitAndNotify() {
    _refitCurve();
    paintEpoch.value++;
    notifyListeners();
  }

  /// Notify after external mutation of a point (position/delta/flags)
  /// when the point itself does not fire [ChangeNotifier].
  void pointUpdated() => _onPointChanged();

  void reset() {
    for (final p in List<DataPoint>.from(points.points)) {
      p.removeListener(_onPointChanged);
    }
    points.clear();

    for (var i = 0; i < 4; i++) {
      sliderValues[i] = CurveFittingConstants.defaultSliderValues[i];
    }
    order = 1;
    fitType = FitType.best;
    curveVisible = false;
    residualsVisible = false;
    valuesVisible = false;
    equationExpanded = true;
    deviationsExpanded = true;

    curve.order = order;
    curve.fitType = fitType;
    curve.bindSliders(sliderValues);
    curve.reset();
    curve.updateFit();
    paintEpoch.value++;
    notifyListeners();
  }

  @override
  void dispose() {
    paintEpoch.dispose();
    super.dispose();
  }
}
