import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../controller/intro_controller.dart';
import '../controller/lab_controller.dart';
import '../painters/peg_raster.dart';
import '../plinko_strings.dart';
import 'intro_screen.dart';
import 'lab_screen.dart';

/// Plinko Probability tabbed home (Intro | Lab) — wired into KARTOSLAB Home.
class PlinkoProbabilityHome extends StatefulWidget {
  const PlinkoProbabilityHome({super.key});

  static const String title = PlinkoStrings.title;
  static const String subtitle = PlinkoStrings.subtitle;
  static const Color accentColor = Color(0xFFE91E24);

  @override
  State<PlinkoProbabilityHome> createState() => _PlinkoProbabilityHomeState();
}

class _PlinkoProbabilityHomeState extends State<PlinkoProbabilityHome>
    with TickerProviderStateMixin {
  late final IntroController _intro;
  late final LabController _lab;
  bool _pegReady = PegRaster.isReady;

  @override
  void initState() {
    super.initState();
    _intro = IntroController();
    _lab = LabController();
    _intro.attach(this);
    _lab.attach(this);
    if (!_pegReady) {
      PegRaster.ensureLoaded().then((_) {
        if (mounted) setState(() => _pegReady = true);
      });
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _lab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: PlinkoProbabilityHome.title,
      accentColor: PlinkoProbabilityHome.accentColor,
      tabs: [
        KratosTab(
          label: PlinkoStrings.intro,
          child: IntroScreen(controller: _intro),
        ),
        KratosTab(
          label: PlinkoStrings.lab,
          child: LabScreen(controller: _lab),
        ),
      ],
    );
  }
}
