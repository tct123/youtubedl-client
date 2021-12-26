import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtubedlclient/gui.dart';

late SharedPreferences prefs;

Future _getStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    setState(() {
      permissionGranted = true;
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  runApp(YoutubedlApp());
}

class YoutubedlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      showSemanticsDebugger: false,
      title: 'YoutubeDL',
      home: YoutubedlGui(),
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light,
        accentColor: Colors.red,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        accentColor: Colors.red,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
        ),
      ),
    );
  }
}
