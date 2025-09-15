import 'package:flutter/material.dart';

/// Container for captured inherited widget data from showcase's context.
class FlutterInheritedData {
  const FlutterInheritedData({
    required this.mediaQuery,
    required this.textDirection,
    required this.capturedThemes,
    required this.textStyle,
  });

  factory FlutterInheritedData.fromContext(BuildContext context) {
    return FlutterInheritedData(
      mediaQuery: MediaQuery.of(context),
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: Navigator.maybeOf(context)?.context,
      ),
      textDirection: Directionality.of(context),
      textStyle: DefaultTextStyle.of(context).style,
    );
  }

  final MediaQueryData mediaQuery;
  final CapturedThemes capturedThemes;
  final TextDirection textDirection;
  final TextStyle textStyle;
}
