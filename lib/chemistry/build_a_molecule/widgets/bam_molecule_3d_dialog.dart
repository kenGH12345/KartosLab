import 'package:flutter/material.dart';

import '../bam_constants.dart';
import '../model/bam_complete_molecule.dart';
import 'bam_molecule_thumbnail.dart';

/// 3D molecule dialog. Canvas projection (Molecule3DNode semantics), not WebGL.
class BamMolecule3dDialog extends StatelessWidget {
  const BamMolecule3dDialog({super.key, required this.molecule});

  final BamCompleteMolecule molecule;

  static Future<void> show(BuildContext context, BamCompleteMolecule molecule) {
    return showDialog<void>(
      context: context,
      builder: (_) => BamMolecule3dDialog(molecule: molecule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = molecule.getDisplayName();
    final formula = molecule.getGeneralFormulaFragment();
    return Dialog(
      backgroundColor: Colors.black,
      child: SizedBox(
        width: 420,
        height: 480,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$name ($formula)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: BamConstants.completeBackgroundColor,
                child: BamMolecule3dView(molecule: molecule),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Drag to rotate · Space-fill',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
