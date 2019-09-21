import 'package:flutter/material.dart';
import 'package:showcaseview/get_position.dart';

class ToolTipWidget extends StatelessWidget {
  final GetPosition position;
  final Offset offset;
  final Size screenSize;
  final String title;
  final String description;
  final Animation<double> animationOffset;
  final TextStyle titleTextStyle;
  final TextStyle descTextStyle;
  final Widget container;
  final Color tooltipColor;
  final Color textColor;
  final bool showArrow;
  final double contentHeight;
  final double contentWidth;
  static bool isArrowUp;
  final VoidCallback onTooltipTap;

  ToolTipWidget({
    this.position,
    this.offset,
    this.screenSize,
    this.title,
    this.description,
    this.animationOffset,
    this.titleTextStyle,
    this.descTextStyle,
    this.container,
    this.tooltipColor,
    this.textColor,
    this.showArrow,
    this.contentHeight,
    this.contentWidth,
    this.onTooltipTap,
  });

  bool isCloseToTopOrBottom(Offset position) {
    double height = 120;
    if (contentHeight != null) {
      height = contentHeight;
    }
    return (screenSize.height - position.dy) <= height;
  }

  String findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return 'ABOVE';
    } else {
      return 'BELOW';
    }
  }

  double _getTooltipWidth() {
    double titleLength = title == null ? 0 : (title.length * 10.0);
    double descriptionLength = (description.length * 7.0);
    if (titleLength > descriptionLength) {
      return titleLength + 10;
    } else {
      return descriptionLength + 10;
    }
  }

  bool _isLeft() {
    double screenWidth = screenSize.width / 3;
    return !(screenWidth <= position.getCenter());
  }

  bool _isRight() {
    double screenWidth = screenSize.width / 3;
    return ((screenWidth * 2) <= position.getCenter());
  }

  double _getLeft() {
    if (_isLeft()) {
      double leftPadding = position.getCenter() - (_getTooltipWidth() * 0.1);
      if (leftPadding + _getTooltipWidth() > screenSize.width) {
        leftPadding = (screenSize.width - 20) - _getTooltipWidth();
      }
      if (leftPadding < 20) {
        leftPadding = 14;
      }
      return leftPadding;
    } else if (!(_isRight())) {
      return position.getCenter() - (_getTooltipWidth() * 0.5);
    } else {
      return null;
    }
  }

  double _getRight() {
    if (_isRight()) {
      double rightPadding = position.getCenter() + (_getTooltipWidth() / 2);
      if (rightPadding + _getTooltipWidth() > screenSize.width) {
        rightPadding = 14;
      }
      return rightPadding;
    } else if (!(_isLeft())) {
      return position.getCenter() - (_getTooltipWidth() * 0.5);
    } else {
      return null;
    }
  }

  double _getSpace() {
    double space = position.getCenter() - (contentWidth / 2);
    if (space + contentWidth > screenSize.width) {
      space = screenSize.width - contentWidth - 8;
    } else if (space < (contentWidth / 2)) {
      space = 16;
    }
    return space;
  }

  @override
  Widget build(BuildContext context) {
    final contentOrientation = findPositionForContent(offset);
    final contentOffsetMultiplier = contentOrientation == "BELOW" ? 1.0 : -1.0;
    isArrowUp = contentOffsetMultiplier == 1.0 ? true : false;

    final contentY = isArrowUp
        ? position.getBottom() + (contentOffsetMultiplier * 3)
        : position.getTop() + (contentOffsetMultiplier * 3);

    final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);

    double paddingTop = isArrowUp ? 22 : 0;
    double paddingBottom = isArrowUp ? 0 : 27;

    if (!showArrow) {
      paddingTop = 10;
      paddingBottom = 10;
    }

    if (container == null) {
      return Stack(
        children: <Widget>[
          showArrow ? _getArrow(contentOffsetMultiplier) : Container(),
          Positioned(
            top: contentY,
            left: _getLeft(),
            right: _getRight(),
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: Offset(0.0, 0.100),
                ).animate(animationOffset),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding:
                        EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: onTooltipTap,
                        child: Container(
                          width: _getTooltipWidth(),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          color: tooltipColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  crossAxisAlignment: title != null
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.center,
                                  children: <Widget>[
                                    title != null
                                        ? Text(
                                            title,
                                            style: titleTextStyle ??
                                                Theme.of(context)
                                                    .textTheme
                                                    .title
                                                    .merge(TextStyle(
                                                        color: textColor)),
                                          )
                                        : Container(),
                                    Text(
                                      description,
                                      style: descTextStyle ??
                                          Theme.of(context)
                                              .textTheme
                                              .subtitle
                                              .merge(TextStyle(color: textColor)),
                                    ),
                                  ],
                                ),
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
          )
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned(
            left: _getSpace(),
            top: contentY - 10,
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 5),
                  end: Offset(0.0, 0.100),
                ).animate(animationOffset),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: onTooltipTap,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: paddingTop,
                      ),
                      color: Colors.transparent,
                      child: Center(
                        child: container,
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

  Widget _getArrow(contentOffsetMultiplier) {
    final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);
    return Positioned(
      top: isArrowUp ? position.getBottom() : position.getTop() - 1,
      left: position.getCenter() - 24,
      child: FractionalTranslation(
        translation: Offset(0.0, contentFractionalOffset),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, contentFractionalOffset / 5),
            end: Offset(0.0, 0.150),
          ).animate(animationOffset),
          child: isArrowUp
              ? Icon(
                  Icons.arrow_drop_up,
                  color: tooltipColor,
                  size: 50,
                )
              : Icon(
                  Icons.arrow_drop_down,
                  color: tooltipColor,
                  size: 50,
                ),
        ),
      ),
    );
  }
}
