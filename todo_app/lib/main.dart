import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
// In case of error for package, add the dependency in pubspec.yml and run flutter pub get in the terminal.
import 'package:path_provider/path_provider.dart';
import 'listview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Add Text',
        // Start the app with the "/" named route. In this case, the app starts
        // on the FirstScreen widget.
        initialRoute: '/',
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          '/': (context) => MyCustomForm(),
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/second': (context) => ListApp(),
        }
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> with SingleTickerProviderStateMixin {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();
  final storage = FileStorage();
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.lightBlueAccent,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'btn3',
        backgroundColor: Colors.green,
        onPressed: () {
          return showDialog(
            context: context,
            builder: (context) {
              if (myController.text == null || myController.text == "") {
                return AlertDialog(
                  title: Text('Text'),
                  content: Text('No text added!'),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text('OK'),
                      color: Colors.lightBlue,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              } else {
                return AlertDialog(
                  title: Text('Text'),
                  content: Text(myController.text),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text('Save'),
                      color: Colors.green,
                      onPressed: () {
                        storage.writeFile(myController.text);
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              }
            },
          );
        },
        tooltip: 'Add Text',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget launch() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'btn1',
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () {
          Navigator.pushNamed(context, '/second');
        },
        tooltip: 'Switch',
        child: Icon(Icons.launch),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Text'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: myController,
        ),
      ),
      floatingActionButton: buildAnimation(),
    );
  }

  Widget buildAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: add(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: launch(),
        ),
        toggle(),
      ],
    );
  }
}

class FileStorage {
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/Datafile.txt');
  }

  Future<String> readFileAsString() async {
    String contents = "";
    final file = await _localFile;
    if (file.existsSync()) { //Must check or error is thrown
      debugPrint("File exists");
      contents = await file.readAsString();
    }
    return contents;
  }

  Future<Null> writeFile(String text) async {
    final file = await _localFile;

    IOSink sink = file.openWrite(mode: FileMode.append);
    sink.add(utf8.encode('$text\n')); //Use newline as the delimiter
    await sink.flush();
    await sink.close();
  }
}