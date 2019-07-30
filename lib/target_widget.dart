import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:showcaseview/custom_paint.dart';
import 'package:showcaseview/tooltip_widget.dart';

import 'get_position.dart';
import 'layout_overlays.dart';

class TargetWidget extends StatefulWidget {
  final Widget child;
  final String title;
  final String description;
  final ShapeBorder shapeBorder;
  final TextStyle titleTextStyle;
  final TextStyle descTextStyle;
  final GlobalKey key;
  final Color overlayColor;
  final double overlayOpacity;
  final Widget container;
  final Color tooltipColor;
  final Color textColor;
  final bool showArrow;
  final double cHeight;
  final double cWidth;
  final Duration slideDuration;

  const TargetWidget({
    this.key,
    @required this.child,
    @required this.title,
    @required this.description,
    this.shapeBorder,
    this.overlayColor,
    this.overlayOpacity,
    this.titleTextStyle,
    this.descTextStyle,
    this.tooltipColor = Colors.white,
    this.textColor = Colors.black,
    this.showArrow,
    this.slideDuration = const Duration(milliseconds: 2000),
  })  : cHeight = null,
        cWidth = null,
        container = null;

  const TargetWidget.withWidget({
    this.key,
    @required this.child,
    @required this.container,
    @required this.cHeight,
    @required this.cWidth,
    this.title,
    this.description,
    this.shapeBorder,
    this.overlayColor,
    this.overlayOpacity,
    this.titleTextStyle,
    this.descTextStyle,
    this.tooltipColor = Colors.white,
    this.textColor = Colors.black,
    this.showArrow = false,
    this.slideDuration = const Duration(milliseconds: 2000),
  });

  @override
  _TargetWidgetState createState() => _TargetWidgetState();
}

class _TargetWidgetState extends State<TargetWidget>
    with TickerProviderStateMixin {
  bool _showShowCase = false;
  Animation<double> _slideAnimation;
  AnimationController _slideAnimationController;

  GetPosition position;

  @override
  void initState() {
    super.initState();

    _slideAnimationController = AnimationController(
      duration: widget.slideDuration,
      vsync: this,
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _slideAnimationController.reverse();
        }
        if (_slideAnimationController.isDismissed) {
          _slideAnimationController.forward();
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
    super.dispose();
    _slideAnimationController.dispose();
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
    GlobalKey activeStep = ShowCase.activeTargetWidget(context);
    setState(() {
      _showShowCase = activeStep == widget.key;
    });

    if (activeStep == widget.key) {
      _slideAnimationController.forward();
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
    ShowCase.completed(context, widget.key);
    _slideAnimationController.forward();
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
                      opacity: widget.overlayOpacity ?? 0.7,
                      rect: position.getRect(),
                      shapeBorder: widget.shapeBorder,
                      color: widget.overlayColor ?? Colors.black),
                ),
              ),
            ),
            _TargetWidget(
              offset: offset,
              size: size,
              onTap: _nextIfAny,
              shapeBorder: widget.shapeBorder,
            ),
            Content(
              position: position,
              offset: offset,
              screenSize: screenSize,
              title: widget.title,
              description: widget.description,
              animationOffset: _slideAnimation,
              titleTextStyle: widget.titleTextStyle,
              descTextStyle: widget.descTextStyle,
              container: widget.container,
              tooltipColor: widget.tooltipColor,
              textColor: widget.textColor,
              showArrow: widget.showArrow ?? true,
              contentHeight: widget.cHeight,
              contentWidth: widget.cWidth,
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
