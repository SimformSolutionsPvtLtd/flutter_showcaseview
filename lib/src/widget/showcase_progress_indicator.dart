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

/// A widget that displays progress information during a showcase sequence.
///
/// This widget shows the current step and progress through a series of
/// showcases, helping users understand their position in the tour.
class ShowcaseProgressIndicator extends StatelessWidget {
  /// Creates a showcase progress indicator.
  const ShowcaseProgressIndicator({
    super.key,
    required this.config,
    required this.currentIndex,
    required this.totalCount,
  });

  /// The configuration for the progress indicator.
  final ProgressIndicatorConfig config;

  /// The current showcase index (0-based).
  final int currentIndex;

  /// The total number of showcases.
  final int totalCount;

  /// Calculates the current progress as a value between 0.0 and 1.0.
  double get progress {
    if (totalCount <= 0) return 0.0;
    final safeIndex = currentIndex.clamp(0, totalCount - 1);
    return (safeIndex + 1) / totalCount;
  }

  @override
  Widget build(BuildContext context) {
    if (!config.enabled || totalCount <= 1) {
      return const SizedBox.shrink();
    }

    // Use custom builder if provided
    if (config.customBuilder != null) {
      return Container(
        constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        child: config.customBuilder!(
          context,
          currentIndex,
          totalCount,
          progress,
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      child: _DefaultProgressIndicator(
        config: config,
        currentIndex: currentIndex,
        totalCount: totalCount,
        progress: progress,
      ),
    );
  }
}

/// The default progress indicator implementation.
class _DefaultProgressIndicator extends StatelessWidget {
  const _DefaultProgressIndicator({
    required this.config,
    required this.currentIndex,
    required this.totalCount,
    required this.progress,
  });

  final ProgressIndicatorConfig config;
  final int currentIndex;
  final int totalCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: config.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (config.showStepNumbers) ...[
              Text(
                '${currentIndex + 1} of $totalCount',
                style: config.textStyle ??
                    TextStyle(
                      color: config.progressColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (config.showProgressBar) const SizedBox(height: 8),
            ],
            if (config.showProgressBar)
              _ProgressBar(
                progress: progress,
                config: config,
              ),
          ],
        ),
      ),
    );
  }
}

/// A custom progress bar widget.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.config,
  });

  final double progress;
  final ProgressIndicatorConfig config;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 100.0;

        return Container(
          width: width,
          height: config.height,
          decoration: BoxDecoration(
            color: config.progressColor.withValues(alpha: 0.3),
            borderRadius: config.borderRadius,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width * progress.clamp(0.0, 1.0),
              height: config.height,
              decoration: BoxDecoration(
                color: config.progressColor,
                borderRadius: config.borderRadius,
              ),
            ),
          ),
        );
      },
    );
  }
}
