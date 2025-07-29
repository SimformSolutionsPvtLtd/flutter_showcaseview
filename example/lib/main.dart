import 'dart:developer';

import 'package:example/detailscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';

part '_mails.dart';

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
      home: const MailPage(),
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

  @override
  void initState() {
    super.initState();
    // Register the showcase view
    // This is alternative of ShowCaseWidget register all the configuration here which are in ShowCaseWidget.
    // if we don't register the ShowcaseView then showcase functionality will not work.
    ShowcaseView.register(
      hideFloatingActionWidgetForShowcase: [_lastShowcaseWidget],
      progressIndicatorConfig: const ProgressIndicatorConfig(
        enabled: true,
        position: ProgressIndicatorPosition.top,
        backgroundColor: Color(0xffEE5366),
        progressColor: Colors.white,
        showStepNumbers: true,
        showProgressBar: true,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 3.0,
      ),
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        left: 16,
        bottom: 16,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => ShowcaseView.get().dismiss(),
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
        log('onStart: $index, $key');
      },
      onComplete: (index, key) {
        log('onComplete: $index, $key');
        if (index == 4) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.white,
            ),
          );
        }
      },
      blurValue: 1,
      autoPlayDelay: const Duration(seconds: 3),
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
    );
    //Start showcase view after current widget frames are drawn.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowcaseView.get().startShowCase(
        [_firstShowcaseWidget, _two, _three, _four, _lastShowcaseWidget],
      ),
    );
    mails = _mails;
  }

  @override
  void dispose() {
    scrollController.dispose();
    // Unregister the showcase view when the widget is disposed
    ShowcaseView.get().unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 10, right: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xffF9F9F9),
                            border: Border.all(
                              color: const Color(0xffF3F3F3),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    Showcase(
                                      key: _firstShowcaseWidget,
                                      description: 'Tap to see menu options',
                                      onBarrierClick: () {
                                        debugPrint('Barrier clicked');
                                        debugPrint(
                                          'Floating Action widget for first '
                                          'showcase is now hidden',
                                        );
                                        ShowcaseView.get()
                                            .hideFloatingActionWidgetForKeys([
                                          _firstShowcaseWidget,
                                          _lastShowcaseWidget
                                        ]);
                                      },
                                      tooltipActionConfig:
                                          const TooltipActionConfig(
                                        alignment: MainAxisAlignment.end,
                                        position: TooltipActionPosition.outside,
                                        gapBetweenContentAndAction: 10,
                                      ),
                                      child: GestureDetector(
                                        onTap: () =>
                                            debugPrint('menu button clicked'),
                                        child: Icon(
                                          Icons.menu,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      'Search email',
                                      style: TextStyle(
                                        color: Colors.black45,
                                        fontSize: 16,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.search,
                                      color: Color(0xffADADAD),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Showcase(
                      targetPadding: const EdgeInsets.all(5),
                      key: _two,
                      title: 'Profile',
                      description:
                          "Tap to see profile which contains user's name, profile picture, mobile number and country",
                      tooltipBackgroundColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      floatingActionWidget: FloatingActionWidget(
                        left: 16,
                        bottom: 16,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffEE5366),
                            ),
                            onPressed: ShowcaseView.get().dismiss,
                            child: const Text(
                              'Close Showcase',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      targetShapeBorder: const CircleBorder(),
                      tooltipActionConfig: const TooltipActionConfig(
                        alignment: MainAxisAlignment.spaceBetween,
                        gapBetweenContentAndAction: 10,
                        position: TooltipActionPosition.outside,
                      ),
                      tooltipActions: const [
                        TooltipActionButton(
                          backgroundColor: Colors.transparent,
                          type: TooltipDefaultActionType.previous,
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          textStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TooltipActionButton(
                          type: TooltipDefaultActionType.next,
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Image.asset('assets/simform.png'),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: const Text(
                    'PRIMARY',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 8)),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return showcaseMailTile(_three, true, context, mails.first);
                  }
                  return MailTile(
                    mail: mails[index % mails.length],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Showcase(
        key: _lastShowcaseWidget,
        title: 'Compose Mail',
        description: 'Click here to compose mail',
        targetBorderRadius: const BorderRadius.all(Radius.circular(16)),
        showArrow: false,
        tooltipActions: [
          TooltipActionButton(
              type: TooltipDefaultActionType.previous,
              name: 'Back',
              onTap: () {
                // Write your code on button tap
                ShowcaseView.get().previous();
              },
              backgroundColor: Colors.pink.shade50,
              textStyle: const TextStyle(
                color: Colors.pink,
              )),
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
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
              /* reset ListView to ensure that the showcased widgets are
               * currently rendered so the showcased keys are available in the
               * render tree. */
              scrollController.jumpTo(0);
              ShowcaseView.get().startShowCase([
                _firstShowcaseWidget,
                _two,
                _three,
                _four,
                _lastShowcaseWidget
              ]);
            });
          },
          child: const Icon(
            Icons.add,
          ),
        ),
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
              // First we need to unregister the details screen showcase
              // as get method will use the latest registered scopes
              ShowcaseView.getNamed("_detailsScreen").unregister();

              // Then we need to start the main screen showcase
              ShowcaseView.get().startShowCase(
                [_four, _lastShowcaseWidget],
              );
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
                ShowcaseView.get().previous();
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
