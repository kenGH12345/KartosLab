import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/molecule_polarity/model/mp_preferences.dart';
import 'package:kratos/chemistry/molecule_polarity/model/real_molecules/real_molecule_surface_colors.dart';
import 'package:kratos/chemistry/molecule_polarity/model/real_molecules/real_molecules_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RealMolecules mesh catalog', () {
    test('loads original all-molecules mesh for HF and applies origin', () async {
      final catalog = await RealMoleculeCatalog.load();
      final hf = catalog.molecules.firstWhere((m) => m.symbol == 'HF');
      expect(hf.mesh, isNotNull);
      expect(hf.mesh!.vertexCount, greaterThan(100));
      expect(hf.mesh!.faceIndices, isNotEmpty);
      // HF centers on F → F at origin after offset.
      final f = hf.atoms.firstWhere((a) => a.symbol == 'F');
      expect(f.x, closeTo(0, 1e-9));
      expect(f.y, closeTo(0, 1e-9));
      expect(f.z, closeTo(0, 1e-9));
    });

    test('quaternion rotates mesh with molecule (shared transform)', () async {
      final catalog = await RealMoleculeCatalog.load();
      final model = RealMoleculesModel(catalog: catalog);
      expect(model.molecule.symbol, 'HF');
      final before = model.molecule.mesh!.positions[0];
      model.applyDrag(40, 0);
      expect(model.quaternion.y.abs(), greaterThan(0.01));
      // Mesh data itself unchanged — only quaternion drives view.
      expect(model.molecule.mesh!.positions[0], before);
      model.reset();
      expect(model.quaternion.y.abs(), greaterThan(0.5)); // HF initial Y rot
      expect(model.viewProperties.surfaceType, SurfaceType.none);
    });

    test('basic ESP uses Coulomb sum; advanced uses vertex values', () async {
      final catalog = await RealMoleculeCatalog.load();
      final hf = catalog.molecules.firstWhere((m) => m.symbol == 'HF');
      final mesh = hf.mesh!;
      final i = 0;
      final x = mesh.positions[0];
      final y = mesh.positions[1];
      final z = mesh.positions[2];
      final basic = hf.sampleSurfaceValue(
        SurfaceType.electrostaticPotential,
        isAdvanced: false,
        vertexIndex: i,
        x: x,
        y: y,
        z: z,
      );
      final advanced = hf.sampleSurfaceValue(
        SurfaceType.electrostaticPotential,
        isAdvanced: true,
        vertexIndex: i,
        x: x,
        y: y,
        z: z,
      );
      expect(basic, isNot(advanced));
      expect(advanced, mesh.espValues[i]);
    });

    test('HF applies customization initialRotation (Y 90°)', () async {
      final catalog = await RealMoleculeCatalog.load();
      final model = RealMoleculesModel(catalog: catalog);
      // THREE.Quaternion(0, -√2/2, 0, √2/2)
      expect(model.quaternion.x, closeTo(0, 1e-9));
      expect(model.quaternion.y, closeTo(-math.sqrt1_2, 1e-9));
      expect(model.quaternion.z, closeTo(0, 1e-9));
      expect(model.quaternion.w, closeTo(math.sqrt1_2, 1e-9));
      // After rotation, H and F should separate in XY (not stacked on Z).
      final f = model.molecule.atoms.firstWhere((a) => a.symbol == 'F');
      final h = model.molecule.atoms.firstWhere((a) => a.symbol == 'H');
      final rf = model.quaternion.rotate(f.x, f.y, f.z);
      final rh = model.quaternion.rotate(h.x, h.y, h.z);
      final dx = rh[0] - rf[0];
      final dy = rh[1] - rf[1];
      expect(math.sqrt(dx * dx + dy * dy), greaterThan(0.5));
    });

    test('empty space is not a grab; grabbed H follows pointer', () async {
      final catalog = await RealMoleculeCatalog.load();
      final model = RealMoleculesModel(catalog: catalog);
      const center = Offset(400, 300);
      expect(model.hitTestAtom(const Offset(10, 10), center), isNull);

      final hIndex =
          model.molecule.atoms.indexWhere((a) => a.symbol == 'H');
      expect(hIndex, greaterThanOrEqualTo(0));
      final h = model.molecule.atoms[hIndex];
      Offset hScreen() {
        final r = model.quaternion.rotate(h.x, h.y, h.z);
        return Offset(
          center.dx + r[0] * RealMoleculesModel.viewScale,
          center.dy - r[1] * RealMoleculesModel.viewScale,
        );
      }

      expect(model.hitTestAtom(hScreen(), center), hIndex);
      final p0 = hScreen();
      model.applyArcball(p0, p0 + const Offset(0, 50), center);
      final p1 = hScreen();
      expect(p1.dy, greaterThan(p0.dy));
    });

    test('surface colorizers return opaque colors', () {
      final rwb = RealMoleculeSurfaceColors.colorizeElectrostaticPotentialRwb(0.1);
      expect(rwb.a, 1.0);
      final dens = RealMoleculeSurfaceColors.colorizeJavaElectronDensity(0.05);
      expect(dens.a, 1.0);
    });
  });
}
