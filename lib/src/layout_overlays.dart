/*
 * Copyright © 2020, Simform Solutions
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import 'package:flutter/material.dart';

/// Displays an overlay Widget anchored directly above the center of this
/// [AnchoredOverlay].
///
/// The overlay Widget is created by invoking the provided [overlayBuilder].
///
/// The [anchor] position is provided to the [overlayBuilder], but the builder
/// does not have to respect it. In other words, the [overlayBuilder] can
/// interpret the meaning of "anchor" however it wants - the overlay will not
/// be forced to be centered about the [anchor].
///
/// The overlay built by this [AnchoredOverlay] can be conditionally shown
/// and hidden by settings the [showOverlay] property to true or false.
///
/// The [overlayBuilder] is invoked every time this Widget is rebuilt.
///
class AnchoredOverlay extends StatelessWidget {
  final bool showOverlay;
  final Widget Function(BuildContext, Rect anchorBounds, Offset anchor)?
      overlayBuilder;
  final Widget? child;

  AnchoredOverlay({
    Key? key,
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OverlayBuilder(
          showOverlay: showOverlay,
          overlayBuilder: (overlayContext) {
            // To calculate the "anchor" point we grab the render box of
            // our parent Container and then we find the center of that box.
            final box = context.findRenderObject() as RenderBox;
            final topLeft =
                box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
            final bottomRight =
                box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
            final anchorBounds = Rect.fromLTRB(
              topLeft.dx,
              topLeft.dy,
              bottomRight.dx,
              bottomRight.dy,
            );
            final anchorCenter = box.size.center(topLeft);
            return overlayBuilder!(overlayContext, anchorBounds, anchorCenter);
          },
          child: child,
        );
      },
    );
  }
}

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
  final bool showOverlay;
  final Widget Function(BuildContext)? overlayBuilder;
  final Widget? child;

  OverlayBuilder({
    Key? key,
    this.showOverlay = false,
    this.overlayBuilder,
    this.child,
  }) : super(key: key);

  @override
  _OverlayBuilderState createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.showOverlay) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => showOverlay());
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => syncWidgetAndOverlay());
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
    Overlay.of(context)!.insert(overlayEntry);
  }

  void hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  void buildOverlay() async {
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _overlayEntry?.markNeedsBuild());
  }

  @override
  Widget build(BuildContext context) {
    buildOverlay();

    return widget.child!;
  }
}
