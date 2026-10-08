import 'package:flutter/material.dart';

import '../model/intro_model.dart';
import '../model/substance.dart';
import '../view/intro_play_area.dart';
import 'bending_light_scene_shell.dart';
import 'package:kratos/bending_light/bl_strings.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, this.embedded = false});

  /// Home embeds the play area. The QA AppBar stays on the demo route only.
  final bool embedded;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final IntroModel model = IntroModel(
    bottomSubstance: Substance.water,
    horizontalPlayAreaOffset: true,
  );

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = BendingLightSceneShell(
      child: IntroPlayArea(model: model),
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text(BlStrings.titleIntro)),
      body: body,
    );
  }
}
