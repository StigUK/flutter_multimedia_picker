import 'package:flutter/material.dart';
import 'package:flutter_multimedia_picker/data/MediaFile.dart';

import 'GalleryWidgetItem.dart';

class GalleryWidget extends StatefulWidget {
  final List<MediaFile> mediaFiles;

  GalleryWidget({@required this.mediaFiles});

  @override
  State<StatefulWidget> createState() => GalleryWidgetState();
}

class GalleryWidgetState extends State<GalleryWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: widget.mediaFiles.isEmpty
          ? Center(child: Text("Empty Folder"))
          : GridView.builder(
              padding: EdgeInsets.all(0),
              itemCount: widget.mediaFiles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemBuilder: (BuildContext context, int index) {
                return GalleryWidgetItem(mediaFile: widget.mediaFiles[index]);
              }),
    );
  }
}
