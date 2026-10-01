import 'package:flutter/material.dart';

import '../../model/reaction.dart';
import '../../model/substance.dart';
import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import '../../rpal_strings.dart';
import '../molecules_controller.dart';
import 'formula_text.dart';
import 'molecule_icon.dart';
import 'quantities_node.dart';
import 'rpal_number_spinner.dart';

/// Quantities below boxes for Molecules — `QuantitiesNode` with showSymbols.
class MoleculesQuantitiesNode extends StatelessWidget {
  const MoleculesQuantitiesNode({
    super.key,
    required this.controller,
    required this.reaction,
    required this.boxWidth,
  });

  final MoleculesController controller;
  final Reaction reaction;
  final double boxWidth;

  Widget _icon(Substance s) {
    final id = RpalMoleculeIdX.fromIconId(s.iconId);
    if (id == null) {
      return const SizedBox(width: 24, height: 24);
    }
    return MoleculeIcon(id: id);
  }

  @override
  Widget build(BuildContext context) {
    final reactants = reaction.reactants;
    final products = reaction.products;
    final leftovers = reaction.leftovers;
    final beforeOffsets =
        QuantitiesNode.createXOffsets(reactants.length, boxWidth);
    final afterOffsets = QuantitiesNode.createXOffsets(
      products.length + leftovers.length,
      boxWidth,
    );
    const arrowGap = 60.0;
    final afterBoxX = boxWidth + arrowGap;

    return SizedBox(
      width: afterBoxX + boxWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                for (var i = 0; i < reactants.length; i++)
                  Positioned(
                    left: beforeOffsets[i] - 40,
                    width: 80,
                    child: _Column(
                      quantity: reactants[i].quantity,
                      interactive: true,
                      icon: _icon(reactants[i]),
                      symbolHtml: reactants[i].symbol,
                      onChanged: (v) =>
                          controller.setReactantQuantity(reactants[i], v),
                    ),
                  ),
                for (var i = 0; i < products.length; i++)
                  Positioned(
                    left: afterBoxX + afterOffsets[i] - 40,
                    width: 80,
                    child: _Column(
                      quantity: products[i].quantity,
                      interactive: false,
                      icon: _icon(products[i]),
                      symbolHtml: products[i].symbol,
                    ),
                  ),
                for (var i = 0; i < leftovers.length; i++)
                  Positioned(
                    left: afterBoxX +
                        afterOffsets[i + products.length] -
                        40,
                    width: 80,
                    child: _Column(
                      quantity: leftovers[i].quantity,
                      interactive: false,
                      icon: _icon(leftovers[i]),
                      symbolHtml: leftovers[i].symbol,
                    ),
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
                  left: afterBoxX,
                  width: boxWidth *
                      products.length /
                      (products.length + leftovers.length),
                  child: const _Bracket(label: RpalStrings.products),
                ),
                Positioned(
                  left: afterBoxX +
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

class _Column extends StatelessWidget {
  const _Column({
    required this.quantity,
    required this.interactive,
    required this.icon,
    required this.symbolHtml,
    this.onChanged,
  });

  final int quantity;
  final bool interactive;
  final Widget icon;
  final String symbolHtml;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (interactive)
          RpalNumberSpinner(
            value: quantity,
            min: RpalConstants.quantityMin,
            max: RpalConstants.quantityMax,
            onChanged: onChanged!,
          )
        else
          Text(
            '$quantity',
            style: const TextStyle(fontSize: 28, fontFamily: 'Arial', height: 1.1),
          ),
        const SizedBox(height: 4),
        icon,
        const SizedBox(height: 2),
        FormulaText(
          symbolHtml: symbolHtml,
          fontSize: 16,
          color: Colors.black,
        ),
      ],
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
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(0, 8)
        ..lineTo(0, 2)
        ..lineTo(size.width, 2)
        ..lineTo(size.width, 8),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
