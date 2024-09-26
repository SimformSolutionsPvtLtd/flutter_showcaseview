![Showcase View - Simform LLC.](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/preview/banner.png)


# ShowCaseView

[![Build](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/actions/workflows/flutter.yaml/badge.svg?branch=master)](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/actions) [![showcaseview](https://img.shields.io/pub/v/showcaseview?label=showcaseview)](https://pub.dev/packages/showcaseview)

A Flutter package allows you to Showcase/Highlight your widgets step by step.

_Check out other amazing open-source [Flutter libraries](https://pub.dev/publishers/simform.com/packages) and [Mobile libraries](https://github.com/SimformSolutionsPvtLtd/Awesome-Mobile-Libraries) developed by Simform Solutions!_

## Preview

![The example app running in Android](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/preview/showcaseview.gif)

## Migration guide for release 4.0.0

Renamed parameters `titleAlignment` to `titleTextAlign` and `descriptionAlignment`
to `descriptionTextAlign` to correspond it more with the TextAlign property.`titleAlignment`
and `descriptionAlignment` will be used for widget alignment.

Before:
```dart
Showcase(
  titleAlignment: TextAlign.center,
  descriptionAlignment: TextAlign.center,
),
```

After:
```dart
Showcase(
  titleTextAlign: TextAlign.center,
  descriptionTextAlign: TextAlign.center,
),
```

## Migration guide for release 3.0.0
Removed builder widget from `ShowCaseWidget` and replaced it with builder function

Before:
```dart
ShowCaseWidget(
  builder: Builder(
    builder : (context) => Somewidget()
  ),
),
```

After:
```dart
ShowCaseWidget(
  builder : (context) => Somewidget(),
),
```

## Installing

1.  Add dependency to `pubspec.yaml`

    *Get the latest version in the 'Installing' tab on [pub.dev](https://pub.dev/packages/showcaseview)*

```dart
dependencies:
    showcaseview: <latest-version>
```

2.  Import the package
```dart
import 'package:showcaseview/showcaseview.dart';
```

3. Adding a `ShowCaseWidget` widget.
```dart
ShowCaseWidget(
  builder:  (context)=> Somewidget(),
),
```

4. Adding a `Showcase` widget.
```dart
GlobalKey _one = GlobalKey();
GlobalKey _two = GlobalKey();
GlobalKey _three = GlobalKey();

...

Showcase(
  key: _one,
  title: 'Menu',
  description: 'Click here to see menu options',
  child: Icon(
    Icons.menu,
    color: Colors.black45,
  ),
),

Showcase.withWidget(
  key: _three,
  height: 80,
  width: 140,
  targetShapeBorder: CircleBorder(),
  container: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      ...
    ],
  ),
  child: ...,
),
```

5. Starting the `ShowCase`
```dart
someEvent(){
    ShowCaseWidget.of(context).startShowCase([_one, _two, _three]);
}
```

If you want to start the `ShowCaseView` as soon as your UI built up then use below code.

```dart
WidgetsBinding.instance.addPostFrameCallback((_) =>
  ShowCaseWidget.of(context).startShowCase([_one, _two, _three])
);
```

## Functions of `ShowCaseWidget.of(context)`:

| Function Name                            | Description              |
|------------------------------------------|--------------------------|
| startShowCase(List<GlobalKey> widgetIds) | Starting the showcase    |
| next()                                   | Starts next showcase     |
| previous()                               | Starts previous showcase |
| dismiss()                                | Dismisses all showcases  |

## Properties of `ShowCaseWidget`:

| Name                                | Type                                         | Default Behaviour            | Description                                                                    |
|-------------------------------------|----------------------------------------------|------------------------------|--------------------------------------------------------------------------------|
| builder                             | Builder                                      |                              |                                                                                |
| blurValue                           | double                                       | 0                            | Provides blur effect on overlay.                                               |
| autoPlay                            | bool                                         | false                        | Automatically display Next showcase.                                           |
| autoPlayDelay                       | Duration                                     | Duration(milliseconds: 2000) | Visibility time of showcase when `autoplay` is enabled.                        |
| enableAutoPlayLock                  | bool                                         | false                        | Block the user interaction on overlay when autoPlay is enabled.                |
| enableAutoScroll                    | bool                                         | false                        | Allows to auto scroll to next showcase so as to make the given target visible. |
| scrollDuration                      | Duration                                     | Duration(milliseconds: 300)  | Time duration for auto scrolling.                                              |
| disableBarrierInteraction           | bool                                         | false                        | Disable barrier interaction.                                                   |
| disableScaleAnimation               | bool                                         | false                        | Disable scale transition for all showcases.                                    |
| disableMovingAnimation              | bool                                         | false                        | Disable bouncing/moving transition for all showcases.                          |
| onStart                             | Function(int?, GlobalKey)?                   |                              | Triggered on start of each showcase.                                           |
| onComplete                          | Function(int?, GlobalKey)?                   |                              | Triggered on completion of each showcase.                                      |
| onFinish                            | VoidCallback?                                |                              | Triggered when all the showcases are completed.                                |
| enableShowcase                      | bool                                         | true                         | Enable or disable showcase globally.                                           |
| toolTipMargin                       | double                                       | 14                           | For tooltip margin.                                                            |
| globalTooltipActionConfig           | TooltipActionConfig?                         |                              | Global tooltip actionbar config.                                               |
| globalTooltipActions                | List<TooltipActionButton>?                   |                              | Global list of tooltip actions .                                               |
| scrollAlignment                     | double                                       | 0.5                          | For Auto scroll widget alignment.                                              |
| globalFloatingActionWidget          | FloatingActionWidget Function(BuildContext)? |                              | Global Config for tooltip action to auto apply for all the toolTip .           |
| hideFloatingActionWidgetForShowcase | List<GlobalKey>                              | []                           | Hides globalFloatingActionWidget for the provided showcase widget keys.        |


## Properties of `Showcase` and `Showcase.withWidget`:

| Name                         | Type                       | Default Behaviour                                | Description                                                                                        | `Showcase` | `ShowCaseWidget` |
|------------------------------|----------------------------|--------------------------------------------------|----------------------------------------------------------------------------------------------------|------------|------------------|
| key                          | GlobalKey                  |                                                  | Unique Global key for each showcase.                                                               | ✅          | ✅                |
| child                        | Widget                     |                                                  | The Target widget that you want to be showcased                                                    | ✅          | ✅                |
| title                        | String?                    |                                                  | Title of default tooltip                                                                           | ✅          |                  |
| description                  | String?                    |                                                  | Description of default tooltip                                                                     | ✅          |                  |
| container                    | Widget?                    |                                                  | Allows to create custom tooltip widget.                                                            |            | ✅                |
| height                       | double?                    |                                                  | Height of custom tooltip widget                                                                    |            | ✅                |
| width                        | double?                    |                                                  | Width of custom tooltip widget                                                                     |            | ✅                |
| titleTextStyle               | TextStyle?                 |                                                  | Text Style of title                                                                                | ✅          |                  |
| descTextStyle                | TextStyle?                 |                                                  | Text Style of description                                                                          | ✅          |                  |
| titleTextAlign               | TextAlign                  | TextAlign.start                                  | Alignment of title text                                                                            | ✅          |                  |
| descriptionTextAlign         | TextAlign                  | TextAlign.start                                  | Alignment of description text                                                                      | ✅          |                  |
| titleAlignment               | AlignmentGeometry          | Alignment.center                                 | Alignment of title                                                                                 | ✅          |                  |
| descriptionAlignment         | AlignmentGeometry          | Alignment.center                                 | Alignment of description                                                                           | ✅          |                  |
| targetShapeBorder            | ShapeBorder                |                                                  | If `targetBorderRadius` param is not provided then it applies shape border to target widget        | ✅          | ✅                |
| targetBorderRadius           | BorderRadius?              |                                                  | Border radius of target widget                                                                     | ✅          | ✅                |
| tooltipBorderRadius          | BorderRadius?              | BorderRadius.circular(8.0)                       | Border radius of tooltip                                                                           | ✅          |                  |
| blurValue                    | double?                    | `ShowCaseWidget.blurValue`                       | Gaussian blur effect on overlay                                                                    | ✅          | ✅                |
| tooltipPadding               | EdgeInsets                 | EdgeInsets.symmetric(vertical: 8, horizontal: 8) | Padding to tooltip content                                                                         | ✅          |                  |
| targetPadding                | EdgeInsets                 | EdgeInsets.zero                                  | Padding to target widget                                                                           | ✅          | ✅                |
| overlayOpacity               | double                     | 0.75                                             | Opacity of overlay layer                                                                           | ✅          | ✅                |
| overlayColor                 | Color                      | Colors.black45                                   | Color of overlay layer                                                                             | ✅          | ✅                |
| tooltipBackgroundColor       | Color                      | Colors.white                                     | Background Color of default tooltip                                                                | ✅          |                  |
| textColor                    | Color                      | Colors.black                                     | Color of tooltip text                                                                              | ✅          |                  |
| scrollLoadingWidget          | Widget                     |                                                  | Loading widget on overlay until active showcase is visible to viewport when `autoScroll` is enable | ✅          | ✅                |
| movingAnimationDuration      | Duration                   | Duration(milliseconds: 2000)                     | Duration of time this moving animation should last.                                                | ✅          | ✅                |
| showArrow                    | bool                       | true                                             | Shows tooltip with arrow                                                                           | ✅          |                  |
| disableDefaultTargetGestures | bool                       | false                                            | disable default gestures of target widget                                                          | ✅          | ✅                |
| disposeOnTap                 | bool?                      | false                                            | Dismiss all showcases on target/tooltip tap                                                        | ✅          | ✅                |
| disableMovingAnimation       | bool?                      | `ShowCaseWidget.disableMovingAnimation`          | Disable bouncing/moving transition                                                                 | ✅          | ✅                |
| disableScaleAnimation        | bool?                      | `ShowCaseWidget.disableScaleAnimation`           | Disable initial scale transition when showcase is being started and completed                      | ✅          |                  |
| scaleAnimationDuration       | Duration                   | Duration(milliseconds: 300)                      | Duration of time scale animation should last.                                                      | ✅          |                  |
| scaleAnimationCurve          | Curve                      | Curves.easeIn                                    | Curve to use in scale animation.                                                                   | ✅          |                  |
| scaleAnimationAlignment      | Alignment?                 |                                                  | Origin of the coordinate in which the scale takes place, relative to the size of the box.          | ✅          |                  |
| onToolTipClick               | VoidCallback?              |                                                  | Triggers when tooltip is being clicked.                                                            | ✅          |                  |
| onTargetClick                | VoidCallback?              |                                                  | Triggers when target widget is being clicked                                                       | ✅          | ✅                |
| onTargetDoubleTap            | VoidCallback?              |                                                  | Triggers when target widget is being double clicked                                                | ✅          | ✅                |
| onTargetLongPress            | VoidCallback?              |                                                  | Triggers when target widget is being long pressed                                                  | ✅          | ✅                |
| onBarrierClick               | VoidCallback?              |                                                  | Triggers when barrier is clicked                                                                   | ✅          | ✅                |
| tooltipPosition              | TooltipPosition?           |                                                  | Defines vertical position of tooltip respective to Target widget                                   | ✅          | ✅                |
| titlePadding                 | EdgeInsets?                | EdgeInsets.zero                                  | Padding to title                                                                                   | ✅          |                  |
| descriptionPadding           | EdgeInsets?                | EdgeInsets.zero                                  | Padding to description                                                                             | ✅          |                  |
| titleTextDirection           | TextDirection?             |                                                  | Give textDirection to title                                                                        | ✅          |                  |
| descriptionTextDirection     | TextDirection?             |                                                  | Give textDirection to description                                                                  | ✅          |                  |
| descriptionTextDirection     | TextDirection?             |                                                  | Give textDirection to description                                                                  | ✅          |                  |
| disableBarrierInteraction    | bool                       | false                                            | Disables barrier interaction for a particular showCase                                             | ✅          | ✅                |
| toolTipSlideEndDistance      | double                     | 7                                                | Defines motion range for tooltip slide animation                                                   | ✅          | ✅                |
| tooltipActions               | List<TooltipActionButton>? | []                                               | Provide a list of tooltip actions                                                                  | ✅          | ✅                |
| tooltipActionConfig          | TooltipActionConfig?       |                                                  | Give configurations (alignment, position, etc...) to the tooltip actionbar                         | ✅          | ✅                |
| enableAutoScroll             | bool?                      | ShowCaseWidget.enableAutoScroll                  | This is used to override the `ShowCaseWidget.enableAutoScroll` behaviour                           | ✅          | ✅                |
| floatingActionWidget         | FloatingActionWidget       |                                                  | Provided a floating static action widget to show at any place on the screen                        | ✅          | ✅                |

## Properties of `TooltipActionButton` and `TooltipActionButton.custom`:

| Name                        | Type                | Default Behaviour                                | Description                                                | `TooltipActionButton` | `TooltipActionButton.custom` |
|-----------------------------|---------------------|--------------------------------------------------|------------------------------------------------------------|-----------------------|------------------------------|
| button                      | Widget              |                                                  | Provide custom tooltip action button widget                |                       | ✅                            |
| type                        | TooltipActionButton |                                                  | Type of action button (next, skip, previous)               | ✅                     |                              |
| backgroundColor             | Color?              |                                                  | Give background color to action button                     | ✅                     |                              |
| borderRadius                | BorderRadius?       | BorderRadius.all(Radius.circular(50))            | Give border radius to action button                        | ✅                     |                              |
| textStyle                   | TextStyle?          |                                                  | Give text styles to the name of button                     | ✅                     |                              |
| padding                     | EdgeInsets?         | EdgeInsets.symmetric(horizontal: 15,vertical: 4) | Give padding to button content                             | ✅                     |                              |
| leadIcon                    | ActionButtonIcon?   |                                                  | Add icon at first before name in action button             | ✅                     |                              |
| tailIcon                    | ActionButtonIcon?   |                                                  | Add icon at last after name in action button               | ✅                     |                              |
| name                        | String?             |                                                  | Action button name                                         | ✅                     |                              |
| onTap                       | VoidCallback?       |                                                  | Triggers when action button is tapped                      | ✅                     |                              |
| border                      | Border?             |                                                  | Give border custom border to the action widget             | ✅                     |                              |
| hideActionWidgetForShowcase | List<GlobalKey>     | []                                               | Hide This action widget for provided list of showcase keys | ✅                     |                              |

## Properties of `TooltipActionConfig`:

| Name                       | Type                   | Default Behaviour              | Description                                       |
|----------------------------|------------------------|:-------------------------------|---------------------------------------------------|
| alignment                  | MainAxisAlignment      | MainAxisAlignment.spaceBetween | Horizontal Alignment of tooltip action buttons    |
| crossAxisAlignment         | CrossAxisAlignment     | CrossAxisAlignment.start       | Vertical Alignment of tooltip action buttons      |
| actionGap                  | double?                | 5                              | Horizontal gap between the tooltip action buttons |
| position                   | TooltipActionPosition? | TooltipActionPosition.inside   | Position of tooltip actionbar (inside, outside)   |
| gapBetweenContentAndAction | double?                | 10                             | Gap between tooltip content and actionbar         |

## How to use

Check out the **example** app in the [example](example) directory or the 'Example' tab on pub.dartlang.org for a more complete example.

## Scrolling to active showcase

Auto Scrolling to active showcase feature will not work properly in scroll views that renders widgets on demand(ex, ListView, GridView).

In order to scroll to a widget it needs to be attached with widget tree. So, If you are using a scrollview that renders widgets on demand, it is possible that the widget on which showcase is applied is not attached in widget tree. So, flutter won't be able to scroll to that widget.

So, If you want to make a scroll view that contains less number of children widget then prefer to use SingleChildScrollView.

If using SingleChildScrollView is not an option, then you can assign a ScrollController to that scrollview and manually scroll to the position where showcase widget gets rendered. You can add that code in onStart method of `ShowCaseWidget`.

Example,

```dart
// This controller will be assigned to respected sctollview.
final _controller = ScrollController();

ShowCaseWidget(
  onStart: (index, key) {
    if(index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
       // If showcase widget is at offset 1000 in the listview.
       // If you don't know the exact position of the showcase widget,
       // You can provide nearest possible location.
       // 
       // In this case providing 990 instead of 1000 will work as well.
        _controller.jumpTo(1000);
      });
    }
  },
);
```

## How to test

In order to make sure that particular showcase was shown you can check for a presence of showcase
overlay root widget. Key of that widget is `ValueKey(showcaseGlobalKey)`. Here `showcaseGlobalKey`
is a key you defined for relevant `Showcase` widget.

```dart
void main() {
  // ...
  testWidgets('showcase', (tester) async {
    final overlay = find.byKey(ValueKey(showcaseGlobalKey));
    expect(overlay, findsOneWidget);

    await tap(overlay);

    // Make few pumps (note, that pumpAndSettle doesn't work for infinite animations)
    for (int i = 0; i != 5; ++i) {
      await pump(Duration(milliseconds: 200));
    }

    final overlayTapped = find.byKey(_overlayKeyFor(w1Key));
    expect(overlayTapped, findsNothing);
  });
}
```

## Main Contributors

<table>
  <tr>
     <td align="center"><a href="https://github.com/vatsaltanna"><img src="https://avatars.githubusercontent.com/u/25323183?s=100" width="100px;" alt=""/><br /><sub><b>Vatsal Tanna</b></sub></a></td>
     <td align="center"><a href="https://github.com/sanket-simform"><img src="https://avatars.githubusercontent.com/u/65167856?v=4" width="100px;" alt=""/><br /><sub><b>Sanket Kachhela</b></sub></a></td>
     <td align="center"><a href="https://github.com/ParthBaraiya"><img src="https://avatars.githubusercontent.com/u/36261739?v=4" width="100px;" alt=""/><br /><sub><b>Parth Baraiya</b></sub></a></td>
     <td align="center"><a href="https://github.com/DhavalRKansara"><img src="https://avatars.githubusercontent.com/u/44993081?v=4" width="100px;" alt=""/><br /><sub><b>Dhaval Kansara</b></sub></a></td>
     <td align="center"><a href="https://github.com/HappyMakadiyaS"><img src="https://avatars.githubusercontent.com/u/97177197?v=4" width="100px;" alt=""/><br /><sub><b>Happy Makadiya</b></sub></a></td>
     <td align="center"><a href="https://github.com/Ujas-Majithiya"><img src="https://avatars.githubusercontent.com/u/56400956?v=4" width="100px;" alt=""/><br /><sub><b>Ujas Majithiya</b></sub></a></td>
     <td align="center"><a href="https://github.com/aditya-chavda"><img src="https://avatars.githubusercontent.com/u/41247722?v=4" width="100px;" alt=""/><br /><sub><b>Aditya Chavda</b></sub></a></td>
     <td align="center"><a href="https://github.com/Flamingloon"><img src="https://avatars.githubusercontent.com/u/81063988?v=4" width="100px;" alt=""/><br /><sub><b>Sahil Totala</b></sub></a></td>
  </tr>
</table>


## License

```text
MIT License

Copyright (c) 2021 Simform Solutions

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
