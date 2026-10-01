import 'package:flutter/material.dart';

import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import '../controller/molecule_polarity_controller.dart';
import '../mp_assets.dart';
import '../mp_colors.dart';
import '../mp_strings.dart';
import 'real_molecules_screen.dart';
import 'three_atoms_screen.dart';
import 'two_atoms_screen.dart';

/// Molecule Polarity entry (wired from Home → 化学 → 分子极性).
class MoleculePolarityHome extends StatefulWidget {
  const MoleculePolarityHome({super.key, this.controller});

  final MoleculePolarityController? controller;

  static const String title = MpStrings.title;
  static const Color accentColor = Color(0xFF3B82F6);

  @override
  State<MoleculePolarityHome> createState() => _MoleculePolarityHomeState();
}

class _MoleculePolarityHomeState extends State<MoleculePolarityHome>
    with TickerProviderStateMixin {
  late final MoleculePolarityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MoleculePolarityController.shared();
    _controller.attachClock(this);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.disposeClock();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: MoleculePolarityHome.title,
      accentColor: MoleculePolarityHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: MpStrings.twoAtoms,
          tabIcon: _twoAtomsIcon(),
          child: TwoAtomsScreenBody(controller: _controller),
        ),
        KratosTab(
          label: MpStrings.threeAtoms,
          tabIcon: _threeAtomsIcon(),
          child: ThreeAtomsScreenBody(controller: _controller),
        ),
        KratosTab(
          label: MpStrings.realMolecules,
          tabIcon: Image.asset(
            MpAssets.realMoleculesScreenIcon,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          child: RealMoleculesScreenBody(controller: _controller),
        ),
      ],
    );
  }

  Widget _twoAtomsIcon() {
    return CustomPaint(
      size: const Size(40, 24),
      painter: _DiatomicIconPainter(),
    );
  }

  Widget _threeAtomsIcon() {
    return CustomPaint(
      size: const Size(40, 28),
      painter: _TriatomicIconPainter(),
    );
  }
}

class _DiatomicIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final a = Offset(size.width * 0.28, size.height * 0.5);
    final b = Offset(size.width * 0.72, size.height * 0.5);
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = MpColors.bond
        ..strokeWidth = 4,
    );
    canvas.drawCircle(a, 8, Paint()..color = MpColors.atomA);
    canvas.drawCircle(b, 8, Paint()..color = MpColors.atomB);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TriatomicIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final b = Offset(size.width * 0.5, size.height * 0.55);
    final a = Offset(size.width * 0.2, size.height * 0.75);
    final c = Offset(size.width * 0.8, size.height * 0.75);
    final paint = Paint()
      ..color = MpColors.bond
      ..strokeWidth = 3;
    canvas.drawLine(a, b, paint);
    canvas.drawLine(b, c, paint);
    canvas.drawCircle(a, 6, Paint()..color = MpColors.atomA);
    canvas.drawCircle(b, 7, Paint()..color = MpColors.atomB);
    canvas.drawCircle(c, 6, Paint()..color = MpColors.atomC);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
