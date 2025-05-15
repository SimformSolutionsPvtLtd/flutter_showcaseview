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

import 'dart:math';

import 'package:flutter/widgets.dart';

import '../showcase/showcase_view.dart';
import '../tooltip/render_object_manager.dart';

/// Defines the position of a tooltip relative to its target widget in the
/// showcase.
///
/// This enum is used to:
/// - Position tooltips around the target element (top, bottom, left, or right).
/// - Determine arrow rotation angles to point correctly to the target.
/// - Establish proper animation alignment for scaling effects.
/// - Calculate movement offsets for tooltip slide animations.
/// - Handle adaptive positioning when screen edges constrain the preferred
/// position.
/// - Support flipping the tooltip to the opposite side when space is limited.
///
/// The tooltip position can be explicitly set in the Showcase widget
/// configuration, or it can be automatically determined based on available
/// space constraints.
enum TooltipPosition {
  /// Positions the tooltip above the target widget with the arrow pointing
  /// down.
  ///
  /// This position is useful when there is more space available above the
  /// target than below it. The tooltip will be centered horizontally with
  /// respect to the target.
  top(rotationAngle: pi, scaleAlignment: Alignment.topCenter),

  /// Positions the tooltip below the target widget with the arrow pointing up.
  ///
  /// This is the default and preferred position when there is sufficient space
  /// below the target. The tooltip will be centered horizontally with
  /// respect to the target.
  bottom(rotationAngle: 0, scaleAlignment: Alignment.bottomCenter),

  /// Positions the tooltip to the left of the target widget with the arrow
  /// pointing right.
  ///
  /// Used when there is more horizontal space available to the left of the
  /// target. The tooltip will be centered vertically with respect to the
  /// target.
  left(rotationAngle: pi * 0.5, scaleAlignment: Alignment.centerLeft),

  /// Positions the tooltip to the right of the target widget with the arrow
  /// pointing left.
  ///
  /// Used when there is more horizontal space available to the right of the
  /// target. The tooltip will be centered vertically with respect to the
  /// target.
  right(rotationAngle: 3 * pi * 0.5, scaleAlignment: Alignment.centerRight);

  const TooltipPosition({
    required this.rotationAngle,
    required this.scaleAlignment,
  });

  /// Initial position of the arrow is pointing top so we need to rotate as
  /// per the position of the tooltip. This will provide necessary rotation to
  /// properly point arrow.
  final double rotationAngle;

  /// Determines the default scale alignment based on tooltip position.
  final Alignment scaleAlignment;

  /// Computes the offset movement animation based on tooltip position.
  Offset calculateMoveOffset(
    double animationValue,
    double toolTipSlideEndDistance,
  ) {
    switch (this) {
      case TooltipPosition.top:
        return Offset(0, (1 - animationValue) * -toolTipSlideEndDistance);
      case TooltipPosition.bottom:
        return Offset(0, (1 - animationValue) * toolTipSlideEndDistance);
      case TooltipPosition.left:
        return Offset((1 - animationValue) * -toolTipSlideEndDistance, 0);
      case TooltipPosition.right:
        return Offset((1 - animationValue) * toolTipSlideEndDistance, 0);
    }
  }

  bool get isRight => this == TooltipPosition.right;
  bool get isLeft => this == TooltipPosition.left;
  bool get isTop => this == TooltipPosition.top;
  bool get isBottom => this == TooltipPosition.bottom;

  bool get isHorizontal => isRight || isLeft;
  bool get isVertical => isTop || isBottom;

  TooltipPosition get opposite {
    switch (this) {
      case TooltipPosition.left:
        return TooltipPosition.right;
      case TooltipPosition.right:
        return TooltipPosition.left;
      case TooltipPosition.top:
        return TooltipPosition.bottom;
      case TooltipPosition.bottom:
        return TooltipPosition.top;
    }
  }
}

/// Defines the positioning of action buttons relative to the tooltip content.
///
/// This enum determines whether action buttons (like next, previous, skip buttons)
/// should be placed:
/// - Inside the tooltip container itself, appearing as part of the tooltip content
/// - Outside the tooltip container, appearing as separate UI elements below/above the tooltip
///
/// The position affects the layout calculations, spacing, and visual appearance
/// of the tooltip component within the showcase.
enum TooltipActionPosition {
  /// Places the action buttons outside the tooltip container.
  ///
  /// When this option is selected, the action buttons will be rendered as
  /// separate UI elements below/above the tooltip content.
  outside,

  /// Places the action buttons inside the tooltip container.
  ///
  /// When this option is selected, the action buttons will be rendered as
  /// part of the tooltip content, appearing within the same container.
  inside;

  bool get isInside => this == inside;

  bool get isOutside => this == outside;
}

/// Defines the standard action types that can be used in tooltip action
/// buttons.
///
/// Each action type has a default display name and a predefined behavior
/// when tapped, making it easy to implement standard navigation controls in
/// showcase tooltips. Custom behaviors can be achieved by providing an
/// explicit `onTap` callback when creating a `TooltipActionButton`.
enum TooltipDefaultActionType {
  /// Advances to the next showcase item in the sequence.
  next(actionName: 'Next'),

  /// Dismisses the entire showcase flow.
  skip(actionName: 'Skip'),

  /// Returns to the previous showcase item in the sequence.
  previous(actionName: 'Previous');

  const TooltipDefaultActionType({required this.actionName});

  final String actionName;

  void onTap(ShowcaseView showcaseView) {
    switch (this) {
      case TooltipDefaultActionType.next:
        showcaseView.next(force: true);
        break;
      case TooltipDefaultActionType.previous:
        showcaseView.previous();
        break;
      case TooltipDefaultActionType.skip:
        showcaseView.dismiss();
        break;
      default:
        throw ArgumentError('Invalid tooltip default action type');
    }
  }
}

/// Identifies the different components within the tooltip layout system.
///
/// This enum is used internally by the rendering system to:
/// - Identify and track the different render objects in the tooltip layout.
/// - Manage the positioning and sizing of each component independently.
/// - Coordinate layout operations between tooltip content, action buttons,
/// and the arrow.
///
/// The layout system uses these identifiers to properly arrange and render
/// the tooltip components while respecting screen boundaries and maintaining
/// proper alignment with the target widget.
enum TooltipLayoutSlot {
  /// Represents the main tooltip content container.
  ///
  /// This component holds the primary content of the tooltip, including the
  /// title, description, and any internal action buttons.
  tooltipBox,

  /// Represents the container for action buttons when positioned outside the
  /// tooltip.
  ///
  /// This component is only used when tooltip actions are configured with
  /// `TooltipActionPosition.outside`.
  actionBox,

  /// Represents the directional arrow that points from the tooltip to the
  /// target.
  ///
  /// This component is a small triangle that visually connects the tooltip to
  /// its target widget.
  arrow;

  RenderObjectManager? get getObjectManager =>
      RenderObjectManager.renderObjects[this];
}
