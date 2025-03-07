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

  @override
  void performLayout() {
    // Always set a size for this render object first to prevent layout errors
    size = constraints.biggest;

    // Initialize variables for child sizes
    Size toolTipBoxSize = Size.zero;
    Size actionBoxSize = Size.zero;
    var minimumActionBoxSize = Size.zero;

    final availableScreenWidth = screenSize.width - (2 * screenEdgePadding);
    final availableScreenHeight = screenSize.height - (2 * screenEdgePadding);

    // Find children by ID
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

    // STEP 1: First perform dry layout to determine natural sizes for all children

    // Dry layout arrow early
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
      toolTipBoxSize =
          TooltipLayoutSlot.tooltipBox.getObjectManager!.performDryLayout(
        const BoxConstraints.tightFor(
          width: null,
          height: null,
        ),
      );
    }

    // Dry layout action box (if exists)
    if (TooltipLayoutSlot.actionBox.getObjectManager != null) {
      actionBoxSize =
          TooltipLayoutSlot.actionBox.getObjectManager!.performDryLayout(
        const BoxConstraints.tightFor(
          width: null,
          height: null,
        ),
      );
      minimumActionBoxSize = actionBoxSize;
    }

    // STEP 2: Normalize widths between tooltip and action box for consistency

    // Make both boxes the same width (use the wider one)
    if (actionBoxSize.width > toolTipBoxSize.width &&
        TooltipLayoutSlot.tooltipBox.getObjectManager != null) {
      // Action box is wider, recalculate tooltip dry layout with new width
      toolTipBoxSize =
          TooltipLayoutSlot.tooltipBox.getObjectManager!.performDryLayout(
        BoxConstraints.tightFor(
          width: actionBoxSize.width,
          height: null,
        ),
      );
    } else if (toolTipBoxSize.width > actionBoxSize.width &&
        hasSecondBox &&
        TooltipLayoutSlot.actionBox.getObjectManager != null) {
      // Tooltip is wider, recalculate action box dry layout with new width
      actionBoxSize =
          TooltipLayoutSlot.actionBox.getObjectManager!.performDryLayout(
        BoxConstraints.tightFor(
          width: toolTipBoxSize.width,
          height: null,
        ),
      );
    }

    // Calculate combined tooltip height including gap if needed
    double tooltipHeight = toolTipBoxSize.height;
    if (hasSecondBox) {
      tooltipHeight += actionBoxSize.height + gapBetweenContentAndAction;
    }

    // STEP 3: Determine optimal tooltip position

    // If no position provided, find best automatic position
    if (position == null) {
      // Try positions in priority order: bottom, top, left, right
      tooltipPosition = _getRecommendedToolTipPosition(
        toolTipBoxSize,
        tooltipHeight,
      );
    } else {
      // Use provided position
      tooltipPosition = position!;
    }

    // Initialize tooltip positioning variables
    double xOffset = 0;
    double yOffset = 0;

    // STEP 4: Position tooltip according to selected position

    // Calculate initial position
    final initialPosition = positionToolTip(
      targetSize: targetSize,
      toolTipBoxSize: toolTipBoxSize,
      tooltipPosition: tooltipPosition,
    );
    xOffset = initialPosition.dx;
    yOffset = initialPosition.dy;

    // STEP 5: Handle screen boundary constraints and adjustments

    // Flags to track if we need to make adjustments
    bool needToResize = false; // Whether to resize the tooltip
    bool needToFlip = false; // Whether to flip to opposite side

    // Maximum dimensions to use when resizing
    double maxWidth = toolTipBoxSize.width;
    double maxHeight = tooltipHeight;

    // Horizontal boundary handling
    if (xOffset < screenEdgePadding + showcaseOffset.dx) {
      // Tooltip extends beyond left edge
      if (tooltipPosition.isLeft) {
        // When positioned left, we have a few options:
        var minWidth = targetPosition.dx -
            showcaseOffset.dx -
            screenEdgePadding -
            Constants.tooltipOffset -
            targetPadding.left;
        if (hasArrow) {
          minWidth -= Constants.withArrowToolTipPadding;
        } else {
          minWidth -= Constants.withOutArrowToolTipPadding;
        }
        if (minWidth > Constants.minimumToolTipWidth &&
            minWidth > minimumActionBoxSize.width) {
          // Option 1: Resize tooltip to fit
          maxWidth = minWidth;
          xOffset = screenEdgePadding + showcaseOffset.dx;
          needToResize = true;
        } else if (_fitsInPosition(
          TooltipPosition.right,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 2: Flip to right side if it fits
          needToFlip = true;
        } else if (_fitsInPosition(
          TooltipPosition.bottom,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 3: Switch to bottom position if it fits
          tooltipPosition = TooltipPosition.bottom;
          if (maxWidth > availableScreenWidth) {
            maxWidth = availableScreenWidth;
          }
          needToResize = true;
        } else if (_fitsInPosition(
          TooltipPosition.top,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 4: Switch to top position if it fits
          tooltipPosition = TooltipPosition.top;
          if (maxWidth > availableScreenWidth) {
            maxWidth = availableScreenWidth;
          }
          needToResize = true;
        } else {
          // Option 5: Last resort - resize and keep at left
          maxWidth -= screenEdgePadding - xOffset;
          xOffset = screenEdgePadding + showcaseOffset.dx;
          needToResize = true;
        }
      } else if (tooltipPosition.isVertical) {
        // For top/bottom positions, ensure width fits and align to left edge
        if (maxWidth > availableScreenWidth) {
          maxWidth = availableScreenWidth;
          needToResize = true;
        }
        xOffset = screenEdgePadding + showcaseOffset.dx;
      }
    } else if (xOffset + toolTipBoxSize.width - showcaseOffset.dx >
        screenSize.width - screenEdgePadding) {
      // Tooltip extends beyond right edge
      if (tooltipPosition.isRight) {
        // When positioned right, similar options as with left position
        var minWidth = screenSize.width -
            screenEdgePadding -
            xOffset -
            targetPadding.right;

        if (minWidth > Constants.minimumToolTipWidth &&
            minWidth > minimumActionBoxSize.width) {
          // Option 1: Resize tooltip to fit
          maxWidth = screenSize.width - xOffset - screenEdgePadding;
          needToResize = true;
        } else if (_fitsInPosition(
          TooltipPosition.left,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 2: Flip to left side if it fits
          needToFlip = true;
        } else if (_fitsInPosition(
          TooltipPosition.bottom,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 3: Switch to bottom position if it fits
          tooltipPosition = TooltipPosition.bottom;
          maxWidth = availableScreenWidth;
          needToResize = true;
        } else if (_fitsInPosition(
          TooltipPosition.top,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 4: Switch to top position if it fits
          tooltipPosition = TooltipPosition.top;
          maxWidth = availableScreenWidth;
          needToResize = true;
        } else {
          // Option 5: Last resort - resize and keep at right
          maxWidth = screenSize.width - xOffset - screenEdgePadding;
          needToResize = true;
        }
      } else {
        // For top/bottom positions, ensure width fits and adjust alignment
        if (maxWidth > availableScreenWidth) {
          maxWidth = availableScreenWidth;
          needToResize = true;
          xOffset = screenEdgePadding + showcaseOffset.dx;
        } else {
          // Align to right edge
          xOffset = screenSize.width -
              screenEdgePadding -
              toolTipBoxSize.width +
              showcaseOffset.dx;
        }
      }
    }

    // Recalculate max height based on new width constraints if resizing
    maxHeight = (TooltipLayoutSlot.tooltipBox.getObjectManager?.customRenderBox
            .getDryLayout(
              BoxConstraints.tightFor(
                width: maxWidth,
                height: null,
              ),
            )
            .height ??
        0);
    if (hasSecondBox) {
      maxHeight += (actionBoxSize.height + gapBetweenContentAndAction);
    }
    var extraVerticalComponentHeight = 0.0;
    if (tooltipPosition.isVertical) {
      extraVerticalComponentHeight += Constants.tooltipOffset;
      if (hasArrow) {
        extraVerticalComponentHeight += Constants.withArrowToolTipPadding;
      } else {
        extraVerticalComponentHeight += Constants.withOutArrowToolTipPadding;
      }
    }

    // Vertical boundary handling
    if (yOffset < screenEdgePadding + showcaseOffset.dy) {
      // Tooltip extends beyond top edge
      if (tooltipPosition.isTop) {
        // When positioned at top, check options
        if (_fitsInPosition(
          TooltipPosition.bottom,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 1: Flip to bottom side if it fits
          needToFlip = true;
        } else if (_fitsInPosition(
          TooltipPosition.left,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 2: Switch to left position if it fits
          tooltipPosition = TooltipPosition.left;
          if (maxHeight > availableScreenHeight) {
            maxHeight = availableScreenHeight;
          }
          needToResize = true;
        } else if (_fitsInPosition(
          TooltipPosition.right,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 3: Switch to right position if it fits
          tooltipPosition = TooltipPosition.right;
          if (maxHeight > availableScreenHeight) {
            maxHeight = availableScreenHeight;
          }
          needToResize = true;
        } else {
          // Option 4: Last resort - resize and keep at top
          maxHeight -= screenEdgePadding - xOffset;
          yOffset = screenEdgePadding + showcaseOffset.dy;
          needToResize = true;
        }
      } else if (tooltipPosition.isHorizontal) {
        // For left/right positions, ensure height fits and align to top edge
        if (maxHeight > availableScreenHeight) {
          maxHeight = availableScreenHeight;
          needToResize = true;
        }
        yOffset = screenEdgePadding + showcaseOffset.dy;
      }
    } else if (yOffset +
            maxHeight +
            extraVerticalComponentHeight -
            showcaseOffset.dy >
        screenSize.height - screenEdgePadding) {
      // Tooltip extends beyond bottom edge
      if (tooltipPosition.isBottom) {
        // When positioned at bottom, check options
        if (_fitsInPosition(
          TooltipPosition.top,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 1: Flip to top side if it fits
          needToFlip = true;
        } else if (_fitsInPosition(
          TooltipPosition.left,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 2: Switch to left position if it fits
          tooltipPosition = TooltipPosition.left;
          if (maxHeight > availableScreenHeight) {
            maxHeight = availableScreenHeight;
          }
          needToResize = true;
        } else if (_fitsInPosition(
          TooltipPosition.right,
          toolTipBoxSize,
          tooltipHeight,
        )) {
          // Option 3: Switch to right position if it fits
          tooltipPosition = TooltipPosition.right;
          if (maxHeight > availableScreenHeight) {
            maxHeight = availableScreenHeight;
          }
          needToResize = true;
        } else {
          // Option 4: Last resort - resize and keep at bottom
          maxHeight += extraVerticalComponentHeight;
          needToResize = true;
          yOffset = screenSize.height -
              showcaseOffset.dy -
              screenEdgePadding -
              maxHeight;
        }
      } else {
        // For left/right positions, ensure height fits and adjust alignment
        if (maxHeight > availableScreenHeight) {
          maxHeight = availableScreenHeight;
          needToResize = true;
          yOffset = screenEdgePadding + showcaseOffset.dy;
        } else {
          // Align to bottom edge
          yOffset = screenSize.height -
              screenEdgePadding -
              tooltipHeight +
              showcaseOffset.dy;
        }
      }
    }

    // STEP 6: Handle resizing if needed
    if (needToResize && TooltipLayoutSlot.tooltipBox.getObjectManager != null) {
      // Resize tooltip box with new constraints
      var tooltipBoxHeight = maxHeight;
      if (hasSecondBox) {
        tooltipBoxHeight -= (actionBoxSize.height + gapBetweenContentAndAction);
      }
      TooltipLayoutSlot.tooltipBox.getObjectManager!.customRenderBox.layout(
        BoxConstraints.tightFor(
          width: maxWidth,
          height: tooltipBoxHeight,
        ),
        parentUsesSize: true,
      );
      toolTipBoxSize =
          TooltipLayoutSlot.tooltipBox.getObjectManager!.customRenderBox.size;

      // Resize action box if exists
      if (hasSecondBox &&
          TooltipLayoutSlot.actionBox.getObjectManager != null) {
        TooltipLayoutSlot.actionBox.getObjectManager!.customRenderBox.layout(
          BoxConstraints.tightFor(
            width: maxWidth,
            height: null,
          ),
          parentUsesSize: true,
        );
        actionBoxSize =
            TooltipLayoutSlot.actionBox.getObjectManager!.customRenderBox.size;
      }

      // Recalculate tooltip height after resizing
      tooltipHeight = toolTipBoxSize.height;
      if (hasSecondBox) {
        tooltipHeight += actionBoxSize.height + gapBetweenContentAndAction;
      }

      // Recalculate position if not flipping
      if (!needToFlip) {
        final initialPosition = positionToolTip(
          targetSize: targetSize,
          toolTipBoxSize: toolTipBoxSize,
          tooltipPosition: tooltipPosition,
        );
        xOffset = initialPosition.dx;
        yOffset = initialPosition.dy;
      }
    }

    // STEP 7: Handle flipping to opposite side if needed
    if (needToFlip) {
      switch (tooltipPosition) {
        case TooltipPosition.bottom:
          // Flip from bottom to top
          tooltipPosition = TooltipPosition.top;
          yOffset = targetPosition.dy -
              toolTipBoxSize.height -
              Constants.tooltipOffset;
          yOffset -= hasArrow
              ? Constants.withArrowToolTipPadding
              : Constants.withOutArrowToolTipPadding;

          break;

        case TooltipPosition.top:
          // Flip from top to bottom
          tooltipPosition = TooltipPosition.bottom;
          yOffset =
              targetPosition.dy + targetSize.height + Constants.tooltipOffset;
          yOffset += hasArrow
              ? Constants.withArrowToolTipPadding
              : Constants.withOutArrowToolTipPadding;
          break;

        case TooltipPosition.left:
          // Flip from left to right
          tooltipPosition = TooltipPosition.right;
          xOffset =
              targetPosition.dx + targetSize.width + Constants.tooltipOffset;
          xOffset += hasArrow
              ? Constants.withArrowToolTipPadding
              : Constants.withOutArrowToolTipPadding;

          break;

        case TooltipPosition.right:
          // Flip from right to left
          tooltipPosition = TooltipPosition.left;
          xOffset = targetPosition.dx -
              toolTipBoxSize.width -
              Constants.tooltipOffset;
          xOffset -= hasArrow
              ? Constants.withArrowToolTipPadding
              : Constants.withOutArrowToolTipPadding;

          break;
      }
    }

    // STEP 8: Final screen boundary check after all adjustments

    // Ensure tooltip stays within horizontal screen bounds
    xOffset = xOffset.clamp(
      screenEdgePadding + showcaseOffset.dx,
      screenSize.width -
          toolTipBoxSize.width -
          screenEdgePadding +
          showcaseOffset.dx,
    );

    // Ensure tooltip stays within vertical screen bounds
    yOffset = yOffset.clamp(
      screenEdgePadding + showcaseOffset.dy,
      screenSize.height - tooltipHeight - screenEdgePadding + showcaseOffset.dy,
    );

    switch (tooltipPosition) {
      case TooltipPosition.top:
        yOffset -= (targetPadding.top);
        break;
      case TooltipPosition.bottom:
        yOffset += (targetPadding.bottom);
        break;
      case TooltipPosition.left:
        xOffset -= (targetPadding.left);
        break;
      case TooltipPosition.right:
        xOffset += targetPadding.right;
        break;
    }

    // STEP 9: Position all child elements

    // STEP 9: Now that we've determined all the calculations, perform the actual layout

    // Perform actual layout for arrow
    if (TooltipLayoutSlot.arrow.getObjectManager != null) {
      TooltipLayoutSlot.arrow.getObjectManager!.performLayout(
        const BoxConstraints.tightFor(
          width: Constants.arrowWidth,
          height: Constants.arrowHeight,
        ),
      );
    }

    // Perform actual layout for tooltip box
    if (TooltipLayoutSlot.tooltipBox.getObjectManager != null) {
      TooltipLayoutSlot.tooltipBox.getObjectManager!.performLayout(
        BoxConstraints.tightFor(
          width: toolTipBoxSize.width,
          height: toolTipBoxSize.height,
        ),
      );

      // Position the tooltip content box
      final firstBoxParentData = TooltipLayoutSlot.tooltipBox.getObjectManager!
          .customRenderBox.parentData! as MultiChildLayoutParentData;
      firstBoxParentData.offset = Offset(xOffset, yOffset);
    }

    // Perform actual layout for action box
    if (hasSecondBox && TooltipLayoutSlot.actionBox.getObjectManager != null) {
      TooltipLayoutSlot.actionBox.getObjectManager!.performLayout(
        BoxConstraints.tightFor(
          width: actionBoxSize.width,
          height: actionBoxSize.height,
        ),
      );

      // Position the action box
      final secondBoxParentData = TooltipLayoutSlot.actionBox.getObjectManager!
          .customRenderBox.parentData! as MultiChildLayoutParentData;

      // Position differently based on tooltip direction
      if (tooltipPosition.isTop) {
        // For top tooltips, action box goes above content
        secondBoxParentData.offset = Offset(
          xOffset,
          yOffset - actionBoxSize.height - gapBetweenContentAndAction,
        );
      } else {
        // For other positions, action box goes below content
        secondBoxParentData.offset = Offset(
          xOffset,
          yOffset + toolTipBoxSize.height + gapBetweenContentAndAction,
        );
      }
    }

    // Position the arrow element
    if (hasArrow && TooltipLayoutSlot.arrow.getObjectManager != null) {
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
            yOffset + toolTipBoxSize.height - 2,
          );
          break;

        case TooltipPosition.bottom:
          // Arrow points up from top of tooltip
          arrowBoxParentData.offset = Offset(
            targetPosition.dx + halfTargetWidth - halfArrowWidth,
            yOffset - Constants.arrowHeight + 1,
          );
          break;

        case TooltipPosition.left:
          // Arrow points right from right side of tooltip
          arrowBoxParentData.offset = Offset(
            xOffset + toolTipBoxSize.width - halfArrowHeight + 4,
            targetPosition.dy + halfTargetHeight - halfArrowWidth + 4,
          );
          break;

        case TooltipPosition.right:
          // Arrow points left from left side of tooltip
          arrowBoxParentData.offset = Offset(
            xOffset - Constants.arrowHeight - 4,
            targetPosition.dy + halfTargetHeight - halfArrowHeight + 4,
          );
          break;
      }
    }
    RenderObjectManager.renderObjects.clear();
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
    switch (pos) {
      case TooltipPosition.bottom:
        // Check if tooltip fits below target
        return targetPosition.dy +
                targetSize.height +
                totalHeight +
                Constants.tooltipOffset +
                (hasArrow
                    ? Constants.withArrowToolTipPadding
                    : Constants.withOutArrowToolTipPadding) -
                showcaseOffset.dy <=
            screenSize.height - screenEdgePadding;

      case TooltipPosition.top:
        // Check if tooltip fits above target
        return targetPosition.dy -
                totalHeight -
                Constants.tooltipOffset -
                (hasArrow
                    ? Constants.withArrowToolTipPadding
                    : Constants.withOutArrowToolTipPadding) -
                showcaseOffset.dy >=
            screenEdgePadding;

      case TooltipPosition.left:
        // Check if tooltip fits to the left of target
        return targetPosition.dx -
                tooltipSize.width -
                Constants.tooltipOffset -
                (hasArrow
                    ? Constants.withArrowToolTipPadding
                    : Constants.withOutArrowToolTipPadding) -
                showcaseOffset.dx >=
            screenEdgePadding;

      case TooltipPosition.right:
        // Check if tooltip fits to the right of target
        return targetPosition.dx +
                targetSize.width +
                tooltipSize.width +
                Constants.tooltipOffset +
                (hasArrow
                    ? Constants.withArrowToolTipPadding
                    : Constants.withOutArrowToolTipPadding) -
                showcaseOffset.dx <=
            screenSize.width - screenEdgePadding;
    }
  }
}
