![alt text](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/blob/master/banner.png?raw=true)


# ShowCaseView

[![Build](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/workflows/Build/badge.svg?branch=master)](https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/actions) [![showcaseview](https://img.shields.io/pub/v/showcaseview?label=showcaseview)](https://pub.dev/packages/showcaseview)

A Flutter package allows you to Showcase/Highlight your widgets step by step.

It is inspired from [Fluttery's Flutter challenge](https://www.youtube.com/watch?v=Xm0ELlBtNWM).



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
  showArrow: false,
  overlayPadding: EdgeInsets.all(5),
  slideDuration: Duration(milliseconds: 1500),
  tooltipColor: Colors.blueGrey,
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
    ShowCaseWidget.startShowCase(context, [_one, _two, _three]);
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

If you want to start the `ShowCaseView` as soon as your UI built up then use below code.
```dart
WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.startShowCase(context, [_one, _two, _three]));
```


## How to use
Check out the **example** app in the [example](example) directory or the 'Example' tab on pub.dartlang.org for a more complete example.

<br/>

## Main Contributors

<table>
  <tr>
    <td align="center"><a href="https://github.com/birjuvachhani"><img src="https://avatars.githubusercontent.com/u/20423471?s=100" width="100px;" alt=""/><br /><sub><b>Birju Vachhani</b></sub></a></td>
    <td align="center"><a href="https://github.com/DevarshRanpara"><img src="https://avatars.githubusercontent.com/u/26064415?s=100" width="100px;" alt=""/><br /><sub><b>Devarsh Ranpara</b></sub></a></td>
    <td align="center"><a href="https://github.com/AnkitPanchal10"><img src="https://avatars.githubusercontent.com/u/38405884?s=100" width="100px;" alt=""/><br /><sub><b>Ankit Panchal</b></sub></a></td>
    <td align="center"><a href="https://github.com/Kashifalaliwala"><img src="https://avatars.githubusercontent.com/u/30998350?s=100" width="100px;" alt=""/><br /><sub><b>Kashifa Laliwala</b></sub></a></td>
     <td align="center"><a href="https://github.com/vatsaltanna"><img src="https://avatars.githubusercontent.com/u/25323183?s=100" width="100px;" alt=""/><br /><sub><b>Vatsal Tanna</b></sub></a></td>
  </tr>
</table>
<br/>

## License

```
Copyright © 2020, Simform Solutions
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

```
