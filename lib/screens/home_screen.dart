import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../circuit/screens/circuit_screen.dart';
import '../optics/screens/optics_screen.dart';
import '../forces/screens/forces_home.dart';
import '../chemistry/molarity/view/screens/molarity_screen.dart';
import '../color_vision/screens/color_vision_home.dart';
import '../common/widgets/lesson_entry_section.dart';
import '../sound/screens/sound_screen.dart';
import '../radio_waves/screens/radio_waves_screen.dart';
import '../wave_interference/screens/wave_interference_screen.dart';

/// 单个 sim 入口的展示元数据 + 目标屏构造器。
class _SimEntry {
  const _SimEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
    this.simKey,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;

  /// sim 标识（T-P1-11 课时入口过滤用：'circuit' / 'color_vision' / ...）。
  /// null = 无课时入口（向后兼容）。
  final String? simKey;
}

/// 学科下的二级子领域分组（力学 / 电学 / 光学与波动 / 溶液与浓度）。
class _SubjectGroup {
  const _SubjectGroup({required this.name, required this.sims});

  final String name;
  final List<_SimEntry> sims;
}

/// 一级学科（物理 / 化学）。
class _Discipline {
  const _Discipline({
    required this.name,
    required this.englishName,
    required this.color,
    required this.groups,
  });

  final String name;
  final String englishName;
  final Color color;
  final List<_SubjectGroup> groups;

  int get simCount =>
      groups.fold<int>(0, (sum, group) => sum + group.sims.length);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<_Discipline> _disciplines = <_Discipline>[
    _Discipline(
      name: '物理',
      englishName: 'Physics',
      color: const Color(0xFF1177AA),
      groups: <_SubjectGroup>[
        _SubjectGroup(
          name: '力学',
          sims: <_SimEntry>[
            _SimEntry(
              title: '力与运动',
              subtitle: '合力 · 摩擦 · 加速度',
              icon: Icons.sports_kabaddi_rounded,
              color: Color(0xFF166534),
              builder: _buildForces,
              simKey: 'forces',
            ),
          ],
        ),
        _SubjectGroup(
          name: '电学与电路',
          sims: <_SimEntry>[
            _SimEntry(
              title: '电路搭建',
              subtitle: '串并联 · 电流路径',
              icon: Icons.electric_bolt_rounded,
              color: Color(0xFF0C4A6E),
              builder: _buildCircuit,
              simKey: 'circuit',
            ),
          ],
        ),
        _SubjectGroup(
          name: '光学与波动',
          sims: <_SimEntry>[
            _SimEntry(
              title: '几何光学',
              subtitle: '透镜 · 镜面 · 成像',
              icon: Icons.play_arrow_rounded,
              color: Color(0xFF1177AA),
              builder: _buildOptics,
              simKey: 'optics',
            ),
            _SimEntry(
              title: '色觉',
              subtitle: 'RGB 合成 · 滤光',
              icon: Icons.palette_rounded,
              color: Color(0xFFDB2777),
              builder: _buildColorVision,
              simKey: 'color_vision',
            ),
            _SimEntry(
              title: '波的干涉',
              subtitle: '双缝 · 叠加原理',
              icon: Icons.waves_rounded,
              color: Color(0xFF2563EB),
              builder: _buildWaveInterference,
              simKey: 'wave_interference',
            ),
            _SimEntry(
              title: '声波',
              subtitle: '频率 · 振幅 · 波形',
              icon: Icons.graphic_eq_rounded,
              color: Color(0xFF0D9488),
              builder: _buildSound,
              simKey: 'sound',
            ),
            _SimEntry(
              title: '电磁波',
              subtitle: '天线 · 传播',
              icon: Icons.sensors_rounded,
              color: Color(0xFF7C3AED),
              builder: _buildRadioWaves,
              simKey: 'radio_waves',
            ),
          ],
        ),
      ],
    ),
    _Discipline(
      name: '化学',
      englishName: 'Chemistry',
      color: const Color(0xFF0891B2),
      groups: <_SubjectGroup>[
        _SubjectGroup(
          name: '溶液与浓度',
          sims: <_SimEntry>[
            _SimEntry(
              title: '摩尔浓度',
              subtitle: '溶液配比 · 浓度计算',
              icon: Icons.science_rounded,
              color: Color(0xFF0891B2),
              builder: _buildMolarity,
              simKey: 'molarity',
            ),
          ],
        ),
      ],
    ),
  ];

  static Widget _buildForces(BuildContext _) => const ForcesHome();
  static Widget _buildCircuit(BuildContext _) => const CircuitScreen();
  static Widget _buildOptics(BuildContext _) => const OpticsScreen();
  static Widget _buildColorVision(BuildContext _) => const ColorVisionHome();
  static Widget _buildWaveInterference(BuildContext _) =>
      const WaveInterferenceScreen();
  static Widget _buildSound(BuildContext _) => const SoundScreen();
  static Widget _buildRadioWaves(BuildContext _) => const RadioWavesScreen();
  static Widget _buildMolarity(BuildContext _) => const MolarityScreen();

  int get _totalSimCount =>
      _disciplines.fold<int>(0, (sum, discipline) => sum + discipline.simCount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    for (var i = 0; i < _disciplines.length; i++) ...[
                      _DisciplineBlock(discipline: _disciplines[i]),
                      if (i != _disciplines.length - 1)
                        const SizedBox(height: 28),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/lens_convex.svg', width: 56),
            const SizedBox(width: 18),
            SvgPicture.asset('assets/images/battery.svg', width: 40),
            const SizedBox(width: 18),
            SvgPicture.asset('assets/images/drop.svg', width: 44),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Kratos 仿真实验室',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF073B54),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '物理 · 化学 交互式仿真实验合集 · 共 $_totalSimCount 个实验',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: const Color(0xFF48616E)),
        ),
      ],
    );
  }
}

/// 一级学科块：学科 header + 各子领域分组。
class _DisciplineBlock extends StatelessWidget {
  const _DisciplineBlock({required this.discipline});

  final _Discipline discipline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DisciplineHeader(discipline: discipline),
        const SizedBox(height: 14),
        for (var i = 0; i < discipline.groups.length; i++) ...[
          _SubjectGroupBlock(group: discipline.groups[i]),
          if (i != discipline.groups.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }
}

/// 一级学科 header（色条 + 中英文名 + 实验计数）。
class _DisciplineHeader extends StatelessWidget {
  const _DisciplineHeader({required this.discipline});

  final _Discipline discipline;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 28,
          decoration: BoxDecoration(
            color: discipline.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          discipline.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF073B54),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          discipline.englishName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: discipline.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: discipline.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${discipline.simCount} 个实验',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: discipline.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// 子领域块：分组名 + 自适应卡片网格。
class _SubjectGroupBlock extends StatelessWidget {
  const _SubjectGroupBlock({required this.group});

  final _SubjectGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            group.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF48616E),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1000
                ? 4
                : width >= 720
                ? 3
                : width >= 460
                ? 2
                : 1;
            const spacing = 12.0;
            final cardWidth = (width - (columns - 1) * spacing) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final sim in group.sims)
                  SizedBox(
                    width: cardWidth,
                    child: _SimCard(sim: sim),
                  ),
              ],
            );
          },
        ),
        // T-P1-11：该组各 sim 的课时入口（无课时 sim → SizedBox.shrink · AC-17）
        for (final sim in group.sims)
          if (sim.simKey != null) LessonEntrySection(sim: sim.simKey!),
      ],
    );
  }
}

/// 单个 sim 入口卡片。
class _SimCard extends StatelessWidget {
  const _SimCard({required this.sim});

  final _SimEntry sim;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: sim.builder));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: sim.color.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: sim.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(sim.icon, color: sim.color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sim.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF073B54),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sim.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B8291),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: sim.color.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
