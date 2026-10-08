import 'package:flutter/material.dart';
import 'package:kratos/color_vision/view/cv_spectrum_slider.dart';

import '../bll_strings.dart';
import '../model/beers_law_constants.dart';
import '../model/beers_law_model.dart';
import '../model/light_mode.dart';
import 'beers_law_layout.dart';

/// PhET `WavelengthPanel` — label + display + Preset/Variable + WavelengthNumberControl.
///
/// VARIABLE uses scenery-phet spectrum track (150×30) + house thumb (35×45),
/// matching `BLLWavelengthNumberControl` / `CvSpectrumSlider`.
class BeersLawWavelengthPanel extends StatelessWidget {
  const BeersLawWavelengthPanel({
    super.key,
    required this.model,
    required this.left,
    required this.top,
  });

  final BeersLawModel model;
  final double left;
  final double top;

  /// Source `BLLWavelengthNumberControl` SLIDER_TRACK_SIZE.
  static const double spectrumTrackWidth = 150;
  static const double spectrumTrackHeight = 30;
  static const double spectrumThumbWidth = 35;
  static const double spectrumThumbHeight = 45;

  @override
  Widget build(BuildContext context) {
    final variable = model.light.mode == LightMode.variable;
    final wl = model.light.wavelength.round();

    return Positioned(
      left: left,
      top: top,
      child: Container(
        key: const Key('beers_law_wavelength_panel'),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: BeersLawLayout.panelFill,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${BllStrings.wavelength}：', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '$wl nm',
                    key: const Key('beers_law_wavelength_value'),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modeRadio(LightMode.preset, 'Preset'),
                const SizedBox(width: 15),
                _modeRadio(LightMode.variable, 'Variable'),
              ],
            ),
            if (variable) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stepBtn('-', () {
                    model.setWavelength(model.light.wavelength - 1);
                  }),
                  const SizedBox(width: 4),
                  CvSpectrumSlider(
                    key: const Key('beers_law_wavelength_slider'),
                    wavelength: model.light.wavelength.clamp(
                      BeersLawConstants.minWavelength,
                      BeersLawConstants.maxWavelength,
                    ),
                    onChanged: model.setWavelength,
                    trackWidth: spectrumTrackWidth,
                    trackHeight: spectrumTrackHeight,
                    thumbWidth: spectrumThumbWidth,
                    thumbHeight: spectrumThumbHeight,
                    showWindowCursor: true,
                  ),
                  const SizedBox(width: 4),
                  _stepBtn('+', () {
                    model.setWavelength(model.light.wavelength + 1);
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _modeRadio(LightMode mode, String label) {
    final on = model.light.mode == mode;
    return GestureDetector(
      onTap: () => model.setLightMode(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 1.5),
                color: Colors.white,
              ),
              child: on
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _stepBtn(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFF42A5F5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
