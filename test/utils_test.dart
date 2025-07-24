import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:showcaseview/src/utils/constants.dart';
import 'package:showcaseview/src/widget/showcase_circular_progress_indicator.dart';

void main() {
  group('Constants Tests', () {
    test('Constants have correct default values', () {
      expect(Constants.defaultScope, '_showcaseDefaultScope');
      expect(
        Constants.defaultAutoPlayDelay,
        const Duration(milliseconds: 2000),
      );
      expect(
        Constants.defaultAnimationDuration,
        const Duration(milliseconds: 2000),
      );
      expect(
        Constants.defaultScrollDuration,
        const Duration(milliseconds: 300),
      );
      expect(
        Constants.defaultProgressIndicator,
        isA<ShowcaseCircularProgressIndicator>(),
      );
      expect(Constants.defaultTargetShapeBorder, isA<RoundedRectangleBorder>());
    });

    test(
        'Constants progress indicator is instance of ShowcaseCircularProgressIndicator',
        () {
      const progressIndicator = Constants.defaultProgressIndicator;
      expect(progressIndicator, isA<ShowcaseCircularProgressIndicator>());
    });

    test('Constants target shape border is instance of RoundedRectangleBorder',
        () {
      const targetShapeBorder = Constants.defaultTargetShapeBorder;
      expect(targetShapeBorder, isA<RoundedRectangleBorder>());
    });
  });

  group('Enum Tests', () {
    test('TooltipPosition enum values', () {
      expect(TooltipPosition.values.length, 4);
      expect(TooltipPosition.values.contains(TooltipPosition.top), true);
      expect(TooltipPosition.values.contains(TooltipPosition.bottom), true);
      expect(TooltipPosition.values.contains(TooltipPosition.left), true);
      expect(TooltipPosition.values.contains(TooltipPosition.right), true);
    });

    test('TooltipPosition enum string values', () {
      expect(TooltipPosition.top.toString(), 'TooltipPosition.top');
      expect(TooltipPosition.bottom.toString(), 'TooltipPosition.bottom');
      expect(TooltipPosition.left.toString(), 'TooltipPosition.left');
      expect(TooltipPosition.right.toString(), 'TooltipPosition.right');
    });

    test('TooltipPosition enum equality', () {
      expect(TooltipPosition.top == TooltipPosition.top, true);
      expect(TooltipPosition.top == TooltipPosition.bottom, false);
      expect(TooltipPosition.bottom == TooltipPosition.left, false);
    });
  });

  group('Model Tests', () {
    test('TooltipActionButton creation', () {
      int clickCount = 0;
      final actionButton = TooltipActionButton(
        type: TooltipDefaultActionType.next,
        name: 'Test Action',
        onTap: () => clickCount++,
      );

      expect(actionButton.name, 'Test Action');
      expect(actionButton.onTap, isNotNull);

      // Test callback execution
      actionButton.onTap!();
      expect(clickCount, 1);
    });

    test('TooltipActionConfig creation', () {
      const config = TooltipActionConfig(
        alignment: MainAxisAlignment.center,
        actionGap: 10.0,
      );

      expect(config.alignment, MainAxisAlignment.center);
      expect(config.actionGap, 10.0);
    });

    test('TooltipActionConfig with default values', () {
      const config = TooltipActionConfig();

      expect(config.alignment, MainAxisAlignment.spaceBetween);
      expect(config.actionGap, 5.0);
    });

    test('TooltipDefaultActionType enum values', () {
      expect(TooltipDefaultActionType.values.length, 3);
      expect(
        TooltipDefaultActionType.values.contains(TooltipDefaultActionType.next),
        true,
      );
      expect(
        TooltipDefaultActionType.values
            .contains(TooltipDefaultActionType.previous),
        true,
      );
      expect(
        TooltipDefaultActionType.values.contains(TooltipDefaultActionType.skip),
        true,
      );
    });
  });

  group('Model Edge Cases', () {
    test('TooltipActionButton with null onTap', () {
      const actionButton = TooltipActionButton(
        type: TooltipDefaultActionType.next,
        name: 'No Callback',
        onTap: null,
      );
      expect(actionButton.onTap, isNull);
    });
    test('TooltipActionConfig with unusual values', () {
      const config = TooltipActionConfig(
        alignment: MainAxisAlignment.end,
        actionGap: -10.0,
      );
      expect(config.actionGap, -10.0);
    });
  });

  group('Widget Tests', () {
    testWidgets('FloatingActionWidget renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingActionWidget(
                  top: 0,
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.blue,
                    child: const Icon(Icons.star),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionWidget), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('FloatingActionWidget renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingActionWidget(
                  bottom: 0,
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.blue,
                    child: const Icon(Icons.star),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionWidget), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('Widget Edge Cases', () {
    testWidgets('FloatingActionWidget with both top and bottom set',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingActionWidget(
                  top: 0,
                  bottom: 0,
                  child: Container(width: 50, height: 50, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(FloatingActionWidget), findsOneWidget);
    });
    testWidgets('FloatingActionWidget with neither top nor bottom set',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingActionWidget(
                  child: Container(width: 50, height: 50, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(FloatingActionWidget), findsOneWidget);
    });
  });

  group('Integration Tests for Utils', () {
    setUp(
      () {
        ShowcaseView.register();
      },
    );
    tearDown(
      () {
        ShowcaseView.get().unregister();
      },
    );
    testWidgets('Constants integration with Showcase',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Constants Test',
              description: 'Testing constants integration',
              scrollLoadingWidget: Constants.defaultProgressIndicator,
              targetShapeBorder: Constants.defaultTargetShapeBorder,
              child: Container(
                width: 100,
                height: 50,
                color: Colors.red,
                child: const Text('Target Widget'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Target Widget'), findsOneWidget);
    });

    testWidgets('Enum integration with Showcase', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Enum Test',
              description: 'Testing enum integration',
              tooltipPosition: TooltipPosition.top,
              child: Container(
                width: 100,
                height: 50,
                color: Colors.red,
                child: const Text('Target Widget'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Target Widget'), findsOneWidget);
    });

    testWidgets('Action buttons integration', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      int actionClickCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Action Test',
              description: 'Testing action buttons',
              tooltipActions: [
                TooltipActionButton(
                  type: TooltipDefaultActionType.next,
                  name: 'Test Action',
                  onTap: () => actionClickCount++,
                ),
              ],
              tooltipActionConfig: const TooltipActionConfig(
                alignment: MainAxisAlignment.center,
                actionGap: 10,
              ),
              child: Container(
                width: 100,
                height: 50,
                color: Colors.red,
                child: const Text('Target Widget'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Target Widget'), findsOneWidget);
    });

    testWidgets('Floating action widget integration',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Floating Test',
              description: 'Testing floating action widget',
              floatingActionWidget: FloatingActionWidget(
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.orange,
                  child: const Text('Floating Action'),
                ),
              ),
              child: Container(
                width: 100,
                height: 50,
                color: Colors.red,
                child: const Text('Target Widget'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Target Widget'), findsOneWidget);
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Floating Action'), findsOneWidget);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Invalid overlay opacity throws assertion error',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      // Test with invalid overlay opacity
      expect(
        () => Showcase(
          key: key,
          title: 'Invalid Opacity',
          description: 'Testing invalid opacity',
          overlayOpacity: 1.5,
          // Invalid value > 1.0
          child: Container(
            width: 100,
            height: 50,
            color: Colors.red,
            child: const Text('Target Widget'),
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('Invalid targetTooltipGap throws assertion error',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      // Test with invalid targetTooltipGap
      expect(
        () => Showcase(
          key: key,
          title: 'Invalid Gap',
          description: 'Testing invalid gap',
          targetTooltipGap: -5,
          // Invalid negative value
          child: Container(
            width: 100,
            height: 50,
            color: Colors.red,
            child: const Text('Target Widget'),
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets(
        'Invalid disposeOnTap and onTargetClick combination throws assertion error',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      // Test with disposeOnTap but no onTargetClick
      expect(
        () => Showcase(
          key: key,
          title: 'Invalid Combination',
          description: 'Testing invalid combination',
          disposeOnTap: true,
          // Missing onTargetClick
          child: Container(
            width: 100,
            height: 50,
            color: Colors.red,
            child: const Text('Target Widget'),
          ),
        ),
        throwsAssertionError,
      );

      // Test with onTargetClick but no disposeOnTap
      expect(
        () => Showcase(
          key: key,
          title: 'Invalid Combination 2',
          description: 'Testing invalid combination 2',
          onTargetClick: () {},
          // Missing disposeOnTap
          child: Container(
            width: 100,
            height: 50,
            color: Colors.red,
            child: const Text('Target Widget'),
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets(
        'Invalid onBarrierClick and disableBarrierInteraction combination throws assertion error',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      // Test with onBarrierClick and disableBarrierInteraction
      expect(
        () => Showcase(
          key: key,
          title: 'Invalid Barrier Combination',
          description: 'Testing invalid barrier combination',
          onBarrierClick: () {},
          disableBarrierInteraction: true,
          child: Container(
            width: 100,
            height: 50,
            color: Colors.red,
            child: const Text('Target Widget'),
          ),
        ),
        throwsAssertionError,
      );
    });
  });
}
