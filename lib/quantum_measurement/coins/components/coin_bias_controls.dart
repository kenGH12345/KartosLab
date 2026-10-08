/// Initial Orientation selector + dual linked Coin Bias probability controls.
/// Mirrors `InitialCoinStateSelectorNode.ts` + `OutcomeProbabilityControl.ts`
/// + `ProbabilityValueControl.ts` (title + ◀ slider ▶).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../common/system_type.dart';
import '../../qm_assets.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class InitialOrientationSelector extends StatelessWidget {
  const InitialOrientationSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// 'heads' | 'tails'
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          QmStrings.initialOrientation,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _OrientationChip(
              face: 'heads',
              selected: value == 'heads',
              onTap: () => onChanged('heads'),
            ),
            const SizedBox(width: 22),
            _OrientationChip(
              face: 'tails',
              selected: value == 'tails',
              onTap: () => onChanged('tails'),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrientationChip extends StatelessWidget {
  const _OrientationChip({
    required this.face,
    required this.selected,
    required this.onTap,
  });

  final String face;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHeads = face == 'heads';
    final stroke = isHeads
        ? QuantumMeasurementColors.headsColor
        : QuantumMeasurementColors.tailsColor;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? Colors.black : stroke.withValues(alpha: 0.55),
            width: selected ? 3 : 1.5,
          ),
        ),
        child: _CoinFaceGlyph(face: face, size: 32),
      ),
    );
  }
}

/// Dual linked ProbabilityValueControl.
/// Classical title: "Coin Bias (State)"; Quantum: "State to Prepare (α|↑⟩+β|↓⟩)".
class CoinBiasControls extends StatelessWidget {
  const CoinBiasControls({
    super.key,
    required this.systemType,
    required this.upProbability,
    required this.onChanged,
  });

  final SystemType systemType;
  final double upProbability;
  final ValueChanged<double> onChanged;

  static const _fine = 0.01;

  void _nudgeUp(double delta) =>
      onChanged((upProbability + delta).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final down = 1.0 - upProbability;
    final isClassical = systemType == SystemType.classical;
    final downColor = isClassical
        ? QuantumMeasurementColors.tailsColor
        : QuantumMeasurementColors.downColor;
    final alpha = upProbability.clamp(0.0, 1.0);
    final beta = (1.0 - upProbability).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isClassical)
          const Text(
            QmStrings.coinBiasState,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        else ...[
          const Text(
            QmStrings.stateToPrepare,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '( α|↑⟩ + β|↓⟩ )',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 2),
          Text(
            '${alpha.toStringAsFixed(3)}|↑⟩ + ${beta.toStringAsFixed(3)}|↓⟩',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 6),
        _ProbabilitySliderRow(
          title: _ProbabilityTitle(
            systemType: systemType,
            face: isClassical ? 'heads' : 'up',
            quantumSquaredLabel: isClassical ? null : '|α|²',
          ),
          value: upProbability,
          activeColor: QuantumMeasurementColors.selectorButtonSelectedStroke,
          onChanged: onChanged,
          onNudge: _nudgeUp,
        ),
        const SizedBox(height: 8),
        _ProbabilitySliderRow(
          title: _ProbabilityTitle(
            systemType: systemType,
            face: isClassical ? 'tails' : 'down',
            color: downColor,
            quantumSquaredLabel: isClassical ? null : '|β|²',
          ),
          value: down,
          activeColor: downColor,
          onChanged: (v) => onChanged(1.0 - v),
          onNudge: (d) => _nudgeUp(-d),
        ),
      ],
    );
  }
}

/// Basis State radio group for quantum coins (InitialCoinStateSelectorNode).
class BasisStateSelector extends StatelessWidget {
  const BasisStateSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// 'up' | 'down' (superposition is derived from bias, not selectable)
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == 'down' ? 'down' : 'up';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          QmStrings.basisState,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _BasisChip(
              label: '↑',
              selected: selected == 'up',
              color: Colors.black,
              onTap: () => onChanged('up'),
            ),
            const SizedBox(width: 22),
            _BasisChip(
              label: '↓',
              selected: selected == 'down',
              color: QuantumMeasurementColors.downColor,
              onTap: () => onChanged('down'),
            ),
          ],
        ),
      ],
    );
  }
}

class _BasisChip extends StatelessWidget {
  const _BasisChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? Colors.black : color.withValues(alpha: 0.55),
            width: selected ? 3 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _ProbabilityTitle extends StatelessWidget {
  const _ProbabilityTitle({
    required this.systemType,
    required this.face,
    this.color,
    this.quantumSquaredLabel,
  });

  final SystemType systemType;
  final String face;
  final Color? color;
  final String? quantumSquaredLabel;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 12, color: color ?? Colors.black87);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(QmStrings.probabilityP, style: style),
        if (systemType == SystemType.classical)
          _CoinFaceGlyph(face: face, size: 14)
        else
          Text(face == 'up' ? '\u2191' : '\u2193', style: style),
        Text(')', style: style),
        if (quantumSquaredLabel != null) ...[
          Text(' = $quantumSquaredLabel', style: style),
        ],
      ],
    );
  }
}

class _ProbabilitySliderRow extends StatelessWidget {
  const _ProbabilitySliderRow({
    required this.title,
    required this.value,
    required this.activeColor,
    required this.onChanged,
    required this.onNudge,
  });

  final Widget title;
  final double value;
  final Color activeColor;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onNudge;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        title,
        const SizedBox(height: 2),
        Row(
          children: [
            _ArrowBtn(
              icon: Icons.chevron_left,
              onPressed: () => onNudge(-CoinBiasControls._fine),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: activeColor,
                  inactiveTrackColor: const Color(0xFFCCCCCC),
                  thumbColor: activeColor,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                  showValueIndicator: ShowValueIndicator.never,
                ),
                child: Slider(
                  value: value.clamp(0.0, 1.0),
                  divisions: 20, // 0.05 steps like source
                  onChanged: onChanged,
                ),
              ),
            ),
            _ArrowBtn(
              icon: Icons.chevron_right,
              onPressed: () => onNudge(CoinBiasControls._fine),
            ),
          ],
        ),
        // 0 …… 1 tick labels (majorTicks in ProbabilityValueControl)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(fontSize: 10)),
              Text('1', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 22,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black87),
      ),
    );
  }
}

class _CoinFaceGlyph extends StatelessWidget {
  const _CoinFaceGlyph({required this.face, required this.size});

  final String face;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isHeads = face == 'heads';
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        isHeads ? QmAssets.classicalCoinHeads : QmAssets.classicalCoinTails,
        fit: BoxFit.contain,
      ),
    );
  }
}
