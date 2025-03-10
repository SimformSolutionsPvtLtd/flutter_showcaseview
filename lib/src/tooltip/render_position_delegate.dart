part of 'tooltip.dart';

/// Custom RenderObject that handles tooltip positioning and layout
/// Manages the positioning of tooltip content, action buttons, and arrow
/// while ensuring the tooltip stays within screen boundaries
class RenderPositionDelegate extends RenderBox
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
  RenderPositionDelegate({
    required this.targetPosition,
    required this.targetSize,
    required this.position,
    required this.screenSize,
    required this.hasSecondBox,
    required this.hasArrow,
    required this.toolTipSlideEndDistance,
    required this.gapBetweenContentAndAction,
    required this.screenEdgePadding,
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

  // Layout constants
  /// Padding when arrow is visible
  final _withArrowToolTipPadding = 7.0;

  /// Padding when arrow is not visible
  final _withOutArrowToolTipPadding = 0.0;

  /// Distance between target and tooltip
  final _tooltipOffset = 10.0;

  /// Arrow dimensions
  final arrowWidth = 14.0;
  final arrowHeight = 7.0;

  /// Minimum tooltip dimensions to maintain usability
  final minimumToolTipWidth = 50.0;
  final minimumToolTipHeight = 50.0;

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
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    // Always set a size for this render object first to prevent layout errors
    size = constraints.biggest;

    // Initialize variables for child sizes
    Size toolTipBoxSize = Size.zero;
    Size actionBoxSize = Size.zero;
    var minimumActionBoxSize = Size.zero;

    // References to child render objects
    RenderBox? toolTipBox;
    RenderBox? actionBox;
    RenderBox? arrowBox;

    // Find children by ID
    RenderBox? child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData =
          child.parentData! as MultiChildLayoutParentData;

      // Identify each child by its slot ID
      if (childParentData.id == TooltipLayoutSlot.tooltipBox) {
        toolTipBox = child;
      } else if (childParentData.id == TooltipLayoutSlot.actionBox) {
        actionBox = child;
      } else if (childParentData.id == TooltipLayoutSlot.arrow) {
        arrowBox = child;
      }

      child = childParentData.nextSibling;
    }

    // STEP 1: Initial layout of children to determine natural sizes

    // Layout arrow early to avoid RenderCustomPaint errors
    if (hasArrow && arrowBox != null) {
      arrowBox.layout(
          BoxConstraints.tightFor(width: arrowWidth, height: arrowHeight),
          parentUsesSize: true);
    }

    // Layout main tooltip content with loose constraints
    if (toolTipBox != null) {
      toolTipBox.layout(
          const BoxConstraints.tightFor(width: null, height: null),
          parentUsesSize: true);
      toolTipBoxSize = toolTipBox.size;
    }

    // Layout action box (if exists) with loose constraints
    if (hasSecondBox && actionBox != null) {
      actionBox.layout(
        const BoxConstraints.tightFor(width: null, height: null),
        parentUsesSize: true,
      );
      actionBoxSize = actionBox.size;
      minimumActionBoxSize = actionBox.size;
    }

    // STEP 2: Normalize widths between tooltip and action box for consistency

    // Make both boxes the same width (use the wider one)
    if (actionBoxSize.width > toolTipBoxSize.width && toolTipBox != null) {
      // Action box is wider, make tooltip match
      toolTipBox.layout(
          BoxConstraints.tightFor(width: actionBoxSize.width, height: null),
          parentUsesSize: true);
      toolTipBoxSize = toolTipBox.size;
    } else if (toolTipBoxSize.width > actionBoxSize.width &&
        hasSecondBox &&
        actionBox != null) {
      // Tooltip is wider, make action box match
      actionBox.layout(
          BoxConstraints.tightFor(width: toolTipBoxSize.width, height: null),
          parentUsesSize: true);
      actionBoxSize = actionBox.size;
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
      if (_fitsInPosition(
          TooltipPosition.bottom, toolTipBoxSize, tooltipHeight)) {
        tooltipPosition = TooltipPosition.bottom;
      } else if (_fitsInPosition(
          TooltipPosition.top, toolTipBoxSize, tooltipHeight)) {
        tooltipPosition = TooltipPosition.top;
      } else if (_fitsInPosition(
          TooltipPosition.left, toolTipBoxSize, tooltipHeight)) {
        tooltipPosition = TooltipPosition.left;
      } else if (_fitsInPosition(
          TooltipPosition.right, toolTipBoxSize, tooltipHeight)) {
        tooltipPosition = TooltipPosition.right;
      } else {
        // Default to bottom if nothing fits (will be adjusted later)
        tooltipPosition = TooltipPosition.bottom;
      }
    } else {
      // Use provided position
      tooltipPosition = position!;
    }

    // Initialize tooltip positioning variables
    double xOffset = 0;
    double yOffset = 0;

    // STEP 4: Position tooltip according to selected position

    // Helper function to calculate initial position based on selected direction
    void positionToolTip() {
      switch (tooltipPosition) {
        case TooltipPosition.bottom:
          // Center horizontally below target
          xOffset =
              targetPosition.dx + (targetSize.width - toolTipBoxSize.width) / 2;
          // Position below target with appropriate offset
          yOffset = targetPosition.dy + targetSize.height + _tooltipOffset;
          // Add additional padding if arrow is shown
          if (hasArrow) {
            yOffset += _withArrowToolTipPadding;
          } else {
            yOffset += _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.top:
          // Center horizontally above target
          xOffset =
              targetPosition.dx + (targetSize.width - toolTipBoxSize.width) / 2;
          // Position above target with appropriate offset
          yOffset = targetPosition.dy - toolTipBoxSize.height - _tooltipOffset;
          // Add additional padding if arrow is shown
          if (hasArrow) {
            yOffset -= _withArrowToolTipPadding;
          } else {
            yOffset -= _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.left:
          // Position to the left of target with appropriate offset
          xOffset = targetPosition.dx - toolTipBoxSize.width - _tooltipOffset;
          // Add additional padding if arrow is shown
          if (hasArrow) {
            xOffset -= _withArrowToolTipPadding;
          } else {
            xOffset -= _withOutArrowToolTipPadding;
          }
          // Center vertically beside target
          yOffset = targetPosition.dy +
              (targetSize.height - toolTipBoxSize.height) / 2;
          break;

        case TooltipPosition.right:
          // Position to the right of target with appropriate offset
          xOffset = targetPosition.dx + targetSize.width + _tooltipOffset;
          // Add additional padding if arrow is shown
          if (hasArrow) {
            xOffset += _withArrowToolTipPadding;
          } else {
            xOffset += _withOutArrowToolTipPadding;
          }
          // Center vertically beside target
          yOffset = targetPosition.dy +
              (targetSize.height - toolTipBoxSize.height) / 2;
          break;
      }
    }

    // Calculate initial position
    positionToolTip();

    // STEP 5: Handle screen boundary constraints and adjustments

    // Flags to track if we need to make adjustments
    bool needToResize = false; // Whether to resize the tooltip
    bool needToFlip = false; // Whether to flip to opposite side

    // Maximum dimensions to use when resizing
    double maxWidth = toolTipBoxSize.width;
    double maxHeight = tooltipHeight;

    // Horizontal boundary handling
    if (xOffset < screenEdgePadding) {
      // Tooltip extends beyond left edge
      if (tooltipPosition == TooltipPosition.left) {
        // When positioned left, we have a few options:
        var minWidth = maxWidth - screenEdgePadding + xOffset.abs();
        if (minWidth > minimumToolTipWidth &&
            minWidth > minimumActionBoxSize.width) {
          // Option 1: Resize tooltip to fit
          maxWidth -= screenEdgePadding + xOffset.abs();
          xOffset = screenEdgePadding;
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.right, toolTipBoxSize, tooltipHeight)) {
          // Option 2: Flip to right side if it fits
          needToFlip = true;
        } else if (_fitsInPosition(
            TooltipPosition.bottom, toolTipBoxSize, tooltipHeight)) {
          // Option 3: Switch to bottom position if it fits
          tooltipPosition = TooltipPosition.bottom;
          if (maxWidth > screenSize.width - (2 * screenEdgePadding)) {
            maxWidth = screenSize.width - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.top, toolTipBoxSize, tooltipHeight)) {
          // Option 4: Switch to top position if it fits
          tooltipPosition = TooltipPosition.top;
          if (maxWidth > screenSize.width - (2 * screenEdgePadding)) {
            maxWidth = screenSize.width - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else {
          // Option 5: Last resort - resize and keep at left
          maxWidth -= screenEdgePadding - xOffset;
          xOffset = screenEdgePadding;
          needToResize = true;
        }
      } else if (tooltipPosition.isVertical) {
        // For top/bottom positions, ensure width fits and align to left edge
        if (maxWidth > screenSize.width - (2 * screenEdgePadding)) {
          maxWidth = screenSize.width - (2 * screenEdgePadding);
          needToResize = true;
        }
        xOffset = screenEdgePadding;
      }
    } else if (xOffset + toolTipBoxSize.width >
        screenSize.width - screenEdgePadding) {
      // Tooltip extends beyond right edge
      if (tooltipPosition == TooltipPosition.right) {
        // When positioned right, similar options as with left position
        var minWidth = screenSize.width - screenEdgePadding - xOffset;

        if (minWidth > minimumToolTipWidth &&
            minWidth > minimumActionBoxSize.width) {
          // Option 1: Resize tooltip to fit
          maxWidth = screenSize.width - xOffset - screenEdgePadding;
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.left, toolTipBoxSize, tooltipHeight)) {
          // Option 2: Flip to left side if it fits
          needToFlip = true;
        } else if (_fitsInPosition(
            TooltipPosition.bottom, toolTipBoxSize, tooltipHeight)) {
          // Option 3: Switch to bottom position if it fits
          tooltipPosition = TooltipPosition.bottom;
          maxWidth = screenSize.width - (2 * screenEdgePadding);
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.top, toolTipBoxSize, tooltipHeight)) {
          // Option 4: Switch to top position if it fits
          tooltipPosition = TooltipPosition.top;
          maxWidth = screenSize.width - (2 * screenEdgePadding);
          needToResize = true;
        } else {
          // Option 5: Last resort - resize and keep at right
          maxWidth = screenSize.width - xOffset - screenEdgePadding;
          needToResize = true;
        }
      } else {
        // For top/bottom positions, ensure width fits and adjust alignment
        if (maxWidth > screenSize.width - (2 * screenEdgePadding)) {
          maxWidth = screenSize.width - (2 * screenEdgePadding);
          needToResize = true;
          xOffset = screenEdgePadding;
        } else {
          // Align to right edge
          xOffset = screenSize.width - screenEdgePadding - toolTipBoxSize.width;
        }
      }
    }

    // Recalculate max height based on new width constraints if resizing
    maxHeight = (toolTipBox
                ?.getDryLayout(
                    BoxConstraints.tightFor(width: maxWidth, height: null))
                .height ??
            0) +
        actionBoxSize.height;

    // Vertical boundary handling
    if (yOffset < screenEdgePadding) {
      // Tooltip extends beyond top edge
      if (tooltipPosition == TooltipPosition.top) {
        // When positioned at top, check options
        if (_fitsInPosition(
            TooltipPosition.bottom, toolTipBoxSize, tooltipHeight)) {
          // Option 1: Flip to bottom side if it fits
          needToFlip = true;
        } else if (_fitsInPosition(
            TooltipPosition.left, toolTipBoxSize, tooltipHeight)) {
          // Option 2: Switch to left position if it fits
          tooltipPosition = TooltipPosition.left;
          if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
            maxHeight = screenSize.height - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.right, toolTipBoxSize, tooltipHeight)) {
          // Option 3: Switch to right position if it fits
          tooltipPosition = TooltipPosition.right;
          if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
            maxHeight = screenSize.height - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else {
          // Option 4: Last resort - resize and keep at top
          maxHeight -= screenEdgePadding - xOffset;
          yOffset = screenEdgePadding;
          needToResize = true;
        }
      } else if (tooltipPosition.isHorizontal) {
        // For left/right positions, ensure height fits and align to top edge
        if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
          maxHeight = screenSize.height - (2 * screenEdgePadding);
          needToResize = true;
        }
        yOffset = screenEdgePadding;
      }
    } else if (yOffset + tooltipHeight >
        screenSize.height - screenEdgePadding) {
      // Tooltip extends beyond bottom edge
      if (tooltipPosition == TooltipPosition.bottom) {
        // When positioned at bottom, check options
        if (_fitsInPosition(
            TooltipPosition.top, toolTipBoxSize, tooltipHeight)) {
          // Option 1: Flip to top side if it fits
          needToFlip = true;
        } else if (_fitsInPosition(
            TooltipPosition.left, toolTipBoxSize, tooltipHeight)) {
          // Option 2: Switch to left position if it fits
          tooltipPosition = TooltipPosition.left;
          if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
            maxHeight = screenSize.height - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.right, toolTipBoxSize, tooltipHeight)) {
          // Option 3: Switch to right position if it fits
          tooltipPosition = TooltipPosition.right;
          if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
            maxHeight = screenSize.height - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else {
          // Option 4: Last resort - resize and keep at bottom
          maxHeight = screenSize.height - yOffset - screenEdgePadding;
          needToResize = true;
        }
      } else {
        // For left/right positions, ensure height fits and adjust alignment
        if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
          maxHeight = screenSize.height - (2 * screenEdgePadding);
          needToResize = true;
          yOffset = screenEdgePadding;
        } else {
          // Align to bottom edge
          yOffset = screenSize.height - screenEdgePadding - tooltipHeight;
        }
      }
    }

    // STEP 6: Handle resizing if needed
    if (needToResize && toolTipBox != null) {
      // Resize tooltip box with new constraints
      var tooltipBoxHeight = maxHeight;
      if (hasSecondBox) {
        tooltipBoxHeight -= (actionBoxSize.height + gapBetweenContentAndAction);
      }
      toolTipBox.layout(
          BoxConstraints.tightFor(
              width: maxWidth, height: maxHeight - tooltipBoxHeight),
          parentUsesSize: true);
      toolTipBoxSize = toolTipBox.size;

      // Resize action box if exists
      if (hasSecondBox && actionBox != null) {
        actionBox.layout(BoxConstraints.tightFor(width: maxWidth, height: null),
            parentUsesSize: true);
        actionBoxSize = actionBox.size;
      }

      // Recalculate tooltip height after resizing
      tooltipHeight = toolTipBoxSize.height;
      if (hasSecondBox) {
        tooltipHeight += actionBoxSize.height + gapBetweenContentAndAction;
      }

      // Recalculate position if not flipping
      if (!needToFlip) {
        positionToolTip();
      }
    }

    // STEP 7: Handle flipping to opposite side if needed
    if (needToFlip) {
      switch (tooltipPosition) {
        case TooltipPosition.bottom:
          // Flip from bottom to top
          tooltipPosition = TooltipPosition.top;
          yOffset = targetPosition.dy - toolTipBoxSize.height - _tooltipOffset;
          if (hasArrow) {
            yOffset -= _withArrowToolTipPadding;
          } else {
            yOffset -= _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.top:
          // Flip from top to bottom
          tooltipPosition = TooltipPosition.bottom;
          yOffset = targetPosition.dy + targetSize.height + _tooltipOffset;
          if (hasArrow) {
            yOffset += _withArrowToolTipPadding;
          } else {
            yOffset += _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.left:
          // Flip from left to right
          tooltipPosition = TooltipPosition.right;
          xOffset = targetPosition.dx + targetSize.width + _tooltipOffset;
          if (hasArrow) {
            xOffset += _withArrowToolTipPadding;
          } else {
            xOffset += _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.right:
          // Flip from right to left
          tooltipPosition = TooltipPosition.left;
          xOffset = targetPosition.dx - toolTipBoxSize.width - _tooltipOffset;
          if (hasArrow) {
            xOffset -= _withArrowToolTipPadding;
          } else {
            xOffset -= _withOutArrowToolTipPadding;
          }
          break;
      }
    }

    // STEP 8: Final screen boundary check after all adjustments

    // Ensure tooltip stays within horizontal screen bounds
    xOffset = xOffset.clamp(screenEdgePadding,
        screenSize.width - toolTipBoxSize.width - screenEdgePadding);

    // Ensure tooltip stays within vertical screen bounds
    yOffset = yOffset.clamp(screenEdgePadding,
        screenSize.height - tooltipHeight - screenEdgePadding);

    // STEP 9: Position all child elements

    // Position the tooltip content box
    if (toolTipBox != null) {
      final firstBoxParentData =
          toolTipBox.parentData! as MultiChildLayoutParentData;
      firstBoxParentData.offset = Offset(xOffset, yOffset);
    }

    // Position the action box (if exists)
    if (hasSecondBox && actionBox != null) {
      final secondBoxParentData =
          actionBox.parentData! as MultiChildLayoutParentData;

      // Position differently based on tooltip direction
      if (tooltipPosition == TooltipPosition.top) {
        // For top tooltips, action box goes above content
        secondBoxParentData.offset = Offset(xOffset,
            yOffset - actionBoxSize.height - gapBetweenContentAndAction);
      } else {
        // For other positions, action box goes below content
        secondBoxParentData.offset = Offset(xOffset,
            yOffset + toolTipBoxSize.height + gapBetweenContentAndAction);
      }
    }

    // Position the arrow element (if exists)
    if (hasArrow && arrowBox != null) {
      final arrowBoxParentData =
          arrowBox.parentData! as MultiChildLayoutParentData;

      // Position arrow differently based on tooltip direction
      switch (tooltipPosition) {
        case TooltipPosition.top:
          // Arrow points down from bottom of tooltip
          arrowBoxParentData.offset = Offset(
            targetPosition.dx + (targetSize.width / 2) - (arrowWidth / 2),
            yOffset + toolTipBoxSize.height + (arrowHeight / 2) - 2,
          );
          break;

        case TooltipPosition.bottom:
          // Arrow points up from top of tooltip
          arrowBoxParentData.offset = Offset(
            targetPosition.dx + (targetSize.width / 2) - (arrowWidth / 2) - 2,
            yOffset - arrowHeight,
          );
          break;

        case TooltipPosition.left:
          // Arrow points right from right side of tooltip
          arrowBoxParentData.offset = Offset(
            xOffset + toolTipBoxSize.width - 2,
            targetPosition.dy + (targetSize.height / 2) - (arrowWidth / 2) + 2,
          );
          break;

        case TooltipPosition.right:
          // Arrow points left from left side of tooltip
          arrowBoxParentData.offset = Offset(
            xOffset - arrowWidth + 2,
            targetPosition.dy + (targetSize.height / 2) - (arrowHeight / 2),
          );
          break;
      }
    }
  }

  /// Helper method to check if tooltip fits in a specific position
  ///
  /// Returns true if the tooltip fits in the given position without
  /// extending beyond screen boundaries
  bool _fitsInPosition(
      TooltipPosition pos, Size tooltipSize, double totalHeight) {
    switch (pos) {
      case TooltipPosition.bottom:
        // Check if tooltip fits below target
        return targetPosition.dy +
                targetSize.height +
                totalHeight +
                _tooltipOffset +
                (hasArrow
                    ? _withArrowToolTipPadding
                    : _withOutArrowToolTipPadding) <=
            screenSize.height - screenEdgePadding;

      case TooltipPosition.top:
        // Check if tooltip fits above target
        return targetPosition.dy -
                totalHeight -
                _tooltipOffset -
                (hasArrow
                    ? _withArrowToolTipPadding
                    : _withOutArrowToolTipPadding) >=
            screenEdgePadding;

      case TooltipPosition.left:
        // Check if tooltip fits to the left of target
        return targetPosition.dx -
                tooltipSize.width -
                _tooltipOffset -
                (hasArrow
                    ? _withArrowToolTipPadding
                    : _withOutArrowToolTipPadding) >=
            screenEdgePadding;

      case TooltipPosition.right:
        // Check if tooltip fits to the right of target
        return targetPosition.dx +
                targetSize.width +
                tooltipSize.width +
                _tooltipOffset +
                (hasArrow
                    ? _withArrowToolTipPadding
                    : _withOutArrowToolTipPadding) <=
            screenSize.width - screenEdgePadding;
    }
  }
}
