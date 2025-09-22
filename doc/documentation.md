# Overview

A Flutter package that allows you to showcase or highlight your widgets step by step, providing 
interactive tutorials for your application's UI.

## Preview
_**For live web demo, visit [ShowcaseView Web Example](https://simformsolutionspvtltd.github.io/flutter_showcaseview/)**_

![The example app running on mobile](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_showcaseview/master/preview/showcaseview.gif)

## Features

- Guide user through your app by highlighting specific widget step by step.
- Customize tooltips with titles, descriptions, actions, and styling.
- Handles scrolling the widget into view for showcasing.
- Support for custom tooltip widgets.
- Animation and transition effects for tooltip.
- Options to showcase multiple widget at the same time.

## Key Components

- **ShowcaseView**: The class that manages showcase interactions and various configurations.
- **Showcase**: A widget to be wrapped on the your widget enabling creation of a showcase with 
  the default tooltip.
- **Showcase.withWidget**: A widget to be wrapped on the your widget enabling creation of a 
  custom showcase tooltip.

## Main Use Cases

- App onboarding experiences.
- Feature introduction.
- User guidance through complex interfaces.
- Highlighting new features.

## Installation

```yaml
dependencies:
  showcaseview: <latest-version>
```

## Basic Implementation

```dart
// Import the package
import 'package:showcaseview/showcaseview.dart';

// Register the showcase view
ShowcaseView.register();

// Define global keys for your showcases
GlobalKey _one = GlobalKey();

// Add showcases to widgets
Showcase(
  key: _one,
  title: 'Menu',
  description: 'Click here to see menu options',
  child: Icon(Icons.menu),
),

// Start the showcase
void startShowcase() {
  ShowcaseView.get().startShowCase([_one]);
}

// Dispose the showcase view
ShowcaseView.get().unregister();
```

## Customizations

The package offers extensive customization options for:
- Tooltip appearance and positioning.
- Text styling and alignment.
- Overlay colors and opacity.
- Animation effects and durations.
- Interactive controls.
- Auto-scrolling behavior.
- Tooltip action buttons (previous, next, skip) with customizable styling and positioning.
- Floating action widgets for additional interactive elements during showcases.

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

## Setup ShowCaseView

First, register `ShowcaseView` and optionally add configurations as per your requirements:

```dart
ShowcaseView.register();
```

You can add many more configurations than shown below. For more details, refer to the [API 
Reference](https://pub.dev/documentation/showcaseview/latest/showcaseview/).

```dart
ShowcaseView.register(
  autoPlayDelay: const Duration(seconds: 3),
  globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
    left: 16,
    bottom: 16,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
      onPressed: () => ShowcaseView.get().dismiss(),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffEE5366),
      ),
      child: const Text(
        'Skip',
        style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    ),
  ),
  globalTooltipActionConfig: const TooltipActionConfig(
    position: TooltipActionPosition.inside,
    alignment: MainAxisAlignment.spaceBetween,
    actionGap: 20,
  ),
  globalTooltipActions: [
    TooltipActionButton(
      type: TooltipDefaultActionType.previous,
      textStyle: const TextStyle(
        color: Colors.white,
      ),
      // Here we don't need previous action for the first showcase widget
      // so we hide this action for the first showcase widget
      hideActionWidgetForShowcase: [_firstShowcaseWidget],
    ),
    TooltipActionButton(
      type: TooltipDefaultActionType.next,
      textStyle: const TextStyle(
        color: Colors.white,
      ),
      // Here we don't need next action for the last showcase widget so we
      // hide this action for the last showcase widget
      hideActionWidgetForShowcase: [_lastShowcaseWidget],
    ),
  ],
);
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

Wrap each target widget with a `Showcase` widget for a showcase with default tooltip:

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
    ShowcaseView.get().startShowCase([_one, _two, _three]);
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
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => ShowcaseView.get().startShowCase([_one, _two, _three]),
  );
}
```

### After Animation

If your UI has animations, you can start the showcase after they complete:

```dart
WidgetsBinding.instance.addPostFrameCallback(
  (_) => ShowcaseView.get().startShowCase(
    [_one, _two, _three], 
    delay: Duration(milliseconds: 500),
  ),
);
```

### Dispose ShowcaseView

When you no longer need the showcase view, unregister it:

```dart
ShowcaseView.get().unregister();
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Register the showcase view
    ShowcaseView.register();

    // Start showcase after the screen is rendered to ensure internal initialization.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowcaseView.get().startShowCase([_one, _two]),
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
  
  @override
  void dispose() {
    // Unregister the showcase view
    ShowcaseView.get().unregister();
    super.dispose();
  }
}
```

# Advanced Usage

This guide covers more advance features and customizations of the ShowCaseView package.

## Auto Play

Enable auto play to automatically advance through showcases:

```dart
ShowcaseView.register(
  autoPlay: true,
  autoPlayDelay: Duration(milliseconds: 3000),
  enableAutoPlayLock: true,
)
```

## Auto Scrolling

Enable auto scrolling to automatically bring off-screen showcase widgets into view:

```dart
ShowcaseView.register(
  enableAutoScroll: true,
  scrollDuration: Duration(milliseconds: 500),
)
```

> **Note:** Auto-scroll does not work with multi-showcase, and in order to scroll to a widget it 
> needs to be attached with widget tree.
>
> If you are using a scrollview that renders widgets on demand like ListView.builder, it is 
> possible that the widget to be showcased is not attached to the widget tree leaving flutter 
> unable to scroll to that widget.
>
> In such cases, you can assign a ScrollController to that scrollview and manually scroll to 
> the position where showcase widget gets rendered. You can add code for that in the onStart 
> parameter of the ShowcaseView.register as shown below.

Example:
```dart
final _controller = ScrollController();

ShowcaseView.register(
  onStart: (index, key) {
    if(index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Scroll to approximate position of the showcase widget
        _controller.jumpTo(1000);
      });
    }
  },
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

> **Note:** Auto-scroll does not work with multi-showcase, and properties of the first 
> initialized showcase are used for common settings like barrier tap and colors.


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

## Showcase Control Methods

Programmatically control the showcase flow:

```dart
// Navigate to next showcase
ShowcaseView.get().next();

// Navigate to previous showcase
ShowcaseView.get().previous();

// Dismiss all showcases
ShowcaseView.get().dismiss();
```

## Event Callbacks

Handle showcase events:

```dart
ShowcaseView.register(
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
)
```

## Overriding Showcase View Configuration

You can set global configurations for all showcases in your app by using ShowcaseView.register()
and when you want to override that configuration then you can register a new set of 
configurations by giving an unique scope name while registering. 

Let's say you want a specific configuration for your entire app so you register it as follow:

```dart
ShowcaseView.register(
  // appropriate configurations
)
```
Here, when you don't specify a scope name, a default scope name will be used internally. Now, if 
you would prefer an another set of configuration just for the profile module, then you can 
utilise the scope parameter of ShowcaseView.register() and register another set of configurations
when user navigates to profile screen and unregister it when you want the other configuration set to
be used. An example would be as follow:

```dart
ShowcaseView.register(
  scope: 'profile',
  // other configurations
)
```

When a scope name is provided, all the operations like startShowCase, dismiss, etc. should be 
performed using that scope name, i.e.

```dart
  ShowcaseView.get(scope: 'profile').startShowCase([_one, _two, _three]);
```

> If multiple scopes are registered with same name then the last registering scope would be 
> consider valid and the rest would be overrode by the last one.

# Migration Guides

This document provides guidance for migrating between different versions of the ShowCaseView package.

## Migration guide for release 4.0.0

The 4.0.0 release includes changes to parameter names to better reflect their purpose and behavior.

### Parameter Renaming

The parameters `titleAlignment` and `descriptionAlignment` have been renamed to `titleTextAlign` 
and `descriptionTextAlign` to correspond more accurately with the TextAlign property. The 
original parameter names `titleAlignment` and `descriptionAlignment` are now reserved for widget 
alignment.

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

The `ShowCaseWidget` no longer requires a `Builder` widget and instead accepts a builder 
function directly.

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

For a complete list of changes and new features in each version, please refer to the [release 
notes](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/releases) on GitHub.

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
