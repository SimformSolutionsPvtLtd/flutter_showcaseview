import 'package:flutter/widgets.dart';

class ToolTipSlideTransition extends AnimatedWidget {
  /// [SlideTransition] could have been used instead of this widget,
  /// but it internally uses [FractionalTranslation] which affects the
  /// transformation based on the size of a child. This widget uses
  /// [Transform.translate] which would fix translation independent of the
  /// child's size.
  const ToolTipSlideTransition({
    required Listenable position,
    required this.child,
  }) : super(listenable: position);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progress = listenable as Animation<Offset>;
    return Transform.translate(
      offset: progress.value,
      child: child,
    );
  }
}
