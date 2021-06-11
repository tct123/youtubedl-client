import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void _save() async {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        tooltip: 'Save settings',
        child: Icon(Icons.check),
      ),
    );
  }
}
