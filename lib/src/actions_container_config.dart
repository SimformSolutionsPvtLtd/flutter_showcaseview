import 'package:flutter/material.dart';

class ActionsContainer {
  final double? containerWidth;
  final double? containerHeight;
  final Color? containerColor;
  final EdgeInsets? containerPadding;

  const ActionsContainer({
    this.containerWidth,
    this.containerHeight = 40,
    this.containerColor = Colors.white,
    this.containerPadding = const EdgeInsets.only(top: 5.0),
  });
}
