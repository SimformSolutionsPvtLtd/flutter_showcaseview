/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:math';

import 'package:flutter/material.dart';

import 'enum.dart';
import 'get_position.dart';
import 'measure_size.dart';
import 'models/tooltip_action_config.dart';
import 'widget/action_widget.dart';
import 'widget/floating_action_widget.dart';
import 'widget/tooltip_slide_transition.dart';

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size screenSize;
  final String? title;
  final TextAlign? titleTextAlign;
  final String? description;
  final TextAlign? descriptionTextAlign;
  final AlignmentGeometry titleAlignment;
  final AlignmentGeometry descriptionAlignment;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final FloatingActionWidget? floatingActionWidget;
  final Color? tooltipBackgroundColor;
  final Color? textColor;
  final bool showArrow;
  final double? contentHeight;
  final double? contentWidth;
  final VoidCallback? onTooltipTap;
  final EdgeInsets? tooltipPadding;
  final Duration movingAnimationDuration;
  final bool disableMovingAnimation;
  final bool disableScaleAnimation;
  final BorderRadius? tooltipBorderRadius;
  final Duration scaleAnimationDuration;
  final Curve scaleAnimationCurve;
  final Alignment? scaleAnimationAlignment;
  final bool isTooltipDismissed;
  final TooltipPosition? tooltipPosition;
  final EdgeInsets? titlePadding;
  final EdgeInsets? descriptionPadding;
  final TextDirection? titleTextDirection;
  final TextDirection? descriptionTextDirection;
  final double toolTipSlideEndDistance;
  final double toolTipMargin;
  final TooltipActionConfig tooltipActionConfig;
  final List<Widget> tooltipActions;

  const ToolTipWidget({
    super.key,
    required this.position,
    required this.offset,
    required this.screenSize,
    required this.title,
    required this.description,
    required this.titleTextStyle,
    required this.descTextStyle,
    required this.container,
    required this.floatingActionWidget,
    required this.tooltipBackgroundColor,
    required this.textColor,
    required this.showArrow,
    required this.contentHeight,
    required this.contentWidth,
    required this.onTooltipTap,
    required this.movingAnimationDuration,
    required this.titleTextAlign,
    required this.descriptionTextAlign,
    required this.titleAlignment,
    required this.descriptionAlignment,
    this.tooltipPadding = const EdgeInsets.symmetric(vertical: 8),
    required this.disableMovingAnimation,
    required this.disableScaleAnimation,
    required this.tooltipBorderRadius,
    required this.scaleAnimationDuration,
    required this.scaleAnimationCurve,
    required this.toolTipMargin,
    this.scaleAnimationAlignment,
    this.isTooltipDismissed = false,
    this.tooltipPosition,
    this.titlePadding,
    this.descriptionPadding,
    this.titleTextDirection,
    this.descriptionTextDirection,
    this.toolTipSlideEndDistance = 7,
    required this.tooltipActionConfig,
    required this.tooltipActions,
  });

  @override
  State<ToolTipWidget> createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget>
    with TickerProviderStateMixin {
  Offset? position;

  bool isArrowUp = false;

  late final AnimationController _movingAnimationController;
  late final Animation<double> _movingAnimation;
  late final AnimationController _scaleAnimationController;
  late final Animation<double> _scaleAnimation;

  double tooltipWidth = 0;

  // This is Default height considered at the start of this package
  double tooltipHeight = 120;

  final _withArrowToolTipPadding = 16.0;
  final _withOutArrowToolTipPadding = 10.0;

  // To store Tooltip action size
  Size? _tooltipActionSize;

  final zeroPadding = EdgeInsets.zero;
  // This is used when [_tooltipActionSize] is already calculated and
  // on change of something we are recalculating the size of the widget
  bool isSizeRecalculating = false;

  TooltipPosition findPositionForContent(Offset position) {
    var height = tooltipHeight;
    final bottomPosition =
        position.dy + ((widget.position?.getHeight() ?? 0) / 2);
    final topPosition = position.dy - ((widget.position?.getHeight() ?? 0) / 2);
    final hasSpaceInTop = topPosition >= height;
    // TODO: need to update for flutter version > 3.8.X
    // ignore: deprecated_member_use
    final EdgeInsets viewInsets = EdgeInsets.fromWindowPadding(
      // ignore: deprecated_member_use
      WidgetsBinding.instance.window.viewInsets,
      // ignore: deprecated_member_use
      WidgetsBinding.instance.window.devicePixelRatio,
    );
    final double actualVisibleScreenHeight =
        widget.screenSize.height - viewInsets.bottom;
    final hasSpaceInBottom =
        (actualVisibleScreenHeight - bottomPosition) >= height;
    return widget.tooltipPosition ??
        (hasSpaceInTop && !hasSpaceInBottom
            ? TooltipPosition.top
            : TooltipPosition.bottom);
  }

  /// This will calculate the width and height of the tooltip
  void _getTooltipSize() {
    Size? toolTipActionSize;
    // if tooltip action is there this will calculate the height of that
    if (widget.tooltipActions.isNotEmpty) {
      final renderBox =
          _actionWidgetKey.currentContext?.findRenderObject() as RenderBox?;

      // if first frame is drawn then only we will be able to calculate the
      // size of the action widget
      if (renderBox != null && renderBox.hasSize) {
        toolTipActionSize = _tooltipActionSize = renderBox.size;
        isSizeRecalculating = false;
      } else if (_tooltipActionSize == null || renderBox == null) {
        // If first frame is not drawn then we will schedule the rebuild after
        // the first frame is drawn
        isSizeRecalculating = true;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (mounted) {
            _getTooltipSize();
            setState(() {});
          }
        });
        // If size is calculated once then we will wait for first frame
        // to draw before calculating anything as that may cause a flicker
        // in the tooltip
        if (_tooltipActionSize != null) {
          return;
        }
      }
    }
    final titleStyle = widget.titleTextStyle ??
        Theme.of(context)
            .textTheme
            .titleLarge!
            .merge(TextStyle(color: widget.textColor));
    final descriptionStyle = widget.descTextStyle ??
        Theme.of(context)
            .textTheme
            .titleSmall!
            .merge(TextStyle(color: widget.textColor));

    // This is to calculate the size of the title text
    // We have passed padding so we get the perfect width of the Title
    final titleSize = _textSize(
      widget.title,
      titleStyle,
      widget.titlePadding,
    );

    // This is to calculate the size of the description text
    // We have passed padding so we get the perfect width of the Title
    final descriptionSize = _textSize(
      widget.description,
      descriptionStyle,
      widget.descriptionPadding,
    );
    final titleLength = titleSize?.width ?? 0;
    final descriptionLength = descriptionSize?.width ?? 0;
    // This is padding we will have around the tooltip text
    final textPadding = (widget.tooltipPadding ?? zeroPadding).horizontal +
        max((widget.titlePadding ?? zeroPadding).horizontal,
            (widget.descriptionPadding ?? zeroPadding).horizontal);

    final maxTextWidth = max(titleLength, descriptionLength) + textPadding;
    var maxToolTipWidth = max(toolTipActionSize?.width ?? 0, maxTextWidth);

    final availableSpaceForToolTip =
        widget.screenSize.width - (2 * widget.toolTipMargin);

    // if Width is greater than available size which won't happen we will
    // adjust it to stay in available size
    if (maxToolTipWidth > availableSpaceForToolTip) {
      tooltipWidth = availableSpaceForToolTip;
    } else {
      // Final tooltip width will be text width + padding around the tool tip
      // Here we have not considered the margin around the tooltip as that
      // doesn't count in width of the tooltip
      if ((toolTipActionSize?.width ?? 0) >= maxTextWidth) {
        tooltipWidth = toolTipActionSize?.width ?? 0;
      } else {
        tooltipWidth = maxToolTipWidth;
      }
    }

    // If user has provided the width then we will use the maximum of action
    // width and user provided width
    if (widget.contentWidth != null) {
      tooltipWidth = max(toolTipActionSize?.width ?? 0, widget.contentWidth!);
    }

    final arrowHeight = widget.showArrow
        ? _withArrowToolTipPadding
        : _withOutArrowToolTipPadding;
    // To calculate the tooltip height
    // Text height + padding above and below of text  + arrow height + extra
    // space provided between target widget and tooltip widget  +
    // tooltip slide end distance + toolTip action Size

    tooltipHeight = (widget.tooltipPadding ?? zeroPadding).vertical +
        (titleSize?.height ?? 0) +
        (descriptionSize?.height ?? 0) +
        arrowHeight +
        widget.toolTipSlideEndDistance +
        (toolTipActionSize?.height ??
            widget.tooltipActionConfig.gapBetweenContentAndAction) +
        (widget.contentHeight ?? 0);
  }

  double? _getLeft() {
    if (widget.position != null) {
      final width =
          widget.container != null ? _customContainerWidth.value : tooltipWidth;
      double leftPositionValue = widget.position!.getCenter() - (width * 0.5);
      if ((leftPositionValue + width) > widget.screenSize.width) {
        return null;
      } else if ((leftPositionValue) < widget.toolTipMargin) {
        return widget.toolTipMargin;
      } else {
        return leftPositionValue;
      }
    }
    return null;
  }

  double? _getRight() {
    if (widget.position != null) {
      final width =
          widget.container != null ? _customContainerWidth.value : tooltipWidth;

      final left = _getLeft();
      if (left == null || (left + width) > widget.screenSize.width) {
        final rightPosition = widget.position!.getCenter() + (width * 0.5);

        return (rightPosition + width) > widget.screenSize.width
            ? widget.toolTipMargin
            : null;
      } else {
        return null;
      }
    }
    return null;
  }

  double _getSpace() {
    var space = widget.position!.getCenter() - (tooltipWidth / 2);
    if (space + tooltipWidth > widget.screenSize.width) {
      space = widget.screenSize.width - tooltipWidth - 8;
    } else if (space < (tooltipWidth / 2)) {
      space = 16;
    }
    return space;
  }

  double _getAlignmentX() {
    final calculatedLeft = _getLeft();
    var left = calculatedLeft == null
        ? 0
        : (widget.position!.getCenter() - calculatedLeft);
    var right = _getLeft() == null
        ? (widget.screenSize.width - widget.position!.getCenter()) -
            (_getRight() ?? 0)
        : 0;
    final containerWidth =
        widget.container != null ? _customContainerWidth.value : tooltipWidth;

    if (left != 0) {
      return (-1 + (2 * (left / containerWidth)));
    } else {
      return (1 - (2 * (right / containerWidth)));
    }
  }

  double _getAlignmentY() => -1;

  final GlobalKey _customContainerKey = GlobalKey();
  final GlobalKey _actionWidgetKey = GlobalKey();
  final ValueNotifier<double> _customContainerWidth = ValueNotifier<double>(1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.container != null &&
          _customContainerKey.currentContext != null &&
          _customContainerKey.currentContext?.size != null) {
        // TODO: Is it wise to call setState here? All it is doing is setting
        // a value in ValueNotifier which does not require a setState to refresh anyway.
        setState(() {
          _customContainerWidth.value =
              _customContainerKey.currentContext!.size!.width;
        });
      }
    });
    _movingAnimationController = AnimationController(
      duration: widget.movingAnimationDuration,
      vsync: this,
    );
    _movingAnimation = CurvedAnimation(
      parent: _movingAnimationController,
      curve: Curves.easeInOut,
    );
    _scaleAnimationController = AnimationController(
      duration: widget.scaleAnimationDuration,
      vsync: this,
      lowerBound: widget.disableScaleAnimation ? 1 : 0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleAnimationController,
      curve: widget.scaleAnimationCurve,
    );
    if (widget.disableScaleAnimation) {
      movingAnimationListener();
    } else {
      _scaleAnimationController
        ..addStatusListener((scaleAnimationStatus) {
          if (scaleAnimationStatus == AnimationStatus.completed) {
            movingAnimationListener();
          }
        })
        ..forward();
    }
    if (!widget.disableMovingAnimation) {
      _movingAnimationController.forward();
    }
  }

  void movingAnimationListener() {
    _movingAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _movingAnimationController.reverse();
      }
      if (_movingAnimationController.isDismissed) {
        if (!widget.disableMovingAnimation) {
          _movingAnimationController.forward();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If tooltip is dismissing then no need to recalculate the size and widgets
    if (!widget.isTooltipDismissed) {
      _getTooltipSize();
    }
  }

  @override
  void didUpdateWidget(covariant ToolTipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If tooltip is dismissing then no need to recalculate the size and widgets
    // If widget is same as before then also no need to calculate
    if (!widget.isTooltipDismissed && oldWidget.hashCode != hashCode) {
      _getTooltipSize();
    }
  }

  @override
  void dispose() {
    _movingAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: maybe all this calculation doesn't need to run here. Maybe all or some of it can be moved outside?
    position = widget.offset;
    final contentOrientation = findPositionForContent(position!);
    final contentOffsetMultiplier =
        contentOrientation == TooltipPosition.bottom ? 1.0 : -1.0;
    isArrowUp = contentOffsetMultiplier == 1.0;

    final screenSize = MediaQuery.of(context).size;

    var contentY = isArrowUp
        ? widget.position!.getBottom() + (contentOffsetMultiplier * 3)
        : widget.position!.getTop() + (contentOffsetMultiplier * 3);

    // if tooltip is going out of screen in bottom this will ensure it is
    // visible above the widget
    if (contentY + tooltipHeight >= screenSize.height && isArrowUp) {
      contentY = screenSize.height - tooltipHeight;
    }

    final num contentFractionalOffset =
        contentOffsetMultiplier.clamp(-1.0, 0.0);

    var paddingTop = isArrowUp ? _withArrowToolTipPadding : 0.0;
    var paddingBottom = isArrowUp ? 0.0 : _withArrowToolTipPadding;

    if (!widget.showArrow) {
      paddingTop = _withOutArrowToolTipPadding;
      paddingBottom = _withOutArrowToolTipPadding;
    }

    const arrowWidth = 18.0;
    const arrowHeight = 9.0;

    if (!widget.disableScaleAnimation && widget.isTooltipDismissed) {
      _scaleAnimationController.reverse();
    }

    if (widget.container == null) {
      final defaultToolTipWidget = Positioned(
        top: contentY,
        left: _getLeft(),
        right: _getRight(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: widget.scaleAnimationAlignment ??
              Alignment(
                _getAlignmentX(),
                _getAlignmentY(),
              ),
          child: FractionalTranslation(
            translation: Offset(0.0, contentFractionalOffset as double),
            child: ToolTipSlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: Offset(
                  0,
                  widget.toolTipSlideEndDistance * contentOffsetMultiplier,
                ),
              ).animate(_movingAnimation),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    if (widget.tooltipActions.isNotEmpty &&
                        widget.tooltipActionConfig.position.isOutside &&
                        !isArrowUp)
                      _getActionWidget(),
                    Padding(
                      padding: widget.showArrow
                          ? EdgeInsets.only(
                              top: paddingTop - (isArrowUp ? arrowHeight : 0),
                              bottom:
                                  paddingBottom - (isArrowUp ? 0 : arrowHeight),
                            )
                          : zeroPadding,
                      child: Stack(
                        alignment: isArrowUp
                            ? Alignment.topLeft
                            : _getLeft() == null
                                ? Alignment.bottomRight
                                : Alignment.bottomLeft,
                        children: [
                          // This widget is used for calculation of the action
                          // widget size and it will be removed once the size
                          // is calculated
                          if (isSizeRecalculating) _getOffstageActionWidget,
                          if (widget.showArrow)
                            Positioned(
                              left: _getArrowLeft(arrowWidth),
                              right: _getArrowRight(arrowWidth),
                              child: CustomPaint(
                                painter: _Arrow(
                                  strokeColor: widget.tooltipBackgroundColor!,
                                  strokeWidth: 10,
                                  paintingStyle: PaintingStyle.fill,
                                  isUpArrow: isArrowUp,
                                ),
                                child: const SizedBox(
                                  height: arrowHeight,
                                  width: arrowWidth,
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: isArrowUp ? arrowHeight - 1 : 0,
                              bottom: isArrowUp ? 0 : arrowHeight - 1,
                            ),
                            child: ClipRRect(
                              borderRadius: widget.tooltipBorderRadius ??
                                  BorderRadius.circular(8.0),
                              child: GestureDetector(
                                onTap: widget.onTooltipTap,
                                child: Container(
                                  width: tooltipWidth,
                                  padding: widget.tooltipPadding?.copyWith(
                                    left: 0,
                                    right: 0,
                                  ),
                                  color: widget.tooltipBackgroundColor,
                                  child: Column(
                                    children: <Widget>[
                                      if (widget.title != null)
                                        Align(
                                          alignment: widget.titleAlignment,
                                          child: Padding(
                                            padding: (widget.titlePadding ??
                                                    zeroPadding)
                                                .add(
                                              EdgeInsets.only(
                                                left: widget
                                                        .tooltipPadding?.left ??
                                                    0,
                                                right: widget.tooltipPadding
                                                        ?.right ??
                                                    0,
                                              ),
                                            ),
                                            child: Text(
                                              widget.title!,
                                              textAlign: widget.titleTextAlign,
                                              textDirection:
                                                  widget.titleTextDirection,
                                              style: widget.titleTextStyle ??
                                                  Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .merge(
                                                        TextStyle(
                                                          color:
                                                              widget.textColor,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ),
                                      if (widget.description != null)
                                        Align(
                                          alignment:
                                              widget.descriptionAlignment,
                                          child: Padding(
                                            padding:
                                                (widget.descriptionPadding ??
                                                        zeroPadding)
                                                    .add(
                                              EdgeInsets.only(
                                                left: widget
                                                        .tooltipPadding?.left ??
                                                    0,
                                                right: widget.tooltipPadding
                                                        ?.right ??
                                                    0,
                                              ),
                                            ),
                                            child: Text(
                                              widget.description!,
                                              textAlign:
                                                  widget.descriptionTextAlign,
                                              textDirection: widget
                                                  .descriptionTextDirection,
                                              style: widget.descTextStyle ??
                                                  Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .merge(
                                                        TextStyle(
                                                          color:
                                                              widget.textColor,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ),
                                      if (widget.tooltipActions.isNotEmpty &&
                                          widget.tooltipActionConfig.position
                                              .isInside &&
                                          _tooltipActionSize != null)
                                        _getActionWidget(insideWidget: true),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.tooltipActions.isNotEmpty &&
                            widget.tooltipActionConfig.position.isOutside &&
                            isArrowUp ||
                        (_tooltipActionSize == null && isArrowUp))
                      _getActionWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      if (widget.floatingActionWidget == null) {
        return defaultToolTipWidget;
      } else {
        return Stack(
          fit: StackFit.expand,
          children: [
            defaultToolTipWidget,
            widget.floatingActionWidget!,
          ],
        );
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned(
          left: _getSpace(),
          top: contentY,
          child: FractionalTranslation(
            translation: Offset(0.0, contentFractionalOffset as double),
            child: ToolTipSlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: Offset(
                  0,
                  widget.toolTipSlideEndDistance * contentOffsetMultiplier,
                ),
              ).animate(_movingAnimation),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: widget.onTooltipTap,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: paddingTop,
                      bottom: paddingBottom,
                    ),
                    color: Colors.transparent,
                    child: Center(
                      child: Stack(
                        children: [
                          // This widget is used for calculation of the action
                          // widget size and it will be removed once the size
                          // is calculated
                          // We have kept it in colum because if we put is
                          // outside in the stack then it will take whole
                          // screen size and width calculation will fail
                          if (isSizeRecalculating) _getOffstageActionWidget,

                          // This offset is used to make animation smoother
                          // when there is big action widget which make
                          // the tool tip to change it's position
                          Offstage(
                            offstage: isSizeRecalculating,
                            child: SizedBox(
                              width: tooltipWidth,
                              child: Column(
                                children: [
                                  if (widget.tooltipActions.isNotEmpty &&
                                      !isArrowUp)
                                    _getActionWidget(),
                                  MeasureSize(
                                    onSizeChange: onSizeChange,
                                    child: widget.container,
                                  ),
                                  if (widget.tooltipActions.isNotEmpty &&
                                      isArrowUp)
                                    _getActionWidget(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.floatingActionWidget != null) widget.floatingActionWidget!,
      ],
    );
  }

  Widget get _getOffstageActionWidget => Offstage(
        child: ActionWidget(
          key: _actionWidgetKey,
          outSidePadding: widget.tooltipActionConfig.position.isInside &&
                  widget.container == null
              ? EdgeInsets.only(
                  left: widget.tooltipPadding?.left ?? 0,
                  right: widget.tooltipPadding?.right ?? 0,
                )
              : zeroPadding,
          tooltipActionConfig: widget.tooltipActionConfig,
          alignment: widget.tooltipActionConfig.alignment,
          width: null,
          crossAxisAlignment: widget.tooltipActionConfig.crossAxisAlignment,
          isArrowUp: true,
          children: widget.tooltipActions,
        ),
      );

  Widget _getActionWidget({
    bool insideWidget = false,
  }) {
    return ActionWidget(
      tooltipActionConfig: widget.tooltipActionConfig,
      outSidePadding: (insideWidget)
          ? EdgeInsets.only(
              left: widget.tooltipPadding?.left ?? 0,
              right: widget.tooltipPadding?.right ?? 0,
            )
          : zeroPadding,
      alignment: widget.tooltipActionConfig.alignment,
      crossAxisAlignment: widget.tooltipActionConfig.crossAxisAlignment,
      width: _tooltipActionSize == null ? null : tooltipWidth,
      isArrowUp: insideWidget || isArrowUp,
      children: widget.tooltipActions,
    );
  }

  void onSizeChange(Size? size) {
    var tempPos = position;
    tempPos = Offset(
      position?.dx ?? 0,
      position?.dy ?? 0 + (size ?? Size.zero).height,
    );
    if (mounted) {
      setState(() => position = tempPos);
    }
  }

  Size? _textSize(String? text, TextStyle style, EdgeInsets? padding) {
    if (text == null) {
      return null;
    }

    /// Available space for text will be calculated like this:
    /// screen size - padding around the Text - padding around tooltip widget
    /// - 2(margin provided to tooltip from the end of the screen)
    /// We have calculated this to get the exact amount of width this text can
    /// take so height can be calculated precisely for text
    final availableSpaceForText =
        (widget.position?.screenWidth ?? MediaQuery.of(context).size.width) -
            (padding ?? zeroPadding).horizontal -
            (widget.tooltipPadding ?? zeroPadding).horizontal -
            (2 * widget.toolTipMargin);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),

      // TODO: replace this once we support sdk v3.12.
      // ignore: deprecated_member_use
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      textDirection: TextDirection.ltr,
      textWidthBasis: TextWidthBasis.longestLine,
    )..layout(
        // This is used to make maintain the text in available space so height
        // and width calculation will be accurate
        maxWidth: availableSpaceForText,
      );
    return textPainter.size;
  }

  double? _getArrowLeft(double arrowWidth) {
    final left = _getLeft();
    if (left == null) return null;
    return (widget.position!.getCenter() - (arrowWidth / 2) - left);
  }

  double? _getArrowRight(double arrowWidth) {
    if (_getLeft() != null) return null;
    return (widget.screenSize.width - widget.position!.getCenter()) -
        (_getRight() ?? 0) -
        (arrowWidth / 2);
  }
}

class _Arrow extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final bool isUpArrow;
  final Paint _paint;

  _Arrow({
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
    this.isUpArrow = true,
  }) : _paint = Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..style = paintingStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(getTrianglePath(size.width, size.height), _paint);
  }

  Path getTrianglePath(double x, double y) {
    if (isUpArrow) {
      return Path()
        ..moveTo(0, y)
        ..lineTo(x / 2, 0)
        ..lineTo(x, y)
        ..lineTo(0, y);
    }
    return Path()
      ..moveTo(0, 0)
      ..lineTo(x, 0)
      ..lineTo(x / 2, y)
      ..lineTo(0, 0);
  }

  @override
  bool shouldRepaint(covariant _Arrow oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
