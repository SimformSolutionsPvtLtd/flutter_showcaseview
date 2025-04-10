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
  /// [targetPosition] - Position of the target widget that triggered the tooltip
  /// [targetSize] - Size of the target widget
  /// [position] - Optional preferred position for the tooltip
  /// [screenSize] - Current screen size to respect boundaries
  /// [hasSecondBox] - Whether an action box exists below the main tooltip
  /// [hasArrow] - Whether to show a directional arrow pointing to the target
  /// [toolTipSlideEndDistance] - Distance for slide animations
  /// [gapBetweenContentAndAction] - Spacing between tooltip content and action buttons
  /// [screenEdgePadding] - Minimum padding from screen edges
  /// [targetPadding] - Padding around the target
  _RenderPositionDelegate({
    required this.targetPosition,
    required this.targetSize,
    required this.position,
    required this.screenSize,
    required this.hasSecondBox,
    required this.hasArrow,
    required this.toolTipSlideEndDistance,
    required this.gapBetweenContentAndAction,
    required this.screenEdgePadding,
    required this.targetPadding,
    required this.showcaseOffset,
  });

  // Core positioning parameters
  Offset targetPosition;
  Size targetSize;
  TooltipPosition? position;
  Size screenSize;
  bool hasSecondBox;
  bool hasArrow;
  double toolTipSlideEndDistance;
  double gapBetweenContentAndAction;
  double screenEdgePadding;
  EdgeInsets targetPadding;

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
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Standard hit testing implementation for children
    return defaultHitTestChildren(result, position: position + showcaseOffset);
  }

  // Layout properties - keep only those not managed by RenderObjectManager
  var _needToResize = false;
  var _needToFlip = false;
  var _maxWidth = 0.0;
  var _maxHeight = 0.0;
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
    _needToResize = false;
    _needToFlip = false;
  }

  /// Find and identify children by ID
  void _identifyChildren() {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as MultiChildLayoutParentData;

      if (childParentData.id is! TooltipLayoutSlot) {
        child = childParentData.nextSibling;
        continue;
      }
      RenderObjectManager(
        customRenderBox: child,
        slot: childParentData.id as TooltipLayoutSlot,
      );
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
      const BoxConstraints.tightFor(
        width: null,
        height: null,
      ),
    );

    // Dry layout action box (if exists)
    TooltipLayoutSlot.actionBox.getObjectManager?.performDryLayout(
      const BoxConstraints.tightFor(
        width: null,
        height: null,
      ),
    );
    _minimumActionBoxSize = _actionBoxSize;
  }

  /// Normalize widths between tooltip and action box
  void _normalizeWidths() {
    // Make both boxes the same width (use the wider one)
    var tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
    var actionBoxManager = TooltipLayoutSlot.actionBox.getObjectManager;

    if (actionBoxManager == null || tooltipBoxManager == null) return;

    final actionBoxWidth = actionBoxManager.size.width;
    final tooltipBoxWidth = tooltipBoxManager.size.width;

    if (actionBoxWidth > tooltipBoxWidth) {
      // Action box is wider, recalculate tooltip dry layout with new width
      tooltipBoxManager.performDryLayout(
        BoxConstraints.tightFor(
          width: actionBoxWidth,
          height: null,
        ),
      );
    } else if (tooltipBoxWidth > actionBoxWidth && hasSecondBox) {
      // Tooltip is wider, recalculate action box dry layout with new width
      actionBoxManager.performDryLayout(
        BoxConstraints.tightFor(
          width: tooltipBoxWidth,
          height: null,
        ),
      );
    }
  }

  /// Calculate the total tooltip height including all components
  double _calculateTooltipHeight() {
    var tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
    if (tooltipBoxManager == null) return 0.0;

    var tooltipHeight = tooltipBoxManager.size.height;
    if (hasSecondBox) {
      var actionBoxManager = TooltipLayoutSlot.actionBox.getObjectManager;
      if (actionBoxManager != null) {
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
        _getSuitablePosition(
          _toolTipBoxSize,
          tooltipHeight,
        ).get();
  }

  /// Calculate initial tooltip position
  void _calculateInitialPosition() {
    var tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
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
    var tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
    if (tooltipBoxManager == null) return;

    var offset = tooltipBoxManager.getOffset;

    // Check which boundary is exceeded
    if (offset.dx < screenEdgePadding + showcaseOffset.dx) {
      _handleLeftEdgeBoundary(tooltipHeight);
    } else if (offset.dx + tooltipBoxManager.size.width - showcaseOffset.dx >
        screenSize.width - screenEdgePadding) {
      _handleRightEdgeBoundary(tooltipHeight);
    }
  }

  /// Handle tooltip exceeding left screen edge
  void _handleLeftEdgeBoundary(double tooltipHeight) {
    // Calculate minimum width that would fit
    var minWidth = tooltipPosition.isLeft
        ? targetPosition.dx -
            showcaseOffset.dx -
            screenEdgePadding -
            Constants.tooltipOffset -
            targetPadding.left -
            (hasArrow
                ? Constants.withArrowToolTipPadding
                : Constants.withOutArrowToolTipPadding)
        : 0.0;

    // Get optimal position based on current constraints
    if (tooltipPosition.isLeft) {
      final optimalPosition = _getOptimalPositionForConstraint(
        currentPosition: TooltipPosition.left,
        tooltipHeight: tooltipHeight,
        canResize: minWidth > Constants.minimumToolTipWidth &&
            minWidth > _minimumActionBoxSize.width,
      );

      switch (optimalPosition) {
        case TooltipPosition.left:
          // Resize tooltip to fit
          _maxWidth = minWidth;
          _xOffset = screenEdgePadding + showcaseOffset.dx;
          _needToResize = true;
          //TODO: remove breaks when we remove support for older version of the
          // flutter : https://dart.dev/tools/linter-rules/unnecessary_breaks
          break;
        case TooltipPosition.right:
          // Flip to right side
          _needToFlip = true;
          break;
        case TooltipPosition.bottom:
          // Switch to bottom position
          tooltipPosition = TooltipPosition.bottom;
          _maxWidth = _maxWidth.clamp(0.0, _availableScreenWidth);
          _needToResize = true;
          break;
        case TooltipPosition.top:
          // Switch to top position
          tooltipPosition = TooltipPosition.top;
          _maxWidth = _maxWidth.clamp(0.0, _availableScreenWidth);
          _needToResize = true;
          break;
      }
    } else if (tooltipPosition.isVertical) {
      // For top/bottom positions, ensure width fits and align to left edge
      if (_maxWidth > _availableScreenWidth) {
        _maxWidth = _availableScreenWidth;
        _needToResize = true;
      }
      _xOffset = screenEdgePadding + showcaseOffset.dx;
    }
  }

  /// Handle tooltip exceeding right screen edge
  void _handleRightEdgeBoundary(double tooltipHeight) {
    // Calculate minimum width that would fit
    var minWidth = tooltipPosition.isRight
        ? screenSize.width - screenEdgePadding - _xOffset - targetPadding.right
        : 0;

    if (tooltipPosition.isRight) {
      final optimalPosition = _getOptimalPositionForConstraint(
        currentPosition: TooltipPosition.right,
        tooltipHeight: tooltipHeight,
        canResize: minWidth > Constants.minimumToolTipWidth &&
            minWidth > _minimumActionBoxSize.width,
      );

      switch (optimalPosition) {
        case TooltipPosition.right:
          // Resize tooltip to fit
          _maxWidth = screenSize.width - _xOffset - screenEdgePadding;
          _needToResize = true;
          break;
        case TooltipPosition.left:
          // Flip to left side
          _needToFlip = true;
          break;
        case TooltipPosition.bottom:
          // Switch to bottom position
          tooltipPosition = TooltipPosition.bottom;
          _maxWidth = _availableScreenWidth;
          _needToResize = true;
          break;
        case TooltipPosition.top:
          // Switch to top position
          tooltipPosition = TooltipPosition.top;
          _maxWidth = _availableScreenWidth;
          _needToResize = true;
          break;
      }
    } else {
      // For top/bottom positions, ensure width fits and adjust alignment
      if (_maxWidth > _availableScreenWidth) {
        _maxWidth = _availableScreenWidth;
        _needToResize = true;
        _xOffset = screenEdgePadding + showcaseOffset.dx;
      } else {
        // Align to right edge
        _xOffset = screenSize.width -
            screenEdgePadding -
            _toolTipBoxSize.width +
            showcaseOffset.dx;
      }
    }
  }

  /// Handle vertical screen boundary constraints
  void _handleVerticalBoundaries(double tooltipHeight) {
    // Recalculate max height based on new width constraints
    _recalculateMaxHeight();

    double extraVerticalComponentHeight = _calculateExtraVerticalHeight();

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
    if (canResize) {
      return currentPosition;
    }

    // Second preference: check opposite direction
    TooltipPosition oppositePosition;
    switch (currentPosition) {
      case TooltipPosition.left:
        oppositePosition = TooltipPosition.right;
        break;
      case TooltipPosition.right:
        oppositePosition = TooltipPosition.left;
        break;
      case TooltipPosition.top:
        oppositePosition = TooltipPosition.bottom;
        break;
      case TooltipPosition.bottom:
        oppositePosition = TooltipPosition.top;
        break;
    }

    final suitablePosition =
        _getSuitablePosition(_toolTipBoxSize, tooltipHeight);

    if (suitablePosition.checkFor(oppositePosition)) {
      return oppositePosition;
    }

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
    _maxHeight = (TooltipLayoutSlot.tooltipBox.getObjectManager?.customRenderBox
            .getDryLayout(
              BoxConstraints.tightFor(
                width: _maxWidth,
                height: null,
              ),
            )
            .height ??
        0);
    if (hasSecondBox) {
      _maxHeight += (_actionBoxSize.height + gapBetweenContentAndAction);
    }
  }

  /// Calculate extra vertical component height for arrow and padding
  double _calculateExtraVerticalHeight() {
    var extraHeight = 0.0;
    if (tooltipPosition.isVertical) {
      extraHeight += Constants.tooltipOffset;
      extraHeight += hasArrow
          ? Constants.withArrowToolTipPadding
          : Constants.withOutArrowToolTipPadding;
    }
    return extraHeight;
  }

  /// Handle tooltip exceeding top screen edge
  void _handleTopEdgeBoundary(double tooltipHeight) {
    if (tooltipPosition.isTop) {
      final suitablePosition = _getSuitablePosition(
        _toolTipBoxSize,
        tooltipHeight,
      );

      if (suitablePosition.checkFor(TooltipPosition.bottom)) {
        // Option 1: Flip to bottom side if it fits
        _needToFlip = true;
      } else if (suitablePosition.checkFor(TooltipPosition.left)) {
        // Option 2: Switch to left position if it fits
        tooltipPosition = TooltipPosition.left;
        if (_maxHeight > _availableScreenHeight) {
          _maxHeight = _availableScreenHeight;
        }
        _needToResize = true;
      } else if (suitablePosition.checkFor(TooltipPosition.right)) {
        // Option 3: Switch to right position if it fits
        tooltipPosition = TooltipPosition.right;
        if (_maxHeight > _availableScreenHeight) {
          _maxHeight = _availableScreenHeight;
        }
        _needToResize = true;
      } else {
        // Option 4: Last resort - resize and keep at top
        _maxHeight -= screenEdgePadding - _xOffset;
        _yOffset = screenEdgePadding + showcaseOffset.dy;
        _needToResize = true;
      }
    } else if (tooltipPosition.isHorizontal) {
      // For left/right positions, ensure height fits and align to top edge
      if (_maxHeight > _availableScreenHeight) {
        _maxHeight = _availableScreenHeight;
        _needToResize = true;
      }
      _yOffset = screenEdgePadding + showcaseOffset.dy;
    }
  }

  /// Handle tooltip exceeding bottom screen edge
  void _handleBottomEdgeBoundary(double tooltipHeight) {
    if (tooltipPosition.isBottom) {
      final suitablePosition = _getSuitablePosition(
        _toolTipBoxSize,
        tooltipHeight,
      );
      if (suitablePosition.checkFor(TooltipPosition.top)) {
        // Option 1: Flip to top side if it fits
        _needToFlip = true;
      } else if (suitablePosition.checkFor(TooltipPosition.left)) {
        // Option 2: Switch to left position if it fits
        tooltipPosition = TooltipPosition.left;
        if (_maxHeight > _availableScreenHeight) {
          _maxHeight = _availableScreenHeight;
        }
        _needToResize = true;
      } else if (suitablePosition.checkFor(TooltipPosition.right)) {
        // Option 3: Switch to right position if it fits
        tooltipPosition = TooltipPosition.right;
        if (_maxHeight > _availableScreenHeight) {
          _maxHeight = _availableScreenHeight;
        }
        _needToResize = true;
      } else {
        // Option 4: Last resort - resize and keep at bottom
        _maxHeight += _calculateExtraVerticalHeight();
        _needToResize = true;
        _yOffset = screenSize.height -
            showcaseOffset.dy -
            screenEdgePadding -
            _maxHeight;
      }
    } else {
      // For left/right positions, ensure height fits and adjust alignment
      if (_maxHeight > _availableScreenHeight) {
        _maxHeight = _availableScreenHeight;
        _needToResize = true;
        _yOffset = screenEdgePadding + showcaseOffset.dy;
      } else {
        // Align to bottom edge
        _yOffset = screenSize.height -
            screenEdgePadding -
            tooltipHeight +
            showcaseOffset.dy;
      }
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
      tooltipBoxHeight -= (_actionBoxSize.height + gapBetweenContentAndAction);
    }

    // Resize tooltip box
    TooltipLayoutSlot.tooltipBox.getObjectManager?.performLayout(
      BoxConstraints.tightFor(
        width: _maxWidth,
        height: tooltipBoxHeight,
      ),
      parentUsesSize: true,
    );

    // Resize action box if exists
    TooltipLayoutSlot.actionBox.getObjectManager?.performLayout(
      BoxConstraints.tightFor(
        width: _maxWidth,
        height: null,
      ),
      parentUsesSize: true,
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
            Constants.tooltipOffset;
        _yOffset -= hasArrow
            ? Constants.withArrowToolTipPadding
            : Constants.withOutArrowToolTipPadding;
        break;

      case TooltipPosition.top:
        // Flip from top to bottom
        tooltipPosition = TooltipPosition.bottom;
        _yOffset =
            targetPosition.dy + targetSize.height + Constants.tooltipOffset;
        _yOffset += hasArrow
            ? Constants.withArrowToolTipPadding
            : Constants.withOutArrowToolTipPadding;
        break;

      case TooltipPosition.left:
        // Flip from left to right
        tooltipPosition = TooltipPosition.right;
        _xOffset =
            targetPosition.dx + targetSize.width + Constants.tooltipOffset;
        _xOffset += hasArrow
            ? Constants.withArrowToolTipPadding
            : Constants.withOutArrowToolTipPadding;
        break;

      case TooltipPosition.right:
        // Flip from right to left
        tooltipPosition = TooltipPosition.left;
        _xOffset =
            targetPosition.dx - _toolTipBoxSize.width - Constants.tooltipOffset;
        _xOffset -= hasArrow
            ? Constants.withArrowToolTipPadding
            : Constants.withOutArrowToolTipPadding;
        break;
    }
  }

  /// Apply final boundary constraints to ensure tooltip stays on screen
  void _applyBoundaryConstraints(double tooltipHeight) {
    // Ensure tooltip stays within horizontal screen bounds
    _xOffset = _xOffset.clamp(
      screenEdgePadding + showcaseOffset.dx,
      screenSize.width -
          _toolTipBoxSize.width -
          screenEdgePadding +
          showcaseOffset.dx,
    );

    // Ensure tooltip stays within vertical screen bounds
    _yOffset = _yOffset.clamp(
      screenEdgePadding + showcaseOffset.dy,
      screenSize.height - tooltipHeight - screenEdgePadding + showcaseOffset.dy,
    );

    // Apply target padding based on position
    _applyTargetPadding();
  }

  /// Apply target padding based on tooltip position
  void _applyTargetPadding() {
    switch (tooltipPosition) {
      case TooltipPosition.top:
        _yOffset -= targetPadding.top;
        break;
      case TooltipPosition.bottom:
        _yOffset += targetPadding.bottom;
        break;
      case TooltipPosition.left:
        _xOffset -= targetPadding.left;
        break;
      case TooltipPosition.right:
        _xOffset += targetPadding.right;
        break;
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

    // Position the action box
    final secondBoxParentData =
        TooltipLayoutSlot.actionBox.getObjectManager?.layoutParentData;

    // Position differently based on tooltip direction
    if (tooltipPosition.isTop) {
      // For top tooltips, action box goes above content
      secondBoxParentData?.offset = Offset(
        _xOffset,
        _yOffset - _actionBoxSize.height - gapBetweenContentAndAction,
      );
    } else {
      // For other positions, action box goes below content
      secondBoxParentData?.offset = Offset(
        _xOffset,
        _yOffset + _toolTipBoxSize.height + gapBetweenContentAndAction,
      );
    }
  }

  /// Position the arrow element
  void _positionArrow() {
    if (!hasArrow || TooltipLayoutSlot.arrow.getObjectManager == null) {
      return;
    }

    const halfArrowWidth = Constants.arrowWidth * 0.5;
    const halfArrowHeight = Constants.arrowWidth * 0.5;
    final halfTargetHeight = targetSize.height * 0.5;
    final halfTargetWidth = targetSize.width * 0.5;

    final arrowBoxParentData =
        TooltipLayoutSlot.arrow.getObjectManager!.layoutParentData;

    // Position arrow differently based on tooltip direction
    switch (tooltipPosition) {
      case TooltipPosition.top:
        // Arrow points down from bottom of tooltip
        arrowBoxParentData.offset = Offset(
          targetPosition.dx + halfTargetWidth - halfArrowWidth,
          _yOffset + _toolTipBoxSize.height - 2,
        );
        break;

      case TooltipPosition.bottom:
        // Arrow points up from top of tooltip
        arrowBoxParentData.offset = Offset(
          targetPosition.dx + halfTargetWidth - halfArrowWidth,
          _yOffset - Constants.arrowHeight + 1,
        );
        break;

      case TooltipPosition.left:
        // Arrow points right from right side of tooltip
        arrowBoxParentData.offset = Offset(
          _xOffset + _toolTipBoxSize.width - halfArrowHeight + 4,
          targetPosition.dy + halfTargetHeight - halfArrowWidth + 4,
        );
        break;

      case TooltipPosition.right:
        // Arrow points left from left side of tooltip
        arrowBoxParentData.offset = Offset(
          _xOffset - Constants.arrowHeight - 4,
          targetPosition.dy + halfTargetHeight - halfArrowHeight + 4,
        );
        break;
    }
  }

  /// Helper function to calculate position based on selected direction
  Offset positionToolTip({
    required Size targetSize,
    required Size toolTipBoxSize,
    required TooltipPosition tooltipPosition,
  }) {
    var xOffset = 0.0;
    var yOffset = 0.0;

    final centerDxForTooltip = (targetSize.width - toolTipBoxSize.width) * 0.5;
    final centerDyForTooltip =
        (targetSize.height - toolTipBoxSize.height) * 0.5;

    switch (tooltipPosition) {
      case TooltipPosition.bottom:
        // Center horizontally below target
        xOffset = targetPosition.dx + centerDxForTooltip;
        // Position below target with appropriate offset
        yOffset =
            targetPosition.dy + targetSize.height + Constants.tooltipOffset;
        // Add additional padding if arrow is shown

        yOffset += hasArrow
            ? Constants.withArrowToolTipPadding
            : Constants.withOutArrowToolTipPadding;

        break;

      case TooltipPosition.top:
        // Center horizontally above target
        xOffset = targetPosition.dx + centerDxForTooltip;
        // Position above target with appropriate offset
        yOffset =
            targetPosition.dy - toolTipBoxSize.height - Constants.tooltipOffset;
        // Add additional padding if arrow is shown
        yOffset -= hasArrow
            ? Constants.withArrowToolTipPadding
            : Constants.withOutArrowToolTipPadding;

        break;

      case TooltipPosition.left:
        // Position to the left of target with appropriate offset
        xOffset =
            targetPosition.dx - toolTipBoxSize.width - Constants.tooltipOffset;
        // Add additional padding if arrow is shown
        xOffset -= hasArrow
            ? Constants.withArrowToolTipPadding
            : Constants.withOutArrowToolTipPadding;

        // Center vertically beside target
        yOffset = targetPosition.dy + centerDyForTooltip;
        break;

      case TooltipPosition.right:
        // Position to the right of target with appropriate offset
        xOffset =
            targetPosition.dx + targetSize.width + Constants.tooltipOffset;
        // Add additional padding if arrow is shown
        xOffset += hasArrow
            ? Constants.withArrowToolTipPadding
            : Constants.withOutArrowToolTipPadding;

        // Center vertically beside target
        yOffset = targetPosition.dy + centerDyForTooltip;
        break;
    }
    return Offset(xOffset, yOffset);
  }

  /// Determines in which positions the tooltip can be displayed without exceeding screen boundaries.
  ///
  /// This method evaluates the available space in all four directions (top, bottom, left, right)
  /// around the target element and determines whether the tooltip can fit in each direction
  /// while respecting screen edge padding.
  ///
  /// Parameters:
  /// - [tooltipSize]: The current width and height of the tooltip content
  /// - [totalHeight]: The total height including tooltip content and action box (if present)
  ///
  /// Returns:
  /// A [_SuitablePosition] object containing boolean flags for each valid position
  _SuitablePosition _getSuitablePosition(
    Size tooltipSize,
    double totalHeight,
  ) {
    final arrowPadding = hasArrow
        ? Constants.withArrowToolTipPadding
        : Constants.withOutArrowToolTipPadding;

    final isBottom = targetPosition.dy +
            targetSize.height +
            totalHeight +
            Constants.tooltipOffset +
            arrowPadding -
            showcaseOffset.dy <=
        screenSize.height - screenEdgePadding;

    final isTop = targetPosition.dy -
            totalHeight -
            Constants.tooltipOffset -
            arrowPadding -
            showcaseOffset.dy >=
        screenEdgePadding;

    final isLeft = targetPosition.dx -
            tooltipSize.width -
            Constants.tooltipOffset -
            arrowPadding -
            showcaseOffset.dx >=
        screenEdgePadding;

    final isRight = targetPosition.dx +
            targetSize.width +
            tooltipSize.width +
            Constants.tooltipOffset +
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
    switch (position) {
      case TooltipPosition.bottom:
        return isBottom;
      case TooltipPosition.top:
        return isTop;
      case TooltipPosition.left:
        return isLeft;
      case TooltipPosition.right:
        return isRight;
    }
  }

  TooltipPosition get() {
    if (isBottom) return TooltipPosition.bottom;
    if (isTop) return TooltipPosition.top;
    if (isLeft) return TooltipPosition.left;
    if (isRight) return TooltipPosition.right;
    return TooltipPosition.bottom; // Default fallback
  }
}
