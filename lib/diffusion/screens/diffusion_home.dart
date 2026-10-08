import 'package:flutter/material.dart';

import '../../common/widgets/nine_grid_layout.dart';
import '../diffusion_constants.dart';
import '../model/diffusion_model.dart';
import '../widgets/diffusion_shell.dart';
import 'package:kratos/diffusion/diffusion_strings.dart';

class DiffusionHome extends StatefulWidget {
  const DiffusionHome({super.key});

  static const String title = DiffusionStrings.title;
  static const Color accentColor = Color(0xFF00838F);

  @override
  State<DiffusionHome> createState() => _DiffusionHomeState();
}

class _DiffusionHomeState extends State<DiffusionHome> {
  late final DiffusionModel model;

  @override
  void initState() {
    super.initState();
    model = DiffusionModel();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(DiffusionHome.title),
        backgroundColor: DiffusionHome.accentColor,
        foregroundColor: Colors.white,
      ),
      body: ColoredBox(
        color: const Color(0xFF2C2C2C),
        child: NineGridLayout(
          backgroundColor: const Color(0xFF2C2C2C),
          center: LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: DiffusionConstants.layoutWidth,
                  height: DiffusionConstants.layoutHeight,
                  child: DiffusionShell(model: model),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
