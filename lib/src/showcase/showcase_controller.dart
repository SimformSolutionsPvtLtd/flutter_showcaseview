import 'package:flutter/widgets.dart';

import '../get_position.dart';
import '../models/linked_showcase_data.dart';
import 'showcase.dart';

/// Controller class for managing showcase functionality
class ShowcaseController {
  /// Creates a [ShowcaseController] with required parameters
  ShowcaseController({
    required this.showcaseId,
    required this.showcaseKey,
    required this.showcaseConfig,
    this.scrollIntoView,
  });

  /// Unique identifier for the showcase
  final int showcaseId;

  /// Global key associated with the showcase widget
  final GlobalKey showcaseKey;

  /// Configuration for the showcase
  Showcase? showcaseConfig;

  /// Position getter for the showcase
  GetPosition? position;

  /// Data model for linked showcases
  LinkedShowcaseDataModel? linkedShowcaseDataModel;

  /// Callback to start the showcase
  VoidCallback? startShowcase;

  /// Optional function to scroll the view
  final ValueGetter<Future<void>>? scrollIntoView;

  /// Optional function to reverse the animation
  ValueGetter<Future<void>>? reverseAnimation;

  /// Size of the root widget
  Size? rootWidgetSize;

  /// Render box for the root widget
  RenderBox? rootRenderObject;

  /// List of tooltip widgets
  List<Widget> getToolTipWidget = [];

  /// Flag to track if scrolling is in progress
  bool isScrollRunning = false;

  /// Blur effect value
  double blur = 0.0;

  @override
  int get hashCode => Object.hash(showcaseId, showcaseKey);

  @override
  bool operator ==(Object other) {
    return (identical(this, other)) ||
        other is ShowcaseController &&
            other.showcaseKey == showcaseKey &&
            other.showcaseId == showcaseId;
  }
}
