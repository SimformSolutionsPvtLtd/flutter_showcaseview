import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'models/showcase_scope.dart';
import 'showcase/showcase_controller.dart';
import 'showcase_view.dart';
import 'utils/extensions.dart';

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
  final Map<String, ShowcaseScope> _showcaseViews = {};

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
    _showcaseViews[scopeName] = ShowcaseScope(
      showcaseView: showcaseView,
      name: scopeName,
    );

    // If a new scope is provided, push it to the stack
    if (scope == null || scope == currentScope) return;

    _scopeStack.add(scope);
  }

  /// Unregisters the [ShowcaseView] from the specified scope
  ///
  /// * [scope] - Optional scope name (defaults to current scope)
  String? unregister({String? scope}) {
    final scopeName = scope ?? currentScope;
    _showcaseViews.remove(scopeName);

    // If we're removing the current scope, pop it from the stack
    _scopeStack.removeFirstWhere(
      (element) => element == scope,
    );
    return scope;
  }

  /// Returns whether a manager is registered in the specified scope
  ///
  /// * [scope] - Optional scope name (defaults to current scope)
  bool isRegistered({String? scope}) {
    final scopeName = scope ?? currentScope;
    return _showcaseViews.containsKey(scopeName);
  }

  ShowcaseScope getScope({String? scope}) {
    final scopeName = scope ?? currentScope;
    final manager = _showcaseViews[scopeName];
    if (manager == null) {
      throw Exception('No ShowcaseManager registered for scope "$scopeName". '
          'Make sure ShowCaseWidget is initialized in this scope.');
    }
    return manager;
  }

  Map<GlobalKey, Map<int, ShowcaseController>> getControllers({
    required String scope,
  }) =>
      getScope(scope: scope).controllers;

  /// Returns the [ShowcaseView] from the specified scope
  ///
  /// * [scope] - Optional scope name (defaults to current scope)
  ///
  /// Throws an exception if no manager is registered in the specified scope
  ShowcaseView get({String? scope}) =>
      getScope(scope: scope ?? currentScope).showcaseView;

  /// Registers a showcase controller for given key and ID
  void registerController({
    required GlobalKey key,
    required ShowcaseController controller,
    required int id,
    required String scope,
  }) {
    getControllers(scope: scope)
        .putIfAbsent(
          key,
          () => {},
        )
        .update(
          id,
          (value) => controller,
          ifAbsent: () => controller,
        );
  }

  /// Removes showcase controller for given key and ID
  void removeController({
    required GlobalKey key,
    required int id,
    required String scope,
  }) {
    getControllers(scope: scope).remove(
      id,
    );
  }

  /// Returns showcase controller for given key and ID
  /// Throws assertion error if controller not found
  ShowcaseController getController({
    required GlobalKey key,
    required int id,
    required String scope,
  }) {
    final controller = getControllers(scope: scope)[key]?[id];
    assert(
      controller != null,
      'Please register showcase controller first by calling '
      'registerShowcaseController',
    );
    return controller!;
  }
}
