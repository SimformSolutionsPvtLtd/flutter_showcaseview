import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:showcaseview/custom_paint.dart';
import 'package:showcaseview/tooltip_widget.dart';

import 'get_position.dart';

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
  final double cWidht;

  const TargetWidget({
    this.key,
    @required this.child,
    this.container,
    @required this.title,
    @required this.description,
    this.shapeBorder,
    this.overlayColor,
    this.overlayOpacity,
    this.titleTextStyle,
    this.descTextStyle,
    this.tooltipColor,
    this.textColor,
    this.showArrow,
    this.cHeight,
    this.cWidht
  });

  const TargetWidget.withWidget({
    this.key,
    @required this.child,
    @required this.container,
    this.title,
    this.description,
    this.shapeBorder,
    this.overlayColor,
    this.overlayOpacity,
    this.titleTextStyle,
    this.descTextStyle,
    this.tooltipColor,
    this.textColor,
    this.showArrow,
    @required  this.cHeight,
    @required  this.cWidht
  });

  @override
  _TargetWidgetState createState() => _TargetWidgetState();
}

class _TargetWidgetState extends State<TargetWidget>
    with TickerProviderStateMixin {
  bool _showShowCase = false;
  Animation<double> _slideAnimation;
  Animation<double> _widthAnimation;

  AnimationController _slideAnimationController;
  AnimationController _widthAnimationController;

  GetPosition position;

  @override
  void initState() {
    super.initState();
    _widthAnimationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    _widthAnimation = CurvedAnimation(
      parent: _widthAnimationController,
      curve: Curves.easeInOut,
    );

    _widthAnimationController.addListener(() {
      setState(() {});
    });

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
    _widthAnimationController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showOverlay();
  }

  void showOverlay() {
    GlobalKey activeStep = ShowCase.activeTargetWidget(context);
    setState(() {
      _showShowCase = activeStep == widget.key;
    });

    if (activeStep == widget.key) {
      _slideAnimationController.forward();
      _widthAnimationController.forward();
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

  // _onTargetTap() {
  //   ShowCase.dismiss(context);
  //   setState(() {
  //     _showShowCase = false;
  //     print(_showShowCase);
  //   });
  // }

  _nextIfAny() {
    ShowCase.completed(context, widget.key);
    _slideAnimationController.forward();
    _widthAnimationController.forward();
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
                // color: Colors.grey.withOpacity(0.3),
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
              widthAnimation: _widthAnimation,
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
              tooltipColor: widget.tooltipColor ?? Colors.white,
              textColor: widget.textColor ?? Colors.black,
              showArrow: widget.showArrow ?? true,
              cHeight: widget.cHeight,
              cWidht: widget.cWidht,
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
        translation: Offset(-0.5, -0.5),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: size.height + 16,
            width: Tween<double>(
              begin: 0,
              end: size.width + 16, //controls the opening of the slice
            ).animate(widthAnimation).value,
            decoration: ShapeDecoration(
              shape: shapeBorder ??
                  RoundedRectangleBorder(
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

class AnchoredOverlay extends StatelessWidget {
  final bool showOverlay;
  final Widget Function(BuildContext, Rect anchorBounds, Offset anchor)
      overlayBuilder;
  final Widget child;

  AnchoredOverlay({
    key,
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return OverlayBuilder(
          showOverlay: showOverlay,
          overlayBuilder: (BuildContext overlayContext) {
            // To calculate the "anchor" point we grab the render box of
            // our parent Container and then we find the center of that box.
            RenderBox box = context.findRenderObject() as RenderBox;
            final topLeft =
                box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
            final bottomRight =
                box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
            final Rect anchorBounds = Rect.fromLTRB(
              topLeft.dx,
              topLeft.dy,
              bottomRight.dx,
              bottomRight.dy,
            );
            final anchorCenter = box.size.center(topLeft);
            return overlayBuilder(overlayContext, anchorBounds, anchorCenter);
          },
          child: child,
        );
      },
    );
  }
}

class OverlayBuilder extends StatefulWidget {
  final bool showOverlay;
  final Widget Function(BuildContext) overlayBuilder;
  final Widget child;

  OverlayBuilder({
    key,
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  }) : super(key: key);

  @override
  _OverlayBuilderState createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.showOverlay) {
      // showOverlay();
      WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // syncWidgetAndOverlay();
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void reassemble() {
    super.reassemble();
    // syncWidgetAndOverlay();
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void dispose() {
    if (isShowingOverlay()) {
      hideOverlay();
    }

    super.dispose();
  }

  bool isShowingOverlay() => _overlayEntry != null;

  void showOverlay() {
    if (_overlayEntry == null) {
      // Create the overlay.
      _overlayEntry = OverlayEntry(
        builder: widget.overlayBuilder,
      );
      addToOverlay(_overlayEntry);
    } else {
      // Rebuild overlay.
      buildOverlay();
    }
  }

  void addToOverlay(OverlayEntry overlayEntry) async {
    Overlay.of(context).insert(overlayEntry);
    final overlay = Overlay.of(context);
    if (overlayEntry == null)
      WidgetsBinding.instance
          .addPostFrameCallback((_) => overlay.insert(overlayEntry));
  }

  void hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  void buildOverlay() async {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _overlayEntry?.markNeedsBuild());
  }

  @override
  Widget build(BuildContext context) {
    buildOverlay();

    return widget.child;
  }
}
