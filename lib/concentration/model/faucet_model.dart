import 'dart:ui';

import 'concentration_constants.dart';

/// Shared faucet model — beers-law-lab `Faucet.ts`.
class FaucetModel {
  FaucetModel({
    required this.position,
    required this.pipeMinX,
    this.spoutWidth = ConcentrationConstants.faucetSpoutWidth,
    this.maxFlowRate = ConcentrationConstants.faucetMaxFlowRate,
  });

  final Offset position;
  final double pipeMinX;
  final double spoutWidth;
  final double maxFlowRate;

  double flowRate = 0;
  bool enabled = true;

  void setFlowRate(double rate) {
    if (!enabled) {
      flowRate = 0;
      return;
    }
    flowRate = rate.clamp(0.0, maxFlowRate);
  }

  void setEnabled(bool value) {
    enabled = value;
    if (!enabled) {
      flowRate = 0;
    }
  }

  void reset() {
    flowRate = 0;
    enabled = true;
  }
}
