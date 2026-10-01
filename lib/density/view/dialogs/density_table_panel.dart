import 'package:flutter/material.dart';

import '../../data/mystery_sets.dart';
import '../../density_colors.dart';
import '../../density_strings.dart';

/// Mystery screen reference table — AccordionBox + 13-row grid (PhET
/// `DensityTableNode.ts`).
class DensityTablePanel extends StatelessWidget {
  const DensityTablePanel({
    super.key,
    required this.expanded,
    required this.onExpandedChanged,
    this.maxBodyHeight = 400,
  });

  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final double maxBodyHeight;

  @override
  Widget build(BuildContext context) {
    final rows = DensityTable.rows();
    return Material(
      color: const Color(DensityColors.panelBackground),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: onExpandedChanged,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        childrenPadding: EdgeInsets.zero,
        title: Text(
          DensityStrings.densityTable,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxBodyHeight),
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: const Color(0xFF111827)),
                columnWidths: const {
                  0: FlexColumnWidth(1.4),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(DensityColors.chartHeader),
                    ),
                    children: [
                      _cell(DensityStrings.material, header: true),
                      _cell(DensityStrings.kgPerL, header: true, alignRight: true),
                    ],
                  ),
                  for (final row in rows)
                    TableRow(
                      decoration: const BoxDecoration(color: Colors.white),
                      children: [
                        _cell(DensityStrings.materialName(row.material.stringKey)),
                        _cell(row.kgPerLiterDisplay, alignRight: true),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, {bool header = false, bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 12,
          fontWeight: header ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
