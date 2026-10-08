/// Probability accordion — PhotonDetectionProbabilityPanel.ts
library;

import 'package:flutter/material.dart';

import '../model/photons_model.dart';
import '../qm_photons_colors.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class PhotonResultDisplay extends StatefulWidget {
  const PhotonResultDisplay({
    super.key,
    required this.scene,
    required this.isManyMode,
  });

  final PhotonsExperimentSceneModel scene;
  final bool isManyMode;

  @override
  State<PhotonResultDisplay> createState() => _PhotonResultDisplayState();
}

class _PhotonResultDisplayState extends State<PhotonResultDisplay> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        border: Border.all(color: const Color(0xFF777777)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    QmStrings.probability,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  _expanded ? Icons.remove : Icons.add,
                  size: 16,
                  color: const Color(0xFFE36F1E),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  const TextSpan(text: 'P('),
                  TextSpan(
                    text: 'V',
                    style: TextStyle(
                      color: QmPhotonsColors.verticalPolarization,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        ') = ${widget.scene.pVertical.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  const TextSpan(text: 'P('),
                  TextSpan(
                    text: 'H',
                    style: TextStyle(
                      color: QmPhotonsColors.horizontalPolarization,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        ') = ${widget.scene.pHorizontal.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
