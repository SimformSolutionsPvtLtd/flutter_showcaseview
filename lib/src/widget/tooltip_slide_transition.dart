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

class ToolTipSlideTransition extends AnimatedWidget {
  /// [SlideTransition] could have been used instead of this widget,
  /// but it internally uses [FractionalTranslation] which affects the
  /// transformation based on the size of a child. This widget uses
  /// [Transform.translate] which would fix translation independent of the
  /// child's size.
  const ToolTipSlideTransition({
    required Listenable position,
    required this.child,
    super.key,
  }) : super(listenable: position);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progress = listenable as Animation<Offset>;
    return Transform.translate(offset: progress.value, child: child);
  }
}
