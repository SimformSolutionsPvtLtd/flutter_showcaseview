import 'package:flutter/material.dart';

import '../showcaseview.dart';
import 'utilities/_showcase_context_provider.dart';

class ShowCaseDefaultActions extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final double? dividerThickness;
  final Color verticalDividerColor;

  final ActionButtonConfig next;
  final ActionButtonConfig previous;
  final ActionButtonConfig stop;

  final GlobalKey _keyRow = GlobalKey();

  ShowCaseDefaultActions({
    Key? key,
    this.next = const ActionButtonConfig(),
    this.previous = const ActionButtonConfig(),
    this.stop = const ActionButtonConfig(),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.dividerThickness = 1.0,
    this.verticalDividerColor = const Color(0xffee5366),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showcaseContext = ShowcaseContextProvider.of(context)?.context;

    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      verticalDirection: verticalDirection,
      crossAxisAlignment: crossAxisAlignment,
      key: _keyRow,
      textBaseline: textBaseline,
      textDirection: textDirection,
      children: [
        if (previous.buttonVisible)
          _getButtonWidget(
            previous,
            showcaseContext,
            previous.text ?? 'Previous',
            previous.callback ??
                () {
                  if (showcaseContext != null &&
                      ShowCaseWidget.of(showcaseContext)?.ids != null) {
                    ShowCaseWidget.of(showcaseContext)?.prev();
                  }
                },
          ),
        if (previous.buttonVisible && stop.buttonVisible ||
            previous.buttonVisible && next.buttonVisible)
          _getVerticalDivider(),
        if (stop.buttonVisible)
          _getButtonWidget(
            stop,
            showcaseContext,
            stop.text ?? 'Stop',
            stop.callback ??
                () {
                  if (showcaseContext != null &&
                      ShowCaseWidget.of(showcaseContext)!.ids != null) {
                    ShowCaseWidget.of(showcaseContext)!.dismiss();
                  }
                },
          ),
        if (stop.buttonVisible && next.buttonVisible) _getVerticalDivider(),
        if (next.buttonVisible)
          _getButtonWidget(
            next,
            showcaseContext,
            next.text ?? 'Next',
            next.callback ??
                () {
                  if (showcaseContext != null &&
                      ShowCaseWidget.of(showcaseContext)!.ids != null) {
                    ShowCaseWidget.of(showcaseContext)!.completed(
                        ShowCaseWidget.of(showcaseContext)!.ids![
                            ShowCaseWidget.of(showcaseContext)!
                                    .activeWidgetId ??
                                0]);
                  }
                },
          ),
      ],
    );
  }

  Widget _getVerticalDivider() {
    return VerticalDivider(
      width: 1.0,
      thickness: dividerThickness,
      color: verticalDividerColor,
    );
  }

  Widget _getButtonWidget(ActionButtonConfig actionConfig,
      BuildContext? showcaseContext, String buttonText, VoidCallback onClick) {
    return Expanded(
      child: Directionality(
        textDirection: actionConfig.textDirection,
        child: TextButton.icon(
          label: actionConfig.buttonTextVisible
              ? Text(
                  buttonText,
                  style: TextStyle(color: actionConfig.textColor),
                )
              : SizedBox.shrink(),
          icon: actionConfig.icon ?? SizedBox.shrink(),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  actionConfig.textButtonBgColor)),
          onPressed: onClick,
        ),
      ),
    );
  }

  double? _getDefaultWidth() {
    return _keyRow.currentContext != null
        ? (_keyRow.currentContext!.findRenderObject() as RenderBox).size.width
        : null;
  }
}

class ActionButtonConfig {
  /// button text
  final String? text;

  /// button icon or image
  final Widget? icon;

  /// Color of button text.
  final Color textColor;

  /// Color of button background.
  final Color textButtonBgColor;

  /// Callback on button tap.
  ///
  /// Note: Default callback will be overridden by this one.
  final VoidCallback? callback;

  /// Defines visibility of button.
  final bool buttonVisible;

  /// Defines visibility of button.
  final bool buttonTextVisible;

  /// Defines icon and text direction.
  final TextDirection textDirection;

  const ActionButtonConfig({
    this.text,
    this.icon,
    this.textColor = const Color(0xffee5366),
    this.textButtonBgColor = Colors.transparent,
    this.callback,
    this.buttonVisible = true,
    this.buttonTextVisible = true,
    this.textDirection = TextDirection.ltr,
  });
}
