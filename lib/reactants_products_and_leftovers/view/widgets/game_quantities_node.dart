import 'package:flutter/material.dart';

import '../../model/box_type.dart';
import '../../model/substance.dart';
import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import '../../rpal_strings.dart';
import '../game_controller.dart';
import 'formula_text.dart';
import 'quantities_node.dart';
import 'rpal_number_spinner.dart';
import 'substance_icon.dart';

/// Game quantities under boxes — `QuantitiesNode` for Challenge.
class GameQuantitiesNode extends StatelessWidget {
  const GameQuantitiesNode({
    super.key,
    required this.controller,
    required this.reactants,
    required this.products,
    required this.leftovers,
    required this.interactiveBox,
    required this.interactive,
    required this.hideNumbers,
    this.boxWidth = RpalConstants.gameBoxWidth,
    this.afterBoxXOffset,
  });

  final GameController controller;
  final List<Substance> reactants;
  final List<Substance> products;
  final List<Substance> leftovers;
  final BoxType interactiveBox;
  final bool interactive;
  final bool hideNumbers;
  final double boxWidth;
  final double? afterBoxXOffset;

  @override
  Widget build(BuildContext context) {
    final afterX = afterBoxXOffset ?? (boxWidth + 60);
    final beforeOffsets =
        QuantitiesNode.createXOffsets(reactants.length, boxWidth);
    final afterOffsets = QuantitiesNode.createXOffsets(
      products.length + leftovers.length,
      boxWidth,
    );

    Widget column({
      required Substance substance,
      required bool isInteractive,
      required double left,
    }) {
      return Positioned(
        left: left - 40,
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hideNumbers)
              const SizedBox(height: 36)
            else if (isInteractive && interactive)
              RpalNumberSpinner(
                value: substance.quantity,
                min: RpalConstants.quantityMin,
                max: RpalConstants.quantityMax,
                onChanged: (v) => controller.setGuessQuantity(substance, v),
              )
            else
              Text(
                '${substance.quantity}',
                style: const TextStyle(
                  fontSize: 28,
                  fontFamily: 'Arial',
                  height: 1.1,
                ),
              ),
            const SizedBox(height: 4),
            SubstanceIcon(substance: substance),
            const SizedBox(height: 2),
            FormulaText(
              symbolHtml: substance.symbol,
              fontSize: 14,
              color: Colors.black,
            ),
          ],
        ),
      );
    }

    final beforeInteractive = interactiveBox == BoxType.before;
    final afterInteractive = interactiveBox == BoxType.after;

    return SizedBox(
      width: afterX + boxWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                for (var i = 0; i < reactants.length; i++)
                  column(
                    substance: reactants[i],
                    isInteractive: beforeInteractive,
                    left: beforeOffsets[i],
                  ),
                for (var i = 0; i < products.length; i++)
                  column(
                    substance: products[i],
                    isInteractive: afterInteractive,
                    left: afterX + afterOffsets[i],
                  ),
                for (var i = 0; i < leftovers.length; i++)
                  column(
                    substance: leftovers[i],
                    isInteractive: afterInteractive,
                    left: afterX + afterOffsets[i + products.length],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 28,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  width: boxWidth,
                  child: const _Bracket(label: RpalStrings.reactants),
                ),
                Positioned(
                  left: afterX,
                  width: boxWidth *
                      products.length /
                      (products.length + leftovers.length),
                  child: const _Bracket(label: RpalStrings.products),
                ),
                Positioned(
                  left: afterX +
                      boxWidth *
                          products.length /
                          (products.length + leftovers.length),
                  width: boxWidth *
                      leftovers.length /
                      (products.length + leftovers.length),
                  child: const _Bracket(label: RpalStrings.leftovers),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bracket extends StatelessWidget {
  const _Bracket({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(90, 10),
          painter: const _BracketPainter(),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontFamily: 'Arial'),
        ),
      ],
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RpalColors.bracketStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
