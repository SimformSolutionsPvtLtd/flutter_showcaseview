import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionButtonIcon {
  const ActionButtonIcon.withIcon({
    required this.icon,
    this.padding,
  }) : assert(icon is Icon, 'Icon must be of type Icon');

  const ActionButtonIcon.withImageIcon({
    required this.icon,
    this.padding,
  }) : assert(icon is ImageIcon, 'Icon must be of type ImageIcon');

  final Widget icon;
  final EdgeInsets? padding;
}
