# Overview

A Flutter package that allows you to showcase or highlight your widgets step by step, providing interactive tutorials for your application's UI.

## Preview

![The example app running in Android](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/preview/showcaseview.gif)

## Features

- Guide user through your app by highlighting specific widget step by step
- Customize tooltips with titles, descriptions, and styling
- Handles scrolling the widget into view for showcasing
- Support for custom tooltip widgets
- Animation and transition effects for tooltip
- Options to showcase multiple widget at the same time

## Key Components

- **ShowCaseWidget**: The parent widget that manages showcase interactions
- **Showcase**: Widget to create default showcases with titles and descriptions
- **Showcase.withWidget**: Widget to create custom showcase tooltips

## Main Use Cases

- App onboarding experiences
- Feature introduction
- User guidance through complex interfaces
- Highlighting new features

## Installation

```yaml
dependencies:
showcaseview: <latest-version>
```

## Basic Implementation

```dart
// Import the package
import 'package:showcaseview/showcaseview.dart';

// Define global keys for your showcases
GlobalKey _one = GlobalKey();
GlobalKey _two = GlobalKey();

// Wrap your app with ShowCaseWidget
ShowCaseWidget(
builder: (context) => MyApp(),
),

// Add showcases to widgets
Showcase(
key: _one,
title: 'Menu',
description: 'Click here to see menu options',
child: Icon(Icons.menu),
),

// Start the showcase
void startShowcase() {
ShowCaseWidget.of(context).startShowCase([_one, _two]);
}
```

## Customizations

The package offers extensive customization options for:
- Tooltip appearance and positioning
- Text styling and alignment
- Overlay colors and opacity
- Animation effects and durations
- Interactive controls
- Auto-scrolling behavior

# Installation

To use the ShowCaseView package in your Flutter project, follow these steps:

## 1. Add dependency to `pubspec.yaml`

Add the following dependency to your project's `pubspec.yaml` file:

```yaml
dependencies:
  showcaseview: <latest-version>
```

## 2. Install packages

Run the following command to install the package:

```bash
flutter pub get
```

## 3. Import the package

Add the import statement in your Dart files where you want to use ShowCaseView:

```dart
import 'package:showcaseview/showcaseview.dart';
```

Now you're ready to use ShowCaseView in your Flutter application!

# Basic Usage

This guide covers the fundamental implementation of ShowCaseView in your Flutter application.

## Setup ShowCaseWidget

First, wrap your main widget with the `ShowCaseWidget`:

```dart
ShowCaseWidget(
  builder: (context) => MyHomePage(),
),
```

## Define Global Keys

Create global keys for each widget you want to showcase:

```dart
// Define in your widget class
final GlobalKey _one = GlobalKey();
final GlobalKey _two = GlobalKey();
final GlobalKey _three = GlobalKey();
```

## Add Showcase to Widgets

Wrap each target widget with a `Showcase` widget:

```dart
Showcase(
  key: _one,
  title: 'Menu',
  description: 'Click here to see menu options',
  child: Icon(
    Icons.menu,
    color: Colors.black45,
  ),
)
```

## Start the Showcase

There are several ways to start the showcase sequence:

### On Button Press

```dart
ElevatedButton(
  child: Text('Start Showcase'),
  onPressed: () {
    ShowCaseWidget.of(context).startShowCase([_one, _two, _three]);
  },
)
```

### On Screen Load

To start showcase immediately after the screen loads:

```dart
@override
void initState() {
  super.initState();
  // Delayed execution to ensure the UI is fully rendered
  WidgetsBinding.instance.addPostFrameCallback((_) =>
    ShowCaseWidget.of(context).startShowCase([_one, _two, _three])
  );
}
```

### After Animation

If your UI has animations, you can start the showcase after they complete:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) =>
  ShowCaseWidget.of(context).startShowCase(
    [_one, _two, _three], 
    delay: Duration(milliseconds: 500)
  )
);
```

## Example

Here's a complete basic example:

```dart
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShowCase Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ShowCaseWidget(
        builder: (context) => MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Start showcase after the screen is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      ShowCaseWidget.of(context).startShowCase([_one, _two])
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ShowCase Example'),
        leading: Showcase(
          key: _one,
          title: 'Menu',
          description: 'Click here to see menu options',
          child: Icon(Icons.menu),
        ),
      ),
      floatingActionButton: Showcase(
        key: _two,
        title: 'Add',
        description: 'Click here to add new items',
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
      body: Center(
        child: Text('ShowCase Example'),
      ),
    );
  }
}
```

# Advanced Usage

This guide covers more advance features and customizations of the ShowCaseView package.

## Custom Tooltip Widget

Use `Showcase.withWidget` to create a completely custom tooltip:

```dart
Showcase.withWidget(
  key: _customKey,
  height: 80,
  width: 140,
  targetShapeBorder: CircleBorder(),
  container: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('Custom Tooltip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      SizedBox(height: 5),
      Text('This is a completely custom tooltip widget', style: TextStyle(color: Colors.white)),
    ],
  ),
  child: Icon(Icons.star),
)
```

## Multi-Showcase View

To show multiple showcases simultaneously, use the same key for multiple showcase widgets:

```dart
// Both will be displayed at the same time
Showcase(
  key: _multiKey,
  title: 'First Widget',
  description: 'This is the first widget',
  child: Icon(Icons.star),
),

Showcase(
  key: _multiKey,
  title: 'Second Widget',
  description: 'This is the second widget',
  child: Icon(Icons.favorite),
),
```

> Note: Auto-scroll does not work with multi-showcase, and properties of the first initialized showcase are used for common settings like barrier tap and colors.

## Advanced Styling

Customize the appearance of showcases:

```dart
Showcase(
  key: _styleKey,
  title: 'Styled Showcase',
  description: 'This showcase has custom styling',
  titleTextStyle: TextStyle(
    color: Colors.red,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
  descTextStyle: TextStyle(
    color: Colors.green,
    fontSize: 16,
    fontStyle: FontStyle.italic,
  ),
  tooltipBackgroundColor: Colors.black87,
  targetPadding: EdgeInsets.all(8),
  targetBorderRadius: BorderRadius.circular(8),
  tooltipBorderRadius: BorderRadius.circular(16),
  child: MyWidget(),
)
```

## Auto Play

Enable auto play to automatically advance through showcases:

```dart
ShowCaseWidget(
  autoPlay: true,
  autoPlayDelay: Duration(milliseconds: 3000),
  enableAutoPlayLock: true,
  builder: (context) => MyApp(),
)
```

## Auto Scrolling

Enable auto scrolling to automatically bring off-screen showcase widgets into view:

```dart
ShowCaseWidget(
  enableAutoScroll: true,
  scrollDuration: Duration(milliseconds: 500),
  scrollAlignment: 0.5, // Center the widget in the viewport
  builder: (context) => MyScrollableApp(),
)
```

##
---

> Note: Auto-scroll does not work with multi-showcase, and 
> in order to scroll to a widget it needs to be attached with widget tree. So, If you are using a scrollview that renders widgets on demand, it is possible that the widget on which showcase is applied is not attached in widget tree. So, flutter won't be able to scroll to that widget.
> So, If you want to make a scroll view that contains less number of children widget then prefer to use SingleChildScrollView.
> If using SingleChildScrollView is not an option, then you can assign a ScrollController to that scrollview and manually scroll to the position where showcase widget gets rendered. You can add that code in onStart method of `ShowCaseWidget`.

Example:
```dart
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
---

##

## Custom Scroll Controller

For complex scroll views like `ListView` or `GridView`, you might need a custom scroll controller:

```dart
final _controller = ScrollController();

ShowCaseWidget(
  onStart: (index, key) {
    if(index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Scroll to approximate position of the showcase widget
        _controller.jumpTo(1000);
      });
    }
  },
  builder: (context) => MyApp(),
),

// In your ListView:
ListView.builder(
  controller: _controller,
  itemCount: 100,
  itemBuilder: (context, index) {
    // Your list items
  },
)
```

## Tooltip Actions

Add action buttons to tooltips:

```dart
Showcase(
  key: _actionKey,
  title: 'With Actions',
  description: 'This showcase has action buttons',
  tooltipActions: [
    TooltipActionButton(
      type: TooltipActionButtonType.previous,
      backgroundColor: Colors.blue,
      textStyle: TextStyle(color: Colors.white),
      name: 'Previous',
    ),
    TooltipActionButton(
      type: TooltipActionButtonType.next,
      backgroundColor: Colors.green,
      textStyle: TextStyle(color: Colors.white),
      name: 'Next',
    ),
    TooltipActionButton(
      type: TooltipActionButtonType.skip,
      backgroundColor: Colors.red,
      textStyle: TextStyle(color: Colors.white),
      name: 'Skip',
    ),
  ],
  tooltipActionConfig: TooltipActionConfig(
    alignment: MainAxisAlignment.spaceEvenly,
    position: TooltipActionPosition.outside,
  ),
  child: MyWidget(),
)
```

## Custom Floating Action Widget

Add a floating action widget that appears during showcases:

```dart
Showcase(
  key: _floatingKey,
  title: 'With Floating Widget',
  description: 'This showcase has a floating widget',
  floatingActionWidget: (_) => Positioned(
    bottom: 20,
    right: 20,
    child: ElevatedButton(
      onPressed: () {
        // Custom action
      },
      child: Text('Custom Action'),
    ),
  ),
  child: MyWidget(),
)
```

## Showcase Control Methods

Programmatically control the showcase flow:

```dart
// Navigate to next showcase
ShowCaseWidget.of(context).next();

// Navigate to previous showcase
ShowCaseWidget.of(context).previous();

// Dismiss all showcases
ShowCaseWidget.of(context).dismiss();
```

## Event Callbacks

Handle showcase events:

```dart
ShowCaseWidget(
  onStart: (index, key) {
    print('Started showcase $index');
  },
  onComplete: (index, key) {
    print('Completed showcase $index');
  },
  onFinish: () {
    print('All showcases completed');
  },
  onDismiss: (reason) {
    print('Showcase dismissed because: $reason');
  },
  builder: (context) => MyApp(),
)
```

# Migration Guides

This document provides guidance for migrating between different versions of the ShowCaseView package.

## Migration guide for release 4.0.0

The 4.0.0 release includes changes to parameter names to better reflect their purpose and behavior.

### Parameter Renaming

The parameters `titleAlignment` and `descriptionAlignment` have been renamed to `titleTextAlign` and `descriptionTextAlign` to correspond more accurately with the TextAlign property. The original parameter names `titleAlignment` and `descriptionAlignment` are now reserved for widget alignment.

#### Before (Pre-4.0.0):

```dart
Showcase(
  titleAlignment: TextAlign.center,
  descriptionAlignment: TextAlign.center,
),
```

#### After (4.0.0+):

```dart
Showcase(
  titleTextAlign: TextAlign.center,
  descriptionTextAlign: TextAlign.center,
),
```

## Migration guide for release 3.0.0

The 3.0.0 release simplified the API by removing the need for a Builder widget in the ShowCaseWidget.

### Builder Widget Removal

The `ShowCaseWidget` no longer requires a `Builder` widget and instead accepts a builder function directly.

#### Before (Pre-3.0.0):

```dart
ShowCaseWidget(
  builder: Builder(
    builder: (context) => SomeWidget()
  ),
),
```

#### After (3.0.0+):

```dart
ShowCaseWidget(
  builder: (context) => SomeWidget(),
),
```

## Breaking Changes History

### 4.0.0
- Renamed `titleAlignment` to `titleTextAlign`
- Renamed `descriptionAlignment` to `descriptionTextAlign`

### 3.0.0
- Removed Builder widget from `ShowCaseWidget`
- Changed builder property to accept a function directly

For a complete list of changes and new features in each version, please refer to the [release notes](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/releases) on GitHub.

# API References

This document provides a reference for the main classes and properties of the ShowCaseView package.

## ShowCaseWidget Properties

| Property                      | Type                                       | Default Value              | Description                                                                    |
|-------------------------------|--------------------------------------------|-----------------------------|-------------------------------------------------------------------------------|
| builder                       | Builder                                    | -                           | Builder function for your app content                                          |
| blurValue                     | double                                     | 0                           | Provides blur effect on overlay                                                |
| autoPlay                      | bool                                       | false                       | Automatically display next showcase                                            |
| autoPlayDelay                 | Duration                                   | Duration(milliseconds: 2000) | Visibility time of showcase when `autoPlay` is enabled                         |
| enableAutoPlayLock            | bool                                       | false                       | Block user interaction when autoPlay is enabled                                |
| enableAutoScroll              | bool                                       | false                       | Auto scroll to make target visible                                             |
| scrollDuration                | Duration                                   | Duration(milliseconds: 300) | Time duration for auto scrolling                                               |
| disableBarrierInteraction     | bool                                       | false                       | Disable barrier interaction                                                    |
| disableScaleAnimation         | bool                                       | false                       | Disable scale transition for all showcases                                     |
| disableMovingAnimation        | bool                                       | false                       | Disable bouncing/moving transition for all showcases                           |
| onStart                       | Function(int?, GlobalKey)?                 | -                           | Triggered on start of each showcase                                            |
| onComplete                    | Function(int?, GlobalKey)?                 | -                           | Triggered on completion of each showcase                                       |
| onFinish                      | VoidCallback?                              | -                           | Triggered when all the showcases are completed                                 |
| onDismiss                     | OnDismissCallback?                         | -                           | Triggered when onDismiss is called                                             |
| enableShowcase                | bool                                       | true                        | Enable or disable showcase globally                                            |
| toolTipMargin                 | double                                     | 14                          | For tooltip margin                                                             |
| globalTooltipActionConfig     | TooltipActionConfig?                       | -                           | Global tooltip actionbar config                                                |
| globalTooltipActions          | List<TooltipActionButton>?                 | -                           | Global list of tooltip actions                                                 |
| scrollAlignment               | double                                     | 0.5                         | For auto scroll widget alignment                                               |
| globalFloatingActionWidget    | FloatingActionWidget Function(BuildContext)? | -                         | Global config for tooltip action                                               |
| hideFloatingActionWidgetForShowcase | List<GlobalKey>                      | []                          | Hides globalFloatingActionWidget for the provided showcase widget keys         |

## Showcase Properties

| Property                   | Type                 | Default Value                                      | Description                                                     |
|----------------------------|----------------------|----------------------------------------------------|------------------------------------------------------------------|
| key                        | GlobalKey            | -                                                  | Unique Global key for each showcase                              |
| child                      | Widget               | -                                                  | Target widget to be showcased                                    |
| title                      | String?              | -                                                  | Title of default tooltip                                         |
| description                | String?              | -                                                  | Description of default tooltip                                   |
| titleTextStyle             | TextStyle?           | -                                                  | Text Style of title                                              |
| descTextStyle              | TextStyle?           | -                                                  | Text Style of description                                        |
| titleTextAlign             | TextAlign            | TextAlign.start                                    | Alignment of title text                                          |
| descriptionTextAlign       | TextAlign            | TextAlign.start                                    | Alignment of description text                                    |
| titleAlignment             | AlignmentGeometry    | Alignment.center                                   | Alignment of title                                               |
| descriptionAlignment       | AlignmentGeometry    | Alignment.center                                   | Alignment of description                                         |
| targetShapeBorder          | ShapeBorder          | -                                                  | Shape border of target widget                                    |
| targetBorderRadius         | BorderRadius?        | -                                                  | Border radius of target widget                                   |
| tooltipBorderRadius        | BorderRadius?        | BorderRadius.circular(8.0)                         | Border radius of tooltip                                         |
| blurValue                  | double?              | `ShowCaseWidget.blurValue`                         | Gaussian blur effect on overlay                                  |
| tooltipPadding             | EdgeInsets           | EdgeInsets.symmetric(vertical: 8, horizontal: 8)   | Padding to tooltip content                                       |
| targetPadding              | EdgeInsets           | EdgeInsets.zero                                    | Padding to target widget                                         |
| overlayOpacity             | double               | 0.75                                               | Opacity of overlay layer                                         |
| overlayColor               | Color                | Colors.black45                                     | Color of overlay layer                                           |
| tooltipBackgroundColor     | Color                | Colors.white                                       | Background Color of default tooltip                              |
| textColor                  | Color                | Colors.black                                       | Color of tooltip text                                            |
| showArrow                  | bool                 | true                                               | Shows tooltip with arrow                                         |
| disposeOnTap               | bool?                | false                                              | Dismiss all showcases on target/tooltip tap                      |
| tooltipPosition            | TooltipPosition?     | -                                                  | Vertical position of tooltip respective to target                |
| disableDefaultTargetGestures | bool               | false                                              | Disable default gestures of target widget                        |

## Showcase.withWidget Properties

In addition to most of the properties from `Showcase`, `Showcase.withWidget` includes:

| Property   | Type     | Default Value | Description                          |
|------------|----------|---------------|--------------------------------------|
| container  | Widget?  | -             | Custom tooltip widget                |
| height     | double?  | -             | Height of custom tooltip widget      |
| width      | double?  | -             | Width of custom tooltip widget       |

## TooltipActionButton Properties

| Property                    | Type              | Default Value                                 | Description                                              |
|-----------------------------|--------------------|-----------------------------------------------|----------------------------------------------------------|
| type                        | TooltipButtonType  | -                                             | Type of action button (next, skip, previous)             |
| backgroundColor             | Color?             | -                                             | Background color of action button                         |
| borderRadius                | BorderRadius?      | BorderRadius.all(Radius.circular(50))         | Border radius of action button                            |
| textStyle                   | TextStyle?         | -                                             | Text style for button name                                |
| padding                     | EdgeInsets?        | EdgeInsets.symmetric(horizontal: 15,vertical: 4) | Padding to button content                            |
| leadIcon                    | ActionButtonIcon?  | -                                             | Icon before name in action button                         |
| tailIcon                    | ActionButtonIcon?  | -                                             | Icon after name in action button                          |
| name                        | String?            | -                                             | Action button name                                        |
| onTap                       | VoidCallback?      | -                                             | Callback when action button is tapped                     |
| hideActionWidgetForShowcase | List<GlobalKey>    | []                                            | Hide action widget for specified showcase keys            |

## TooltipActionConfig Properties

| Property                  | Type                  | Default Value                | Description                                       |
|---------------------------|------------------------|------------------------------|---------------------------------------------------|
| alignment                 | MainAxisAlignment      | MainAxisAlignment.spaceBetween | Horizontal alignment of tooltip action buttons   |
| crossAxisAlignment        | CrossAxisAlignment     | CrossAxisAlignment.start      | Vertical alignment of tooltip action buttons     |
| actionGap                 | double?                | 5                            | Gap between tooltip action buttons                |
| position                  | TooltipActionPosition? | TooltipActionPosition.inside  | Position of tooltip actionbar (inside, outside)   |
| gapBetweenContentAndAction | double?               | 10                           | Gap between tooltip content and actionbar         |

## ShowCaseWidget Methods

| Method                                    | Description                |
|-------------------------------------------|----------------------------|
| startShowCase(List<GlobalKey> widgetIds)  | Starts the showcase        |
| next()                                    | Go to next showcase        |
| previous()                                | Go to previous showcase    |
| dismiss()                                 | Dismiss all showcases      |

## Enums

### TooltipPosition
- `TooltipPosition.top`: Display tooltip above the target
- `TooltipPosition.bottom`: Display tooltip below the target
- `TooltipPosition.left`: Display tooltip left to the target
- `TooltipPosition.right`: Display tooltip right to the target

### TooltipActionPosition
- `TooltipActionPosition.inside`: Display action buttons inside the tooltip
- `TooltipActionPosition.outside`: Display action buttons outside the tooltip

### TooltipButtonType
- `TooltipButtonType.next`: Next button
- `TooltipButtonType.previous`: Previous button
- `TooltipButtonType.skip`: Skip/finish button
# Contributors

These are the main contributors who have helped shape the ShowCaseView package.

## Main Contributors

| ![img](https://avatars.githubusercontent.com/u/25323183?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/81063988?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/41247722?v=4&s=200) | 
|:------------------------------------------------------------------:|:------------------------------------------------------------------:|:------------------------------------------------------------------:|
|           [Vatsal Tanna](https://github.com/vatsaltanna)           |           [Sahil Totala](https://github.com/Flamingloon)           |         [Aditya Chavda](https://github.com/aditya-chavda)          |

| ![img](https://avatars.githubusercontent.com/u/20923896?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/56400956?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/97177197?v=4&s=200) |
|:------------------------------------------------------------------:|:------------------------------------------------------------------:|:------------------------------------------------------------------:|
|       [Sanket Kachchela](https://github.com/SanketKachhela)        |        [Ujas Majithiya](https://github.com/Ujas-Majithiya)         |        [Happy Makadiya](https://github.com/HappyMakadiyaS)         |


## How to Contribute

Contributions to the ShowCaseView package are welcome! Here's how you can contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Guidelines for Contributing

- Follow the coding style and conventions used in the project
- Write clear, concise commit messages
- Add tests for new features or bug fixes
- Update documentation as needed
- Make sure all tests pass before submitting a pull request

For more information about contributing, please check the [GitHub repository](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview).

# License

```
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
