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

  Content(
      {this.position,
      this.offset,
      this.screenSize,
      this.title,
      this.description,
      this.animationOffset,
      this.titleTextStyle,
      this.descTextStyle,
      this.container});

  bool isCloseToTopOrBottom(Offset position) {
    return (screenSize.height - position.dy) <= 100;
  }

  bool isLeft() {
    double screenWidht = screenSize.width / 2;
    return !(screenWidht <= position.getCenter());
  }

  String findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return 'A';
    } else {
      return 'B';
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

    if (container == null) {
      return Positioned(
        top: contentY,
        right: 16,
        left: 16,
        child: FractionalTranslation(
          translation: Offset(0.0, contentFractionalOffset),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, contentFractionalOffset / 5),
              end: Offset(0.0, 0.100),
            ).animate(animationOffset),
            child: Container(
              width: screenSize.width,
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: <Widget>[
                    _getUpArrow(contentOffsetMultiplier),
                    Column(
                      children: <Widget>[
                        contentOffsetMultiplier == 1
                            ? SizedBox(
                                height: 28.0,
                              )
                            : Container(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: screenSize.width,
                            padding: EdgeInsets.only(left: 40, right: 40),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 4, top: 8),
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
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 37,
                        ),
                        _getDownArrow(contentOffsetMultiplier),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Positioned(
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
                  child: Container(child: container),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _getUpArrow(contentOffsetMultiplier) {
    return contentOffsetMultiplier == 1.0
        ? Positioned(
            left: position.getCenter() - 40,
            child: Icon(
              Icons.arrow_drop_up,
              color: Colors.white,
              size: 50.0,
            ))
        : Container();
  }

  Widget _getDownArrow(contentOffsetMultiplier) {
    return Container(
      width: screenSize.width,
      child: contentOffsetMultiplier == -1.0
          ? Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(left: position.getCenter() - 40),
              child: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 50.0,
              ),
            )
          : Container(),
    );
  }
}
