import 'package:flutter/material.dart';

import '../model/magnet_state.dart';
import 'mini_compass_preview_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/mac_strings.dart';

/// Control panel for the Magnet & Compass simulation.
///
/// Renamed from `_ControlPanel` → `MagnetControlPanel`
/// (private → public, domain-prefixed).
///
/// Extracted from `simulations/magnet_and_compass.dart:872-1043`.
class MagnetControlPanel extends StatelessWidget {
  final MagnetState state;
  final ValueChanged<double> onStrengthChanged;
  final ValueChanged<double> onStrengthStep;
  final ValueChanged<bool> onShowFieldChanged;
  final ValueChanged<bool> onSeeInsideChanged;
  final ValueChanged<bool> onEarthFieldChanged;
  final VoidCallback onFlipPolarity;
  final ValueChanged<bool> onShowCompassChanged;
  final ValueChanged<bool> onShowFieldMeterChanged;

  const MagnetControlPanel({
    super.key,
    required this.state,
    required this.onStrengthChanged,
    required this.onStrengthStep,
    required this.onShowFieldChanged,
    required this.onSeeInsideChanged,
    required this.onEarthFieldChanged,
    required this.onFlipPolarity,
    required this.onShowCompassChanged,
    required this.onShowFieldMeterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _card(children: [
            Text(MacStrings.barMagnet,
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Row(children: [
              Text('${MacStrings.strength}:', style: TextStyle(color: Colors.black87, fontSize: 12)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                child: Text('${(state.strength * 100).round()}%',
                  style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 2),
            Column(children: [
              Row(children: [
                const Text('0%', style: TextStyle(color: Colors.black54, fontSize: 9)),
                const Spacer(),
                const Text('50%', style: TextStyle(color: Colors.black54, fontSize: 9)),
                const Spacer(),
                const Text('100%', style: TextStyle(color: Colors.black54, fontSize: 9)),
              ]),
              Row(children: [
                _arrowBtn(Icons.arrow_left, () => onStrengthStep(-0.05)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blueAccent,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.lightBlue,
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape: SliderComponentShape.noOverlay,
                      padding: EdgeInsets.zero,
                    ),
                    child: Slider(
                      value: state.strength,
                      onChanged: onStrengthChanged,
                    ),
                  ),
                ),
                _arrowBtn(Icons.arrow_right, () => onStrengthStep(0.05)),
              ]),
            ]),
            const SizedBox(height: 2),
            _check(MacStrings.magneticFieldB, state.showField, onShowFieldChanged),
            _check(MacStrings.seeInside, state.seeInside, onSeeInsideChanged),
            _check(MacStrings.earth, state.earthField, onEarthFieldChanged),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFlipPolarity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4fc3f7),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: Text(MacStrings.flipPolarity, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          _card(children: [
            Row(children: [
              SizedBox(
                width: 20, height: 20,
                child: Checkbox(
                  value: state.showCompass,
                  onChanged: (v) => onShowCompassChanged(v ?? false),
                  activeColor: Colors.blueAccent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(MacStrings.compass, style: TextStyle(color: Colors.black87, fontSize: 13))),
              SizedBox(width: 60, height: 22, child: CustomPaint(painter: MiniCompassPreviewPainter())),
            ]),
            const SizedBox(height: 2),
            Row(children: [
              SizedBox(
                width: 20, height: 20,
                child: Checkbox(
                  value: state.showFieldMeter,
                  onChanged: (v) => onShowFieldMeterChanged(v ?? false),
                  activeColor: Colors.blueAccent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(MacStrings.fieldMeter, style: TextStyle(color: Colors.black87, fontSize: 13))),
              const Icon(Icons.add_circle_outline, color: Color(0xff5c35c8), size: 20),
            ]),
          ]),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff0f4f8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChange) {
    return Row(children: [
      SizedBox(
        width: 20, height: 20,
        child: Checkbox(
          value: value,
          onChanged: (v) => onChange(v ?? false),
          activeColor: Colors.blueAccent,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      const SizedBox(width: 4),
      // "Magnetic Field (B)" intrinsic ~238px > card inner 208.
      // Expanded + scaleDown keeps font 13 on short labels; only the long
      // one shrinks. Do not widen the 230 panel.
      Expanded(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13)),
        ),
      ),
    ]);
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Icon(icon, size: 18, color: Colors.black54),
      ),
    );
  }
}
