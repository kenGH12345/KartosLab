import 'dart:ui' show Offset;

import 'package:kratos/under_pressure/model/faucet/faucet_model.dart';
import 'package:kratos/under_pressure/model/pool/pool_with_faucets_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_constants.dart';

/// Source: `SquarePoolModel.js`
class SquarePoolModel extends PoolWithFaucetsModel {
  SquarePoolModel({required super.onVolumeChanged})
      : maxHeight = UnderPressureConstants.maxPoolHeight,
        poolLeftX = 2.3,
        poolRightX = 6.0,
        super(
          inputFaucet: FaucetModel(
            position: const Offset(2.7, 0.44),
            maxFlowRate: 1,
            scale: 0.42,
          ),
          outputFaucet: FaucetModel(
            position: const Offset(6.6, -3.45),
            maxFlowRate: 1,
            scale: 0.3,
          ),
          maxVolume: UnderPressureConstants.maxPoolHeight,
        );

  final double maxHeight;
  final double poolLeftX;
  final double poolRightX;

  double get poolTopY => 0;
  double get poolBottomY => -maxHeight;

  @override
  double getWaterHeightAboveY(double x, double y) {
    return poolBottomY + maxHeight * volume / maxVolume - y;
  }

  @override
  bool isPointInsidePool(double x, double y) {
    return x > poolLeftX &&
        x < poolRightX &&
        y > poolBottomY &&
        y < poolTopY;
  }
}
