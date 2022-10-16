import 'package:flutter/material.dart';

import '../showcaseview.dart';

/// Tooltip Widget Nav
/// Shows tooltip navigation and index / count elements if the conditions are indicated.
class TooltipWidgetNav extends StatelessWidget {
  final GlobalKey globalKey;
  final bool showForwardBackNav;
  final bool showTipCountIndex;
  final Color? textColor;
  const TooltipWidgetNav({
    Key? key,
    required this.globalKey,
    required this.showForwardBackNav,
    required this.showTipCountIndex,
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
                GestureDetector(
                  behavior: HitTestBehavior.translucent,

                  // Disable if activeWidgetId (index) == 0
                  onTap: (isFirstTip)
                      ? null
                      : () {
                          ShowCaseWidget.of(globalKey.currentContext!)
                              .previous();
                        },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      color: (isFirstTip)
                          ? textColor?.withOpacity(0.3) ?? Colors.black26
                          : textColor,
                    ),
                  ),
                ),
              if (showTipCountIndex &&
                  ids != null &&
                  activeWidgetId != null) ...[
                const SizedBox(width: 4.0),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "${activeWidgetId + 1} / ${ids.length}",
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
              ],
              if (showForwardBackNav)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    ShowCaseWidget.of(globalKey.currentContext!).next();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: textColor,
                    ),
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
