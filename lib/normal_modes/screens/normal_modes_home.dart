import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../controller/one_dimension_controller.dart';
import '../controller/two_dimensions_controller.dart';
import '../normal_modes_colors.dart';
import '../normal_modes_strings.dart';
import 'one_dimension_screen.dart';
import 'two_dimensions_screen.dart';

class NormalModesHome extends StatefulWidget {
  const NormalModesHome({super.key});

  static const String title = NormalModesStrings.title;
  static const Color accentColor = NormalModesColors.accent;

  @override
  State<NormalModesHome> createState() => _NormalModesHomeState();
}

class _NormalModesHomeState extends State<NormalModesHome> {
  late final OneDimensionController _one;
  late final TwoDimensionsController _two;

  @override
  void initState() {
    super.initState();
    _one = OneDimensionController();
    _two = TwoDimensionsController();
  }

  @override
  void dispose() {
    _one.dispose();
    _two.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: NormalModesHome.title,
      accentColor: NormalModesHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: NormalModesStrings.oneDimension,
          child: OneDimensionScreen(controller: _one, embedded: true),
        ),
        KratosTab(
          label: NormalModesStrings.twoDimensions,
          child: TwoDimensionsScreen(controller: _two, embedded: true),
        ),
      ],
    );
  }
}
