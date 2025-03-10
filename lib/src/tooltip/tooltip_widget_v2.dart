part of "tooltip.dart";

class TooltipLayoutSlot {
  static const String tooltipBox = 'toolTipBox';
  static const String actionBox = 'actionBox';
  static const String arrow = 'arrow';
}

class ToolTipWidgetV2 extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset; // This is not needed
  final Size screenSize; // This is also not needed
  final String? title;
  final TextAlign? titleTextAlign;
  final String? description;
  final TextAlign? descriptionTextAlign;
  final AlignmentGeometry titleAlignment;
  final AlignmentGeometry descriptionAlignment;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final FloatingActionWidget?
      floatingActionWidget; // This is not needed as we have shifted this to showcase
  final Color? tooltipBackgroundColor;
  final Color? textColor;
  final bool showArrow;
  final double? contentHeight; // Not needed
  final double? contentWidth; // Not needed
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

  const ToolTipWidgetV2({
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
  State<ToolTipWidgetV2> createState() => _ToolTipWidgetV2State();
}

class _ToolTipWidgetV2State extends State<ToolTipWidgetV2>
    with TickerProviderStateMixin {
  late final AnimationController _movingAnimationController;
  late final Animation<double> _movingAnimation;
  late final AnimationController _scaleAnimationController;
  late final Animation<double> _scaleAnimation;

  Offset parentCenter = Offset.zero;

  @override
  void initState() {
    super.initState();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.disableScaleAnimation && widget.isTooltipDismissed) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          _scaleAnimationController.reverse();
        },
      );
    }
  }

  @override
  void didUpdateWidget(covariant ToolTipWidgetV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.disableScaleAnimation && widget.isTooltipDismissed) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          _scaleAnimationController.reverse();
        },
      );
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
  void dispose() {
    _movingAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  final zeroPadding = EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    final defaultToolTipWidget = widget.container == null
        ? ClipRRect(
            borderRadius:
                widget.tooltipBorderRadius ?? BorderRadius.circular(8.0),
            child: MouseRegion(
              cursor: widget.onTooltipTap == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onTooltipTap,
                child: Container(
                  padding: widget.tooltipPadding?.copyWith(
                    left: 0,
                    right: 0,
                  ),
                  color: widget.tooltipBackgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.title != null)
                        Align(
                          alignment: widget.titleAlignment,
                          child: Padding(
                            padding: (widget.titlePadding ?? zeroPadding).add(
                              EdgeInsets.only(
                                left: widget.tooltipPadding?.left ?? 0,
                                right: widget.tooltipPadding?.right ?? 0,
                              ),
                            ),
                            child: Text(
                              widget.title!,
                              textAlign: widget.titleTextAlign,
                              textDirection: widget.titleTextDirection,
                              style: widget.titleTextStyle ??
                                  Theme.of(context).textTheme.titleLarge!.merge(
                                        TextStyle(
                                          color: widget.textColor,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      if (widget.description != null)
                        Align(
                          alignment: widget.descriptionAlignment,
                          child: Padding(
                            padding:
                                (widget.descriptionPadding ?? zeroPadding).add(
                              EdgeInsets.only(
                                left: widget.tooltipPadding?.left ?? 0,
                                right: widget.tooltipPadding?.right ?? 0,
                              ),
                            ),
                            child: Text(
                              widget.description!,
                              textAlign: widget.descriptionTextAlign,
                              textDirection: widget.descriptionTextDirection,
                              style: widget.descTextStyle ??
                                  Theme.of(context).textTheme.titleSmall!.merge(
                                        TextStyle(
                                          color: widget.textColor,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      if (widget.tooltipActions.isNotEmpty &&
                          widget.tooltipActionConfig.position.isInside)
                        _getActionWidget(insideWidget: true),
                    ],
                  ),
                ),
              ),
            ),
          )
        : MouseRegion(
            cursor: widget.onTooltipTap == null
                ? MouseCursor.defer
                : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onTooltipTap,
              child: Container(
                padding: zeroPadding,
                color: Colors.transparent,
                child: Center(
                  child: widget.container ?? const SizedBox.shrink(),
                ),
              ),
            ),
          );

    // Calculate the target position and size
    final targetPosition = widget.position!.box!.localToGlobal(Offset.zero);
    final targetSize = widget.position!.box!.size;

    return Material(
      type: MaterialType.transparency,
      child: AnimatedTooltipMultiLayout(
        scaleController: _scaleAnimationController,
        moveController: _movingAnimationController,
        scaleAnimation: _scaleAnimation,
        moveAnimation: _movingAnimation,
        targetPosition: targetPosition,
        targetSize: targetSize,
        position: widget.tooltipPosition,
        screenSize: MediaQuery.of(context).size,
        hasArrow: widget.showArrow,
        scaleAlignment: widget.scaleAnimationAlignment,
        hasSecondBox: widget.tooltipActions.isNotEmpty &&
            (widget.tooltipActionConfig.position.isOutside ||
                widget.container != null),
        toolTipSlideEndDistance: widget.toolTipSlideEndDistance,
        gapBetweenContentAndAction:
            widget.tooltipActionConfig.gapBetweenContentAndAction,
        screenEdgePadding: widget.toolTipMargin,
        children: [
          TooltipLayoutId(
            id: TooltipLayoutSlot.tooltipBox,
            child: defaultToolTipWidget,
          ),
          if (widget.tooltipActions.isNotEmpty &&
              (widget.tooltipActionConfig.position.isOutside ||
                  widget.container != null))
            TooltipLayoutId(
              id: TooltipLayoutSlot.actionBox,
              child: _getActionWidget(),
            ),
          if (widget.showArrow)
            TooltipLayoutId(
              id: TooltipLayoutSlot.arrow,
              child: CustomPaint(
                painter: _Arrow(
                  strokeColor: widget.tooltipBackgroundColor!,
                  strokeWidth: 10,
                  paintingStyle: PaintingStyle.fill,
                ),
                size: const Size(10, 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getActionWidget({
    bool insideWidget = false,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: ActionWidget(
        tooltipActionConfig: widget.tooltipActionConfig,
        outSidePadding: (insideWidget)
            ? EdgeInsets.only(
                left: widget.tooltipPadding?.left ?? 0,
                right: widget.tooltipPadding?.right ?? 0,
              )
            : zeroPadding,
        alignment: widget.tooltipActionConfig.alignment,
        crossAxisAlignment: widget.tooltipActionConfig.crossAxisAlignment,
        width: 1004,
        isArrowUp: insideWidget,
        children: widget.tooltipActions,
      ),
    );
  }
}
