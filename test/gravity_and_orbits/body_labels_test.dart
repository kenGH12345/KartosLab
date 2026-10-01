import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/gravity_and_orbits/model/body_type.dart';
import 'package:kratos/astronomy/gravity_and_orbits/model/gao_model.dart';
import 'package:kratos/astronomy/gravity_and_orbits/painters/body_labels_painter.dart';
import 'package:kratos/astronomy/gravity_and_orbits/render/gao_mvt.dart';

void main() {
  test('To Scale starPlanet bodies are small enough for labels at default zoom',
      () {
    final model = GaoModel(isModelScreen: false);
    final mvt = GaoMvt.fromZoom(
      defaultZoomScale: model.scene.defaultZoomScale,
      zoomLevel: 1,
      gridCenter: model.scene.gridCenter,
    );
    for (final body in model.scene.bodies) {
      final d = mvt.modelDeltaToViewDelta(body.diameter).abs();
      expect(
        d,
        lessThanOrEqualTo(GaoBodyLabelsPainter.visibilityThreshold),
        reason: '${body.type} should show label on To Scale (d=$d)',
      );
    }
  });

  test('Model starPlanet bodies are large — labels hidden at default zoom', () {
    final model = GaoModel(isModelScreen: true);
    final mvt = GaoMvt.fromZoom(
      defaultZoomScale: model.scene.defaultZoomScale,
      zoomLevel: 1,
      gridCenter: model.scene.gridCenter,
    );
    final star =
        model.scene.bodies.firstWhere((b) => b.type == GaoBodyType.star);
    final d = mvt.modelDeltaToViewDelta(star.diameter).abs();
    expect(d, greaterThan(GaoBodyLabelsPainter.visibilityThreshold));
  });
}
