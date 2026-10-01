import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/make_isotopes_constants.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/make_isotopes_model.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/nucleon_particle.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/sphere_bucket_layout.dart';

void main() {
  group('Bucket state', () {
    test('initial bucket has 4 unique neutrons with stack positions', () {
      final m = MakeIsotopesModel();
      expect(m.bucketNeutrons, hasLength(4));
      final ids = m.bucketNeutrons.map((n) => n.id).toSet();
      expect(ids, hasLength(4));
      for (final n in m.bucketNeutrons) {
        expect(n.kind, NucleonKind.neutron);
        expect(n.container, NeutronContainer.bucket);
      }
      // Deterministic first-open stack: same model → same positions
      final m2 = MakeIsotopesModel();
      for (var i = 0; i < 4; i++) {
        expect(m.bucketNeutrons[i].x, m2.bucketNeutrons[i].x);
        expect(m.bucketNeutrons[i].y, m2.bucketNeutrons[i].y);
      }
    });

    test('bucket positions match SphereBucket firstOpen formula', () {
      final m = MakeIsotopesModel();
      final expected = <({double x, double y})>[];
      final placed = <NucleonParticle>[];
      for (var i = 0; i < 4; i++) {
        final pos = SphereBucketLayout.firstOpenPosition(
          bucketPosition: m.bucketPosition,
          bucketWidth: kNeutronBucketWidth,
          sphereRadius: kNucleonRadius,
          occupiedDestinations: [
            for (final p in placed) p.destination,
          ],
        );
        expected.add((x: pos.x, y: pos.y));
        placed.add(NucleonParticle(id: i, kind: NucleonKind.neutron)
          ..placeAt(pos.x, pos.y));
      }
      for (var i = 0; i < 4; i++) {
        expect(m.bucketNeutrons[i].x, expected[i].x);
        expect(m.bucketNeutrons[i].y, expected[i].y);
      }
    });

    test('bucket → nucleus preserves identity; no auto-refill', () {
      final m = MakeIsotopesModel();
      final id = m.bucketNeutrons.last.id;
      expect(m.addNeutron(), isTrue);
      expect(m.bucketNeutronCount, 3);
      expect(m.neutronCount, 1);
      expect(m.nucleusNeutrons.single.id, id);
      expect(m.nucleusNeutrons.single.container, NeutronContainer.nucleus);
      // No refill — total conserved at mostCommon(0)+4
      expect(m.totalNeutronCount, 4);
    });

    test('nucleus → bucket preserves identity', () {
      final m = MakeIsotopesModel()..selectElement(6);
      final id = m.nucleusNeutrons.last.id;
      expect(m.removeNeutron(), isTrue);
      expect(m.bucketNeutrons.any((n) => n.id == id), isTrue);
      expect(
        m.bucketNeutrons.firstWhere((n) => n.id == id).container,
        NeutronContainer.bucket,
      );
    });
  });

  group('Drag contract', () {
    test('begin/update/end capture keeps same particle id', () {
      final m = MakeIsotopesModel();
      final id = m.bucketNeutrons.first.id;
      expect(m.beginDrag(id, 0, 0), isTrue);
      expect(m.draggingNeutron!.id, id);
      expect(m.bucketNeutronCount, 3);
      expect(m.grabOffsetX, 0);
      expect(m.grabOffsetY, 0);

      m.updateDrag(10, 20);
      expect(m.draggingNeutron!.x, 10);
      expect(m.draggingNeutron!.y, 20);
      expect(m.neutronCount, 0); // counts unchanged during drag

      expect(m.endDrag(), isTrue); // at atom (0,0) → capture
      expect(m.neutronCount, 1);
      expect(m.nucleusNeutrons.single.id, id);
      expect(m.isDragging, isFalse);
    });

    test('invalid release returns to bucket', () {
      final m = MakeIsotopesModel();
      final id = m.bucketNeutrons.first.id;
      m.beginDrag(id, 0, 0);
      m.updateDrag(500, 500);
      expect(m.endDrag(), isFalse);
      expect(m.neutronCount, 0);
      expect(m.bucketNeutronCount, 4);
      expect(m.bucketNeutrons.any((n) => n.id == id), isTrue);
    });

    test('grab offset is zero (ParticleView applyOffset:false)', () {
      final m = MakeIsotopesModel();
      final n = m.bucketNeutrons.first;
      m.beginDrag(n.id, 42, 43);
      expect(m.grabOffsetX, 0);
      expect(m.grabOffsetY, 0);
      expect(m.draggingNeutron!.x, 42);
      expect(m.draggingNeutron!.y, 43);
    });
  });

  group('Capture boundary', () {
    test('distance 99.9 / 100 / 100.1 via endDrag', () {
      final m = MakeIsotopesModel();

      // 99.9 → capture
      var id = m.bucketNeutrons.first.id;
      m.beginDrag(id, 99.9, 0);
      expect(m.endDrag(), isTrue);
      expect(m.neutronCount, 1);

      // 100.0 → bucket (strict <)
      id = m.bucketNeutrons.first.id;
      m.beginDrag(id, 100.0, 0);
      expect(m.endDrag(), isFalse);
      expect(m.neutronCount, 1);

      // 100.1 → bucket
      id = m.bucketNeutrons.first.id;
      m.beginDrag(id, 100.1, 0);
      expect(m.endDrag(), isFalse);
      expect(m.neutronCount, 1);
    });
  });
}
