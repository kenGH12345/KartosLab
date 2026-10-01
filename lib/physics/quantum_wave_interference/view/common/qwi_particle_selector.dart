import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../assets/qwi_assets.dart';
import '../../domain/source_type.dart';
import 'qwi_colors.dart';

/// PhET SceneRadioButtonGroup — 2×2 square buttons, icon above label.
class QwiParticleSelector extends StatelessWidget {
  const QwiParticleSelector({
    super.key,
    required this.active,
    required this.onSelect,
    this.keyPrefix = 'qwi_source',
    this.cellWidth = 72,
    this.cellHeight = 64,
    this.spacing = 4,
    this.runSpacing = 4,
  });

  final SourceType active;
  final ValueChanged<SourceType> onSelect;
  final String keyPrefix;
  final double cellWidth;
  final double cellHeight;
  final double spacing;
  final double runSpacing;

  static const _labels = {
    SourceType.photons: 'Photons',
    SourceType.electrons: 'Electrons',
    SourceType.neutrons: 'Neutrons',
    SourceType.heliumAtoms: 'Helium Atoms',
  };

  @override
  Widget build(BuildContext context) {
    // Always 2×2 (PhET SceneRadioButtonGroup). Do not use Wrap — FittedBox
    // gives unbounded width and would collapse to a 1×4 row.
    final types = SourceType.values;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cell(types[0]),
            SizedBox(width: spacing),
            _cell(types[1]),
          ],
        ),
        SizedBox(height: runSpacing),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _cell(types[2]),
            SizedBox(width: spacing),
            _cell(types[3]),
          ],
        ),
      ],
    );
  }

  Widget _cell(SourceType t) {
    final sel = t == active;
    return Semantics(
      button: true,
      selected: sel,
      label: _labels[t],
      child: SizedBox(
        width: cellWidth,
        height: cellHeight,
        child: Material(
          color: sel ? const Color(0xFFE8F1FB) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            key: ValueKey('${keyPrefix}_$t'),
            onTap: () => onSelect(t),
            borderRadius: BorderRadius.circular(6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: sel ? const Color(0xFF5BA3E0) : QwiColors.panelStroke,
                  width: sel ? 2 : 1,
                ),
                boxShadow: sel
                    ? const [
                        BoxShadow(color: Color(0x665BA3E0), blurRadius: 6),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    QwiAssets.particleIcon(t),
                    width: cellHeight < 56 ? 18 : 22,
                    height: cellHeight < 56 ? 18 : 22,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: cellHeight < 56 ? 2 : 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      _labels[t]!,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: cellHeight < 56 ? 8 : 9,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: Colors.black87,
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
