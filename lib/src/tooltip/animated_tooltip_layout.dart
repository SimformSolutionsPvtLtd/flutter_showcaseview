/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
part of 'tooltip.dart';

class _AnimatedTooltipMultiLayout extends MultiChildRenderObjectWidget {
  // TODO: make this const when update to new flutter version
  // ignore: prefer_const_constructors_in_immutables
  _AnimatedTooltipMultiLayout({
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
