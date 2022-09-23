import 'package:flutter/material.dart';

import '../showcaseview.dart';

/// Tooltip Widget Nav
/// Shows tooltip navigation and index / count elements if the conditions are indicated.
class TooltipWidgetNav extends StatelessWidget {
  final GlobalKey globalKey;
  final bool showForwardBackNav;
  final bool showTipCountIndex;
  final bool showEndIcon;
  final Color? textColor;
  const TooltipWidgetNav({
    Key? key,
    required this.globalKey,
    required this.showForwardBackNav,
    required this.showTipCountIndex,
    required this.showEndIcon,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var ids = ShowCaseWidget.of(globalKey.currentContext!).ids;
    var activeWidgetId =
        ShowCaseWidget.of(globalKey.currentContext!).activeWidgetId;
    bool isFirstTip = activeWidgetId == 0;

    if (showForwardBackNav || showTipCountIndex) {
      return Column(
        children: [
          // const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showForwardBackNav)
                IconButton(
                  // Disable if activeWidgetId (index) == 0
                  onPressed: (isFirstTip)
                      ? null
                      : () {
                          ShowCaseWidget.of(globalKey.currentContext!)
                              .previous();
                        },
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: (isFirstTip) ? null : textColor,
                  ),
                ),
              if (showTipCountIndex &&
                  ids != null &&
                  activeWidgetId != null) ...[
                const SizedBox(width: 4.0),
                Text("${activeWidgetId + 1} / ${ids.length}"),
                const SizedBox(width: 4.0),
              ],
              if (showForwardBackNav)
                IconButton(
                  onPressed: () {
                    ShowCaseWidget.of(globalKey.currentContext!).next();
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    color: textColor,
                  ),
                ),
            ],
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}
