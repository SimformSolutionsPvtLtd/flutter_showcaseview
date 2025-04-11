import 'package:flutter/widgets.dart';

import '../showcase/showcase_controller.dart';
import '../showcase_view.dart';

class ShowcaseScope {
  ShowcaseScope({
    required this.name,
    required this.showcaseView,
  });

  final String name;
  final ShowcaseView showcaseView;

  /// A mapping of showcase keys to their associated controllers
  /// - Key: GlobalKey of a showcase (provided by user)
  /// - Value: Map of showcase IDs to their controllers
  Map<GlobalKey, Map<int, ShowcaseController>> controllers = {};
}
