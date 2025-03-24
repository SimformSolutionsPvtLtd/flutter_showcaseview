import 'package:flutter/material.dart';

import '../../showcaseview.dart';

class ActionWidget extends StatelessWidget {
  const ActionWidget({
    super.key,
    required this.children,
    required this.tooltipActionConfig,
    required this.alignment,
    required this.crossAxisAlignment,
    this.outsidePadding = EdgeInsets.zero,
    this.width,
  });

  final TooltipActionConfig tooltipActionConfig;
  final List<Widget> children;
  final double? width;
  final MainAxisAlignment alignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets outsidePadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: outsidePadding,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: alignment,
          crossAxisAlignment: crossAxisAlignment,
          textBaseline: tooltipActionConfig.textBaseline,
          children: children,
        ),
      ),
    );
  }
}
