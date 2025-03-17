import 'package:flutter/widgets.dart';

import '../get_position.dart';
import '../models/linked_showcase_data.dart';
import 'showcase_v2.dart';

class ShowcaseController {
  ShowcaseController({
    required this.showcaseId,
    required this.showcaseKey,
    required this.showcaseConfig,
  });

  final int showcaseId;
  final GlobalKey showcaseKey;
  final Showcase showcaseConfig;

  late GetPosition position;
  late LinkedShowcaseDataModel linkedShowcaseDataModel;
  late VoidCallback startShowcase;
  Future<void> Function()? reverseAnimation;
  List<Widget> getToolTipWidget = [];
  bool isScrollRunning = false;
  double blur = 0.0;
  Size? rootWidgetSize;
  RenderBox? rootRenderObject;

  @override
  int get hashCode {
    final result = showcaseId.hashCode +
        showcaseKey.hashCode; // Replace with your properties

    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! ShowcaseController) {
      return false;
    }
    return other.showcaseKey == showcaseKey && other.showcaseId == showcaseId;
  }
}
