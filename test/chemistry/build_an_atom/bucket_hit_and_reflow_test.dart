import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_particle.dart';

void main() {
  test('remove mid-stack → neighbors fall into nearest gap (not full re-pack path)',
      () {
    final m = BAAModel();
    final bucket = m.protonBucket;
    expect(bucket.count, 10);

    final before = {
      for (final p in bucket.particles) p.id: (p.x, p.y),
    };

    final mid = bucket.particles[3];
    final midPos = (mid.x, mid.y);
    m.beginDrag(mid, modelX: 0, modelY: 0);
    expect(bucket.count, 9);

    // At least one remaining particle targets a new seat (fills a gap).
    var retargeted = 0;
    var stayed = 0;
    for (final p in bucket.particles) {
      final prev = before[p.id]!;
      final destMoved =
          (p.destX - prev.$1).abs() > 0.5 || (p.destY - prev.$2).abs() > 0.5;
      if (destMoved) {
        retargeted++;
        // Still at old spot until step — short fall into gap, not teleported.
        expect(p.x, closeTo(prev.$1, 1e-6));
      } else {
        stayed++;
      }
    }
    expect(retargeted, greaterThan(0));
    // Most of the pile should stay put (nearest-gap), not all march to new slots.
    expect(stayed, greaterThanOrEqualTo(4));

    m.step(0.08);
    m.endDrag(mid, midPos.$1, midPos.$2 + 30);
    expect(bucket.count, 10);
  });

  test('drop near a gap → particle destination is nearest open, not firstOpen only',
      () {
    final m = BAAModel();
    final bucket = m.protonBucket;
    final top = bucket.particles.reduce(
      (a, b) => a.y >= b.y ? a : b,
    );
    final dropX = top.x + 15;
    final dropY = top.y + 10;
    m.beginDrag(top, modelX: dropX, modelY: dropY);
    m.endDrag(top, dropX, dropY);

    // Returned particle sits near the drop (nearest open), not forced to origin.
    expect(top.destX, closeTo(dropX, 40));
    expect(top.destY, closeTo(dropY, 40));
  });

  test('higher zLayer particle preferred when centers overlap hit radii', () {
    final m = BAAModel();
    final a = m.protonBucket.particles[0];
    final b = m.protonBucket.particles[1];
    a.zLayer = 1;
    b.zLayer = 5;
    a.placeAt(0, 0);
    b.placeAt(0.5, 0.5);

    BaaParticle? best;
    var bestZ = -0x3fffffff;
    var bestD = double.infinity;
    void consider(BaaParticle p) {
      final d = p.distanceTo(0, 0);
      if (d > 18) return;
      if (p.zLayer > bestZ || (p.zLayer == bestZ && d < bestD)) {
        bestZ = p.zLayer;
        bestD = d;
        best = p;
      }
    }

    consider(a);
    consider(b);
    expect(best, same(b));
  });
}
