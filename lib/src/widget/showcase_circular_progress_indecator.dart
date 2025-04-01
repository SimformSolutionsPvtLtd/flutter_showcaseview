import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';

import '../constants.dart';

class ShowcaseCircularProgressIndicator extends StatelessWidget {
  const ShowcaseCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const CupertinoActivityIndicator(
          radius: Constants.cupertinoActivityIndicatorRadius,
          color: Colors.white,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        );
    }
  }
}
