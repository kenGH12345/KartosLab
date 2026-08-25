import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/geometry/projection.dart';

/// 等价性锚定单测：统一 SceneProjection 必须逐位复现两套旧投影的语义。
/// 旧 CanvasProjection（origin=(w/2, h*0.55) + scale）与
/// 旧 SceneProjection（origin 注入 + scale × zoom）在 MT-3 迁移后均由本类承担。
void main() {
  // 画布 800×1000：旧 CanvasProjection 的 origin = (400, 550)
  const canvasOrigin = Offset(400, 550);

  group('① 旧 CanvasProjection 语义等价（optics · origin=(w/2,h*0.55) · scale=20）', () {
    const proj = SceneProjection(origin: canvasOrigin, scale: 20);

    test('toScreen = origin + world × 20（采样点）', () {
      // 手算期望：origin + w×20
      expect(proj.toScreen(const Offset(0, 0)), const Offset(400, 550));
      expect(proj.toScreen(const Offset(1, 1)), const Offset(420, 570));
      expect(proj.toScreen(const Offset(-3, 2.5)), const Offset(340, 600));
      expect(proj.toScreen(const Offset(10, -20)), const Offset(600, 150));
    });

    test('toWorld = (screen - origin) / 20（采样点）', () {
      expect(proj.toWorld(const Offset(400, 550)), const Offset(0, 0));
      expect(proj.toWorld(const Offset(420, 570)), const Offset(1, 1));
      expect(proj.toWorld(const Offset(340, 600)), const Offset(-3, 2.5));
      expect(proj.toWorld(const Offset(600, 150)), const Offset(10, -20));
    });

    test('toWorld(toScreen(p)) == p（往返恒等 · scale=20）', () {
      for (final p in const [
        Offset(0, 0),
        Offset(-12.5, 7.25),
        Offset(30, -44),
      ]) {
        final round = proj.toWorld(proj.toScreen(p));
        expect((round - p).distance, lessThan(1e-9), reason: 'world=$p');
      }
    });
  });

  group('② 旧 SceneProjection 语义等价（circuit · scale=1 · zoom 三档）', () {
    // circuit 语义：origin=(w/2, h/2)，如 800×600 画布 → (400, 300)
    const center = Offset(400, 300);

    for (final zoom in [0.6, 1.0, 2.0]) {
      test('zoom=$zoom：toScreen/toWorld 往返恒等 + 公式核对', () {
        final proj = SceneProjection(origin: center, scale: 1, zoom: zoom);

        // 公式核对：screen = world × zoom + origin
        expect(
          proj.toScreen(const Offset(50, -25)),
          Offset(400 + 50 * zoom, 300 - 25 * zoom),
        );
        // 公式核对：world = (screen - origin) / zoom
        expect(
          proj.toWorld(const Offset(500, 350)),
          Offset(100 / zoom, 50 / zoom),
        );
        // 往返恒等
        for (final p in const [
          Offset(0, 0),
          Offset(-80, 120),
          Offset(260, -190),
        ]) {
          final round = proj.toWorld(proj.toScreen(p));
          expect((round - p).distance, lessThan(1e-9), reason: 'zoom=$zoom world=$p');
        }
      });
    }
  });

  group('③ toScreenLength = world × scale × zoom', () {
    test('scale=1 zoom=1：恒等', () {
      const proj = SceneProjection(origin: Offset.zero);
      expect(proj.toScreenLength(42.5), 42.5);
    });

    test('scale=20 zoom=1（optics）', () {
      const proj = SceneProjection(origin: Offset.zero, scale: 20);
      expect(proj.toScreenLength(3), 60);
    });

    test('scale=1 zoom=2（circuit 极值）', () {
      const proj = SceneProjection(origin: Offset.zero, zoom: 2);
      expect(proj.toScreenLength(15), 30);
    });
  });

  group('④ 默认参数', () {
    test('scale/zoom 默认 1.0，effectiveScale = scale × zoom', () {
      const proj = SceneProjection(origin: Offset(10, 20));
      expect(proj.scale, 1.0);
      expect(proj.zoom, 1.0);
      expect(proj.effectiveScale, 1.0);

      const combo = SceneProjection(origin: Offset.zero, scale: 20, zoom: 2.0);
      expect(combo.effectiveScale, 40.0);
    });
  });

  group('⑤ 组合极值防呆（optics scale=20 × zoom=2.0）', () {
    const proj = SceneProjection(origin: canvasOrigin, scale: 20, zoom: 2.0);

    test('有效比例 = 40：toScreen/toWorld 公式核对', () {
      expect(proj.toScreen(const Offset(5, -5)), const Offset(400 + 200, 550 - 200));
      expect(proj.toWorld(const Offset(600, 350)), const Offset(5, -5));
      expect(proj.toScreenLength(10), 400);
    });
  });
}
