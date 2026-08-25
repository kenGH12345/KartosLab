import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/geometry/hit_test.dart';

/// pointToSegmentDistance 等价性锚定：必须逐位复现 circuit 两份旧实现的数学
/// （死代码版 `_pointToSegmentDistance` 与生效版内联公式，见技术方案 §2.1）。
void main() {
  group('① 水平线段垂足', () {
    test('中点正上方 10px', () {
      expect(
        pointToSegmentDistance(const Offset(50, 10), const Offset(0, 0), const Offset(100, 0)),
        10,
      );
    });

    test('线段上（距离 0）', () {
      expect(
        pointToSegmentDistance(const Offset(70, 0), const Offset(0, 0), const Offset(100, 0)),
        0,
      );
    });
  });

  group('② 延长线外 clamp 到端点', () {
    test('超出 b 端：距离 = 到 b 的距离', () {
      // p 在 (150, 20)，t 会算出 >1，clamp 到 b=(100,0) → 距离 = √(50²+20²)
      expect(
        pointToSegmentDistance(const Offset(150, 20), const Offset(0, 0), const Offset(100, 0)),
        closeTo(53.85164807134504, 1e-9),
      );
    });

    test('超出 a 端：距离 = 到 a 的距离', () {
      expect(
        pointToSegmentDistance(const Offset(-30, -40), const Offset(0, 0), const Offset(100, 0)),
        50,
      );
    });
  });

  group('③ 零长线段退化', () {
    test('a == b：距离 = |p - a|', () {
      expect(
        pointToSegmentDistance(const Offset(3, 4), const Offset(10, 10), const Offset(10, 10)),
        9.219544457292887, // √(7² + 6²) = √85
      );
    });

    test('p 也重合：距离 0', () {
      expect(
        pointToSegmentDistance(const Offset(5, 5), const Offset(5, 5), const Offset(5, 5)),
        0,
      );
    });
  });

  group('④ 斜线段通用值', () {
    test('45° 线段 (0,0)-(100,100)，点 (60,40) 垂足距离 = |60-40|/√2', () {
      final d = pointToSegmentDistance(
        const Offset(60, 40),
        const Offset(0, 0),
        const Offset(100, 100),
      );
      expect(d, closeTo(20 / 1.4142135623730951, 1e-9));
    });

    test('3-4-5 三角形：点 (3,4) 到线段 (0,0)-(6,0) 距离 4', () {
      expect(
        pointToSegmentDistance(const Offset(3, 4), const Offset(0, 0), const Offset(6, 0)),
        4,
      );
    });
  });

  group('⑤ 与旧内联公式对拍（同输入同输出）', () {
    // 旧 circuit_screen.dart 生效版内联数学（迁移前快照），逐位对拍
    double legacyInline(Offset p, Offset a, Offset b) {
      final ab = b - a;
      final ap = p - a;
      final ls = ab.dx * ab.dx + ab.dy * ab.dy;
      var t = 0.0;
      if (ls != 0) t = ((ap.dx * ab.dx) + (ap.dy * ab.dy)) / ls;
      if (t < 0) t = 0;
      if (t > 1) t = 1;
      final cx = a.dx + ab.dx * t;
      final cy = a.dy + ab.dy * t;
      final dx = p.dx - cx;
      final dy = p.dy - cy;
      return dx * dx + dy * dy; // 平方距离（旧版用 < 15² 比较，此处与 sqrt 后对拍）
    }

    test('采样网格逐位一致（含退化/延长线情形）', () {
      const pts = [
        Offset(0, 0), Offset(5, 5), Offset(-3, 12), Offset(150, -20),
        Offset(50, 3), Offset(101, 0.5), Offset(-10, -10), Offset(7, 9),
      ];
      const segs = [
        (Offset(0, 0), Offset(100, 0)),      // 水平
        (Offset(0, 0), Offset(100, 100)),    // 45°
        (Offset(10, 10), Offset(10, 10)),    // 零长
        (Offset(-20, 30), Offset(80, -40)),  // 任意斜线
      ];
      for (final p in pts) {
        for (final (a, b) in segs) {
          final mine = pointToSegmentDistance(p, a, b);
          final legacy = legacyInline(p, a, b);
          expect(mine * mine, closeTo(legacy, 1e-9),
              reason: 'p=$p a=$a b=$b mine=$mine legacySq=$legacy');
        }
      }
    });
  });
}
