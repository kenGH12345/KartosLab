import 'package:flutter/material.dart';

import '../model/more_tools_model.dart';
import '../qa_launch.dart';
import '../view/more_tools_play_area.dart';
import 'bending_light_scene_shell.dart';

class MoreToolsScreen extends StatefulWidget {
  const MoreToolsScreen({super.key, this.embedded = false});

  /// Home embeds the play area. The QA AppBar stays on the demo route only.
  final bool embedded;

  @override
  State<MoreToolsScreen> createState() => _MoreToolsScreenState();
}

class _MoreToolsScreenState extends State<MoreToolsScreen> {
  late final MoreToolsModel model = MoreToolsModel();

  @override
  void initState() {
    super.initState();
    switch (qaCapture) {
      case 'graph':
        applyGraphCapture(model);
      case 'sensors':
        applySensorsCapture(model);
    }
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = BendingLightSceneShell(
      child: MoreToolsPlayArea(model: model),
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Bending Light — More Tools')),
      body: body,
    );
  }
}
