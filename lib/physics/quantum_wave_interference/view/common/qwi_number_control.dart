import 'package:flutter/material.dart';

import 'qwi_colors.dart';
import 'package:kratos/physics/quantum_wave_interference/qwi_strings.dart';

/// Compact PhET-style NumberControl: title · value box · [−] slider [+] · optional ticks.
class QwiNumberControl extends StatelessWidget {
  const QwiNumberControl({
    super.key,
    required this.title,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.sliderKey,
    this.minLabel,
    this.maxLabel,
    this.step,
    this.titleMaxLines = 1,
  });

  final String title;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Key? sliderKey;
  final String? minLabel;
  final String? maxLabel;
  final double? step;
  final int titleMaxLines;

  double get _step => step ?? (max - min) / 100;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(min, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: titleMaxLines,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.w600, height: 1.15),
              ),
            ),
            if (valueText.isNotEmpty) ...[
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 72),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF888888)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    valueText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _ArrowButton(
              label: '−',
              onPressed: () => onChanged((v - _step).clamp(min, max)),
            ),
            Flexible(
              child: Slider(
                key: sliderKey,
                value: v,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
            _ArrowButton(
              label: '+',
              onPressed: () => onChanged((v + _step).clamp(min, max)),
            ),
          ],
        ),
        if (minLabel != null || maxLabel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Text(minLabel ?? '', style: const TextStyle(fontSize: 9, color: Colors.black54)),
                const Spacer(),
                Text(maxLabel ?? '', style: const TextStyle(fontSize: 9, color: Colors.black54)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Visible-spectrum wavelength NumberControl (PhET PhotonWavelengthControl).
class QwiWavelengthControl extends StatelessWidget {
  const QwiWavelengthControl({
    super.key,
    required this.wavelengthNm,
    required this.minNm,
    required this.maxNm,
    required this.onChanged,
    this.sliderKey,
  });

  final double wavelengthNm;
  final double minNm;
  final double maxNm;
  final ValueChanged<double> onChanged;
  final Key? sliderKey;

  @override
  Widget build(BuildContext context) {
    final v = wavelengthNm.clamp(minNm, maxNm);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                QwiStrings.wavelength,
                style: TextStyle(fontFamily: 'Arial', fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF888888)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '${v.toStringAsFixed(0)} nm',
                style: const TextStyle(fontFamily: 'Arial', fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _ArrowButton(label: '−', onPressed: () => onChanged((v - 5).clamp(minNm, maxNm))),
            Expanded(
              child: SizedBox(
                height: 22,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8B00FF),
                              Color(0xFF0000FF),
                              Color(0xFF00FFFF),
                              Color(0xFF00FF00),
                              Color(0xFFFFFF00),
                              Color(0xFFFF7F00),
                              Color(0xFFFF0000),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 0.1,
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: _thumbColor(v),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      ),
                      child: Slider(
                        key: sliderKey,
                        value: v,
                        min: minNm,
                        max: maxNm,
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _ArrowButton(label: '+', onPressed: () => onChanged((v + 5).clamp(minNm, maxNm))),
          ],
        ),
      ],
    );
  }

  Color _thumbColor(double nm) {
    if (nm < 450) return const Color(0xFF7F00FF);
    if (nm < 495) return const Color(0xFF0000FF);
    if (nm < 570) return const Color(0xFF00AA00);
    if (nm < 590) return const Color(0xFFCCCC00);
    if (nm < 620) return const Color(0xFFFF7F00);
    return const Color(0xFFE74C3C);
  }
}

/// Simple aqua-style radio row (Intensity / Hits).
class QwiAquaRadioGroup<T> extends StatelessWidget {
  const QwiAquaRadioGroup({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.entries.map((e) {
        final selected = e.key == value;
        return InkWell(
          key: Key('qwi_mode_${e.value}'),
          onTap: () => onChanged(e.key),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF337AB7), width: 1.5),
                    color: selected ? const Color(0xFF337AB7) : Colors.white,
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 6),
                Text(e.value, style: const TextStyle(fontFamily: 'Arial', fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Material(
        color: QwiColors.panelFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: const BorderSide(color: QwiColors.panelStroke),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1)),
          ),
        ),
      ),
    );
  }
}
