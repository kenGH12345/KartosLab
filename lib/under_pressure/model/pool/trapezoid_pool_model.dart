import 'dart:ui' show Offset;

import 'package:kratos/under_pressure/model/faucet/faucet_model.dart';
import 'package:kratos/under_pressure/model/pool/pool_with_faucets_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';
import 'package:kratos/under_pressure/model/under_pressure_math.dart';

/// Source: `TrapezoidPoolModel.js`
class TrapezoidPoolModel extends PoolWithFaucetsModel {
  TrapezoidPoolModel({required super.onVolumeChanged})
      : maxHeight = UnderPressureConstants.maxPoolHeight,
        super(
          inputFaucet: FaucetModel(
            position: const Offset(3.19, 0.44),
            maxFlowRate: 1,
            scale: 0.42,
          ),
          outputFaucet: FaucetModel(
            position: const Offset(7.5, -3.45),
            maxFlowRate: 1,
            scale: 0.3,
          ),
          maxVolume: UnderPressureConstants.maxPoolHeight,
        ) {
    leftChamber = ChamberBorders(
      centerTop: _leftChamberTopCenter,
      widthTop: _widthAtTop,
      widthBottom: _widthAtBottom,
      leftBorder: LinearFunction(
        0,
        maxHeight,
        _leftChamberTopCenter - _widthAtBottom / 2,
        _leftChamberTopCenter - _widthAtTop / 2,
      ),
      rightBorder: LinearFunction(
        0,
        maxHeight,
        _leftChamberTopCenter + _widthAtBottom / 2,
        _leftChamberTopCenter + _widthAtTop / 2,
      ),
    );
    rightChamber = ChamberBorders(
      centerTop: _leftChamberTopCenter + _separation,
      widthTop: _widthAtBottom,
      widthBottom: _widthAtTop,
      leftBorder: LinearFunction(
        0,
        maxHeight,
        _leftChamberTopCenter + _separation - _widthAtTop / 2,
        _leftChamberTopCenter + _separation - _widthAtBottom / 2,
      ),
      rightBorder: LinearFunction(
        0,
        maxHeight,
        _leftChamberTopCenter + _separation + _widthAtTop / 2,
        _leftChamberTopCenter + _separation + _widthAtBottom / 2,
      ),
    );
  }

  static const double _widthAtTop = 0.7;
  static const double _widthAtBottom = 3.15;
  static const double _leftChamberTopCenter = 3.2;
  static const double _separation = 3.22;

  final double maxHeight;

  late final ChamberBorders leftChamber;
  late final ChamberBorders rightChamber;

  /// Bottom connecting chamber.
  double get bottomX1 => 4;
  double get bottomY1 => -maxHeight + 0.21;
  double get bottomX2 => 6;
  double get bottomY2 => -maxHeight;

  /// Source `verticles` — key coordinates of complex figure.
  double get x1top => leftChamber.centerTop - leftChamber.widthTop / 2;
  double get x2top => leftChamber.centerTop + leftChamber.widthTop / 2;
  double get x3top => rightChamber.centerTop - rightChamber.widthTop / 2;
  double get x4top => rightChamber.centerTop + rightChamber.widthTop / 2;

  double get x1middle => leftChamber.rightBorder.evaluate(
        (bottomY2 - bottomY1).abs(),
      );
  double get x2middle => rightChamber.leftBorder.evaluate(
        (bottomY2 - bottomY1).abs(),
      );

  double get x1bottom => leftChamber.centerTop - leftChamber.widthBottom / 2;
  double get x2bottom => leftChamber.centerTop + leftChamber.widthBottom / 2;
  double get x3bottom => rightChamber.centerTop - rightChamber.widthBottom / 2;
  double get x4bottom => rightChamber.centerTop + rightChamber.widthBottom / 2;

  double get ymiddle => bottomY1;

  @override
  double getWaterHeightAboveY(double x, double y) {
    return maxHeight * volume / maxVolume + bottomY2 - y;
  }

  @override
  bool isPointInsidePool(double x, double y) {
    if (x > bottomX1 &&
        x < bottomX2 &&
        y < bottomY1 &&
        y > bottomY2) {
      return true;
    }
    final yDiffWithPoolBottom = y - bottomY2;
    if (yDiffWithPoolBottom > 0) {
      final x1 = leftChamber.leftBorder.evaluate(yDiffWithPoolBottom);
      final x2 = leftChamber.rightBorder.evaluate(yDiffWithPoolBottom);
      final x3 = rightChamber.leftBorder.evaluate(yDiffWithPoolBottom);
      final x4 = rightChamber.rightBorder.evaluate(yDiffWithPoolBottom);
      return (x1 < x && x < x2) || (x3 < x && x < x4);
    }
    return false;
  }
}

class ChamberBorders {
  ChamberBorders({
    required this.centerTop,
    required this.widthTop,
    required this.widthBottom,
    required this.leftBorder,
    required this.rightBorder,
  });

  final double centerTop;
  final double widthTop;
  final double widthBottom;
  final LinearFunction leftBorder;
  final LinearFunction rightBorder;
}
