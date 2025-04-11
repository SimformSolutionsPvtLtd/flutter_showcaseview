extension ListExtension<E> on List<E> {
  /// Removes and returns the first element that satisfies the provided test function.
  /// If no element satisfies the test, returns the result of calling [orElse],
  /// or null if [orElse] is omitted.
  E? removeFirstWhere(
    bool Function(E element) test, {
    E Function()? orElse,
  }) {
    int length = this.length;
    for (int i = 0; i < length; i++) {
      E element = this[i];
      if (test(element)) {
        removeAt(i);
        return element;
      }
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    if (orElse != null) return orElse();
    return null;
  }
}
