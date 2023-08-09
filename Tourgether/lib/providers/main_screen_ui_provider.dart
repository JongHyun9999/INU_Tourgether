import 'package:flutter/material.dart';

class MainScreenUIProvider with ChangeNotifier {
  // Post Variables
  bool _istitleEmpty = false;
  bool _isContentEmpty = false;

  bool get isTitleEmpty => _istitleEmpty;
  bool get isContentEmpty => _isContentEmpty;

  // AppBar Variables
  bool _isAppBarVisible = true;
  bool _isUserInteractingWithMap = false;

  bool get isAppBarVisible => _isAppBarVisible;
  bool get isUserInteractingWithMap => _isUserInteractingWithMap;

  set isAppBarVisible(bool isAppBarVisible) =>
      _isAppBarVisible = isAppBarVisible;

  set isUserInteractingWithMap(bool isUserInteractingWithMap) =>
      _isUserInteractingWithMap = isUserInteractingWithMap;

  // InteractiveViewer Variables
  double _currentScaleValue = 1;

  double get currentScaleValue => _currentScaleValue;
  set currentScaleValue(double currentScaleValue) {
    _currentScaleValue = currentScaleValue;
  }

  // Post Methods
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

  // InteractiveViewer Methods
  void changeAppBarsVisibility() {
    print("$isAppBarVisible");

    if (isAppBarVisible == true) {
      isAppBarVisible = false;
    } else if (isAppBarVisible == false) {
      isAppBarVisible = true;
    }

    print("$isAppBarVisible");

    notifyListeners();
    print(
        "--- changeAppBarVisibility() is called on MainScreenUIProvider.\ncurrent isAppBarVisible : $isAppBarVisible");
  }
}
