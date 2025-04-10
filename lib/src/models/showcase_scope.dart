import 'package:flutter/widgets.dart';

import '../showcase/showcase_controller.dart';
import '../showcase_view.dart';

class ShowcaseScope {
  ShowcaseScope({
    required this.scope,
    required this.showcaseView,
  });

  final String scope;
  final ShowcaseView showcaseView;

  /// A mapping of showcase keys to their associated controllers
  /// - Key: GlobalKey of a showcase (provided by user)
  /// - Value: Map of showcase IDs to their controllers
  Map<GlobalKey, Map<int, ShowcaseController>> controllers = {};
}
