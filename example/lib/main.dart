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
          // autoPlay: true,
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
    final totalCount = 100;
    final keysList = List.generate(totalCount, (index) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase(keysList),
    );

    final randomShowCase = List.generate(
      totalCount,
      (index) {
        final width = Random()
            .nextInt((MediaQuery.of(context).size.width / 10).toInt())
            .toDouble();
        final height = Random()
            .nextInt((MediaQuery.of(context).size.height / 10).toInt())
            .toDouble();
        return (index % Random().nextInt(100).clamp(1, 100)).isEven
            ? Showcase(
                key: keysList[index],
                description: getRandomString(Random().nextInt(1000)),
                tooltipActions: _generateListOfRandomAction(),
                tooltipActionConfig: getActionConfig(index, totalCount),
                onToolTipClick: () {
                  ShowCaseWidget.of(context).previous();
                },
                tooltipPosition:
                    (index % Random().nextInt(100).clamp(1, 100)).isEven
                        ? null
                        : TooltipPosition.values[index % 2],
                child: Container(
                  color: generateRandomLightColor(),
                  width: Random()
                      .nextInt(MediaQuery.of(context).size.width.toInt() - 30)
                      .toDouble(),
                  height: Random()
                      .nextInt(MediaQuery.of(context).size.width.toInt() - 30)
                      .toDouble(),
                  child: SizedBox(),
                ),
              )
            : Showcase.withWidget(
                width: width,
                height: height,
                key: keysList[index],
                tooltipActions: _generateListOfRandomAction(),
                tooltipActionConfig: getActionConfig(index, totalCount),
                tooltipPosition:
                    (index % Random().nextInt(100).clamp(1, 100)).isEven
                        ? null
                        : TooltipPosition.values[index % 2],
                container: Container(
                  color: Colors.grey,
                  width: width,
                  height: height,
                  child: SizedBox(),
                ),
                child: InkWell(
                  onTap: () {
                    ShowCaseWidget.of(context).previous();
                  },
                  child: Container(
                    color: Color((Random().nextDouble() * 0xFFFFFF).toInt())
                        .withOpacity(1.0),
                    width: Random()
                        .nextInt(MediaQuery.of(context).size.width.toInt() - 30)
                        .toDouble(),
                    height: Random()
                        .nextInt(MediaQuery.of(context).size.width.toInt() - 30)
                        .toDouble(),
                    child: SizedBox(),
                  ),
                ),
              );
      },
    );
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.custom(
        gridDelegate: SliverStairedGridDelegate(
            crossAxisSpacing: 48,
            mainAxisSpacing: 24,
            pattern: List.generate(
                totalCount,
                (index) => StairedGridTile(
                      Random().nextDouble(),
                      Random().nextInt(10).toDouble().clamp(1, 10),
                    ))
            // [
            //   StairedGridTile(0.5, 1),
            //   StairedGridTile(0.5, 3 / 4),
            //   StairedGridTile(1.0, 10 / 4),
            // ],
            ),
        childrenDelegate: SliverChildBuilderDelegate(
          childCount: totalCount,
          (context, index) {
            print(index);
            return randomShowCase[index];
          },
        ),
      ),
    );
  }

  List<TooltipActionButton> _generateListOfRandomAction() {
    return List.generate(
      Random().nextInt(5),
      (index) => (index % Random().nextInt(100).clamp(1, 100)).isEven
          ? TooltipActionButton(
              type: TooltipDefaultActionType.values[index % 3],
              name: getRandomString(50),
            )
          : TooltipActionButton.custom(
              button: Container(
                color: generateRandomLightColor(),
                child: Text(
                  getRandomString(50),
                ),
                width: Random().nextInt(100).toDouble(),
                height: Random().nextInt(100).toDouble(),
              ),
            ),
    );
  }

  TooltipActionConfig? getActionConfig(int index, int totalCount) {
    final data = index % Random().nextInt(totalCount).clamp(1, totalCount) == 0
        ? null
        : TooltipActionConfig(
            position: TooltipActionPosition.values[Random().nextInt(1)],
            actionGap: Random().nextInt(50).toDouble(),
            gapBetweenContentAndAction: Random().nextInt(50).toDouble(),
            crossAxisAlignment: CrossAxisAlignment.values[Random().nextInt(2)],
            alignment: MainAxisAlignment.values[Random().nextInt(5)],
          );
    return data;
  }

  Color generateRandomLightColor() {
    final random = Random();
    final red = random.nextInt(150) + 100;
    final green = random.nextInt(150) + 100;
    final blue = random.nextInt(150) + 100;

    return Color.fromARGB(255, red, green, blue);
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int maxLength) =>
      String.fromCharCodes(Iterable.generate(Random().nextInt(maxLength),
          (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
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
                    width: 140,
                    tooltipActionConfig: const TooltipActionConfig(
                      alignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      actionGap: 16,
                    ),
                    tooltipActions: [
                      const TooltipActionButton(
                        backgroundColor: Colors.transparent,
                        type: TooltipDefaultActionType.previous,
                        padding: EdgeInsets.zero,
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TooltipActionButton.custom(
                        button: InkWell(
                          onTap: () => ShowCaseWidget.of(context).next(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                      width: 140,
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
