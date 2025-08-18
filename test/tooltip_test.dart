import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:showcaseview/src/tooltip/tooltip.dart';

Offset getWidgetCenter(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  return rect.center;
}

/// Utility function to dump position information for debugging tooltip positioning
void dumpPositionInfo(
  WidgetTester tester,
  Finder targetFinder,
  Finder tooltipFinder,
) {
  final targetRect = tester.getRect(targetFinder);
  final tooltipRect = tester.getRect(tooltipFinder);

  debugPrint('Target rect: $targetRect');
  debugPrint('Tooltip rect: $tooltipRect');

  final targetCenter = targetRect.center;
  final tooltipCenter = tooltipRect.center;

  debugPrint('Target center: $targetCenter');
  debugPrint('Tooltip center: $tooltipCenter');

  // Calculate relative positions
  final horizontalPosition = tooltipCenter.dx < targetCenter.dx
      ? "LEFT of"
      : tooltipCenter.dx > targetCenter.dx
          ? "RIGHT of"
          : "HORIZONTALLY CENTERED with";

  final verticalPosition = tooltipCenter.dy < targetCenter.dy
      ? "ABOVE"
      : tooltipCenter.dy > targetCenter.dy
          ? "BELOW"
          : "VERTICALLY CENTERED with";

  debugPrint('Tooltip is $horizontalPosition target');
  debugPrint('Tooltip is $verticalPosition target');

  // Print horizontal and vertical distances
  final horizontalDistance = (tooltipCenter.dx - targetCenter.dx).abs();
  final verticalDistance = (tooltipCenter.dy - targetCenter.dy).abs();
  debugPrint('Horizontal distance: $horizontalDistance');
  debugPrint('Vertical distance: $verticalDistance');
}

/// Waits for the tooltip to appear and returns its position relative to the target
///
/// Sets the tooltip bounds using precise layout constraints to ensure it appears
/// in the desired position.
Future<void> waitForTooltipToAppear(
  WidgetTester tester, {
  required Finder targetFinder,
  required Finder tooltipFinder,
  required TooltipPosition position,
}) async {
  // Wait for tooltip to appear
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));

  // Verify tooltip is present
  expect(tooltipFinder, findsOneWidget, reason: 'Tooltip should be found');

  // Get current positions
  final targetRect = tester.getRect(targetFinder);
  final tooltipRect = tester.getRect(tooltipFinder);
  final targetCenter = targetRect.center;
  final tooltipCenter = tooltipRect.center;

  // Verify positioning
  switch (position) {
    case TooltipPosition.top:
      expect(
        tooltipCenter.dy < targetCenter.dy,
        true,
        reason: 'Tooltip should be above the target',
      );
      break;
    case TooltipPosition.bottom:
      expect(
        tooltipCenter.dy > targetCenter.dy,
        true,
        reason: 'Tooltip should be below the target',
      );
      break;
    case TooltipPosition.left:
      expect(
        tooltipCenter.dx < targetCenter.dx,
        true,
        reason: 'Tooltip should be to the left of the target',
      );
      break;
    case TooltipPosition.right:
      expect(
        tooltipCenter.dx > targetCenter.dx,
        true,
        reason: 'Tooltip should be to the right of the target',
      );
      break;
  }
}

void main() {
  group('Tooltip Tests', () {
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
    testWidgets('ToolTipWidget renders with title and description',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Showcase(
                key: key,
                title: 'Test Title',
                description: 'Test Description',
                disableMovingAnimation: true,
                // Disable animation for test stability
                child: Container(
                  width: 100,
                  height: 50,
                  color: Colors.red,
                  child: const Text('Target Widget'),
                ),
              ),
            ),
          ),
        ),
      );

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify tooltip and content
      expect(find.byType(ToolTipWidget), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);

      // Verify tooltip is visible
      final tooltipFinder = find.byType(ToolTipWidget);
      expect(tooltipFinder, findsOneWidget);

      // Verify target widget is still visible
      final targetFinder = find.text('Target Widget');
      expect(targetFinder, findsOneWidget);

      // Debug positioning
      dumpPositionInfo(tester, targetFinder, tooltipFinder);

      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget shows title and description with correct styles',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Styled Title',
              description: 'Styled Description',
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
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      // Check title and description text and style
      final titleFinder = find.text('Styled Title');
      final descFinder = find.text('Styled Description');
      expect(titleFinder, findsOneWidget);
      expect(descFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      final descWidget = tester.widget<Text>(descFinder);
      expect(titleWidget.style?.fontSize, 24);
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
      expect(titleWidget.style?.color, Colors.deepPurple);
      expect(descWidget.style?.fontSize, 16);
      expect(descWidget.style?.fontStyle, FontStyle.italic);
      expect(descWidget.style?.color, Colors.deepOrange);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget custom styling is applied',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Custom Style',
              description: 'Custom Style Desc',
              tooltipBackgroundColor: Colors.lightBlue,
              tooltipBorderRadius: BorderRadius.circular(20),
              tooltipPadding: const EdgeInsets.all(20),
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
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      // Find the tooltip container and check decoration
      final tooltipContainer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ToolTipWidget),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = tooltipContainer.decoration as BoxDecoration?;
      expect(decoration?.color, Colors.lightBlue);
      expect(decoration?.borderRadius, BorderRadius.circular(20));
      expect(tooltipContainer.padding, const EdgeInsets.all(20));
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget shows arrow when showArrow is true',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Arrow Test',
              description: 'Arrow should be visible',
              showArrow: true,
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
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      // Check for CustomPaint (arrow)
      expect(
        find.byType(ShowcaseArrow),
        findsWidgets,
      );
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget does not show arrow when showArrow is false',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'No Arrow Test',
              description: 'Arrow should not be visible',
              showArrow: false,
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
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      // There should be no CustomPaint for arrow
      expect(
        find.descendant(
          of: find.byType(ToolTipWidget),
          matching: find.byType(ShowcaseArrow),
        ),
        findsNothing,
      );
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget without arrow', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'No Arrow Title',
              description: 'No Arrow Description',
              showArrow: false,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with custom container',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase.withWidget(
              key: key,
              height: 100,
              width: 200,
              container: Container(
                color: Colors.blue,
                child: const Text('Custom Tooltip'),
              ),
              child: Container(
                width: 100,
                height: 50,
                color: Colors.green,
                child: const Text('Target Widget'),
              ),
            ),
          ),
        ),
      );

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify custom tooltip container is rendered
      expect(find.byType(ToolTipWidget), findsOneWidget);
      expect(find.text('Custom Tooltip'), findsOneWidget);

      // Verify the container has blue background
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ToolTipWidget),
          matching: find.byType(Container),
        ),
      );
      expect(container.color, Colors.blue);

      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with text alignment',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Aligned Title',
              description: 'Aligned Description',
              titleTextAlign: TextAlign.center,
              descriptionTextAlign: TextAlign.justify,
              titleAlignment: Alignment.centerLeft,
              descriptionAlignment: Alignment.centerRight,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with text direction',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Direction Title',
              description: 'Direction Description',
              titleTextDirection: TextDirection.ltr,
              descriptionTextDirection: TextDirection.rtl,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with padding', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Padded Title',
              description: 'Padded Description',
              titlePadding: const EdgeInsets.all(10),
              descriptionPadding: const EdgeInsets.all(15),
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with tooltip click callback',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      int tooltipClickCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Clickable Title',
              description: 'Clickable Description',
              onToolTipClick: () => tooltipClickCount++,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget click callback is triggered',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      int clickCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Click Test',
              description: 'Testing click callback',
              onToolTipClick: () {
                clickCount++;
              },
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find and tap the tooltip
      final tooltipFinder = find.byType(ToolTipWidget);
      expect(tooltipFinder, findsOneWidget);

      // Tap the tooltip (but not on any buttons)
      await tester.tap(find.text('Click Test'));
      await tester.pump();

      expect(clickCount, 1, reason: 'Tooltip click callback was not triggered');
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with animation properties',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Animated Title',
              description: 'Animated Description',
              disableMovingAnimation: true,
              movingAnimationDuration: const Duration(milliseconds: 1000),
              disableScaleAnimation: false,
              scaleAnimationDuration: const Duration(milliseconds: 500),
              scaleAnimationCurve: Curves.bounceOut,
              scaleAnimationAlignment: Alignment.topLeft,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with positioning properties',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Positioned Title',
              description: 'Positioned Description',
              tooltipPosition: TooltipPosition.top,
              toolTipMargin: 20,
              targetTooltipGap: 15,
              toolTipSlideEndDistance: 10,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with action buttons',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Action Title',
              description: 'Action Description',
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with action buttons properly rendered',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      int nextPressed = 0;
      int skipPressed = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Action Buttons Test',
              description: 'Testing action buttons rendering and functionality',
              tooltipActions: [
                TooltipActionButton(
                  type: TooltipDefaultActionType.next,
                  name: 'Next',
                  onTap: () => nextPressed++,
                ),
                TooltipActionButton(
                  type: TooltipDefaultActionType.skip,
                  name: 'Skip',
                  onTap: () => skipPressed++,
                ),
              ],
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify action buttons are rendered
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Test tapping next button
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(nextPressed, 1);

      // Restart showcase to test skip button
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Test tapping skip button
      await tester.tap(find.text('Skip'));
      await tester.pump();
      expect(skipPressed, 1);
    });

    testWidgets('ToolTipWidget with target padding',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Padded Target Title',
              description: 'Padded Target Description',
              targetPadding: const EdgeInsets.all(10),
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with disabled moving animation',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'No Moving Title',
              description: 'No Moving Description',
              disableMovingAnimation: true,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with disabled scale animation',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'No Scale Title',
              description: 'No Scale Description',
              disableScaleAnimation: true,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with custom scale animation alignment',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Custom Scale Title',
              description: 'Custom Scale Description',
              scaleAnimationAlignment: Alignment.bottomRight,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with different tooltip positions',
        (WidgetTester tester) async {
      final GlobalKey key1 = GlobalKey();
      final GlobalKey key2 = GlobalKey();
      final GlobalKey key3 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Showcase(
                  key: key1,
                  title: 'Top Position',
                  description: 'Top Position Description',
                  tooltipPosition: TooltipPosition.top,
                  child: Container(
                    width: 100,
                    height: 50,
                    color: Colors.red,
                    child: const Text('Top Target'),
                  ),
                ),
                Showcase(
                  key: key2,
                  title: 'Bottom Position',
                  description: 'Bottom Position Description',
                  tooltipPosition: TooltipPosition.bottom,
                  child: Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                    child: const Text('Bottom Target'),
                  ),
                ),
                Showcase(
                  key: key3,
                  title: 'Auto Position',
                  description: 'Auto Position Description',
                  child: Container(
                    width: 100,
                    height: 50,
                    color: Colors.green,
                    child: const Text('Auto Target'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Test each position
      ShowcaseView.get().startShowCase([key1, key2, key3]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsOneWidget);

      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(ToolTipWidget), findsOneWidget);

      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets(
        'Tooltip is positioned above the target when tooltipPosition is top',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const SizedBox(height: 400),
                Showcase(
                  key: key,
                  title: 'Top Tooltip',
                  description: 'Tooltip should be above',
                  tooltipPosition: TooltipPosition.top,
                  child: Container(
                    width: 100,
                    height: 50,
                    color: Colors.red,
                    child: const Text('Target Widget'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);
      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);
      expect(
        tooltipCenter.dy < targetCenter.dy,
        true,
        reason: 'Tooltip should be above the target',
      );
      ShowcaseView.get().next();
    });

    testWidgets('Tooltip position bottom', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800, // Fixed size to ensure consistent layout
              height: 800,
              child: Stack(
                children: [
                  Positioned(
                    left: 400, // Center horizontally
                    top: 100, // Position near top to ensure space below
                    child: Showcase(
                      key: key,
                      title: 'Bottom Test',
                      description: 'Bottom position',
                      tooltipPosition: TooltipPosition.bottom,
                      targetShapeBorder: const CircleBorder(),
                      targetPadding: EdgeInsets.zero,
                      disableMovingAnimation: true,
                      // Disable animation for test stability
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.red,
                        child: const Text('Target Widget'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);

      // Dump debug info
      dumpPositionInfo(tester, targetFinder, tooltipFinder);

      // Verify position
      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);

      expect(
        tooltipCenter.dy > targetCenter.dy,
        true,
        reason: 'Tooltip should be below the target',
      );

      ShowcaseView.get().next();
    });

    testWidgets('Tooltip auto-positions to available space when space is low',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 800,
              child: Stack(
                children: [
                  // Place target at the top to force tooltip to appear below
                  Positioned(
                    left: 400,
                    top: 10, // Very close to top edge
                    child: Showcase(
                      key: key,
                      title: 'Auto Tooltip',
                      description:
                          'Tooltip should auto-position below when at top edge',
                      // No explicit tooltipPosition - should auto-position
                      disableMovingAnimation: true,
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.red,
                        child: const Text('Target Widget'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);

      expect(tooltipFinder, findsOneWidget, reason: 'Tooltip should be found');

      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);

      // Debug output
      dumpPositionInfo(tester, targetFinder, tooltipFinder);

      // Since the target is at the top, tooltip should be below
      expect(
        tooltipCenter.dy > targetCenter.dy,
        true,
        reason: 'Tooltip should auto-position below if no space above',
      );

      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with different text colors',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Colored Title',
              description: 'Colored Description',
              textColor: Colors.white,
              tooltipBackgroundColor: Colors.black,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with custom border radius',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Rounded Title',
              description: 'Rounded Description',
              tooltipBorderRadius: BorderRadius.circular(20),
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with custom padding',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Padded Title',
              description: 'Padded Description',
              tooltipPadding: const EdgeInsets.all(20),
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with null title', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              description: 'Description Only',
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with null description',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Title Only',
              description: null,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with both null title and description',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase.withWidget(
              key: key,
              height: 100,
              width: 200,
              container: Container(
                color: Colors.blue,
                child: const Text('Custom Container'),
              ),
              child: Container(
                width: 100,
                height: 50,
                color: Colors.green,
                child: const Text('Target Widget'),
              ),
            ),
          ),
        ),
      );

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      expect(find.text('Custom Container'), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with custom animation curves',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Curved Title',
              description: 'Curved Description',
              scaleAnimationCurve: Curves.elasticOut,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('ToolTipWidget with custom animation durations',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Duration Title',
              description: 'Duration Description',
              movingAnimationDuration: const Duration(milliseconds: 2000),
              scaleAnimationDuration: const Duration(milliseconds: 1000),
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ToolTipWidget), findsOneWidget);
      ShowcaseView.get().next();
    });

    testWidgets('Tooltip position left', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800, // Fixed size to ensure consistent layout
              height: 800,
              child: Stack(
                children: [
                  Positioned(
                    right: 100, // Position near right to ensure space on left
                    top: 400, // Center vertically
                    child: Showcase(
                      key: key,
                      title: 'Left Test',
                      description: 'Left position',
                      tooltipPosition: TooltipPosition.left,
                      targetShapeBorder: const CircleBorder(),
                      targetPadding: EdgeInsets.zero,
                      disableMovingAnimation: true,
                      // Disable animation for test stability
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.red,
                        child: const Text('Target Widget'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);

      // Dump debug info
      dumpPositionInfo(tester, targetFinder, tooltipFinder);

      // Verify position
      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);

      expect(
        tooltipCenter.dx < targetCenter.dx,
        true,
        reason: 'Tooltip should be to the left of the target',
      );

      ShowcaseView.get().next();
    });

    testWidgets('Tooltip position right', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800, // Fixed size to ensure consistent layout
              height: 800,
              child: Stack(
                children: [
                  Positioned(
                    left: 100, // Position near left to ensure space on right
                    top: 400, // Center vertically
                    child: Showcase(
                      key: key,
                      title: 'Right Test',
                      description: 'Right position',
                      tooltipPosition: TooltipPosition.right,
                      targetShapeBorder: const CircleBorder(),
                      targetPadding: EdgeInsets.zero,
                      disableMovingAnimation: true,
                      // Disable animation for test stability
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.red,
                        child: const Text('Target Widget'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);

      // Dump debug info
      dumpPositionInfo(tester, targetFinder, tooltipFinder);

      // Verify position
      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);

      expect(
        tooltipCenter.dx > targetCenter.dx,
        true,
        reason: 'Tooltip should be to the right of the target',
      );

      ShowcaseView.get().next();
    });

    testWidgets('Tooltip position top', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      // Position the target near the bottom to ensure there's plenty of room above
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800, // Fixed size to ensure consistent layout
              height: 800,
              child: Stack(
                children: [
                  Positioned(
                    left: 400, // Center horizontally
                    bottom: 100, // Position near bottom to ensure space above
                    child: Showcase(
                      key: key,
                      title: 'Top Test',
                      description: 'Top position',
                      tooltipPosition: TooltipPosition.top,
                      targetShapeBorder: const CircleBorder(),
                      targetPadding: EdgeInsets.zero,
                      disableMovingAnimation: true,
                      // Disable animation for test stability
                      tooltipBackgroundColor: Colors.purple,
                      child: Container(
                        width: 50,
                        height: 50,
                        color: Colors.red,
                        child: const Text('Target Widget'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);

      expect(tooltipFinder, findsOneWidget, reason: 'Tooltip should be found');

      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);

      // Debug information
      debugPrint('Target center: $targetCenter');
      debugPrint('Tooltip center: $tooltipCenter');

      expect(
        tooltipCenter.dy < targetCenter.dy,
        true,
        reason: 'Tooltip should be above the target',
      );
      ShowcaseView.get().next();
    });

    testWidgets('Tooltip bottom overflow', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      // Constrain the layout so only one direction is available at a time
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  // Place the target in the center
                  Positioned(
                    left: 100,
                    top: 100,
                    child: Showcase(
                      key: key,
                      title: 'Center Tooltip',
                      description: 'Tooltip should auto-position',
                      child: Container(
                        width: 20,
                        height: 20,
                        color: Colors.red,
                        child: const Text('Target Widget'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      // 1. Only bottom available
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      var targetFinder = find.text('Target Widget');
      var tooltipFinder = find.byType(ToolTipWidget);
      var targetCenter = getWidgetCenter(tester, targetFinder);
      var tooltipCenter = getWidgetCenter(tester, tooltipFinder);
      expect(
        tooltipCenter.dy > targetCenter.dy,
        true,
        reason: 'Tooltip should be below the target (bottom)',
      );
      ShowcaseView.get().next();

      // 2. Move target to bottom, only top available
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 100,
                  bottom: 0,
                  child: Showcase(
                    key: key,
                    title: 'Fallback Tooltip',
                    description: 'Tooltip should fallback',
                    child: Container(
                      width: 20,
                      height: 20,
                      color: Colors.red,
                      child: const Text('Target Widget'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      targetFinder = find.text('Target Widget');
      tooltipFinder = find.byType(ToolTipWidget);
      targetCenter = getWidgetCenter(tester, targetFinder);
      tooltipCenter = getWidgetCenter(tester, tooltipFinder);
      expect(
        tooltipCenter.dy < targetCenter.dy,
        true,
        reason: 'Tooltip should be above the target (top)',
      );
      ShowcaseView.get().next();

      // 3. Move target to right, only left available
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 100,
                  child: Showcase(
                    key: key,
                    title: 'Fallback Tooltip',
                    description: 'Tooltip should fallback',
                    child: Container(
                      width: 20,
                      height: 20,
                      color: Colors.red,
                      child: const Text('Target Widget'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      targetFinder = find.text('Target Widget');
      tooltipFinder = find.byType(ToolTipWidget);
      targetCenter = getWidgetCenter(tester, targetFinder);
      tooltipCenter = getWidgetCenter(tester, tooltipFinder);
      expect(
        tooltipCenter.dx < targetCenter.dx,
        true,
        reason: 'Tooltip should be left of the target (left)',
      );
      ShowcaseView.get().next();

      // 4. Move target to left, only right available
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 100,
                    child: Showcase(
                      key: key,
                      title: 'Left Tooltip',
                      description: 'Tooltip should auto-position to right',
                      child: Container(
                        width: 20,
                        height: 20,
                        color: Colors.red,
                        child: const Text('Target Widget'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      targetFinder = find.text('Target Widget');
      tooltipFinder = find.byType(ToolTipWidget);
      targetCenter = getWidgetCenter(tester, targetFinder);
      tooltipCenter = getWidgetCenter(tester, tooltipFinder);
      expect(
        tooltipCenter.dx > targetCenter.dx,
        true,
        reason: 'Tooltip should be right of the target (right)',
      );
      ShowcaseView.get().next();
    });
  });

  group('Tooltip Edge Cases', () {
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
    testWidgets('ToolTipWidget with null/empty title and description',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: '',
              description: '',
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsOneWidget);
    });
    testWidgets('ToolTipWidget with extreme padding and border radius',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Extreme',
              description: 'Extreme',
              tooltipPadding: const EdgeInsets.all(100),
              tooltipBorderRadius: BorderRadius.circular(100),
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsOneWidget);
    });
    testWidgets('ToolTipWidget with null/empty custom container',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase.withWidget(
              key: key,
              height: 100,
              width: 200,
              container: Container(),
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsOneWidget);
    });

    testWidgets('ToolTipWidget with error-throwing custom container',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      Widget errorWidget() {
        throw const FormatException('Custom format error');
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase.withWidget(
              key: key,
              height: 100,
              width: 200,
              container: Builder(builder: (_) => errorWidget()),
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

      ShowcaseView.get().startShowCase([key]);

      // Expect the first exception during the first pump
      await tester.pump();
      expect(tester.takeException(), isA<FormatException>());

      // // Expect another exception during the second pump
      // await tester.pump(const Duration(milliseconds: 300));
      // expect(tester.takeException(), isA<FormatException>());

      // Verify no more exceptions are pending
      expect(tester.takeException(), isNull);
    });

    testWidgets('ToolTipWidget with missing/null text styles',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'No Style',
              description: 'No Style',
              titleTextStyle: null,
              descTextStyle: null,
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsOneWidget);
    });
    testWidgets('ToolTipWidget with multiple actions and null callbacks',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Actions',
              description: 'Actions',
              tooltipActions: const [
                TooltipActionButton(
                  type: TooltipDefaultActionType.next,
                  name: 'Next',
                  onTap: null,
                ),
                TooltipActionButton(
                  type: TooltipDefaultActionType.skip,
                  name: 'Skip',
                  onTap: null,
                ),
              ],
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsOneWidget);
    });
    testWidgets('ToolTipWidget with zero and long animation durations',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Anim',
              description: 'Anim',
              disableMovingAnimation: false,
              movingAnimationDuration: Duration.zero,
              disableScaleAnimation: false,
              scaleAnimationDuration: const Duration(seconds: 10),
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pumpAndSettle();
      expect(find.byType(ToolTipWidget), findsOneWidget);
    });
    testWidgets(
        'ToolTipWidget arrow painter presence/absence for all positions',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      for (final pos in TooltipPosition.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Showcase(
                key: key,
                title: 'Arrow Test',
                description: 'Testing arrow with position ${pos.name}',
                tooltipPosition: pos,
                showArrow: true,
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
        ShowcaseView.get().startShowCase([key]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        // Should find ShowcaseArrow
        expect(find.byType(ToolTipWidget), findsOneWidget);
        expect(find.byType(ShowcaseArrow), findsWidgets);
        ShowcaseView.get().next();
      }
      // Now test with showArrow: false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'No Arrow',
              description: 'No Arrow',
              showArrow: false,
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Should not find ShowcaseArrow
      expect(find.byType(ToolTipWidget), findsOneWidget);
      expect(find.byType(ShowcaseArrow), findsNothing);
    });
    testWidgets('ToolTipWidget fallback order for tooltip position',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      // Simulate a small screen by constraining the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 100,
              child: Showcase(
                key: key,
                title: 'Fallback',
                description: 'Fallback',
                tooltipPosition: TooltipPosition.bottom,
                child: const SizedBox(width: 90, height: 90),
              ),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsOneWidget);
    });
    testWidgets('ToolTipWidget target removed during showcase',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      Widget buildTestWidget({required bool showTarget}) {
        return MaterialApp(
          home: Scaffold(
            body: showTarget
                ? Showcase(
                    key: key,
                    title: 'Remove Target',
                    description: 'Target will be removed',
                    child: const SizedBox(width: 100, height: 50),
                  )
                : Container(),
          ),
        );
      }

      await tester.pumpWidget(buildTestWidget(showTarget: true));

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsOneWidget);

      // Remove target
      await tester.pumpWidget(buildTestWidget(showTarget: false));
      ShowcaseView.get().updateOverlay();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ToolTipWidget), findsNothing);
    });
  });

  group('Tooltip Styling Tests', () {
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
    testWidgets(
        'ToolTipWidget applies correct background, border radius and padding',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      final customBorderRadius = BorderRadius.circular(15.0);
      const customPadding = EdgeInsets.all(16.0);
      const customColor = Colors.teal;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Style Test',
              description: 'Testing style application',
              tooltipBackgroundColor: customColor,
              tooltipBorderRadius: customBorderRadius,
              tooltipPadding: customPadding,
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

      // Start showcase to show tooltip
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find the tooltip container
      final tooltipContainers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(ToolTipWidget),
              matching: find.byType(Container),
            ),
          )
          .toList();

      // At least one container should have our styling
      bool foundStyledContainer = false;

      for (final container in tooltipContainers) {
        if (container.decoration is BoxDecoration) {
          final BoxDecoration decoration =
              container.decoration as BoxDecoration;
          if (decoration.color == customColor &&
              decoration.borderRadius == customBorderRadius) {
            foundStyledContainer = true;
            expect(container.padding, customPadding);
            break;
          }
        }
      }

      expect(
        foundStyledContainer,
        true,
        reason: 'Could not find container with correct styling',
      );
      ShowcaseView.get().next();
    });
  });

  group('ToolTipWidget position tests', () {
    setUp(() {
      ShowcaseView.register();
    });

    tearDown(() {
      ShowcaseView.get().unregister();
    });

    // Helper to create a test widget with proper constraints
    Widget buildPositionTestWidget({
      required GlobalKey key,
      required TooltipPosition position,
      required double targetOffset,
      required String title,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              // Use a fixed size for consistency in tests
              return Container(
                width: 800,
                height: 800,
                color: Colors.grey.shade200,
                child: Stack(
                  children: [
                    // Position the target widget based on the tooltip position we want to test
                    // This ensures maximum space in the direction the tooltip should appear
                    Positioned(
                      left: position == TooltipPosition.right
                          ? targetOffset // For RIGHT position, target should be near left
                          : position == TooltipPosition.left
                              ? 800 -
                                  targetOffset // For LEFT position, target should be near right
                              : 400, // For vertical positions, center horizontally
                      top: position == TooltipPosition.bottom
                          ? targetOffset // For BOTTOM position, target should be near top
                          : position == TooltipPosition.top
                              ? 800 -
                                  targetOffset // For TOP position, target should be near bottom
                              : 400, // For horizontal positions, center vertically
                      child: Showcase(
                        key: key,
                        title: title,
                        description: 'Testing $position position',
                        tooltipPosition: position,
                        targetShapeBorder: const CircleBorder(),
                        targetPadding: EdgeInsets.zero,
                        disableMovingAnimation: true,
                        // Disable animation for reliable positioning
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.red,
                          child: const Text('Target Widget'),
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
    }

    testWidgets('Tooltip position top', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        buildPositionTestWidget(
          key: key,
          position: TooltipPosition.top,
          targetOffset: 100, // 100px from the bottom
          title: 'Top Test',
        ),
      );

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);

      // Dump debug info
      dumpPositionInfo(tester, targetFinder, tooltipFinder);

      // Verify position
      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);

      expect(
        tooltipCenter.dy < targetCenter.dy,
        true,
        reason: 'Tooltip should be above the target',
      );

      ShowcaseView.get().next();
    });

    testWidgets('Tooltip position bottom', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        buildPositionTestWidget(
          key: key,
          position: TooltipPosition.bottom,
          targetOffset: 100, // 100px from the top
          title: 'Bottom Test',
        ),
      );

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);

      // Dump debug info
      dumpPositionInfo(tester, targetFinder, tooltipFinder);

      // Verify position
      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);

      expect(
        tooltipCenter.dy > targetCenter.dy,
        true,
        reason: 'Tooltip should be below the target',
      );

      ShowcaseView.get().next();
    });

    testWidgets('Tooltip position left', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        buildPositionTestWidget(
          key: key,
          position: TooltipPosition.left,
          targetOffset: 100, // 100px from the right
          title: 'Left Test',
        ),
      );

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);

      // Dump debug info
      dumpPositionInfo(tester, targetFinder, tooltipFinder);

      // Verify position
      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);

      expect(
        tooltipCenter.dx < targetCenter.dx,
        true,
        reason: 'Tooltip should be to the left of the target',
      );

      ShowcaseView.get().next();
    });

    testWidgets('Tooltip position right', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        buildPositionTestWidget(
          key: key,
          position: TooltipPosition.right,
          targetOffset: 100, // 100px from the left
          title: 'Right Test',
        ),
      );

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final targetFinder = find.text('Target Widget');
      final tooltipFinder = find.byType(ToolTipWidget);

      // Dump debug info
      dumpPositionInfo(tester, targetFinder, tooltipFinder);

      // Verify position
      final targetCenter = getWidgetCenter(tester, targetFinder);
      final tooltipCenter = getWidgetCenter(tester, tooltipFinder);

      expect(
        tooltipCenter.dx > targetCenter.dx,
        true,
        reason: 'Tooltip should be to the right of the target',
      );

      ShowcaseView.get().next();
    });
  });
}
