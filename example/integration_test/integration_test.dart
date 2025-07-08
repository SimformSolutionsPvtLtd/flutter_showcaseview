import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:showcaseview/showcaseview.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // group('ShowcaseView Integration Tests', () {
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
    await tester.pump(const Duration(milliseconds: 100));

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
    await tester.pump(const Duration(milliseconds: 100));

    // Verify second showcase started
    expect(startCount, 2);
    expect(lastStartedKey, key2);
    expect(completeCount, 1);
    expect(lastCompletedKey, key1);
    expect(ShowcaseView.get().getActiveShowcaseKey, key2);

    // Complete second showcase
    ShowcaseView.get().next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify third showcase started
    expect(startCount, 3);
    expect(lastStartedKey, key3);
    expect(completeCount, 2);
    expect(lastCompletedKey, key2);
    expect(ShowcaseView.get().getActiveShowcaseKey, key3);

    // Complete third showcase
    ShowcaseView.get().next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify all showcases completed
    expect(completeCount, 3);
    expect(lastCompletedKey, key3);
    expect(finishCalled, true);
    expect(ShowcaseView.get().isShowCaseCompleted, true);
  });

  testWidgets('Multi-showcase functionality with overlapping targets',
      (WidgetTester tester) async {
    final GlobalKey key1 = GlobalKey();
    final GlobalKey key2 = GlobalKey();
    final GlobalKey key3 = GlobalKey();

    int startCount = 0;
    int completeCount = 0;
    bool finishCalled = false;
    List<GlobalKey> showcaseOrder = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ShowcaseView.register(
              scope: 'overlap_test_scope',
              onStart: (index, key) {
                startCount++;
                showcaseOrder.add(key);
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
                  // Overlapping showcases to test the clipping fix
                  Positioned(
                    top: 100,
                    left: 50,
                    child: Showcase(
                      key: key1,
                      title: 'Overlapping Showcase 1',
                      description: 'This showcase overlaps with another',
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.red,
                        child: const Center(child: Text('Overlap 1')),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: 70,
                    child: Showcase(
                      key: key2,
                      title: 'Overlapping Showcase 2',
                      description: 'This showcase overlaps with the first',
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                        child: const Center(child: Text('Overlap 2')),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 300,
                    left: 50,
                    child: Showcase(
                      key: key3,
                      title: 'Non-overlapping Showcase',
                      description: 'This showcase does not overlap',
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.green,
                        child: const Center(child: Text('No Overlap')),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 50,
                    right: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key1, key2, key3]);
                      },
                      child: const Text('Start Overlapping Showcases'),
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

    // Verify all targets are rendered
    expect(find.text('Overlap 1'), findsOneWidget);
    expect(find.text('Overlap 2'), findsOneWidget);
    expect(find.text('No Overlap'), findsOneWidget);

    // Start the showcase sequence
    await tester.tap(find.text('Start Overlapping Showcases'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify first showcase started
    expect(startCount, 1);
    expect(showcaseOrder.first, key1);
    expect(ShowcaseView.get().isShowcaseRunning, true);

    // Complete all showcases in sequence
    for (int i = 0; i < 3; i++) {
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify all showcases completed
    expect(completeCount, 3);
    expect(finishCalled, true);
    expect(ShowcaseView.get().isShowCaseCompleted, true);
    expect(showcaseOrder.length, 3);
    expect(showcaseOrder, [key1, key2, key3]);
  });

  testWidgets('Multi-showcase with different types and shapes',
      (WidgetTester tester) async {
    final GlobalKey key1 = GlobalKey();
    final GlobalKey key2 = GlobalKey();
    final GlobalKey key3 = GlobalKey();

    int startCount = 0;
    int completeCount = 0;
    bool finishCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ShowcaseView.register(
              scope: 'shapes_test_scope',
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Circular showcase
                  Showcase(
                    key: key1,
                    title: 'Circular Showcase',
                    description: 'This is a circular showcase',
                    targetShapeBorder: const CircleBorder(),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      child: const Center(child: Text('Circle')),
                    ),
                  ),
                  // Rectangular showcase
                  Showcase(
                    key: key2,
                    title: 'Rectangular Showcase',
                    description: 'This is a rectangular showcase',
                    targetShapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Container(
                      width: 120,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.purple,
                      ),
                      child: const Center(child: Text('Rectangle')),
                    ),
                  ),
                  // Custom shape showcase
                  Showcase(
                    key: key3,
                    title: 'Custom Shape Showcase',
                    description: 'This is a custom shape showcase',
                    targetShapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: Colors.teal,
                      ),
                      child: const Center(child: Text('Custom')),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ShowcaseView.get().startShowCase([key1, key2, key3]);
                    },
                    child: const Text('Start Shape Showcases'),
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
    expect(find.text('Circle'), findsOneWidget);
    expect(find.text('Rectangle'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);

    // Start the showcase sequence
    await tester.tap(find.text('Start Shape Showcases'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify first showcase started
    expect(startCount, 1);
    expect(ShowcaseView.get().isShowcaseRunning, true);

    // Complete all showcases
    for (int i = 0; i < 3; i++) {
      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify all showcases completed
    expect(completeCount, 3);
    expect(finishCalled, true);
    expect(ShowcaseView.get().isShowCaseCompleted, true);
  });

  testWidgets('Showcase navigation and state management',
      (WidgetTester tester) async {
    final GlobalKey key1 = GlobalKey();
    final GlobalKey key2 = GlobalKey();

    int startCount = 0;
    int completeCount = 0;
    bool finishCalled = false;

    late ShowcaseView showcaseView;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            showcaseView = ShowcaseView.register(
              scope: 'navigation_test_scope',
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Showcase(
                    key: key1,
                    title: 'Navigation Test 1',
                    description: 'Test navigation controls',
                    child: const Text('Nav Target 1'),
                  ),
                  Showcase(
                    key: key2,
                    title: 'Navigation Test 2',
                    description: 'Test back and forth',
                    child: const Text('Nav Target 2'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showcaseView.startShowCase([key1, key2]);
                    },
                    child: const Text('Start Navigation Test'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.pump();

    // Start the showcase
    await tester.tap(find.text('Start Navigation Test'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify first showcase started
    expect(startCount, 1);
    expect(ShowcaseView.get().getActiveShowcaseKey, key1);

    // Navigate to next programmatically
    showcaseView.next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify second showcase started
    expect(startCount, 2);
    expect(ShowcaseView.get().getActiveShowcaseKey, key2);
    expect(completeCount, 1);

    // Navigate back to previous programmatically
    showcaseView.previous();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Should be back to first showcase
    expect(ShowcaseView.get().getActiveShowcaseKey, key1);

    // Complete all showcases programmatically
    showcaseView.next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    showcaseView.next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify showcase completed
    expect(ShowcaseView.get().isShowCaseCompleted, true);
    expect(finishCalled, true);
  });

  testWidgets('Showcase completion verification', (WidgetTester tester) async {
    final GlobalKey key1 = GlobalKey();

    bool showcaseStarted = false;
    bool showcaseCompleted = false;
    bool showcaseFinished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ShowcaseView.register(
              scope: 'completion_test_scope',
              onStart: (index, key) {
                showcaseStarted = true;
              },
              onComplete: (index, key) {
                showcaseCompleted = true;
              },
              onFinish: () {
                showcaseFinished = true;
              },
            );

            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Showcase(
                      key: key1,
                      title: 'Completion Test',
                      description: 'Testing showcase completion',
                      child: Container(
                        width: 100,
                        height: 50,
                        color: Colors.blue,
                        child: const Center(child: Text('Test Widget')),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        ShowcaseView.get().startShowCase([key1]);
                      },
                      child: const Text('Start Completion Test'),
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

    // Verify initial state
    expect(showcaseStarted, false);
    expect(showcaseCompleted, false);
    expect(showcaseFinished, false);
    expect(ShowcaseView.get().isShowCaseCompleted, true);
    expect(ShowcaseView.get().isShowcaseRunning, false);

    // Start showcase
    await tester.tap(find.text('Start Completion Test'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify showcase started
    expect(showcaseStarted, true);
    expect(ShowcaseView.get().isShowcaseRunning, true);
    expect(ShowcaseView.get().isShowCaseCompleted, false);
    expect(ShowcaseView.get().getActiveShowcaseKey, key1);

    // Complete the showcase
    ShowcaseView.get().next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify showcase completed
    expect(showcaseCompleted, true);
    expect(showcaseFinished, true);
    expect(ShowcaseView.get().isShowCaseCompleted, true);
    expect(ShowcaseView.get().isShowcaseRunning, false);
    expect(ShowcaseView.get().getActiveShowcaseKey, null);
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
                        color: Colors.red.withOpacity(0.7),
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
                      description: 'This showcase overlaps with the first one',
                      child: Container(
                        width: 120,
                        height: 80,
                        color: Colors.blue.withOpacity(0.7),
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
                          'Start Simultaneous Overlapping Showcases'),
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
        find.text('Start Simultaneous Overlapping Showcases'), findsOneWidget);

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

    // Complete the simultaneous showcases
    ShowcaseView.get().next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

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
    await tester.pump(const Duration(milliseconds: 100));

    // First showcase should be the simultaneous one
    expect(startCount, 1);
    expect(showcaseSequence.first, simultaneousKey);
    expect(ShowcaseView.get().getActiveShowcaseKey, simultaneousKey);

    // Complete simultaneous showcase
    ShowcaseView.get().next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Second showcase should be individual key 1
    expect(startCount, 2);
    expect(showcaseSequence[1], individualKey1);
    expect(ShowcaseView.get().getActiveShowcaseKey, individualKey1);
    expect(completeCount, 1);

    // Complete individual showcase 1
    ShowcaseView.get().next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Third showcase should be individual key 2
    expect(startCount, 3);
    expect(showcaseSequence[2], individualKey2);
    expect(ShowcaseView.get().getActiveShowcaseKey, individualKey2);
    expect(completeCount, 2);

    // Complete individual showcase 2
    ShowcaseView.get().next();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // All showcases should be completed
    expect(completeCount, 3);
    expect(finishCalled, true);
    expect(ShowcaseView.get().isShowCaseCompleted, true);
    expect(ShowcaseView.get().isShowcaseRunning, false);
    expect(ShowcaseView.get().getActiveShowcaseKey, null);
  });
  // });
}
