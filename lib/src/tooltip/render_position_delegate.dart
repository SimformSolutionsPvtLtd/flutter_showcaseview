part of 'tooltip.dart';

// Custom RenderObject for tooltip multi-child layout
class RenderPositionDelegate extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
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

  Offset targetPosition;
  Size targetSize;
  TooltipPosition? position;
  Size screenSize;
  bool hasSecondBox;
  bool hasArrow;
  double toolTipSlideEndDistance;
  double gapBetweenContentAndAction;
  double screenEdgePadding;

  // Constants for padding
  final _withArrowToolTipPadding = 7.0;
  final _withOutArrowToolTipPadding = 0.0;

  final _tooltipOffset = 10.0;
  final arrowWidth = 14.0;
  final arrowHeight = 7.0;
  final minimumToolTipWidth = 50;
  final minimumToolTipHeight = 50;

  late TooltipPosition tooltipPosition;
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
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

    RenderBox? toolTipBox;
    RenderBox? actionBox;
    RenderBox? arrowBox;

    // Find children by ID
    RenderBox? child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData =
          child.parentData! as MultiChildLayoutParentData;

      if (childParentData.id == TooltipLayoutSlot.tooltipBox) {
        toolTipBox = child;
      } else if (childParentData.id == TooltipLayoutSlot.actionBox) {
        actionBox = child;
      } else if (childParentData.id == TooltipLayoutSlot.arrow) {
        arrowBox = child;
      }

      child = childParentData.nextSibling;
    }

    // Layout first box with loose constraints initially
    if (toolTipBox != null) {
      toolTipBox.layout(
          const BoxConstraints.tightFor(width: null, height: null),
          parentUsesSize: true);
      toolTipBoxSize = toolTipBox.size;
    }

    // Layout second box (if exists) with loose constraints initially
    if (hasSecondBox && actionBox != null) {
      actionBox.layout(
        const BoxConstraints.tightFor(width: null, height: null),
        parentUsesSize: true,
      );
      actionBoxSize = actionBox.size;
      minimumActionBoxSize = actionBox.size;
    }

    // Layout arrow (if exists) early to avoid RenderCustomPaint errors
    if (hasArrow && arrowBox != null) {
      arrowBox.layout(
          BoxConstraints.tightFor(width: arrowWidth, height: arrowHeight),
          parentUsesSize: true);
    }

    // Make sure boxes have consistent width
    if (actionBoxSize.width > toolTipBoxSize.width && toolTipBox != null) {
      toolTipBox.layout(
          BoxConstraints.tightFor(width: actionBoxSize.width, height: null),
          parentUsesSize: true);
      toolTipBoxSize = toolTipBox.size;
    } else if (toolTipBoxSize.width > actionBoxSize.width &&
        hasSecondBox &&
        actionBox != null) {
      actionBox.layout(
          BoxConstraints.tightFor(width: toolTipBoxSize.width, height: null),
          parentUsesSize: true);
      actionBoxSize = actionBox.size;
    }

    // Get combined tooltip height
    double tooltipHeight = toolTipBoxSize.height;
    if (hasSecondBox) {
      tooltipHeight += actionBoxSize.height + gapBetweenContentAndAction;
    }

    // Determine tooltip position if not provided

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
      tooltipPosition = position!;
    }

    // Calculate initial tooltip position
    double xOffset = 0;
    double yOffset = 0;

    // Position tooltip according to selected position

    void positionToolTip() {
      switch (tooltipPosition) {
        case TooltipPosition.bottom:
          xOffset =
              targetPosition.dx + (targetSize.width - toolTipBoxSize.width) / 2;
          yOffset = targetPosition.dy + targetSize.height + _tooltipOffset;
          if (hasArrow) {
            yOffset += _withArrowToolTipPadding;
          } else {
            yOffset += _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.top:
          xOffset =
              targetPosition.dx + (targetSize.width - toolTipBoxSize.width) / 2;
          yOffset = targetPosition.dy - toolTipBoxSize.height - _tooltipOffset;
          if (hasArrow) {
            yOffset -= _withArrowToolTipPadding;
          } else {
            yOffset -= _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.left:
          xOffset = targetPosition.dx - toolTipBoxSize.width - _tooltipOffset;
          if (hasArrow) {
            xOffset -= _withArrowToolTipPadding;
          } else {
            xOffset -= _withOutArrowToolTipPadding;
          }
          yOffset = targetPosition.dy +
              (targetSize.height - toolTipBoxSize.height) / 2;
          break;

        case TooltipPosition.right:
          xOffset = targetPosition.dx + targetSize.width + _tooltipOffset;
          if (hasArrow) {
            xOffset += _withArrowToolTipPadding;
          } else {
            xOffset += _withOutArrowToolTipPadding;
          }
          yOffset = targetPosition.dy +
              (targetSize.height - toolTipBoxSize.height) / 2;
          break;
      }
    }

    positionToolTip();

    // Check if tooltip exceeds screen boundaries and adjust accordingly
    bool needToResize = false;
    bool needToFlip = false;
    double maxWidth = toolTipBoxSize.width;
    double maxHeight = tooltipHeight;

    // Horizontal adjustments

    if (xOffset < screenEdgePadding) {
      if (tooltipPosition == TooltipPosition.left) {
        var minWidth = maxWidth - screenEdgePadding + xOffset.abs();
        if (minWidth > minimumToolTipWidth &&
            minWidth > minimumActionBoxSize.width) {
          maxWidth -= screenEdgePadding + xOffset.abs();
          xOffset = screenEdgePadding;
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.right, toolTipBoxSize, tooltipHeight)) {
          needToFlip = true;
        } else if (_fitsInPosition(
            TooltipPosition.bottom, toolTipBoxSize, tooltipHeight)) {
          tooltipPosition = TooltipPosition.bottom;
          if (maxWidth > screenSize.width - (2 * screenEdgePadding)) {
            maxWidth = screenSize.width - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.top, toolTipBoxSize, tooltipHeight)) {
          tooltipPosition = TooltipPosition.top;
          if (maxWidth > screenSize.width - (2 * screenEdgePadding)) {
            maxWidth = screenSize.width - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else {
          maxWidth -= screenEdgePadding - xOffset;
          xOffset = screenEdgePadding;
          needToResize = true;
        }
      } else if (tooltipPosition.isVertical) {
        if (maxWidth > screenSize.width - (2 * screenEdgePadding)) {
          maxWidth = screenSize.width - (2 * screenEdgePadding);
          needToResize = true;
        }
        xOffset = screenEdgePadding;
      }
    } else if (xOffset + toolTipBoxSize.width >
        screenSize.width - screenEdgePadding) {
      if (tooltipPosition == TooltipPosition.right) {
        var minWidth = screenSize.width - screenEdgePadding - xOffset;

        if (minWidth > minimumToolTipWidth &&
            minWidth > minimumActionBoxSize.width) {
          maxWidth = screenSize.width - xOffset - screenEdgePadding;
          needToResize = true;
        }
        // Just align with screen edge
        else if (_fitsInPosition(
            TooltipPosition.left, toolTipBoxSize, tooltipHeight)) {
          needToFlip = true;
        } else if (_fitsInPosition(
            TooltipPosition.bottom, toolTipBoxSize, tooltipHeight)) {
          tooltipPosition = TooltipPosition.bottom;
          maxWidth = screenSize.width - (2 * screenEdgePadding);
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.top, toolTipBoxSize, tooltipHeight)) {
          tooltipPosition = TooltipPosition.top;
          maxWidth = screenSize.width - (2 * screenEdgePadding);
          needToResize = true;
        } else {
          maxWidth = screenSize.width - xOffset - screenEdgePadding;
          needToResize = true;
        }
      } else {
        if (maxWidth > screenSize.width - (2 * screenEdgePadding)) {
          maxWidth = screenSize.width - (2 * screenEdgePadding);
          needToResize = true;
          xOffset = screenEdgePadding;
        } else {
          xOffset = screenSize.width - screenEdgePadding - toolTipBoxSize.width;
        }
      }
    }

    maxHeight = (toolTipBox
                ?.getDryLayout(
                    BoxConstraints.tightFor(width: maxWidth, height: null))
                .height ??
            0) +
        actionBoxSize.height;

    // Vertical adjustments
    if (yOffset < screenEdgePadding) {
      if (tooltipPosition == TooltipPosition.top) {
        if (_fitsInPosition(
            TooltipPosition.bottom, toolTipBoxSize, tooltipHeight)) {
          needToFlip = true;
        } else if (_fitsInPosition(
            TooltipPosition.left, toolTipBoxSize, tooltipHeight)) {
          tooltipPosition = TooltipPosition.left;
          if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
            maxHeight = screenSize.height - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.right, toolTipBoxSize, tooltipHeight)) {
          tooltipPosition = TooltipPosition.right;
          if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
            maxHeight = screenSize.height - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else {
          maxHeight -= screenEdgePadding - xOffset;
          yOffset = screenEdgePadding;
          needToResize = true;
        }
      } else if (tooltipPosition.isHorizontal) {
        if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
          maxHeight = screenSize.height - (2 * screenEdgePadding);
          needToResize = true;
        }
        yOffset = screenEdgePadding;
      }
    } else if (yOffset + tooltipHeight >
        screenSize.height - screenEdgePadding) {
      if (tooltipPosition == TooltipPosition.bottom) {
        // Just align with screen edge
        if (_fitsInPosition(
            TooltipPosition.top, toolTipBoxSize, tooltipHeight)) {
          needToFlip = true;
        } else if (_fitsInPosition(
            TooltipPosition.left, toolTipBoxSize, tooltipHeight)) {
          tooltipPosition = TooltipPosition.left;
          if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
            maxHeight = screenSize.height - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else if (_fitsInPosition(
            TooltipPosition.right, toolTipBoxSize, tooltipHeight)) {
          tooltipPosition = TooltipPosition.right;
          if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
            maxHeight = screenSize.height - (2 * screenEdgePadding);
          }
          needToResize = true;
        } else {
          maxHeight = screenSize.height - yOffset - screenEdgePadding;
          needToResize = true;
        }
      } else {
        if (maxHeight > screenSize.height - (2 * screenEdgePadding)) {
          maxHeight = screenSize.height - (2 * screenEdgePadding);
          needToResize = true;
          yOffset = screenEdgePadding;
        } else {
          yOffset = screenSize.height - screenEdgePadding - tooltipHeight;
        }
      }
    } else if (maxHeight > screenSize.height + screenEdgePadding) {}

    // Handle resizing if needed
    if (needToResize && toolTipBox != null) {
      toolTipBox.layout(
          BoxConstraints.tightFor(
              width: maxWidth, height: maxHeight - actionBoxSize.height),
          parentUsesSize: true);
      toolTipBoxSize = toolTipBox.size;

      if (hasSecondBox && actionBox != null) {
        actionBox.layout(BoxConstraints.tightFor(width: maxWidth, height: null),
            parentUsesSize: true);
        actionBoxSize = actionBox.size;
      }

      // Recalculate tooltip height
      tooltipHeight = toolTipBoxSize.height;
      if (hasSecondBox) {
        tooltipHeight += actionBoxSize.height + gapBetweenContentAndAction;
      }
      if (!needToFlip) {
        positionToolTip();
      }
    }

    // Handle flipping to opposite side if needed
    if (needToFlip) {
      switch (tooltipPosition) {
        case TooltipPosition.bottom:
          tooltipPosition = TooltipPosition.top;
          yOffset = targetPosition.dy - toolTipBoxSize.height - _tooltipOffset;
          if (hasArrow) {
            yOffset -= _withArrowToolTipPadding;
          } else {
            yOffset -= _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.top:
          tooltipPosition = TooltipPosition.bottom;
          yOffset = targetPosition.dy + targetSize.height + _tooltipOffset;
          if (hasArrow) {
            yOffset += _withArrowToolTipPadding;
          } else {
            yOffset += _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.left:
          tooltipPosition = TooltipPosition.right;
          xOffset = targetPosition.dx + targetSize.width + _tooltipOffset;
          if (hasArrow) {
            xOffset += _withArrowToolTipPadding;
          } else {
            xOffset += _withOutArrowToolTipPadding;
          }
          break;

        case TooltipPosition.right:
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

    // Final screen boundary check after all adjustments
    xOffset = xOffset.clamp(screenEdgePadding,
        screenSize.width - toolTipBoxSize.width - screenEdgePadding);
    yOffset = yOffset.clamp(screenEdgePadding,
        screenSize.height - tooltipHeight - screenEdgePadding);

    // Position the first box
    if (toolTipBox != null) {
      final firstBoxParentData =
          toolTipBox.parentData! as MultiChildLayoutParentData;
      firstBoxParentData.offset = Offset(xOffset, yOffset);
    }

    // Position the second box (if exists)
    if (hasSecondBox && actionBox != null) {
      final secondBoxParentData =
          actionBox.parentData! as MultiChildLayoutParentData;
      if (tooltipPosition == TooltipPosition.top) {
        secondBoxParentData.offset = Offset(xOffset,
            yOffset - actionBoxSize.height - gapBetweenContentAndAction);
      } else {
        secondBoxParentData.offset = Offset(xOffset,
            yOffset + toolTipBoxSize.height + gapBetweenContentAndAction);
      }
    }

    // Position the arrow (if exists)
    if (hasArrow && arrowBox != null) {
      // Arrow has already been laid out earlier
      final arrowBoxParentData =
          arrowBox.parentData! as MultiChildLayoutParentData;

      switch (tooltipPosition) {
        case TooltipPosition.top:
          arrowBoxParentData.offset = Offset(
            targetPosition.dx + (targetSize.width / 2) - (arrowWidth / 2),
            yOffset + toolTipBoxSize.height + (arrowHeight / 2) - 2,
          );
          break;

        case TooltipPosition.bottom:
          arrowBoxParentData.offset = Offset(
            targetPosition.dx + (targetSize.width / 2) - (arrowWidth / 2) - 2,
            yOffset - arrowHeight,
          );
          break;

        case TooltipPosition.left:
          arrowBoxParentData.offset = Offset(
            xOffset + toolTipBoxSize.width - 2,
            targetPosition.dy + (targetSize.height / 2) - (arrowWidth / 2) + 2,
          );
          break;

        case TooltipPosition.right:
          arrowBoxParentData.offset = Offset(
            xOffset - arrowWidth + 2,
            targetPosition.dy + (targetSize.height / 2) - (arrowHeight / 2),
          );
          break;
      }
    }
  }

  // Helper method to check if tooltip fits in a specific position
  bool _fitsInPosition(
      TooltipPosition pos, Size tooltipSize, double totalHeight) {
    switch (pos) {
      case TooltipPosition.bottom:
        return targetPosition.dy +
                targetSize.height +
                totalHeight +
                _tooltipOffset +
                (hasArrow
                    ? _withArrowToolTipPadding
                    : _withOutArrowToolTipPadding) <=
            screenSize.height - screenEdgePadding;

      case TooltipPosition.top:
        return targetPosition.dy -
                totalHeight -
                _tooltipOffset -
                (hasArrow
                    ? _withArrowToolTipPadding
                    : _withOutArrowToolTipPadding) >=
            screenEdgePadding;

      case TooltipPosition.left:
        return targetPosition.dx -
                tooltipSize.width -
                _tooltipOffset -
                (hasArrow
                    ? _withArrowToolTipPadding
                    : _withOutArrowToolTipPadding) >=
            screenEdgePadding;

      case TooltipPosition.right:
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
