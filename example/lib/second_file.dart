import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Showcase demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: ShowCase(
//         child: MyHomePage(),
//       ),
//     );
//   }
// }

class MailPage extends StatefulWidget {
  @override
  _MailPageState createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
  GlobalKey _four = GlobalKey();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCase.startShowCase(context, [_one, _two, _three, _four]));
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      elevation: 3.0,
                      child: Container(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  TargetWidget(
                                    key: _one,
                                    title: 'Menu',
                                    description:
                                        'Click here to see menu options',
                                    child: Icon(
                                      Icons.menu,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    'Search email',
                                    style: TextStyle(
                                        color: Colors.black45, fontSize: 20.0),
                                  ),
                                ],
                              ),
                            ),
                            TargetWidget(
                              key: _two,
                              title: 'Profile',
                              description: 'Click here to go to your Profile',
                              shapeBorder: CircleBorder(),
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new AssetImage('assets/simform.png'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 7.0,
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        'PRIMARY',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: TargetWidget(
                      key: _three,
                      title: 'Mail',
                      description: 'Click here to check mail',
                      child: MailTile(
                        Mail(
                            sender: 'Slack',
                            sub: 'Flutter Notification',
                            msg: 'Hi, you have new Notification',
                            date: '1 Jun',
                            isUnread: true),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: MailTile(
                      Mail(
                          sender: 'Medium',
                          sub: 'Showcase View',
                          msg: 'Check new showcase View',
                          date: '25 May',
                          isUnread: false),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: MailTile(
                      Mail(
                          sender: 'Quora',
                          sub: 'New Question for you',
                          msg: 'Hi, There is new question for you',
                          date: '22 May',
                          isUnread: false),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: MailTile(
                      Mail(
                          sender: 'Google',
                          sub: 'Flutter 1.5',
                          msg: 'We have launched Flutter 1.5',
                          date: '20 May',
                          isUnread: true),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: MailTile(
                      Mail(
                          sender: 'Simfom',
                          sub: 'Credit card Plugin',
                          msg: 'Check out our credit card plugin',
                          date: '19 May',
                          isUnread: true),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: MailTile(
                      Mail(
                          sender: 'Flutter',
                          sub: 'Flutter is Future',
                          msg: 'Flutter laucnhed for Web',
                          date: '18 Jun',
                          isUnread: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: TargetWidget(
        key: _four,
        title: 'Compose Mail',
        description: 'Click here to compose mail',
        shapeBorder: CircleBorder(),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            setState(() {});
          },
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class Mail {
  String sender;
  String sub;
  String msg;
  String date;
  bool isUnread;
  Mail({this.sender, this.sub, this.msg, this.date, this.isUnread});
}

class MailTile extends StatelessWidget {
  final Mail mail;

  MailTile(this.mail);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                width: 40.0,
                height: 40.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle, color: Colors.blue[200]),
                child: Center(
                  child: Text(mail.sender[0]),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    mail.sender,
                    style: TextStyle(
                        fontWeight:
                            mail.isUnread ? FontWeight.bold : FontWeight.normal,
                        fontSize: 17.0),
                  ),
                  Text(
                    mail.sub,
                    style: TextStyle(
                        fontWeight:
                            mail.isUnread ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16.0),
                  ),
                  Text(
                    mail.msg,
                    style: TextStyle(
                        fontWeight:
                            mail.isUnread ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15.0),
                  )
                ],
              )
            ],
          ),
        ),
        Column(
          children: <Widget>[
            Text(
              mail.date,
              style: TextStyle(
                fontWeight: mail.isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Icon(
              Icons.star_border,
              color: Colors.grey,
            )
          ],
        )
      ],
    );
  }
}
