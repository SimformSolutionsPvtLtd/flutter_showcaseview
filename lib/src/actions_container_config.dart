import 'package:flutter/material.dart';

class ActionsSettings {
  final double? containerWidth;
  final double? containerHeight;
  final Color? containerColor;
  final EdgeInsets? containerPadding;

  const ActionsSettings({
    this.containerWidth,
    this.containerHeight = 40,
    this.containerColor = Colors.white,
    this.containerPadding = const EdgeInsets.only(top: 5.0),
  });
}
