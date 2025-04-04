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

import 'showcase_widget.dart';

/// Displays an overlay Widget as constructed by the given [overlayBuilder].
///
/// The overlay built by the [overlayBuilder] can be conditionally shown and
/// hidden by settings the [showOverlay] property to true or false.
///
/// The [overlayBuilder] is invoked every time this Widget is rebuilt.
///
/// Implementation note: the reason we rebuild the overlay every time our state
/// changes is because there doesn't seem to be any better way to invalidate the
/// overlay itself than to invalidate this Widget. Remember, overlay Widgets
/// exist in [OverlayEntry]s which are inaccessible to outside Widgets. But if
/// a better approach is found then feel free to use it.
class OverlayBuilder extends StatefulWidget {
  const OverlayBuilder({
    super.key,
    required this.child,
    required this.updateOverlay,
    this.overlayBuilder,
  });

  final WidgetBuilder? overlayBuilder;
  final Widget child;

  /// A callback that provides a way to control the overlay visibility from
  /// showcase widget
  /// Basically we pass a reference to [_updateOverlay] function to parent so we
  /// can call this from parent class to update the overlay
  /// This callback provides a function that can be called with a boolean
  /// parameter to show (true) or hide (false) the overlay.
  final ValueSetter<ValueSetter<bool>> updateOverlay;

  @override
  State<OverlayBuilder> createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry? _overlayEntry;

  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();

    if (_showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
    }
    widget.updateOverlay.call(_updateOverlay);
  }

  void _updateOverlay(bool showOverlay) {
    _showOverlay = showOverlay;
    buildOverlay();
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
  }

  @override
  void reassemble() {
    super.reassemble();
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
        builder: widget.overlayBuilder!,
      );
      addToOverlay(_overlayEntry!);
    } else {
      // Rebuild overlay.
      buildOverlay();
    }
  }

  void addToOverlay(OverlayEntry overlayEntry) async {
    if (mounted) {
      final showCaseContext = ShowCaseWidget.of(context).context;
      // TODO: switch to Overlay.maybeOf once we support dart 2.19 minimum.
      final showCaseOverlay =
          showCaseContext.findAncestorStateOfType<OverlayState>();
      final overlay = context.findAncestorStateOfType<OverlayState>();
      (showCaseOverlay ?? overlay)?.insert(overlayEntry);
    }
  }

  void hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !_showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && _showOverlay) {
      showOverlay();
    }
  }

  void buildOverlay() async {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _overlayEntry?.markNeedsBuild());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
