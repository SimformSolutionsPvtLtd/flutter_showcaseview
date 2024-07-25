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

import '../showcaseview.dart';
import 'get_position.dart';
import 'measure_size.dart';
import 'widget/tooltip_slide_transition.dart';

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size screenSize;
  final String? title;
  final TextAlign? titleAlignment;
  final String? description;
  final TextAlign? descriptionAlignment;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
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
  List<TooltipActionButton>? tooltipActions;
  final TextDirection? titleTextDirection;
  final TextDirection? descriptionTextDirection;
  final double toolTipSlideEndDistance;
  final double toolTipMargin;
  final ShowCaseWidgetState showCaseState;
  TooltipActionConfig tooltipActionConfig;

  ToolTipWidget({
    super.key,
    required this.position,
    required this.offset,
    required this.screenSize,
    required this.title,
    required this.titleAlignment,
    required this.description,
    required this.titleTextStyle,
    required this.descTextStyle,
    required this.container,
    required this.tooltipBackgroundColor,
    required this.textColor,
    required this.showArrow,
    required this.contentHeight,
    required this.contentWidth,
    required this.onTooltipTap,
    required this.movingAnimationDuration,
    required this.descriptionAlignment,
    this.tooltipPadding = const EdgeInsets.symmetric(vertical: 8),
    required this.disableMovingAnimation,
    required this.disableScaleAnimation,
    required this.tooltipBorderRadius,
    required this.scaleAnimationDuration,
    required this.scaleAnimationCurve,
    required this.showCaseState,
    required this.tooltipActionConfig,
    required this.toolTipMargin,
    this.scaleAnimationAlignment,
    this.isTooltipDismissed = false,
    this.tooltipPosition,
    this.titlePadding,
    this.descriptionPadding,
    this.tooltipActions,
    this.titleTextDirection,
    this.descriptionTextDirection,
    this.toolTipSlideEndDistance = 7,
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
  double tooltipHeight = 0;
  double tooltipScreenEdgePadding = 20;
  double tooltipTextPadding = 15;
  double actionWidgetHeight = 0.0;

  Size? tooltipActionSize;
  final GlobalKey tooltipActionKey = GlobalKey();
  bool isOffstage = true;

  void setTooltipActionWidth(size) => tooltipActionSize ??= size;

  TooltipPosition findPositionForContent(Offset position) {
    var height = tooltipHeight;
    height = widget.contentHeight ?? height;
    final bottomPosition = position.dy +
        ((widget.position?.getHeight() ?? 0) * 0.5) +
        actionWidgetHeight;
    final topPosition = position.dy -
        ((widget.position?.getHeight() ?? 0) * 0.5) -
        actionWidgetHeight;
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

  void _getTooltipWidth() {
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
    final titleLength = widget.title == null
        ? 0
        : _textSize(widget.title!, titleStyle).width +
            widget.tooltipPadding!.right +
            widget.tooltipPadding!.left +
            (widget.titlePadding?.right ?? 0) +
            (widget.titlePadding?.left ?? 0);
    final descriptionLength = widget.description == null
        ? 0
        : (_textSize(widget.description!, descriptionStyle).width +
            widget.tooltipPadding!.right +
            widget.tooltipPadding!.left +
            (widget.descriptionPadding?.right ?? 0) +
            (widget.descriptionPadding?.left ?? 0));
    var maxTextWidth = max(titleLength, descriptionLength);
    if (maxTextWidth > widget.screenSize.width - tooltipScreenEdgePadding) {
      tooltipWidth = widget.screenSize.width - tooltipScreenEdgePadding;
    } else {
      tooltipWidth = maxTextWidth + 0;
    }
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
    var space = widget.position!.getCenter() - (widget.contentWidth! * 0.5);
    if (space + widget.contentWidth! > widget.screenSize.width) {
      space = widget.screenSize.width - widget.contentWidth! - 8;
    } else if (space < (widget.contentWidth! * 0.5)) {
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
  final ValueNotifier<double> _customContainerWidth = ValueNotifier<double>(1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getWidgetSize();
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
    _getTooltipWidth();
  }

  @override
  void didUpdateWidget(covariant ToolTipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getTooltipWidth();
  }

  @override
  void dispose() {
    _movingAnimationController.dispose();
    _scaleAnimationController.dispose();

    super.dispose();
  }

  void _getWidgetSize() {
    if (tooltipActionSize == null) {
      final renderBox =
          tooltipActionKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        tooltipActionSize = renderBox.size;
        setState(() => isOffstage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: maybe all this calculation doesn't need to run here. Maybe all or some of it can be moved outside?
    position = widget.offset;
    final contentOrientation = findPositionForContent(position!);
    final contentOffsetMultiplier =
        contentOrientation == TooltipPosition.bottom ? 1.0 : -1.0;
    isArrowUp = contentOffsetMultiplier == 1.0;

    final contentY = isArrowUp
        ? widget.position!.getBottom() + (contentOffsetMultiplier * 3)
        : widget.position!.getTop() + (contentOffsetMultiplier * 3);

    final num contentFractionalOffset =
        contentOffsetMultiplier.clamp(-1.0, 0.0);

    var paddingTop = isArrowUp ? 22.0 : 0.0;
    var paddingBottom = isArrowUp ? 0.0 : 22.0;

    if (!widget.showArrow) {
      paddingTop = 10;
      paddingBottom = 10;
    }

    const arrowWidth = 18.0;
    const arrowHeight = 9.0;

    if (!widget.disableScaleAnimation && widget.isTooltipDismissed) {
      _scaleAnimationController.reverse();
    }

    final tooltipActionButtonAlignment =
        widget.tooltipActionConfig.alignment.alignment;
    final tooltipAdaptiveWidth = _getTooltipAdaptiveWidth();
    final tooltipActionsList = _getActionWidgets();

    Widget tooltipActionWidget = Offstage(
      offstage: true,
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          key: tooltipActionKey,
          padding: widget.tooltipActionConfig.padding ?? EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: tooltipActionButtonAlignment,
            children: tooltipActionsList,
          ),
        ),
      ),
    );

    if (widget.container == null) {
      if (isOffstage) {
        return tooltipActionWidget;
      } else {
        return Positioned(
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
                  child: MeasureSize(
                    onSizeChange: onTooltipSizeChanged,
                    child: Container(
                      padding: widget.showArrow
                          ? EdgeInsets.only(
                              top: paddingTop - (isArrowUp ? arrowHeight : 0),
                              bottom:
                                  paddingBottom - (isArrowUp ? 0 : arrowHeight),
                            )
                          : EdgeInsets.symmetric(
                              vertical: paddingTop,
                            ),
                      child: SizedBox(
                        width: tooltipAdaptiveWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isArrowUp &&
                                widget.tooltipActionConfig.position ==
                                    TooltipActionPosition.outside &&
                                tooltipActionsList.isNotEmpty) ...[
                              Container(
                                width: tooltipAdaptiveWidth,
                                padding: widget.tooltipActionConfig.padding ??
                                    EdgeInsets.zero,
                                child: Row(
                                  mainAxisAlignment:
                                      tooltipActionButtonAlignment,
                                  children: tooltipActionsList,
                                ),
                              ),
                              SizedBox(
                                height: widget.tooltipActionConfig
                                    .gapBetweenContentAndAction,
                              ),
                            ],
                            Stack(
                              alignment: isArrowUp
                                  ? Alignment.topLeft
                                  : _getLeft() == null
                                      ? Alignment.bottomRight
                                      : Alignment.bottomLeft,
                              children: [
                                if (widget.showArrow)
                                  Positioned(
                                    left: _getArrowLeft(arrowWidth),
                                    right: _getArrowRight(arrowWidth),
                                    child: CustomPaint(
                                      painter: _Arrow(
                                        strokeColor:
                                            widget.tooltipBackgroundColor!,
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
                                    top: widget.showArrow && isArrowUp
                                        ? arrowHeight - 1
                                        : 0,
                                    bottom: widget.showArrow && !isArrowUp
                                        ? arrowHeight - 1
                                        : 0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: widget.tooltipBorderRadius ??
                                        BorderRadius.circular(8.0),
                                    child: GestureDetector(
                                      onTap: widget.onTooltipTap,
                                      child: Container(
                                        padding: widget.tooltipPadding,
                                        color: widget.tooltipBackgroundColor,
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                widget.title != null
                                                    ? CrossAxisAlignment.start
                                                    : CrossAxisAlignment.center,
                                            children: <Widget>[
                                              if (widget.title != null)
                                                SizedBox(
                                                  width: tooltipAdaptiveWidth,
                                                  child: Padding(
                                                    padding:
                                                        widget.titlePadding ??
                                                            EdgeInsets.zero,
                                                    child: Text(
                                                      widget.title ?? '',
                                                      textAlign:
                                                          widget.titleAlignment,
                                                      textDirection: widget
                                                          .titleTextDirection,
                                                      style: widget
                                                              .titleTextStyle ??
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleLarge
                                                              ?.merge(
                                                                TextStyle(
                                                                  color: widget
                                                                      .textColor,
                                                                ),
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              SizedBox(
                                                width: tooltipAdaptiveWidth,
                                                child: Padding(
                                                  padding: widget
                                                          .descriptionPadding ??
                                                      EdgeInsets.zero,
                                                  child: Text(
                                                    widget.description!,
                                                    textAlign: widget
                                                        .descriptionAlignment,
                                                    textDirection: widget
                                                        .descriptionTextDirection,
                                                    style:
                                                        widget.descTextStyle ??
                                                            Theme.of(context)
                                                                .textTheme
                                                                .titleSmall
                                                                ?.merge(
                                                                  TextStyle(
                                                                    color: widget
                                                                        .textColor,
                                                                  ),
                                                                ),
                                                  ),
                                                ),
                                              ),
                                              if (widget.tooltipActionConfig
                                                          .position ==
                                                      TooltipActionPosition
                                                          .inside &&
                                                  tooltipActionsList
                                                      .isNotEmpty) ...[
                                                SizedBox(
                                                  height: widget
                                                      .tooltipActionConfig
                                                      .gapBetweenContentAndAction,
                                                ),
                                                Padding(
                                                  padding: widget
                                                          .tooltipActionConfig
                                                          .padding ??
                                                      EdgeInsets.zero,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        tooltipActionButtonAlignment,
                                                    children:
                                                        tooltipActionsList,
                                                  ),
                                                ),
                                              ]
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isArrowUp &&
                                widget.tooltipActionConfig.position ==
                                    TooltipActionPosition.outside &&
                                tooltipActionsList.isNotEmpty) ...[
                              SizedBox(
                                height: widget.tooltipActionConfig
                                    .gapBetweenContentAndAction,
                              ),
                              Container(
                                width: tooltipAdaptiveWidth,
                                padding: widget.tooltipActionConfig.padding ??
                                    EdgeInsets.zero,
                                child: Row(
                                  mainAxisAlignment:
                                      tooltipActionButtonAlignment,
                                  children: tooltipActionsList,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    if (isOffstage) {
      return tooltipActionWidget;
    } else {
      return Stack(
        children: <Widget>[
          Positioned(
            left: _getSpace(),
            top: contentY - (10 * contentOffsetMultiplier),
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
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: widget.onTooltipTap,
                      child: Container(
                        padding: EdgeInsets.only(
                          top: paddingTop,
                          bottom: paddingBottom,
                        ),
                        width: widget.contentWidth,
                        color: Colors.transparent,
                        child: Center(
                          child: MeasureSize(
                            onSizeChange: onSizeChange,
                            child: Column(
                              children: [
                                widget.container!,
                                if (tooltipActionsList.isNotEmpty)
                                  SizedBox(
                                    height: widget.tooltipActionConfig
                                        .gapBetweenContentAndAction,
                                  ),
                                SizedBox(
                                  width: max(widget.contentWidth ?? 0,
                                      tooltipActionSize?.width ?? 0),
                                  child: (tooltipActionsList.isNotEmpty)
                                      ? SizedBox(
                                          width: tooltipAdaptiveWidth,
                                          child: Padding(
                                            padding: widget.tooltipActionConfig
                                                    .padding ??
                                                EdgeInsets.zero,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  tooltipActionButtonAlignment,
                                              children: tooltipActionsList,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  double? _getTooltipAdaptiveWidth() => tooltipActionSize == null
      ? null
      : max(
          tooltipWidth,
          tooltipActionSize!.width +
              (widget.tooltipActionConfig.position ==
                      TooltipActionPosition.inside
                  ? (widget.tooltipPadding?.left ?? 0) +
                      (widget.tooltipPadding?.right ?? 0)
                  : 0),
        );

  List<Padding> _getActionWidgets() {
    List<Padding> actions = [];
    for (var i = 0; i < (widget.tooltipActions?.length ?? 0); i++) {
      if ((widget.showCaseState.activeWidgetId == 0 &&
              !widget.tooltipActions![i].shouldShowForFirstTooltip) ||
          (widget.showCaseState.activeWidgetId ==
                  (widget.showCaseState.ids?.length ?? 0) - 1 &&
              !widget.tooltipActions![i].shouldShowForLastTooltip)) {
        continue;
      }
      actions.add(
        Padding(
          padding: EdgeInsets.only(
            right: i < widget.tooltipActions!.length - 1
                ? widget.tooltipActionConfig.actionGap
                : 0,
          ),
          child: TooltipActionButtonWidget(
            config: widget.tooltipActions![i],
            showCaseState: widget.showCaseState,
          ),
        ),
      );
    }
    return actions;
  }

  void onSizeChange(Size? size) {
    var tempPos = position;
    tempPos = Offset(position!.dx, position!.dy + size!.height);
    setState(() => position = tempPos);
  }

  Size _textSize(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      // TODO: replace this once we support sdk v3.12.
      // ignore: deprecated_member_use
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }

  double? _getArrowLeft(double arrowWidth) {
    final left = _getLeft();
    if (left == null) return null;
    return (widget.position!.getCenter() - (arrowWidth * 0.5) - left);
  }

  double? _getArrowRight(double arrowWidth) {
    if (_getLeft() != null) return null;
    return (widget.screenSize.width - widget.position!.getCenter()) -
        (_getRight() ?? 0) -
        (arrowWidth * 0.5);
  }

  void onTooltipSizeChanged(Size? size) {
    if (size == null) return;
    setState(() {
      if (size.width > widget.screenSize.width - tooltipScreenEdgePadding) {
        tooltipWidth = widget.screenSize.width - tooltipScreenEdgePadding;
      } else {
        tooltipWidth = size.width;
      }
      tooltipHeight = size.height;
    });
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
    canvas.drawPath(
      getTrianglePath(size.width, size.height),
      _paint,
    );
  }

  Path getTrianglePath(double x, double y) {
    if (isUpArrow) {
      return Path()
        ..moveTo(0, y)
        ..lineTo(x * 0.5, 0)
        ..lineTo(x, y)
        ..lineTo(0, y);
    }
    return Path()
      ..moveTo(0, 0)
      ..lineTo(x, 0)
      ..lineTo(x * 0.5, y)
      ..lineTo(0, 0);
  }

  @override
  bool shouldRepaint(covariant _Arrow oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
