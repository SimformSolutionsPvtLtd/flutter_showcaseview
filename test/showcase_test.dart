import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:showcaseview/src/tooltip_widget.dart';

class ShowcaseTestApp extends StatelessWidget {
  const ShowcaseTestApp({super.key});

  @override
  Widget build(BuildContext context)
  => ShowCaseWidget(builder: (_)
      => const MaterialApp(
          title: 'Flutter Test App',
          home: ShowcaseTestAppScreen(),
      )
  );
}

final w1Key = GlobalKey();
const w1Descr = "w1 descr";
const w1Title = "w1 title";

final w2Key = GlobalKey();
const w2Descr = "w2 descr";
const w2Title = "w2 title";

final scriptTopLevel = [
  w1Key,
  w2Key,
];

class ShowcaseTestAppScreen extends StatefulWidget {
  const ShowcaseTestAppScreen({super.key});

  @override
  State<StatefulWidget> createState() => ShowcaseTestAppScreenState();
}

class ShowcaseTestAppScreenState extends State<ShowcaseTestAppScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase(scriptTopLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Showcase(key: w1Key, description: w1Descr, title: w1Title, child: const Text('Text Widget 1')),
            Showcase(key: w2Key, description: w2Descr, title: w2Title, child: const Text('Text Widget 2')),
            // Perhaps we will want more tests?
            //   ElevatedButton(
            //     onPressed: () {
            //       showDialog(
            //         context: context,
            //         builder: (BuildContext context) {
            //           return AlertDialog(
            //             title: const Text('Dialog'),
            //             content: const Column(
            //               mainAxisSize: MainAxisSize.min,
            //               children: <Widget>[
            //                 Text('Dialog Text 1'),
            //                 Text('Dialog Text 2'),
            //               ],
            //             ),
            //             actions: <Widget>[
            //               TextButton(
            //                 child: const Text('Close'),
            //                 onPressed: () {
            //                   Navigator.of(context).pop();
            //                 },
            //               ),
            //             ],
            //           );
            //         },
            //       );
            //     },
            //     child: const Text('Open Dialog'),
            //   ),
          ],
        ),
      ),
    );
  }
}

Key _overlayKeyFor(GlobalKey showcaseKey)
=> ValueKey(showcaseKey);

void _expectOptionalText(String? text, Matcher m)
=> text != null ? expect(find.text(text), m) : null;

extension _MorePumps on WidgetTester {
  /// Pump implementation with some portion of continuouty.
  /// Duration of pump is defined by [d], amount if exact pump requests
  /// is defined by [n].
  /// This is alternative to pumpAndSettle. As long as we use animated showcase
  /// tooltips we can't use pumpAndSettle, since animation never stops and
  /// it triggers pumpAndSettle timeout.
  Future<void> pumpLilbit([Duration d = const Duration(seconds: 1), n=5]) async {
    for (int i = 0; i != n; ++i) {
      await pump(d~/n);
    }
  }

  /// Make sure showcase with global key [showcaseKey] really appears.
  /// Optionally check its [title] and [description].
  /// 1. Checks that this showcase is present.
  /// 2. Taps it.
  /// 3. Checks that it has been disappeared.
  Future<void> checkShowcase(
      GlobalKey showcaseKey,
      {
        String? title,
        String? description,
      }
  ) async {
      final overlay = find.byKey(_overlayKeyFor(showcaseKey));
      expect(overlay, findsOneWidget);

      final tooltip = find.byType(ToolTipWidget);
      expect(tooltip, findsOneWidget);

      _expectOptionalText(title, findsOneWidget);
      _expectOptionalText(description, findsOneWidget);

      // Tap it
      await tap(overlay);
      await pumpLilbit();

      final overlayTapped = find.byKey(_overlayKeyFor(w1Key));
      expect(overlayTapped, findsNothing);

      _expectOptionalText(title, findsNothing);
      _expectOptionalText(description, findsNothing);
  }
}

void main() {
  testWidgets('basic', (tester) async {

    await tester.pumpWidget(const ShowcaseTestApp());
    await tester.pumpLilbit();

    await tester.checkShowcase(w1Key, title: w1Title, description: w1Descr);
    await tester.checkShowcase(w2Key, title: w2Title, description: w2Descr);
  });
}
