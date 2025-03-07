part of 'tooltip.dart';

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
    // Add listeners to animations
    _scaleAnimation.addListener(markNeedsPaint);
    _moveAnimation.addListener(markNeedsPaint);
  }

  // Setters for animation controllers and animations
  set scaleController(AnimationController value) {
    if (_scaleController != value) {
      _scaleController = value;
    }
  }

  set moveController(AnimationController value) {
    if (_moveController != value) {
      _moveController = value;
    }
  }

  set scaleAnimation(Animation<double> value) {
    if (_scaleAnimation != value) {
      _scaleAnimation.removeListener(markNeedsPaint);
      _scaleAnimation = value;
      _scaleAnimation.addListener(markNeedsPaint);
      markNeedsPaint();
    }
  }

  set moveAnimation(Animation<double> value) {
    if (_moveAnimation != value) {
      _moveAnimation.removeListener(markNeedsPaint);
      _moveAnimation = value;
      _moveAnimation.addListener(markNeedsPaint);
      markNeedsPaint();
    }
  }

  // Method to update alignment
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

      // Calculate scale origin based on target widget and alignment
      // This uses the target widget's bounds and the alignment parameter
      final Rect targetRect = Rect.fromLTWH(targetPosition.dx,
          targetPosition.dy, targetSize.width, targetSize.height);

      // Convert alignment to actual pixel position within the target rect

      if (scaleAlignment == null) {
        switch (tooltipPosition) {
          case TooltipPosition.top:
            scaleAlignment = Alignment.topCenter;
            break;
          case TooltipPosition.bottom:
            scaleAlignment = Alignment.bottomCenter;
            break;
          case TooltipPosition.left:
            scaleAlignment = Alignment.centerLeft;
            break;
          case TooltipPosition.right:
            scaleAlignment = Alignment.centerRight;
            break;
        }
      }
      final Offset scaleOrigin = Offset(
          targetRect.left +
              (targetRect.width / 2) +
              (scaleAlignment!.x * targetRect.width / 2),
          targetRect.top +
              (targetRect.height / 2) +
              (scaleAlignment!.y * targetRect.height / 2));

      // Apply move animation
      late Offset moveOffset;

      switch (tooltipPosition) {
        case TooltipPosition.top:
          moveOffset = Offset(
            0,
            (1 - _moveAnimation.value) * -toolTipSlideEndDistance,
          );
          break;
        case TooltipPosition.bottom:
          moveOffset = Offset(
            0,
            (1 - _moveAnimation.value) * toolTipSlideEndDistance,
          );
          break;
        case TooltipPosition.left:
          moveOffset = Offset(
            (1 - _moveAnimation.value) * -toolTipSlideEndDistance,
            0,
          );
          break;
        case TooltipPosition.right:
          moveOffset = Offset(
            (1 - _moveAnimation.value) * toolTipSlideEndDistance,
            0,
          );
          break;
      }

      context.canvas.translate(scaleOrigin.dx, scaleOrigin.dy);

      // Apply scale around this origin
      context.canvas.scale(_scaleAnimation.value);

      // Translate back and paint each child
      if (childParentData.id == TooltipLayoutSlot.arrow) {
        // Special handling for arrow
        context.canvas.translate(
            -scaleOrigin.dx + childParentData.offset.dx + child.size.width / 2,
            -scaleOrigin.dy +
                childParentData.offset.dy +
                child.size.height / 2);

        // Add move offset
        context.canvas.translate(moveOffset.dx, moveOffset.dy);

        // Rotate arrow if needed
        context.canvas.rotate(tooltipPosition.rotationAngle);

        // Paint the arrow
        context.paintChild(
            child, Offset(-child.size.width / 2, -child.size.height / 2));
      } else {
        // Normal children
        context.canvas.translate(-scaleOrigin.dx + childParentData.offset.dx,
            -scaleOrigin.dy + childParentData.offset.dy);

        // Add move offset
        context.canvas.translate(moveOffset.dx, moveOffset.dy);

        // Paint the child
        context.paintChild(child, Offset.zero);
      }

      context.canvas.restore();

      child = childParentData.nextSibling;
    }
  }
}
