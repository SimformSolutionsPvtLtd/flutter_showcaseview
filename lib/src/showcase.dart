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

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'extension.dart';
import 'get_position.dart';
import 'layout_overlays.dart';
import 'shape_clipper.dart';
import 'showcase_widget.dart';
import 'tooltip_widget.dart';

class Showcase extends StatefulWidget {
  @override
  final GlobalKey key;

  final Widget child;
  final String? title;
  final String? description;
  final ShapeBorder? shapeBorder;
  final BorderRadius? radius;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final EdgeInsets contentPadding;
  final Color overlayColor;
  final double overlayOpacity;
  final Widget? container;
  final Color showcaseBackgroundColor;
  final Color textColor;
  final Widget scrollLoadingWidget;
  final bool disableAutoScrollInView;
  final bool showArrow;
  final double? height;
  final double? width;
  final Duration animationDuration;
  final VoidCallback? onToolTipClick;
  final VoidCallback? onTargetClick;
  final bool? disposeOnTap;
  final bool? disableAnimation;
  final EdgeInsets overlayPadding;
  final VoidCallback? onTargetDoubleTap;
  final VoidCallback? onTargetLongPress;

  /// Defines blur value.
  /// This will blur the background while displaying showcase.
  ///
  /// If null value is provided,
  /// [ShowCaseWidget.defaultBlurValue] will be considered.
  ///
  final double? blurValue;

  const Showcase({
    required this.key,
    required this.child,
    this.title,
    required this.description,
    this.shapeBorder,
    this.overlayColor = Colors.black45,
    this.overlayOpacity = 0.75,
    this.titleTextStyle,
    this.descTextStyle,
    this.showcaseBackgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.scrollLoadingWidget = const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
    this.disableAutoScrollInView = false,
    this.showArrow = true,
    this.onTargetClick,
    this.disposeOnTap,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.disableAnimation,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.onToolTipClick,
    this.overlayPadding = EdgeInsets.zero,
    this.blurValue,
    this.radius,
    this.onTargetLongPress,
    this.onTargetDoubleTap,
  })  : height = null,
        width = null,
        container = null,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0, "overlay opacity must be between 0 and 1."),
        assert(onTargetClick == null ? true : (disposeOnTap == null ? false : true),
            "disposeOnTap is required if you're using onTargetClick"),
        assert(disposeOnTap == null ? true : (onTargetClick == null ? false : true),
            "onTargetClick is required if you're using disposeOnTap");

  const Showcase.withWidget({
    required this.key,
    required this.child,
    required this.container,
    required this.height,
    required this.width,
    this.title,
    this.description,
    this.shapeBorder,
    this.overlayColor = Colors.black45,
    this.radius,
    this.overlayOpacity = 0.75,
    this.titleTextStyle,
    this.descTextStyle,
    this.showcaseBackgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.scrollLoadingWidget = const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
    this.disableAutoScrollInView = false,
    this.onTargetClick,
    this.disposeOnTap,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.disableAnimation,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
    this.overlayPadding = EdgeInsets.zero,
    this.blurValue,
    this.onTargetLongPress,
    this.onTargetDoubleTap,
  })  : showArrow = false,
        onToolTipClick = null,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0, "overlay opacity must be between 0 and 1.");

  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  bool _showShowCase = false;
  bool _isScrollRunning = false;
  Timer? timer;
  GetPosition? position;

  ShowCaseWidgetState get showCaseWidgetState => ShowCaseWidget.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    position ??= GetPosition(
      key: widget.key,
      padding: widget.overlayPadding,
      screenWidth: MediaQuery.of(context).size.width,
      screenHeight: MediaQuery.of(context).size.height,
    );
    showOverlay();
  }

  /// show overlay if there is any target widget
  ///
  void showOverlay() {
    final activeStep = ShowCaseWidget.activeTargetWidget(context);
    setState(() {
      _showShowCase = activeStep == widget.key;
    });

    if (activeStep == widget.key) {
      if (!widget.disableAutoScrollInView) {
        _scrollIntoView();
      }
      if (showCaseWidgetState.autoPlay) {
        timer = Timer(Duration(seconds: showCaseWidgetState.autoPlayDelay.inSeconds), _nextIfAny);
      }
    }
  }

  void _scrollIntoView() {
    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) async {
      setState(() {
        _isScrollRunning = true;
      });
      await Scrollable.ensureVisible(
        widget.key.currentContext!,
        duration: showCaseWidgetState.widget.scrollDuration,
        alignment: 0.5,
      );
      setState(() {
        _isScrollRunning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      overlayBuilder: (context, rectBound, offset) {
        final size = MediaQuery.of(context).size;
        position = GetPosition(
          key: widget.key,
          padding: widget.overlayPadding,
          screenWidth: size.width,
          screenHeight: size.height,
        );
        return buildOverlayOnTarget(offset, rectBound.size, rectBound, size);
      },
      showOverlay: true,
      child: widget.child,
    );
  }

  void _nextIfAny() {
    if (timer != null && timer!.isActive) {
      if (showCaseWidgetState.autoPlayLockEnable) {
        return;
      }
      timer!.cancel();
    } else if (timer != null && !timer!.isActive) {
      timer = null;
    }
    showCaseWidgetState.completed(widget.key);
  }

  void _getOnTargetTap() {
    if (widget.disposeOnTap == true) {
      showCaseWidgetState.dismiss();
      widget.onTargetClick!();
    } else {
      (widget.onTargetClick ?? _nextIfAny).call();
    }
  }

  void _getOnTooltipTap() {
    if (widget.disposeOnTap == true) {
      showCaseWidgetState.dismiss();
    }
    widget.onToolTipClick?.call();
  }

  Widget buildOverlayOnTarget(
    Offset offset,
    Size size,
    Rect rectBound,
    Size screenSize,
  ) {
    var blur = 0.0;
    if (_showShowCase) {
      blur = widget.blurValue ?? showCaseWidgetState.blurValue;
    }

    // Set blur to 0 if application is running on web and
    // provided blur is less than 0.
    blur = kIsWeb && blur < 0 ? 0 : blur;

    return _showShowCase
        ? Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (!(ShowCaseWidget.of(context).disableBarrierInteraction)) {
                    _nextIfAny();
                  }
                },
                child: ClipPath(
                  clipper: RRectClipper(
                    area: _isScrollRunning ? Rect.zero : rectBound,
                    isCircle: widget.shapeBorder == const CircleBorder(),
                    radius: _isScrollRunning ? BorderRadius.zero : widget.radius,
                    overlayPadding: _isScrollRunning ? EdgeInsets.zero : widget.overlayPadding,
                  ),
                  child: blur != 0
                      ? BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: widget.overlayColor.withOpacity(widget.overlayOpacity),
                            ),
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: widget.overlayColor.withOpacity(widget.overlayOpacity),
                          ),
                        ),
                ),
              ),
              if (_isScrollRunning) Center(child: widget.scrollLoadingWidget),
              if (!_isScrollRunning)
                _TargetWidget(
                  offset: offset,
                  size: size,
                  onTap: _getOnTargetTap,
                  onDoubleTap: widget.onTargetDoubleTap,
                  onLongPress: widget.onTargetLongPress,
                  shapeBorder: widget.shapeBorder,
                ),
              if (!_isScrollRunning)
                ToolTipWidget(
                  position: position,
                  offset: offset,
                  screenSize: screenSize,
                  title: widget.title,
                  description: widget.description,
                  titleTextStyle: widget.titleTextStyle,
                  descTextStyle: widget.descTextStyle,
                  container: widget.container,
                  tooltipColor: widget.showcaseBackgroundColor,
                  textColor: widget.textColor,
                  showArrow: widget.showArrow,
                  contentHeight: widget.height,
                  contentWidth: widget.width,
                  onTooltipTap: _getOnTooltipTap,
                  contentPadding: widget.contentPadding,
                  disableAnimation: widget.disableAnimation ?? showCaseWidgetState.disableAnimation,
                  animationDuration: widget.animationDuration,
                ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class _TargetWidget extends StatelessWidget {
  final Offset offset;
  final Size? size;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final ShapeBorder? shapeBorder;
  final BorderRadius? radius;

  const _TargetWidget({
    Key? key,
    required this.offset,
    this.size,
    this.onTap,
    this.shapeBorder,
    this.radius,
    this.onDoubleTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          onDoubleTap: onDoubleTap,
          child: Container(
            height: size!.height + 16,
            width: size!.width + 16,
            decoration: ShapeDecoration(
              shape: radius != null
                  ? RoundedRectangleBorder(borderRadius: radius!)
                  : shapeBorder ??
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
