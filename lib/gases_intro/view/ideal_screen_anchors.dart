import '../gases_intro_constants.dart';
import '../render/render_data.dart';
import '../widgets/play_area_layout.dart';
import 'gases_intro_mvt.dart';
import 'layout_policy.dart';

/// IdealGasLawScreenView + IdealScreenView + BaseScreenView anchor snapshot.
///
/// V2 rules preserved; V5 applies uniform [layoutScale] to all lengths/positions.
class IdealScreenAnchors {
  IdealScreenAnchors(this.data, {this.layoutScale = 1.0})
      : layout = PlayAreaLayout(
          GasesIntroLayoutPolicy.physicalSize(layoutScale),
          layoutScale: layoutScale,
        ) {
    final s = layoutScale;
    const xMargin = 20.0;
    const yMargin = 20.0;
    final lw = GasesIntroConstants.layoutWidth * s;
    final lh = GasesIntroConstants.layoutHeight * s;

    containerLeft = layout.vx(data.containerLeft);
    containerRight = layout.vx(data.containerRight);
    containerTop = layout.vy(data.containerTop);
    containerBottom = layout.vy(data.containerBottom);
    containerNodeRight = containerRight + layout.vs(data.wallThickness);
    containerViewX = GasesIntroMvt.originX * s;
    containerViewY = GasesIntroMvt.originY * s;

    thermometerW = 48 * s;
    thermometerH = 168 * s; // combo (~28) + tube
    thermometerLeft = (containerNodeRight - 50 * s) - thermometerW / 2;
    thermometerTop = (containerTop + 60 * s) - thermometerH;

    gaugeW = 100 * s;
    gaugeH = 130 * s;
    gaugeLeft = containerNodeRight - 2 * s;
    gaugeTop = (containerTop + 30 * s) - 50 * s; // dial radius 50, centerY = top+30

    heaterW = 120 * s;
    heaterH = 150 * s;
    // Original: left = containerViewX − Δx(widthMin). Do not follow the
    // expanding left wall, or the stove sits on the time controls.
    heaterLeft = containerViewX - layout.vs(GasesIntroConstants.widthMin);
    heaterBottom = lh - yMargin * s;
    heaterTop = heaterBottom - heaterH;

    // ContainerWidthNode: origin at container right, top = containerBottom + 8.
    widthArrowsH = 22 * s;
    widthArrowsTop = containerBottom + 8 * s;

    // EraseParticlesButton: right = container.right, top = widthNode.bottom + 5
    eraseW = 40 * s;
    eraseH = 40 * s;
    eraseLeft = containerNodeRight - eraseW;
    eraseTop = widthArrowsTop + widthArrowsH + 5 * s;

    final openingRightView = layout.vx(
      data.containerRight - GasesIntroConstants.openingRightInset,
    );
    returnLidW = 100 * s;
    returnLidH = 32 * s;
    returnLidLeft = openingRightView - 30 * s - returnLidW;
    returnLidTop = containerTop - 15 * s - returnLidH;

    panelW = GasesIntroLayoutPolicy.rightPanelWidthLogical * s;
    panelLeft = lw - xMargin * s - panelW;
    panelTop = yMargin * s;

    // BicyclePumpControl: left = containerNode.right, bottom = layout − Y_MARGIN.
    // Radios sit under the pump (top = pump.bottom + 15), centered on the cylinder.
    particleTypeW = 120 * s;
    particleTypeH = 48 * s;
    pumpW = 112 * s;
    pumpBodyH = 176 * s;
    pumpLeft = containerNodeRight;
    particleTypeBottom = lh - yMargin * s;
    particleTypeTop = particleTypeBottom - particleTypeH;
    particleTypeLeft = pumpLeft + pumpW * 0.68 - particleTypeW / 2;
    pumpTop = particleTypeTop - 15 * s - pumpBodyH;

    hoseViewX = layout.vx(data.containerRight + data.wallThickness);
    hoseViewY = layout.vy(
      data.containerBottom + GasesIntroConstants.height / 5,
    );

    timeW = 90 * s;
    timeH = 48 * s;
    timeLeft = 8 * s;
    timeBottom = lh - yMargin * s;
    timeTop = timeBottom - timeH;

    resetW = 56 * s;
    resetH = 56 * s;
    resetLeft = lw - xMargin * s - resetW;
    resetTop = lh - yMargin * s - resetH;

    stopwatchMountLeft = 240 * s;
    stopwatchMountTop = 15 * s;
    collisionMountLeft = 40 * s;
    collisionMountTop = 15 * s;
  }

  final RenderData data;
  final double layoutScale;
  final PlayAreaLayout layout;

  late final double containerLeft,
      containerRight,
      containerTop,
      containerBottom,
      containerNodeRight,
      containerViewX,
      containerViewY;
  late final double thermometerLeft, thermometerTop, thermometerW, thermometerH;
  late final double gaugeLeft, gaugeTop, gaugeW, gaugeH;
  late final double eraseLeft, eraseTop, eraseW, eraseH;
  late final double widthArrowsTop, widthArrowsH;
  late final double returnLidLeft, returnLidTop, returnLidW, returnLidH;
  late final double particleTypeLeft,
      particleTypeTop,
      particleTypeBottom,
      particleTypeW,
      particleTypeH;
  late final double pumpLeft, pumpTop, pumpW, pumpBodyH, hoseViewX, hoseViewY;
  late final double heaterLeft, heaterTop, heaterBottom, heaterW, heaterH;
  late final double timeLeft, timeTop, timeBottom, timeW, timeH;
  late final double resetLeft, resetTop, resetW, resetH;
  late final double panelLeft, panelTop, panelW;
  late final double stopwatchMountLeft,
      stopwatchMountTop,
      collisionMountLeft,
      collisionMountTop;
}
