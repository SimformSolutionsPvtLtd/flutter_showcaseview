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
import 'package:flutter/widgets.dart';

import '../showcase/showcase_controller.dart';
import '../showcase/showcase_view.dart';

class ShowcaseScope {
  /// A container class that manages showcase views within a specific named
  /// scope.
  ///
  /// This class is responsible for:
  /// - Maintain a reference to a named scope and its associated [ShowcaseView].
  /// - Store and organize [ShowcaseController] instances by their GlobalKeys.
  /// - Enable multiple independent showcase systems to coexist in different
  /// parts of the app.
  /// - Facilitate proper routing of showcase events to the correct controllers.
  ///
  /// This class is primarily used by [ShowcaseService] to manage showcase
  /// views and their controllers within different scopes, allowing for
  /// isolated showcase experiences that can be independently controlled and
  /// navigated.
  ShowcaseScope({
    required this.name,
    required this.showcaseView,
  });

  final String name;
  final ShowcaseView showcaseView;

  /// A mapping of showcase keys to their associated controllers
  /// - Key: GlobalKey of a showcase (provided by user)
  /// - Value: Map of showcase IDs to their controllers
  final Map<GlobalKey, Map<int, ShowcaseController>> controllers = {};
}
