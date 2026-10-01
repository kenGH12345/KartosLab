/// Laser / photon source — LaserPointerNode approximation (body + nozzle + emit).
library;

import 'package:flutter/material.dart';

import '../model/photons_model.dart';
import '../qm_photons_colors.dart';

class PhotonSourceNode extends StatelessWidget {
  const PhotonSourceNode({
    super.key,
    required this.emissionMode,
    required this.emissionRate,
    required this.onEmitSingle,
    required this.onEmissionRateChanged,
  });

  final PhotonExperimentMode emissionMode;
  final double emissionRate;
  final VoidCallback onEmitSingle;
  final ValueChanged<double> onEmissionRateChanged;

  static const bodySize = Size(95, 55);
  static const nozzleSize = Size(15, 45);

  @override
  Widget build(BuildContext context) {
    final totalW = bodySize.width + nozzleSize.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: totalW,
          height: bodySize.height,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: bodySize.width,
                  height: bodySize.height,
                  decoration: BoxDecoration(
                    color: QmPhotonsColors.laserBody,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black54),
                  ),
                  alignment: Alignment.center,
                  child: emissionMode == PhotonExperimentMode.singlePhoton
                      ? Material(
                          color: QmPhotonsColors.emitButton,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onEmitSingle,
                            child: const SizedBox(width: 36, height: 36),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                            ),
                            child: Slider(
                              value: emissionRate.clamp(0, 200),
                              min: 0,
                              max: 200,
                              divisions: 20,
                              activeColor: QmPhotonsColors.photonStroke,
                              onChanged: onEmissionRateChanged,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                left: bodySize.width,
                top: (bodySize.height - nozzleSize.height) / 2,
                child: Container(
                  width: nozzleSize.width,
                  height: nozzleSize.height,
                  decoration: const BoxDecoration(
                    color: QmPhotonsColors.laserNozzle,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Text('Photon Source', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
