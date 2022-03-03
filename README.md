![Showcaes View - Simform LLC.](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/blob/master/preview/banner.png?raw=true)


# ShowCaseView

[![Build](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/workflows/Build/badge.svg?branch=master)](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/actions) [![showcaseview](https://img.shields.io/pub/v/showcaseview?label=showcaseview)](https://pub.dev/packages/showcaseview)

A Flutter package allows you to Showcase/Highlight your widgets step by step.

## Preview

![The example app running in Android](https://github.com/simformsolutions/flutter_showcaseview/blob/master/preview/showcaseview.gif)



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
  builder: Builder(
    builder : (context) ()=> Somewidget()
  ),
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
```

Some more optional parameters

```dart
Showcase(
  key: _two,
  title: 'Profile',
  description: 'Click here to go to your Profile',
  disableAnimation: true,
  shapeBorder: CircleBorder(),
  radius: BorderRadius.all(Radius.circular(40)),
  showArrow: false,
  overlayPadding: EdgeInsets.all(5),
  slideDuration: Duration(milliseconds: 1500),
  tooltipColor: Colors.blueGrey,
  blurValue: 2,
  child: ...,
),
```

5. Using a `Showcase.withWidget` widget.

```dart
Showcase.withWidget(
  key: _three,
  cHeight: 80,
  cWidth: 140,
  shapeBorder: CircleBorder(),
  container: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      ...
    ],
  ),
  child: ...,
),
```

6. Starting the `ShowCase`
```dart
someEvent(){
    ShowCaseWidget.of(context).startShowCase([_one, _two, _three]);
}
```

7. onFinish method for `ShowCase`
```dart
ShowCaseWidget(
  onFinish: () {
    // Your code goes here
  },
  builder: Builder(
    builder : (context) ()=> Somewidget()
  ),
),
```

8. Go to next `ShowCase`
```dart
someEvent(){
  ShowCaseWidget.of(context).next();
}
```

9. Go to previous `ShowCase`
```dart
someEvent(){
  ShowCaseWidget.of(context).previous();
}
```

If you want to start the `ShowCaseView` as soon as your UI built up then use below code.

```dart
WidgetsBinding.instance.addPostFrameCallback((_) =>
  ShowCaseWidget.of(context).startShowCase([_one, _two, _three])
);
```

## How to use

Check out the **example** app in the [example](example) directory or the 'Example' tab on pub.dartlang.org for a more complete example.


## Main Contributors

<table>
  <tr>
    <td align="center"><a href="https://github.com/birjuvachhani"><img src="https://avatars.githubusercontent.com/u/20423471?s=100" width="100px;" alt=""/><br /><sub><b>Birju Vachhani</b></sub></a></td>
    <td align="center"><a href="https://github.com/DevarshRanpara"><img src="https://avatars.githubusercontent.com/u/26064415?s=100" width="100px;" alt=""/><br /><sub><b>Devarsh Ranpara</b></sub></a></td>
    <td align="center"><a href="https://github.com/AnkitPanchal10"><img src="https://avatars.githubusercontent.com/u/38405884?s=100" width="100px;" alt=""/><br /><sub><b>Ankit Panchal</b></sub></a></td>
    <td align="center"><a href="https://github.com/Kashifalaliwala"><img src="https://avatars.githubusercontent.com/u/30998350?s=100" width="100px;" alt=""/><br /><sub><b>Kashifa Laliwala</b></sub></a></td>
     <td align="center"><a href="https://github.com/vatsaltanna"><img src="https://avatars.githubusercontent.com/u/25323183?s=100" width="100px;" alt=""/><br /><sub><b>Vatsal Tanna</b></sub></a></td>
     <td align="center"><a href="https://github.com/sanket-simform"><img src="https://avatars.githubusercontent.com/u/65167856?v=4" width="100px;" alt=""/><br /><sub><b>Sanket Kachhela</b></sub></a></td>
     <td align="center"><a href="https://github.com/ParthBaraiya"><img src="https://avatars.githubusercontent.com/u/36261739?v=4" width="100px;" alt=""/><br /><sub><b>Parth Baraiya</b></sub></a></td>
          <td align="center"><a href="https://github.com/ShwetaChauhan18"><img src="https://avatars.githubusercontent.com/u/34509457" width="80px;" alt=""/><br /><sub><b>Shweta Chauhan</b></sub></a></td>
  </tr>
</table>
<br/>

## Note

We have updated license of flutter_showcaseview from BSD 2-Clause "Simplified" to MIT.

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
