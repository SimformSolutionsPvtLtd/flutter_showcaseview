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

      if (length != this.length) throw ConcurrentModificationError(this);
    }
    return orElse?.call();
  }
}

/// Extension on `Color` that provides non-deprecated, stable access to
/// ARGB channels and utility functions across all Flutter versions.
///
/// ⚠️ NOTE:
/// - Starting from **Flutter 3.22**, the following `Color` properties are deprecated:
///   - `.red`, `.green`, `.blue`, `.alpha`, `.opacity`
/// - This extension uses bitmasking on the `.value` field to extract
///   ARGB components without relying on deprecated APIs.
extension ColorExtension on Color {
  /// Reduces the opacity of this color by the [opacity] factor (0.0 to 1.0).
  ///
  /// ✅ Avoids using deprecated `.opacity` or `.alpha` properties.
  /// ✅ Uses `.withAlpha()` with calculated alpha from the factor.
  ///
  /// Works in all Flutter versions, including Flutter 3.22+.
  Color reduceOpacity(double opacity) =>
      withAlpha((opacity.clamp(0.0, 1.0) * 255).round());

  /// Safe replacement for deprecated `.alpha` (Flutter >= 3.22)
  int get safeAlpha => (value >> 24) & 0xFF;

  /// Safe replacement for deprecated `.red` (Flutter >= 3.22)
  int get safeRed => (value >> 16) & 0xFF;

  /// Safe replacement for deprecated `.green` (Flutter >= 3.22)
  int get safeGreen => (value >> 8) & 0xFF;

  /// Safe replacement for deprecated `.blue` (Flutter >= 3.22)
  int get safeBlue => value & 0xFF;

  /// Safe replacement for deprecated `.opacity` (Flutter >= 3.22)
  double get safeOpacity => safeAlpha / 255.0;
}
