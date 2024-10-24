import 'package:flutter/material.dart';

class ToolTipActionButton extends StatelessWidget {
  const ToolTipActionButton({
    Key? key,
    required this.action,
    required this.padding,
    required this.widget,
    required this.opacity,
  }) : super(key: key);

  final VoidCallback? action;
  final EdgeInsetsGeometry padding;
  final Widget? widget;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: action,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: padding,
            child: widget,
          ),
        ),
      ),
    );
  }
}
