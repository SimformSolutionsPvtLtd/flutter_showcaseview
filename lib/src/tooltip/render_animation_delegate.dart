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

/// A callback function type used for painting children within a render object.
///
/// This callback takes a [RenderObject] child and an [Offset] that defines
/// the position where the child should be painted.
///
/// Used primarily in custom painting operations within tooltip rendering.
typedef PaintChildCallBack = void Function(RenderObject child, Offset offset);

/// A delegate for handling tooltip animations including scaling and movement.
class _RenderAnimationDelegate extends _RenderPositionDelegate {
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
    required super.showcaseOffset,
    required super.targetTooltipGap,
  })  : _scaleController = scaleController,
        _moveController = moveController,
        _scaleAnimation = scaleAnimation,
        _moveAnimation = moveAnimation {
    // Add listeners to trigger repaint when animations change.
    _scaleAnimation.addListener(_throttledMarkNeedsPaint);
    _moveAnimation.addListener(_throttledMarkNeedsPaint);
  }

  AnimationController _scaleController;
  AnimationController _moveController;
  Animation<double> _scaleAnimation;
  Animation<double> _moveAnimation;
  Alignment? scaleAlignment;

  /// This will stop extra repaint when paint function is already in progress
  bool _isPreviousRepaintInProgress = false;

  /// Cache for animation values to prevent unnecessary repaints
  double? _lastScaleValue;
  double? _lastMoveValue;

  /// Last time a repaint was requested (used for throttling)
  int _lastRepaintTime = 0;

  /// Minimum time between repaints in milliseconds (throttle to reduce load)
  static const _repaintThrottleMs = 8; // ~120fps

  /// Updates the scale animation controller.
  set scaleController(AnimationController value) {
    if (_scaleController == value) return;
    _scaleController = value;
  }

  /// Updates the move animation controller.
  set moveController(AnimationController value) {
    if (_moveController == value) return;
    _moveController = value;
  }

  /// Updates the scale animation and refreshes listeners.
  set scaleAnimation(Animation<double> value) {
    if (_scaleAnimation == value) return;
    _scaleAnimation.removeListener(_throttledMarkNeedsPaint);
    _scaleAnimation = value;
    _scaleAnimation.addListener(_throttledMarkNeedsPaint);
    markNeedsPaint();
  }

  /// Updates the move animation and refreshes listeners.
  set moveAnimation(Animation<double> value) {
    if (_moveAnimation == value) return;
    _moveAnimation.removeListener(_throttledMarkNeedsPaint);
    _moveAnimation = value;
    _moveAnimation.addListener(_throttledMarkNeedsPaint);
    _throttledMarkNeedsPaint();
  }

  /// Throttled version of markNeedsPaint to avoid excessive repaints
  void _throttledMarkNeedsPaint() {
    // Skip if a repaint is already in progress
    if (_isPreviousRepaintInProgress) return;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeSinceLastRepaint = currentTime - _lastRepaintTime;

    // Check if animation values have actually changed
    final currentScaleValue = _scaleAnimation.value;
    final currentMoveValue = _moveAnimation.value;

    // Only repaint if values changed and sufficient time has passed
    if ((currentScaleValue != _lastScaleValue ||
            currentMoveValue != _lastMoveValue) &&
        timeSinceLastRepaint >= _repaintThrottleMs) {
      _lastScaleValue = currentScaleValue;
      _lastMoveValue = currentMoveValue;
      _lastRepaintTime = currentTime;
      markNeedsPaint();
    }
  }

  /// Sets the scale alignment and marks the widget for repaint.
  void setScaleAlignment(Alignment alignment) {
    if (scaleAlignment == alignment) return;
    scaleAlignment = alignment;
    _throttledMarkNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    _isPreviousRepaintInProgress = true;
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
      final targetRect = Rect.fromLTWH(
        targetPosition.dx,
        targetPosition.dy,
        targetSize.width,
        targetSize.height,
      );

      // Determine scale alignment if not set.
      scaleAlignment ??= tooltipPosition.scaleAlignment;

      // Compute scale origin from alignment within the target rectangle.
      final halfTargetWidth = targetRect.width * 0.5;
      final halfTargetHeight = targetRect.height * 0.5;

      var scaleOrigin = Offset(
        targetRect.left +
            halfTargetWidth +
            (scaleAlignment!.x * halfTargetWidth),
        targetRect.top +
            halfTargetHeight +
            (scaleAlignment!.y * halfTargetHeight),
      );
      switch (tooltipPosition) {
        case TooltipPosition.top:
          scaleOrigin -= Offset(
            0,
            targetPadding.top + Constants.extraAlignmentOffset,
          );
        case TooltipPosition.bottom:
          scaleOrigin += Offset(
            0,
            targetPadding.bottom + Constants.extraAlignmentOffset,
          );
        case TooltipPosition.left:
          scaleOrigin -= Offset(
            targetPadding.left + Constants.extraAlignmentOffset,
            0,
          );
        case TooltipPosition.right:
          scaleOrigin += Offset(
            targetPadding.right + Constants.extraAlignmentOffset,
            0,
          );
      }

      // Compute movement offset based on animation progress.
      final moveOffset = tooltipPosition.calculateMoveOffset(
        _moveAnimation.value,
        toolTipSlideEndDistance,
      );

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
    _isPreviousRepaintInProgress = false;
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
    paintChild(child, Offset(-halfChildWidth, -halfChildHeight));
  }

  /// Paints normal children with translation and animation effects.
  void _paintChild(
    PaintChildCallBack paintChild,
    RenderBox child,
    MultiChildLayoutParentData childParentData,
    Offset scaleOrigin,
    Offset moveOffset,
  ) {
    paintChild(child, moveOffset + childParentData.offset - scaleOrigin);
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
        paintChild,
        child,
        childParentData,
        scaleOrigin,
        moveOffset,
      );
    }
  }
}
