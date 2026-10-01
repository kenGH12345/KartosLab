/// PhotonDetectorNode — aperture + body + count/rate readout.
///
/// Source layout (`PhotonDetectorNode.ts`):
/// - detectionDirection `up` (Vertical): label → body → aperture (aperture bottom)
/// - detectionDirection `down` (Horizontal): aperture → body → label (aperture top)
/// Labels: "Vertical Polarization Detector" / "Horizontal Polarization Detector"
/// with colored orientation word.
library;

import 'package:flutter/material.dart';

import '../qm_photons_colors.dart';

class PhotonDetectorDisplay extends StatelessWidget {
  const PhotonDetectorDisplay({
    super.key,
    required this.label,
    required this.highlightWord,
    required this.value,
    required this.lookingUp,
    this.showRate = false,
    this.highlightColor,
  });

  /// Full label e.g. "Vertical Polarization Detector"
  final String label;

  /// Colored substring e.g. "Vertical"
  final String highlightWord;
  final int value;
  final bool lookingUp;
  final bool showRate;
  final Color? highlightColor;

  static const bodySize = Size(85, 50);
  static const apertureSize = Size(50, 18);
  static const _labelGap = 5.0;
  static const _labelHeight = 28.0;

  /// Distance from widget top to aperture center (for Positioned anchoring).
  static double apertureCenterFromTop({required bool lookingUp}) {
    if (lookingUp) {
      return _labelHeight + _labelGap + bodySize.height + apertureSize.height / 2;
    }
    return apertureSize.height / 2;
  }

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: bodySize.width,
      height: bodySize.height,
      decoration: BoxDecoration(
        color: QmPhotonsColors.detectorBody,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8899AA)),
      ),
      alignment: Alignment.center,
      child: Text(
        showRate ? '$value /s' : '$value',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final aperture = Container(
      width: apertureSize.width,
      height: apertureSize.height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFDDEE), Color(0xFF555555)],
        ),
        border: Border.all(color: Colors.black),
      ),
    );

    final color = highlightColor ?? Colors.black87;
    final rest = label.replaceFirst(highlightWord, '').trimLeft();
    final labelWidget = SizedBox(
      width: 170,
      height: _labelHeight,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
            height: 1.15,
          ),
          children: [
            TextSpan(
              text: highlightWord,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            if (rest.isNotEmpty) TextSpan(text: ' $rest'),
          ],
        ),
      ),
    );

    final children = lookingUp
        ? <Widget>[
            labelWidget,
            const SizedBox(height: _labelGap),
            body,
            aperture,
          ]
        : <Widget>[
            aperture,
            body,
            const SizedBox(height: _labelGap),
            labelWidget,
          ];

    return SizedBox(
      width: 170,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
