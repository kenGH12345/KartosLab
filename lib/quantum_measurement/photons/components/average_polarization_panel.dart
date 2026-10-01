/// Average Polarization panel — NormalizedOutcomeVectorGraph (simplified).
/// Source: PhotonsExperimentSceneView dynamicDataDisplayBox right side.
library;

import 'package:flutter/material.dart';

import '../model/photons_model.dart';
import '../qm_photons_colors.dart';

class AveragePolarizationPanel extends StatefulWidget {
  const AveragePolarizationPanel({
    super.key,
    required this.scene,
  });

  final PhotonsExperimentSceneModel scene;

  @override
  State<AveragePolarizationPanel> createState() =>
      _AveragePolarizationPanelState();
}

class _AveragePolarizationPanelState extends State<AveragePolarizationPanel> {
  bool _showVector = true;
  bool _showExpectation = false;
  bool _showDecimal = false;

  @override
  Widget build(BuildContext context) {
    final outcome = widget.scene.normalizedOutcome; // [-1,1] typically
    final expectation = widget.scene.expectation;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF777777)),
            ),
            child: const Text(
              'Average Polarization',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              children: [
                const TextSpan(text: '(N('),
                TextSpan(
                  text: 'V',
                  style: TextStyle(
                    color: QmPhotonsColors.verticalPolarization,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ') − N('),
                TextSpan(
                  text: 'H',
                  style: TextStyle(
                    color: QmPhotonsColors.horizontalPolarization,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ')) / N(Total)'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            width: 200,
            child: CustomPaint(
              painter: _OutcomeGraphPainter(
                outcome: outcome,
                expectation: expectation,
                showVector: _showVector,
                showExpectation: _showExpectation && expectation != null,
                showDecimal: _showDecimal,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _check(
            'Vector Representation',
            _showVector,
            (v) => setState(() => _showVector = v),
            trailing: const Icon(Icons.arrow_right_alt, size: 16),
          ),
          _check(
            'Expectation Value',
            _showExpectation,
            (v) => setState(() => _showExpectation = v),
            trailing: Container(
              width: 18,
              height: 3,
              color: QmPhotonsColors.photonStroke,
            ),
            enabled: expectation != null,
          ),
          _check(
            'Decimal Values',
            _showDecimal,
            (v) => setState(() => _showDecimal = v),
          ),
          if (_showDecimal)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'outcome = ${outcome.toStringAsFixed(2)}'
                '${expectation != null ? '  ⟨E⟩ = ${expectation.toStringAsFixed(2)}' : ''}',
                style: const TextStyle(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _check(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    Widget? trailing,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class _OutcomeGraphPainter extends CustomPainter {
  _OutcomeGraphPainter({
    required this.outcome,
    required this.expectation,
    required this.showVector,
    required this.showExpectation,
    required this.showDecimal,
  });

  final double outcome;
  final double? expectation;
  final bool showVector;
  final bool showExpectation;
  final bool showDecimal;

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;
    final midY = size.height / 2;
    final midX = size.width * 0.35;

    // Y axis
    canvas.drawLine(Offset(midX, 8), Offset(midX, size.height - 8), axis);
    // X axis (zero)
    canvas.drawLine(Offset(midX, midY), Offset(size.width - 8, midY), axis);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    void label(String s, Offset o, {Color? color}) {
      tp.text = TextSpan(
        text: s,
        style: TextStyle(fontSize: 10, color: color ?? Colors.black87),
      );
      tp.layout();
      tp.paint(canvas, o);
    }

    label('+1', Offset(4, 4));
    label('V', Offset(22, 4), color: QmPhotonsColors.verticalPolarization);
    label('0', Offset(4, midY - 6));
    label('-1', Offset(4, size.height - 16));
    label('H', Offset(22, size.height - 16),
        color: QmPhotonsColors.horizontalPolarization);
    label('1.0', Offset(size.width - 22, midY + 4));


    // Map outcome ∈ typically [-1,1] where +1 = all V → top
    final plotY = midY - outcome.clamp(-1.0, 1.0) * (midY - 16);
    final tip = Offset(size.width * 0.75, plotY);

    if (showVector) {
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(midX, midY), tip, paint);
      // arrow head
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 8, tip.dy - 4)
        ..lineTo(tip.dx - 8, tip.dy + 4)
        ..close();
      canvas.drawPath(path, Paint()..color = Colors.black);
    }

    if (showExpectation && expectation != null) {
      final ey = midY - expectation!.clamp(-1.0, 1.0) * (midY - 16);
      canvas.drawLine(
        Offset(midX + 4, ey),
        Offset(size.width - 10, ey),
        Paint()
          ..color = QmPhotonsColors.photonStroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OutcomeGraphPainter oldDelegate) =>
      oldDelegate.outcome != outcome ||
      oldDelegate.expectation != expectation ||
      oldDelegate.showVector != showVector ||
      oldDelegate.showExpectation != showExpectation ||
      oldDelegate.showDecimal != showDecimal;
}
