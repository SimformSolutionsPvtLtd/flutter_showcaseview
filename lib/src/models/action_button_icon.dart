import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionButtonIcon {
  const ActionButtonIcon({
    required Icon this.icon,
    this.padding,
  });

  const ActionButtonIcon.withImageIcon({
    required ImageIcon this.icon,
    this.padding,
  });

  final Widget icon;
  final EdgeInsets? padding;
}
