import 'package:flutter/material.dart';

class ToolTipActionButton extends StatelessWidget {
  const ToolTipActionButton({
    super.key,
    required this.action,
    required this.padding,
    required this.icon,
    required this.iconSize,
    required this.color,
  });

  final VoidCallback? action;
  final EdgeInsetsGeometry padding;
  final IconData icon;
  final double? iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: action,
      child: Padding(
        padding: padding,
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }
}
