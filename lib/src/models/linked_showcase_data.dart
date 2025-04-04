import 'package:flutter/widgets.dart';

/// This model is used to move linked showcase overlay data to parent
/// showcase to crop linked showcase rect
class LinkedShowcaseDataModel {
  const LinkedShowcaseDataModel({
    required this.rect,
    required this.radius,
    required this.overlayPadding,
    required this.isCircle,
  });

  final Rect rect;
  final EdgeInsets overlayPadding;
  final BorderRadius? radius;
  final bool isCircle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedShowcaseDataModel &&
          runtimeType == other.runtimeType &&
          rect == other.rect &&
          radius == other.radius &&
          overlayPadding == other.overlayPadding &&
          isCircle == other.isCircle;

  @override
  int get hashCode => Object.hash(
        rect,
        radius,
        overlayPadding,
        isCircle,
      );
}
