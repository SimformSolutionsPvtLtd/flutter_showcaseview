part of 'tooltip.dart';

class TooltipLayoutId extends ParentDataWidget<MultiChildLayoutParentData> {
  final Object id;

  const TooltipLayoutId({
    super.key,
    required this.id,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final parentData = renderObject.parentData! as MultiChildLayoutParentData;
    if (parentData.id != id) {
      parentData.id = id;
      final targetObject = renderObject.parent;
      if (targetObject is RenderObject) {
        targetObject.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => AnimatedTooltipMultiLayout;
}
