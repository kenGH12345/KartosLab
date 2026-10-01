/// Decay 屏核素状态文案与展示。
///
/// 纯函数从 [BuildANucleusState] 已有派生量读取，**不复制核素表**。
/// 文案逐行对标：
/// - `ElementNameText.ts`
/// - `StabilityIndicatorText.ts`
/// - `DecayModel.halfLifeNumberProperty`（本阶段只出文字，数轴属 1G-4）
/// - `SymbolNode.ts`（无电荷；Decay 屏未传 chargeProperty）
library;

import 'package:flutter/material.dart';

import '../ban_constants.dart';
import '../model/build_a_nucleus_state.dart';
import '../model/half_life_number_line.dart';
import '../model/half_life_readout.dart';

/// 原版字符串填空。英文键来自 `build-a-nucleus-strings_en.json` [已确认]。
class NuclideStatusText {
  const NuclideStatusText._();

  /// 元素名行。对标 ElementNameText 的 DerivedProperty。
  /// 0p0n 返回空串（原版 name = ''，不是「空核」）。
  static String elementCaption(BuildANucleusState s) {
    final name = s.elementName;
    final n = s.neutronCount;
    final mass = s.massNumber;
    final nameMass = name.isEmpty ? '' : '$name - $mass';

    if (!s.nuclideExists && mass != 0) {
      if (name.isEmpty) {
        // zeroParticlesDoesNotFormPattern: "{{mass}} {{particleType}} {{doesNotForm}}"
        return '$mass neutrons does not form';
      }
      // elementDoesNotFormPattern: "{{nameMass}} {{doesNotForm}}"
      return '$nameMass does not form';
    }
    if (name.isEmpty) {
      if (n == 0) return '';
      if (n == 1) {
        // doesNotForm 为空： "{{mass}} neutron "
        return '$n neutron';
      }
      return 'Cluster of $n neutrons';
    }
    // nameMassPattern: "{{name}} - {{mass}}"
    return nameMass;
  }

  /// 稳定/不稳定。不存在（含空核）时返回 null → 控件隐藏。
  /// [已确认] StabilityIndicatorText.visible = nuclideExistsProperty
  static String? stabilityCaption(BuildANucleusState s) {
    if (!s.nuclideExists) return null;
    return s.isStable ? 'Stable' : 'Unstable';
  }

  /// 半衰期文字。NineGrid 边格占位；数轴上的结构化读数见
  /// [HalfLifeNumberLineReadout]（1G-3B-3）。
  ///
  /// 格式走 [HalfLifeReadoutContent]（Reading），不在此处重判哨兵。
  static String halfLifeCaption(BuildANucleusState s) {
    return HalfLifeReadoutContent.fromReading(
      HalfLifeNumberLine.fromState(s),
    ).captionLine;
  }
}

/// 核上方标签：Stable/Unstable 在上，元素名在下。
///
/// [已确认] `DecayScreenView`：
/// `stability.center = (halfLifeInformationNodeCenterX, availableDecays.top)`
/// `elementName.center = stability.center.plusXY(0, 60)`
/// 水平居中；字号/字重本阶段不改（P3）。
class ElementAndStabilityReadout extends StatelessWidget {
  const ElementAndStabilityReadout({super.key, required this.state});

  final BuildANucleusState state;

  /// [已确认] `elementNameText.center = stability.center.plusXY(0, 60)`
  /// Column 间距用同一数值；中心距会略大于 60（字高未补偿）。
  static const double stabilityToNameGap = 60;

  @override
  Widget build(BuildContext context) {
    final name = NuclideStatusText.elementCaption(state);
    final stability = NuclideStatusText.stabilityCaption(state);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (stability != null)
            Text(
              stability,
              key: const ValueKey('ban_stability'),
              textAlign: TextAlign.center,
              // [已确认] StabilityIndicatorText: REGULAR_FONT PhetFont(20) regular
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Color(0xFF000000),
              ),
            )
          else
            const SizedBox.shrink(key: ValueKey('ban_stability')),
          const SizedBox(height: stabilityToNameGap),
          Text(
            name,
            key: const ValueKey('ban_element_name'),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            // [已确认] ElementNameText: REGULAR_FONT PhetFont(20) regular, fill red
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: Color(0xFFFF0000),
            ),
          ),
        ],
      ),
    );
  }
}

/// 质子/中子计数。对标 NucleonNumberPanel（无 0.1s 淡入替换动画 —— 本阶段不做）。
class NucleonCountReadout extends StatelessWidget {
  const NucleonCountReadout({super.key, required this.state});

  final BuildANucleusState state;

  @override
  Widget build(BuildContext context) {
    // 九宫格左边格实测约 57px 宽；原版 NucleonNumberPanel 宽 140。
    // scaleDown 适配边格，不另起布局框架。[视觉待确认]
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        alignment: Alignment.topLeft,
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _countRow(
              key: 'ban_proton_count',
              color: const Color(BanConstants.protonColorValue),
              // 生成器已用中文「质子」；面板与之一致。[推测：中文本地化仍待确认]
              label: '质子',
              value: state.protonCount,
            ),
            const SizedBox(height: 4),
            _countRow(
              key: 'ban_neutron_count',
              color: const Color(BanConstants.neutronColorValue),
              label: '中子',
              value: state.neutronCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _countRow({
    required String key,
    required Color color,
    required String label,
    required int value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.4, -0.4),
              radius: 1.6,
              colors: [Colors.white, color],
            ),
            border: Border.all(color: color, width: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text('$label: $value',
            key: ValueKey(key),
            // [已确认] NucleonNumberPanel LABEL_FONT PhetFont(18)
            // 边格窄：外层 FittedBox.scaleDown。[视觉近似：NineGrid]
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            )),
      ],
    );
  }
}

/// 半衰期文字（1G-2 边格占位）。Decay 屏已改用数轴上的
/// [HalfLifeNumberLineReadout]（1G-3B-5），本控件保留给单行 caption 测试。
class HalfLifeReadout extends StatelessWidget {
  const HalfLifeReadout({super.key, required this.state});

  final BuildANucleusState state;

  @override
  Widget build(BuildContext context) {
    final text = NuclideStatusText.halfLifeCaption(state);
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        alignment: Alignment.topLeft,
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          key: const ValueKey('ban_half_life'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

/// 核素符号盒：A 左上、Z 左下（质子色）、符号居中。
/// [已确认] shred SymbolNode；Decay 屏 scale 0.3、无电荷。
class NuclideSymbolReadout extends StatelessWidget {
  const NuclideSymbolReadout({super.key, required this.state});

  final BuildANucleusState state;

  @override
  Widget build(BuildContext context) {
    final symbol = state.protonCount > 0 ? state.elementSymbol : '-';
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Symbol', style: TextStyle(fontSize: 11)),
            const SizedBox(height: 2),
            Container(
              key: const ValueKey('ban_symbol'),
              width: 72,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      symbol,
                      key: const ValueKey('ban_element_symbol'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4,
                    top: 2,
                    child: Text(
                      '${state.massNumber}',
                      key: const ValueKey('ban_mass_number'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Positioned(
                    left: 4,
                    bottom: 2,
                    child: Text(
                      '${state.protonCount}',
                      key: const ValueKey('ban_atomic_number'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(BanConstants.protonColorValue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
