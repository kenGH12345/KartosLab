import 'package:flutter/material.dart';

import '../bam_constants.dart';
import '../controller/bam_controller.dart';
import '../widgets/bam_atom_inventory.dart';
import '../widgets/bam_molecule_viewport.dart';
import '../widgets/bam_your_molecules_panel.dart';

/// Page-level BAM layout matching PhET Single baseline:
/// ```
/// TopTabBar (outside, via KratosTabbedScreen)
/// MainArea
///   ├── MoleculeViewport (expanded)
///   └── YourMoleculesPanel (fixed fraction width)
/// AtomInventory (bottom)
/// ```
///
/// No Stack/Positioned covering regions — pure Column/Row fractions.
class BamScreenBody extends StatelessWidget {
  const BamScreenBody({
    super.key,
    required this.controller,
    this.showCollection = true,
    this.title,
    this.embedded = false,
  });

  final BamController controller;
  final bool showCollection;
  final String? title;
  final bool embedded;

  /// Right panel width as fraction of main row (source-anchored ~250/768 ≈ 0.32).
  static const double yourMoleculesWidthFraction = 0.28;

  /// Bottom inventory height as fraction of body (kit carousel + dots).
  static const double inventoryHeightFraction = 0.22;

  @override
  Widget build(BuildContext context) {
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final inventoryH = (constraints.maxHeight * inventoryHeightFraction)
            .clamp(132.0, 180.0);
        final panelW = showCollection
            ? (constraints.maxWidth * yourMoleculesWidthFraction)
                .clamp(200.0, 280.0)
            : 0.0;

        return ColoredBox(
          color: BamConstants.playAreaBackgroundColor,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: BamMoleculeViewport(controller: controller),
                    ),
                    if (showCollection)
                      SizedBox(
                        width: panelW,
                        child: BamYourMoleculesPanel(controller: controller),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: inventoryH,
                child: BamAtomInventory(controller: controller),
              ),
            ],
          ),
        );
      },
    );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Build a Molecule'),
        backgroundColor: BamConstants.playAreaBackgroundColor,
      ),
      body: body,
    );
  }
}
