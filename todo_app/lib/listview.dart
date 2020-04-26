import 'dart:async';

import 'package:flutter/material.dart';
import 'main.dart';
import 'package:intl/intl.dart';

class ListApp extends StatefulWidget {
  @override
  _ListAppState createState() => _ListAppState();
}

class _ListAppState extends State<ListApp> with SingleTickerProviderStateMixin{
  List<String> lines = [];
  final storage = new FileStorage();
  String _timeString;

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
    _loadFile();
  }

  //can not make initState() async, so calling this function asynchronously
  _loadFile() async {
    final String readLines = await storage.readFileAsString();
    debugPrint("readLines: $readLines");
    setState(() {
      lines = readLines.split('\n'); //Escape the new line
    });
  }
  List<String> data = List<String>();
  int curIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_timeString'),
        backgroundColor: Colors.teal,
      ),
      body: buildList(),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }

  Widget buildList() {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.deepPurpleAccent,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(data[index], style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
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