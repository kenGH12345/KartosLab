import 'package:flutter/material.dart';

import '../controller/inelastic_controller.dart';
import '../widgets/control_panel.dart';
import 'collision_lab_screen_body.dart';

class InelasticScreen extends StatefulWidget {
  const InelasticScreen({
    super.key,
    this.controller,
    this.embedded = false,
  });

  final InelasticController? controller;
  final bool embedded;

  @override
  State<InelasticScreen> createState() => _InelasticScreenState();
}

class _InelasticScreenState extends State<InelasticScreen> {
  late final InelasticController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? InelasticController();
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
      config: ControlPanelConfig.inelastic,
      embedded: widget.embedded,
    );
  }
}
