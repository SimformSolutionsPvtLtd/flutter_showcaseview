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

import 'showcase_widget.dart';
import 'tooltip/render_object_manager.dart';

enum TooltipPosition {
  top(rotationAngle: pi, scaleAlignment: Alignment.topCenter),
  bottom(rotationAngle: 0, scaleAlignment: Alignment.bottomCenter),
  left(rotationAngle: pi * 0.5, scaleAlignment: Alignment.centerLeft),
  right(rotationAngle: 3 * pi * 0.5, scaleAlignment: Alignment.centerRight);

  const TooltipPosition({
    required this.rotationAngle,
    required this.scaleAlignment,
  });

  /// Initial position of the arrow is pointing top so we need to rotate as per the position of the tooltip
  /// This will provide necessary rotation to properly point arrow
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
}

enum TooltipActionPosition {
  outside,
  inside;

  bool get isInside => this == inside;

  bool get isOutside => this == outside;
}

enum TooltipDefaultActionType {
  next(actionName: 'Next'),
  skip(actionName: 'Skip'),
  previous(actionName: 'Previous');

  const TooltipDefaultActionType({
    required this.actionName,
  });

  final String actionName;

  void onTap(ShowCaseWidgetState showCaseState) {
    switch (this) {
      case TooltipDefaultActionType.next:
        showCaseState.next(forceNext: true);
        break;
      case TooltipDefaultActionType.previous:
        showCaseState.previous();
        break;
      case TooltipDefaultActionType.skip:
        showCaseState.dismiss();
        break;
      default:
        throw ArgumentError('Invalid tooltip default action type');
    }
  }
}

/// These are the ToolTip layout widget ids and will be used to identify
/// the widget during layout and painting phase
enum TooltipLayoutSlot {
  tooltipBox,
  actionBox,
  arrow;

  RenderObjectManager? get getObjectManager =>
      RenderObjectManager.renderObjects[this];
}
