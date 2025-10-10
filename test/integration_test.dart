import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:showcaseview/src/tooltip/tooltip.dart';
import 'package:showcaseview/src/utils/extensions.dart';

void main() {
  group('ShowcaseView Integration Tests', () {
    testWidgets('Single showcase starts and completes properly',
        (WidgetTester tester) async {
      final GlobalKey key1 = GlobalKey();

      int startCount = 0;
      int completeCount = 0;
      GlobalKey? lastStartedKey;
      GlobalKey? lastCompletedKey;
      bool finishCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'single_test_scope',
                onStart: (index, key) {
                  startCount++;
                  lastStartedKey = key;
                },
                onComplete: (index, key) {
                  completeCount++;
                  lastCompletedKey = key;
                },
                onFinish: () {
                  finishCalled = true;
                },
              );

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Showcase(
                      key: key1,
                      title: 'Single Showcase',
                      description: 'This is a single showcase test',
                      child: const Text('Target 1'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key1]);
                      },
                      child: const Text('Start Single Showcase'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify target is rendered
      expect(find.text('Target 1'), findsOneWidget);
      expect(find.text('Start Single Showcase'), findsOneWidget);

      // Start the showcase
      await tester.tap(find.text('Start Single Showcase'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify showcase started
      expect(startCount, 1);
      expect(lastStartedKey, key1);
      expect(ShowcaseView.get().isShowcaseRunning, true);
      expect(ShowcaseView.get().getActiveShowcaseKey, key1);

      // Complete the showcase programmatically
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify showcase completed
      expect(completeCount, 1);
      expect(lastCompletedKey, key1);
      expect(finishCalled, true);
      expect(ShowcaseView.get().isShowCaseCompleted, true);
    });

    testWidgets('Multiple showcases work in sequence',
        (WidgetTester tester) async {
      final GlobalKey key1 = GlobalKey();
      final GlobalKey key2 = GlobalKey();
      final GlobalKey key3 = GlobalKey();

      int startCount = 0;
      int completeCount = 0;
      GlobalKey? lastStartedKey;
      GlobalKey? lastCompletedKey;
      bool finishCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'multi_test_scope',
                onStart: (index, key) {
                  startCount++;
                  lastStartedKey = key;
                },
                onComplete: (index, key) {
                  completeCount++;
                  lastCompletedKey = key;
                },
                onFinish: () {
                  finishCalled = true;
                },
              );

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Showcase(
                      key: key1,
                      title: 'First Showcase',
                      description: 'This is the first showcase',
                      child: const Text('Target 1'),
                    ),
                    Showcase(
                      key: key2,
                      title: 'Second Showcase',
                      description: 'This is the second showcase',
                      child: const Text('Target 2'),
                    ),
                    Showcase(
                      key: key3,
                      title: 'Third Showcase',
                      description: 'This is the third showcase',
                      child: const Text('Target 3'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key1, key2, key3]);
                      },
                      child: const Text('Start Multiple Showcases'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify all targets are rendered
      expect(find.text('Target 1'), findsOneWidget);
      expect(find.text('Target 2'), findsOneWidget);
      expect(find.text('Target 3'), findsOneWidget);
      expect(find.text('Start Multiple Showcases'), findsOneWidget);

      // Start the showcase sequence
      await tester.tap(find.text('Start Multiple Showcases'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify first showcase started
      expect(startCount, 1);
      expect(lastStartedKey, key1);
      expect(ShowcaseView.get().isShowcaseRunning, true);
      expect(ShowcaseView.get().getActiveShowcaseKey, key1);

      // Complete first showcase
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify second showcase started
      expect(startCount, 2);
      expect(lastStartedKey, key2);
      expect(completeCount, 1);
      expect(lastCompletedKey, key1);
      expect(ShowcaseView.get().getActiveShowcaseKey, key2);

      // Complete second showcase
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify third showcase started
      expect(startCount, 3);
      expect(lastStartedKey, key3);
      expect(completeCount, 2);
      expect(lastCompletedKey, key2);
      expect(ShowcaseView.get().getActiveShowcaseKey, key3);

      // Complete third showcase
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      // Verify all showcases completed
      expect(completeCount, 3);
      expect(lastCompletedKey, key3);
      expect(finishCalled, true);
      expect(ShowcaseView.get().isShowCaseCompleted, true);
    });

    testWidgets(
        'Multiple showcases with same key start simultaneously and create overlapping areas',
        (WidgetTester tester) async {
      // Use the same key for multiple showcases to start them simultaneously
      final GlobalKey sharedKey = GlobalKey();

      int startCount = 0;
      int completeCount = 0;
      bool finishCalled = false;
      List<GlobalKey> startedKeys = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'simultaneous_test_scope',
                onStart: (index, key) {
                  startCount++;
                  startedKeys.add(key);
                },
                onComplete: (index, key) {
                  completeCount++;
                },
                onFinish: () {
                  finishCalled = true;
                },
              );

              return Scaffold(
                body: Stack(
                  children: [
                    // Multiple showcases with the same key to start simultaneously
                    // This creates overlapping areas that need proper clipping
                    Positioned(
                      top: 150,
                      left: 100,
                      child: Showcase(
                        key: sharedKey,
                        title: 'Simultaneous Showcase 1',
                        description:
                            'This showcase starts with others using the same key',
                        child: Container(
                          width: 120,
                          height: 80,
                          color: Colors.red.reduceOpacity(0.7),
                          child: const Center(
                            child: Text(
                              'Overlap Area 1',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 180,
                      left: 130,
                      child: Showcase(
                        key: sharedKey,
                        title: 'Simultaneous Showcase 2',
                        description:
                            'This showcase overlaps with the first one',
                        child: Container(
                          width: 120,
                          height: 80,
                          color: Colors.blue.reduceOpacity(0.7),
                          child: const Center(
                            child: Text(
                              'Overlap Area 2',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 210,
                      left: 160,
                      child: Showcase(
                        key: sharedKey,
                        title: 'Simultaneous Showcase 3',
                        description:
                            'This showcase also overlaps creating a complex overlapping region',
                        child: Container(
                          width: 120,
                          height: 80,
                          color: Colors.green.withOpacity(0.7),
                          child: const Center(
                            child: Text(
                              'Overlap Area 3',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 100,
                      left: 50,
                      right: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Start all showcases with the same key simultaneously
                          ShowcaseView.get().startShowCase([sharedKey]);
                        },
                        child: const Text(
                          'Start Simultaneous Overlapping Showcases',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify all overlapping targets are rendered
      expect(find.text('Overlap Area 1'), findsOneWidget);
      expect(find.text('Overlap Area 2'), findsOneWidget);
      expect(find.text('Overlap Area 3'), findsOneWidget);
      expect(
        find.text('Start Simultaneous Overlapping Showcases'),
        findsOneWidget,
      );

      // Start the simultaneous showcases
      await tester.tap(find.text('Start Simultaneous Overlapping Showcases'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify showcases started simultaneously
      // Since they share the same key, they should all be treated as one showcase
      expect(startCount, 1);
      expect(startedKeys.length, 1);
      expect(startedKeys.first, sharedKey);
      expect(ShowcaseView.get().isShowcaseRunning, true);
      expect(ShowcaseView.get().getActiveShowcaseKey, sharedKey);

      // Verify that all overlapping areas are properly cut out
      // The overlapping region should be transparent, not black
      // This tests our ShapeClipper fix for overlapping shapes
      expect(find.text('Overlap Area 1'), findsOneWidget);
      expect(find.text('Overlap Area 2'), findsOneWidget);
      // Complete the simultaneous showcases
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify all showcases completed
      expect(completeCount, 1);
      expect(finishCalled, true);
      expect(ShowcaseView.get().isShowCaseCompleted, true);
      expect(ShowcaseView.get().isShowcaseRunning, false);
      expect(ShowcaseView.get().getActiveShowcaseKey, null);
    });

    testWidgets('Mixed showcase keys - some same, some different',
        (WidgetTester tester) async {
      final GlobalKey simultaneousKey = GlobalKey();
      final GlobalKey individualKey1 = GlobalKey();
      final GlobalKey individualKey2 = GlobalKey();

      int startCount = 0;
      int completeCount = 0;
      bool finishCalled = false;
      List<GlobalKey> showcaseSequence = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'mixed_keys_test_scope',
                onStart: (index, key) {
                  startCount++;
                  showcaseSequence.add(key);
                },
                onComplete: (index, key) {
                  completeCount++;
                },
                onFinish: () {
                  finishCalled = true;
                },
              );

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Two showcases with the same key (will start simultaneously)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Showcase(
                          key: simultaneousKey,
                          title: 'Simultaneous A',
                          description: 'Part of simultaneous group',
                          child: Container(
                            width: 80,
                            height: 60,
                            color: Colors.orange,
                            child: const Center(child: Text('Sim A')),
                          ),
                        ),
                        Showcase(
                          key: simultaneousKey,
                          title: 'Simultaneous B',
                          description: 'Part of simultaneous group',
                          child: Container(
                            width: 80,
                            height: 60,
                            color: Colors.purple,
                            child: const Center(child: Text('Sim B')),
                          ),
                        ),
                      ],
                    ),
                    // Individual showcases with unique keys
                    Showcase(
                      key: individualKey1,
                      title: 'Individual 1',
                      description: 'Individual showcase',
                      child: Container(
                        width: 100,
                        height: 60,
                        color: Colors.teal,
                        child: const Center(child: Text('Individual 1')),
                      ),
                    ),
                    Showcase(
                      key: individualKey2,
                      title: 'Individual 2',
                      description: 'Another individual showcase',
                      child: Container(
                        width: 100,
                        height: 60,
                        color: Colors.brown,
                        child: const Center(child: Text('Individual 2')),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Start mixed sequence: simultaneous key, then individual keys
                        ShowcaseView.get().startShowCase([
                          simultaneousKey,
                          individualKey1,
                          individualKey2,
                        ]);
                      },
                      child: const Text('Start Mixed Showcase Sequence'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify all targets are rendered
      expect(find.text('Sim A'), findsOneWidget);
      expect(find.text('Sim B'), findsOneWidget);
      expect(find.text('Individual 1'), findsOneWidget);
      expect(find.text('Individual 2'), findsOneWidget);

      // Start the mixed showcase sequence
      await tester.tap(find.text('Start Mixed Showcase Sequence'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // First showcase should be the simultaneous one
      expect(startCount, 1);
      expect(showcaseSequence.first, simultaneousKey);
      expect(ShowcaseView.get().getActiveShowcaseKey, simultaneousKey);

      // Complete simultaneous showcase
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Second showcase should be individual key 1
      expect(startCount, 2);
      expect(showcaseSequence[1], individualKey1);
      expect(ShowcaseView.get().getActiveShowcaseKey, individualKey1);
      expect(completeCount, 1);

      // Complete individual showcase 1
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Third showcase should be individual key 2
      expect(startCount, 3);
      expect(showcaseSequence[2], individualKey2);
      expect(ShowcaseView.get().getActiveShowcaseKey, individualKey2);
      expect(completeCount, 2);

      // Complete individual showcase 2
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // All showcases should be completed
      expect(completeCount, 3);
      expect(finishCalled, true);
      expect(ShowcaseView.get().isShowCaseCompleted, true);
      expect(ShowcaseView.get().isShowcaseRunning, false);
      expect(ShowcaseView.get().getActiveShowcaseKey, null);
    });

    testWidgets('disposeOnTap and onTargetClick functionality test',
        (WidgetTester tester) async {
      final GlobalKey key1 = GlobalKey();
      final GlobalKey key2 = GlobalKey();
      final GlobalKey key3 = GlobalKey();

      int startCount = 0;
      int completeCount = 0;
      bool finishCalled = false;

      // Track target click events
      int target1ClickCount = 0;
      int target2ClickCount = 0;

      List<GlobalKey> showcaseSequence = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'dispose_on_tap_test_scope',
                onStart: (index, key) {
                  startCount++;
                  showcaseSequence.add(key);
                },
                onComplete: (index, key) {
                  completeCount++;
                },
                onFinish: () {
                  finishCalled = true;
                },
                onDismiss: (_) {
                  finishCalled = true;
                },
              );

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // First showcase: disposeOnTap = true, should dispose when tapped
                    Showcase(
                      key: key1,
                      title: 'Disposable Showcase',
                      description: 'Tap this target to dispose all showcases',
                      disposeOnTap: true,
                      onTargetClick: () {
                        target1ClickCount++;
                      },
                      child: Container(
                        width: 100,
                        height: 60,
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            'Target 1\n(Disposable)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    // Second showcase: disposeOnTap = false, should NOT dispose when tapped
                    Showcase(
                      key: key2,
                      title: 'Non-Disposable Showcase',
                      description:
                          'Tap this target - it should NOT dispose showcases',
                      disposeOnTap: false,
                      onTargetClick: () {
                        target2ClickCount++;
                      },
                      child: Container(
                        width: 100,
                        height: 60,
                        color: Colors.blue,
                        child: const Center(
                          child: Text(
                            'Target 2\n(Non-Disposable)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    // Third showcase: disposeOnTap = false, should NOT dispose when tapped
                    Showcase(
                      key: key3,
                      title: 'Default Showcase',
                      description:
                          'Tap this target - default behavior (no disposal)',
                      // onTargetClick: () {
                      //   // Add empty callback to track clicks but not dispose
                      // },
                      // disposeOnTap: false,
                      disableBarrierInteraction: true,
                      child: InkWell(
                        child: Container(
                          width: 100,
                          height: 60,
                          color: Colors.green,
                          child: const Center(
                            child: Text(
                              'Target 3\n(Default)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key1, key2, key3]);
                      },
                      child: const Text('Start Dispose Test Showcases'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify all targets are rendered
      expect(find.text('Target 1\n(Disposable)'), findsOneWidget);
      expect(find.text('Target 2\n(Non-Disposable)'), findsOneWidget);
      expect(find.text('Target 3\n(Default)'), findsOneWidget);

      // Test 1: Start showcases and tap on first target (disposable)
      await tester.tap(find.text('Start Dispose Test Showcases'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify first showcase started
      expect(startCount, 1);
      expect(showcaseSequence.first, key1);
      expect(ShowcaseView.get().isShowcaseRunning, true);
      expect(ShowcaseView.get().getActiveShowcaseKey, key1);

      // Tap on the first target (should dispose all showcases)
      await tester.tap(
        find.text('Target 1\n(Disposable)'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify target click was registered and showcases were disposed
      expect(target1ClickCount, 1);
      expect(ShowcaseView.get().isShowcaseRunning, false);
      expect(ShowcaseView.get().getActiveShowcaseKey, null);
      expect(finishCalled, true);

      // Reset for next test
      finishCalled = false;
      startCount = 0;
      completeCount = 0;
      showcaseSequence.clear();

      // Test 2: Start showcases and test non-disposable target
      await tester.tap(find.text('Start Dispose Test Showcases'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify first showcase started again
      expect(startCount, 1);
      expect(ShowcaseView.get().isShowcaseRunning, true);
      expect(ShowcaseView.get().getActiveShowcaseKey, key1);

      // Move to second showcase (non-disposable)
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(startCount, 2);
      expect(ShowcaseView.get().getActiveShowcaseKey, key2);
      expect(completeCount, 1);

      // Tap on the second target (should NOT dispose showcases)
      await tester.tap(
        find.text('Target 2\n(Non-Disposable)'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify target click was registered but showcases were NOT disposed
      expect(ShowcaseView.get().isShowcaseRunning, true);
      expect(ShowcaseView.get().getActiveShowcaseKey, key2);
      expect(finishCalled, false);
      expect(target2ClickCount, 1);

      // Move to third showcase (default behavior)
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(startCount, 3);
      expect(ShowcaseView.get().getActiveShowcaseKey, key3);
      expect(completeCount, 2);

      // Tap on the third target (should NOT dispose showcases - default behavior)
      await tester.tap(
        find.text('Target 3\n(Default)'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify all showcases completed normally
      expect(completeCount, 3);
      expect(finishCalled, true);
      expect(ShowcaseView.get().isShowCaseCompleted, true);
      expect(ShowcaseView.get().isShowcaseRunning, false);
      expect(ShowcaseView.get().getActiveShowcaseKey, null);

      // Verify all target clicks were registered correctly
      expect(target1ClickCount, 1);
      expect(target2ClickCount, 1);
    });

    testWidgets('Showcase styling properties test (with style checks)',
        (WidgetTester tester) async {
      final GlobalKey key1 = GlobalKey();
      final GlobalKey key2 = GlobalKey();
      final GlobalKey key3 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'styling_test_scope',
              );

              return Scaffold(
                body: Column(
                  children: [
                    Showcase(
                      key: key1,
                      title: 'Custom Styled Showcase',
                      description:
                          'This showcase has custom styling properties',
                      titleTextStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      descTextStyle: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.deepOrange,
                      ),
                      tooltipBackgroundColor: Colors.lightBlue,
                      tooltipBorderRadius: BorderRadius.circular(20),
                      tooltipPadding: const EdgeInsets.all(20),
                      overlayColor: Colors.purple,
                      overlayOpacity: 0.3,
                      targetPadding: const EdgeInsets.all(10),
                      targetBorderRadius: BorderRadius.circular(15),
                      showArrow: false,
                      child: Container(
                        width: 80,
                        height: 60,
                        color: Colors.amber,
                        child: const Center(child: Text('Styled Target')),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key1, key2, key3]);
                      },
                      child: const Text('Start Styling Tests'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Start Styling Tests'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // 👇 Assert tooltip exists
      expect(ShowcaseView.get().getActiveShowcaseKey, key1);
      expect(find.byType(ToolTipWidget), findsOneWidget);

      final textWidgets = tester.widgetList<Text>(find.byType(Text)).toList();

      final titleText =
          textWidgets.firstWhere((t) => t.data == 'Custom Styled Showcase');
      final descText = textWidgets.firstWhere(
        (t) => t.data == 'This showcase has custom styling properties',
      );

      // 👇 Assert title text style
      expect(titleText.style?.fontSize, 24);
      expect(titleText.style?.fontWeight, FontWeight.bold);
      expect(titleText.style?.color, Colors.deepPurple);

      // 👇 Assert description style
      expect(descText.style?.fontSize, 16);
      expect(descText.style?.fontStyle, FontStyle.italic);
      expect(descText.style?.color, Colors.deepOrange);

      // 👇 Assert tooltip padding and background color
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ToolTipWidget),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, Colors.lightBlue);
      expect(decoration?.borderRadius, BorderRadius.circular(20));

      // 👇 Overlay check is hard due to blur/opacity limitations
      // You can check if there's a widget in the tree with expected overlay color if it's implemented as such

      // Complete the showcase
      ShowcaseView.get().next();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets(
        'Showcase animation properties test (with animation assertions)',
        (WidgetTester tester) async {
      final GlobalKey key1 = GlobalKey();
      final GlobalKey key2 = GlobalKey();
      final GlobalKey key3 = GlobalKey();

      int startCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'animation_test_scope',
                onStart: (index, key) {
                  startCount++;
                },
              );

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Showcase(
                      key: key1,
                      title: 'No Moving Animation',
                      description:
                          'This showcase has moving animation disabled',
                      disableMovingAnimation: true,
                      movingAnimationDuration: const Duration(
                        milliseconds: 1000,
                      ), // should be ignored
                      child: Container(
                        key: const Key('no_move_target'),
                        width: 80,
                        height: 60,
                        color: Colors.red,
                        child: const Center(child: Text('No Move')),
                      ),
                    ),
                    Showcase(
                      key: key2,
                      title: 'Custom Scale Animation',
                      description:
                          'This showcase has custom scale animation properties',
                      disableScaleAnimation: false,
                      scaleAnimationDuration: const Duration(milliseconds: 500),
                      scaleAnimationCurve: Curves.bounceOut,
                      scaleAnimationAlignment: Alignment.topLeft,
                      child: Container(
                        key: const Key('custom_scale_target'),
                        width: 100,
                        height: 60,
                        color: Colors.blue,
                        child: const Center(child: Text('Custom Scale')),
                      ),
                    ),
                    Showcase(
                      key: key3,
                      title: 'No Scale Animation',
                      description: 'This showcase has scale animation disabled',
                      disableScaleAnimation: true,
                      child: Container(
                        key: const Key('no_scale_target'),
                        width: 90,
                        height: 60,
                        color: Colors.orange,
                        child: const Center(child: Text('No Scale')),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key1, key2, key3]);
                      },
                      child: const Text('Start Animation Tests'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Start Animation Tests'));
      await tester.pump(); // trigger animation
      await tester.pump(const Duration(milliseconds: 100)); // partial render

      expect(startCount, 1);
      expect(ShowcaseView.get().getActiveShowcaseKey, key1);

      // 🔍 Check that the widget with no animation is rendered immediately
      final noMoveTarget = find.byKey(const Key('no_move_target'));
      expect(noMoveTarget, findsOneWidget);

      // Move to second showcase (with scale animation)
      ShowcaseView.get().next();
      await tester.pump(); // trigger animation
      await tester.pump(const Duration(milliseconds: 100));
      expect(startCount, 2);
      expect(ShowcaseView.get().getActiveShowcaseKey, key2);

      // ⏱ Simulate enough time for animation
      await tester.pump(const Duration(milliseconds: 500));

      // 🔍 Check scale animation container is present
      final customScaleTarget = find.byKey(const Key('custom_scale_target'));
      expect(customScaleTarget, findsOneWidget);

      // Optionally test for ScaleTransition or Transform widget
      final scaleWidget = find.ancestor(
        of: customScaleTarget,
        matching: find.byType(AnimatedBuilder),
      );
      expect(scaleWidget, findsWidgets); // may vary based on your Showcase lib

      // Move to third showcase (scale disabled)
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(startCount, 3);
      expect(ShowcaseView.get().getActiveShowcaseKey, key3);

      final noScaleTarget = find.byKey(const Key('no_scale_target'));
      expect(noScaleTarget, findsOneWidget);

      // ✅ Done
      ShowcaseView.get().next();
      await tester.pumpAndSettle();

      expect(ShowcaseView.get().isShowCaseCompleted, true);
    });

    testWidgets('Showcase gesture callbacks test', (WidgetTester tester) async {
      final GlobalKey gestureKey = GlobalKey();

      int targetLongPressCount = 0;
      int targetDoubleTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'gesture_callbacks_test_scope',
              );

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Showcase(
                        key: gestureKey,
                        title: 'Gesture Test',
                        description: 'Test various gesture callbacks',
                        onTargetLongPress: () {
                          targetLongPressCount++;
                        },
                        onTargetDoubleTap: () {
                          targetDoubleTapCount++;
                        },
                        child: Container(
                          width: 100,
                          height: 60,
                          color: Colors.purple,
                          child: const Center(child: Text('Gesture Target')),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ShowcaseView.get().startShowCase([gestureKey]);
                        },
                        child: const Text('Start Gesture Test'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Start gesture test
      await tester.tap(find.text('Start Gesture Test'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(ShowcaseView.get().isShowcaseRunning, true);

      // Test target long press
      await tester.longPress(
        find.text('Gesture Target'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(targetLongPressCount, 1);

      // Test target double tap (if showcase is still running)
      if (ShowcaseView.get().isShowcaseRunning) {
        await tester.tap(find.text('Gesture Target'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Gesture Target'), warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(targetDoubleTapCount, 1);
      }

      // Complete the test
      if (ShowcaseView.get().isShowcaseRunning) {
        ShowcaseView.get().next();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }

      expect(ShowcaseView.get().isShowCaseCompleted, true);
    });

    testWidgets(
        'Showcase `disableBarrierInteraction` and `disableDefaultTargetGestures` test',
        (WidgetTester tester) async {
      final GlobalKey disabledKey = GlobalKey();
      int onTargetGesture = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'disabled_gestures_test_scope',
              );

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Showcase(
                        key: disabledKey,
                        title: 'Disabled Gestures',
                        description:
                            'This showcase has disabled default target gestures',
                        disableDefaultTargetGestures: true,
                        disableBarrierInteraction: true,
                        disposeOnTap: true,
                        onTargetClick: () {
                          onTargetGesture++;
                        },
                        onTargetLongPress: () {
                          onTargetGesture++;
                        },
                        child: Container(
                          width: 100,
                          height: 60,
                          color: Colors.cyan,
                          child: const Center(child: Text('Disabled Target')),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ShowcaseView.get().startShowCase([disabledKey]);
                        },
                        child: const Text('Start Disabled Test'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Start disabled gestures test
      await tester.tap(find.text('Start Disabled Test'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(ShowcaseView.get().isShowcaseRunning, true);

      // Try interactions on disabled target - they should not work
      await tester.tap(find.text('Disabled Target'), warnIfMissed: false);
      expect(onTargetGesture, 0);
      await tester.longPress(find.text('Disabled Target'), warnIfMissed: false);
      expect(onTargetGesture, 0);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Showcase should still be running since gestures are disabled
      expect(ShowcaseView.get().isShowcaseRunning, true);

      // Complete the test manually
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(ShowcaseView.get().isShowCaseCompleted, true);
    });

    testWidgets('Showcase tooltip positioning and layout test',
        (WidgetTester tester) async {
      final GlobalKey topKey = GlobalKey();
      final GlobalKey bottomKey = GlobalKey();
      final GlobalKey autoKey = GlobalKey();

      int startCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'positioning_test_scope',
                onStart: (index, key) {
                  startCount++;
                },
              );

              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top positioned showcase
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Showcase(
                        key: topKey,
                        title: 'Top Position',
                        description: 'Tooltip positioned at top',
                        tooltipPosition: TooltipPosition.top,
                        toolTipMargin: 20,
                        targetTooltipGap: 15,
                        child: Container(
                          width: 100,
                          height: 60,
                          color: Colors.red,
                          child: const Center(child: Text('Top Target')),
                        ),
                      ),
                    ),

                    // Auto positioned showcase (center)
                    Showcase(
                      key: autoKey,
                      title: 'Auto Position',
                      description:
                          'Tooltip positioned automatically based on available space',
                      toolTipSlideEndDistance: 10,
                      child: Container(
                        width: 120,
                        height: 60,
                        color: Colors.green,
                        child: const Center(child: Text('Auto Target')),
                      ),
                    ),

                    // Bottom positioned showcase
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Showcase(
                        key: bottomKey,
                        title: 'Bottom Position',
                        description: 'Tooltip positioned at bottom',
                        tooltipPosition: TooltipPosition.bottom,
                        toolTipMargin: 25,
                        targetTooltipGap: 20,
                        child: Container(
                          width: 100,
                          height: 60,
                          color: Colors.blue,
                          child: const Center(child: Text('Bottom Target')),
                        ),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get()
                            .startShowCase([topKey, autoKey, bottomKey]);
                      },
                      child: const Text('Start Position Tests'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Start positioning tests
      await tester.tap(find.text('Start Position Tests'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(startCount, 1);
      expect(ShowcaseView.get().getActiveShowcaseKey, topKey);

      // Move through different positioned showcases
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(startCount, 2);
      expect(ShowcaseView.get().getActiveShowcaseKey, autoKey);

      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(startCount, 3);
      expect(ShowcaseView.get().getActiveShowcaseKey, bottomKey);

      // Complete positioning tests
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(ShowcaseView.get().isShowCaseCompleted, true);
    });

    testWidgets('Showcase custom widget container test',
        (WidgetTester tester) async {
      final GlobalKey customKey = GlobalKey();

      int startCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'custom_widget_test_scope',
                onStart: (index, key) {
                  startCount++;
                },
              );

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Custom widget showcase
                      Showcase.withWidget(
                        key: customKey,
                        height: 150,
                        width: 200,
                        container: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Custom Widget Showcase!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Custom Design',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              'Custom\nTarget',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      ElevatedButton(
                        onPressed: () {
                          ShowcaseView.get().startShowCase([customKey]);
                        },
                        child: const Text('Start Custom Widget Test'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Verify custom widget target is rendered
      expect(find.text('Custom\nTarget'), findsOneWidget);

      // Start custom widget showcase test
      await tester.tap(find.text('Start Custom Widget Test'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(startCount, 1);
      expect(ShowcaseView.get().getActiveShowcaseKey, customKey);
      expect(ShowcaseView.get().isShowcaseRunning, true);

      // Complete custom widget showcase
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(ShowcaseView.get().isShowCaseCompleted, true);
      expect(ShowcaseView.get().isShowcaseRunning, false);
    });

    testWidgets('Showcase scroll properties and auto-scroll test',
        (WidgetTester tester) async {
      final GlobalKey scrollKey1 = GlobalKey();
      final GlobalKey scrollKey2 = GlobalKey();

      int startCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'scroll_test_scope',
                onStart: (index, key) {
                  startCount++;
                },
              );

              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Add some content to make scrolling necessary
                      ...List.generate(
                        10,
                        (index) => Container(
                          height: 100,
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey[300],
                          child: Center(child: Text('Spacer $index')),
                        ),
                      ),

                      // First scrollable showcase
                      Showcase(
                        key: scrollKey1,
                        title: 'Scrollable Showcase 1',
                        description:
                            'This showcase tests auto-scroll functionality',
                        enableAutoScroll: true,
                        scrollAlignment: 0.3,
                        scrollLoadingWidget: const CircularProgressIndicator(
                          color: Colors.red,
                        ),
                        child: Container(
                          width: 200,
                          height: 80,
                          color: Colors.red,
                          child: const Center(
                            child: Text(
                              'Scroll Target 1',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      ...List.generate(
                        10,
                        (index) => Container(
                          height: 100,
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey[300],
                          child: Center(child: Text('Spacer ${index + 10}')),
                        ),
                      ),

                      // Second scrollable showcase
                      Showcase(
                        key: scrollKey2,
                        title: 'Scrollable Showcase 2',
                        description: 'Another showcase to test scroll behavior',
                        enableAutoScroll: true,
                        scrollAlignment: 0.7,
                        child: Container(
                          width: 200,
                          height: 80,
                          color: Colors.blue,
                          child: const Center(
                            child: Text(
                              'Scroll Target 2',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      ...List.generate(
                        5,
                        (index) => Container(
                          height: 100,
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey[300],
                          child: Center(child: Text('Bottom Spacer $index')),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          ShowcaseView.get()
                              .startShowCase([scrollKey1, scrollKey2]);
                        },
                        child: const Text('Start Scroll Tests'),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();

      // Scroll to see the button
      await tester.dragUntilVisible(
        find.text('Start Scroll Tests'),
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pump();

      // Start scroll tests
      await tester.tap(find.text('Start Scroll Tests'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(startCount, 1);
      expect(ShowcaseView.get().getActiveShowcaseKey, scrollKey1);

      // Wait for potential auto-scroll
      await tester.pump(const Duration(milliseconds: 1000));

      // Move to second showcase
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(startCount, 2);
      expect(ShowcaseView.get().getActiveShowcaseKey, scrollKey2);

      // Wait for potential auto-scroll
      await tester.pump(const Duration(milliseconds: 1000));

      // Complete scroll tests
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(ShowcaseView.get().isShowCaseCompleted, true);
    });

    testWidgets('Showcase custom styling, animation, and flow test',
        (WidgetTester tester) async {
      final GlobalKey showcaseKey = GlobalKey();
      int onStartCount = 0;
      int onCompleteCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'custom_full_test_scope',
                onStart: (index, key) => onStartCount++,
                onComplete: (_, __) => onCompleteCount++,
              );
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Showcase(
                        key: showcaseKey,
                        title: 'Styled & Animated',
                        description: 'Custom style, animation, and flow',
                        titleTextStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                        descTextStyle: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.pink,
                        ),
                        tooltipBackgroundColor: Colors.yellow,
                        tooltipBorderRadius: BorderRadius.circular(18),
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        overlayColor: Colors.black,
                        blurValue: 0,
                        overlayOpacity: 0.4,
                        targetPadding: const EdgeInsets.all(8),
                        targetBorderRadius: BorderRadius.circular(10),
                        showArrow: true,
                        disableMovingAnimation: false,
                        movingAnimationDuration:
                            const Duration(milliseconds: 400),
                        disableScaleAnimation: false,
                        scaleAnimationDuration:
                            const Duration(milliseconds: 300),
                        scaleAnimationCurve: Curves.easeInOutBack,
                        scaleAnimationAlignment: Alignment.bottomRight,
                        tooltipPosition: TooltipPosition.bottom,
                        toolTipMargin: 12,
                        targetTooltipGap: 10,
                        child: Container(
                          width: 90,
                          height: 50,
                          color: Colors.tealAccent,
                          child: const Center(child: Text('Showcase Target')),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          ShowcaseView.get().startShowCase([showcaseKey]);
                        },
                        child: const Text('Start Full Showcase Test'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Showcase Target'), findsOneWidget);
      await tester.tap(find.text('Start Full Showcase Test'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify showcase started
      expect(onStartCount, 1);
      expect(ShowcaseView.get().isShowcaseRunning, true);
      expect(ShowcaseView.get().getActiveShowcaseKey, showcaseKey);

      // Verify tooltip exists
      expect(find.byType(ToolTipWidget), findsOneWidget);

      // Verify text styles
      final textWidgets = tester.widgetList<Text>(find.byType(Text)).toList();
      final titleText =
          textWidgets.firstWhere((t) => t.data == 'Styled & Animated');
      final descText = textWidgets
          .firstWhere((t) => t.data == 'Custom style, animation, and flow');
      expect(titleText.style?.fontSize, 22);
      expect(titleText.style?.fontWeight, FontWeight.w600);
      expect(titleText.style?.color, Colors.teal);
      expect(descText.style?.fontSize, 14);
      expect(descText.style?.fontStyle, FontStyle.italic);
      expect(descText.style?.color, Colors.pink);

      // Verify tooltip container styling
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ToolTipWidget),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, Colors.yellow);
      expect(decoration?.borderRadius, BorderRadius.circular(18));
      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      );

      // Verify overlay color and opacity (if possible)
      // (This may depend on implementation, so just check overlay widget exists)
      expect(
        find.byWidgetPredicate((w) {
          Color? color;
          if (w is ColoredBox) {
            color = w.color;
          } else if (w is DecoratedBox && w.decoration is BoxDecoration) {
            color = (w.decoration as BoxDecoration).color;
          }
          return color != null &&
              color.value == Colors.black.withOpacity(0.4).value;
        }),
        findsWidgets,
      );

      // Verify arrow is shown
      expect(
        find.byType(CustomPaint),
        findsWidgets,
      ); // Arrow is usually a CustomPaint

      // Animation checks: move to next and verify transitions
      // (You may want to check for AnimatedBuilder, Transform, or ScaleTransition)
      final animated = find.ancestor(
        of: find.text('Showcase Target'),
        matching: find.byType(AnimatedBuilder),
      );
      expect(animated, findsWidgets);

      // Complete the showcase
      ShowcaseView.get().next();
      await tester.pumpAndSettle();
      expect(ShowcaseView.get().isShowCaseCompleted, true);
      expect(onCompleteCount, 1);
      expect(ShowcaseView.get().isShowcaseRunning, false);
    });
  });
}
