import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_multimedia_picker/fullter_multimedia_picker.dart';
import 'package:flutter_multimedia_picker/data/MediaFile.dart';
import 'package:flutter_multimedia_picker/widget/PickerWidget.dart';
import 'package:permission_handler/permission_handler.dart';

void main() =>
    runApp(MaterialApp(
      title: "App",
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String selectText = "";

  @override
  void initState() {
    super.initState();

    _checkPermission().then((granted) {
      if (!granted) return;
    });
  }

  Future<bool> _checkPermission() async {
    final permissionStorageGroup =
    Platform.isIOS ? PermissionGroup.photos : PermissionGroup.storage;
    Map<PermissionGroup, PermissionStatus> res =
    await PermissionHandler().requestPermissions([
      permissionStorageGroup,
    ]);
    return res[permissionStorageGroup] == PermissionStatus.granted;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getMedia() async {
    try {
      List<MediaFile> imageMediaFileList =
      await FlutterMultiMediaPicker.getImage();

      List<MediaFile> videoMediaFileList =
      await FlutterMultiMediaPicker.getVideo();

      List<MediaFile> allMediaFileList = await FlutterMultiMediaPicker.getAll();

      if (imageMediaFileList.length > 0) {
        MediaFile imageMedia = await FlutterMultiMediaPicker.getMediaFile(
            fileId: imageMediaFileList[0].id, type: MediaType.IMAGE);
      }

      if (videoMediaFileList.length > 0) {
        MediaFile videoMedia = await FlutterMultiMediaPicker.getMediaFile(
            fileId: videoMediaFileList[0].id, type: MediaType.VIDEO);
      }

      if (imageMediaFileList.length > 0) {
        String imageMedia = await FlutterMultiMediaPicker.getThumbnail(
            fileId: imageMediaFileList[0].id, type: MediaType.IMAGE);
      }

      if (videoMediaFileList.length > 0) {
        String videoMedia = await FlutterMultiMediaPicker.getThumbnail(
            fileId: videoMediaFileList[0].id, type: MediaType.VIDEO);
      }
    } on Exception {
      print("Exception");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
                child: const Text("Show All Media"),
                onPressed: () {
                  FlutterMultiMediaPicker.getAll().then((mediaFiles) {
                    //print(mediaFiles);
                    _awaitReturnValueFromSecondScreen(context, mediaFiles);
                  });
                }),
            RaisedButton(
                child: const Text("Show Image Media"),
                onPressed: () {
                  FlutterMultiMediaPicker.getImage().then((mediaFiles) {
                    //print(mediaFiles);
                    _awaitReturnValueFromSecondScreen(context, mediaFiles);
                  });
                }),
            RaisedButton(
                child: const Text("Show Video Media"),
                onPressed: () {
                  FlutterMultiMediaPicker.getVideo().then((mediaFiles) {
                    //print(mediaFiles);
                    _awaitReturnValueFromSecondScreen(context, mediaFiles);
                  });
                }),
            Text("$selectText")
          ],
        ),
      ),
    );
  }

  void _awaitReturnValueFromSecondScreen(BuildContext context,
      List<MediaFile> mediaFiles) async {
    // start the SecondScreen and wait for it to finish with a result
    Set<MediaFile> result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickerScreen(mediaFiles),
        ));

    // after the SecondScreen result comes back update the Text widget with it

    if (result == null) {
      return;
    }

    setState(() {
      int size = result.length;
      selectText = "Selected Media Size $size";
    });
  }
}


class PickerScreen extends StatefulWidget {

  List<MediaFile> mediaFiles;

  PickerScreen(this.mediaFiles);

  @override
  _PickerScreenState createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Media Picker"),
        ),
        body: Center(
          child: PickerWidget(widget.mediaFiles, onDone, onCancel),
        ));
  }

  onDone(Set<MediaFile> selectedFiles) {
    Navigator.pop(context, selectedFiles);
  }

  onCancel() {
    Navigator.pop(context);
  }

}
