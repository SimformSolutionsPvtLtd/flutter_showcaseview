import 'package:flutter/material.dart';
import 'package:showcaseview/get_position.dart';

class Content extends StatelessWidget {
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

  Content({
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
  });

  bool isCloseToTopOrBottom(Offset position) {
    return (screenSize.height - position.dy) <= 100;
  }

  String findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return 'A';
    } else {
      return 'B';
    }
  }

  double _getTooltipWidth() {
    double width = 80;
    width += (description.length * 6);
    return width;
  }

  bool _isLeft() {
    double screenWidht = screenSize.width / 3;
    return !(screenWidht <= position.getCenter());
  }

  bool _isRight() {
    double screenWidht = screenSize.width / 3;
    return ((screenWidht * 2) <= position.getCenter());
  }

  double _getLeft() {
    if (_isLeft()) {
      return position.getCenter() - (_getTooltipWidth() * 0.2);
    }
    if (_isRight()) {
      return position.getCenter() - (_getTooltipWidth());
    } else {
      return position.getCenter() - (_getTooltipWidth() * 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentOrientation = findPositionForContent(offset);
    final contentOffsetMultiplier = contentOrientation == "B" ? 1.0 : -1.0;
    final contentY = contentOffsetMultiplier == 1.0
        ? position.getBottom() + (contentOffsetMultiplier * 3)
        : position.getTop() + (contentOffsetMultiplier * 3);
    final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);

    double padingTop = contentOffsetMultiplier == 1 ? 22 : 0;
    double padingBottom = contentOffsetMultiplier == 1 ? 0 : 27;

    if (!showArrow) {
      padingTop = 10;
      padingBottom = 10;
    }

    if (container == null) {
      double leftPos = _getLeft();
      return Stack(
        children: <Widget>[
          showArrow ? _getArrow(contentOffsetMultiplier) : Container(),
          Positioned(
            top: contentY,
            left: leftPos,
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
                        EdgeInsets.only(top: padingTop, bottom: padingBottom),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        color: tooltipColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, top: 8),
                              child: Text(
                                title,
                                style: titleTextStyle ??
                                    Theme.of(context).textTheme.title,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                description,
                                style: descTextStyle ??
                                    Theme.of(context).textTheme.subtitle,
                              ),
                            ),
                          ],
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
          showArrow ? _getArrow(contentOffsetMultiplier) : Container(),
          Positioned(
            top: contentOffsetMultiplier == 1 ? contentY + 10 : contentY - 10,
            left: position.getCenter() - 30,
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 5),
                  end: Offset(0.0, 0.100),
                ).animate(animationOffset),
                child: Container(
                  child: Material(
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                          padding: EdgeInsets.only(
                              top: padingTop, bottom: padingBottom),
                          child: container),
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
      top: contentOffsetMultiplier == 1.0
          ? position.getBottom()
          : position.getTop(),
      left: position.getCenter() - 25,
      child: FractionalTranslation(
          translation: Offset(0.0, contentFractionalOffset),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, contentFractionalOffset / 5),
              end: Offset(0.0, 0.100),
            ).animate(animationOffset),
            child: contentOffsetMultiplier == 1.0
                ? Icon(
                    Icons.arrow_drop_up,
                    color: tooltipColor,
                    size: 50.0,
                  )
                : Icon(
                    Icons.arrow_drop_down,
                    color: tooltipColor,
                    size: 50.0,
                  ),
          )),
    );
  }
}
