import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ShowCase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ShowCase(child: MyHomePage(title: 'ShowCase Example')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
  GlobalKey _four = GlobalKey();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCase.startShowCase(context, [_one, _two, _three, _four]));

    return Scaffold(
      appBar: AppBar(
        title: TargetWidget(
          key: _one,
          title: "Title",
          description: "Hey There! I am title of the screen.",
          child: Text(widget.title),
        ),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment(0.2, 0.6),
                child: TargetWidget.withWidget(
                  key: _two,
                  container: Text(
                    'Hello',
                    style: TextStyle(fontSize: 30.0, color: Colors.white),
                  ),
                  child: Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.2, 0.8),
                child: TargetWidget.withWidget(
                  key: _four,
                  container: Text(
                    'Hello',
                    style: TextStyle(fontSize: 30.0, color: Colors.white),
                  ),
                  child: Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
              ),
            ],
          )),
      floatingActionButton: TargetWidget(
        key: _three,
        title: "Tap Me!",
        description: "Tap me and counter will increase.",
        shapeBorder: CircleBorder(),
        child: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
