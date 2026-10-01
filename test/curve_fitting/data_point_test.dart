import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/curve_fitting_constants.dart';
import 'package:kratos/curve_fitting/model/data_point.dart';
import 'package:kratos/curve_fitting/model/data_set.dart';

void main() {
  group('DataPoint', () {
    test('default delta is 0.8', () {
      final p = DataPoint(x: 1, y: 2);
      expect(p.delta, CurveFittingConstants.defaultDelta);
      expect(p.dragging, isFalse);
      expect(p.animationActive, isFalse);
    });

    test('isInsideGraph uses closed GRAPH_BACKGROUND bounds', () {
      expect(DataPoint(x: 0, y: 0).isInsideGraph, isTrue);
      expect(DataPoint(x: -10, y: -10).isInsideGraph, isTrue);
      expect(DataPoint(x: 10, y: 10).isInsideGraph, isTrue);
      expect(DataPoint(x: 10.001, y: 0).isInsideGraph, isFalse);
      expect(DataPoint(x: 0, y: -10.001).isInsideGraph, isFalse);
    });
  });

  group('DataSet', () {
    test('getRelevantPoints filters outside / animating', () {
      final set = DataSet();
      final inside = DataPoint(x: 1, y: 1);
      final outside = DataPoint(x: 20, y: 0);
      final animating = DataPoint(x: 2, y: 2)..animationActive = true;
      set
        ..add(inside)
        ..add(outside)
        ..add(animating);

      final relevant = set.getRelevantPoints();
      expect(relevant, [inside]);
      expect(set.getNumberUniquePositionX(), 1);
    });

    test('unique X count', () {
      final set = DataSet();
      set.add(DataPoint(x: 8, y: 0));
      set.add(DataPoint(x: 9, y: 0));
      set.add(DataPoint(x: 9, y: 1));
      set.add(DataPoint(x: 9, y: 2));
      set.add(DataPoint(x: 10, y: 0));
      expect(set.getNumberUniquePositionX(), 3);
    });
  });
}
