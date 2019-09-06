import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:showcaseview/custom_paint.dart';
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

  const Showcase({
    @required this.key,
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
    this.animationDuration = const Duration(milliseconds: 2000),
  })  : height = null,
        width = null,
        container = null,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
            "overlay opacity should be >= 0.0 and <= 1.0."),
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

  const Showcase.withWidget({
    this.key,
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
    this.animationDuration = const Duration(milliseconds: 2000),
  })  : this.showArrow = false,
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
    ShowCaseWidget.completed(context, widget.key);
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
              onTap: _nextIfAny,
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
