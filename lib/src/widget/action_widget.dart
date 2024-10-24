import 'package:flutter/material.dart';

import '../../showcaseview.dart';

class ActionWidget extends StatelessWidget {
  const ActionWidget({
    super.key,
    required this.children,
    required this.tooltipActionConfig,
    required this.alignment,
    required this.crossAxisAlignment,
    required this.isArrowUp,
    this.outSidePadding = EdgeInsets.zero,
    this.width,
  });

  final TooltipActionConfig tooltipActionConfig;
  final List<Widget> children;
  final double? width;
  final MainAxisAlignment alignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets outSidePadding;
  final bool isArrowUp;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.only(
          top: isArrowUp ? tooltipActionConfig.gapBetweenContentAndAction : 0.0,
          bottom:
              !isArrowUp ? tooltipActionConfig.gapBetweenContentAndAction : 0.0,
        ).add(outSidePadding),
        child: Row(
          mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment:
              width == null ? MainAxisAlignment.start : alignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      ),
    );
  }
}
