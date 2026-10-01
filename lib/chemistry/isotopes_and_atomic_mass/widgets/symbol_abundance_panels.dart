/// Symbol accordion + Abundance accordion (IAAM AccordionBox).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/make_isotopes_controller.dart';
import '../iaam_constants.dart';
import '../model/data/phet_number_utils.dart';

class SymbolAccordion extends StatelessWidget {
  const SymbolAccordion({
    super.key,
    required this.controller,
    required this.width,
  });

  final MakeIsotopesController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    return _AccordionShell(
      title: 'Symbol',
      width: width,
      expanded: controller.symbolExpanded,
      onToggle: () =>
          controller.setSymbolExpanded(!controller.symbolExpanded),
      child: SizedBox(
        height: 72,
        child: Center(
          child: _SymbolBadge(
            atomicNumber: m.protonCount,
            massNumber: m.massNumber,
            symbol: m.selectedElement.symbol,
          ),
        ),
      ),
    );
  }
}

class AbundanceAccordion extends StatelessWidget {
  const AbundanceAccordion({
    super.key,
    required this.controller,
    required this.width,
  });

  final MakeIsotopesController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final abundance = m.naturalAbundanceRounded(6);
    final String percentText;
    if (m.protonCount <= 0) {
      percentText = '';
    } else if (abundance == 0 && m.existsInTraceAmounts) {
      percentText = 'trace';
    } else {
      percentText = '${toFixedNumber(abundance * 100, 4)}%';
    }

    final others = 'Other ${m.selectedElement.name} Isotopes';
    final thisSlice = abundance == 0 && m.existsInTraceAmounts
        ? 1e-6
        : abundance;
    final otherSlice = (1.0 - thisSlice).clamp(0.0, 1.0);

    return _AccordionShell(
      title: 'Abundance in Nature',
      width: width,
      expanded: controller.abundanceExpanded,
      onToggle: () =>
          controller.setAbundanceExpanded(!controller.abundanceExpanded),
      child: SizedBox(
        height: 96,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: IaamConstants.pieThisIsotope,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    percentText,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 4),
                const Text('This Isotope', style: TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(width: 10),
            CustomPaint(
              size: const Size(64, 64),
              painter: _PiePainter(
                thisValue: thisSlice,
                otherValue: otherSlice,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                others,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccordionShell extends StatelessWidget {
  const _AccordionShell({
    required this.title,
    required this.width,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final double width;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: IaamConstants.panelBackground,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  _ExpandCollapseButton(expanded: expanded),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _ExpandCollapseButton extends StatelessWidget {
  const _ExpandCollapseButton({required this.expanded});
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE36F1E),
        border: Border.all(color: Colors.black54, width: 0.8),
      ),
      child: Text(
        expanded ? '−' : '+',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}

class _SymbolBadge extends StatelessWidget {
  const _SymbolBadge({
    required this.atomicNumber,
    required this.massNumber,
    required this.symbol,
  });

  final int atomicNumber;
  final int massNumber;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    // SymbolNode scale 0.2 of large badge — compact version.
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              symbol,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            left: 4,
            top: 2,
            child: Text(
              '$massNumber',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 2,
            child: Text(
              '$atomicNumber',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.thisValue, required this.otherValue});

  final double thisValue;
  final double otherValue;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final total = thisValue + otherValue;
    if (total <= 0) {
      canvas.drawCircle(c, r, Paint()..color = IaamConstants.pieOther);
      return;
    }
    final thisSweep = (thisValue / total) * 2 * math.pi;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      thisSweep,
      true,
      Paint()..color = IaamConstants.pieThisIsotope,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2 + thisSweep,
      2 * math.pi - thisSweep,
      true,
      Paint()..color = IaamConstants.pieOther,
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.thisValue != thisValue ||
      oldDelegate.otherValue != otherValue;
}
