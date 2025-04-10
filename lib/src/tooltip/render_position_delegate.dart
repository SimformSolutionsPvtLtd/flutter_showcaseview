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
  bool _needToResize = false;
  bool _needToFlip = false;
  double _maxWidth = 0.0;
  double _maxHeight = 0.0;
  double _availableScreenWidth = 0.0;
  double _availableScreenHeight = 0.0;

  Size get _toolTipBoxSize =>
      TooltipLayoutSlot.tooltipBox.getObjectManager?.size ?? Size.zero;

  Size get _actionBoxSize =>
      TooltipLayoutSlot.actionBox.getObjectManager?.size ?? Size.zero;

  Size _minimumActionBoxSize = Size.zero;

  double get _xOffset =>
      TooltipLayoutSlot.tooltipBox.getObjectManager?.xOffset ?? 0.0;

  set _xOffset(double value) {
    if (TooltipLayoutSlot.tooltipBox.getObjectManager != null) {
      TooltipLayoutSlot.tooltipBox.getObjectManager!.xOffset = value;
    }
  }

  double get _yOffset =>
      TooltipLayoutSlot.tooltipBox.getObjectManager?.yOffset ?? 0.0;

  set _yOffset(double value) {
    if (TooltipLayoutSlot.tooltipBox.getObjectManager != null) {
      TooltipLayoutSlot.tooltipBox.getObjectManager!.yOffset = value;
    }
  }

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
    final double tooltipHeight = _calculateTooltipHeight();
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
    RenderObjectManager.renderObjects.clear();
  }

  /// Initialize layout variables and set size
  void _initializeLayout() {
    // Set size for this render object
    size = constraints.biggest;

    final totalScreenEdgePadding = (2 * screenEdgePadding);

    // Get available screen dimensions
    _availableScreenWidth = screenSize.width - totalScreenEdgePadding;
    _availableScreenHeight = screenSize.height - totalScreenEdgePadding;

    // Reset layout variables
    _needToResize = false;
    _needToFlip = false;
  }

  /// Find and identify children by ID
  void _identifyChildren() {
    RenderBox? child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData =
          child.parentData! as MultiChildLayoutParentData;

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
    if (TooltipLayoutSlot.arrow.getObjectManager != null) {
      TooltipLayoutSlot.arrow.getObjectManager!.performDryLayout(
        const BoxConstraints.tightFor(
          width: Constants.arrowWidth,
          height: Constants.arrowHeight,
        ),
      );
    }

    // Dry layout main tooltip content
    if (TooltipLayoutSlot.tooltipBox.getObjectManager != null) {
      TooltipLayoutSlot.tooltipBox.getObjectManager!.performDryLayout(
        const BoxConstraints.tightFor(
          width: null,
          height: null,
        ),
      );
    }

    // Dry layout action box (if exists)
    if (TooltipLayoutSlot.actionBox.getObjectManager != null) {
      TooltipLayoutSlot.actionBox.getObjectManager!.performDryLayout(
        const BoxConstraints.tightFor(
          width: null,
          height: null,
        ),
      );
      _minimumActionBoxSize = _actionBoxSize;
    }
  }

  /// Normalize widths between tooltip and action box
  void _normalizeWidths() {
    // Make both boxes the same width (use the wider one)
    var tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
    var actionBoxManager = TooltipLayoutSlot.actionBox.getObjectManager;

    if (actionBoxManager == null || tooltipBoxManager == null) return;
    if (actionBoxManager.size.width > tooltipBoxManager.size.width) {
      // Action box is wider, recalculate tooltip dry layout with new width
      tooltipBoxManager.performDryLayout(
        BoxConstraints.tightFor(
          width: actionBoxManager.size.width,
          height: null,
        ),
      );
    } else if (tooltipBoxManager.size.width > actionBoxManager.size.width &&
        hasSecondBox) {
      // Tooltip is wider, recalculate action box dry layout with new width
      actionBoxManager.performDryLayout(
        BoxConstraints.tightFor(
          width: tooltipBoxManager.size.width,
          height: null,
        ),
      );
    }
  }

  /// Calculate the total tooltip height including all components
  double _calculateTooltipHeight() {
    var tooltipBoxManager = TooltipLayoutSlot.tooltipBox.getObjectManager;
    if (tooltipBoxManager == null) return 0.0;

    double tooltipHeight = tooltipBoxManager.size.height;
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
    if (position != null) {
      // Use provided position
      tooltipPosition = position!;
      return;
    }
    // Try positions in priority order: bottom, top, left, right
    tooltipPosition = _getRecommendedToolTipPosition(
      _toolTipBoxSize,
      tooltipHeight,
    );
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

    // Left edge boundary
    if (offset.dx < screenEdgePadding + showcaseOffset.dx) {
      _handleLeftEdgeBoundary(tooltipHeight);
    }
    // Right edge boundary
    else if (offset.dx + tooltipBoxManager.size.width - showcaseOffset.dx >
        screenSize.width - screenEdgePadding) {
      _handleRightEdgeBoundary(tooltipHeight);
    }
  }

  /// Handle tooltip exceeding left screen edge
  void _handleLeftEdgeBoundary(double tooltipHeight) {
    if (tooltipPosition.isLeft) {
      // Calculate minimum width that would fit
      var minWidth = targetPosition.dx -
          showcaseOffset.dx -
          screenEdgePadding -
          Constants.tooltipOffset -
          targetPadding.left;
      minWidth -= hasArrow
          ? Constants.withArrowToolTipPadding
          : Constants.withOutArrowToolTipPadding;

      if (minWidth > Constants.minimumToolTipWidth &&
          minWidth > _minimumActionBoxSize.width) {
        // Option 1: Resize tooltip to fit
        _maxWidth = minWidth;
        _xOffset = screenEdgePadding + showcaseOffset.dx;
        _needToResize = true;
      } else if (_fitsInPosition(
        TooltipPosition.right,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 2: Flip to right side if it fits
        _needToFlip = true;
      } else if (_fitsInPosition(
        TooltipPosition.bottom,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 3: Switch to bottom position if it fits
        tooltipPosition = TooltipPosition.bottom;
        if (_maxWidth > _availableScreenWidth) {
          _maxWidth = _availableScreenWidth;
        }
        _needToResize = true;
      } else if (_fitsInPosition(
        TooltipPosition.top,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 4: Switch to top position if it fits
        tooltipPosition = TooltipPosition.top;
        if (_maxWidth > _availableScreenWidth) {
          _maxWidth = _availableScreenWidth;
        }
        _needToResize = true;
      } else {
        // Option 5: Last resort - resize and keep at left
        _maxWidth -= screenEdgePadding - _xOffset;
        _xOffset = screenEdgePadding + showcaseOffset.dx;
        _needToResize = true;
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
    if (tooltipPosition.isRight) {
      // Calculate minimum width that would fit
      var minWidth =
          screenSize.width - screenEdgePadding - _xOffset - targetPadding.right;

      if (minWidth > Constants.minimumToolTipWidth &&
          minWidth > _minimumActionBoxSize.width) {
        // Option 1: Resize tooltip to fit
        _maxWidth = screenSize.width - _xOffset - screenEdgePadding;
        _needToResize = true;
      } else if (_fitsInPosition(
        TooltipPosition.left,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 2: Flip to left side if it fits
        _needToFlip = true;
      } else if (_fitsInPosition(
        TooltipPosition.bottom,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 3: Switch to bottom position if it fits
        tooltipPosition = TooltipPosition.bottom;
        _maxWidth = _availableScreenWidth;
        _needToResize = true;
      } else if (_fitsInPosition(
        TooltipPosition.top,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 4: Switch to top position if it fits
        tooltipPosition = TooltipPosition.top;
        _maxWidth = _availableScreenWidth;
        _needToResize = true;
      } else {
        // Option 5: Last resort - resize and keep at right
        _maxWidth = screenSize.width - _xOffset - screenEdgePadding;
        _needToResize = true;
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

    // Top edge boundary
    if (_yOffset < screenEdgePadding + showcaseOffset.dy) {
      _handleTopEdgeBoundary(tooltipHeight);
    }
    // Bottom edge boundary
    else if (_yOffset +
            _maxHeight +
            extraVerticalComponentHeight -
            showcaseOffset.dy >
        screenSize.height - screenEdgePadding) {
      _handleBottomEdgeBoundary(tooltipHeight);
    }
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
      if (_fitsInPosition(
        TooltipPosition.bottom,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 1: Flip to bottom side if it fits
        _needToFlip = true;
      } else if (_fitsInPosition(
        TooltipPosition.left,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 2: Switch to left position if it fits
        tooltipPosition = TooltipPosition.left;
        if (_maxHeight > _availableScreenHeight) {
          _maxHeight = _availableScreenHeight;
        }
        _needToResize = true;
      } else if (_fitsInPosition(
        TooltipPosition.right,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
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
      if (_fitsInPosition(
        TooltipPosition.top,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 1: Flip to top side if it fits
        _needToFlip = true;
      } else if (_fitsInPosition(
        TooltipPosition.left,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
        // Option 2: Switch to left position if it fits
        tooltipPosition = TooltipPosition.left;
        if (_maxHeight > _availableScreenHeight) {
          _maxHeight = _availableScreenHeight;
        }
        _needToResize = true;
      } else if (_fitsInPosition(
        TooltipPosition.right,
        _toolTipBoxSize,
        tooltipHeight,
      )) {
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
    TooltipLayoutSlot.tooltipBox.getObjectManager!.performLayout(
      BoxConstraints.tightFor(
        width: _maxWidth,
        height: tooltipBoxHeight,
      ),
      parentUsesSize: true,
    );

    // Resize action box if exists
    if (hasSecondBox && TooltipLayoutSlot.actionBox.getObjectManager != null) {
      TooltipLayoutSlot.actionBox.getObjectManager!.performLayout(
        BoxConstraints.tightFor(
          width: _maxWidth,
          height: null,
        ),
        parentUsesSize: true,
      );
    }

    // Recalculate position if not flipping
    if (!_needToFlip) {
      final initialPosition = positionToolTip(
        targetSize: targetSize,
        toolTipBoxSize: _toolTipBoxSize,
        tooltipPosition: tooltipPosition,
      );
      _xOffset = initialPosition.dx;
      _yOffset = initialPosition.dy;
    }
  }

  /// Handle flipping to opposite side if needed
  void _handleFlipping() {
    if (!_needToFlip) {
      return;
    }

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
        _yOffset -= (targetPadding.top);
        break;
      case TooltipPosition.bottom:
        _yOffset += (targetPadding.bottom);
        break;
      case TooltipPosition.left:
        _xOffset -= (targetPadding.left);
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
    if (TooltipLayoutSlot.arrow.getObjectManager != null) {
      TooltipLayoutSlot.arrow.getObjectManager!.performLayout(
        const BoxConstraints.tightFor(
          width: Constants.arrowWidth,
          height: Constants.arrowHeight,
        ),
      );
    }
  }

  /// Layout the tooltip content box
  void _layoutTooltipBox() {
    if (TooltipLayoutSlot.tooltipBox.getObjectManager != null) {
      TooltipLayoutSlot.tooltipBox.getObjectManager!.performLayout(
        BoxConstraints.tightFor(
          width: _toolTipBoxSize.width,
          height: _toolTipBoxSize.height,
        ),
      );

      // Position the tooltip content box
      final firstBoxParentData = TooltipLayoutSlot.tooltipBox.getObjectManager!
          .customRenderBox.parentData! as MultiChildLayoutParentData;
      firstBoxParentData.offset = Offset(_xOffset, _yOffset);
    }
  }

  /// Layout the action box
  void _layoutActionBox() {
    if (hasSecondBox && TooltipLayoutSlot.actionBox.getObjectManager != null) {
      TooltipLayoutSlot.actionBox.getObjectManager!.performLayout(
        BoxConstraints.tightFor(
          width: _actionBoxSize.width,
          height: _actionBoxSize.height,
        ),
      );

      // Position the action box
      final secondBoxParentData = TooltipLayoutSlot.actionBox.getObjectManager!
          .customRenderBox.parentData! as MultiChildLayoutParentData;

      // Position differently based on tooltip direction
      if (tooltipPosition.isTop) {
        // For top tooltips, action box goes above content
        secondBoxParentData.offset = Offset(
          _xOffset,
          _yOffset - _actionBoxSize.height - gapBetweenContentAndAction,
        );
      } else {
        // For other positions, action box goes below content
        secondBoxParentData.offset = Offset(
          _xOffset,
          _yOffset + _toolTipBoxSize.height + gapBetweenContentAndAction,
        );
      }
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

    final arrowBoxParentData = TooltipLayoutSlot.arrow.getObjectManager!
        .customRenderBox.parentData! as MultiChildLayoutParentData;

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

  TooltipPosition _getRecommendedToolTipPosition(
    Size toolTipBoxSize,
    double tooltipHeight,
  ) {
    if (_fitsInPosition(
      TooltipPosition.bottom,
      toolTipBoxSize,
      tooltipHeight,
    )) {
      return TooltipPosition.bottom;
    } else if (_fitsInPosition(
      TooltipPosition.top,
      toolTipBoxSize,
      tooltipHeight,
    )) {
      return TooltipPosition.top;
    } else if (_fitsInPosition(
      TooltipPosition.left,
      toolTipBoxSize,
      tooltipHeight,
    )) {
      return TooltipPosition.left;
    } else if (_fitsInPosition(
      TooltipPosition.right,
      toolTipBoxSize,
      tooltipHeight,
    )) {
      return TooltipPosition.right;
    } else {
      // Default to bottom if nothing fits (will be adjusted later)
      return TooltipPosition.bottom;
    }
  }

  /// Helper method to check if tooltip fits in a specific position
  ///
  /// Returns true if the tooltip fits in the given position without
  /// extending beyond screen boundaries
  bool _fitsInPosition(
    TooltipPosition pos,
    Size tooltipSize,
    double totalHeight,
  ) {
    final arrowPadding = hasArrow
        ? Constants.withArrowToolTipPadding
        : Constants.withOutArrowToolTipPadding;

    switch (pos) {
      case TooltipPosition.bottom:
        // Check if tooltip fits below target
        return targetPosition.dy +
                targetSize.height +
                totalHeight +
                Constants.tooltipOffset +
                arrowPadding -
                showcaseOffset.dy <=
            screenSize.height - screenEdgePadding;

      case TooltipPosition.top:
        // Check if tooltip fits above target
        return targetPosition.dy -
                totalHeight -
                Constants.tooltipOffset -
                arrowPadding -
                showcaseOffset.dy >=
            screenEdgePadding;

      case TooltipPosition.left:
        // Check if tooltip fits to the left of target
        return targetPosition.dx -
                tooltipSize.width -
                Constants.tooltipOffset -
                arrowPadding -
                showcaseOffset.dx >=
            screenEdgePadding;

      case TooltipPosition.right:
        // Check if tooltip fits to the right of target
        return targetPosition.dx +
                targetSize.width +
                tooltipSize.width +
                Constants.tooltipOffset +
                arrowPadding -
                showcaseOffset.dx <=
            screenSize.width - screenEdgePadding;
    }
  }
}
