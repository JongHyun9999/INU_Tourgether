// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tourgether/models/gps_model.dart';

// 2023.07.10 jdk
// Provider Pattern에 따라서 GPS 관련 Logic을 처리하는 Provider Class.
// Geolocator 관련 코드를 모두 처리하고, 관련 데이터를 보관한다.
// 데이터를 Publish하고, Subject(Listeners)에게 notifyListeners() 함수를 통해
// 이를 알린다.
class GPSProvider with ChangeNotifier {
  // 2023.07.10, jdk
  // 초기에는 GPSModel에 null값을 넣어둔다.
  GPSModel gpsModel = GPSModel(null, null, null);
  Position? currentPosition;

  DateTime? startTime;
  DateTime? endTime;

  // 2023.07.12, jdk
  // 현재 이슈 : streamInterval은 Provider에 의해 데이터가 변화된것이 표시되나,
  // gpsModel은 표시되지 않고 있음. 새로운 객체를 넣어보기도 했으나 바뀌지 않음.
  // 내가 모르는 다른 문제가 있는 것으로 생각된다.
  Duration? streamInterval;
  double? latitude;
  double? longitude;
  double? accuracy;

  bool _serviceEnabled = false;
  StreamSubscription<Position>? _positionStream;

  // Geolocator에 사용되는 Setting 값들
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
  );

  // 2023.07.10, jdk
  startGPSCallback() async {
    LocationPermission? permission;

    // LocationService 사용 가능 여부 확인
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // 2023.07.10, jdk
    // LocationService가 사용 불가능함.
    // 에러 메시지 확인 필요.
    // 이후에는 앱 초기에 데이터를 initialize 하는 과정에서
    // 모든 권한 설정이 되도록 코드 수정이 필요함.
    if (!_serviceEnabled) {
      print("LocationService가 disable 되어있음.");
      return;
    }

    // 권한 설정
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print("권한 재설정 실패.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("권한 설정이 영구히 거부됨.");
      return;
    }

    // 2023.07.10, jdk
    // GPS 데이터가 들어오는 시간 간격을 측정하기 위해
    // GPS 데이터 요청이 들어간 시각을 기록.
    startTime = DateTime.now();

    Geolocator.getCurrentPosition().then(
      (Position? newPosition) {
        // 2023.07.10, jdk
        // 새로운 데이터가 들어왔으므로,
        // 들어오는데 걸린 시각을 기록한다.
        endTime = DateTime.now();
        streamInterval = endTime!.difference(startTime!);

        if (newPosition != null) {
          currentPosition = newPosition;

          // newPosition이 null이 아니기 때문에,
          // currentPosition은 null이 아님.
          // Null Reference Exeception이 일어나지 않으므로
          // non-null assertion operator '!' 추가.
          gpsModel.changeGPSData(
            currentPosition!.latitude,
            currentPosition!.longitude,
            currentPosition!.accuracy,
          );

          latitude = currentPosition!.latitude;
          longitude = currentPosition!.longitude;
          accuracy = currentPosition!.accuracy;

          // 새로운 Position 데이터가 들어왔으므로, 구독자들에게 알려주어야 함.
          notifyListeners();

          // 2023.07.10, jdk
          // 이제 Stream을 통해서 다시 GPS 데이터를 전달받을 것이므로,
          // startTime을 now()로 초기화한다.
          startTime = DateTime.now();

          // PositionStream을 통해서 계속해서 GPS 데이터를 전달받는다.
          _positionStream =
              Geolocator.getPositionStream(locationSettings: locationSettings)
                  .listen(
            (Position? newPosition) {
              if (newPosition != null) {
                endTime = DateTime.now();
                streamInterval = endTime!.difference(startTime!);

                currentPosition = newPosition;

                print("A new GPS data has arrived");
                print("new latitude : ${currentPosition!.latitude}");
                print("new latitude : ${currentPosition!.longitude}");
                print("Accuracy : ${currentPosition!.accuracy}");

                latitude = currentPosition!.latitude;
                longitude = currentPosition!.longitude;
                accuracy = currentPosition!.accuracy;

                notifyListeners();
                startTime = DateTime.now();
              } else {
                // 전달받은 초기 GPS 데이터가 null인 경우.
                // 이후에 적절한 에러 처리가 필요하다.
              }
            },
          );
        } else {
          // Stream을 통해 전달받은 새로운 GPS 데이터가 null인 경우.
          // 이후에 적절한 에러 처리가 필요하다.
        }
      },
    ).catchError((error) {
      print("Geolocator.getCurrentPosition() 에서 Error 발생. ${error.toString()}");
    });
  }

  endGPSCallback() async {
    // GPS Data Stream을 취소한다.
    if (_positionStream != null) {
      print("GPS Stream has been canceled...");
      await _positionStream!.cancel();
      _positionStream = null;

      gpsModel.changeGPSData(null, null, null);

      startTime = null;
      endTime = null;
      streamInterval = null;

      latitude = null;
      longitude = null;
      accuracy = null;

      notifyListeners();
    }
  }
}
