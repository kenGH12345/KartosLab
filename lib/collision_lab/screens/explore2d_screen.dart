import 'package:flutter/material.dart';

import '../controller/explore2d_controller.dart';
import '../widgets/control_panel.dart';
import 'collision_lab_screen_body.dart';

class Explore2dScreen extends StatefulWidget {
  const Explore2dScreen({
    super.key,
    this.controller,
    this.embedded = false,
  });

  final Explore2dController? controller;
  final bool embedded;

  @override
  State<Explore2dScreen> createState() => _Explore2dScreenState();
}

class _Explore2dScreenState extends State<Explore2dScreen> {
  late final Explore2dController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? Explore2dController();
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
      config: ControlPanelConfig.explore2d,
      embedded: widget.embedded,
    );
  }
}
