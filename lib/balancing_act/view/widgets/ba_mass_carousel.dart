import 'package:flutter/material.dart';
import 'package:kratos/balancing_act/ba_assets.dart';
import 'package:kratos/balancing_act/ba_colors.dart';
import 'package:kratos/balancing_act/ba_strings.dart';
import 'package:kratos/balancing_act/model/ba_mass.dart';
import 'package:kratos/balancing_act/model/balance_lab_model.dart';
import 'package:kratos/balancing_act/view/widgets/ba_mass_node.dart';
import 'package:kratos/balancing_act/view/widgets/ba_styled_svg.dart';
import 'package:kratos/balancing_act/view/widgets/ba_text.dart';

/// Lab MassCarousel — source `MassCarousel.ts` (5 pages).
///
/// Creator thumbnail scales from source:
/// - Brick / Mystery: SCALING_MVT = 150
/// - People: SCALING_MVT = 80
class BaMassCarousel extends StatelessWidget {
  const BaMassCarousel({
    super.key,
    required this.carousel,
    required this.stageKey,
    required this.onPrev,
    required this.onNext,
    required this.onCreateBrick,
    required this.onCreatePerson,
    required this.onCreateMystery,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final LabCarouselState carousel;
  final GlobalKey stageKey;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final void Function(int numBricks, Offset stageLocal) onCreateBrick;
  final void Function(BaMassType type, Offset stageLocal) onCreatePerson;
  final void Function(int mysteryId, Offset stageLocal) onCreateMystery;
  final void Function(Offset stageLocal) onDragUpdate;
  final VoidCallback onDragEnd;

  Offset _toStage(Offset global) {
    final box = stageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return global;
    return box.globalToLocal(global);
  }

  String get _title {
    switch (carousel.currentPage) {
      case LabCarouselPage.bricks:
        return BaStrings.bricks;
      case LabCarouselPage.people1:
      case LabCarouselPage.people2:
        return BaStrings.people;
      case LabCarouselPage.mystery1:
      case LabCarouselPage.mystery2:
        return BaStrings.mysteryObjects;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ba_lab_carousel'),
      decoration: BoxDecoration(
        color: BaColors.panelFill,
        borderRadius: BorderRadius.circular(10), // MassCarousel cornerRadius
        border: Border.all(color: const Color(0xFF666666), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // xMargin:8
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ArrowButton(
            key: const Key('ba_lab_carousel_prev'),
            enabled: carousel.pageIndex > 0,
            pointingLeft: true,
            onPressed: onPrev,
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BaText(_title, size: 16),
                  const SizedBox(height: 5),
                  _pageContent(),
                ],
              ),
            ),
          ),
          _ArrowButton(
            key: const Key('ba_lab_carousel_next'),
            enabled: carousel.pageIndex < carousel.pageCount - 1,
            pointingLeft: false,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }

  Widget _creator({
    required VoidCallback Function(Offset stageLocal) start,
    required Widget child,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) => start(_toStage(d.globalPosition))(),
      onPanUpdate: (d) => onDragUpdate(_toStage(d.globalPosition)),
      onPanEnd: (_) => onDragEnd(),
      child: child,
    );
  }

  Widget _pageContent() {
    switch (carousel.currentPage) {
      case LabCarouselPage.bricks:
        // Source VBox/HBox spacing: 20
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _creator(
                  start: (p) => () => onCreateBrick(1, p),
                  child: const BaBrickCreatorThumb(numBricks: 1),
                ),
                const SizedBox(width: 20),
                _creator(
                  start: (p) => () => onCreateBrick(2, p),
                  child: const BaBrickCreatorThumb(numBricks: 2),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _creator(
                  start: (p) => () => onCreateBrick(3, p),
                  child: const BaBrickCreatorThumb(numBricks: 3),
                ),
                const SizedBox(width: 20),
                _creator(
                  start: (p) => () => onCreateBrick(4, p),
                  child: const BaBrickCreatorThumb(numBricks: 4),
                ),
              ],
            ),
          ],
        );
      case LabCarouselPage.people1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _creator(
              start: (p) => () => onCreatePerson(BaMassType.boy, p),
              child: const _PersonThumb(
                type: BaMassType.boy,
                asset: BaAssets.usaBoyStanding,
                labelKg: 20,
              ),
            ),
            const SizedBox(width: 20),
            _creator(
              start: (p) => () => onCreatePerson(BaMassType.man, p),
              child: const _PersonThumb(
                type: BaMassType.man,
                asset: BaAssets.usaManStanding,
                labelKg: 80,
              ),
            ),
          ],
        );
      case LabCarouselPage.people2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _creator(
              start: (p) => () => onCreatePerson(BaMassType.girl, p),
              child: const _PersonThumb(
                type: BaMassType.girl,
                asset: BaAssets.usaGirlStanding,
                labelKg: 30,
              ),
            ),
            const SizedBox(width: 20),
            _creator(
              start: (p) => () => onCreatePerson(BaMassType.woman, p),
              child: const _PersonThumb(
                type: BaMassType.woman,
                asset: BaAssets.usaWomanStanding,
                labelKg: 60,
              ),
            ),
          ],
        );
      case LabCarouselPage.mystery1:
        return _mysteryPage(const [0, 1, 2, 3]);
      case LabCarouselPage.mystery2:
        return _mysteryPage(const [4, 5, 6, 7]);
    }
  }

  Widget _mysteryPage(List<int> ids) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _creator(
              start: (p) => () => onCreateMystery(ids[0], p),
              child: _MysteryThumb(id: ids[0]),
            ),
            const SizedBox(width: 20),
            _creator(
              start: (p) => () => onCreateMystery(ids[1], p),
              child: _MysteryThumb(id: ids[1]),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _creator(
              start: (p) => () => onCreateMystery(ids[2], p),
              child: _MysteryThumb(id: ids[2]),
            ),
            const SizedBox(width: 20),
            _creator(
              start: (p) => () => onCreateMystery(ids[3], p),
              child: _MysteryThumb(id: ids[3]),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersonThumb extends StatelessWidget {
  const _PersonThumb({
    required this.type,
    required this.asset,
    required this.labelKg,
  });

  final BaMassType type;
  final String asset;
  final double labelKg;

  /// PeopleCreatorNode SCALING_MVT = 80
  static const double scalingMvt = 80;

  @override
  Widget build(BuildContext context) {
    final modelH = BaMassCatalog.defaultHeights[type] ?? 1.0;
    final h = modelH * scalingMvt;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BaSvgPicture.asset(asset, height: h, fit: BoxFit.contain),
        const SizedBox(height: 2),
        BaText(BaStrings.massLabel(labelKg), size: 12),
      ],
    );
  }
}

class _MysteryThumb extends StatelessWidget {
  const _MysteryThumb({required this.id});

  final int id;

  /// MysteryMassCreatorNode SCALING_MVT = 150
  static const double scalingMvt = 150;

  @override
  Widget build(BuildContext context) {
    final h = BaMassCatalog.mysteryHeights[id] * scalingMvt;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BaSvgPicture.asset(
          BaAssets.mysteryObject(id),
          height: h,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        BaText(BaStrings.unknownMassLabel, size: 14),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    super.key,
    required this.enabled,
    required this.pointingLeft,
    required this.onPressed,
  });

  final bool enabled;
  final bool pointingLeft;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // MassCarousel buttonOptions: baseColor/stroke null (lightweight)
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CustomPaint(
          size: const Size(18, 28),
          painter: _ChevronPainter(
            pointingLeft: pointingLeft,
            color: enabled ? Colors.black87 : Colors.black26,
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({required this.pointingLeft, required this.color});

  final bool pointingLeft;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointingLeft) {
      path
        ..moveTo(size.width * 0.7, 0)
        ..lineTo(size.width * 0.2, size.height / 2)
        ..lineTo(size.width * 0.7, size.height);
    } else {
      path
        ..moveTo(size.width * 0.3, 0)
        ..lineTo(size.width * 0.8, size.height / 2)
        ..lineTo(size.width * 0.3, size.height);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.pointingLeft != pointingLeft || oldDelegate.color != color;
}
