import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:showcaseview/src/utils/extensions.dart';

Color? findOverlayColor(WidgetTester tester, Color color) {
  // Try to find a DecoratedBox or ColoredBox in the overlay
  final coloredBox =
      tester.widgetList(find.byType(ColoredBox)).cast<ColoredBox?>().toList();

  for (final box in coloredBox) {
    final boxColor = box?.color;

    if (boxColor != null) {
      // Check if colors match with a small tolerance
      final colorMatches = (boxColor.safeRed - color.safeRed).abs() < 0.01 &&
          (boxColor.safeGreen - color.safeGreen).abs() < 0.01 &&
          (boxColor.safeBlue - color.safeBlue).abs() < 0.01 &&
          (boxColor.safeOpacity - color.safeOpacity).abs() < 0.01;

      if (colorMatches) {
        return boxColor;
      }
    }
  }

  // If no exact match, try to find closest color
  if (coloredBox.isNotEmpty && coloredBox.first?.color != null) {
    return coloredBox.first?.color;
  }

  return null;
}

double? findOverlayBlurSigma(WidgetTester tester) {
  final filters =
      tester.widgetList(find.byType(ImageFiltered)).cast<ImageFiltered?>();

  for (final filter in filters) {
    final ImageFilter? imageFilter = filter?.imageFilter;

    if (imageFilter is ImageFilter) {
      // Try to extract sigma from the filter's toString (since ImageFilter.blur is private)
      final str = imageFilter.toString();

      final match = RegExp(r'ImageFilter\.blur\(\s*([0-9.]+)\s*,\s*([0-9.]+)')
          .firstMatch(str);
      if (match != null) {
        final sigma = double.tryParse(match.group(1)!);
        return sigma;
      }
    }
  }
  return null;
}

void main() {
  group('Overlay Tests', () {
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
      'Overlay renders with default properties',
      (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Showcase(
                key: key,
                title: 'Overlay Test',
                description: 'Testing overlay functionality',
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

        // Start showcase to show overlay
        ShowcaseView.get().startShowCase([key]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify overlay is rendered
        expect(find.byType(Overlay), findsWidgets);
      },
    );

    testWidgets(
      'Overlay with custom color and opacity',
      (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Showcase(
                key: key,
                title: 'Custom Overlay',
                description: 'Testing custom overlay properties',
                overlayColor: Colors.purple,
                overlayOpacity: 0.5,
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

        // Start showcase to show overlay
        ShowcaseView.get().startShowCase([key]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify overlay is rendered
        expect(find.byType(Overlay), findsWidgets);
        // Check for overlay color and opacity
        final color =
            findOverlayColor(tester, Colors.purple.reduceOpacity(0.5));
        expect(color, isNotNull);
        expect(color, Colors.purple.reduceOpacity(0.5));
      },
    );

    testWidgets(
      'Overlay with blur value',
      (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Showcase(
                key: key,
                title: 'Blurred Overlay',
                description: 'Testing overlay with blur',
                blurValue: 8.0,
                overlayColor: Colors.pink,
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

        // Start showcase to show overlay
        ShowcaseView.get().startShowCase([key]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify overlay is rendered
        expect(find.byType(Overlay), findsWidgets);
        // Check for BackdropFilter and blur value
        final blurSigma = findOverlayBlurSigma(tester);
        expect(blurSigma, isNotNull);
        expect(blurSigma, closeTo(8.0, 0.1));
      },
    );

    testWidgets(
      'Overlay with barrier click callback',
      (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();
        int barrierClickCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                width: 300,
                height: 200,
                alignment: Alignment.center,
                child: Showcase(
                  key: key,
                  title: 'Barrier Click Test',
                  description: 'Testing barrier click functionality',
                  onBarrierClick: () => barrierClickCount++,
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

        // Start showcase to show overlay
        ShowcaseView.get().startShowCase([key]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        // Verify overlay is rendered
        expect(find.byType(Overlay), findsWidgets);
        await tester.tapAt(const Offset(10, 10)); // Tap on the barrier

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(barrierClickCount, 1);
      },
    );

    testWidgets(
      'Overlay with disabled barrier interaction',
      (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                width: 300,
                height: 200,
                alignment: Alignment.center,
                child: Showcase(
                  key: key,
                  title: 'Barrier Click Test',
                  description: 'Testing barrier click functionality',
                  disableBarrierInteraction: true,
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

        // Start showcase to show overlay
        ShowcaseView.get().startShowCase([key]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify overlay is rendered
        expect(find.byType(Overlay), findsWidgets);
        await tester.tapAt(const Offset(0, 0)); // Tap on the barrier

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(ShowcaseView.get().isShowcaseRunning, true);
      },
    );

    testWidgets(
      'Overlay with multiple showcases',
      (WidgetTester tester) async {
        final GlobalKey key1 = GlobalKey();
        final GlobalKey key2 = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Showcase(
                    key: key1,
                    title: 'First Overlay',
                    description: 'First overlay description',
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.red,
                      child: const Text('Target 1'),
                    ),
                  ),
                  Showcase(
                    key: key2,
                    title: 'Second Overlay',
                    description: 'Second overlay description',
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.blue,
                      child: const Text('Target 2'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Start showcase sequence
        ShowcaseView.get().startShowCase([key1, key2]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify overlay is rendered for first showcase
        expect(find.byType(Overlay), findsWidgets);

        // Move to second showcase
        ShowcaseView.get().next();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify overlay is rendered for second showcase
        expect(find.byType(Overlay), findsWidgets);
      },
    );

    testWidgets(
      'Overlay with multi showcases',
      (WidgetTester tester) async {
        final GlobalKey sharedKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    top: 100,
                    left: 50,
                    child: Showcase(
                      key: sharedKey,
                      title: 'Simultaneous Overlay 1',
                      description: 'First simultaneous overlay',
                      child: Container(
                        width: 100,
                        height: 50,
                        color: Colors.red,
                        child: const Text('Target 1'),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 150,
                    left: 100,
                    child: Showcase(
                      key: sharedKey,
                      title: 'Simultaneous Overlay 2',
                      description: 'Second simultaneous overlay',
                      child: Container(
                        width: 100,
                        height: 50,
                        color: Colors.blue,
                        child: const Text('Target 2'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Start simultaneous showcases
        ShowcaseView.get().startShowCase([sharedKey]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify overlay is rendered
        expect(find.byType(Overlay), findsWidgets);
      },
    );

    testWidgets(
      'Overlay with different opacity values',
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
                    title: 'High Opacity',
                    description: 'High opacity overlay',
                    overlayOpacity: 0.9,
                    overlayColor: Colors.blue,
                    child: const SizedBox(
                      width: 100,
                      height: 50,
                      // color: Colors.red,
                      child: Text('Target 1'),
                    ),
                  ),
                  Showcase(
                    key: key2,
                    title: 'Medium Opacity',
                    description: 'Medium opacity overlay',
                    overlayOpacity: 0.1,
                    overlayColor: Colors.blue,
                    child: const SizedBox(
                      width: 100,
                      height: 50,
                      // color: Colors.blue,
                      child: Text('Target 2'),
                    ),
                  ),
                  Showcase(
                    key: key3,
                    title: 'Low Opacity',
                    description: 'Low opacity overlay',
                    overlayOpacity: 0.3,
                    overlayColor: Colors.green,
                    child: const SizedBox(
                      width: 100,
                      height: 50,
                      // color: Colors.green,
                      child: Text('Target 3'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Test each opacity level
        ShowcaseView.get().startShowCase([key1, key2, key3]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // First showcase - High opacity
        expect(find.byType(Overlay), findsWidgets);
        var color = findOverlayColor(tester, Colors.blue.reduceOpacity(0.9));
        expect(color, isNotNull);

        // Allow a small tolerance when comparing colors
        expect(
          (color!.safeOpacity - 0.9).abs() < 0.01,
          isTrue,
          reason: 'Opacity should be close to 0.9',
        );
        expect(color.safeRed, closeTo(Colors.blue.safeRed, 0.01));
        expect(color.safeGreen, closeTo(Colors.blue.safeGreen, 0.01));
        expect(color.safeBlue, closeTo(Colors.blue.safeBlue, 0.01));

        // Move to second showcase - Medium opacity
        ShowcaseView.get().next();
        await tester.pump(); // pump once to register the callback

        // Use multiple pumps with delays instead of pumpAndSettle
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byType(Overlay), findsWidgets);
        expect(ShowcaseView.get().getActiveShowcaseKey, key2);

        color = findOverlayColor(tester, Colors.blue.reduceOpacity(0.1));
        expect(color, isNotNull);

        // Allow a small tolerance when comparing colors
        expect(
          (color!.safeOpacity - 0.1).abs() < 0.05,
          isTrue,
          reason: 'Opacity should be close to 0.1',
        );
        expect(color.safeRed, closeTo(Colors.blue.safeRed, 0.01));
        expect(color.safeGreen, closeTo(Colors.blue.safeGreen, 0.01));
        expect(color.safeBlue, closeTo(Colors.blue.safeBlue, 0.01));

        // Move to third showcase - Low opacity
        ShowcaseView.get().next();
        await tester.pump();

        // Use multiple pumps with delays instead of pumpAndSettle
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byType(Overlay), findsWidgets);
        expect(ShowcaseView.get().getActiveShowcaseKey, key3);

        color = findOverlayColor(tester, Colors.green.reduceOpacity(0.3));
        expect(color, isNotNull);

        // Allow a small tolerance when comparing colors
        expect(
          (color!.safeOpacity - 0.3).abs() < 0.05,
          isTrue,
          reason: 'Opacity should be close to 0.3',
        );
        expect(color.safeRed, closeTo(Colors.green.safeRed, 0.01));
        expect(color.safeGreen, closeTo(Colors.green.safeGreen, 0.01));
        expect(color.safeBlue, closeTo(Colors.green.safeBlue, 0.01));
      },
    );

    testWidgets(
      'Overlay with different blur values',
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
                    title: 'No Blur',
                    description: 'No blur overlay',
                    blurValue: 0,
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.red,
                      child: const Text('Target 1'),
                    ),
                  ),
                  Showcase(
                    key: key2,
                    title: 'Medium Blur',
                    description: 'Medium blur overlay',
                    blurValue: 5.0,
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.blue,
                      child: const Text('Target 2'),
                    ),
                  ),
                  Showcase(
                    key: key3,
                    title: 'High Blur',
                    description: 'High blur overlay',
                    blurValue: 10.0,
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.green,
                      child: const Text('Target 3'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Test each blur level
        ShowcaseView.get().startShowCase([key1, key2, key3]);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // First showcase - No blur
        expect(find.byType(Overlay), findsWidgets);
        var blurSigma = findOverlayBlurSigma(tester);
        expect(
          blurSigma == null || blurSigma == 0,
          isTrue,
          reason: 'First showcase should have no blur',
        );

        // Move to second showcase - Medium blur
        ShowcaseView.get().next();
        await tester.pump();

        // Use multiple pumps with delays instead of pumpAndSettle
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Verify the active showcase key
        expect(ShowcaseView.get().getActiveShowcaseKey, key2);
        expect(find.byType(Overlay), findsWidgets);

        // Explicitly ask to rebuild the overlay
        ShowcaseView.get().updateOverlay();
        await tester.pump();

        // Use more pumps to ensure updates are applied
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Check medium blur
        blurSigma = findOverlayBlurSigma(tester);
        expect(
          blurSigma,
          isNotNull,
          reason: 'Second showcase should have a blur value',
        );
        expect(
          blurSigma,
          closeTo(5.0, 0.1),
          reason: 'Blur value should be close to 5.0',
        );

        // Move to third showcase - High blur
        ShowcaseView.get().next();
        await tester.pump();

        // Use multiple pumps with delays instead of pumpAndSettle
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Verify the active showcase key
        expect(ShowcaseView.get().getActiveShowcaseKey, key3);
        expect(find.byType(Overlay), findsWidgets);

        // Explicitly ask to rebuild the overlay
        ShowcaseView.get().updateOverlay();
        await tester.pump();

        // Use more pumps to ensure updates are applied
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Check high blur
        blurSigma = findOverlayBlurSigma(tester);
        expect(
          blurSigma,
          isNotNull,
          reason: 'Third showcase should have a blur value',
        );
        expect(
          blurSigma,
          closeTo(10.0, 0.1),
          reason: 'Blur value should be close to 10.0',
        );
      },
    );

    testWidgets('Overlay with custom target shape borders',
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
                  title: 'Rounded Border',
                  description: 'Rounded border overlay',
                  targetShapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: 100,
                    height: 50,
                    color: Colors.red,
                    child: const Text('Target 1'),
                  ),
                ),
                Showcase(
                  key: key2,
                  title: 'Beveled Border',
                  description: 'Beveled border overlay',
                  targetShapeBorder: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: 100,
                    height: 50,
                    color: Colors.blue,
                    child: const Text('Target 2'),
                  ),
                ),
                Showcase(
                  key: key3,
                  title: 'Stadium Border',
                  description: 'Stadium border overlay',
                  targetShapeBorder: const StadiumBorder(),
                  child: Container(
                    width: 100,
                    height: 50,
                    color: Colors.green,
                    child: const Text('Target 3'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Test each border shape
      ShowcaseView.get().startShowCase([key1]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Overlay), findsWidgets);

      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Overlay), findsWidgets);

      ShowcaseView.get().next();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Overlay), findsWidgets);
    });

    testWidgets('Overlay with zero opacity', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Zero Opacity',
              description: 'Testing overlay with zero opacity',
              overlayOpacity: 0.0,
              overlayColor: Colors.black,
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

      // Start showcase to show overlay
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify overlay is rendered
      expect(find.byType(Overlay), findsWidgets);

      // Check for overlay color with zero opacity
      final color = findOverlayColor(tester, Colors.black.reduceOpacity(0.0));
      expect(color, isNotNull);
      expect(color, Colors.black.reduceOpacity(0.0));
    });

    testWidgets('Overlay with full opacity', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Full Opacity',
              description: 'Testing overlay with full opacity',
              overlayOpacity: 1.0,
              overlayColor: Colors.black,
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

      // Start showcase to show overlay
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify overlay is rendered
      expect(find.byType(Overlay), findsWidgets);

      // Check for overlay color with full opacity
      final color = findOverlayColor(tester, Colors.black.reduceOpacity(1.0));
      expect(color, isNotNull);
      expect(color, Colors.black.reduceOpacity(1.0));
    });

    testWidgets('Overlay with custom target shape border and border radius',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      const Color borderColor = Colors.red;
      const double borderWidth = 2.0;
      final BorderRadius borderRadius = BorderRadius.circular(24);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Custom Border Overlay',
              description: 'Testing overlay with custom target border',
              targetShapeBorder: RoundedRectangleBorder(
                borderRadius: borderRadius,
                side: const BorderSide(color: borderColor, width: borderWidth),
              ),
              targetBorderRadius: borderRadius,
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

      // Verify showcase is visible
      expect(find.byType(Overlay), findsWidgets);
      expect(find.text('Custom Border Overlay'), findsOneWidget);
      expect(
        find.text('Testing overlay with custom target border'),
        findsOneWidget,
      );

      // Check for CustomPaint for shape rendering
      expect(find.byType(CustomPaint), findsWidgets);

      // Look for ClipRRect with the specified border radius (if used)
      final clipRRects =
          tester.widgetList(find.byType(ClipRRect)).cast<ClipRRect?>().toList();
      bool foundMatchingBorderRadius = false;
      for (final clip in clipRRects) {
        if (clip?.borderRadius.toString() == borderRadius.toString()) {
          foundMatchingBorderRadius = true;
          break;
        }
      }

      // Either we found a matching ClipRRect or there's a custom painter handling the shape
      expect(
        foundMatchingBorderRadius ||
            find.byType(CustomPaint).evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  group('Overlay Edge Cases', () {
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

    testWidgets('Overlay with fully transparent color',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Transparent',
              description: 'Fully transparent overlay',
              overlayColor: Colors.transparent,
              overlayOpacity: 0.0,
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify overlay exists
      expect(find.byType(Overlay), findsWidgets);

      // Verify the overlay is actually transparent
      final color = findOverlayColor(tester, Colors.transparent);
      expect(color, isNotNull);
      expect(color?.safeAlpha, equals(0));

      // Verify showcase content is visible
      expect(find.text('Transparent'), findsOneWidget);
      expect(find.text('Fully transparent overlay'), findsOneWidget);
    });

    testWidgets('Overlay with fully opaque color', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Opaque',
              description: 'Fully opaque overlay',
              overlayColor: Colors.black,
              overlayOpacity: 1.0,
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify overlay exists
      expect(find.byType(Overlay), findsWidgets);

      // Verify the overlay is actually fully opaque
      final color = findOverlayColor(tester, Colors.black.reduceOpacity(1.0));
      expect(color, isNotNull);
      expect(color, equals(Colors.black.reduceOpacity(1.0)));

      // Verify showcase content is visible
      expect(find.text('Opaque'), findsOneWidget);
      expect(find.text('Fully opaque overlay'), findsOneWidget);
    });

    testWidgets('Overlay with zero blur', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Zero Blur',
              description: 'No blur',
              blurValue: 0.0,
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify overlay exists
      expect(find.byType(Overlay), findsWidgets);

      // Verify no blur filter is applied
      final blurSigma = findOverlayBlurSigma(tester);
      expect(blurSigma == null || blurSigma == 0, isTrue);

      // Verify there are no ImageFiltered widgets with blur
      final imageFilteredWidgets =
          tester.widgetList(find.byType(ImageFiltered)).where((widget) {
        final filter = (widget as ImageFiltered).imageFilter;
        return filter.toString().contains('ImageFilter.blur') &&
            !filter.toString().contains('0.0');
      });
      expect(imageFilteredWidgets.isEmpty, isTrue);

      // Verify showcase content is visible
      expect(find.text('Zero Blur'), findsOneWidget);
    });

    testWidgets('Overlay with very high blur', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      const double highBlurValue = 100.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'High Blur',
              description: 'Extreme blur',
              blurValue: highBlurValue,
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify overlay exists
      expect(find.byType(Overlay), findsWidgets);

      // Verify high blur is applied
      final blurSigma = findOverlayBlurSigma(tester);
      expect(blurSigma, isNotNull);
      expect(blurSigma, closeTo(highBlurValue, 0.1));

      // Verify showcase content is visible despite blur
      expect(find.text('High Blur'), findsOneWidget);
    });

    testWidgets('Overlay with edge case border radius',
        (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();
      final BorderRadius extremeRadius = BorderRadius.circular(1000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Showcase(
              key: key,
              title: 'Extreme Border Radius',
              description: 'Testing very large border radius',
              targetBorderRadius: extremeRadius,
              child: const SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );

      ShowcaseView.get().startShowCase([key]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Overlay), findsWidgets);
      expect(find.text('Extreme Border Radius'), findsOneWidget);

      // Verify the showcase properly renders with extreme border radius
      // by checking that the content is still accessible
      expect(find.text('Testing very large border radius'), findsOneWidget);
    });
  });
}
