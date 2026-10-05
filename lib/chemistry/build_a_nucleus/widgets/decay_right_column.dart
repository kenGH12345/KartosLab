/// Decay 右栏：counters | symbol 同行，Available Decays 在下。
///
/// [已确认] `DecayScreenView`：symbol 与计数同顶；
/// `availableDecaysPanel.top = symbol.bottom + 10`；
/// `nucleonNumberPanel.left = availableDecaysPanel.left`。
/// 不是五合一信息面板。只占 NineGrid midRight。
library;

import 'package:flutter/material.dart';

import '../model/build_a_nucleus_state.dart';
import 'nuclide_status.dart';

class DecayRightColumn extends StatelessWidget {
  const DecayRightColumn({
    super.key,
    required this.state,
    required this.decays,
  });

  final BuildANucleusState state;
  final Widget decays;

  /// [已确认] `availableDecaysPanel.top = symbolAccordionBox.bottom + 10`
  static const double symbolToDecaysGap = 10;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('ban_decay_right_column'),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: NucleonCountReadout(state: state)),
              Expanded(child: NuclideSymbolReadout(state: state)),
            ],
          ),
          const SizedBox(height: symbolToDecaysGap),
          Expanded(child: decays),
        ],
      ),
    );
  }
}
