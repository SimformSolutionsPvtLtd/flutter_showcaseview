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

import '../models/tooltip_action_button.dart';
import '../models/tooltip_action_config.dart';
import '../utils/constants.dart';
import '../utils/enum.dart';
import '../utils/overlay_manager.dart';
import '../widget/floating_action_widget.dart';
import 'showcase_controller.dart';
import 'showcase_service.dart';

/// Callback type for showcase events that need index and key information
typedef OnShowcaseCallback = void Function(int? showcaseIndex, GlobalKey key);

/// Callback function type for building a floating action widget.
///
/// Parameters:
///   * [context] - The build context used to access the ShowcaseView state.
typedef FloatingActionBuilderCallback = FloatingActionWidget Function(
  BuildContext context,
);

/// Callback function type for handling showcase dismissal events.
///
/// This callback is triggered when a showcase is dismissed, providing the key
/// of the dismissed showcase widget if available.
typedef OnDismissCallback = void Function(
  /// The key on which showcase is dismissed. Null if no showcase was active.
  GlobalKey? dismissedAt,
);

class ShowcaseView {
  /// Creates and registers a [ShowcaseView] with the specified [scope].
  ///
  /// A controller class that manages showcase functionality independently.
  ///
  /// This class provides a way to manage showcase state and configure various
  /// options like auto-play, animation, and many more.
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

  /// Retrieves registered Showcase with the specified [scope].
  ///
  /// This is recommended to use when you have multiple scopes registered.
  factory ShowcaseView.getNamed(String scope) =>
      ShowcaseService.instance.get(scope: scope);

  /// The enclosing scope for this instance.
  final String scope;

  /// Triggered when all the showcases are completed.
  final VoidCallback? onFinish;

  /// Triggered when showcase view is dismissed.
  final OnDismissCallback? onDismiss;

  /// Triggered every time on start of each showcase.
  final OnShowcaseCallback? onStart;

  /// Triggered every time on completion of each showcase.
  final OnShowcaseCallback? onComplete;

  /// Whether all showcases will auto sequentially start
  /// having time interval of [autoPlayDelay].
  bool autoPlay;

  /// Visibility time of current showcase when [autoPlay] is enabled.
  Duration autoPlayDelay;

  /// Whether blocking user interaction while [autoPlay] is enabled.
  bool enableAutoPlayLock;

  /// Whether to disable bouncing/moving animation for all tooltips while
  /// showcasing.
  bool disableMovingAnimation;

  /// Whether to disable scale animation for all the default tooltips when
  /// showcase appears and goes away.
  bool disableScaleAnimation;

  /// Whether to disable barrier interaction.
  bool disableBarrierInteraction;

  /// Determines the time taken to scroll when [enableAutoScroll] is true.
  Duration scrollDuration;

  /// The overlay blur used by showcase.
  double blurValue;

  /// Whether to enable auto scroll as to bring the target widget in the
  /// viewport.
  bool enableAutoScroll;

  /// Enable/disable showcase globally.
  bool enableShowcase;

  /// Custom static floating action widget to show a static non-animating
  /// widget anywhere on the screen for all the showcase widget.
  FloatingActionBuilderCallback? globalFloatingActionWidget;

  /// Global action to show on every tooltip widget.
  List<TooltipActionButton>? globalTooltipActions;

  /// Global Config for tooltip action to auto apply for all the tooltip.
  TooltipActionConfig? globalTooltipActionConfig;

  /// Hides [globalFloatingActionWidget] for the provided showcase widgets.
  List<GlobalKey> hideFloatingActionWidgetForShowcase;

  /// Internal list to store showcase widget keys.
  List<GlobalKey>? _ids;

  /// Current active showcase widget index.
  int? _activeWidgetId;

  /// Timer for auto-play functionality.
  Timer? _timer;

  /// Whether the manager is mounted and active.
  bool _mounted = true;

  /// Map to store keys for which floating action widget should be hidden.
  late final Map<GlobalKey, bool> _hideFloatingWidgetKeys;

  /// Returns whether showcase is completed or not.
  bool get isShowCaseCompleted => _ids == null && _activeWidgetId == null;

  /// Returns list of keys for which floating action widget is hidden.
  List<GlobalKey> get hiddenFloatingActionKeys =>
      _hideFloatingWidgetKeys.keys.toList();

  /// Returns the current active showcase key if any.
  GlobalKey? get getActiveShowcaseKey {
    if (_ids == null || _activeWidgetId == null) return null;

    if (_activeWidgetId! < _ids!.length && _activeWidgetId! >= 0) {
      return _ids![_activeWidgetId!];
    } else {
      return null;
    }
  }

  /// Returns whether showcase is currently running or not.
  bool get isShowcaseRunning => getActiveShowcaseKey != null;

  /// Returns list of showcase controllers for current active showcase.
  List<ShowcaseController> get _getCurrentActiveControllers {
    return ShowcaseService.instance
            .getControllers(
              scope: scope,
            )[getActiveShowcaseKey]
            ?.values
            .toList() ??
        <ShowcaseController>[];
  }

  /// Starts showcase with given widget ids after the optional delay.
  ///
  /// * [widgetIds] - List of GlobalKeys for widgets to showcase
  /// * [delay] - Optional delay before starting showcase
  void startShowCase(
    List<GlobalKey> widgetIds, {
    Duration delay = Duration.zero,
  }) {
    assert(_mounted, 'ShowcaseView is no longer mounted');
    if (!_mounted) return;
    _findEnclosingShowcaseView(widgetIds)._startShowcase(delay, widgetIds);
  }

  /// Moves to next showcase if possible.
  ///
  /// Will finish entire showcase if no more widgets to show.
  ///
  /// * [force] - Whether to ignore autoPlayLock, defaults to false.
  void next({bool force = false}) {
    if ((!force && enableAutoPlayLock) || _ids == null || !_mounted) {
      return;
    }
    _changeSequence(ShowcaseProgressType.forward);
  }

  /// Moves to previous showcase if possible.
  ///
  /// Does nothing if already at the first showcase.
  void previous() {
    if (_ids == null || ((_activeWidgetId ?? 0) - 1).isNegative || !_mounted) {
      return;
    }
    _changeSequence(ShowcaseProgressType.backward);
  }

  /// Completes showcase for given key and starts next one.
  ///
  /// * [key] - The key of the showcase to complete.
  ///
  /// Will finish entire showcase if no more widgets to show.
  void completed(GlobalKey? key) {
    if (_activeWidgetId == null ||
        _ids?[_activeWidgetId!] != key ||
        !_mounted) {
      return;
    }
    _changeSequence(ShowcaseProgressType.forward);
  }

  /// Dismisses the entire showcase and calls [onDismiss] callback.
  void dismiss() {
    final idDoesNotExist =
        _activeWidgetId == null || (_ids?.length ?? -1) <= _activeWidgetId!;

    onDismiss?.call(idDoesNotExist ? null : _ids?[_activeWidgetId!]);
    if (!_mounted) return;

    _cleanupAfterSteps();
    OverlayManager.instance.update(
      show: isShowcaseRunning,
      scope: scope,
    );
  }

  /// Cleans up resources when unregistering the showcase view.
  void unregister() {
    if (isShowcaseRunning) {
      OverlayManager.instance.dispose(scope: scope);
    }
    ShowcaseService.instance.unregister(scope: scope);
    _mounted = false;
    _cancelTimer();
  }

  /// Updates the overlay to reflect current showcase state.
  void updateOverlay() =>
      OverlayManager.instance.update(show: isShowcaseRunning, scope: scope);

  /// Updates list of showcase keys that should hide floating action widget.
  ///
  /// * [updatedList] - New list of keys to hide floating action widget for
  void hideFloatingActionWidgetForKeys(List<GlobalKey> updatedList) {
    _hideFloatingWidgetKeys
      ..clear()
      ..addAll({
        for (final item in updatedList) item: true,
      });
  }

  /// Returns floating action widget for given showcase key if not hidden.
  ///
  /// * [showcaseKey] - The key of the showcase to check.
  FloatingActionBuilderCallback? getFloatingActionWidget(
    GlobalKey showcaseKey,
  ) {
    return _hideFloatingWidgetKeys[showcaseKey] ?? false
        ? null
        : globalFloatingActionWidget;
  }

  void _startShowcase(
    Duration delay,
    List<GlobalKey<State<StatefulWidget>>> widgetIds,
  ) {
    assert(
      enableShowcase,
      'You are trying to start Showcase while it has been disabled with '
      '[enableShowcase] parameter.',
    );
    if (!enableShowcase) return;

    ShowcaseService.instance.updateCurrentScope(scope);
    if (delay == Duration.zero) {
      _ids = widgetIds;
      _activeWidgetId = 0;
      _onStart();
      OverlayManager.instance.update(
        show: isShowcaseRunning,
        scope: scope,
      );
    } else {
      Future.delayed(delay, () => _startShowcase(Duration.zero, widgetIds));
    }
  }

  /// Process showcase update after navigation
  ///
  /// This method handles the common logic needed when navigating between
  /// showcases:
  /// - Starts the current showcase
  /// - Checks if we've reached the end of showcases
  /// - Updates the overlay to reflect current state
  void _changeSequence(ShowcaseProgressType type) {
    assert(_activeWidgetId != null, 'Please ensure to call startShowcase.');
    final id = switch (type) {
      ShowcaseProgressType.forward => _activeWidgetId! + 1,
      ShowcaseProgressType.backward => _activeWidgetId! - 1,
    };
    _onComplete().then(
      (_) {
        if (!_mounted) return;
        _activeWidgetId = id;
        _onStart();
        if (_activeWidgetId! >= _ids!.length) {
          _cleanupAfterSteps();
          onFinish?.call();
        }
        OverlayManager.instance.update(show: isShowcaseRunning, scope: scope);
      },
    );
  }

  /// Finds the appropriate ShowcaseView that can handle all the specified
  /// widget keys.
  ///
  /// This method searches through all registered scopes to find a
  /// [ShowcaseView] that contains all the widget keys in [widgetIds]. This
  /// is necessary when starting a showcase that might include widgets
  /// registered across different scopes.
  ///
  /// * [widgetIds] - List of GlobalKeys for widgets to showcase
  ///
  /// Returns either the current ShowcaseView if all keys are in this scope, or
  /// another scope's ShowcaseView that contains the keys not found in the
  /// current scope.
  ShowcaseView _findEnclosingShowcaseView(
    List<GlobalKey<State<StatefulWidget>>> widgetIds,
  ) {
    final currentScopeControllers =
        ShowcaseService.instance.getControllers(scope: scope);
    final keysNotInCurrentScope = {
      for (final key in widgetIds)
        if (!currentScopeControllers.containsKey(key)) key: true,
    };

    if (keysNotInCurrentScope.isEmpty) return this;

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
      final otherScopeControllers = otherScope.controllers;

      if (otherScopeControllers.keys.any(keysNotInCurrentScope.containsKey)) {
        return otherScope.showcaseView;
      }
    }
    return this;
  }

  /// Internal method to handle showcase start.
  ///
  /// Initializes controllers and sets up auto-play timer if enabled.
  Future<void> _onStart() async {
    _activeWidgetId ??= 0;
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
      // Showcase is first.
      final config = _getCurrentActiveControllers[_activeWidgetId!];
      _timer = Timer(
        config.config.autoPlayDelay ?? autoPlayDelay,
        () => next(force: true),
      );
    }
  }

  /// Internal method to handle showcase completion.
  ///
  /// Runs reverse animations and triggers completion callbacks.
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

    final activeId = _activeWidgetId ?? -1;
    if (activeId < (_ids?.length ?? activeId)) {
      onComplete?.call(activeId, _ids![activeId]);
    }

    if (autoPlay) _cancelTimer();
  }

  /// Cancels auto-play timer if active.
  void _cancelTimer() {
    if (!(_timer?.isActive ?? false)) return;
    _timer?.cancel();
    _timer = null;
  }

  /// Cleans up showcase state after completion.
  void _cleanupAfterSteps() {
    _ids = _activeWidgetId = null;
    _cancelTimer();
  }
}
