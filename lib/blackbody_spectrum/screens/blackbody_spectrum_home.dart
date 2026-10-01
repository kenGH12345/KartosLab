import 'package:flutter/material.dart';

import '../blackbody_spectrum_colors.dart';
import '../blackbody_spectrum_strings.dart';
import '../model/blackbody_spectrum_model.dart';
import 'blackbody_spectrum_screen_body.dart';

/// Home entry for Blackbody Spectrum (single screen).
class BlackbodySpectrumHome extends StatefulWidget {
  const BlackbodySpectrumHome({super.key});

  static const String title = BlackbodySpectrumStrings.title;
  static const Color accentColor = BlackbodySpectrumColors.background;

  @override
  State<BlackbodySpectrumHome> createState() => BlackbodySpectrumHomeState();
}

class BlackbodySpectrumHomeState extends State<BlackbodySpectrumHome> {
  late BlackbodySpectrumModel model;

  @override
  void initState() {
    super.initState();
    model = BlackbodySpectrumModel();
  }

  void reinitializeForTest() {
    setState(() {
      model.dispose();
      model = BlackbodySpectrumModel();
    });
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar — simulation canvas must fill the entire screen.
      // PhET layoutBounds = 1024×768; we scale to fit available space.
      backgroundColor: BlackbodySpectrumColors.background,
      body: BlackbodySpectrumScreenBody(model: model),
    );
  }
}
