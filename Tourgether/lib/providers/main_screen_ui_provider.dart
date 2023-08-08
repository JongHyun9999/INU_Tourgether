import 'package:flutter/material.dart';

class MainScreenUIProvider with ChangeNotifier {
  bool _istitleEmpty = false;
  bool _isContentEmpty = false;

  bool get isTitleEmpty => _istitleEmpty;
  bool get isContentEmpty => _isContentEmpty;

  void detectEmptyTextField(bool isTitleEmpty, bool isContentEmpty) {
    if (isTitleEmpty == true) {
      _istitleEmpty = true;
    }

    if (isContentEmpty == true) {
      _isContentEmpty = true;
    }

    notifyListeners();
  }

  void onPostDialogClosed() {
    _istitleEmpty = false;
    _isContentEmpty = false;
  }
}
