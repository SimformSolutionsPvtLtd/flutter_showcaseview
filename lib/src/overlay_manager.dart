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

import 'package:flutter/material.dart';

import 'constants.dart';
import 'models/linked_showcase_data.dart';
import 'shape_clipper.dart';
import 'showcase/showcase_controller.dart';
import 'showcase_service.dart';
import 'showcase_view.dart';

/// A singleton manager class responsible for displaying and controlling overlays
/// in the ShowcaseView.
///
/// This class manages the creation, display, and removal of overlays used by the
/// showcase system. It coordinates with [ShowcaseView] to control overlay visibility
/// and maintains the current showcase scope.
class OverlayManager {
  /// Private constructor for singleton implementation
  OverlayManager._();

  /// Singleton instance of the manager
  static final _instance = OverlayManager._();

  /// Public accessor for the singleton instance
  static OverlayManager get instance => _instance;

  /// The overlay state where entries will be inserted
  OverlayState? overlayState;

  /// Current overlay entry being displayed
  OverlayEntry? _overlayEntry;

  /// Flag to determine if overlay should be shown
  var _shouldShow = false;

  /// The current showcase scope identifier
  var _currentScope = Constants.initialScope;

  /// Returns whether an overlay is currently being displayed
  bool get _isShowing => _overlayEntry != null;

  /// Updates the overlay visibility based on the provided showcase view
  ///
  /// This method is called from showcase widgets to control overlay visibility.
  /// If the scope has changed, it will dispose the previous overlay.
  ///
  /// * [show] - Whether to show or hide the overlay
  /// * [showcaseView] - The showcase view requesting this update
  void update({
    required bool show,
    required ShowcaseView showcaseView,
  }) {
    if (_currentScope != showcaseView.scope) {
      dispose(scope: _currentScope);
      _currentScope = showcaseView.scope;
      return;
    }
    _shouldShow = show;
    _buildOverlay();
    _sync(showcaseView);
  }

  /// Updates the overlay state reference used by the manager
  ///
  /// This method allows setting or updating the [OverlayState] that will be used
  /// for inserting overlay entries.
  ///
  /// * [overlayState] - The new overlay state to use, can be null
  void updateState(OverlayState? overlayState) {
    this.overlayState = overlayState;
  }

  /// Disposes the overlay for the specified scope
  ///
  /// Hides the overlay if it's currently showing and matches the provided scope.
  ///
  /// * [scope] - The scope to dispose overlays for
  void dispose({required String scope}) {
    if (!_isShowing || _currentScope != scope) {
      return;
    }
    _hide();
  }

  /// Shows the overlay using the provided builder
  ///
  /// Creates a new overlay entry if none exists, otherwise rebuilds the existing one.
  void _show(WidgetBuilder overlayBuilder) {
    if (_overlayEntry != null) {
      // Rebuild overlay.
      _buildOverlay();
      return;
    }
    // Create the overlay.
    _overlayEntry = OverlayEntry(
      builder: overlayBuilder,
    );
    _add(_overlayEntry!);
  }

  /// Adds the overlay entry to the overlay state
  ///
  /// Safely handles the case where overlay state might be null.
  void _add(OverlayEntry overlayEntry) {
    if (overlayState == null) return;
    overlayState!.insert(overlayEntry);
  }

  /// Removes and clears the current overlay entry
  void _hide() {
    if (_overlayEntry == null) return;
    _overlayEntry!.remove();
    _overlayEntry = null;
  }

  /// Synchronizes the overlay visibility with the showcase manager state
  ///
  /// Shows or hides the overlay based on the [_shouldShow] flag.
  void _sync(ShowcaseView showcaseView) {
    if (_isShowing && !_shouldShow) {
      _hide();
    } else if (!_isShowing && _shouldShow) {
      _show((_) => _getBuilder(showcaseView));
    }
  }

  /// Creates and returns the overlay widget structure
  ///
  /// Builds a stack with background and tooltip widgets based on active controllers.
  Widget _getBuilder(ShowcaseView showcaseView) {
    final controller = ShowcaseService.instance
            .getControllers(
              scope: showcaseView.scope,
            )[showcaseView.getCurrentActiveShowcaseKey]
            ?.values
            .toList() ??
        <ShowcaseController>[];

    if (controller.isEmpty) {
      return const SizedBox.shrink();
    }

    final controllerLength = controller.length;
    for (var i = 0; i < controllerLength; i++) {
      controller[i].updateControllerData();
    }

    final firstController = controller.first;
    final firstShowcaseConfig = firstController.config;

    final backgroundContainer = ColoredBox(
      color: firstShowcaseConfig.overlayColor
          //ignore: deprecated_member_use
          .withOpacity(firstShowcaseConfig.overlayOpacity),
      child: const Align(),
    );

    return Stack(
      children: [
        GestureDetector(
          onTap: () => showcaseView.handleBarrierTap(firstShowcaseConfig),
          child: ClipPath(
            clipper: RRectClipper(
              area: Rect.zero,
              isCircle: false,
              radius: BorderRadius.zero,
              overlayPadding: EdgeInsets.zero,
              linkedObjectData: _getLinkedShowcasesData(controller),
            ),
            child: firstController.blur == 0
                ? backgroundContainer
                : BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: firstController.blur,
                      sigmaY: firstController.blur,
                    ),
                    child: backgroundContainer,
                  ),
          ),
        ),
        ...controller.expand((object) => object.getToolTipWidget).toList(),
      ],
    );
  }

  /// Extracts and returns linked showcase data from controllers
  ///
  /// Filters out null data and collects valid linked showcase information.
  List<LinkedShowcaseDataModel> _getLinkedShowcasesData(
    List<ShowcaseController> controllers,
  ) {
    final controllerLength = controllers.length;
    return [
      for (var i = 0; i < controllerLength; i++)
        if (controllers[i].linkedShowcaseDataModel != null)
          controllers[i].linkedShowcaseDataModel!,
    ];
  }

  /// Forces the overlay entry to rebuild
  void _buildOverlay() => _overlayEntry?.markNeedsBuild();
}
