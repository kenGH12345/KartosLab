/// Quantum coin visual -?embeds QCT QuantumCoinNode (programmatic up/down arrows).
/// Superposition crossfade uses bias probability per source QuantumCoinNode.ts.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:kratos/quantum_coin_toss/coins/view/quantum_coin_node.dart';
import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

class QuantumCoinDisplay extends StatefulWidget {
  const QuantumCoinDisplay({
    super.key,
    required this.coinState,
    required this.upProbability,
    required this.radius,
    this.revealed = true,
    this.showSuperposition = true,
  });

  /// 'up' | 'down' | 'superposition'
  final ValueListenable<String> coinState;
  final ValueListenable<double> upProbability;
  final double radius;
  final bool revealed;
  final bool showSuperposition;

  @override
  State<QuantumCoinDisplay> createState() => _QuantumCoinDisplayState();
}

class _QuantumCoinDisplayState extends State<QuantumCoinDisplay> {
  late final ValueNotifier<bool> _showSuperposition;

  @override
  void initState() {
    super.initState();
    _showSuperposition = ValueNotifier(widget.showSuperposition);
  }

  @override
  void didUpdateWidget(covariant QuantumCoinDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showSuperposition != widget.showSuperposition) {
      _showSuperposition.value = widget.showSuperposition;
    }
  }

  @override
  void dispose() {
    _showSuperposition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.revealed) {
      return Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: QuantumMeasurementColors.maskedFill,
          border: Border.all(
            color: QuantumMeasurementColors.coinStroke,
            width: 2,
          ),
        ),
      );
    }

    return QuantumCoinNode(
      coinStateNotifier: widget.coinState,
      stateProbabilityNotifier: widget.upProbability,
      radius: widget.radius,
      showSuperpositionNotifier: _showSuperposition,
    );
  }
}
