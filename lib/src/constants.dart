import 'package:flutter/material.dart';

import 'widget/showcase_circular_progress_indecator.dart';

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
}
