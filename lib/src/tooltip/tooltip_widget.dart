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
part of "tooltip.dart";

class ToolTipWidget extends StatefulWidget {
  const ToolTipWidget({
    super.key,
    required this.title,
    required this.description,
    required this.titleTextStyle,
    required this.descTextStyle,
    required this.container,
    required this.tooltipBackgroundColor,
    required this.textColor,
    required this.showArrow,
    required this.onTooltipTap,
    required this.movingAnimationDuration,
    required this.titleTextAlign,
    required this.descriptionTextAlign,
    required this.titleAlignment,
    required this.descriptionAlignment,
    required this.tooltipActionConfig,
    required this.tooltipActions,
    required this.targetPadding,
    required this.disableMovingAnimation,
    required this.disableScaleAnimation,
    required this.tooltipBorderRadius,
    required this.scaleAnimationDuration,
    required this.scaleAnimationCurve,
    required this.toolTipMargin,
    required this.showcaseController,
    required this.tooltipPadding,
    required this.toolTipSlideEndDistance,
    this.scaleAnimationAlignment,
    this.tooltipPosition,
    this.titlePadding,
    this.descriptionPadding,
    this.titleTextDirection,
    this.descriptionTextDirection,
  });

  final String? title;
  final TextAlign? titleTextAlign;
  final String? description;
  final TextAlign? descriptionTextAlign;
  final AlignmentGeometry titleAlignment;
  final AlignmentGeometry descriptionAlignment;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final Color? tooltipBackgroundColor;
  final Color? textColor;
  final bool showArrow;
  final VoidCallback? onTooltipTap;
  final EdgeInsets? tooltipPadding;
  final Duration movingAnimationDuration;
  final bool disableMovingAnimation;
  final bool disableScaleAnimation;
  final BorderRadius? tooltipBorderRadius;
  final Duration scaleAnimationDuration;
  final Curve scaleAnimationCurve;
  final Alignment? scaleAnimationAlignment;
  final TooltipPosition? tooltipPosition;
  final EdgeInsets? titlePadding;
  final EdgeInsets? descriptionPadding;
  final TextDirection? titleTextDirection;
  final TextDirection? descriptionTextDirection;
  final double toolTipSlideEndDistance;
  final double toolTipMargin;
  final TooltipActionConfig tooltipActionConfig;
  final List<Widget> tooltipActions;
  final EdgeInsets targetPadding;
  final ShowcaseController showcaseController;

  @override
  State<ToolTipWidget> createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget>
    with TickerProviderStateMixin {
  late final AnimationController _movingAnimationController =
      AnimationController(
    duration: widget.movingAnimationDuration,
    vsync: this,
  );

  late final Animation<double> _movingAnimation = CurvedAnimation(
    parent: _movingAnimationController,
    curve: Curves.easeInOut,
  );

  late final AnimationController _scaleAnimationController =
      AnimationController(
    duration: widget.scaleAnimationDuration,
    vsync: this,
    lowerBound: widget.disableScaleAnimation ? 1 : 0,
  );
  late final Animation<double> _scaleAnimation = CurvedAnimation(
    parent: _scaleAnimationController,
    curve: widget.scaleAnimationCurve,
  );

  @override
  void initState() {
    super.initState();
    if (widget.disableScaleAnimation) {
      movingAnimationListener();
    } else {
      _scaleAnimationController
        ..addStatusListener((scaleAnimationStatus) {
          if (scaleAnimationStatus != AnimationStatus.completed) {
            return;
          }
          movingAnimationListener();
        })
        ..forward();
    }
    if (!widget.disableMovingAnimation) {
      _movingAnimationController.forward();
    }
    widget.showcaseController.reverseAnimationCallback =
        widget.disableScaleAnimation ? null : _scaleAnimationController.reverse;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the target position and size
    final box = widget.showcaseController.position?.renderBox;
    // This is a workaround to avoid the error when the widget is not mounted
    // but won't happen in general cases
    if (box == null || !box.attached) {
      return const SizedBox.shrink();
    }
    final targetPosition = box.localToGlobal(Offset.zero);
    final targetSize = box.size;

    final defaultToolTipWidget = widget.container != null
        ? MouseRegion(
            cursor: widget.onTooltipTap == null
                ? MouseCursor.defer
                : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onTooltipTap,
              child: Center(
                child: widget.container ?? const SizedBox.shrink(),
              ),
            ),
          )
        : ClipRRect(
            borderRadius: widget.tooltipBorderRadius ??
                const BorderRadius.all(
                  Radius.circular(8.0),
                ),
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
                        DefaultTooltipTextWidget(
                          padding: (widget.titlePadding ?? EdgeInsets.zero).add(
                            EdgeInsets.only(
                              left: widget.tooltipPadding?.left ?? 0,
                              right: widget.tooltipPadding?.right ?? 0,
                            ),
                          ),
                          text: widget.title!,
                          textAlign: widget.titleTextAlign,
                          alignment: widget.titleAlignment,
                          textColor: widget.textColor,
                          textDirection: widget.titleTextDirection,
                          textStyle: widget.titleTextStyle ??
                              Theme.of(context).textTheme.titleLarge!.merge(
                                    TextStyle(
                                      color: widget.textColor,
                                    ),
                                  ),
                        ),
                      if (widget.description != null)
                        DefaultTooltipTextWidget(
                          padding:
                              (widget.descriptionPadding ?? EdgeInsets.zero)
                                  .add(
                            EdgeInsets.only(
                              left: widget.tooltipPadding?.left ?? 0,
                              right: widget.tooltipPadding?.right ?? 0,
                            ),
                          ),
                          text: widget.description!,
                          textAlign: widget.descriptionTextAlign,
                          alignment: widget.descriptionAlignment,
                          textColor: widget.textColor,
                          textDirection: widget.descriptionTextDirection,
                          textStyle: widget.descTextStyle ??
                              Theme.of(context).textTheme.titleSmall!.merge(
                                    TextStyle(
                                      color: widget.textColor,
                                    ),
                                  ),
                        ),
                      if (widget.tooltipActions.isNotEmpty &&
                          widget.tooltipActionConfig.position.isInside)
                        ActionWidget(
                          tooltipActionConfig: widget.tooltipActionConfig,
                          outsidePadding: EdgeInsets.only(
                            left: widget.tooltipPadding?.left ?? 0,
                            right: widget.tooltipPadding?.right ?? 0,
                          ),
                          alignment: widget.tooltipActionConfig.alignment,
                          crossAxisAlignment:
                              widget.tooltipActionConfig.crossAxisAlignment,
                          children: widget.tooltipActions,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );

    return Material(
      type: MaterialType.transparency,
      child: _AnimatedTooltipMultiLayout(
        scaleController: _scaleAnimationController,
        moveController: _movingAnimationController,
        scaleAnimation: _scaleAnimation,
        moveAnimation: _movingAnimation,
        targetPosition: targetPosition,
        targetSize: targetSize,
        position: widget.tooltipPosition,
        screenSize: widget.showcaseController.rootWidgetSize ??
            MediaQuery.of(context).size,
        hasArrow: widget.showArrow,
        targetPadding: widget.targetPadding,
        scaleAlignment: widget.scaleAnimationAlignment,
        hasSecondBox: widget.tooltipActions.isNotEmpty &&
            (widget.tooltipActionConfig.position.isOutside ||
                widget.container != null),
        toolTipSlideEndDistance: widget.toolTipSlideEndDistance,
        gapBetweenContentAndAction:
            widget.tooltipActionConfig.gapBetweenContentAndAction,
        screenEdgePadding: widget.toolTipMargin,
        showcaseOffset: widget.showcaseController.rootRenderObject
                ?.localToGlobal(Offset.zero) ??
            Offset.zero,
        children: [
          _TooltipLayoutId(
            id: TooltipLayoutSlot.tooltipBox,
            child: defaultToolTipWidget,
          ),
          if (widget.tooltipActions.isNotEmpty &&
              (widget.tooltipActionConfig.position.isOutside ||
                  widget.container != null))
            _TooltipLayoutId(
              id: TooltipLayoutSlot.actionBox,
              child: ActionWidget(
                tooltipActionConfig: widget.tooltipActionConfig,
                outsidePadding: EdgeInsets.zero,
                alignment: widget.tooltipActionConfig.alignment,
                crossAxisAlignment:
                    widget.tooltipActionConfig.crossAxisAlignment,
                children: widget.tooltipActions,
              ),
            ),
          if (widget.showArrow)
            _TooltipLayoutId(
              id: TooltipLayoutSlot.arrow,
              child: CustomPaint(
                painter: _Arrow(
                  strokeColor: widget.tooltipBackgroundColor!,
                ),
                size: const Size(
                  Constants.arrowWidth,
                  Constants.arrowHeight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _movingAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  void movingAnimationListener() {
    // We have added check at the call of the this function but still this
    // will be our last defence
    if (widget.disableMovingAnimation) return;

    _movingAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _movingAnimationController.reverse();
      }
      if (_movingAnimationController.isDismissed &&
          !widget.disableMovingAnimation) {
        _movingAnimationController.forward();
      }
    });
  }
}
