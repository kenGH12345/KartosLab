import 'package:flutter/material.dart';

import '../controller/explore1d_controller.dart';
import '../widgets/control_panel.dart';
import 'collision_lab_screen_body.dart';

class Explore1dScreen extends StatefulWidget {
  const Explore1dScreen({
    super.key,
    this.controller,
    this.embedded = false,
  });

  final Explore1dController? controller;
  final bool embedded;

  @override
  State<Explore1dScreen> createState() => _Explore1dScreenState();
}

class _Explore1dScreenState extends State<Explore1dScreen> {
  late final Explore1dController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? Explore1dController();
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
      config: ControlPanelConfig.explore1d,
      embedded: widget.embedded,
    );
  }
}
