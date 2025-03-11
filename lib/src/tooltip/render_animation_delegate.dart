part of 'tooltip.dart';

typedef PaintChildCallBack = void Function(RenderObject child, Offset offset);

/// A delegate for handling tooltip animations including scaling and movement.
class _RenderAnimationDelegate extends _RenderPositionDelegate {
  AnimationController _scaleController;
  AnimationController _moveController;
  Animation<double> _scaleAnimation;
  Animation<double> _moveAnimation;
  Alignment? scaleAlignment;

  /// This will stop extra repaint when paint function is already in progress
  bool _isPaintRunning = false;

  _RenderAnimationDelegate({
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
    required super.targetPadding,
  })  : _scaleController = scaleController,
        _moveController = moveController,
        _scaleAnimation = scaleAnimation,
        _moveAnimation = moveAnimation {
    // Add listeners to trigger repaint when animations change.
    _scaleAnimation.addListener(_effectivelyMarkNeedsPaint);
    _moveAnimation.addListener(_effectivelyMarkNeedsPaint);
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
    if (_scaleAnimation == value) {
      return;
    }
    _scaleAnimation.removeListener(_effectivelyMarkNeedsPaint);
    _scaleAnimation = value;
    _scaleAnimation.addListener(_effectivelyMarkNeedsPaint);
    markNeedsPaint();
  }

  /// Updates the move animation and refreshes listeners.
  set moveAnimation(Animation<double> value) {
    if (_moveAnimation == value) {
      return;
    }
    _moveAnimation.removeListener(_effectivelyMarkNeedsPaint);
    _moveAnimation = value;
    _moveAnimation.addListener(_effectivelyMarkNeedsPaint);
    _effectivelyMarkNeedsPaint();
  }

  void _effectivelyMarkNeedsPaint() {
    if (_isPaintRunning) return;
    _isPaintRunning = true;
    markNeedsPaint();
    _isPaintRunning = false;
  }

  /// Sets the scale alignment and marks the widget for repaint.
  void setScaleAlignment(Alignment alignment) {
    if (scaleAlignment == alignment) {
      return;
    }
    scaleAlignment = alignment;
    _effectivelyMarkNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;

    while (child != null) {
      // As we have checked above it is safe to force null check
      assert(
        child.parentData is MultiChildLayoutParentData,
        'Tooltip should only take `_TooltipLayoutId` as a child',
      );
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
      scaleAlignment ??= _defaultScaleAlignment(tooltipPosition);

      // Compute scale origin from alignment within the target rectangle.
      final halfTargetWidth = targetRect.width * 0.5;
      final halfTargetHeight = targetRect.height * 0.5;

      Offset scaleOrigin = Offset(
        targetRect.left +
            halfTargetWidth +
            (scaleAlignment!.x * halfTargetWidth),
        targetRect.top +
            halfTargetHeight +
            (scaleAlignment!.y * halfTargetHeight),
      );
      switch (tooltipPosition) {
        case TooltipPosition.top:
          scaleOrigin -= Offset(0, targetPadding.top + 5);
          break;
        case TooltipPosition.bottom:
          scaleOrigin += Offset(0, targetPadding.bottom + 5);
          break;
        case TooltipPosition.left:
          scaleOrigin -= Offset(targetPadding.left + 5, 0);
          break;
        case TooltipPosition.right:
          scaleOrigin += Offset(targetPadding.right + 5, 0);
          break;
      }

      // Compute movement offset based on animation progress.
      final Offset moveOffset = _calculateMoveOffset(tooltipPosition);

      context.canvas
        ..translate(scaleOrigin.dx, scaleOrigin.dy)
        ..scale(_scaleAnimation.value);

      // paint children
      _paintChildren(
        context.canvas,
        context.paintChild,
        child,
        childParentData,
        scaleOrigin,
        moveOffset,
      );

      context.canvas.restore();
      child = childParentData.nextSibling;
    }
    _isPaintRunning = false;
  }

  /// Determines the default scale alignment based on tooltip position.
  Alignment _defaultScaleAlignment(TooltipPosition tooltipPosition) {
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
  Offset _calculateMoveOffset(TooltipPosition tooltipPosition) {
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
    Canvas canvas,
    PaintChildCallBack paintChild,
    RenderBox child,
    MultiChildLayoutParentData childParentData,
    Offset scaleOrigin,
    Offset moveOffset,
  ) {
    final halfChildWidth = child.size.width * 0.5;
    final halfChildHeight = child.size.height * 0.5;
    // Step 1: Translate the canvas to the center of the arrow
    // This moves the origin point to the center of the child widget
    // by accounting for scale origin, child offset, and child dimensions
    canvas
      ..translate(
        -scaleOrigin.dx + childParentData.offset.dx + halfChildWidth,
        -scaleOrigin.dy + childParentData.offset.dy + halfChildHeight,
      )

      // Step 2: Apply additional movement offset
      // This adjusts the arrow position based on the provided moveOffset
      ..translate(moveOffset.dx, moveOffset.dy)

      // Step 3: Rotate the canvas based on the tooltip's rotation angle
      // This orients the arrow in the correct direction
      ..rotate(tooltipPosition.rotationAngle);

    // Step 4: Paint the child (arrow) with its center at the canvas origin
    // The negative offsets ensure the child is centered at the origin point
    paintChild(
      child,
      Offset(-halfChildWidth, -halfChildHeight),
    );
  }

  /// Paints normal children with translation and animation effects.
  void _paintChild(
    Canvas canvas,
    PaintChildCallBack paintChild,
    RenderBox child,
    MultiChildLayoutParentData childParentData,
    Offset scaleOrigin,
    Offset moveOffset,
  ) {
    canvas
      ..translate(
        -scaleOrigin.dx + childParentData.offset.dx,
        -scaleOrigin.dy + childParentData.offset.dy,
      )
      ..translate(moveOffset.dx, moveOffset.dy);
    paintChild(child, Offset.zero);
  }

  void _paintChildren(
    Canvas canvas,
    PaintChildCallBack paintChild,
    RenderBox child,
    MultiChildLayoutParentData childParentData,
    Offset scaleOrigin,
    Offset moveOffset,
  ) {
    // Adjust for arrow rendering or normal child rendering.
    if (childParentData.id == TooltipLayoutSlot.arrow) {
      _paintArrow(
        canvas,
        paintChild,
        child,
        childParentData,
        scaleOrigin,
        moveOffset,
      );
    } else {
      _paintChild(
        canvas,
        paintChild,
        child,
        childParentData,
        scaleOrigin,
        moveOffset,
      );
    }
  }
}
