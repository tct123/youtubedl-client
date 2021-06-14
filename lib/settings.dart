import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtubedlclient/prefs.dart';

import 'main.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _convertToMp3 = prefs.getBool(Prefs.convertToMp3Key) ?? false;
  bool? _keepOriginalFile = prefs.getBool(Prefs.keepOriginalFileKey) ?? null;

  List<String> _paths = [];

  String? _selectedPath = prefs.getString(Prefs.downloadPathKey);

  @override
  void initState() {
    super.initState();

    _initPaths();
  }

  void _initPaths() async {
    _paths.add((await getDownloadsDirectory())!.path);
    _paths.add((await getApplicationDocumentsDirectory()).path);

    // _paths = _paths.where((p) => p != null).toList();

    setState(() {});
  }

  // void _save() async {
  //   Navigator.of(context).pop();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download path',
                    style: TextStyle(color: Colors.grey),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Select download path'),
                    menuMaxHeight: MediaQuery.of(context).size.height / 2,
                    items: _paths.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: _selectedPath,
                    onChanged: (p) {
                      setState(() {
                        _selectedPath = p;
                      });

                      prefs.setString(Prefs.downloadPathKey, _selectedPath!);
                    },
                  ),
                ],
              ),
            ),
            CheckboxListTile(
              title: Text('Converter para mp3'),
              value: _convertToMp3,
              onChanged: (n) {
                _convertToMp3 = n!;

                if (!n) {
                  _keepOriginalFile = null;

                  prefs.remove(Prefs.keepOriginalFileKey);
                } else {
                  _keepOriginalFile =
                      prefs.getBool(Prefs.keepOriginalFileKey) ?? true;

                  prefs.setBool(
                    Prefs.keepOriginalFileKey,
                    _keepOriginalFile!,
                  );
                }

                setState(() {});

                prefs.setBool(Prefs.convertToMp3Key, _convertToMp3);
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.red,
            ),
            Opacity(
              opacity: null == _keepOriginalFile ? 0.3 : 1,
              child: IgnorePointer(
                ignoring: null == _keepOriginalFile,
                child: CheckboxListTile(
                  title: Text('Manter arquivo original'),
                  value: _keepOriginalFile,
                  tristate: !_convertToMp3,
                  onChanged: (n) {
                    setState(() {
                      _keepOriginalFile = n;
                    });

                    prefs.setBool(
                      Prefs.keepOriginalFileKey,
                      _keepOriginalFile!,
                    );
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.red,
                ),
              ),
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _save,
      //   tooltip: 'Save settings',
      //   child: Icon(Icons.check),
      // ),
    );
  }
}
