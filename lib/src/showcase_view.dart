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
import 'dart:async';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'models/tooltip_action_button.dart';
import 'models/tooltip_action_config.dart';
import 'overlay_manager.dart';
import 'showcase/showcase.dart';
import 'showcase/showcase_controller.dart';
import 'showcase_service.dart';
import 'showcase_widget.dart';

/// Callback type for showcase events that need index and key information
typedef OnShowcaseCallback = void Function(int? showcaseIndex, GlobalKey key);

/// A controller class that manages showcase functionality independently.
///
/// This class provides a way to manage showcase state and control showcase flow
/// with customizable options like auto-play, animation, and user interaction.
class ShowcaseView {
  /// Creates and registers a [ShowcaseView] with the specified scope.
  ///
  /// Use this constructor to create a new showcase view and automatically register
  /// it with the [ShowcaseService].
  ShowcaseView.register({
    this.scope = Constants.defaultScope,
    this.onFinish,
    this.onStart,
    this.onComplete,
    this.onDismiss,
    this.autoPlay = false,
    this.autoPlayDelay = Constants.defaultAutoPlayDelay,
    this.enableAutoPlayLock = false,
    this.blurValue = 0,
    this.scrollDuration = Constants.defaultScrollDuration,
    this.disableMovingAnimation = false,
    this.disableScaleAnimation = false,
    this.enableAutoScroll = false,
    this.disableBarrierInteraction = false,
    this.enableShowcase = true,
    this.globalTooltipActionConfig,
    this.globalTooltipActions,
    this.globalFloatingActionWidget,
    this.hideFloatingActionWidgetForShowcase = const [],
  }) {
    ShowcaseService.instance.register(this, scope: scope);
    _hideFloatingWidgetKeys = {
      for (final item in hideFloatingActionWidgetForShowcase) item: true,
    };
  }

  /// Retrieves last registered [ShowcaseView].
  factory ShowcaseView.get() => ShowcaseService.instance.get();

  /// Retrieves registered Showcase with the specified scope.
  ///
  /// This is recommended to use when you have multiple scopes.
  factory ShowcaseView.getNamed(String scope) =>
      ShowcaseService.instance.get(scope: scope);

  /// Unique identifier for this manager instance
  final String scope;

  /// Triggered when all the showcases are completed
  final VoidCallback? onFinish;

  /// Triggered when showcase view is dismissed
  final OnDismissCallback? onDismiss;

  /// Triggered every time on start of each showcase
  final OnShowcaseCallback? onStart;

  /// Triggered every time on completion of each showcase
  final OnShowcaseCallback? onComplete;

  /// Whether all showcases will auto sequentially start
  /// having time interval of [autoPlayDelay]
  bool autoPlay;

  /// Visibility time of current showcase when [autoPlay] is enabled
  Duration autoPlayDelay;

  /// Whether blocking user interaction while [autoPlay] is enabled
  bool enableAutoPlayLock;

  /// Whether disabling bouncing/moving animation for all tooltips
  /// while showcasing
  bool disableMovingAnimation;

  /// Whether disabling initial scale animation for all the default tooltips
  /// when showcase is started and completed
  bool disableScaleAnimation;

  /// Whether disabling barrier interaction
  bool disableBarrierInteraction;

  /// Provides time duration for auto scrolling when [enableAutoScroll] is true
  Duration scrollDuration;

  /// Default overlay blur used by showcase
  double blurValue;

  /// While target widget is out viewport then
  /// whether enabling auto scroll so as to make the target widget visible
  bool enableAutoScroll;

  /// Enable/disable showcase globally
  bool enableShowcase;

  /// Custom static floating action widget to show a static widget anywhere
  /// on the screen for all the showcase widget
  FloatingActionBuilderCallback? globalFloatingActionWidget;

  /// Global action to apply on every tooltip widget
  List<TooltipActionButton>? globalTooltipActions;

  /// Global Config for tooltip action to auto apply for all the toolTip
  TooltipActionConfig? globalTooltipActionConfig;

  /// Hides [globalFloatingActionWidget] for the provided showcase widgets
  List<GlobalKey> hideFloatingActionWidgetForShowcase;

  /// Internal list to store showcase widget keys
  List<GlobalKey>? _ids;

  /// Current active showcase widget index
  int? _activeWidgetId;

  /// Timer for auto-play functionality
  Timer? _timer;

  /// Whether the manager is mounted and active
  bool _mounted = true;

  /// Map to store keys for which floating action widget should be hidden
  late final Map<GlobalKey, bool> _hideFloatingWidgetKeys;

  /// Returns whether showcase is completed by checking if ids and activeWidgetId are null
  bool get isShowCaseCompleted => _ids == null && _activeWidgetId == null;

  /// Returns list of keys for which floating action widget is hidden
  List<GlobalKey> get hiddenFloatingActionKeys =>
      _hideFloatingWidgetKeys.keys.toList();

  /// Returns current active showcase key if it exists and is within valid range
  GlobalKey? get getCurrentActiveShowcaseKey {
    if (_ids == null || _activeWidgetId == null) return null;

    if (_activeWidgetId! < _ids!.length && _activeWidgetId! >= 0) {
      return _ids![_activeWidgetId!];
    } else {
      return null;
    }
  }

  /// Returns whether showcase is currently running by checking active key
  bool get isShowcaseRunning => getCurrentActiveShowcaseKey != null;

  /// Returns list of showcase controllers for current active showcase
  List<ShowcaseController> get _getCurrentActiveControllers {
    return ShowcaseService.instance
            .getControllers(
              scope: scope,
            )[getCurrentActiveShowcaseKey]
            ?.values
            .toList() ??
        <ShowcaseController>[];
  }

  /// Cleans up resources when manager is unRegister
  void unregister() {
    if (isShowcaseRunning) {
      OverlayManager.instance.dispose(scope: scope);
    }
    ShowcaseService.instance.unregister(scope: scope);
    _mounted = false;
    _cancelTimer();
  }

  /// Returns floating action widget for given showcase key if not hidden
  ///
  /// * [showcaseKey] - The key of the showcase to check
  ///
  /// Returns null if the floating action widget is hidden for this key
  FloatingActionBuilderCallback? getFloatingActionWidget(
    GlobalKey showcaseKey,
  ) {
    return _hideFloatingWidgetKeys[showcaseKey] ?? false
        ? null
        : globalFloatingActionWidget;
  }

  /// Starts showcase with given widget ids after optional delay
  ///
  /// * [widgetIds] - List of GlobalKeys for widgets to showcase
  /// * [delay] - Optional delay before starting showcase
  ///
  /// Throws an exception if showcase is disabled
  void startShowCase(
    List<GlobalKey> widgetIds, {
    Duration delay = Duration.zero,
  }) {
    assert(_mounted, 'ShowcaseView is no longer mounted');
    if (!_mounted) return;

    final enclosingShowcase = _findEnclosingShowcaseView(widgetIds);

    enclosingShowcase._startShowcase(delay, widgetIds);
  }

  void _startShowcase(
    Duration delay,
    List<GlobalKey<State<StatefulWidget>>> widgetIds,
  ) {
    ShowcaseService.instance.updateCurrentScope(scope);
    if (!enableShowcase) {
      throw Exception(
        "You are trying to start Showcase while it has been disabled with "
        "`enableShowcase` parameter to false from ShowCaseWidget",
      );
    }
    if (delay == Duration.zero) {
      _ids = widgetIds;
      _activeWidgetId = 0;
      _onStart();
      OverlayManager.instance.update(
        show: isShowcaseRunning,
        scope: scope,
      );
    } else {
      Future.delayed(
        delay,
        () {
          _startShowcase(Duration.zero, widgetIds);
        },
      );
    }
  }

  ShowcaseView _findEnclosingShowcaseView(
    List<GlobalKey<State<StatefulWidget>>> widgetIds,
  ) {
    final currentScopeControllers =
        ShowcaseService.instance.getControllers(scope: scope);
    final keysNotInCurrentScope = {
      for (final key in widgetIds)
        if (!currentScopeControllers.containsKey(key)) key: true,
    };

    if (keysNotInCurrentScope.isEmpty) {
      return this;
    }

    final scopes = ShowcaseService.instance.scopes;
    final scopeLength = scopes.length;
    for (var i = 0; i < scopeLength; i++) {
      final otherScopeName = scopes[i];
      if (otherScopeName == scope || otherScopeName == Constants.initialScope) {
        continue;
      }

      final otherScope = ShowcaseService.instance.getScope(
        scope: otherScopeName,
      );
      final otherScopeShowcase = otherScope.showcaseView;
      final otherScopeControllers = otherScope.controllers;

      if (otherScopeControllers.keys.any(keysNotInCurrentScope.containsKey)) {
        return otherScopeShowcase;
      }
    }
    return this;
  }

  /// Updates the overlay to reflect current showcase state
  ///
  /// This method should be called when showcase state changes
  void updateOverlay() {
    OverlayManager.instance.update(
      show: isShowcaseRunning,
      scope: scope,
    );
  }

  /// Completes showcase for given key and starts next one
  ///
  /// * [key] - The key of the showcase to complete
  ///
  /// Will finish entire showcase if no more widgets to show
  void completed(GlobalKey? key) {
    if (_activeWidgetId == null ||
        _ids?[_activeWidgetId!] != key ||
        !_mounted) {
      return;
    }
    _onComplete().then(
      (_) {
        if (!_mounted) return;
        _activeWidgetId = _activeWidgetId! + 1;
        _processShowcaseUpdate();
      },
    );
  }

  /// Moves to next showcase if possible
  ///
  /// * [force] - Whether to ignore autoPlayLock, defaults to false
  ///
  /// Will finish entire showcase if no more widgets to show
  void next({bool force = false}) {
    if ((!force && enableAutoPlayLock) || _ids == null || !_mounted) {
      return;
    }

    _onComplete().then(
      (_) {
        if (!_mounted) return;
        _activeWidgetId = _activeWidgetId! + 1;
        _processShowcaseUpdate();
      },
    );
  }

  /// Moves to previous showcase if possible
  ///
  /// Does nothing if already at the first showcase
  void previous() {
    if (_ids == null || ((_activeWidgetId ?? 0) - 1) < 0 || !_mounted) {
      return;
    }
    _onComplete().then(
      (_) {
        if (!_mounted) return;

        _activeWidgetId = _activeWidgetId! - 1;
        _processShowcaseUpdate();
      },
    );
  }

  /// Process showcase update after navigation
  ///
  /// This method handles the common logic needed when navigating between showcases:
  /// - Starts the current showcase
  /// - Checks if we've reached the end of showcases
  /// - Updates the overlay to reflect current state
  void _processShowcaseUpdate() {
    _onStart();
    if (_activeWidgetId! >= _ids!.length) {
      _cleanupAfterSteps();
      onFinish?.call();
    }
    OverlayManager.instance.update(
      show: isShowcaseRunning,
      scope: scope,
    );
  }

  /// Dismisses the entire showcase and calls onDismiss callback
  void dismiss() {
    final idNotExist = _activeWidgetId == null ||
        _ids == null ||
        _ids!.length <= _activeWidgetId!;

    onDismiss?.call(idNotExist ? null : _ids?[_activeWidgetId!]);
    if (!_mounted) return;

    _cleanupAfterSteps();
    OverlayManager.instance.update(
      show: isShowcaseRunning,
      scope: scope,
    );
  }

  /// Updates list of showcase keys that should hide floating action widget
  ///
  /// * [updatedList] - New list of keys to hide floating action widget for
  void hideFloatingActionWidgetForKeys(List<GlobalKey> updatedList) {
    _hideFloatingWidgetKeys
      ..clear()
      ..addAll({
        for (final item in updatedList) item: true,
      });
  }

  /// Handles tap on barrier area
  ///
  /// * [config] - The showcase configuration for the current showcase
  ///
  /// Respects [disableBarrierInteraction] settings from both global and local config
  void handleBarrierTap(Showcase config) {
    config.onBarrierClick?.call();
    if (disableBarrierInteraction || config.disableBarrierInteraction) {
      return;
    }
    next();
  }

  /// Internal method to handle showcase start
  ///
  /// Initializes controllers and sets up auto-play timer if enabled
  Future<void> _onStart() async {
    if (_activeWidgetId! < _ids!.length) {
      onStart?.call(_activeWidgetId, _ids![_activeWidgetId!]);
      final controllers = _getCurrentActiveControllers;
      final controllerLength = controllers.length;
      for (var i = 0; i < controllerLength; i++) {
        final controller = controllers[i];
        final isAutoScroll =
            controller.config.enableAutoScroll ?? enableAutoScroll;
        if (controllerLength == 1 && isAutoScroll) {
          await controller.scrollIntoView();
        } else {
          controller.startShowcase();
        }
      }
    }

    if (autoPlay) {
      _cancelTimer();
      _timer = Timer(
        autoPlayDelay,
        () => next(force: true),
      );
    }
  }

  /// Internal method to handle showcase completion
  ///
  /// Runs reverse animations and triggers completion callbacks
  Future<void> _onComplete() async {
    final currentControllers = _getCurrentActiveControllers;
    final controllerLength = currentControllers.length;

    await Future.wait([
      for (var i = 0; i < controllerLength; i++)
        if (!(currentControllers[i].config.disableScaleAnimation ??
                disableScaleAnimation) &&
            currentControllers[i].reverseAnimationCallback != null)
          currentControllers[i].reverseAnimationCallback!.call(),
    ]);

    if (_activeWidgetId != null &&
        _ids != null &&
        _activeWidgetId! < _ids!.length) {
      onComplete?.call(_activeWidgetId, _ids![_activeWidgetId!]);
    }

    if (autoPlay) _cancelTimer();
  }

  /// Cancels auto-play timer if active
  void _cancelTimer() {
    if (!(_timer?.isActive ?? false)) return;
    _timer?.cancel();
    _timer = null;
  }

  /// Cleans up showcase state after completion
  void _cleanupAfterSteps() {
    _ids = null;
    _activeWidgetId = null;
    _cancelTimer();
  }
}
