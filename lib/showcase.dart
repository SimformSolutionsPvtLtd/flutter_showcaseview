/*
 * Copyright © 2020, Simform Solutions
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:showcaseview/custom_paint.dart';
import 'package:showcaseview/showcaseview.dart';

import 'get_position.dart';
import 'layout_overlays.dart';
import 'tooltip_widget.dart';

class Showcase extends StatefulWidget {
  final Widget child;
  final String title;
  final String description;
  final ShapeBorder shapeBorder;
  final TextStyle titleTextStyle;
  final TextStyle descTextStyle;
  final EdgeInsets contentPadding;
  final GlobalKey key;
  final Color overlayColor;
  final double overlayOpacity;
  final Widget container;
  final Color showcaseBackgroundColor;
  final Color textColor;
  final bool showArrow;
  final double height;
  final double width;
  final Duration animationDuration;
  final VoidCallback onToolTipClick;
  final VoidCallback onTargetClick;
  final bool disposeOnTap;
  final bool disableAnimation;

  const Showcase(
      {@required this.key,
      @required this.child,
      this.title,
      @required this.description,
      this.shapeBorder,
      this.overlayColor = Colors.black,
      this.overlayOpacity = 0.75,
      this.titleTextStyle,
      this.descTextStyle,
      this.showcaseBackgroundColor = Colors.white,
      this.textColor = Colors.black,
      this.showArrow = true,
      this.onTargetClick,
      this.disposeOnTap,
      this.animationDuration = const Duration(milliseconds: 2000),
      this.disableAnimation = false,
      this.contentPadding = const EdgeInsets.symmetric(vertical: 8)})
      : height = null,
        width = null,
        container = null,
        this.onToolTipClick = null,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
            "overlay opacity should be >= 0.0 and <= 1.0."),
        assert(
            onTargetClick == null
                ? true
                : (disposeOnTap == null ? false : true),
            "disposeOnTap is required if you're using onTargetClick"),
        assert(
            disposeOnTap == null
                ? true
                : (onTargetClick == null ? false : true),
            "onTargetClick is required if you're using disposeOnTap"),
        assert(key != null ||
            child != null ||
            title != null ||
            showArrow != null ||
            description != null ||
            shapeBorder != null ||
            overlayColor != null ||
            titleTextStyle != null ||
            descTextStyle != null ||
            showcaseBackgroundColor != null ||
            textColor != null ||
            shapeBorder != null ||
            animationDuration != null);

  const Showcase.withWidget(
      {this.key,
      @required this.child,
      @required this.container,
      @required this.height,
      @required this.width,
      this.title,
      this.description,
      this.shapeBorder,
      this.overlayColor = Colors.black,
      this.overlayOpacity = 0.75,
      this.titleTextStyle,
      this.descTextStyle,
      this.showcaseBackgroundColor = Colors.white,
      this.textColor = Colors.black,
      this.onTargetClick,
      this.disposeOnTap,
      this.animationDuration = const Duration(milliseconds: 2000),
      this.disableAnimation = false,
      this.contentPadding = const EdgeInsets.symmetric(vertical: 8)})
      : this.showArrow = false,
        this.onToolTipClick = null,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
            "overlay opacity should be >= 0.0 and <= 1.0."),
        assert(key != null ||
            child != null ||
            title != null ||
            description != null ||
            shapeBorder != null ||
            overlayColor != null ||
            titleTextStyle != null ||
            descTextStyle != null ||
            showcaseBackgroundColor != null ||
            textColor != null ||
            shapeBorder != null ||
            animationDuration != null);

  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> with TickerProviderStateMixin {
  bool _showShowCase = false;
  Animation<double> _slideAnimation;
  AnimationController _slideAnimationController;

  GetPosition position;

  @override
  void initState() {
    super.initState();

    _slideAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _slideAnimationController.reverse();
        }
        if (_slideAnimationController.isDismissed) {
          if (!widget.disableAnimation) {
            _slideAnimationController.forward();
          }
        }
      });

    _slideAnimation = CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    );

    position = GetPosition(key: widget.key);
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showOverlay();
  }

  ///
  /// show overlay if there is any target widget
  ///
  void showOverlay() {
    GlobalKey activeStep = ShowCaseWidget.activeTargetWidget(context);
    setState(() {
      _showShowCase = activeStep == widget.key;
    });

    if (activeStep == widget.key) {
      if (!widget.disableAnimation) {
        _slideAnimationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AnchoredOverlay(
      overlayBuilder: (BuildContext context, Rect rectBound, Offset offset) =>
          buildOverlayOnTarget(offset, rectBound.size, rectBound, size),
      showOverlay: true,
      child: widget.child,
    );
  }

  _nextIfAny() {
    ShowCaseWidget.of(context).completed(widget.key);
    if (!widget.disableAnimation) {
      _slideAnimationController.forward();
    }
  }

  _getOnTargetTap() {
    if (widget.disposeOnTap == true) {
      return widget.onTargetClick == null
          ? () {
              ShowCaseWidget.of(context).dismiss();
            }
          : () {
              ShowCaseWidget.of(context).dismiss();
              widget.onTargetClick();
            };
    } else {
      return widget.onTargetClick ?? _nextIfAny;
    }
  }

  _getOnTooltipTap() {
    if (widget.disposeOnTap == true) {
      return widget.onToolTipClick == null
          ? () {
              ShowCaseWidget.of(context).dismiss();
            }
          : () {
              ShowCaseWidget.of(context).dismiss();
              widget.onToolTipClick();
            };
    } else {
      return widget.onToolTipClick ?? () {};
    }
  }

  buildOverlayOnTarget(
    Offset offset,
    Size size,
    Rect rectBound,
    Size screenSize,
  ) =>
      Visibility(
        visible: _showShowCase,
        maintainAnimation: true,
        maintainState: true,
        child: Stack(
          children: [
            GestureDetector(
              onTap: _nextIfAny,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CustomPaint(
                  painter: ShapePainter(
                      opacity: widget.overlayOpacity,
                      rect: position.getRect(),
                      shapeBorder: widget.shapeBorder,
                      color: widget.overlayColor),
                ),
              ),
            ),
            _TargetWidget(
              offset: offset,
              size: size,
              onTap: _getOnTargetTap(),
              shapeBorder: widget.shapeBorder,
            ),
            ToolTipWidget(
              position: position,
              offset: offset,
              screenSize: screenSize,
              title: widget.title,
              description: widget.description,
              animationOffset: _slideAnimation,
              titleTextStyle: widget.titleTextStyle,
              descTextStyle: widget.descTextStyle,
              container: widget.container,
              tooltipColor: widget.showcaseBackgroundColor,
              textColor: widget.textColor,
              showArrow: widget.showArrow,
              contentHeight: widget.height,
              contentWidth: widget.width,
              onTooltipTap: _getOnTooltipTap(),
              contentPadding: widget.contentPadding,
            ),
          ],
        ),
      );
}

class _TargetWidget extends StatelessWidget {
  final Offset offset;
  final Size size;
  final Animation<double> widthAnimation;
  final VoidCallback onTap;
  final ShapeBorder shapeBorder;

  _TargetWidget({
    Key key,
    @required this.offset,
    this.size,
    this.widthAnimation,
    this.onTap,
    this.shapeBorder,
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
          child: Container(
            height: size.height + 16,
            width: size.width + 16,
            decoration: ShapeDecoration(
              shape: shapeBorder ??
                  RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(
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
