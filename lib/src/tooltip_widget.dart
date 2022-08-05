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

import 'get_position.dart';
import 'measure_size.dart';

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size? screenSize;
  final String? title;
  final String? description;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final Color? tooltipColor;
  final Color? textColor;
  final bool showArrow;
  final double? contentHeight;
  final double? contentWidth;
  final VoidCallback? onTooltipTap;
  final EdgeInsets? contentPadding;
  final Duration animationDuration;
  final bool disableAnimation;
  final BorderRadius? borderRadius;

  const ToolTipWidget({
    Key? key,
    required this.position,
    required this.offset,
    required this.screenSize,
    required this.title,
    required this.description,
    required this.titleTextStyle,
    required this.descTextStyle,
    required this.container,
    required this.tooltipColor,
    required this.textColor,
    required this.showArrow,
    required this.contentHeight,
    required this.contentWidth,
    required this.onTooltipTap,
    required this.animationDuration,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
    required this.disableAnimation,
    required this.borderRadius,
  }) : super(key: key);

  @override
  State<ToolTipWidget> createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget>
    with SingleTickerProviderStateMixin {
  Offset? position;

  bool isArrowUp = false;

  late final AnimationController _parentController;
  late final Animation<double> _curvedAnimation;

  bool isCloseToTopOrBottom(Offset position) {
    var height = 120.0;
    height = widget.contentHeight ?? height;
    final bottomPosition =
        position.dy + ((widget.position?.getHeight() ?? 0) / 2);
    final topPosition = position.dy - ((widget.position?.getHeight() ?? 0) / 2);
    return ((widget.screenSize?.height ?? MediaQuery.of(context).size.height) -
                bottomPosition) <=
            height &&
        topPosition >= height;
  }

  String findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return 'ABOVE';
    } else {
      return 'BELOW';
    }
  }

  double _getTooltipWidth() {
    final titleStyle = widget.titleTextStyle ??
        Theme.of(context)
            .textTheme
            .headline6!
            .merge(TextStyle(color: widget.textColor));
    final descriptionStyle = widget.descTextStyle ??
        Theme.of(context)
            .textTheme
            .subtitle2!
            .merge(TextStyle(color: widget.textColor));
    final titleLength = widget.title == null
        ? 0
        : _textSize(widget.title!, titleStyle).width +
            widget.contentPadding!.right +
            widget.contentPadding!.left;
    final descriptionLength =
        _textSize(widget.description!, descriptionStyle).width +
            widget.contentPadding!.right +
            widget.contentPadding!.left;
    var maxTextWidth = max(titleLength, descriptionLength);
    if (maxTextWidth > widget.screenSize!.width - 20) {
      return widget.screenSize!.width - 20;
    } else {
      return maxTextWidth + 15;
    }
  }

  bool _isLeft() {
    final screenWidth = widget.screenSize!.width / 3;
    return !(screenWidth <= widget.position!.getCenter());
  }

  bool _isRight() {
    final screenWidth = widget.screenSize!.width / 3;
    return ((screenWidth * 2) <= widget.position!.getCenter());
  }

  double? _getLeft() {
    if (_isLeft()) {
      var leftPadding =
          widget.position!.getCenter() - (_getTooltipWidth() * 0.1);
      if (leftPadding + _getTooltipWidth() > widget.screenSize!.width) {
        leftPadding = (widget.screenSize!.width - 20) - _getTooltipWidth();
      }
      if (leftPadding < 20) {
        leftPadding = 14;
      }
      return leftPadding;
    } else if (!(_isRight())) {
      return widget.position!.getCenter() - (_getTooltipWidth() * 0.5);
    } else {
      return null;
    }
  }

  double? _getRight() {
    if (_isRight()) {
      var rightPadding =
          widget.position!.getCenter() + (_getTooltipWidth() / 2);
      if (rightPadding + _getTooltipWidth() > widget.screenSize!.width) {
        rightPadding = 14;
      }
      return rightPadding;
    } else if (!(_isLeft())) {
      return widget.position!.getCenter() - (_getTooltipWidth() * 0.5);
    } else {
      return null;
    }
  }

  double _getSpace() {
    var space = widget.position!.getCenter() - (widget.contentWidth! / 2);
    if (space + widget.contentWidth! > widget.screenSize!.width) {
      space = widget.screenSize!.width - widget.contentWidth! - 8;
    } else if (space < (widget.contentWidth! / 2)) {
      space = 16;
    }
    return space;
  }

  @override
  void initState() {
    super.initState();
    _parentController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _parentController.reverse();
        }
        if (_parentController.isDismissed) {
          if (!widget.disableAnimation) {
            _parentController.forward();
          }
        }
      });

    _curvedAnimation = CurvedAnimation(
      parent: _parentController,
      curve: Curves.easeInOut,
    );

    if (!widget.disableAnimation) {
      _parentController.forward();
    }
  }

  @override
  void dispose() {
    _parentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    position = widget.offset;
    final contentOrientation = findPositionForContent(position!);
    final contentOffsetMultiplier = contentOrientation == "BELOW" ? 1.0 : -1.0;
    isArrowUp = contentOffsetMultiplier == 1.0;

    final contentY = isArrowUp
        ? widget.position!.getBottom() + (contentOffsetMultiplier * 3)
        : widget.position!.getTop() + (contentOffsetMultiplier * 3);

    final num contentFractionalOffset =
        contentOffsetMultiplier.clamp(-1.0, 0.0);

    var paddingTop = isArrowUp ? 22.0 : 0.0;
    var paddingBottom = isArrowUp ? 0.0 : 27.0;

    if (!widget.showArrow) {
      paddingTop = 10;
      paddingBottom = 10;
    }

    const arrowWidth = 18.0;
    const arrowHeight = 9.0;

    if (widget.container == null) {
      return Positioned(
        top: contentY,
        left: _getLeft(),
        right: _getRight(),
        child: FractionalTranslation(
          translation: Offset(0.0, contentFractionalOffset as double),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, contentFractionalOffset / 10),
              end: const Offset(0.0, 0.100),
            ).animate(_curvedAnimation),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: widget.showArrow
                    ? EdgeInsets.only(
                        top: paddingTop - (isArrowUp ? arrowHeight : 0),
                        bottom: paddingBottom - (isArrowUp ? 0 : arrowHeight),
                      )
                    : null,
                child: Stack(
                  alignment: isArrowUp
                      ? Alignment.topLeft
                      : _getLeft() == null
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                  children: [
                    if (widget.showArrow)
                      Positioned(
                        left: _getLeft() == null
                            ? null
                            : (widget.position!.getCenter() -
                                (arrowWidth / 2) -
                                (_getLeft() ?? 0)),
                        right: _getLeft() == null
                            ? (MediaQuery.of(context).size.width -
                                    widget.position!.getCenter()) -
                                (_getRight() ?? 0) -
                                (arrowWidth / 2)
                            : null,
                        child: CustomPaint(
                          painter: _Arrow(
                            strokeColor: widget.tooltipColor!,
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
                        borderRadius:
                            widget.borderRadius ?? BorderRadius.circular(8.0),
                        child: GestureDetector(
                          onTap: widget.onTooltipTap,
                          child: Container(
                            width: _getTooltipWidth(),
                            padding: widget.contentPadding,
                            color: widget.tooltipColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: widget.title != null
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.center,
                                  children: <Widget>[
                                    widget.title != null
                                        ? Text(
                                            widget.title!,
                                            style: widget.titleTextStyle ??
                                                Theme.of(context)
                                                    .textTheme
                                                    .headline6!
                                                    .merge(
                                                      TextStyle(
                                                        color: widget.textColor,
                                                      ),
                                                    ),
                                          )
                                        : const SizedBox(),
                                    Text(
                                      widget.description!,
                                      style: widget.descTextStyle ??
                                          Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .merge(
                                                TextStyle(
                                                  color: widget.textColor,
                                                ),
                                              ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned(
            left: _getSpace(),
            top: contentY - 10,
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset as double),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: !widget.showArrow && !isArrowUp
                      ? const Offset(0.0, 0.0)
                      : const Offset(0.0, 0.100),
                ).animate(_curvedAnimation),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: widget.onTooltipTap,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: paddingTop,
                      ),
                      color: Colors.transparent,
                      child: Center(
                        child: MeasureSize(
                            onSizeChange: (size) {
                              setState(() {
                                var tempPos = position;
                                tempPos = Offset(
                                    position!.dx, position!.dy + size!.height);
                                position = tempPos;
                              });
                            },
                            child: widget.container),
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

  Size _textSize(String text, TextStyle style) {
    final textPainter = (TextPainter(
            text: TextSpan(text: text, style: style),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    return textPainter;
  }
}

class _Arrow extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final bool isUpArrow;

  _Arrow(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke,
      this.isUpArrow = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    if (isUpArrow) {
      return Path()
        ..moveTo(0, y)
        ..lineTo(x / 2, 0)
        ..lineTo(x, y)
        ..lineTo(0, y);
    } else {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(x, 0)
        ..lineTo(x / 2, y)
        ..lineTo(0, 0);
    }
  }

  @override
  bool shouldRepaint(_Arrow oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
