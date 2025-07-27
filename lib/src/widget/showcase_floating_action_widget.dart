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

import '../models/progress_indicator_config.dart';
import '../showcase/showcase_view.dart';
import '../widget/showcase_progress_indicator.dart';
import 'floating_action_widget.dart';

/// A floating action widget that combines progress indicator with custom action widgets.
///
/// This widget provides a cohesive UI by showing the progress indicator alongside
/// action buttons in a single floating container.
class ShowcaseFloatingActionWidget extends FloatingActionWidget {
  /// Creates a combined floating action widget with progress indicator.
  ShowcaseFloatingActionWidget({
    super.key,
    required this.showcaseView,
    required this.originalFloatingWidget,
    this.progressPosition = ProgressIndicatorPosition.top,
    this.spacing = 12.0,
  }) : super(
          left: originalFloatingWidget.left,
          top: originalFloatingWidget.top,
          right: originalFloatingWidget.right,
          bottom: originalFloatingWidget.bottom,
          child: _buildCombinedWidget(
            showcaseView,
            originalFloatingWidget,
            progressPosition,
            spacing,
          ),
        );

  /// The showcase view instance to get progress information from.
  final ShowcaseView showcaseView;

  /// The original floating widget provided by the user.
  final FloatingActionWidget originalFloatingWidget;

  /// Position of the progress indicator relative to the action widget.
  final ProgressIndicatorPosition progressPosition;

  /// Spacing between progress indicator and action widget.
  final double spacing;

  /// Builds the combined widget with progress indicator and action widget.
  static Widget _buildCombinedWidget(
    ShowcaseView showcaseView,
    FloatingActionWidget originalFloatingWidget,
    ProgressIndicatorPosition progressPosition,
    double spacing,
  ) {
    final progressConfig = showcaseView.progressIndicatorConfig;

    // If progress is disabled, just return the original widget's child
    if (!progressConfig.enabled) {
      return originalFloatingWidget.child;
    }

    final currentIndex = showcaseView.currentShowcaseIndex;
    final totalCount = showcaseView.totalShowcaseCount;

    // Safety checks: if showcase data is not ready or single showcase, don't show progress
    if (currentIndex == null || totalCount <= 1) {
      return originalFloatingWidget.child;
    }

    final progressIndicator = Container(
      constraints: const BoxConstraints(minWidth: 0),
      child: ShowcaseProgressIndicator(
        config: progressConfig,
        currentIndex: currentIndex,
        totalCount: totalCount,
      ),
    );

    final isVerticalLayout =
        progressPosition == ProgressIndicatorPosition.top ||
            progressPosition == ProgressIndicatorPosition.bottom;

    return Container(
      constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      child: isVerticalLayout
          ? _buildVerticalLayout(
              progressIndicator,
              originalFloatingWidget.child,
              progressPosition,
              spacing,
            )
          : _buildHorizontalLayout(
              progressIndicator,
              originalFloatingWidget.child,
              progressPosition,
              spacing,
            ),
    );
  }

  /// Builds vertical layout with progress indicator above or below the action widget.
  static Widget _buildVerticalLayout(
    Widget progressIndicator,
    Widget actionWidget,
    ProgressIndicatorPosition position,
    double spacing,
  ) {
    final children = position == ProgressIndicatorPosition.top
        ? [progressIndicator, SizedBox(height: spacing), actionWidget]
        : [actionWidget, SizedBox(height: spacing), progressIndicator];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  /// Builds horizontal layout with progress indicator beside the action widget.
  static Widget _buildHorizontalLayout(
    Widget progressIndicator,
    Widget actionWidget,
    ProgressIndicatorPosition position,
    double spacing,
  ) {
    final children = position == ProgressIndicatorPosition.left
        ? [progressIndicator, SizedBox(width: spacing), actionWidget]
        : [actionWidget, SizedBox(width: spacing), progressIndicator];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
