import 'package:flutter/material.dart';

class ActionsSettings {
  final double? containerWidth;
  final double? containerHeight;
  final Color? containerColor;
  final EdgeInsets? containerPadding;

  const ActionsSettings({
    this.containerWidth = 350,
    this.containerHeight = 40,
    this.containerColor = Colors.white,
    this.containerPadding = const EdgeInsets.only(top: 0.0),
  });
}
