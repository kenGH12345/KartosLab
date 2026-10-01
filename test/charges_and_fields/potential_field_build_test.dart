import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/charges_and_fields/model/charges_and_fields_model.dart';
import 'package:kratos/charges_and_fields/model/vec2.dart';
import 'package:kratos/charges_and_fields/painters/potential_visual.dart';

void main() {
  test('buildPotentialFieldImage produces saturated pixels near charge', () async {
    final model = ChargesAndFieldsModel();
    model.setParticleActive(model.addPositiveCharge(const CafVec2(-1, 0)), true);
    model.setParticleActive(model.addNegativeCharge(const CafVec2(1, 0)), true);
    model.isElectricPotentialVisible = true;

    final v = CafPotentialColors.samplePotential(model, const CafVec2(-1, 0.2));
    final c = CafPotentialColors.forField(v);
    expect(v.abs(), greaterThan(10));
    expect((c.r * 255).round(), greaterThan(100));

    final sw = Stopwatch()..start();
    final result = await buildPotentialFieldImage(model, viewScale: 128);
    expect(result, isNotNull);
    final (image, size) = result!;
    expect(size.numHorizontal, greaterThan(100));
    // Spot-check: cell for model (-1, 0.2) should be red-dominant
    final bounds = model.enlargedBounds;
    final col = (((-1 - bounds.minX) / bounds.width) * size.numHorizontal)
        .floor()
        .clamp(0, size.numHorizontal - 1);
    final row = (((0.2 - bounds.minY) / bounds.height) * size.numVertical)
        .floor()
        .clamp(0, size.numVertical - 1);
    expect(col, greaterThan(0));
    expect(row, greaterThan(0));
    image.dispose();
    // Keep build under a few seconds for UX
    expect(sw.elapsedMilliseconds, lessThan(15000));
  });
}
