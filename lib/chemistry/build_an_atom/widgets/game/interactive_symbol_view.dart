import 'package:flutter/material.dart';

import '../../model/charge_notation.dart';
import '../../model/number_atom.dart';
import '../../view/baa_phet_font.dart';
import 'baa_number_spinner.dart';

/// PhET Game `InteractiveSymbolNode` (275×300, number font 56).
///
/// Not the same geometry as Symbol Screen `SymbolNode`.
class InteractiveSymbolView extends StatelessWidget {
  const InteractiveSymbolView({
    super.key,
    required this.protonCount,
    required this.massNumber,
    required this.charge,
    required this.onProtonChanged,
    required this.onMassChanged,
    required this.onChargeChanged,
    this.isProtonInteractive = false,
    this.isMassInteractive = false,
    this.isChargeInteractive = false,
    this.enabled = true,
    this.scale = 0.75,
    this.showAtomName = true,
  });

  final int protonCount;
  final int massNumber;
  final int charge;
  final ValueChanged<int> onProtonChanged;
  final ValueChanged<int> onMassChanged;
  final ValueChanged<int> onChargeChanged;
  final bool isProtonInteractive;
  final bool isMassInteractive;
  final bool isChargeInteractive;
  final bool enabled;
  final double scale;
  final bool showAtomName;

  static const boxW = 275.0;
  static const boxH = 300.0;
  static const numberFont = 56.0;
  static const symbolFont = 120.0;
  static const inset = 15.0;

  @override
  Widget build(BuildContext context) {
    final atom = NumberAtom(
      protonCount,
      (massNumber - protonCount).clamp(0, 99),
      (protonCount - charge).clamp(0, 99),
    );
    final symbol = protonCount > 0 ? atom.symbol : '-';
    final chargeStr = formatChargeDisplay(charge);
    final chargeColor = Color(chargeTextColorValue(charge));

    final box = SizedBox(
      width: boxW,
      height: boxH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: boxW,
            height: boxH,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Stack(
              children: [
                // Mass
                Positioned(
                  left: inset,
                  top: inset,
                  child: isMassInteractive
                      ? BaaNumberSpinner(
                          value: massNumber,
                          onChanged: onMassChanged,
                          enabled: enabled,
                          minValue: 0,
                          maxValue: 99,
                          width: 64,
                        )
                      : Text(
                          '$massNumber',
                          style: BaaPhetFont.of(numberFont, fontWeight: FontWeight.w500),
                        ),
                ),
                // Charge
                Positioned(
                  right: inset,
                  top: inset,
                  child: isChargeInteractive
                      ? BaaNumberSpinner(
                          value: charge,
                          onChanged: onChargeChanged,
                          enabled: enabled,
                          showPlusForPositive: true,
                          textColor: chargeColor,
                          minValue: -99,
                          maxValue: 99,
                          width: 64,
                        )
                      : Text(
                          chargeStr,
                          style: BaaPhetFont.of(
                            numberFont,
                            fontWeight: FontWeight.w500,
                            color: chargeColor,
                          ),
                        ),
                ),
                Center(
                  child: Text(
                    symbol,
                    style: BaaPhetFont.of(symbolFont, fontWeight: FontWeight.w500),
                  ),
                ),
                // Z
                Positioned(
                  left: inset,
                  bottom: inset,
                  child: isProtonInteractive
                      ? BaaNumberSpinner(
                          value: protonCount,
                          onChanged: onProtonChanged,
                          enabled: enabled,
                          minValue: 0,
                          maxValue: 99,
                          width: 64,
                          textColor: const Color(0xFFD14600),
                        )
                      : Text(
                          '$protonCount',
                          style: BaaPhetFont.of(
                            numberFont,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFD14600),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Transform.scale(
      scale: scale,
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: boxW * scale,
            height: boxH * scale,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: boxW,
              maxWidth: boxW,
              minHeight: boxH,
              maxHeight: boxH,
              child: box,
            ),
          ),
          if (showAtomName && protonCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                atom.elementDisplayName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
