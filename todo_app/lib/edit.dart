import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'model/note.dart';
import 'main.dart';
import 'listview.dart';

class HiveArguments {
  int key;
  HiveArguments(this.key);
}

class EditText extends StatefulWidget {
  @override
  _EditTextState createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  int index;
  static String value;
  @override
  Widget build(BuildContext context){
    final HiveArguments args = ModalRoute.of(context).settings.arguments;
    index = args.key;
    getText(index);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Text', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: myController,
          enableInteractiveSelection: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
                        addText(Note(myController.text));
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
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }
  final myController = TextEditingController(text: '$value');
  void getText(int key){
    final noteBox = Hive.box('notes');
    value = noteBox.getAt(key).title;
  }
  void addText(Note note) {
    final noteBox = Hive.box('notes');
    noteBox.putAt(index, note);
  }
}