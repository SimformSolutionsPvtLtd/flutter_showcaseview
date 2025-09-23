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

/// Custom RenderObject that handles tooltip positioning and layout
/// Manages the positioning of tooltip content, action buttons, and arrow
/// while ensuring the tooltip stays within screen boundaries
class _RenderPositionDelegate extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  /// Creates a new RenderPositionDelegate for tooltip layout
  ///
  /// [targetPosition] - Position of the target widget that triggered the
  /// tooltip
  /// [targetSize] - Size of the target widget
  /// [position] - Optional preferred position for the tooltip
  /// [screenSize] - Current screen size to respect boundaries
  /// [hasSecondBox] - Whether an action box exists below the main tooltip
  /// [hasArrow] - Whether to show a directional arrow pointing to the target
  /// [toolTipSlideEndDistance] - Distance for slide animations
  /// [gapBetweenContentAndAction] - Spacing between tooltip content and
  /// action buttons
  /// [screenEdgePadding] - Minimum padding from screen edges
  /// [targetPadding] - Padding around the target
  _RenderPositionDelegate({
    required this.targetPosition,
    required this.targetSize,
    required this.position,
    required this.screenSize,
    required this.hasSecondBox,
    required this.hasArrow,
    required this.arrowAlignment,
    this.arrowPadding,
    this.tooltipBorderRadius,
    required this.toolTipSlideEndDistance,
    required this.gapBetweenContentAndAction,
    required this.screenEdgePadding,
    required this.targetPadding,
    required this.showcaseOffset,
    required this.targetTooltipGap,
  });

  // Core positioning parameters
  Offset targetPosition;
  Size targetSize;
  TooltipPosition? position;
  Size screenSize;
  bool hasSecondBox;
  bool hasArrow;
  ArrowAlignment arrowAlignment;
  double? arrowPadding;
  BorderRadius? tooltipBorderRadius;
  double toolTipSlideEndDistance;
  double gapBetweenContentAndAction;
  double screenEdgePadding;
  EdgeInsets targetPadding;
  double targetTooltipGap;

  /// This is used when there is some space around showcaseview as this widget
  /// implementation works in global coordinate system so because of that we
  /// need to manage local position by our self
  /// To check this usecase wrap material app in padding widget
  Offset showcaseOffset;

  /// Calculated tooltip position after layout
  late TooltipPosition tooltipPosition;

  @override
  void setupParentData(RenderBox child) {
    // Ensure all children have the correct parent data type
    if (child.parentData is MultiChildLayoutParentData) return;
    child.parentData = MultiChildLayoutParentData();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Standard hit testing implementation for children
    return defaultHitTestChildren(result, position: position + showcaseOffset);
  }

  // Layout properties - keep only those not managed by RenderObjectManager
  var _needToResize = false;
  var _needToFlip = false;

  // These are the max size tooltip can have
  // these can change as per the tooltip widget configuration and content
  var _maxWidth = 0.0;
  var _maxHeight = 0.0;

  // These are the total size that we can use for tooltip
  // This will be fixed after initial layout and will not change after that
  var _availableScreenWidth = 0.0;
  var _availableScreenHeight = 0.0;
  var _minimumActionBoxSize = Size.zero;

  Size get _toolTipBoxSize =>
      TooltipLayoutSlot.tooltipBox.getObjectManager?.size ?? Size.zero;

  Size get _actionBoxSize =>
      TooltipLayoutSlot.actionBox.getObjectManager?.size ?? Size.zero;

  double get _xOffset =>
      TooltipLayoutSlot.tooltipBox.getObjectManager?.xOffset ?? 0.0;

  set _xOffset(double value) =>
      TooltipLayoutSlot.tooltipBox.getObjectManager?.xOffset = value;

  double get _yOffset =>
      TooltipLayoutSlot.tooltipBox.getObjectManager?.yOffset ?? 0.0;

  set _yOffset(double value) =>
      TooltipLayoutSlot.tooltipBox.getObjectManager?.yOffset = value;

  double get _getArrowPadding => hasArrow
      ? Constants.withArrowToolTipPadding
      : Constants.withOutArrowToolTipPadding;

  // Override to make this object a repaint boundary for better raster thread performance
  @override
  bool get isRepaintBoundary => true;

  @override
  void performLayout() {
    // Initialize
    _initializeLayout();

    // Identify child elements
    _identifyChildren();

    // Calculate sizes
    _performDryLayout();
    _normalizeWidths();

    // Calculate tooltip position
    final tooltipHeight = _calculateTooltipHeight();
    _determineTooltipPosition(tooltipHeight);

    // Position tooltip and handle constraints
    _calculateInitialPosition();
    _handleHorizontalBoundaries(tooltipHeight);
    _handleVerticalBoundaries(tooltipHeight);

    // Apply changes based on constraints
    _handleResizing();
    _handleFlipping();
    _applyBoundaryConstraints(tooltipHeight);

    // Final layout and positioning
    _performFinalChildLayout();

    // Cleanup
    RenderObjectManager.clear();
  }

  /// Initialize layout variables and set size
  void _initializeLayout() {
    // Set size for this render object
    size = constraints.biggest;

    final totalScreenEdgePadding = 2 * screenEdgePadding;

    // Get available screen dimensions
    _availableScreenWidth = screenSize.width - totalScreenEdgePadding;
    _availableScreenHeight = screenSize.height - totalScreenEdgePadding;

    // Reset layout variables
    _needToResize = _needToFlip = false;
  }

  /// Find and identify children by ID
  void _identifyChildren() {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as MultiChildLayoutParentData;

      final parentId = childParentData.id;
      if (parentId is! TooltipLayoutSlot) {
        child = childParentData.nextSibling;
        continue;
      }

      RenderObjectManager(customRenderBox: child, slot: parentId);
      child = childParentData.nextSibling;
    }
  }

  /// Perform dry layout to determine natural sizes for all children
  void _performDryLayout() {
    // Dry layout arrow
    TooltipLayoutSlot.arrow.getObjectManager?.performDryLayout(
      const BoxConstraints.tightFor(
        width: Constants.arrowWidth,
        height: Constants.arrowHeight,
      ),
    );

    // Dry layout main tooltip content
    TooltipLayoutSlot.tooltipBox.getObjectManager?.performDryLayout(
      const BoxConstraints.tightFor(),
    );

    // Dry layout action box (if exists)
    TooltipLayoutSlot.actionBox.getObjectManager?.performDryLayout(
      const BoxConstraints.tightFor(),
    );
    _minimumActionBoxSize = _actionBoxSize;
  }

  /// Normalize widths between tooltip and action box
  void _normalizeWidths() {
    // Make both boxes the same width (use the wider one)
    final tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
    final actionBoxManager = TooltipLayoutSlot.actionBox.getObjectManager;

    if (actionBoxManager == null || tooltipBoxManager == null) return;

    final actionBoxWidth = actionBoxManager.size.width;
    final tooltipBoxWidth = tooltipBoxManager.size.width;

    if (actionBoxWidth > tooltipBoxWidth) {
      // Action box is wider, recalculate tooltip dry layout with new width
      tooltipBoxManager.performDryLayout(
        BoxConstraints.tightFor(width: actionBoxWidth),
      );
    } else if (tooltipBoxWidth > actionBoxWidth && hasSecondBox) {
      // Tooltip is wider, recalculate action box dry layout with new width
      actionBoxManager.performDryLayout(
        BoxConstraints.tightFor(width: tooltipBoxWidth),
      );
    }
  }

  /// Calculate the total tooltip height including all components
  double _calculateTooltipHeight() {
    final tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
    if (tooltipBoxManager == null) return 0;

    var tooltipHeight = tooltipBoxManager.size.height;
    if (hasSecondBox) {
      if (TooltipLayoutSlot.actionBox.getObjectManager
          case final actionBoxManager?) {
        tooltipHeight +=
            actionBoxManager.size.height + gapBetweenContentAndAction;
      }
    }
    return tooltipHeight;
  }

  /// Determine optimal tooltip position based on available space
  void _determineTooltipPosition(double tooltipHeight) {
    // Use provided position or Try positions in priority order:
    // bottom, top, left, right
    tooltipPosition = position ??
        _getSuitablePosition(_toolTipBoxSize, tooltipHeight).calculate();
  }

  /// Calculate initial tooltip position
  void _calculateInitialPosition() {
    final tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
    if (tooltipBoxManager == null) return;

    final initialPosition = positionToolTip(
      targetSize: targetSize,
      toolTipBoxSize: tooltipBoxManager.size,
      tooltipPosition: tooltipPosition,
    );

    // Set position in manager
    tooltipBoxManager.setOffset(initialPosition.dx, initialPosition.dy);

    // Initialize maximum dimensions
    _maxWidth = tooltipBoxManager.size.width;
    _maxHeight = _calculateTooltipHeight();
  }

  /// Handle horizontal screen boundary constraints
  void _handleHorizontalBoundaries(double tooltipHeight) {
    final tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
    if (tooltipBoxManager == null) return;

    final offset = tooltipBoxManager.getOffset;

    // Check which boundary is exceeded
    if (offset.dx < screenEdgePadding + showcaseOffset.dx) {
      _handleLeftEdgeBoundary(tooltipHeight);
    } else if (offset.dx + tooltipBoxManager.size.width - showcaseOffset.dx >
        screenSize.width - screenEdgePadding) {
      _handleRightEdgeBoundary(tooltipHeight);
    }
  }

  /// Handle tooltip exceeding left or right screen edge
  void _handleHorizontalEdgeBoundary({
    required double tooltipHeight,
    required bool isLeftEdge,
  }) {
    final edgePosition =
        isLeftEdge ? TooltipPosition.left : TooltipPosition.right;

    // Calculate minimum width that would fit
    final minWidth = isLeftEdge
        ? targetPosition.dx -
            showcaseOffset.dx -
            screenEdgePadding -
            targetTooltipGap -
            targetPadding.left -
            _getArrowPadding
        : screenSize.width - screenEdgePadding - _xOffset - targetPadding.right;

    if ((isLeftEdge && tooltipPosition.isLeft) ||
        (!isLeftEdge && tooltipPosition.isRight)) {
      final optimalPosition = _getOptimalPositionForConstraint(
        currentPosition: edgePosition,
        tooltipHeight: tooltipHeight,
        canResize: minWidth > Constants.minimumToolTipWidth &&
            minWidth > _minimumActionBoxSize.width,
      );

      switch (optimalPosition) {
        case TooltipPosition.left:
          if (isLeftEdge) {
            // Resize tooltip to fit on left edge
            _maxWidth = minWidth;
            _xOffset = screenEdgePadding + showcaseOffset.dx;
            _needToResize = true;
          } else {
            // Flip to opposite side
            _needToFlip = true;
          }
        case TooltipPosition.right:
          if (!isLeftEdge) {
            // Resize tooltip to fit on right edge
            _maxWidth = screenSize.width - _xOffset - screenEdgePadding;
            _needToResize = true;
          } else {
            // Flip to opposite side
            _needToFlip = true;
          }
        case TooltipPosition.bottom:
        case TooltipPosition.top:
          // Switch to vertical position
          tooltipPosition = optimalPosition;
          _maxWidth = _maxWidth.clamp(0.0, _availableScreenWidth);
          _needToResize = true;
      }
    } else if (tooltipPosition.isVertical) {
      // For top/bottom positions, ensure width fits and adjust alignment
      if (_maxWidth > _availableScreenWidth) {
        _maxWidth = _availableScreenWidth;
        _needToResize = true;
        _xOffset = screenEdgePadding + showcaseOffset.dx;
      } else if (!isLeftEdge) {
        // Align to right edge
        _xOffset = screenSize.width -
            screenEdgePadding -
            _toolTipBoxSize.width +
            showcaseOffset.dx;
      } else {
        // Align to left edge
        _xOffset = screenEdgePadding + showcaseOffset.dx;
      }
    }
  }

  /// Handle tooltip exceeding left screen edge
  void _handleLeftEdgeBoundary(double tooltipHeight) {
    _handleHorizontalEdgeBoundary(
      tooltipHeight: tooltipHeight,
      isLeftEdge: true,
    );
  }

  /// Handle tooltip exceeding right screen edge
  void _handleRightEdgeBoundary(double tooltipHeight) {
    _handleHorizontalEdgeBoundary(
      tooltipHeight: tooltipHeight,
      isLeftEdge: false,
    );
  }

  /// Handle vertical screen boundary constraints
  void _handleVerticalBoundaries(double tooltipHeight) {
    // Recalculate max height based on new width constraints
    _recalculateMaxHeight();

    final extraVerticalComponentHeight = _calculateExtraVerticalHeight();

    // Check which vertical boundary is exceeded
    if (_yOffset < screenEdgePadding + showcaseOffset.dy) {
      _handleTopEdgeBoundary(tooltipHeight);
    } else if (_yOffset +
            _maxHeight +
            extraVerticalComponentHeight -
            showcaseOffset.dy >
        screenSize.height - screenEdgePadding) {
      _handleBottomEdgeBoundary(tooltipHeight);
    }
  }

  /// Returns optimal position based on current constraints
  TooltipPosition _getOptimalPositionForConstraint({
    required TooltipPosition currentPosition,
    required double tooltipHeight,
    required bool canResize,
  }) {
    // First preference: resize in current position if possible
    if (canResize) return currentPosition;

    // Second preference: check opposite direction
    final oppositePosition = currentPosition.opposite;

    final suitablePosition =
        _getSuitablePosition(_toolTipBoxSize, tooltipHeight);

    if (suitablePosition.checkFor(oppositePosition)) return oppositePosition;

    // Third preference: try bottom position
    if (currentPosition != TooltipPosition.bottom &&
        suitablePosition.checkFor(TooltipPosition.bottom)) {
      return TooltipPosition.bottom;
    }

    // Fourth preference: try top position
    if (currentPosition != TooltipPosition.top &&
        suitablePosition.checkFor(TooltipPosition.top)) {
      return TooltipPosition.top;
    }

    // Fifth preference: try horizontal positions if not already tried
    if (currentPosition.isVertical) {
      if (suitablePosition.checkFor(TooltipPosition.left)) {
        return TooltipPosition.left;
      }
      if (suitablePosition.checkFor(TooltipPosition.right)) {
        return TooltipPosition.right;
      }
    }

    // Last resort: stay in current position and resize
    return currentPosition;
  }

  /// Recalculate max height based on new width constraints
  void _recalculateMaxHeight() {
    _maxHeight = TooltipLayoutSlot.tooltipBox.getObjectManager?.customRenderBox
            .getDryLayout(BoxConstraints.tightFor(width: _maxWidth))
            .height ??
        0;
    if (!hasSecondBox) return;
    _maxHeight += _actionBoxSize.height + gapBetweenContentAndAction;
  }

  /// Calculate extra vertical component height for arrow and padding
  double _calculateExtraVerticalHeight() {
    return tooltipPosition.isHorizontal
        ? 0
        : targetTooltipGap + _getArrowPadding;
  }

  /// Handle tooltip exceeding top or bottom screen edge
  void _handleVerticalEdgeBoundary({
    required double tooltipHeight,
    required bool isTopEdge,
  }) {
    final edgePosition =
        isTopEdge ? TooltipPosition.top : TooltipPosition.bottom;

    if ((isTopEdge && tooltipPosition.isTop) ||
        (!isTopEdge && tooltipPosition.isBottom)) {
      final optimalPosition = _getOptimalPositionForConstraint(
        currentPosition: edgePosition,
        tooltipHeight: tooltipHeight,
        canResize: false, // Vertical positioning is constrained by screen edge
      );

      if (optimalPosition == edgePosition.opposite) {
        // Option 1: Flip to opposite side if it fits
        _needToFlip = true;
        return;
      }
      switch (optimalPosition) {
        case TooltipPosition.left:
        case TooltipPosition.right:
          // Option 2: Switch to horizontal position if it fits
          tooltipPosition = optimalPosition;
          if (_maxHeight > _availableScreenHeight) {
            _maxHeight = _availableScreenHeight;
          }
          _needToResize = true;
        case TooltipPosition.top:
        case TooltipPosition.bottom:
          // Option 3: Last resort - resize and keep at current edge
          _handleLastResortResizing(
            isTopEdge: isTopEdge,
            tooltipHeight: tooltipHeight,
          );
      }
    } else if (tooltipPosition.isHorizontal) {
      // For left/right positions, ensure height fits
      if (_maxHeight > _availableScreenHeight) {
        _needToResize = true;
        _yOffset = screenEdgePadding + showcaseOffset.dy;
      } else if (!isTopEdge) {
        // Align to bottom edge (only for bottom boundary handling)
        _yOffset = screenSize.height -
            screenEdgePadding -
            tooltipHeight +
            showcaseOffset.dy;
      } else {
        // Align to top edge (only for top boundary handling)
        _yOffset = screenEdgePadding + showcaseOffset.dy;
      }
    }
  }

  /// Handle tooltip exceeding top screen edge
  void _handleTopEdgeBoundary(double tooltipHeight) {
    _handleVerticalEdgeBoundary(tooltipHeight: tooltipHeight, isTopEdge: true);
  }

  /// Handle tooltip exceeding bottom screen edge
  void _handleBottomEdgeBoundary(double tooltipHeight) {
    _handleVerticalEdgeBoundary(tooltipHeight: tooltipHeight, isTopEdge: false);
  }

  /// Handle last resort resizing when tooltip must stay at current edge
  void _handleLastResortResizing({
    required bool isTopEdge,
    required double tooltipHeight,
  }) {
    _needToResize = true;

    if (isTopEdge) {
      // Top edge - resize and keep at top
      _maxHeight -= screenEdgePadding - _xOffset;
      _yOffset = screenEdgePadding + showcaseOffset.dy;
    } else {
      // Bottom edge - keep at bottom
      _yOffset = screenSize.height -
          showcaseOffset.dy -
          screenEdgePadding -
          _maxHeight;
    }
  }

  /// Handle resizing if needed
  void _handleResizing() {
    if (!_needToResize ||
        TooltipLayoutSlot.tooltipBox.getObjectManager == null) {
      return;
    }

    // Calculate tooltip box height
    var tooltipBoxHeight = _maxHeight;
    if (hasSecondBox) {
      tooltipBoxHeight -= _actionBoxSize.height + gapBetweenContentAndAction;
    }

    // Resize tooltip box
    TooltipLayoutSlot.tooltipBox.getObjectManager?.performLayout(
      BoxConstraints.tightFor(width: _maxWidth, height: tooltipBoxHeight),
    );

    // Resize action box if exists
    TooltipLayoutSlot.actionBox.getObjectManager?.performLayout(
      BoxConstraints.tightFor(width: _maxWidth),
    );

    // Recalculate position if not flipping
    if (_needToFlip) return;
    final initialPosition = positionToolTip(
      targetSize: targetSize,
      toolTipBoxSize: _toolTipBoxSize,
      tooltipPosition: tooltipPosition,
    );
    _xOffset = initialPosition.dx;
    _yOffset = initialPosition.dy;
  }

  /// Handle flipping to opposite side if needed
  void _handleFlipping() {
    if (!_needToFlip) return;

    switch (tooltipPosition) {
      case TooltipPosition.bottom:
        // Flip from bottom to top
        tooltipPosition = TooltipPosition.top;
        _yOffset = targetPosition.dy -
            _toolTipBoxSize.height -
            targetTooltipGap -
            _getArrowPadding;

      case TooltipPosition.top:
        // Flip from top to bottom
        tooltipPosition = TooltipPosition.bottom;
        _yOffset = targetPosition.dy +
            targetSize.height +
            targetTooltipGap +
            _getArrowPadding;

      case TooltipPosition.left:
        // Flip from left to right
        tooltipPosition = TooltipPosition.right;
        _xOffset = targetPosition.dx +
            targetSize.width +
            targetTooltipGap +
            _getArrowPadding;

      case TooltipPosition.right:
        // Flip from right to left
        tooltipPosition = TooltipPosition.left;
        _xOffset = targetPosition.dx -
            _toolTipBoxSize.width -
            targetTooltipGap -
            _getArrowPadding;
    }
  }

  /// Apply final boundary constraints to ensure tooltip stays on screen
  void _applyBoundaryConstraints(double tooltipHeight) {
    final screenStart = Offset(
      screenEdgePadding + showcaseOffset.dx,
      screenEdgePadding + showcaseOffset.dy,
    );

    final screenEnd = Offset(
      screenSize.width -
          _toolTipBoxSize.width -
          screenEdgePadding +
          showcaseOffset.dx,
      screenSize.height - tooltipHeight - screenEdgePadding + showcaseOffset.dy,
    );

    // Ensure tooltip stays within horizontal screen bounds
    _xOffset = screenStart.dx > screenEnd.dx
        ? screenStart.dx
        : _xOffset.clamp(screenStart.dx, screenEnd.dx);

    // Ensure tooltip stays within vertical screen bounds
    _yOffset = screenStart.dy > screenEnd.dy
        ? screenStart.dy
        : _yOffset.clamp(screenStart.dy, screenEnd.dy);

    // Apply target padding based on position
    _applyTargetPadding();
  }

  /// Apply target padding based on tooltip position
  void _applyTargetPadding() {
    switch (tooltipPosition) {
      case TooltipPosition.top:
        _yOffset -= targetPadding.top;
      case TooltipPosition.bottom:
        _yOffset += targetPadding.bottom;
      case TooltipPosition.left:
        _xOffset -= targetPadding.left;
      case TooltipPosition.right:
        _xOffset += targetPadding.right;
    }
  }

  /// Perform final layout for all child elements
  void _performFinalChildLayout() {
    // Layout arrow
    _layoutArrowElement();

    // Layout tooltip box
    _layoutTooltipBox();

    // Layout action box
    _layoutActionBox();

    // Position arrow
    _positionArrow();
  }

  /// Layout the arrow element
  void _layoutArrowElement() {
    TooltipLayoutSlot.arrow.getObjectManager?.performLayout(
      const BoxConstraints.tightFor(
        width: Constants.arrowWidth,
        height: Constants.arrowHeight,
      ),
    );
  }

  /// Layout the tooltip content box
  void _layoutTooltipBox() {
    TooltipLayoutSlot.tooltipBox.getObjectManager?.performLayout(
      BoxConstraints.tightFor(
        width: _toolTipBoxSize.width,
        height: _toolTipBoxSize.height,
      ),
    );

    // Position the tooltip content box
    final firstBoxParentData =
        TooltipLayoutSlot.tooltipBox.getObjectManager?.layoutParentData;
    firstBoxParentData?.offset = Offset(_xOffset, _yOffset);
  }

  /// Layout the action box
  void _layoutActionBox() {
    TooltipLayoutSlot.actionBox.getObjectManager?.performLayout(
      BoxConstraints.tightFor(
        width: _actionBoxSize.width,
        height: _actionBoxSize.height,
      ),
    );

    // Position the action box differently based on tooltip direction
    TooltipLayoutSlot.actionBox.getObjectManager?.layoutParentData.offset =
        Offset(
      _xOffset,
      tooltipPosition.isTop
          // For top tooltips, action box goes above content
          ? _yOffset - _actionBoxSize.height - gapBetweenContentAndAction
          // For other positions, action box goes below content
          : _yOffset + _toolTipBoxSize.height + gapBetweenContentAndAction,
    );
  }

  /// Position the arrow element
  void _positionArrow() {
    final arrowBoxParentData =
        TooltipLayoutSlot.arrow.getObjectManager?.layoutParentData;
    if (!hasArrow || arrowBoxParentData == null) return;

    const halfArrowWidth = Constants.arrowWidth * 0.5;
    const halfArrowHeight = Constants.arrowWidth * 0.5;

    // Calculate arrow position based on alignment
    switch (tooltipPosition) {
      case TooltipPosition.top:
        // Arrow points down from bottom of tooltip
        final arrowX = _calculateArrowX(
          alignment: arrowAlignment,
          halfArrowWidth: halfArrowWidth,
          targetPosition: targetPosition,
          targetSize: targetSize,
          tooltipPosition: Offset(_xOffset, _yOffset),
          tooltipSize: _toolTipBoxSize,
        );
        arrowBoxParentData.offset = Offset(
          arrowX,
          _yOffset + _toolTipBoxSize.height - 2,
        );

      case TooltipPosition.bottom:
        // Arrow points up from top of tooltip
        final arrowX = _calculateArrowX(
          alignment: arrowAlignment,
          halfArrowWidth: halfArrowWidth,
          targetPosition: targetPosition,
          targetSize: targetSize,
          tooltipPosition: Offset(_xOffset, _yOffset),
          tooltipSize: _toolTipBoxSize,
        );
        arrowBoxParentData.offset = Offset(
          arrowX,
          _yOffset - Constants.arrowHeight + 1,
        );

      case TooltipPosition.left:
        // Arrow points right from right side of tooltip
        final arrowY = _calculateArrowY(
          alignment: arrowAlignment,
          halfArrowWidth: halfArrowWidth,
          targetSize: targetSize,
          tooltipSize: _toolTipBoxSize,
          targetPosition: targetPosition,
          tooltipPosition: Offset(_xOffset, _yOffset),
        );
        arrowBoxParentData.offset = Offset(
          _xOffset + _toolTipBoxSize.width - halfArrowHeight + 4,
          arrowY,
        );

      case TooltipPosition.right:
        // Arrow points left from left side of tooltip
        final arrowY = _calculateArrowY(
          alignment: arrowAlignment,
          halfArrowWidth: halfArrowWidth,
          targetSize: targetSize,
          tooltipSize: _toolTipBoxSize,
          targetPosition: targetPosition,
          tooltipPosition: Offset(_xOffset, _yOffset),
        );
        arrowBoxParentData.offset = Offset(
          _xOffset - Constants.arrowHeight - 4,
          arrowY,
        );
    }
  }

  /// Calculate position-specific padding for horizontal arrow positioning
  /// Considers only the relevant corner radius based on arrow alignment and tooltip position
  double _calculateHorizontalPadding({
    required ArrowAlignment alignment,
    required TooltipPosition tooltipPosition,
  }) {
    if (arrowPadding != null) {
      return arrowPadding!;
    }

    if (tooltipBorderRadius == null) {
      return 8.0;
    }

    var relevantRadius = 0.0;

    // For horizontal positioning, we care about the X-axis radius of relevant corners
    switch (alignment) {
      case ArrowAlignment.start:
        // Arrow at start (left side) - consider left corners
        if (tooltipPosition == TooltipPosition.top) {
          relevantRadius =
              tooltipBorderRadius!.bottomLeft.x; // Bottom-left for top tooltip
        } else if (tooltipPosition == TooltipPosition.bottom) {
          relevantRadius =
              tooltipBorderRadius!.topLeft.x; // Top-left for bottom tooltip
        } else {
          // For left/right tooltips, use the larger left radius
          relevantRadius = [
            tooltipBorderRadius!.topLeft.x,
            tooltipBorderRadius!.bottomLeft.x,
          ].reduce((a, b) => a > b ? a : b);
        }
        break;

      case ArrowAlignment.end:
        // Arrow at end (right side) - consider right corners
        if (tooltipPosition == TooltipPosition.top) {
          relevantRadius = tooltipBorderRadius!
              .bottomRight.x; // Bottom-right for top tooltip
        } else if (tooltipPosition == TooltipPosition.bottom) {
          relevantRadius =
              tooltipBorderRadius!.topRight.x; // Top-right for bottom tooltip
        } else {
          // For left/right tooltips, use the larger right radius
          relevantRadius = [
            tooltipBorderRadius!.topRight.x,
            tooltipBorderRadius!.bottomRight.x,
          ].reduce((a, b) => a > b ? a : b);
        }
        break;

      case ArrowAlignment.center:
        // For center alignment, we don't need curve-specific padding
        // Use a minimal padding since arrow is away from corners
        return 8.0;
    }

    // Calculate curve-aware padding instead of using full radius
    return _calculateCurveAwarePadding(relevantRadius);
  }

  /// Calculate position-specific padding for vertical arrow positioning
  /// Considers only the relevant corner radius based on arrow alignment and tooltip position
  double _calculateVerticalPadding({
    required ArrowAlignment alignment,
    required TooltipPosition tooltipPosition,
  }) {
    if (arrowPadding != null) {
      return arrowPadding!;
    }

    if (tooltipBorderRadius == null) {
      return 8.0;
    }

    var relevantRadius = 0.0;

    // For vertical positioning, we care about the Y-axis radius of relevant corners
    switch (alignment) {
      case ArrowAlignment.start:
        // Arrow at start (top side) - consider top corners
        if (tooltipPosition == TooltipPosition.left) {
          relevantRadius =
              tooltipBorderRadius!.topRight.y; // Top-right for left tooltip
        } else if (tooltipPosition == TooltipPosition.right) {
          relevantRadius =
              tooltipBorderRadius!.topLeft.y; // Top-left for right tooltip
        } else {
          // For top/bottom tooltips, use the larger top radius
          relevantRadius = [
            tooltipBorderRadius!.topLeft.y,
            tooltipBorderRadius!.topRight.y,
          ].reduce((a, b) => a > b ? a : b);
        }
        break;

      case ArrowAlignment.end:
        // Arrow at end (bottom side) - consider bottom corners
        if (tooltipPosition == TooltipPosition.left) {
          relevantRadius = tooltipBorderRadius!
              .bottomRight.y; // Bottom-right for left tooltip
        } else if (tooltipPosition == TooltipPosition.right) {
          relevantRadius = tooltipBorderRadius!
              .bottomLeft.y; // Bottom-left for right tooltip
        } else {
          // For top/bottom tooltips, use the larger bottom radius
          relevantRadius = [
            tooltipBorderRadius!.bottomLeft.y,
            tooltipBorderRadius!.bottomRight.y,
          ].reduce((a, b) => a > b ? a : b);
        }
        break;

      case ArrowAlignment.center:
        // For center alignment, we don't need curve-specific padding
        // Use a minimal padding since arrow is away from corners
        return 8.0;
    }

    // Calculate curve-aware padding instead of using full radius
    return _calculateCurveAwarePadding(relevantRadius);
  }

  /// Calculate curve-aware padding that considers the geometric arc intersection
  /// Rather than using the full radius, this calculates where the curve actually
  /// affects the straight edge of the tooltip
  double _calculateCurveAwarePadding(double radius) {
    if (radius == 0.0) {
      return 8.0; // Default padding for sharp corners
    }

    // For a rounded corner with radius r, the curve creates an arc
    // The "effective radius" for padding is much smaller than the full radius
    // We want to avoid the curve but not over-compensate

    // Use a fraction of the radius plus a small buffer
    // This ensures we clear the curve without excessive padding
    final effectivePadding = (radius * 0.3) + 4.0;

    // Ensure minimum padding and reasonable maximum
    return effectivePadding.clamp(6.0, radius * 0.5 + 8.0);
  }

  /// Calculate horizontal arrow position based on alignment for top/bottom tooltips
  double _calculateArrowX({
    required ArrowAlignment alignment,
    required double halfArrowWidth,
    required Size targetSize,
    required Size tooltipSize,
    required Offset targetPosition,
    required Offset tooltipPosition,
  }) {
    // Determine tooltip position based on arrow context
    final tooltipPos = tooltipPosition.dy < targetPosition.dy
        ? TooltipPosition.top
        : TooltipPosition.bottom;

    final padding = _calculateHorizontalPadding(
      alignment: alignment,
      tooltipPosition: tooltipPos,
    );
    final tooltipEnd = tooltipPosition.dx + tooltipSize.width;
    final targetEnd = targetPosition.dx + targetSize.width;
    final arrowEndWithPadding = halfArrowWidth * 2 + padding;
    final targetCenter = targetPosition.dx + (targetSize.width * 0.5);

    switch (alignment) {
      case ArrowAlignment.start:
        // Position arrow at the start (left) of target bounds, not tooltip
        final proposedX = targetPosition.dx;
        return proposedX
            .clamp(
              tooltipPosition.dx + padding,
              tooltipEnd - padding,
            )
            .clamp(targetPosition.dx + padding, targetEnd - padding);

      case ArrowAlignment.center:
        // Position arrow centered relative to target (default behavior)
        return (targetCenter - halfArrowWidth).clamp(
          tooltipPosition.dx + halfArrowWidth,
          tooltipEnd - halfArrowWidth,
        );

      case ArrowAlignment.end:
        // Position arrow at the end (right) of target bounds, not tooltip
        final proposedX = targetEnd;
        return proposedX
            .clamp(
              tooltipPosition.dx + arrowEndWithPadding,
              tooltipEnd - arrowEndWithPadding,
            )
            .clamp(targetPosition.dx + padding, targetEnd - padding);
    }
  }

  /// Calculate vertical arrow position based on alignment for left/right tooltips
  double _calculateArrowY({
    required ArrowAlignment alignment,
    required double halfArrowWidth,
    required Size targetSize,
    required Size tooltipSize,
    required Offset targetPosition,
    required Offset tooltipPosition,
  }) {
    // Determine tooltip position based on arrow context
    final tooltipPos = tooltipPosition.dx < targetPosition.dx
        ? TooltipPosition.left
        : TooltipPosition.right;

    final padding = _calculateVerticalPadding(
      alignment: alignment,
      tooltipPosition: tooltipPos,
    );
    final tooltipEnd = tooltipPosition.dy + tooltipSize.height;
    final targetEnd = targetPosition.dy + targetSize.height;
    final targetCenter = targetPosition.dy + (targetSize.height * 0.5);

    switch (alignment) {
      case ArrowAlignment.start:
        // Position arrow at the start (top) of target bounds, not tooltip
        final proposedY = targetPosition.dy;
        return proposedY
            .clamp(
              tooltipPosition.dy + (halfArrowWidth + 4),
              tooltipEnd - (padding + 2),
            )
            .clamp(targetPosition.dy + padding, targetEnd - padding);

      case ArrowAlignment.center:
        // Position arrow centered relative to target (default behavior)
        return (targetCenter - halfArrowWidth).clamp(
          tooltipPosition.dy + halfArrowWidth,
          tooltipEnd - halfArrowWidth,
        );

      case ArrowAlignment.end:
        // Position arrow at the end (bottom) of target bounds, not tooltip
        final proposedY = targetEnd;
        return proposedY
            .clamp(
              tooltipPosition.dy + padding,
              tooltipEnd - (halfArrowWidth * 2 + 2),
            )
            .clamp(targetPosition.dy + padding, targetEnd - padding);
    }
  }

  /// Helper function to calculate position based on selected direction
  Offset positionToolTip({
    required Size targetSize,
    required Size toolTipBoxSize,
    required TooltipPosition tooltipPosition,
  }) {
    final centerDxForTooltip = (targetSize.width - toolTipBoxSize.width) * 0.5;
    final centerDyForTooltip =
        (targetSize.height - toolTipBoxSize.height) * 0.5;

    return switch (tooltipPosition) {
      TooltipPosition.bottom => Offset(
          // Center horizontally below target
          targetPosition.dx + centerDxForTooltip,
          // Position below target with appropriate offset
          // and add additional padding if arrow is shown
          targetPosition.dy +
              targetSize.height +
              targetTooltipGap +
              _getArrowPadding,
        ),
      TooltipPosition.top => Offset(
          // Center horizontally above target
          targetPosition.dx + centerDxForTooltip,
          // Position above target with appropriate offset
          targetPosition.dy -
              toolTipBoxSize.height -
              targetTooltipGap -
              _getArrowPadding,
        ),
      TooltipPosition.left => Offset(
          // Position to the left of target with appropriate offset
          targetPosition.dx -
              toolTipBoxSize.width -
              targetTooltipGap -
              _getArrowPadding,
          // Center vertically beside target
          targetPosition.dy + centerDyForTooltip,
        ),
      TooltipPosition.right => Offset(
          // Position to the right of target with appropriate offset
          targetPosition.dx +
              targetSize.width +
              targetTooltipGap +
              _getArrowPadding,
          // Center vertically beside target
          targetPosition.dy + centerDyForTooltip,
        ),
    };
  }

  /// Determines in which positions the tooltip can be displayed without
  /// exceeding screen boundaries.
  ///
  /// This method evaluates the available space in all four directions (top,
  /// bottom, left, right)
  /// around the target element and determines whether the tooltip can fit in
  /// each direction while respecting screen edge padding.
  ///
  /// Parameters:
  /// - [tooltipSize]: The current width and height of the tooltip content
  /// - [totalHeight]: The total height including tooltip content and action
  /// box (if present)
  ///
  /// Returns:
  /// A [_SuitablePosition] object containing boolean flags for each valid
  /// position
  _SuitablePosition _getSuitablePosition(
    Size tooltipSize,
    double totalHeight,
  ) {
    final arrowPadding = _getArrowPadding;

    final isBottom = targetPosition.dy +
            targetSize.height +
            totalHeight +
            targetTooltipGap +
            arrowPadding -
            showcaseOffset.dy <=
        screenSize.height - screenEdgePadding;

    final isTop = targetPosition.dy -
            totalHeight -
            targetTooltipGap -
            arrowPadding -
            showcaseOffset.dy >=
        screenEdgePadding;

    final isLeft = targetPosition.dx -
            tooltipSize.width -
            targetTooltipGap -
            arrowPadding -
            showcaseOffset.dx >=
        screenEdgePadding;

    final isRight = targetPosition.dx +
            targetSize.width +
            tooltipSize.width +
            targetTooltipGap +
            arrowPadding -
            showcaseOffset.dx <=
        screenSize.width - screenEdgePadding;

    return _SuitablePosition(
      isBottom: isBottom,
      isLeft: isLeft,
      isRight: isRight,
      isTop: isTop,
    );
  }
}

class _SuitablePosition {
  const _SuitablePosition({
    this.isRight = false,
    this.isLeft = false,
    this.isTop = false,
    this.isBottom = false,
  });

  final bool isRight;

  final bool isLeft;

  final bool isTop;

  final bool isBottom;

  bool checkFor(TooltipPosition position) {
    return switch (position) {
      TooltipPosition.bottom => isBottom,
      TooltipPosition.top => isTop,
      TooltipPosition.left => isLeft,
      TooltipPosition.right => isRight,
    };
  }

  TooltipPosition calculate() {
    if (isBottom) return TooltipPosition.bottom;
    if (isTop) return TooltipPosition.top;
    if (isLeft) return TooltipPosition.left;
    if (isRight) return TooltipPosition.right;
    return TooltipPosition.bottom; // Default fallback
  }
}
