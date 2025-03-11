class Constants {
  Constants._();

  /// Arrow dimensions
  static const double arrowWidth = 18;
  static const double arrowHeight = 9;

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
}
