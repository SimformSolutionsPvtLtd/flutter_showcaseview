import 'dart:developer';

import 'package:example/detailscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showcaseview/showcaseview.dart';

void main() => runApp(const MyApp());

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
          builder: Builder(builder: (context) => const MailPage()),
          autoPlayDelay: const Duration(seconds: 3),
        ),
      ),
    );
  }
}

class MailPage extends StatefulWidget {
  const MailPage({Key? key}) : super(key: key);

  @override
  _MailPageState createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  List<Mail> mails = [];

  @override
  void initState() {
    super.initState();
    //Start showcase view after current widget frames are drawn.
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context)!
          .startShowCase([_one, _two, _three, _four, _five]),
    );
    mails = [
      Mail(
        sender: 'Medium',
        sub: 'Showcase View',
        msg: 'Check new showcase View',
        date: '25 May',
        isUnread: false,
      ),
      Mail(
        sender: 'Quora',
        sub: 'New Question for you',
        msg: 'Hi, There is new question for you',
        date: '22 May',
        isUnread: false,
      ),
      Mail(
        sender: 'Google',
        sub: 'Flutter 1.5',
        msg: 'We have launched Flutter 1.5',
        date: '20 May',
        isUnread: true,
      ),
      Mail(
        sender: 'Github',
        sub: 'Showcase View',
        msg: 'New star on your showcase view.',
        date: '21 May ',
        isUnread: false,
      ),
      Mail(
        sender: 'Simform',
        sub: 'Credit card Plugin',
        msg: 'Check out our credit card plugin',
        date: '19 May',
        isUnread: true,
      ),
      Mail(
        sender: 'Flutter',
        sub: 'Flutter is Future',
        msg: 'Flutter laucnhed for Web',
        date: '18 Jun',
        isUnread: true,
      ),
      Mail(
        sender: 'Medium',
        sub: 'Showcase View',
        msg: 'Check new showcase View',
        date: '21 May ',
        isUnread: false,
      ),
      Mail(
        sender: 'Simform',
        sub: 'Credit card Plugin',
        msg: 'Check out our credit card plugin',
        date: '19 May',
        isUnread: true,
      ),
      Mail(
        sender: 'Flutter',
        sub: 'Flutter is Future',
        msg: 'Flutter laucnhed for Web',
        date: '18 Jun',
        isUnread: true,
      ),
    ];
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
                                      key: _one,
                                      description: 'Tap to see menu options',
                                      child: Icon(
                                        Icons.menu,
                                        color: Theme.of(context).primaryColor,
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
                      overlayPadding: const EdgeInsets.all(5),
                      key: _two,
                      title: 'Profile',
                      description:
                          "Tap to see profile which contains user's name, profile picture, mobile number and country",
                      showcaseBackgroundColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      shapeBorder: const CircleBorder(),
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
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return showcaseMailTile(context);
                  }
                  return MailTile(mails[index % mails.length]);
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Showcase(
        key: _five,
        title: 'Compose Mail',
        description: 'Click here to compose mail',
        shapeBorder: const CircleBorder(),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
              ShowCaseWidget.of(context)!
                  .startShowCase([_one, _two, _three, _four, _five]);
            });
          },
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }

  GestureDetector showcaseMailTile(BuildContext context) {
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
          key: _three,
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
                ShowCaseWidget.of(context)!.startShowCase([_four, _five]);
              });
            });
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 6, right: 16, top: 5, bottom: 5),
            color: const Color(0xffFFF6F7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Showcase.withWidget(
                        key: _four,
                        height: 50,
                        width: 140,
                        shapeBorder: const CircleBorder(),
                        radius: const BorderRadius.all(Radius.circular(150)),
                        container: Column(
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
                              "Your sender's profile ",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                        child: Container(
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
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 8)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Slack',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const Text(
                            'Flutter Notification',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Hi, you have new Notification',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '1 Jun',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Icon(
                        Icons.star,
                        color: Color(0xffFBC800),
                      )
                    ],
                  ),
                ),
              ],
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
  const MailTile(this.mail, {Key? key}) : super(key: key);

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
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffFCD8DC),
                  ),
                  child: Center(
                    child: Text(
                      mail.sender[0],
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
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
