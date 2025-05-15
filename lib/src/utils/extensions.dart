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
import 'dart:ui';

extension ListExtension<E> on List<E> {
  /// Removes and returns the first element that satisfies the provided test
  /// function. If no element satisfies the test, returns the result of
  /// calling [orElse], or null if [orElse] is omitted.
  E? removeFirstWhere(
    bool Function(E element) test, {
    E Function()? orElse,
  }) {
    final length = this.length;
    for (var i = 0; i < length; i++) {
      final element = this[i];
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

extension ColorExtension on Color {
  /// Converts opacity value to color with alpha
  /// This avoids using the deprecated overlayOpacity directly
  Color reduceOpacity(double opacity) => withAlpha((opacity * 255).round());
}
