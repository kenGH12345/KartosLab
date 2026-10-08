import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/screens/home_disciplines.dart';

/// KartosLab Home — categories + simulation cards (display language = zh-CN).
///
/// Simulation IDs / builders stay stable English identifiers.
/// Display titles/subtitles come exclusively from [loc.sim] / [loc.home].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<HomeDiscipline> get _disciplines => buildHomeDisciplines();

  int get _totalSimCount =>
      _disciplines.fold<int>(0, (sum, discipline) => sum + discipline.simCount);

  @override
  Widget build(BuildContext context) {
    final disciplines = _disciplines;
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
                    for (var i = 0; i < disciplines.length; i++) ...[
                      _DisciplineBlock(discipline: disciplines[i]),
                      if (i != disciplines.length - 1)
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
          loc.home.appTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF073B54),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.home.tagline(_totalSimCount),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: const Color(0xFF48616E)),
        ),
      ],
    );
  }
}

class _DisciplineBlock extends StatelessWidget {
  const _DisciplineBlock({required this.discipline});

  final HomeDiscipline discipline;

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

class _DisciplineHeader extends StatelessWidget {
  const _DisciplineHeader({required this.discipline});

  final HomeDiscipline discipline;

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
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: discipline.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            loc.home.simCountBadge(discipline.simCount),
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

class _SubjectGroupBlock extends StatelessWidget {
  const _SubjectGroupBlock({required this.group});

  final HomeSubjectGroup group;

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
      ],
    );
  }
}

class _SimCard extends StatelessWidget {
  const _SimCard({required this.sim});

  final HomeSimEntry sim;

  @override
  Widget build(BuildContext context) {
    final title = sim.title;
    final subtitle = sim.subtitle;
    return Semantics(
      button: true,
      label: loc.accessibility.openSimulation(title),
      child: Material(
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
            // Slightly taller for CJK title+subtitle without page-level Positioned.
            constraints: const BoxConstraints(minHeight: 88),
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
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: sim.iconAsset != null
                      ? (sim.iconAsset!.toLowerCase().endsWith('.svg')
                          ? SvgPicture.asset(
                              sim.iconAsset!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              sim.iconAsset!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ))
                      : Icon(sim.icon, color: sim.color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF073B54),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B8291),
                          height: 1.2,
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
      ),
    );
  }
}
