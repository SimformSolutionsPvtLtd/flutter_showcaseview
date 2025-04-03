part of 'tooltip.dart';

class _AnimatedTooltipMultiLayout extends MultiChildRenderObjectWidget {
  const _AnimatedTooltipMultiLayout({
    // If we remove this parameter it will cause error in v3.29.0 so ignore
    // ignore: unused_element_parameter
    super.key,
    required this.scaleController,
    required this.moveController,
    required this.scaleAnimation,
    required this.moveAnimation,
    required this.targetPosition,
    required this.targetSize,
    required this.screenSize,
    required this.hasSecondBox,
    required this.hasArrow,
    required this.gapBetweenContentAndAction,
    required this.toolTipSlideEndDistance,
    required super.children,
    required this.position,
    required this.scaleAlignment,
    required this.screenEdgePadding,
    required this.targetPadding,
    required this.showcaseOffset,
  });

  final AnimationController scaleController;
  final AnimationController moveController;
  final Animation<double> scaleAnimation;
  final Animation<double> moveAnimation;
  final Offset targetPosition;
  final Size targetSize;
  final TooltipPosition? position;
  final Size screenSize;
  final bool hasSecondBox;
  final bool hasArrow;
  final double gapBetweenContentAndAction;
  final double toolTipSlideEndDistance;
  final Alignment? scaleAlignment;
  final double screenEdgePadding;
  final EdgeInsets targetPadding;
  final Offset showcaseOffset;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderAnimationDelegate(
      scaleController: scaleController,
      moveController: moveController,
      scaleAnimation: scaleAnimation,
      moveAnimation: moveAnimation,
      targetPosition: targetPosition,
      targetSize: targetSize,
      position: position,
      screenSize: screenSize,
      hasSecondBox: hasSecondBox,
      hasArrow: hasArrow,
      scaleAlignment: scaleAlignment,
      gapBetweenContentAndAction: gapBetweenContentAndAction,
      toolTipSlideEndDistance: toolTipSlideEndDistance,
      screenEdgePadding: screenEdgePadding,
      targetPadding: targetPadding,
      showcaseOffset: showcaseOffset,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderAnimationDelegate renderObject,
  ) {
    renderObject
      ..scaleController = scaleController
      ..moveController = moveController
      ..scaleAnimation = scaleAnimation
      ..moveAnimation = moveAnimation
      ..targetPosition = targetPosition
      ..targetSize = targetSize
      ..position = position
      ..screenSize = screenSize
      ..hasSecondBox = hasSecondBox
      ..hasArrow = hasArrow
      ..screenEdgePadding = screenEdgePadding
      ..toolTipSlideEndDistance = toolTipSlideEndDistance
      ..gapBetweenContentAndAction = gapBetweenContentAndAction
      ..targetPadding = targetPadding
      ..showcaseOffset = showcaseOffset;
  }
}
