import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaseview/showcaseview.dart';

void main() {
  group('ShowcaseView Tests', () {
    // Consolidated test for basic registration and property access
    tearDown(
      () {
        ShowcaseView.get().unregister();
      },
    );
    testWidgets(
        'ShowcaseView.register creates instance with correct properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'test_scope',
                onStart: (index, key) {},
                onComplete: (index, key) {},
                onFinish: () {},
                enableShowcase: true,
                autoPlay: false,
                autoPlayDelay: const Duration(seconds: 2),
                enableAutoPlayLock: false,
                enableAutoScroll: false,
                scrollDuration: const Duration(milliseconds: 500),
                disableBarrierInteraction: false,
                disableScaleAnimation: false,
                disableMovingAnimation: false,
                blurValue: 0,
                globalTooltipActions: [],
                globalTooltipActionConfig: null,
                globalFloatingActionWidget: null,
                hideFloatingActionWidgetForShowcase: [],
              );

              return Scaffold(
                body: Container(),
              );
            },
          ),
        ),
      );

      final showcaseView = ShowcaseView.get();
      expect(showcaseView.scope, 'test_scope');
      expect(showcaseView.enableShowcase, true);
      expect(showcaseView.autoPlay, false);
      expect(showcaseView.autoPlayDelay, const Duration(seconds: 2));
      expect(showcaseView.enableAutoPlayLock, false);
      expect(showcaseView.enableAutoScroll, false);
      expect(showcaseView.scrollDuration, const Duration(milliseconds: 500));
      expect(showcaseView.disableBarrierInteraction, false);
      expect(showcaseView.disableScaleAnimation, false);
      expect(showcaseView.disableMovingAnimation, false);
      expect(showcaseView.blurValue, 0);
      expect(showcaseView.globalTooltipActions, isEmpty);
      expect(showcaseView.globalTooltipActionConfig, isNull);
      expect(showcaseView.globalFloatingActionWidget, isNull);
      expect(showcaseView.hiddenFloatingActionKeys, isEmpty);
    });

    testWidgets('ShowcaseView.get returns registered instance',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(scope: 'get_test_scope');
              return Scaffold(body: Container());
            },
          ),
        ),
      );

      final showcaseView = ShowcaseView.get();
      expect(showcaseView.scope, 'get_test_scope');
      // Verify default values for important properties
      expect(showcaseView.enableShowcase, true);
      expect(showcaseView.autoPlay, false);
    });

    testWidgets('ShowcaseView.getNamed returns named instance',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(scope: 'named_test_scope');
              return Scaffold(body: Container());
            },
          ),
        ),
      );

      final showcaseView = ShowcaseView.getNamed('named_test_scope');
      expect(showcaseView.scope, 'named_test_scope');
      // Also verify with incorrect scope name
      expect(
        () => ShowcaseView.getNamed('non_existent_scope'),
        throwsException,
      );
    });

    // Lifecycle test with improved verification
    testWidgets(
        'ShowcaseView state properties work correctly through lifecycle',
        (WidgetTester tester) async {
      final GlobalKey key1 = GlobalKey();
      final GlobalKey key2 = GlobalKey();
      int startCount = 0;
      int completeCount = 0;
      bool finishCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'state_test_scope',
                onStart: (index, key) {
                  startCount++;
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
                  children: [
                    Showcase(
                      key: key1,
                      title: 'First Showcase',
                      description: 'First description',
                      child: const Text('Target 1'),
                    ),
                    Showcase(
                      key: key2,
                      title: 'Second Showcase',
                      description: 'Second description',
                      child: const Text('Target 2'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key1, key2]);
                      },
                      child: const Text('Start Showcase'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      final showcaseView = ShowcaseView.get();

      // Initially, showcase should not be running
      expect(showcaseView.isShowCaseCompleted, true);
      expect(showcaseView.isShowcaseRunning, false);
      expect(showcaseView.getActiveShowcaseKey, null);
      expect(startCount, 0);
      expect(completeCount, 0);
      expect(finishCalled, false);

      // Start showcase
      await tester.tap(find.text('Start Showcase'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // After starting, showcase should be running with first key
      expect(showcaseView.isShowcaseRunning, true);
      expect(showcaseView.getActiveShowcaseKey, key1);
      expect(showcaseView.isShowCaseCompleted, false);
      expect(startCount, 1);
      expect(completeCount, 0);

      // Move to next showcase
      showcaseView.next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Should be on second showcase now
      expect(showcaseView.isShowcaseRunning, true);
      expect(showcaseView.getActiveShowcaseKey, key2);
      expect(startCount, 2);
      expect(completeCount, 1);

      // Complete showcase
      showcaseView.next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // After completion, showcase should be completed
      expect(showcaseView.isShowCaseCompleted, true);
      expect(showcaseView.isShowcaseRunning, false);
      expect(showcaseView.getActiveShowcaseKey, null);
      expect(startCount, 2);
      expect(completeCount, 2);
      expect(finishCalled, true);
    });

    testWidgets('ShowcaseView with global tooltip actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'global_actions_test_scope',
                globalTooltipActions: [
                  const TooltipActionButton(
                    type: TooltipDefaultActionType.next,
                  ),
                  const TooltipActionButton(
                    type: TooltipDefaultActionType.skip,
                  ),
                ],
                globalTooltipActionConfig: const TooltipActionConfig(),
              );
              return Scaffold(body: Container());
            },
          ),
        ),
      );

      final showcaseView = ShowcaseView.get();
      expect(showcaseView.globalTooltipActions, isNotNull);
      expect(showcaseView.globalTooltipActions!.length, 2);
      expect(
        showcaseView.globalTooltipActions![0].type,
        TooltipDefaultActionType.next,
      );
      expect(
        showcaseView.globalTooltipActions![1].type,
        TooltipDefaultActionType.skip,
      );
      expect(showcaseView.globalTooltipActionConfig, isNotNull);
    });

    testWidgets('ShowcaseView with global floating action widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'global_floating_test_scope',
                globalFloatingActionWidget: (context) => FloatingActionWidget(
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.blue,
                    child: const Icon(Icons.star),
                  ),
                ),
              );
              return Scaffold(body: Container());
            },
          ),
        ),
      );

      final showcaseView = ShowcaseView.get();
      expect(showcaseView.globalFloatingActionWidget, isNotNull);

      // Verify the widget builder returns the correct type
      final widget = showcaseView
          .globalFloatingActionWidget!(tester.element(find.byType(Scaffold)));
      expect(widget, isA<FloatingActionWidget>());
    });

    testWidgets('ShowcaseView with dismiss callback and verification',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      GlobalKey? dismissedKey;
      bool dismissCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'dismiss_test_scope',
                onDismiss: (dismissedAt) {
                  dismissedKey = dismissedAt;
                  dismissCalled = true;
                },
              );

              return Scaffold(
                body: Column(
                  children: [
                    Showcase(
                      key: key,
                      title: 'Dismiss Test',
                      description: 'Testing dismiss callback',
                      child: const Text('Target'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key]);
                      },
                      child: const Text('Start'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Start showcase
      await tester.tap(find.text('Start'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify showcase is running
      expect(ShowcaseView.get().isShowcaseRunning, true);
      expect(dismissCalled, false);

      // Dismiss showcase
      ShowcaseView.get().dismiss();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify dismiss callback and state
      expect(dismissedKey, key);
      expect(dismissCalled, true);
      expect(ShowcaseView.get().isShowcaseRunning, false);
    });

    // Comprehensive auto-play test
    testWidgets('ShowcaseView with auto-play functionality and controls',
        (WidgetTester tester) async {
      final GlobalKey key1 = GlobalKey();
      final GlobalKey key2 = GlobalKey();
      int startCount = 0;
      int completeCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ShowcaseView.register(
                scope: 'autoplay_test_scope',
                autoPlay: true,
                autoPlayDelay: const Duration(milliseconds: 100),
                onStart: (index, key) {
                  startCount++;
                },
                onComplete: (index, key) {
                  completeCount++;
                },
              );

              return Scaffold(
                body: Column(
                  children: [
                    Showcase(
                      key: key1,
                      title: 'Auto-play 1',
                      description: 'First auto-play showcase',
                      child: const Text('Target 1'),
                    ),
                    Showcase(
                      key: key2,
                      title: 'Auto-play 2',
                      description: 'Second auto-play showcase',
                      child: const Text('Target 2'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key1, key2]);
                      },
                      child: const Text('Start Auto-play'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      final showcaseView = ShowcaseView.get();
      expect(showcaseView.autoPlay, true);
      expect(showcaseView.autoPlayDelay, const Duration(milliseconds: 100));

      // Start auto-play showcase
      await tester.tap(find.text('Start Auto-play'));
      await tester.pump();
      // await tester.pump(const Duration(milliseconds: 50));
      expect(startCount, 1);
      expect(showcaseView.getActiveShowcaseKey, key1);

      // Wait for auto-play timer to trigger progression
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait longer than autoPlayDelay

      expect(startCount, 2);
      expect(completeCount, 1);
      expect(showcaseView.getActiveShowcaseKey, key2);

      // Wait for final auto-play progression
      await tester.pump(
        const Duration(milliseconds: 150),
      ); // Wait longer than autoPlayDelay
      await tester.pumpAndSettle(); // Let all animations and timers complete

      expect(showcaseView.isShowCaseCompleted, true);
      expect(completeCount, 2);
    });

    // Test for multiple scopes with distinct configurations
    testWidgets('Multiple scopes maintain separate configurations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Register two scopes with different configurations
              ShowcaseView.register(
                scope: 'scope1',
                autoPlay: true,
                blurValue: 5.0,
              );
              ShowcaseView.register(
                scope: 'scope2',
                autoPlay: false,
                blurValue: 10.0,
              );
              return Scaffold(body: Container());
            },
          ),
        ),
      );

      final scope1 = ShowcaseView.getNamed('scope1');
      final scope2 = ShowcaseView.getNamed('scope2');

      // Verify scopes maintain different configurations
      expect(scope1.scope, 'scope1');
      expect(scope2.scope, 'scope2');
      expect(scope1.autoPlay, true);
      expect(scope2.autoPlay, false);
      expect(scope1.blurValue, 5.0);
      expect(scope2.blurValue, 10.0);

      // Changing one scope should not affect the other
      scope1.unregister();
      expect(() => ShowcaseView.getNamed('scope1'), throwsException);
      expect(ShowcaseView.getNamed('scope2').scope, 'scope2');
    });

    // Comprehensive edge case test
    testWidgets('Edge cases - Rapid transitions and nullability',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      ShowcaseView.register();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Showcase(
                  key: key,
                  title: 'Edge Case Test',
                  description: 'Testing edge cases',
                  child: Container(width: 100, height: 50, color: Colors.blue),
                ),
                ElevatedButton(
                  onPressed: () {
                    ShowcaseView.get().startShowCase([key]);
                  },
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
        ),
      );

      final showcaseView = ShowcaseView.get();

      // Test starting with empty key list
      showcaseView.startShowCase([]);
      await tester.pump();
      expect(showcaseView.isShowcaseRunning, false);

      // Test rapid start/stop/restart sequence
      showcaseView.startShowCase([key]);
      await tester.pump();
      showcaseView.dismiss();
      await tester.pump();
      showcaseView.startShowCase([key]);
      await tester.pump();
      expect(showcaseView.isShowcaseRunning, true);
      expect(showcaseView.getActiveShowcaseKey, key);

      // Test next/previous edge cases
      showcaseView.previous(); // Should do nothing at first showcase
      await tester.pump();
      expect(showcaseView.getActiveShowcaseKey, key);

      showcaseView.next(); // Should complete
      await tester.pump();
      expect(showcaseView.isShowCaseCompleted, true);

      showcaseView.next(); // Should do nothing when already completed
      await tester.pump();
      expect(showcaseView.isShowCaseCompleted, true);

      // Test with null dismiss callback
      showcaseView.startShowCase([key]);
      await tester.pump();
      showcaseView.dismiss();
      await tester.pump();
      expect(showcaseView.isShowcaseRunning, false);
    });
  });
}
