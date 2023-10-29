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
  double _currentMapPositionX = 0;
  double _currentMapPositionY = 0;

  double get currentScaleValue => _currentScaleValue;
  double get currentMapPositionX => _currentMapPositionX;
  double get currentMapPositionY => _currentMapPositionY;

  set currentScaleValue(double currentScaleValue) =>
      _currentScaleValue = currentScaleValue;
  set currentMapPositionX(double currentMapPositionX) => _currentMapPositionX;
  set currentMapPositionY(double currentMapPositionY) => _currentMapPositionY;

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

    isAppBarVisible = !isAppBarVisible;

    notifyListeners();
  }

  // void changeCurrentScaleValue(double newScaleValue) {
  //   _currentScaleValue = newScaleValue;
  // }

  // void compareNewScaleValueWithPrev(double newScaleValue) {
  //   // Scale 값이 다르다면 새로운 Scale 값으로 currentScaleValue를 지정한다.
  //   if (_currentScaleValue != newScaleValue) {
  //     print("scale value is changed");
  //     print("prev : ${_currentScaleValue}");
  //     _currentScaleValue = newScaleValue;
  //     print("new : ${newScaleValue}");
  //     notifyListeners();
  //   }
  // }

  // void changeMapPosition(double newMapPositionX, double newMapPositionY) {
  //   _currentMapPositionX = newMapPositionX;
  //   _currentMapPositionY = newMapPositionY;
  // }

  // // 새로운 Position이 이전의 Position과 같은지 비교하는 함수.
  // bool compareNewPositionWithPrev(
  //   double newMapPositionX,
  //   double newMapPositionY,
  // ) {
  //   print("newPosX : ${newMapPositionX}");
  //   print("newPosY : ${newMapPositionY}");

  //   print("currentPosX : ${currentMapPositionX}");
  //   print("currentPosY : ${currentMapPositionY}");

  //   bool isEqual = (_currentMapPositionX == newMapPositionX) &&
  //       (_currentMapPositionY == newMapPositionY);

  //   print("isEqual : $isEqual");

  //   return isEqual;
  // }
}
