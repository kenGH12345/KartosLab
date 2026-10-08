import 'package:flutter/material.dart';

import '../model/enums.dart';
import '../model/prisms_model.dart';
import '../qa_launch.dart';
import '../view/prisms_play_area.dart';
import 'bending_light_scene_shell.dart';
import 'package:kratos/bending_light/bl_strings.dart';

class PrismsScreen extends StatefulWidget {
  const PrismsScreen({super.key, this.embedded = false});

  /// Home embeds the play area. The QA AppBar stays on the demo route only.
  final bool embedded;

  @override
  State<PrismsScreen> createState() => _PrismsScreenState();
}

class _PrismsScreenState extends State<PrismsScreen> {
  late final PrismsModel model = PrismsModel();

  @override
  void initState() {
    super.initState();
    if (qaCapture == 'white') applyWhiteLightCapture(model);
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final white = model.laser.colorMode == ColorModeEnum.white;
        return BendingLightSceneShell(
          background: white ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          child: PrismsPlayArea(model: model),
        );
      },
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text(BlStrings.titlePrisms)),
      body: body,
    );
  }
}
