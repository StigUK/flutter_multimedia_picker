# flutter_multimedia_picker
Flutter plugin to get All Media.It also allows you to select both images and videos if you wish

## Installation

First, add `flutter_multimedia_picker` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```
flutter_multimedia_picker: ^1.0.3
```

## Usage
You need user permission to access media.
  * ##### For IOS: You must to modify the Info.plist file in Runner project
  ```
 <key>NSPhotoLibraryUsageDescription</key>
 <string>App need your agree, can visit your meida</string>
  ```

  * ##### For Android: You must Add permission to `AndroidManifest.xml`
  ``` 
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  ```

## Example
```
  Future<void> getMedia() async {
    try {
      List<MediaFile> imageMediaFileList = await FlutterMultiMediaPicker.getImage();

      List<MediaFile> videoMediaFileList = await FlutterMultiMediaPicker.getVideo();

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

```

## Credits
Thanks to Kasem SAEED for his awesome [media_picker_builder](https://github.com/KasemJaffer/media_picker_builder) library. It's the core of this library.
