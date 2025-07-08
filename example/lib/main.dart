import 'dart:math';

import 'package:example/detailscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:showcaseview/showcaseview.dart';

void main() => runApp(const MyApp());

/// Global key for the first showcase widget
final GlobalKey _firstShowcaseWidget = GlobalKey();

/// Global key for the last showcase widget
final GlobalKey _lastShowcaseWidget = GlobalKey();

/// Random instance for consistent seeding
final Random _globalRandom = Random();

/// Enhanced Random Configuration Class
class RandomShowcaseConfig {
  static const List<Color> randomColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.indigo,
    Colors.pink,
    Colors.teal,
    Colors.lime,
    Colors.brown,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.yellow,
    Colors.grey
  ];

  static const List<String> randomEmojis = [
    '🎯',
    '🎨',
    '🚀',
    '⭐',
    '🌟',
    '💫',
    '🎪',
    '🎭',
    '🎨',
    '🎯',
    '🔥',
    '💎',
    '🌈',
    '⚡',
    '🌸',
    '🎄',
    '🎃',
    '🎁',
    '🎉',
    '🎊'
  ];

  static const List<String> randomDescriptions = [
    'Amazing feature here!',
    'Don\'t miss this!',
    'Super cool functionality',
    'Tap to explore',
    'Check this out!',
    'Awesome content',
    'Interactive element',
    'Important feature',
    'Hidden gem',
    'Special functionality',
    'Cool animation',
    'Swipe to continue',
    'Long press for more',
    'Shake to activate'
  ];

  static const List<double> randomSizes = [
    0.1,
    0.2,
    0.3,
    0.4,
    0.5,
    0.6,
    // 0.75,
    // 1.0,
    // 1.25,
    // 1.5,
    // 2.0,
    // 2.5,
    // 3.0
  ];

  static const List<BorderRadius> randomBorderRadius = [
    BorderRadius.zero,
    BorderRadius.all(Radius.circular(5)),
    BorderRadius.all(Radius.circular(10)),
    BorderRadius.all(Radius.circular(15)),
    BorderRadius.all(Radius.circular(20)),
    BorderRadius.all(Radius.circular(25)),
    BorderRadius.all(Radius.circular(30)),
  ];
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ShowCase',
      theme: ThemeData(
        primaryColor: const Color(0xffEE5366),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ShowCaseWidget(
          hideFloatingActionWidgetForShowcase: [_lastShowcaseWidget],
          globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
            left: 16,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: ShowCaseWidget.of(showcaseContext).dismiss,
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
          onStart: (index, key) {
            print('onStart: $index, $key');
          },
          onComplete: (index, key) {
            print('onComplete: $index, $key');
            if (index == 4) {
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle.light.copyWith(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.white,
                ),
              );
            }
          },
          onFinish: () {
            print('finished');
          },
          autoPlay: true,
          blurValue: 5,
          autoPlayDelay: const Duration(seconds: 2),
          builder: (context) => const MailPage(),
          enableAutoScroll: true,
          globalTooltipActionConfig: const TooltipActionConfig(
            position: TooltipActionPosition.inside,
            alignment: MainAxisAlignment.spaceBetween,
            actionGap: 20,
          ),
          globalTooltipActions: [
            // Here we don't need previous action for the first showcase widget
            // so we hide this action for the first showcase widget
            TooltipActionButton(
              type: TooltipDefaultActionType.previous,
              textStyle: const TextStyle(
                color: Colors.white,
              ),
              hideActionWidgetForShowcase: [_firstShowcaseWidget],
            ),
            // Here we don't need next action for the last showcase widget so we
            // hide this action for the last showcase widget
            TooltipActionButton(
              type: TooltipDefaultActionType.next,
              textStyle: const TextStyle(
                color: Colors.white,
              ),
              hideActionWidgetForShowcase: [_lastShowcaseWidget],
            ),
          ],
          onDismiss: (key) {
            debugPrint('Dismissed at $key');
          },
        ),
      ),
    );
  }
}

class MailPage extends StatefulWidget {
  const MailPage({Key? key}) : super(key: key);

  @override
  State<MailPage> createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  List<Mail> mails = [];

  final scrollController = ScrollController();

  Widget RandomShowCaseBuilder() {
    final totalCount = 150; // Increased for more variety
    final keysList = List.generate(totalCount, (index) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase(keysList),
    );

    final randomShowCase = List.generate(
      totalCount,
      (index) {
        // Enhanced random parameters - use timestamp-based seed to ensure different results each run
        final random = Random(DateTime.now().millisecondsSinceEpoch + index);
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Random dimensions with more variety
        // Create special handling for items 23 and 24 that are consistently too large
        final bool isProblematicIndex = (index == 23 || index == 24);

        final minWidth = screenWidth * (isProblematicIndex ? 0.05 : 0.05);
        final maxWidth = screenWidth *
            (isProblematicIndex ? 0.15 : (0.15 + random.nextDouble() * 0.25));

        final minHeight = screenHeight * (isProblematicIndex ? 0.02 : 0.02);
        final maxHeight = screenHeight *
            (isProblematicIndex ? 0.05 : (0.05 + random.nextDouble() * 0.15));

        final width = 100.0;
        final height = minHeight +
            (random.nextDouble() * (maxHeight - minHeight))
                .clamp(0, 100)
                .toDouble();
        print('$index item: $height');
        // Random positioning parameters
        final isLeftAligned = random.nextBool();
        final isRightAligned = !isLeftAligned && random.nextBool();
        final useRandomMargin = random.nextBool();
        final randomMargin = random.nextDouble() * 20;

        // Random styling parameters
        final randomColor = generateEnhancedRandomColor(index);
        final randomBorderRadius = getRandomBorderRadius(index);
        final randomElevation = random.nextDouble() * 10;
        final randomOpacity = 0.3 + random.nextDouble() * 0.7;
        final randomRotation = (random.nextDouble() - 0.5) * 0.2;

        // Random animation parameters
        final animationDuration =
            Duration(milliseconds: 500 + random.nextInt(2000));
        final useRandomAnimation = random.nextBool();

        // Random content parameters
        final randomEmoji = getRandomEmoji(index);
        final randomDescription = getEnhancedRandomDescription(index);
        final randomTooltipPosition = getRandomTooltipPosition(index);

        return (index % random.nextInt(100).clamp(1, 100)).isEven
            ? Transform.rotate(
                angle: randomRotation,
                child: AnimatedContainer(
                  duration:
                      useRandomAnimation ? animationDuration : Duration.zero,
                  margin: EdgeInsets.only(
                    left: isLeftAligned ? randomMargin : 0,
                    right: isRightAligned ? randomMargin : 0,
                    top: useRandomMargin ? randomMargin : 0,
                    bottom: useRandomMargin ? randomMargin : 0,
                  ),
                  child: Showcase(
                    key: keysList[index],
                    description: '$randomEmoji $randomDescription',
                    tooltipActions: _generateEnhancedListOfRandomAction(index),
                    tooltipActionConfig:
                        getEnhancedActionConfig(index, totalCount),
                    onToolTipClick: () {
                      // Random navigation behavior
                      if (random.nextBool()) {
                        ShowCaseWidget.of(context).previous();
                      } else {
                        ShowCaseWidget.of(context).next();
                      }
                    },
                    tooltipPosition: randomTooltipPosition,
                    targetBorderRadius: randomBorderRadius,
                    targetShapeBorder: getRandomShapeBorder(index),
                    blurValue: random.nextDouble() * 5,
                    // Only set disposeOnTap if we also provide onTargetClick
                    // disposeOnTap: random.nextBool(),
                    // onTargetClick: !random.nextBool()
                    //     ? () {
                    //         final actions = [
                    //           () => ShowCaseWidget.of(context).previous(),
                    //           () => ShowCaseWidget.of(context).next(),
                    //           () => ShowCaseWidget.of(context).dismiss(),
                    //         ];
                    //         actions[random.nextInt(actions.length)];
                    //       }
                    //     : null,
                    movingAnimationDuration: animationDuration,
                    showArrow: random.nextBool(),
                    disableMovingAnimation: !useRandomAnimation,
                    child: Material(
                      elevation: randomElevation,
                      borderRadius: randomBorderRadius,
                      child: Container(
                        decoration: BoxDecoration(
                          color: randomColor.withOpacity(randomOpacity),
                          borderRadius: randomBorderRadius,
                          gradient: random.nextBool()
                              ? getRandomGradient(index)
                              : null,
                          boxShadow: random.nextBool()
                              ? [
                                  BoxShadow(
                                    color: randomColor.withOpacity(0.3),
                                    blurRadius: random.nextDouble() * 10,
                                    offset: Offset(
                                      (random.nextDouble() - 0.5) * 10,
                                      (random.nextDouble() - 0.5) * 10,
                                    ),
                                  )
                                ]
                              : null,
                        ),
                        width: width,
                        height: height,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                randomEmoji,
                                style: TextStyle(
                                  fontSize: 20 + random.nextDouble() * 20,
                                ),
                              ),
                              if (random.nextBool()) ...[
                                SizedBox(height: 5),
                                Text(
                                  'Item $index',
                                  style: TextStyle(
                                    color: getContrastColor(randomColor),
                                    fontSize: 12 + random.nextDouble() * 8,
                                    fontWeight: random.nextBool()
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Transform.rotate(
                angle: -randomRotation,
                child: AnimatedContainer(
                  duration:
                      useRandomAnimation ? animationDuration : Duration.zero,
                  margin: EdgeInsets.only(
                    left: isRightAligned ? randomMargin : 0,
                    right: isLeftAligned ? randomMargin : 0,
                    top: useRandomMargin ? randomMargin * 0.5 : 0,
                    bottom: useRandomMargin ? randomMargin * 0.5 : 0,
                  ),
                  child: Showcase.withWidget(
                    width: width,
                    height: height,
                    key: keysList[index],
                    tooltipActions: _generateEnhancedListOfRandomAction(index),
                    tooltipActionConfig:
                        getEnhancedActionConfig(index, totalCount),
                    tooltipPosition: randomTooltipPosition,
                    targetBorderRadius: randomBorderRadius,
                    targetShapeBorder: getRandomShapeBorder(index),
                    blurValue: random.nextDouble() * 8,
                    // disposeOnTap: random.nextBool() ,
                    // // ensure onTargetClick present when disposeOnTap is set
                    // onTargetClick: random.nextBool()
                    //     ? () {
                    //         final actions = [
                    //           () => ShowCaseWidget.of(context).previous(),
                    //           () => ShowCaseWidget.of(context).next(),
                    //           () => ShowCaseWidget.of(context).dismiss(),
                    //         ];
                    //         actions[random.nextInt(actions.length)];
                    //       }
                    //     : null,
                    movingAnimationDuration: animationDuration,
                    // showArrow: random.nextBool(),
                    disableMovingAnimation: !useRandomAnimation,
                    container: Material(
                      elevation: randomElevation,
                      borderRadius: randomBorderRadius,
                      child: Container(
                        decoration: BoxDecoration(
                          color: randomColor.withOpacity(randomOpacity),
                          borderRadius: randomBorderRadius,
                          gradient: random.nextBool()
                              ? getRandomGradient(index)
                              : null,
                        ),
                        width: width,
                        height: height,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                getRandomIcon(index),
                                size: 20 + random.nextDouble() * 30,
                                color: getContrastColor(randomColor),
                              ),
                              if (random.nextBool()) ...[
                                SizedBox(height: 5),
                                Text(
                                  'Widget $index',
                                  style: TextStyle(
                                    color: getContrastColor(randomColor),
                                    fontSize: 10 + random.nextDouble() * 6,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Random tap behavior
                        final actions = [
                          () => ShowCaseWidget.of(context).previous(),
                          () => ShowCaseWidget.of(context).next(),
                          () => ShowCaseWidget.of(context).dismiss(),
                        ];
                        actions[random.nextInt(actions.length)]();
                      },
                      onLongPress: random.nextBool()
                          ? () {
                              ShowCaseWidget.of(context).dismiss();
                            }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: generateEnhancedRandomColor(index * 2)
                              .withOpacity(randomOpacity),
                          borderRadius: randomBorderRadius,
                          border: random.nextBool()
                              ? Border.all(
                                  color: randomColor,
                                  width: 1 + random.nextDouble() * 3,
                                )
                              : null,
                        ),
                        width: width,
                        height: height,
                        child: Center(
                          child: Text(
                            randomEmoji,
                            style: TextStyle(
                              fontSize: 25 + random.nextDouble() * 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
      },
    );

    return Padding(
      padding: EdgeInsets.all(8 + _globalRandom.nextDouble() * 16),
      child: GridView.custom(
        gridDelegate: SliverStairedGridDelegate(
          crossAxisSpacing: 20 + _globalRandom.nextDouble() * 40,
          mainAxisSpacing: 10 + _globalRandom.nextDouble() * 30,
          pattern: List.generate(
            totalCount,
            (index) => StairedGridTile(
              0.3 + Random(index).nextDouble() * 0.7,
              0.5 + Random(index).nextDouble() * 15,
            ),
          ),
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          childCount: totalCount,
          (context, index) {
            print('Building showcase item: $index');
            return randomShowCase[index];
          },
        ),
      ),
    );
  }

  // List<TooltipActionButton> _generateListOfRandomAction() {
  //   return List.generate(
  //     Random().nextInt(5),
  //     (index) => (index % Random().nextInt(100).clamp(1, 100)).isEven
  //         ? TooltipActionButton(
  //             type: TooltipDefaultActionType.values[index % 3],
  //             name: getRandomString(50),
  //           )
  //         : TooltipActionButton.custom(
  //             button: Container(
  //               color: generateRandomLightColor(),
  //               child: Text(
  //                 getRandomString(50),
  //               ),
  //               width: Random().nextInt(100).toDouble(),
  //               height: Random().nextInt(100).toDouble(),
  //             ),
  //           ),
  //   );
  // }

  // Enhanced helper methods
  List<TooltipActionButton> _generateEnhancedListOfRandomAction(int index) {
    final random = Random(index);
    final actionCount = 1 + random.nextInt(6); // 1-6 actions

    return List.generate(
      actionCount,
      (actionIndex) {
        final isCustomAction = random.nextBool();
        final randomColor = generateEnhancedRandomColor(index + actionIndex);

        if (isCustomAction) {
          return TooltipActionButton.custom(
            button: InkWell(
              child: Container(
                padding: EdgeInsets.all(8 + random.nextDouble() * 12),
                decoration: BoxDecoration(
                  color: randomColor.withOpacity(0.8),
                  borderRadius:
                      BorderRadius.circular(5 + random.nextDouble() * 20),
                  gradient: random.nextBool()
                      ? getRandomGradient(index + actionIndex)
                      : null,
                  boxShadow: random.nextBool()
                      ? [
                          BoxShadow(
                            color: randomColor.withOpacity(0.3),
                            blurRadius: random.nextDouble() * 5,
                            offset: Offset(random.nextDouble() * 2,
                                random.nextDouble() * 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getRandomIcon(actionIndex),
                      size: 16 + random.nextDouble() * 8,
                      color: getContrastColor(randomColor),
                    ),
                    if (random.nextBool()) ...[
                      SizedBox(width: 5),
                      Text(
                        getRandomActionName(actionIndex),
                        style: TextStyle(
                          color: getContrastColor(randomColor),
                          fontSize: 12 + random.nextDouble() * 6,
                          fontWeight: random.nextBool()
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              onTap: () {
                // Random action behavior
                final actions = [
                  () => ShowCaseWidget.of(context).previous(),
                  () => ShowCaseWidget.of(context).next(),
                  () => ShowCaseWidget.of(context).dismiss(),
                ];
                actions[random.nextInt(actions.length)]();
              },
            ),
          );
        } else {
          return TooltipActionButton(
            type: TooltipDefaultActionType
                .values[actionIndex % TooltipDefaultActionType.values.length],
            name: getRandomActionName(actionIndex),
            backgroundColor: randomColor.withOpacity(0.8),
            textStyle: TextStyle(
              color: getContrastColor(randomColor),
              fontSize: 12 + random.nextDouble() * 4,
              fontWeight:
                  random.nextBool() ? FontWeight.bold : FontWeight.normal,
            ),
            leadIcon: random.nextBool()
                ? ActionButtonIcon(
                    icon: Icon(
                      getRandomIcon(actionIndex),
                      size: 16,
                      color: getContrastColor(randomColor),
                    ),
                  )
                : null,
            tailIcon: random.nextBool()
                ? ActionButtonIcon(
                    icon: Icon(
                      getRandomIcon(actionIndex + 1),
                      size: 16,
                      color: getContrastColor(randomColor),
                    ),
                  )
                : null,
            onTap: () {
              // Random action behavior
              final actions = [
                () => ShowCaseWidget.of(context).previous(),
                () => ShowCaseWidget.of(context).next(),
                () => ShowCaseWidget.of(context).dismiss(),
              ];
              actions[random.nextInt(actions.length)]();
            },
          );
        }
      },
    );
  }

  TooltipActionConfig? getEnhancedActionConfig(int index, int totalCount) {
    final random = Random(index);

    // Sometimes return null for variety
    if (random.nextInt(10) == 0) return null;

    // Create a list of valid CrossAxisAlignment values, excluding stretch
    final validCrossAxisAlignments = [
      CrossAxisAlignment.start,
      CrossAxisAlignment.center,
      CrossAxisAlignment.end,
      // CrossAxisAlignment.baseline,
    ];

    return TooltipActionConfig(
      position: TooltipActionPosition
          .values[random.nextInt(TooltipActionPosition.values.length)],
      actionGap: 5 + random.nextDouble() * 25,
      gapBetweenContentAndAction: 5 + random.nextDouble() * 25,
      // Use the validCrossAxisAlignments list to avoid CrossAxisAlignment.stretch
      crossAxisAlignment: validCrossAxisAlignments[
          random.nextInt(validCrossAxisAlignments.length)],
      alignment: MainAxisAlignment
          .values[random.nextInt(MainAxisAlignment.values.length)],
    );
  }

  Color generateEnhancedRandomColor(int index) {
    final random = Random(index);
    final colorIndex = random.nextInt(RandomShowcaseConfig.randomColors.length);
    final baseColor = RandomShowcaseConfig.randomColors[colorIndex];

    // Add some variation to the base color
    final hslColor = HSLColor.fromColor(baseColor);
    final newHue = (hslColor.hue + random.nextDouble() * 60 - 30) % 360;
    final newSaturation =
        (hslColor.saturation + random.nextDouble() * 0.4 - 0.2).clamp(0.0, 1.0);
    final newLightness =
        (hslColor.lightness + random.nextDouble() * 0.3 - 0.15).clamp(0.2, 0.8);

    return HSLColor.fromAHSL(1.0, newHue, newSaturation, newLightness)
        .toColor();
  }

  BorderRadius getRandomBorderRadius(int index) {
    final random = Random(index);
    final radiusIndex =
        random.nextInt(RandomShowcaseConfig.randomBorderRadius.length);
    return RandomShowcaseConfig.randomBorderRadius[radiusIndex];
  }

  String getRandomEmoji(int index) {
    final random = Random(index);
    final emojiIndex = random.nextInt(RandomShowcaseConfig.randomEmojis.length);
    return RandomShowcaseConfig.randomEmojis[emojiIndex];
  }

  String getEnhancedRandomDescription(int index) {
    final random = Random(index);
    final descIndex =
        random.nextInt(RandomShowcaseConfig.randomDescriptions.length);
    final baseDesc = RandomShowcaseConfig.randomDescriptions[descIndex];

    // Add some variation
    final variations = [
      baseDesc,
      '$baseDesc 🎉',
      '⭐ $baseDesc',
      '$baseDesc (Item #$index)',
      'Step ${index + 1}: $baseDesc',
    ];

    return variations[random.nextInt(variations.length)];
  }

  TooltipPosition? getRandomTooltipPosition(int index) {
    final random = Random(index);
    if (random.nextInt(3) == 0) return null; // Sometimes no specific position

    return TooltipPosition
        .values[random.nextInt(TooltipPosition.values.length)];
  }

  ShapeBorder getRandomShapeBorder(int index) {
    final random = Random(index);
    final shapes = [
      const CircleBorder(),
      const RoundedRectangleBorder(),
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(random.nextDouble() * 30)),
      const StadiumBorder(),
      BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(random.nextDouble() * 15)),
    ];

    return shapes[random.nextInt(shapes.length)];
  }

  Gradient getRandomGradient(int index) {
    final random = Random(index);
    final color1 = generateEnhancedRandomColor(index);
    final color2 = generateEnhancedRandomColor(index + 1);
    final color3 = generateEnhancedRandomColor(index + 2);

    if (random.nextBool()) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color1, color2],
        stops: const [0.0, 1.0],
      );
    } else {
      return RadialGradient(
        center: Alignment.center,
        radius: 0.5 + random.nextDouble() * 0.5,
        colors: [color1, color2, color3],
        stops: const [0.0, 0.5, 1.0],
      );
    }
  }

  IconData getRandomIcon(int index) {
    final random = Random(index);
    final icons = [
      Icons.star,
      Icons.favorite,
      Icons.thumb_up,
      Icons.lightbulb,
      Icons.rocket_launch,
      Icons.celebration,
      Icons.pets,
      Icons.face,
      Icons.music_note,
      Icons.palette,
      Icons.camera,
      Icons.games,
      Icons.sports_soccer,
      Icons.local_pizza,
      Icons.coffee,
      Icons.beach_access,
      Icons.airplane_ticket,
      Icons.directions_car,
      Icons.home,
      Icons.work,
      Icons.school,
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.movie,
      Icons.fitness_center,
      Icons.spa,
      Icons.park,
      Icons.nature,
    ];

    return icons[random.nextInt(icons.length)];
  }

  String getRandomActionName(int index) {
    final random = Random(index);
    final names = [
      'Next',
      'Previous',
      'Skip',
      'Done',
      'Continue',
      'Back',
      'Close',
      'Finish',
      'Start',
      'Begin',
      'Explore',
      'Discover',
      'Learn',
      'Try',
      'Test',
      'Demo',
      'Show',
      'Hide',
      'Toggle',
      'Switch',
      'Change',
      'Update',
      'Refresh',
      'Reset',
      'Save',
      'Load',
      'Edit',
      'Delete',
      'Add',
      'Remove',
      'Share',
      'Like',
    ];

    return names[random.nextInt(names.length)];
  }

  Color getContrastColor(Color color) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  void initState() {
    super.initState();
    //Start showcase view after current widget frames are drawn.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase(
          [_firstShowcaseWidget, _two, _three, _four, _lastShowcaseWidget]),
    );
    mails = [
      Mail(
        sender: 'Medium',
        sub: 'Showcase View',
        msg: 'Check new showcase View',
        date: '1 May',
        isUnread: false,
      ),
      Mail(
        sender: 'Quora',
        sub: 'New Question for you',
        msg: 'Hi, There is new question for you',
        date: '2 May',
        isUnread: true,
      ),
      Mail(
        sender: 'Google',
        sub: 'Flutter 1.5',
        msg: 'We have launched Flutter 1.5',
        date: '3 May',
        isUnread: false,
      ),
      Mail(
        sender: 'Github',
        sub: 'Showcase View',
        msg: 'New star on your showcase view.',
        date: '4 May ',
        isUnread: true,
      ),
      Mail(
        sender: 'Simform',
        sub: 'Credit card Plugin',
        msg: 'Check out our credit card plugin',
        date: '5 May',
        isUnread: false,
      ),
      Mail(
        sender: 'Flutter',
        sub: 'Flutter is Future',
        msg: 'Flutter launched for Web',
        date: '6 May',
        isUnread: true,
      ),
      Mail(
        sender: 'Medium',
        sub: 'Showcase View',
        msg: 'Check new showcase View',
        date: '7 May ',
        isUnread: false,
      ),
      Mail(
        sender: 'Simform',
        sub: 'Credit card Plugin',
        msg: 'Check out our credit card plugin',
        date: '8 May',
        isUnread: true,
      ),
      Mail(
        sender: 'Flutter',
        sub: 'Flutter is Future',
        msg: 'Flutter launched for Web',
        date: '9 May',
        isUnread: false,
      ),
    ];
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  late final widgets = RandomShowCaseBuilder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: widgets,
      ),
    );
  }

  GestureDetector showcaseMailTile(GlobalKey<State<StatefulWidget>> key,
      bool showCaseDetail, BuildContext context, Mail mail) {
    return GestureDetector(
      onTap: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const Detail(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Showcase(
          key: key,
          description: 'Tap to check mail',
          disposeOnTap: true,
          onTargetClick: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const Detail(),
              ),
            ).then((_) {
              setState(() {
                ShowCaseWidget.of(context)
                    .startShowCase([_four, _lastShowcaseWidget]);
              });
            });
          },
          tooltipActionConfig: const TooltipActionConfig(
            alignment: MainAxisAlignment.spaceBetween,
            actionGap: 16,
            position: TooltipActionPosition.outside,
            gapBetweenContentAndAction: 16,
          ),
          tooltipActions: [
            TooltipActionButton(
              type: TooltipDefaultActionType.previous,
              name: 'Back',
              onTap: () {
                // Write your code on button tap
                ShowCaseWidget.of(context).previous();
              },
              backgroundColor: Colors.pink.shade50,
              textStyle: const TextStyle(
                color: Colors.pink,
              ),
            ),
            const TooltipActionButton(
              type: TooltipDefaultActionType.skip,
              name: 'Close',
              textStyle: TextStyle(
                color: Colors.white,
              ),
              tailIcon: ActionButtonIcon(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
          child: MailTile(
            mail: mail,
            showCaseKey: _four,
            showCaseDetail: showCaseDetail,
          ),
        ),
      ),
    );
  }
}

class SAvatarExampleChild extends StatelessWidget {
  const SAvatarExampleChild({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xffFCD8DC),
        ),
        child: Center(
          child: Text(
            'S',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class Mail {
  Mail({
    required this.sender,
    required this.sub,
    required this.msg,
    required this.date,
    required this.isUnread,
  });

  String sender;
  String sub;
  String msg;
  String date;
  bool isUnread;
}

class MailTile extends StatelessWidget {
  const MailTile(
      {required this.mail,
      this.showCaseDetail = false,
      this.showCaseKey,
      Key? key})
      : super(key: key);
  final bool showCaseDetail;
  final GlobalKey<State<StatefulWidget>>? showCaseKey;
  final Mail mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 16, top: 8, bottom: 8),
      color: mail.isUnread ? const Color(0xffFFF6F7) : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (showCaseDetail)
                  Showcase.withWidget(
                    key: showCaseKey!,
                    height: 50,
                    width: 150,
                    tooltipActionConfig: const TooltipActionConfig(
                      alignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      actionGap: 16,
                    ),
                    tooltipActions: const [
                      TooltipActionButton(
                        type: TooltipDefaultActionType.previous,
                        name: 'Back',
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TooltipActionButton(
                        type: TooltipDefaultActionType.skip,
                        name: 'Close',
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                    targetShapeBorder: const CircleBorder(),
                    targetBorderRadius: const BorderRadius.all(
                      Radius.circular(150),
                    ),
                    container: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xffFCD8DC),
                            ),
                            child: Center(
                              child: Text(
                                'S',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Your sender's profile",
                          )
                        ],
                      ),
                    ),
                    child: const SAvatarExampleChild(),
                  )
                else
                  const SAvatarExampleChild(),
                const Padding(padding: EdgeInsets.only(left: 8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        mail.sender,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: mail.isUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        mail.sub,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        mail.msg,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: mail.isUnread
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 5,
                ),
                Text(
                  mail.date,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Icon(
                  mail.isUnread ? Icons.star : Icons.star_border,
                  color: mail.isUnread ? const Color(0xffFBC800) : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
