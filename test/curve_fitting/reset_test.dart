import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/curve_fitting_constants.dart';
import 'package:kratos/curve_fitting/model/curve_fitting_model.dart';
import 'package:kratos/curve_fitting/model/data_point.dart';
import 'package:kratos/curve_fitting/model/fit_type.dart';

void main() {
  test('reset restores defaults and clears points', () {
    final model = CurveFittingModel();
    model.setOrder(3);
    model.setFitType(FitType.adjustable);
    model.setSliderValue(0, -5);
    model.setSliderValue(1, 1.5);
    model.setCurveVisible(true);
    model.setResidualsVisible(true);
    model.setValuesVisible(true);
    model.equationExpanded = false;
    model.deviationsExpanded = false;
    model.addPoint(DataPoint(x: 1, y: 2));
    model.addPoint(DataPoint(x: 3, y: 4));

    model.reset();

    expect(model.order, 1);
    expect(model.fitType, FitType.best);
    expect(model.sliderValues, CurveFittingConstants.defaultSliderValues);
    expect(model.curveVisible, isFalse);
    expect(model.residualsVisible, isFalse);
    expect(model.valuesVisible, isFalse);
    expect(model.equationExpanded, isTrue);
    expect(model.deviationsExpanded, isTrue);
    expect(model.points.length, 0);
    expect(model.curve.rSquared, 0);
    expect(model.curve.chiSquared, 0);
    expect(model.curve.isCurvePresent, isFalse);
  });

  test('initial model has no points and default view flags', () {
    final model = CurveFittingModel();
    expect(model.points.length, 0);
    expect(model.curveVisible, isFalse);
    expect(model.residualsVisible, isFalse);
    expect(model.valuesVisible, isFalse);
    expect(model.order, 1);
    expect(model.fitType, FitType.best);
    expect(model.sliderValues[0], CurveFittingConstants.constantDefault);
  });
}
