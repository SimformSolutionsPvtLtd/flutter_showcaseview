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

import 'showcase_widget.dart';

enum TooltipPosition {
  top,
  bottom,
  left,
  right;

  double get rotationAngle {
    switch (this) {
      case TooltipPosition.top:
        return pi;

      case TooltipPosition.bottom:
        return 0;

      case TooltipPosition.left:
        return pi / 2;

      case TooltipPosition.right:
        return 3 * pi / 2;
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
        showCaseState.next();
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
