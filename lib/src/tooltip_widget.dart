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

import 'package:flutter/material.dart';

import 'get_position.dart';

enum TooltipHorizontalAxis { left, right }

enum TooltipVerticalPosition { up, down }

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size screenSize;
  final String? title;
  final String? description;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final Color? tooltipColor;
  final Color? textColor;
  final bool showArrow;
  final VoidCallback? onTooltipTap;
  final EdgeInsets? contentPadding;
  final Widget? actions;
  final Duration animationDuration;
  final bool disableAnimation;
  final Rect rect;
  final Size arrowSize;

  ToolTipWidget({
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
    required this.onTooltipTap,
    required this.animationDuration,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
    required this.disableAnimation,
    this.actions,
    required this.rect,
    required this.arrowSize,
  });

  @override
  _ToolTipWidgetState createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget>
    with SingleTickerProviderStateMixin {
  _TooltipCoordinates? _coords;

  late final AnimationController _parentController;
  late final Animation<double> _curvedAnimation;

  bool isArrowUp = false;
  void _getPosition() {
    // Tooltip render box.
    final box = (context.findRenderObject() as RenderBox);

    late final AnimationController _parentController;
    late final Animation _curvedAnimation;
    // TODO: get this offset from user if possible.
    final tooltipOffset = Offset(0, 15);

    final overlayPadding = 14.0;

    // Size of the widget.
    final widgetSize = widget.rect.size;

    // Position of the widget.
    final widgetPosition = widget.rect.topLeft;

    final widgetCenter = (widgetPosition & widgetSize).center;

    // Size of the showcase.
    final showcaseSize = box.size;

    var top = widgetPosition.dy + widgetSize.height + tooltipOffset.dy;
    var left = widgetCenter.dx - (showcaseSize.width / 2);

    var horizontalAxis = TooltipHorizontalAxis.right;
    var verticalAxis = TooltipVerticalPosition.down;

    var leftOffset = widgetCenter.dx - left;

    // If left position is in negative with offset remove the offset.
    if (left < 0) {
      left = overlayPadding;

      leftOffset = widgetCenter.dx - left - (widget.arrowSize.width / 2);
    } else if (left + showcaseSize.width > widget.screenSize.width) {
      left = widget.screenSize.width - showcaseSize.width - overlayPadding;
      leftOffset = widgetCenter.dx - left + (widget.arrowSize.width / 2);
      horizontalAxis = TooltipHorizontalAxis.left;
    }

    if (top + showcaseSize.height > widget.screenSize.height) {
      // TODO: recalculate top

      top = widgetPosition.dy - tooltipOffset.dy - showcaseSize.height;

      verticalAxis = TooltipVerticalPosition.up;
    }

    final alignmentLeft = -1 + (2 * (leftOffset / showcaseSize.width));

    var right = left + showcaseSize.width;

    var bottom = top + showcaseSize.height;

    if (right > widget.screenSize.width) {
      right = widget.screenSize.width - overlayPadding;
    }
    if (bottom > widget.screenSize.height) {
      bottom = widget.screenSize.height - overlayPadding;
    }

    final newCoords = _TooltipCoordinates(
      // area: Offset(left, top) & showcaseSize,
      area: Rect.fromLTRB(left, top, right, bottom),
      horizontalAxis: horizontalAxis,
      verticalAxis: verticalAxis,
      arrowAlignment: Alignment(alignmentLeft, 0),
    );

    /// Call set state only if widget is mounted and newly calculated data
    /// differs from older one. This will be useful in web when user resize
    /// window. That will call build method and when window is resized every
    /// time coords will have different values and will trigger rebuild.
    ///
    /// In short it will trigger rebuild only on first build after application
    /// run/resize.
    if (mounted && _coords != newCoords) {
      setState(() {
        /// Assign calculated coordinates to [_coords] that will
        /// be reflected on UI.
        _coords = newCoords;
      });
    }
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
    // This will register callback on every build/rebuild.
    WidgetsBinding.instance!.addPostFrameCallback((_) => _getPosition());

    final verticalDirection = _coords?.isArrowUp ?? true
        ? VerticalDirection.down
        : VerticalDirection.up;

    return Positioned(
      top: _coords?.area.top ?? 0,
      left: _coords?.area.left ?? 0,
      child: Opacity(
        opacity: _coords == null ? 0 : 1,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, 0.0),
            end: Offset(0.0, 0.1),
          ).animate(_curvedAnimation),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: verticalDirection,
              children: [
                if (widget.showArrow)
                  SizedBox(
                    width: _coords?.area.width ?? 0,
                    child: Align(
                      alignment: _coords?.arrowAlignment ?? Alignment.center,
                      child: CustomPaint(
                        size: widget.arrowSize,
                        painter: _Arrow(
                          strokeColor: widget.tooltipColor!,
                          strokeWidth: 10,
                          paintingStyle: PaintingStyle.fill,
                          isUpArrow: _coords != null && _coords!.isArrowUp,
                        ),
                        child: SizedBox.fromSize(
                          size: widget.arrowSize,
                        ),
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: _coords != null && _coords!.isArrowLeft
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  verticalDirection: verticalDirection,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.container == null
                        ? Container(
                            child: GestureDetector(
                              onTap: widget.onTooltipTap,
                              child: Container(
                                padding: widget.contentPadding,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: widget.tooltipColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: widget.screenSize.width - 42,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: widget.title != null
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
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
                                                          color:
                                                              widget.textColor,
                                                        ),
                                                      ),
                                            )
                                          : SizedBox.shrink(),
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
                                  ),
                                ),
                              ),
                            ),
                          )
                        : widget.container!,
                    if (widget.actions != null) widget.actions!
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

// Keep this to avoid 'avoid_equals_and_hash_code_on_mutable_classes' warning.
@immutable
class _TooltipCoordinates {
  final Rect area;
  final TooltipHorizontalAxis horizontalAxis;
  final TooltipVerticalPosition verticalAxis;
  final Alignment arrowAlignment;

  const _TooltipCoordinates({
    required this.area,
    required this.horizontalAxis,
    required this.verticalAxis,
    required this.arrowAlignment,
  });

  bool get isArrowUp => verticalAxis == TooltipVerticalPosition.down;
  bool get isArrowLeft => horizontalAxis == TooltipHorizontalAxis.right;

  @override
  bool operator ==(Object other) =>
      other is _TooltipCoordinates &&
      area == other.area &&
      horizontalAxis == other.horizontalAxis &&
      verticalAxis == other.verticalAxis &&
      arrowAlignment == other.arrowAlignment;

  @override
  int get hashCode => super.hashCode;
}
