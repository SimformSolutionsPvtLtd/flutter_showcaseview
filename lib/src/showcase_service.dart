import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'models/showcase_scope.dart';
import 'showcase/showcase_controller.dart';
import 'showcase_view.dart';

/// A scoped service locator for showcase functionality
///
/// This class provides global access to [ShowcaseView] instances without requiring
/// a BuildContext, similar to the GetIt service locator pattern, but with support
/// for multiple independent scopes.
class ShowcaseService {
  /// Private constructor to prevent external instantiation
  ShowcaseService._();

  /// Singleton instance of the service
  static final ShowcaseService _instance = ShowcaseService._();

  /// Returns the global instance of the service
  static ShowcaseService get instance => _instance;

  /// Map of scope names to showcase managers
  final Map<String, ShowcaseScope> _managers = {};

  /// Map of scope names to showcase controllers

  /// Stack of scope names to track navigation
  final List<String> _scopeStack = [Constants.initialScope];

  /// Current active scope name
  String get currentScope => _scopeStack.last;

  /// Registers a [ShowcaseView] with the service in the specified scope
  ///
  /// * [showcaseView] - The showcase manager to register
  /// * [scope] - Optional scope name (defaults to current scope)
  void register(ShowcaseView showcaseView, {String? scope}) {
    final scopeName = scope ?? currentScope;
    _managers[scopeName] = ShowcaseScope(
      showcaseView: showcaseView,
      scope: scopeName,
    );

    // If a new scope is provided, push it to the stack
    if (scope == null || scope == currentScope) return;

    _scopeStack.add(scope);
  }

  /// Unregisters the [ShowcaseView] from the specified scope
  ///
  /// * [scope] - Optional scope name (defaults to current scope)
  void unregister({String? scope}) {
    final scopeName = scope ?? currentScope;
    _managers.remove(scopeName);

    // If we're removing the current scope, pop it from the stack
    if (scopeName != currentScope || _scopeStack.isEmpty) return;
    _scopeStack.removeLast();
  }

  /// Push a new scope to the stack without registering a manager
  ///
  /// Useful when navigating to a new screen
  void pushScope(String scope) {
    if (_scopeStack.contains(scope)) return;
    _scopeStack.add(scope);
  }

  /// Pop the current scope from the stack
  ///
  /// Returns to previous scope, useful when popping a screen
  void popScope() {
    if (_scopeStack.isEmpty) return;
    _scopeStack.removeLast();
  }

  /// Returns whether a manager is registered in the specified scope
  ///
  /// * [scope] - Optional scope name (defaults to current scope)
  bool isRegistered({String? scope}) {
    final scopeName = scope ?? currentScope;
    return _managers.containsKey(scopeName);
  }

  ShowcaseScope getShowcaseManager({String? scope}) {
    final scopeName = scope ?? currentScope;
    final manager = _managers[scopeName];
    if (manager == null) {
      throw Exception('No ShowcaseManager registered for scope "$scopeName". '
          'Make sure ShowCaseWidget is initialized in this scope.');
    }
    return manager;
  }

  Map<GlobalKey, Map<int, ShowcaseController>> getShowCaseControllers({
    required String scope,
  }) =>
      getShowcaseManager(scope: scope).controllers;

  /// Returns the [ShowcaseView] from the specified scope
  ///
  /// * [scope] - Optional scope name (defaults to current scope)
  ///
  /// Throws an exception if no manager is registered in the specified scope
  ShowcaseView get({String? scope}) =>
      getShowcaseManager(scope: scope ?? currentScope).showcaseView;

  /// Registers a showcase controller for given key and ID
  void registerShowcaseController({
    required GlobalKey key,
    required ShowcaseController controller,
    required int showcaseId,
    required String scope,
  }) {
    getShowCaseControllers(scope: scope)
        .putIfAbsent(
          key,
          () => {},
        )
        .update(
          showcaseId,
          (value) => controller,
          ifAbsent: () => controller,
        );
  }

  /// Removes showcase controller for given key and ID
  void removeShowcaseController({
    required GlobalKey key,
    required int uniqueShowcaseKey,
    required String scope,
  }) {
    getShowCaseControllers(scope: scope).remove(
      uniqueShowcaseKey,
    );
  }

  /// Returns showcase controller for given key and ID
  /// Throws assertion error if controller not found
  ShowcaseController getControllerForShowcase({
    required GlobalKey key,
    required int showcaseId,
    required String scope,
  }) {
    final controller = getShowCaseControllers(scope: scope)[key]?[showcaseId];
    assert(
      controller != null,
      'Please register showcase controller first by calling '
      'registerShowcaseController',
    );
    return controller!;
  }
}
