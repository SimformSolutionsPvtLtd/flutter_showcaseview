part of 'tooltip.dart';

class AnimatedTooltipMultiLayout extends MultiChildRenderObjectWidget {
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

  const AnimatedTooltipMultiLayout({
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
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnimationDelegate(
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
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderAnimationDelegate renderObject) {
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
      ..gapBetweenContentAndAction = gapBetweenContentAndAction;
  }
}
