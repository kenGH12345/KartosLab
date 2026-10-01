import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../molecule_shapes_strings.dart';
import '../view/model_molecules_screen.dart';
import '../view/molecule_shapes_colors.dart';
import '../view/real_molecules_screen.dart';

/// Home → 化学 → 分子形状 → Molecule Shapes entry.
///
/// Two independent screens (Model / Real Molecules). Each owns its model and
/// ticker; [KratosTabSwitcher] disables inactive tickers via [TickerMode].
class MoleculeShapesHome extends StatelessWidget {
  const MoleculeShapesHome({super.key});

  static const String title = MoleculeShapesStrings.title;
  static const String subtitle = 'Model · Real Molecules · VSEPR';
  static const Color accentColor = Color(0xFF9F66DA);

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      initialIndex: 0,
      tabs: const [
        KratosTab(
          label: MoleculeShapesStrings.screenModel,
          icon: Icons.science_outlined,
          child: ModelMoleculesScreen(),
        ),
        KratosTab(
          label: MoleculeShapesStrings.screenRealMolecules,
          icon: Icons.water_drop_outlined,
          child: RealMoleculesScreen(),
        ),
      ],
    );
  }
}

/// Tiny brand chip for documentation / tests — central + two bonded atoms.
class MoleculeShapesHomeIcon extends StatelessWidget {
  const MoleculeShapesHomeIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.7),
      painter: _MoleculeShapesHomeIconPainter(),
    );
  }
}

class _MoleculeShapesHomeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.45);
    final a = Offset(size.width * 0.18, size.height * 0.75);
    final b = Offset(size.width * 0.82, size.height * 0.75);
    final bond = Paint()
      ..color = Colors.white70
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, a, bond);
    canvas.drawLine(center, b, bond);
    canvas.drawCircle(a, 5, Paint()..color = Colors.white);
    canvas.drawCircle(b, 5, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      8,
      Paint()..color = MoleculeShapesColors.centralAtom,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
