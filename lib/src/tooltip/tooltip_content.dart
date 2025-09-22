import 'package:flutter/material.dart';

import '../models/tooltip_action_config.dart';
import '../widget/action_widget.dart';
import '../widget/default_tooltip_text_widget.dart';

class ToolTipContent extends StatelessWidget {
  /// Builds the tooltip content layout based on action position configuration.
  ///
  /// Supports following layouts:
  /// - Vertical layout (actions at bottom) for [TooltipActionPosition.inside]
  /// - Horizontal layout (actions on left/right) for
  /// [TooltipActionPosition.insideLeft] and [TooltipActionPosition.insideRight]
  const ToolTipContent({
    required this.description,
    required this.titleTextAlign,
    required this.descriptionTextAlign,
    required this.titleAlignment,
    required this.descriptionAlignment,
    required this.tooltipActionConfig,
    required this.tooltipActions,
    required this.textColor,
    this.title,
    this.titleTextStyle,
    this.descTextStyle,
    this.titlePadding,
    this.descriptionPadding,
    this.titleTextDirection,
    this.descriptionTextDirection,
    super.key,
  }) : assert(
          title != null || description != null,
          'Either title or description must be provided',
        );

  final String? title;
  final TextAlign titleTextAlign;
  final String? description;
  final TextAlign descriptionTextAlign;
  final AlignmentGeometry titleAlignment;
  final AlignmentGeometry descriptionAlignment;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Color textColor;
  final EdgeInsets? titlePadding;
  final EdgeInsets? descriptionPadding;
  final TextDirection? titleTextDirection;
  final TextDirection? descriptionTextDirection;
  final TooltipActionConfig tooltipActionConfig;
  final List<Widget> tooltipActions;

  @override
  Widget build(BuildContext context) {
    final shouldShowActionsInside =
        tooltipActions.isNotEmpty && tooltipActionConfig.position.isInside;
    final textTheme = Theme.of(context).textTheme;

    // Build title widget
    Widget? titleWidget;
    if (title case final title?) {
      titleWidget = DefaultTooltipTextWidget(
        padding: titlePadding ?? EdgeInsets.zero,
        text: title,
        textAlign: titleTextAlign,
        alignment: titleAlignment,
        textColor: textColor,
        textDirection: titleTextDirection,
        textStyle: titleTextStyle ??
            textTheme.titleLarge?.merge(TextStyle(color: textColor)),
      );
    }

    // Build description widget
    Widget? descriptionWidget;
    if (description case final desc?) {
      descriptionWidget = DefaultTooltipTextWidget(
        padding: descriptionPadding ?? EdgeInsets.zero,
        text: desc,
        textAlign: descriptionTextAlign,
        alignment: descriptionAlignment,
        textColor: textColor,
        textDirection: descriptionTextDirection,
        textStyle: descTextStyle ??
            textTheme.titleSmall?.merge(TextStyle(color: textColor)),
      );
    }

    // Build action widget
    Widget? actionWidget;
    if (shouldShowActionsInside) {
      actionWidget = ActionWidget(
        tooltipActionConfig: tooltipActionConfig,
        children: tooltipActions,
      );
    }

    // For vertical action positioning (default), use Column layout
    final contentColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (titleWidget != null) titleWidget,
        if (descriptionWidget != null) descriptionWidget,
        if (actionWidget != null &&
            tooltipActionConfig.position.isInsideVertical)
          actionWidget,
      ],
    );

    // If no horizontal action positioning, return vertical layout
    if (actionWidget == null ||
        !tooltipActionConfig.position.isInsideHorizontal) {
      return contentColumn;
    }

    // For horizontal action positioning, use Row layout
    final gap = SizedBox(
      width: tooltipActionConfig.gapBetweenContentAndAction,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tooltipActionConfig.position.isInsideLeft) ...[
          actionWidget,
          gap,
        ],
        Flexible(child: contentColumn),
        if (tooltipActionConfig.position.isInsideRight) ...[
          gap,
          actionWidget,
        ],
      ],
    );
  }
}
