import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../common/widgets/property_control_panel.dart';
import '../../common/widgets/celebration_dialog.dart';
import '../../common/widgets/knowledge_panel.dart';
import '../../common/widgets/nine_grid_layout.dart';
import '../model/color_vision_state.dart';
import '../solver/color_model.dart';
import '../painters/potion_cauldron_painter.dart';
import '../painters/challenge_painter.dart';
import '../painters/color_wheel_painter.dart';
import '../config/color_vision_scenario.dart';

class MagicLabScreen extends StatefulWidget {
  const MagicLabScreen({super.key, this.scenario});
  final ColorVisionScenario? scenario;
  @override State<MagicLabScreen> createState() => _MagicLabScreenState();
}

enum LabMode { explore, challenge, wheel }

class _MagicLabScreenState extends State<MagicLabScreen> with TickerProviderStateMixin {
  late final ColorVisionState _state;
  Ticker? _bubbleTicker;
  double _bubblePhase = 0;
  LabMode _mode = LabMode.explore;
  bool _showLabels = true;

  double _canvasW = 0, _bottlesY = 0;
  static const double _bottleW = 52, _bottleH = 140, _bottleMargin = 18;

  final Random _rng = Random();
  late Color _targetColor;
  int _score = 0, _streak = 0, _level = 1, _timeLeft = 30;
  Ticker? _timerTicker;
  bool _challengeActive = false;

  Offset? _wheelPoint;
  Color _wheelColor = const Color(0xFF888888);
  double _wheelBrightness = 1.0;
  double _wheelCx = 0, _wheelCy = 0, _wheelR = 0;

  @override
  void initState() {
    super.initState();
    final s = widget.scenario;
    _state = ColorVisionState(beams: const [],
      redIntensity: s?.redIntensity ?? 100, greenIntensity: s?.greenIntensity ?? 100, blueIntensity: s?.blueIntensity ?? 100);
    _bubbleTicker = createTicker((_) => setState(() => _bubblePhase += 0.05))..start();
    _targetColor = _randomColor();
  }

  @override
  void dispose() {
    _bubbleTicker?.dispose(); _timerTicker?.dispose(); _state.dispose();
    super.dispose();
  }

  Color _randomColor() => Color.fromARGB(255, _rng.nextInt(256), _rng.nextInt(256), _rng.nextInt(256));

  void _startChallenge() {
    _targetColor = _randomColor();
    _state.updateIntensity(0, 0); _state.updateIntensity(1, 0); _state.updateIntensity(2, 0);
    _timeLeft = 30 + (_level - 1) * 5; _challengeActive = true;
    _timerTicker?.dispose();
    _timerTicker = createTicker((_) {
      if (!_challengeActive) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) { _timeLeft = 0; _challengeActive = false; _streak = 0; }
      });
    });
    _timerTicker!.start();
  }

  double _calcAccuracy() {
    final t = _targetColor, cur = _state.mixedColor;
    final dr = (t.r - cur.r).abs(), dg = (t.g - cur.g).abs(), db = (t.b - cur.b).abs();
    final acc = ((1 - sqrt(dr*dr + dg*dg + db*db) / sqrt(3.0)) * 100).clamp(0.0, 100.0);
    // 100% 精确匹配才算成功 · 弹喜庆弹框
    if (acc >= 99.99 && _challengeActive && mounted) {
      _challengeActive = false; _timerTicker?.stop();
      final earnedScore = (10 + _timeLeft).clamp(10, 50);
      // 延迟一帧再弹框,避免 build 期间 showDialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showCelebrationDialog(
          context,
          title: '挑战成功！',
          subtitle: '完美匹配 · +$earnedScore 分',
          accentColor: const Color(0xFFF97316),
          showcaseColor: _targetColor,
          primaryLabel: '下一关',
          secondaryLabel: '结束挑战',
          onPrimary: () {
            if (!mounted) return;
            setState(() {
              _score += earnedScore;
              _streak++;
              _level++;
              _startChallenge();
            });
          },
          onSecondary: () {
            if (!mounted) return;
            setState(() { _score += earnedScore; _streak++; _timeLeft = 0; });
          },
        );
      });
    }
    return acc;
  }

  int _hitBottle(double dx, double dy) {
    final bx0 = _canvasW / 2 - (_bottleW * 1.5 + _bottleMargin);
    for (int i = 0; i < 3; i++) {
      final x = bx0 + i * (_bottleW + _bottleMargin);
      if (dx >= x && dx <= x + _bottleW && dy >= _bottlesY && dy <= _bottlesY + _bottleH) return i;
    }
    return -1;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final idx = _hitBottle(d.localPosition.dx, d.localPosition.dy);
    if (idx < 0) return;
    final fy = (d.localPosition.dy - _bottlesY).clamp(0, _bottleH);
    setState(() => _state.updateIntensity(idx, ((1 - fy / _bottleH) * 100).clamp(0.0, 100.0)));
  }

  void _onWheelTap(TapDownDetails d) {
    final dx = d.localPosition.dx - _wheelCx, dy = d.localPosition.dy - _wheelCy;
    if (sqrt(dx*dx + dy*dy) > _wheelR) return;
    double hue = (atan2(dy, dx) * 180 / pi + 360) % 360;
    setState(() { _wheelPoint = d.localPosition; _wheelColor = HSVColor.fromAHSV(1.0, hue, (sqrt(dx*dx + dy*dy) / _wheelR).clamp(0.0, 1.0), _wheelBrightness).toColor(); });
  }

  void _switchMode(LabMode m) {
    setState(() { _mode = m;
      if (m == LabMode.challenge) { _startChallenge(); }
      else { _challengeActive = false; _timerTicker?.stop(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NineGridLayout(
      // 顶部中格 = 标题 + 模式切换
      topCenter: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('三原色魔法实验室',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF312E81))),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            alignment: WrapAlignment.center,
            children: [
              _modeBtn('自由探索', LabMode.explore, const Color(0xFFEF4444)),
              _modeBtn('挑战模式', LabMode.challenge, const Color(0xFFF97316)),
              _modeBtn('色轮探秘', LabMode.wheel, const Color(0xFFEC4899)),
            ],
          ),
        ],
      ),
      // 中间格 = 实验画面（三种模式）· 面积 ≥ 70% 屏 · 自适应
      center: _buildCanvas(),
      // 右侧边格 = 模式相关控制 · 竖排紧凑 · 窄条可滚动
      midRight: _buildSideControls(),
      // 右下边格 = 知识点入口（explore 模式 · 知识卡过长改为弹窗）
      bottomRight: _mode == LabMode.explore
          ? Center(
              child: IconButton(
                icon: const Icon(Icons.menu_book_outlined, size: 22),
                tooltip: '知识点',
                onPressed: _showKnowledgeDialog,
              ),
            )
          : null,
    );
  }

  Widget _buildCanvas() {
    // ====== 色轮 ======
    if (_mode == LabMode.wheel) {
      return LayoutBuilder(builder: (ctx, c) {
        _wheelCx = c.maxWidth / 2; _wheelCy = c.maxHeight * 0.38; _wheelR = min(_wheelCx, _wheelCy) * 0.68;
        return GestureDetector(onTapDown: _onWheelTap,
          child: CustomPaint(size: Size.infinite, painter: ColorWheelPainter(
            brightness: _wheelBrightness, selectedPoint: _wheelPoint,
            selectedColor: _wheelPoint != null ? _wheelColor : null,
            wheelCenterX: _wheelCx, wheelCenterY: _wheelCy, wheelRadius: _wheelR)));
      });
    }

    // ====== 挑战模式 —— 独立清屏 ======
    if (_mode == LabMode.challenge) {
      return LayoutBuilder(builder: (ctx, c) {
        _canvasW = c.maxWidth; _bottlesY = 6;
        return GestureDetector(
          onPanUpdate: _onDragUpdate,
          child: CustomPaint(size: Size.infinite,
            painter: ChallengePainter(
              targetColor: _targetColor, currentColor: _state.mixedColor,
              accuracy: _calcAccuracy(), score: _score, streak: _streak,
              level: _level, timeLeft: _timeLeft, showTarget: true,
              redIntensity: _state.redIntensity, greenIntensity: _state.greenIntensity, blueIntensity: _state.blueIntensity),
              ));
      });
    }

    // ====== 自由探索 —— 瓶子(CustomPaint) + 混合色大盘(Widget) ======
    // 用复合布局: CustomPaint 只画瓶子, Widget 层画混合色, 保证混合色始终可见
    return LayoutBuilder(builder: (ctx, c) {
      _canvasW = c.maxWidth; _bottlesY = 6;
      final mixed = _state.mixedColor;
      final r = (mixed.r * 255).round(), g = (mixed.g * 255).round(), b = (mixed.b * 255).round();
      return Column(children: [
        // 上半: 三个瓶子 (CustomPaint)
        SizedBox(
          height: _bottleH + 40, // 瓶身 140 + 顶部 6 + 底部 label 34
          child: GestureDetector(
            onPanUpdate: _onDragUpdate,
            child: CustomPaint(size: Size.infinite,
              painter: PotionCauldronPainter(_state, bubblePhase: _bubblePhase, showLabels: false, bottlesOnly: true)),
          ),
        ),
        // 下半: 合成色大盘 (Widget)
        Expanded(child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [mixed.withAlpha(30), Colors.transparent], radius: 0.8),
          ),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // 混合色大圆
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mixed,
                boxShadow: [BoxShadow(color: mixed.withAlpha(120), blurRadius: 30, spreadRadius: 6)],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(child: Text('🧪',
                style: TextStyle(fontSize: 48, shadows: [Shadow(color: Colors.black.withAlpha(80), blurRadius: 4)]))),
            ),
            const SizedBox(height: 12),
            // 颜色名称
            Text(ColorModel.colorName(mixed),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: mixed,
                shadows: [Shadow(color: Colors.black.withAlpha(30), blurRadius: 4)])),
            const SizedBox(height: 4),
            // RGB 值
            if (_showLabels) Text('R:$r  G:$g  B:$b',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                color: Color(0xFF64748B), fontFamily: 'monospace')),
          ])),
        )),
      ]);
    });
  }

  Widget _buildSideControls() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: PropertyControlPanel(
        padding: const EdgeInsets.all(8),
        spacing: 10,
        children: _modeControls(),
      ),
    );
  }

  List<Widget> _modeControls() {
    // ====== 色轮 ======
    if (_mode == LabMode.wheel) {
      return [
        _readoutRow('亮度 Brightness', '${(_wheelBrightness * 100).round()}%'),
        Slider(value: _wheelBrightness, min: 0.1, max: 1.0, activeColor: const Color(0xFF6366F1),
          onChanged: (v) => setState(() => _wheelBrightness = v)),
        Center(
          child: Column(children: [
            Container(width: 24, height: 24, decoration: BoxDecoration(color: _wheelColor,
              borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFCBD5E1)))),
            const SizedBox(height: 4),
            Text(_nameColor(_wheelColor), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _wheelColor)),
          ]),
        ),
      ];
    }

    // ====== 挑战模式 ======
    if (_mode == LabMode.challenge) {
      final acc = _calcAccuracy();
      final totalTime = (30 + (_level - 1) * 5).toDouble();
      return [
        Row(children: [
          Expanded(child: SizedBox(height: 6, child: ClipRRect(borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: (_timeLeft / totalTime).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                _timeLeft > 10 ? const Color(0xFF22C55E) : _timeLeft > 5 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)))))),
          const SizedBox(width: 8),
          Text('${acc.round()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: acc >= 90 ? const Color(0xFF22C55E) : acc >= 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444))),
        ]),
        _miniSliderVertical(0, 'R', const Color(0xFFFF0000)),
        _miniSliderVertical(1, 'G', const Color(0xFF00CC00)),
        _miniSliderVertical(2, 'B', const Color(0xFF0088FF)),
        if (!_challengeActive && _timeLeft <= 0)
          Center(child: SizedBox(height: 28, child: ElevatedButton.icon(
            onPressed: () { _score = 0; _streak = 0; _level = 1; _startChallenge(); },
            icon: const Icon(Icons.replay, size: 14), label: const Text('重新开始', style: TextStyle(fontSize: 10)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12))))),
      ];
    }

    // ====== 自由探索 ======
    return [
      Center(child: Column(children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(color: _state.mixedColor,
          borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFCBD5E1), width: 2))),
        const SizedBox(height: 4),
        Text(ColorModel.colorName(_state.mixedColor), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _state.mixedColor)),
      ])),
      const Divider(height: 10),
      Center(child: FilterChip(label: const Text('标签 Labels', style: TextStyle(fontSize: 10)),
        selected: _showLabels, visualDensity: VisualDensity.compact,
        onSelected: (v) => setState(() => _showLabels = v))),
    ];
  }

  Widget _readoutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6366F1))),
      ],
    );
  }

  Widget _miniSliderVertical(int ch, String label, Color color) {
    final v = ch == 0 ? _state.redIntensity : ch == 1 ? _state.greenIntensity : _state.blueIntensity;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      Expanded(child: Slider(value: v, min: 0, max: 100, activeColor: color,
        inactiveColor: color.withAlpha(40), onChanged: (val) => setState(() => _state.updateIntensity(ch, val)))),
      SizedBox(width: 24, child: Text('${v.round()}', style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8)))),
    ]);
  }

  /// 知识点卡 → 弹窗（9 宫格边条容纳不下长文本知识卡）
  void _showKnowledgeDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
            child: _buildKnowledgePanel(),
          ),
        ),
      ),
    );
  }

  String _nameColor(Color c) {
    final r = (c.r * 255).round(), g = (c.g * 255).round(), b = (c.b * 255).round();
    if (r > 200 && g < 50 && b < 50) return '红色';
    if (r < 50 && g > 200 && b < 50) return '绿色';
    if (r < 50 && g < 50 && b > 200) return '蓝色';
    if (r > 200 && g > 200 && b < 50) return '黄色';
    if (r > 200 && g < 50 && b > 200) return '品红';
    if (r < 50 && g > 200 && b > 200) return '青色';
    if (r > 200 && g > 200 && b > 200) return '白色';
    if (r < 30 && g < 30 && b < 30) return '黑色';
    if (r > 200 && g > 100 && g < 210 && b < 50) return '橙色';
    if (r > 100 && g < 80 && b > 120) return '紫色';
    return '混合色';
  }

  // ---- RGB 加色法知识点 ----
  Widget _buildKnowledgePanel() {
    return KnowledgePanel(
      title: 'RGB 加色法原理',
      titleIcon: '🌈',
      titleColor: const Color(0xFFEC4899),
      sections: [
        KnowledgeSection.grid(items: [
          const KnowledgeItem(
            dot: Color(0xFFEF4444),
            title: '红光 (Red)',
            titleColor: Color(0xFFEF4444),
            desc: '波长约 620-750nm。人眼L视锥细胞最敏感。与绿光混合得黄色。',
          ),
          const KnowledgeItem(
            dot: Color(0xFF22C55E),
            title: '绿光 (Green)',
            titleColor: Color(0xFF22C55E),
            desc: '波长约 495-570nm。M视锥细胞感知。与红光混合得黄、与蓝光混合得青。',
          ),
          const KnowledgeItem(
            dot: Color(0xFF3B82F6),
            title: '蓝光 (Blue)',
            titleColor: Color(0xFF3B82F6),
            desc: '波长约 450-495nm。S视锥细胞感知。与红光混合得品红、与绿光混合得青。',
          ),
          const KnowledgeItem(
            icon: '🔴🟢',
            title: '互补色',
            titleColor: Color(0xFFF59E0B),
            desc: '红+青=白、绿+品红=白、蓝+黄=白。互补色叠加形成白光——这就是加色法的核心。',
          ),
        ]),
        KnowledgeSection.list(
          subtitle: '知识点',
          subtitleIcon: '📚',
          subtitleColor: const Color(0xFF60A5FA),
          items: const [
            KnowledgeItem(
              icon: '➕',
              title: '加色法原理 (Additive Mixing)',
              titleColor: Color(0xFFF59E0B),
              desc: '光源直接发光的颜色混合属于"加色法"。红+绿+蓝三原色按不同强度混合能产生人眼可见的几乎所有颜色。'
                  '手机、电视、显示器的每个像素都由RGB子像素组成——这是现代显示技术的物理基础。',
            ),
            KnowledgeItem(
              icon: '👁️',
              title: '人眼三色视觉 · 视锥细胞',
              titleColor: Color(0xFF22C55E),
              desc: '人眼视网膜有三种视锥细胞：L(长波/红)、M(中波/绿)、S(短波/蓝)。大脑通过比较三种细胞的响应强度来感知颜色。'
                  'RGB系统正是利用了人眼的这一生理特性——用三原色"欺骗"眼睛看到全彩世界。',
            ),
            KnowledgeItem(
              icon: '🆚',
              title: '加色法 vs 减色法 · 生活对照',
              titleColor: Color(0xFF8B5CF6),
              desc: '加色法(光源RGB): 越混越亮,三原色全开=白光。减色法(颜料CMYK): 越混越暗,三原色全混=黑色。'
                  '屏幕显示用RGB加色,打印用CMYK减色——两种体系互补,覆盖了从发光到反射的全部色彩场景。',
            ),
            KnowledgeItem(
              icon: '🎨',
              title: '色域与实际应用',
              titleColor: Color(0xFFEC4899),
              desc: 'RGB能覆盖的色彩范围叫"色域"。不同显示设备（手机OLED/液晶/投影仪）的色域不同——sRGB是最通用的标准色域。'
                  '舞台灯光、LED装饰灯、手机屏幕都在用RGB加色法——你身边到处都是这个原理的应用。',
            ),
          ],
        ),
      ],
    );
  }

  Widget _modeBtn(String label, LabMode mode, Color color) {
    final active = _mode == mode;
    return GestureDetector(onTap: () => _switchMode(mode),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: active ? color : color.withAlpha(60),
          borderRadius: BorderRadius.circular(16), border: Border.all(color: active ? color : color.withAlpha(100), width: 1.5)),
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFFCBD5E1)))));
  }
}
