import 'package:flutter/material.dart';

import '../constants/baa_constants.dart';
import '../model/charge_notation.dart';
import '../model/number_atom.dart';
import '../view/baa_phet_font.dart';
import 'charge_meter.dart';

/// PhET `SymbolNode` constants (local box coords before outer scale).
class SymbolNodeGeometry {
  static const double boxWidth = 275;
  static const double boxHeight = 325;
  static const double numberInset = 20;
  static const double numberFontSize = 70;
  static const double symbolFontSize = 150;

  /// `scale.png` intrinsic (PhET `images/scale.png`).
  static const double scalePngWidth = 351;
  static const double scalePngHeight = 189;

  /// PhET `scaleImage.scale(0.33)`.
  static const double scaleImageFactor = 0.33;

  static double get scaleImageWidth => scalePngWidth * scaleImageFactor;
  static double get scaleImageHeight => scalePngHeight * scaleImageFactor;

  /// ChargeMeter base width before `*1.6`.
  static const double chargeMeterBase = 70;
  static const double chargeMeterScale = 1.6;

  static double get chargeMeterLayoutWidth =>
      chargeMeterBase * chargeMeterScale;

  /// Row width before outer accordion scale (0.41).
  static double get intrinsicWidth =>
      scaleImageWidth + 10 + boxWidth + 10 + chargeMeterLayoutWidth;

  static double get intrinsicHeight => boxHeight;
}

/// PhET `BAASymbolNode` — scale.png + SymbolNode box + ChargeMeter.
///
/// Outer [scale] matches SymbolScreenView (`0.41`).
class BaaSymbolNode extends StatelessWidget {
  const BaaSymbolNode({
    super.key,
    required this.atom,
    this.scale = 0.41,
    this.chargeNotation = ChargeNotation.signLast,
  });

  final NumberAtom atom;
  final double scale;
  final ChargeNotation chargeNotation;

  static const scaleAsset = 'assets/build_an_atom/images/scale.png';

  @override
  Widget build(BuildContext context) {
    final w = SymbolNodeGeometry.intrinsicWidth;
    final h = SymbolNodeGeometry.intrinsicHeight;
    return SizedBox(
      width: w * scale,
      height: h * scale,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: w,
          maxWidth: w,
          minHeight: h,
          maxHeight: h,
          child: _IntrinsicSymbolRow(
            atom: atom,
            chargeNotation: chargeNotation,
          ),
        ),
      ),
    );
  }
}

class _IntrinsicSymbolRow extends StatelessWidget {
  const _IntrinsicSymbolRow({
    required this.atom,
    required this.chargeNotation,
  });

  final NumberAtom atom;
  final ChargeNotation chargeNotation;

  @override
  Widget build(BuildContext context) {
    const meterBase = SymbolNodeGeometry.chargeMeterBase;
    const meterScale = SymbolNodeGeometry.chargeMeterScale;
    final meter = Transform.scale(
      scale: meterScale,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: meterBase,
        height: meterBase * 0.55,
        child: ChargeMeter(
          charge: atom.charge,
          width: meterBase,
          showNumericalReadout: false,
        ),
      ),
    );

    // Mass number top inset → align scale image centerY with mass number centerY.
    // Approx mass glyph center ≈ NUMBER_INSET + numberFontSize/2.
    final scaleTop = SymbolNodeGeometry.numberInset +
        SymbolNodeGeometry.numberFontSize / 2 -
        SymbolNodeGeometry.scaleImageHeight / 2;

    // Charge meter centerY ≈ charge display centerY (NUMBER_INSET + font/2).
    final meterTop = SymbolNodeGeometry.numberInset +
        SymbolNodeGeometry.numberFontSize / 2 -
        (meterBase * 0.55 * meterScale) / 2;

    return SizedBox(
      width: SymbolNodeGeometry.intrinsicWidth,
      height: SymbolNodeGeometry.intrinsicHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: scaleTop.clamp(0.0, 200.0),
            child: Image.asset(
              BaaSymbolNode.scaleAsset,
              width: SymbolNodeGeometry.scaleImageWidth,
              height: SymbolNodeGeometry.scaleImageHeight,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
              errorBuilder: (c, e, s) => SizedBox(
                width: SymbolNodeGeometry.scaleImageWidth,
                height: SymbolNodeGeometry.scaleImageHeight,
              ),
            ),
          ),
          Positioned(
            left: SymbolNodeGeometry.scaleImageWidth + 10,
            top: 0,
            child: _SymbolBox(
              atom: atom,
              chargeNotation: chargeNotation,
              width: SymbolNodeGeometry.boxWidth,
              height: SymbolNodeGeometry.boxHeight,
            ),
          ),
          Positioned(
            left: SymbolNodeGeometry.scaleImageWidth +
                10 +
                SymbolNodeGeometry.boxWidth +
                10,
            top: meterTop.clamp(0.0, 200.0),
            child: SizedBox(
              width: SymbolNodeGeometry.chargeMeterLayoutWidth,
              height: meterBase * 0.55 * meterScale,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: meterBase,
                maxWidth: meterBase,
                minHeight: meterBase * 0.55,
                maxHeight: meterBase * 0.55,
                child: meter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// shred `SymbolNode` white box with A / X / Z / charge.
class _SymbolBox extends StatelessWidget {
  const _SymbolBox({
    required this.atom,
    required this.chargeNotation,
    required this.width,
    required this.height,
  });

  final NumberAtom atom;
  final ChargeNotation chargeNotation;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    const inset = SymbolNodeGeometry.numberInset;
    // PhET: protonCount > 0 ? AtomIdentifier.getSymbol : '-'
    final symbol = atom.protons > 0 ? atom.symbol : '-';
    final chargeStr =
        formatChargeDisplay(atom.charge, notation: chargeNotation);
    final chargeColor = Color(chargeTextColorValue(atom.charge));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            left: inset,
            top: inset,
            child: Text(
              '${atom.massNumber}',
              style: BaaPhetFont.of(
                SymbolNodeGeometry.numberFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            right: inset,
            top: inset,
            child: Text(
              chargeStr,
              style: BaaPhetFont.of(
                SymbolNodeGeometry.numberFontSize,
                fontWeight: FontWeight.w500,
                color: chargeColor,
              ),
            ),
          ),
          Center(
            child: Text(
              symbol,
              style: BaaPhetFont.of(
                SymbolNodeGeometry.symbolFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            left: inset,
            bottom: inset,
            child: Text(
              '${atom.protons}',
              style: BaaPhetFont.of(
                SymbolNodeGeometry.numberFontSize,
                fontWeight: FontWeight.w500,
                color: const Color(BAAConstants.protonColorValue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
