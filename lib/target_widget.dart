import 'package:flutter/material.dart';

class TargetWidget extends StatefulWidget {
  final String widgetId;
  final Widget child;
  final String title;
  final String description;

  const TargetWidget({
    Key key,
    @required this.widgetId,
    @required this.child,
    this.title,
    this.description,
  }) : super(key: key);

  @override
  _TargetWidgetState createState() => _TargetWidgetState();
}

class _TargetWidgetState extends State<TargetWidget> {
  bool _showShowCase = true;

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

  buildOverlayOnTarget(
          Offset offset, Size size, Rect rectBound, Size screenSize) =>
      Visibility(
        visible: _showShowCase,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _showShowCase = false;
                  print(_showShowCase);
                });
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            _Target(
              offset: offset,
              size: size,
            ),
            _Content(
              title: widget.title,
              description: widget.description,
              rectBound: rectBound,
              offset: offset,
              screenSize: screenSize,
              widgetSize: size,
            ),
          ],
        ),
      );
}

class _Content extends StatelessWidget {
  final String title;
  final String description;
  final Rect rectBound;
  final Offset offset;
  final Size screenSize;
  final Size widgetSize;

  const _Content({
    Key key,
    this.title,
    this.description,
    this.rectBound,
    this.offset,
    this.screenSize,
    this.widgetSize,
  }) : super(key: key);

  bool isCloseToTopOrBottom(Offset position) {
    return position.dy <= 88.0 || (screenSize.height - position.dy) <= 88.0;
  }

  bool isOnTopHalfOfScreen(Offset position) {
    return position.dy < (screenSize.height / 2.0);
  }

  String findPostionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      if (isOnTopHalfOfScreen(position)) {
        return "B";
      } else {
        return "A";
      }
    } else {
      if (isOnTopHalfOfScreen(position)) {
        return "A";
      } else {
        return "B";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentOrientation = findPostionForContent(offset);
    print(contentOrientation);
    final contentOffsetMultiplier = contentOrientation == "B" ? 1.0 : -1.0;
    final contentY = offset.dy +
        (contentOffsetMultiplier *
            (contentOrientation == "A"
                ? (widgetSize.height + 48)
                : widgetSize.height));

    return Positioned(
      top: contentY,
      right: 16,
      left: 16,
      child: Card(
        elevation: 4,
        child: Container(
          height: 48,
          width: screenSize.width,
          child: Material(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    title,
                  ),
                ),
                Expanded(
                  child: Text(
                    description,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Target extends StatelessWidget {
  final Offset offset;
  final Size size;

  const _Target({
    Key key,
    @required this.offset,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(offset);

    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: FractionalTranslation(
        translation: Offset(-0.5, -0.5),
        child: GestureDetector(
          onTap: () {
            print("tapped");
          },
          child: Container(
            height: size.height + 16,
            width: size.width + 16,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(),
              color: Colors.grey.withOpacity(0.7),
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
    return Container(
      // This LayoutBuilder gives us the opportunity to measure the above
      // Container to calculate the "anchor" point at its center.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return OverlayBuilder(
            showOverlay: showOverlay,
            overlayBuilder: (BuildContext overlayContext) {
              // To calculate the "anchor" point we grab the render box of
              // our parent Container and then we find the center of that box.
              RenderBox box = context.findRenderObject() as RenderBox;
              final topLeft =
                  box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
              final bottomRight = box.size
                  .bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
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
      ),
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

  // void addToOverlay(OverlayEntry entry) async {
  //   Overlay.of(context).insert(entry);
  // }

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
