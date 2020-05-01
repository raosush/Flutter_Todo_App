import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/edit.dart';
import 'package:todoapp/model/note.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';

class MyAppListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Add Text',
        home: FutureBuilder(
          future: Hive.openBox('notes'),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError)
                return Text(snapshot.error.toString());
              else
                return ListApp();
            }
            // Although opening a Box takes a very short time,
            // we still need to return something before the Future completes.
            else
              return Scaffold();
          },
        ),
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      //'/': (context) => MyCustomForm(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      'home': (context) => MyApp(),
      'home/third': (context) => EditText(),
    }
    );
  }
}

class ListApp extends StatefulWidget {
  @override
  _ListAppState createState() => _ListAppState();
}

class _ListAppState extends State<ListApp> with SingleTickerProviderStateMixin{
  String _timeString;
  var box;

  void loadBox() async {
    box = await Hive.openBox('notes');
  }

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  //can not make initState() async, so calling this function asynchronously
 /* _loadFile() async {
    final String readLines = await storage.readFileAsString();
    debugPrint("readLines: $readLines");
    setState(() {
      lines = readLines.split('\n'); //Escape the new line
    });
  } */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_timeString'),
        backgroundColor: Colors.teal,
      ),
      body: buildList(),
     /* floatingActionButton: FloatingActionButton(
        heroTag: 'btn_ListApp',
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
        onPressed: () {
          if (curIndex < lines.length && lines[curIndex] != "") {
            data.add(lines[curIndex]);
            curIndex++;
            setState(() {});
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Alert'),
                    content: Text('End of list!'),
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
                });
          }
        },
      ), */
     floatingActionButton: FloatingActionButton(
       tooltip: 'Go Back',
       child: Icon(Icons.arrow_back),
       onPressed: () {
         Navigator.pushNamed(context, 'home');
       },
     ),
    );
  }

  Widget buildList() {
    return ValueListenableBuilder(
        valueListenable: Hive.box('notes').listenable(),
        builder: (context, Box notes, _) {
          debugPrint('Adding Item to ListView');
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes.getAt(index);
            return ListTile(
              title: Text(notes.getAt(index).title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      Navigator.pushNamed(context, 'home/third', arguments: HiveArguments(index));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => notes.deleteAt(index),
                  ),
                ],
              ),
            );
          });
    });
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    try {
      // To handle "setState() Called before dispose()" exception.
      if (this.mounted){
        setState(() {
          _timeString = formattedDateTime;
        });
      }
    } catch(e){
      debugPrint(e);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy hh:mm:ss').format(dateTime);
  }
}