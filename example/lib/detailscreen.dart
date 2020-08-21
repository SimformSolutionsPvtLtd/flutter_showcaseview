import 'package:flutter/material.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:showcaseview/showcaseview.dart';

class Detail extends StatefulWidget {
  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final GlobalKey _one = GlobalKey();
  BuildContext myContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 200),
          () => ShowCaseWidget.of(myContext).startShowCase([_one]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) {
          myContext = context;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  Showcase(
                    key: _one,
                    title: 'Title',
                    description: 'Desc',
                    child: InkWell(
                      onTap: () {},
                      child: Text(
                        'Flutter Notification',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Hi, you have new Notification from flutter group, open slack and check it out',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: Colors.black),
                      children: [
                        TextSpan(text: 'Hi team,\n\n'),
                        TextSpan(
                            text:
                                'As some of you know, we’re moving to Slack for our internal team communications. Slack is a messaging app where we can talk, share files, and work together. It also connects with tools we already use, like [add your examples here], plus 900+ other apps.\n\n'),
                        TextSpan(
                            text: 'Why are we moving to Slack?\n\n',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        TextSpan(
                            text:
                                'We want to use the best communication tools to make our lives easier and be more productive. Having everything in one place will help us work together better and faster, rather than jumping around between emails, IMs, texts and a bunch of other programs. Everything you share in Slack is automatically indexed and archived, creating a searchable archive of all our work.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
