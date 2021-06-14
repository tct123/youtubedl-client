import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:youtubedlclient/main.dart';
import 'package:youtubedlclient/prefs.dart';
import 'download.dart';
import 'settings.dart';

class YoutubedlGui extends StatefulWidget {
  YoutubedlGui({Key? key}) : super(key: key);

  @override
  _YoutubedlGuiState createState() => _YoutubedlGuiState();
}

class _YoutubedlGuiState extends State<YoutubedlGui> {
  final urlInputController = TextEditingController();

  final shell = Shell();

  Future<String> get _tempPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<String> get _finalPath async {
    var path = prefs.getString(Prefs.downloadPathKey);

    if (null == path) {
      path = await _tempPath;
    }

    return '-o $path/"%(title)s.%(ext)s"';
  }

  // Future<String> get _localPath async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   return directory.path;
  // }

  // Future<File> get _localFile async {
  //   final path = await _localPath;
  //   return File('$path/logs.txt');
  // }

  String get keepOriginalFileCommand {
    bool? keepOriginalFile = prefs.getBool(Prefs.keepOriginalFileKey);

    if (null == keepOriginalFile) return '';
    if (!keepOriginalFile) return '';

    return '-k';
  }

  String get convertToMp3Command {
    bool? convertToMp3 = prefs.getBool(Prefs.convertToMp3Key);

    if (null == convertToMp3) return '';
    if (!convertToMp3) return '';

    return '--extract-audio --audio-format mp3';
  }

  List<Download> downloadList = [];

  List<Download> get pendingList => downloadList
      .where((download) => download.status == Status.PENDING)
      .toList();

  List<Download> get downloadingList => downloadList
      .where((download) => download.status == Status.DOWNLOADING)
      .toList();

  List<Download> get finishedList => downloadList
      .where((download) => download.status == Status.FINISHED)
      .toList();

  void _clearListByStatus(Status status) {
    downloadList.removeWhere((download) => download.status == status);
    setState(() {});
  }

  void _openSetings() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Settings(),
      ),
    );
  }

  void _pasteIntoInput() async {
    ClipboardData? clipboardData = await Clipboard.getData(
      Clipboard.kTextPlain,
    );

    if (null != clipboardData && null != clipboardData.text) {
      urlInputController.text = clipboardData.text!;
    }
  }

  void _openAddDialog() async {
    urlInputController.text = '';

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: urlInputController,
            decoration: InputDecoration(
              hintText: 'Paste video url here',
              suffixIcon: IconButton(
                onPressed: _pasteIntoInput,
                icon: Icon(Icons.paste_rounded),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
            TextButton(
              onPressed: () {
                _addVideoToList(urlInputController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeVideoFromList(Download download) {
    downloadList.removeWhere((d) => d == download);
    setState(() {});
  }

  void _addVideoToList(String url) async {
    Download? exists = downloadList.firstWhereOrNull((d) => d.url == url);

    if (exists != null) return;

    var response = await http.read(
      Uri.parse('https://www.youtube.com/oembed?url=$url&format=json'),
    );

    Map<String, dynamic> data = jsonDecode(response);

    setState(() {
      downloadList.add(
        Download(url, Metadata.fromJson(data)),
      );
    });
  }

  void _startDownload() async {
    // print(whichSync('youtube-dl'));
    // print(whichSync('ffmpeg'));
    // print('userHomePath $userHomePath');

    // final file = await _localFile;

    pendingList.forEach((pendingDownload) async {
      // file.writeAsStringSync(
      //   'url: ${pendingDownload.url}\n',
      //   mode: FileMode.writeOnlyAppend,
      // );

      setState(() {
        pendingDownload.status = Status.DOWNLOADING;
      });

      await _processDownload(pendingDownload.url);

      setState(() {
        pendingDownload.status = Status.FINISHED;
      });
    });
  }

  Future<void> _processDownload(String url, [File? file]) async {
    // final tempPath = await _tempPath;
    final finalPath = await _finalPath;

    final fullCommand =
        'youtube-dl $finalPath $convertToMp3Command $keepOriginalFileCommand $url';

    print('fullCommand $fullCommand');

    List<ProcessResult> results = await shell.run(
      fullCommand,
      onProcess: (Process process) {},
    );

    if (null != file) {
      // log results to file
    }

    // results.forEach((result) {
    //   file.writeAsStringSync(
    //     'errLines: ${result.errLines}\n',
    //     mode: FileMode.writeOnlyAppend,
    //   );
    //   file.writeAsStringSync(
    //     'errText: ${result.errText}\n',
    //     mode: FileMode.writeOnlyAppend,
    //   );
    //   file.writeAsStringSync(
    //     'exitCode: ${result.exitCode}\n',
    //     mode: FileMode.writeOnlyAppend,
    //   );
    //   file.writeAsStringSync(
    //     'outLines: ${result.outLines}\n',
    //     mode: FileMode.writeOnlyAppend,
    //   );
    //   file.writeAsStringSync(
    //     'outText: ${result.outText}\n',
    //     mode: FileMode.writeOnlyAppend,
    //   );
    //   file.writeAsStringSync(
    //     'pid: ${result.pid}\n',
    //     mode: FileMode.writeOnlyAppend,
    //   );
    //   file.writeAsStringSync(
    //     'stderr: ${result.stderr}\n',
    //     mode: FileMode.writeOnlyAppend,
    //   );
    //   file.writeAsStringSync(
    //     'stdout: ${result.stdout}\n',
    //     mode: FileMode.writeOnlyAppend,
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Youtubedl GUI'),
        actions: [
          IconButton(
            onPressed: _openSetings,
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 3,
                  padding: EdgeInsets.all(12),
                  color: Colors.red.shade700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PENDING',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _clearListByStatus(Status.PENDING);
                        },
                        icon: Icon(Icons.clear_all),
                        color: Colors.white,
                        iconSize: 20,
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: pendingList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(
                        top: index == 0 ? 0 : 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Tooltip(
                              message: pendingList[index].url,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(8, 8, 4, 8),
                                child: Text(
                                  pendingList[index].metadata.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton(
                              onPressed: () {
                                _removeVideoFromList(pendingList[index]);
                              },
                              icon: Icon(Icons.clear_rounded),
                              iconSize: 18,
                              constraints: BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Colors.red),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 3,
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  color: Colors.red.shade700,
                  child: Center(
                    child: Text(
                      'DOWNLOADING',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: downloadingList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        downloadingList[index].metadata.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 3,
                  padding: EdgeInsets.all(12),
                  color: Colors.red.shade700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FINISHED',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _clearListByStatus(Status.FINISHED);
                        },
                        icon: Icon(Icons.clear_all),
                        iconSize: 20,
                        color: Colors.white,
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: finishedList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        finishedList[index].metadata.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add list button tag',
            onPressed: _openAddDialog,
            tooltip: 'Add video to list',
            child: Icon(Icons.add),
          ),
          SizedBox(width: 15),
          FloatingActionButton(
            heroTag: 'start download button tag',
            onPressed: _startDownload,
            tooltip: 'Start download',
            child: Icon(Icons.download),
          ),
        ],
      ),
    );
  }
}
