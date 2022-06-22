import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_multimedia_picker/data/MediaFile.dart';
import 'GalleryWidget.dart';
import 'MultiSelectorModel.dart';

class PickerWidget extends StatefulWidget {
  final List<MediaFile> mediaFiles;

  PickerWidget(this.mediaFiles, this.onDone, this.onCancel);

  final Function(Set<MediaFile> selectedFiles) onDone;
  final Function() onCancel;

  @override
  State<StatefulWidget> createState() => PickerWidgetState();
}

class PickerWidgetState extends State<PickerWidget> {
  MultiSelectorModel _selector = MultiSelectorModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildWidget();
  }

  _buildWidget() {
    return ChangeNotifierProvider<MultiSelectorModel>(
      builder: (context) => _selector,
      child: Container(
        height: double.infinity,
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 50,
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    textColor: Colors.blue,
                    onPressed: () => widget.onCancel(),
                    child: Text("Cancel"),
                  ),
                ),
                Consumer<MultiSelectorModel>(
                  builder: (context, selector, child) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 60),
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        textColor: Colors.blue,
                        onPressed: () => widget.onDone(_selector.selectedItems),
                        child: Text(
                          "Done (${selector.selectedItems.length})",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            GalleryWidget(mediaFiles: widget.mediaFiles),
          ],
        ),
      ),
    );
  }
}
