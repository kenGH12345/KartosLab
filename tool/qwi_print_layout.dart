import 'package:kratos/physics/quantum_wave_interference/view/layout/experiment_layout_spec.dart';

void main() {
  final s = ExperimentLayoutSpec.resolve();
  void p(String n, dynamic r) {
    print('$n: L=${r.left.toStringAsFixed(1)} T=${r.top.toStringAsFixed(1)} '
        'W=${r.width.toStringAsFixed(1)} H=${r.height.toStringAsFixed(1)} '
        'R=${r.right.toStringAsFixed(1)} B=${r.bottom.toStringAsFixed(1)}');
  }

  print('canvas ${s.canvas.width}x${s.canvas.height}');
  print('middleCenterX ${s.middleCenterX}');
  p('source', s.sourcePanel);
  p('radios', s.sceneRadios);
  p('slitView', s.slitView);
  p('slitPanel', s.slitPanel);
  p('detector', s.detector);
  p('screenCtrl', s.screenControls);
  p('graph', s.graph);
  p('reset', s.reset);
  print('slit∩detector X=${(s.slitView.right - s.detector.left).toStringAsFixed(1)}');
  print('slitPanel∩screenCtrl X=${(s.slitPanel.right - s.screenControls.left).toStringAsFixed(1)}');
  print('slitPanel∩radios X=${(s.slitPanel.right - s.sceneRadios.left).clamp(0, 999)} '
      'overlapW=${((s.slitPanel.left < s.sceneRadios.right && s.sceneRadios.left < s.slitPanel.right) ? (s.slitPanel.left < s.sceneRadios.left ? s.sceneRadios.right : s.slitPanel.right) - (s.slitPanel.left < s.sceneRadios.left ? s.slitPanel.left : s.sceneRadios.left) : 0)}');
  print('slitPanel∩radios Y overlap='
      '${!(s.slitPanel.bottom <= s.sceneRadios.top || s.sceneRadios.bottom <= s.slitPanel.top)}');
}
