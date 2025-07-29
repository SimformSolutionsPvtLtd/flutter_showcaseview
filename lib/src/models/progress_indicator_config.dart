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

import 'package:flutter/material.dart';

/// Defines the position of the progress indicator on the screen.
enum ProgressIndicatorPosition {
  /// Shows the progress indicator at the top of the screen
  top,

  /// Shows the progress indicator at the bottom of the screen
  bottom,

  /// Shows the progress indicator at the left of the screen
  left,

  /// Shows the progress indicator at the right of the screen
  right,
}

/// Callback function type for building a custom progress indicator widget.
///
/// Parameters:
///   * [context] - The build context
///   * [currentIndex] - The current showcase index (0-based)
///   * [totalCount] - The total number of showcases
///   * [progress] - The progress as a value between 0.0 and 1.0
typedef ProgressIndicatorBuilder = Widget Function(
  BuildContext context,
  int currentIndex,
  int totalCount,
  double progress,
);

/// Configuration for the showcase progress indicator.
///
/// This class defines how the progress indicator should appear and behave
/// during a showcase sequence.
class ProgressIndicatorConfig {
  /// Creates a progress indicator configuration.
  const ProgressIndicatorConfig({
    this.enabled = false,
    this.position = ProgressIndicatorPosition.top,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.backgroundColor = Colors.black54,
    this.progressColor = Colors.white,
    this.textStyle,
    this.showStepNumbers = true,
    this.showProgressBar = true,
    this.customBuilder,
    this.height = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
  });

  /// Whether to show the progress indicator during showcase.
  final bool enabled;

  /// Position of the progress indicator on the screen.
  final ProgressIndicatorPosition position;

  /// Padding around the progress indicator container.
  final EdgeInsets padding;

  /// Background color of the progress indicator container.
  final Color backgroundColor;

  /// Color of the progress bar and text.
  final Color progressColor;

  /// Text style for the step numbers (if shown).
  final TextStyle? textStyle;

  /// Whether to show step numbers like "1 of 5".
  final bool showStepNumbers;

  /// Whether to show the progress bar.
  final bool showProgressBar;

  /// Custom builder for the progress indicator widget.
  /// If provided, this overrides the default progress indicator.
  final ProgressIndicatorBuilder? customBuilder;

  /// Height of the progress bar.
  final double height;

  /// Border radius of the progress bar.
  final BorderRadius borderRadius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgressIndicatorConfig &&
        enabled == other.enabled &&
        position == other.position &&
        padding == other.padding &&
        backgroundColor == other.backgroundColor &&
        progressColor == other.progressColor &&
        textStyle == other.textStyle &&
        showStepNumbers == other.showStepNumbers &&
        showProgressBar == other.showProgressBar &&
        customBuilder == other.customBuilder &&
        height == other.height &&
        borderRadius == other.borderRadius;
  }

  @override
  int get hashCode => Object.hashAllUnordered([
        enabled,
        position,
        padding,
        backgroundColor,
        progressColor,
        textStyle,
        showStepNumbers,
        showProgressBar,
        customBuilder,
        height,
        borderRadius,
      ]);
}
