import 'package:flutter/material.dart';

/// A widget that represents the target of a showcase.
///
/// This widget creates a transparent overlay that highlights a UI element
/// that needs to be showcased. It defines the position, size, and interaction
/// behavior of the target area.
///
/// The [TargetWidget] is positioned absolutely within the showcase overlay and
/// can respond to various gestures like tap, double tap, and long press.
class TargetWidget extends StatelessWidget {
  /// Creates a target widget for showcasing.
  ///
  /// * [offset] - The position of the target widget in the overlay
  /// * [size] - The size of the target widget
  /// * [shapeBorder] - The shape of the target highlight (e.g., circle)
  /// * [targetPadding] - Padding applied around the target to increase its
  /// highlight area
  /// * [onTap] - Callback when the target is tapped
  /// * [radius] - Border radius when using a rectangular shape
  /// * [onDoubleTap] - Callback when the target is double-tapped
  /// * [onLongPress] - Callback when the target is long-pressed
  /// * [disableDefaultChildGestures] - Whether to disable gesture detection
  /// on the target
  const TargetWidget({
    required this.offset,
    required this.size,
    required this.shapeBorder,
    required this.targetPadding,
    this.onTap,
    this.radius,
    this.onDoubleTap,
    this.onLongPress,
    this.disableDefaultChildGestures = false,
  });

  /// The position of the target widget in the overlay coordinates
  final Offset offset;

  /// The size of the target widget to be highlighted
  final Size size;

  /// Callback function when the target is tapped
  final VoidCallback? onTap;

  /// Callback function when the target is double-tapped
  final VoidCallback? onDoubleTap;

  /// Callback function when the target is long-pressed
  final VoidCallback? onLongPress;

  /// The shape of the target highlight
  ///
  /// Common shapes include [CircleBorder] and [RoundedRectangleBorder]
  final ShapeBorder shapeBorder;

  /// Border radius when using a rectangular shape
  ///
  /// This is used only when a rectangular shape is needed with rounded corners
  final BorderRadius? radius;

  /// Whether to disable gesture detection on the target area
  ///
  /// When true, the target area will not respond to gestures and will
  /// not show a pointer cursor on hover
  final bool disableDefaultChildGestures;

  /// Padding applied around the target to increase its highlight area
  ///
  /// This creates some space between the actual widget and its highlight border
  final EdgeInsets targetPadding;

  @override
  Widget build(BuildContext context) {
    /// Creates the content of the target widget
    ///
    /// This includes the gesture detector and the container with the appropriate
    /// shape decoration that defines the target's visual appearance.
    final targetWidgetContent = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: size.height.abs(),
        width: size.width.abs(),
        margin: targetPadding,
        decoration: ShapeDecoration(
          shape: radius == null
              ? shapeBorder
              : RoundedRectangleBorder(borderRadius: radius!),
        ),
      ),
    );
    return Positioned(
      top: offset.dy - targetPadding.top,
      left: offset.dx - targetPadding.left,
      child: disableDefaultChildGestures
          ? IgnorePointer(
              child: targetWidgetContent,
            )
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: targetWidgetContent,
            ),
    );
  }
}
