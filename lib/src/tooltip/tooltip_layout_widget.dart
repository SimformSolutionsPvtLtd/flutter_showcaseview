part of 'tooltip.dart';

class _TooltipLayoutId extends ParentDataWidget<MultiChildLayoutParentData> {
  const _TooltipLayoutId({
    required this.id,
    required super.child,
  });

  final Object id;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final parentData = renderObject.parentData! as MultiChildLayoutParentData;

    if (parentData.id == id) return;

    parentData.id = id;
    final targetObject = renderObject.parent;
    if (targetObject is! RenderObject) {
      return;
    }
    targetObject.markNeedsLayout();
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _AnimatedTooltipMultiLayout;
}
