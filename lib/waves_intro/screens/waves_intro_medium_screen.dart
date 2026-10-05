import 'package:flutter/material.dart';

import '../model/scene_kind.dart';
import '../model/waves_intro_model.dart';
import '../view/waves_intro_shell.dart';
import '../waves_intro_constants.dart';

/// One medium screen shell — delegates to screen-specific views inside [WavesIntroShell].
class WavesIntroMediumScreen extends StatefulWidget {
  const WavesIntroMediumScreen({
    super.key,
    required this.kind,
    this.embedded = false,
  });

  final SceneKind kind;
  final bool embedded;

  @override
  State<WavesIntroMediumScreen> createState() => _WavesIntroMediumScreenState();
}

class _WavesIntroMediumScreenState extends State<WavesIntroMediumScreen>
    with SingleTickerProviderStateMixin {
  late WavesIntroModel model;

  @override
  void initState() {
    super.initState();
    model = WavesIntroModel(kind: widget.kind, vsync: this);
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = WavesIntroPlayArea(model: model);
    final canvas = ColoredBox(
      color: Colors.white,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: WavesIntroConstants.layoutWidth,
            height: WavesIntroConstants.layoutHeight,
            child: body,
          ),
        ),
      ),
    );
    if (widget.embedded) return canvas;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(widget.kind)),
        backgroundColor: Color(_accentFor(widget.kind)),
        foregroundColor: Colors.white,
      ),
      body: canvas,
    );
  }

  static String _titleFor(SceneKind kind) {
    switch (kind) {
      case SceneKind.water:
        return 'Water';
      case SceneKind.sound:
        return 'Sound';
      case SceneKind.light:
        return 'Light';
    }
  }

  static int _accentFor(SceneKind kind) {
    switch (kind) {
      case SceneKind.water:
        return WavesIntroConstants.waterAccent.value;
      case SceneKind.sound:
        return WavesIntroConstants.soundAccent.value;
      case SceneKind.light:
        return WavesIntroConstants.lightAccent.value;
    }
  }
}

/// Public play-area entry (tests / Visual QA).
class WavesIntroPlayArea extends StatelessWidget {
  const WavesIntroPlayArea({super.key, required this.model});

  final WavesIntroModel model;

  @override
  Widget build(BuildContext context) => WavesIntroShell(model: model);
}
