## [2.0.4] (Un-Released)
- Fixed [#369](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/pull/369) - Fixed ToolTip Slide Transition
- Fixed [#388](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/388) - Can't scroll horizontal list with showcase
- Fixed [#366](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/366) - Null check operator used on a null value
- Fixed [#389](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/389) - Ignore extra `_nextIfAny` function operations
- Fixed [#409](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/pull/409) - Fixed target hit area.
- Improvement [#370](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/pull/370) - Improved `GetPosition` class.
- Feature [#387](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/387) - Provided barrier click disable functionality for a particular showcase.
- Fixed [#383](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/383) - Targeted widget focusing issue when we applying size constraint on root widget(MaterialApp).
- Improved internal `findRenderObject` calls.

## [2.0.3]
- Feature [#148](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/148) - Add feasibility to add `textDirection` of `title` and `description`.
- Feature [#272](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/272) - Add barrier click callback.
- Fixed [#360](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/360) - child constructor invocation to get rid out of flutter lint warning.

## [2.0.2]
- Fixed [#335](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/335) - Flutter inspector makes screen grey
- Fixed [#346](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/346) - Dont respond to any clicks in target.

## [2.0.1]
- Feature [#306](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/pull/306) - Added support of manual vertical tooltip position.
- Fixed [#318](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/318) - Add support for enable/disable showcase globally.
- Fixed [#316](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/316) - Add title and description padding
- Fixed [#330](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/330) - Overlay not showing in flutter 3.7.0
- Fixed [#288](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/pull/288) - Take in account view insets (such as keyboard)
- Fixed [#334](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/334) - Move code line to resolve no context issue
- Add PR title validation workflow

## [2.0.0+1]
- Fixed [#237](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/261) - Feature added to enable/disable default gesture of ShowcaseView child using `disableDefaultTargetGestures` parameter
- Fixed [#206](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/206) - getLeft and getRight return wrong result when in middle with a little offset
- Fixed issue of duplicate key found in example.
- Fixed [#253](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/253) - Add TextAlign attribute for title and description
- `pull_request_template.md.` file updated with proper document
- `CONTRIBUTING.md` file updated with proper document
- Fixed [#268](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/268) - Added smooth scale transition when tooltip appear on the screen
- Updated parameter name of `ShowCaseWidget` and `Showcase` class

## [1.1.8]
- Fixed [#237](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/237) - Feature added to enable/disable overlay click using `disableBarrierInteraction` parameters
- ToolTip BorderRadius setting support

## [1.1.7]

- Fixed [#235](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/235) - 1.1.6 scrolling behavior in PageView.
- Fixed [#242](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/242) - Error when display showcase on FloatingActionBar inside a TabBar (with more than 1 tab).

## [1.1.6]

- Fixed [#62](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/62) - While using ShowCase widget, not scrolling to respective widget when it's not visible.
- Fixed [#131](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/131) - Support of other gestures onTargetLongPress and onTargetDoubleTap
- Fixed [#140](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/140) - disableAnimation at ShowcaseWidget level
- Fixed [#71](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/71) - Highlight Not working when widget is not visible on screen
- Add flutter 3.0 support.

## [1.1.5]

- Fixed [#173](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/173) - showArrow not working
- Fixed [#150](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/150) - Add condition for determine state is active
- Fixed [#121](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/121) - SlideTransition widget in tooltip_widget.dart is constantly rebuildung even after the showcasing is supposed to have stopped
- Fixed [#152](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/152) - Calculation of tooltip position
- Fixed [#182](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/182) - Not providing blurValue causes Exception: Please provide ShowCaseView context
- Fixed [#162](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/162) - Add feature to move back
- Fixed [#181](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/181) - Add feature to go to previous item

## [1.1.4]

- Add glassmorphism effect in showcase background.
- Fixed [#166](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/166) - shapeBorder need to be more customisable
- Fixed [#163](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/163) - Null check operator used on a null value

## [1.1.3]

- Fixed [#158](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/158) - Arrow animation is not synchronized with tooltip

## [1.1.2]

- Fixed [#78](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/78) - Exception:BoxConstraints has NaN values #78
- Fixed [#139](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/139) - Weird position #139
- Fixed [#138](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/138) - show Unhandled Exception: Null check operator used on a null value error

## [1.1.1]

- Fixed [#92](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/92) - Showcase in ReorderableListView show at incorrect position
- License update from BSD 2-Clause "Simplified" to MIT

## [1.1.0]

- Fixed [#103](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/103) - add overlay padding.
- Fixed [#105](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/105) - showcase not showing text in one line even if it is not so big.
- Fixed [#56](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/56) - Landscape mode issue
- Fixed [#86](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/86) - Showcase isn't rendering responsively

## [1.0.0]

- Fixed [#95](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/95) - Migrated to null safety.  
- Fixed [#74](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/74) - Long text description is hidden.
- Fixed [#76](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/76) - Overlay is not displayed properly on web.
- Fixed [#81](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/81) - Crash on hot reload.
- Fixed [#84](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/84) - Background dim does not work in some screens.
- Fixed [#90](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/90) - ListView Item Support.

## [0.1.6]

- [Feature #63](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/63) method callback after individual showcase start and end
- [Fix #57](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/57) Position of the Showcase.withWidget is different on iPhone 11
- [Feature #49](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/pull/49) Add autoplay tooltip on showcase view plugin.

## [0.1.5]

* Refactor usage of deprecated methods
* Add support for `disableAnimation` option.

## [0.1.4] - Added onFinish method [#17](https://github.com/simformsolutions/flutter_showcaseview/issues/17).

## [0.1.3] - Added feature

Updated syntax to pass new context to ShowCaseWidget
Added onTargetTap callback feature [#10](https://github.com/simformsolutions/flutter_showcaseview/issues/10).

## [0.1.2] - Fixed issue [#6](https://github.com/simformsolutions/flutter_showcaseview/issues/6).

## [0.1.1] - Fixed maintenance issues.

## [0.1.0] - Initial release on 22nd Augest, 2019.

* First release.
