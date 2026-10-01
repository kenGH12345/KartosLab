import 'package:flutter/material.dart';

import '../controller/intro_controller.dart';
import '../widgets/control_panel.dart';
import 'collision_lab_screen_body.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({
    super.key,
    this.controller,
    this.embedded = false,
  });

  final IntroController? controller;
  final bool embedded;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final IntroController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? IntroController();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CollisionLabScreenBody(
      controller: _controller,
      config: ControlPanelConfig.intro,
      embedded: widget.embedded,
    );
  }
}
