part of 'tooltip.dart';

/// A delegate for handling tooltip animations including scaling and movement.
class RenderAnimationDelegate extends RenderPositionDelegate {
  AnimationController _scaleController;
  AnimationController _moveController;
  Animation<double> _scaleAnimation;
  Animation<double> _moveAnimation;
  Alignment? scaleAlignment;

  RenderAnimationDelegate({
    required AnimationController scaleController,
    required AnimationController moveController,
    required Animation<double> scaleAnimation,
    required Animation<double> moveAnimation,
    required this.scaleAlignment,
    required super.targetPosition,
    required super.targetSize,
    required super.position,
    required super.screenSize,
    required super.hasSecondBox,
    required super.hasArrow,
    required super.gapBetweenContentAndAction,
    required super.toolTipSlideEndDistance,
    required super.screenEdgePadding,
  })  : _scaleController = scaleController,
        _moveController = moveController,
        _scaleAnimation = scaleAnimation,
        _moveAnimation = moveAnimation {
    // Add listeners to trigger repaint when animations change.
    _scaleAnimation.addListener(markNeedsPaint);
    _moveAnimation.addListener(markNeedsPaint);
  }

  /// Updates the scale animation controller.
  set scaleController(AnimationController value) {
    if (_scaleController != value) {
      _scaleController = value;
    }
  }

  /// Updates the move animation controller.
  set moveController(AnimationController value) {
    if (_moveController != value) {
      _moveController = value;
    }
  }

  /// Updates the scale animation and refreshes listeners.
  set scaleAnimation(Animation<double> value) {
    if (_scaleAnimation != value) {
      _scaleAnimation.removeListener(markNeedsPaint);
      _scaleAnimation = value;
      _scaleAnimation.addListener(markNeedsPaint);
      markNeedsPaint();
    }
  }

  /// Updates the move animation and refreshes listeners.
  set moveAnimation(Animation<double> value) {
    if (_moveAnimation != value) {
      _moveAnimation.removeListener(markNeedsPaint);
      _moveAnimation = value;
      _moveAnimation.addListener(markNeedsPaint);
      markNeedsPaint();
    }
  }

  /// Sets the scale alignment and marks the widget for repaint.
  void setScaleAlignment(Alignment alignment) {
    scaleAlignment = alignment;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;

    while (child != null) {
      final childParentData = child.parentData! as MultiChildLayoutParentData;
      context.canvas.save();

      // Calculate target widget bounds.
      final Rect targetRect = Rect.fromLTWH(
        targetPosition.dx,
        targetPosition.dy,
        targetSize.width,
        targetSize.height,
      );

      // Determine scale alignment if not set.
      scaleAlignment ??= _defaultScaleAlignment();

      // Compute scale origin from alignment within the target rectangle.
      final Offset scaleOrigin = Offset(
        targetRect.left +
            (targetRect.width / 2) +
            (scaleAlignment!.x * targetRect.width / 2),
        targetRect.top +
            (targetRect.height / 2) +
            (scaleAlignment!.y * targetRect.height / 2),
      );

      // Compute movement offset based on animation progress.
      final Offset moveOffset = _calculateMoveOffset();

      context.canvas.translate(scaleOrigin.dx, scaleOrigin.dy);
      context.canvas.scale(_scaleAnimation.value);

      // Adjust for arrow rendering or normal child rendering.
      if (childParentData.id == TooltipLayoutSlot.arrow) {
        _paintArrow(context, child, childParentData, scaleOrigin, moveOffset);
      } else {
        _paintChild(context, child, childParentData, scaleOrigin, moveOffset);
      }

      context.canvas.restore();
      child = childParentData.nextSibling;
    }
  }

  /// Determines the default scale alignment based on tooltip position.
  Alignment _defaultScaleAlignment() {
    switch (tooltipPosition) {
      case TooltipPosition.top:
        return Alignment.topCenter;
      case TooltipPosition.bottom:
        return Alignment.bottomCenter;
      case TooltipPosition.left:
        return Alignment.centerLeft;
      case TooltipPosition.right:
        return Alignment.centerRight;
    }
  }

  /// Computes the offset movement animation based on tooltip position.
  Offset _calculateMoveOffset() {
    switch (tooltipPosition) {
      case TooltipPosition.top:
        return Offset(0, (1 - _moveAnimation.value) * -toolTipSlideEndDistance);
      case TooltipPosition.bottom:
        return Offset(0, (1 - _moveAnimation.value) * toolTipSlideEndDistance);
      case TooltipPosition.left:
        return Offset((1 - _moveAnimation.value) * -toolTipSlideEndDistance, 0);
      case TooltipPosition.right:
        return Offset((1 - _moveAnimation.value) * toolTipSlideEndDistance, 0);
    }
  }

  /// Paints the tooltip arrow with proper alignment and rotation.
  void _paintArrow(
      PaintingContext context,
      RenderBox child,
      MultiChildLayoutParentData childParentData,
      Offset scaleOrigin,
      Offset moveOffset) {
    context.canvas.translate(
      -scaleOrigin.dx + childParentData.offset.dx + child.size.width / 2,
      -scaleOrigin.dy + childParentData.offset.dy + child.size.height / 2,
    );
    context.canvas.translate(moveOffset.dx, moveOffset.dy);
    context.canvas.rotate(tooltipPosition.rotationAngle);
    context.paintChild(
        child, Offset(-child.size.width / 2, -child.size.height / 2));
  }

  /// Paints normal children with translation and animation effects.
  void _paintChild(
      PaintingContext context,
      RenderBox child,
      MultiChildLayoutParentData childParentData,
      Offset scaleOrigin,
      Offset moveOffset) {
    context.canvas.translate(
      -scaleOrigin.dx + childParentData.offset.dx,
      -scaleOrigin.dy + childParentData.offset.dy,
    );
    context.canvas.translate(moveOffset.dx, moveOffset.dy);
    context.paintChild(child, Offset.zero);
  }
}
