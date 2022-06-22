import 'package:flutter/material.dart';
import 'package:flutter_multimedia_picker/data/MediaFile.dart';

class MultiSelectorModel extends ChangeNotifier {
  Set<MediaFile> _selectedItems = Set();

  void toggle(MediaFile file) {
    if (_selectedItems.contains(file)) {
      _selectedItems.remove(file);
    } else {
      _selectedItems.add(file);
    }
    notifyListeners();
  }

  bool isSelected(MediaFile file) {
    return _selectedItems.contains(file);
  }

  Set<MediaFile> get selectedItems => _selectedItems;
}
