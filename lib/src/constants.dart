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
import 'package:flutter/material.dart';

import 'widget/showcase_circular_progress_indicator.dart';

class Constants {
  Constants._();

  /// Arrow dimensions
  static const double arrowWidth = 18;
  static const double arrowHeight = 9;

  static const double arrowStrokeWidth = 10;

  /// Padding when arrow is visible
  static const double withArrowToolTipPadding = 7;

  /// Padding when arrow is not visible
  static const double withOutArrowToolTipPadding = 0;

  /// Distance between target and tooltip
  static const double tooltipOffset = 10;

  /// Minimum tooltip dimensions to maintain usability
  static const double minimumToolTipWidth = 50;
  // Currently we are not constraining height but will do in future
  static const double minimumToolTipHeight = 50;

  /// This is amount of extra offset scale alignment will have
  /// i.e if it is bottom position then centerBottom + [extraAlignmentOffset]
  /// in bottom
  static const double extraAlignmentOffset = 5;

  static const Radius defaultTargetRadius = Radius.circular(3.0);

  static const ShapeBorder defaultTargetShapeBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const double cupertinoActivityIndicatorRadius = 12.0;
  static const Widget defaultProgressIndicator =
      ShowcaseCircularProgressIndicator();

  static const Duration defaultAnimationDuration = Duration(milliseconds: 2000);

  /// Default scope name when none is specified
  static const String defaultScope = '_showcaseDefaultScope';
  static const String initialScope = '_showcaseInitialScope';

  static const Duration defaultAutoPlayDelay = Duration(milliseconds: 2000);
  static const Duration defaultScrollDuration = Duration(milliseconds: 300);
}
