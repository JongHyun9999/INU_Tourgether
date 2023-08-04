// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mytourgether/models/gps_model.dart';
import 'package:logger/logger.dart';

// 2023.07.10 jdk
// Provider Pattern에 따라서 GPS 관련 Logic을 처리하는 Provider Class.
// Geolocator 관련 코드를 모두 처리하고, 관련 데이터를 보관한다.
// 데이터를 Publish하고, Subject(Listeners)에게 notifyListeners() 함수를 통해
// 이를 알린다.

class GPSProvider with ChangeNotifier {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  bool _serviceEnabled = false;
  StreamSubscription<Position>? _positionStream;

  // 2023.07.10, jdk
  // 초기에는 GPSModel에 null값을 넣어둔다.
  GPSModel _gpsModel = GPSModel();
  double? get latitude => _gpsModel.latitude;
  double? get longitude => _gpsModel.longitude;
  double? get accuracy => _gpsModel.accuracy;

  // 2023.07.29, jdk
  // 쪽지를 작성할 때 현재 위치를 기록하기 위한 위치 변수
  // 쪽지 작성하기 버튼을 눌렀을 때 현재 위치를 기록한다.
  late double currentLatitudeForLetter;
  late double currentLongitudeForLetter;

  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _streamInterval;
  Duration? get streamInterval => _streamInterval;

  bool _isListeningGPSPositionStream = false;
  bool get isListeningGPSPositionStream => _isListeningGPSPositionStream;

  // 2023.07.12, jdk
  // 현재 이슈 : streamInterval은 Provider에 의해 데이터가 변화된것이 표시되나,
  // gpsModel은 표시되지 않고 있음. 새로운 객체를 넣어보기도 했으나 바뀌지 않음.
  // 내가 모르는 다른 문제가 있는 것으로 생각된다.

  // Geolocator에 사용되는 Setting 값들
  final LocationSettings _locationSettings = const LocationSettings(
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
      logger.d("Location service is not enabled.", time: DateTime.now());
      return;
    }

    // 권한 설정
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        logger.d("Location permission has been denied.", time: DateTime.now());
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.d("Location permission has been denied forever.",
          time: DateTime.now());
      return;
    }

    // GPS Stream Enabled
    _isListeningGPSPositionStream = true;

    // 2023.07.10, jdk
    // GPS 데이터가 들어오는 시간 간격을 측정하기 위해
    // GPS 데이터 요청이 들어간 시각을 기록.
    _startTime = DateTime.now();

    // 2023.07.29, jdk
    // getCurrentPosition and start to get positionStream(GPS Callback).
    Geolocator.getCurrentPosition().then(
      (Position? newPosition) {
        // 2023.07.10, jdk
        // endTime - startTime을 통해
        // 새로운 데이터가 들어온 간격을 체크한다.
        _endTime = DateTime.now();
        _streamInterval = _endTime!.difference(_startTime!);

        if (newPosition != null) {
          _gpsModel.currentPosition = newPosition;

          // 새로운 Position 데이터가 들어왔으므로, 구독자들에게 알려주어야 함.
          notifyListeners();

          // 2023.07.10, jdk
          // 이제 Stream을 통해서 다시 GPS 데이터를 전달받을 것이므로,
          // startTime을 now()로 초기화한다.
          _startTime = DateTime.now();

          // PositionStream을 통해서 계속해서 GPS 데이터를 전달받는다.
          _positionStream =
              Geolocator.getPositionStream(locationSettings: _locationSettings)
                  .listen((Position? newPosition) {
            if (newPosition != null) {
              _endTime = DateTime.now();
              _streamInterval = _endTime!.difference(_startTime!);
              _gpsModel.currentPosition = newPosition;

              logger.d(
                "A new GPS data has arrived\nlatitude : ${_gpsModel.latitude}\nlongitude : ${_gpsModel.longitude}\naccuracy : ${_gpsModel.accuracy}\nstreamInterval : ${streamInterval}",
              );

              notifyListeners();
              _startTime = DateTime.now();
            } else {
              // Stream을 통해 전달받은 새로운 GPS 데이터가 null인 경우.
              // 이후에 적절한 에러 처리가 필요하다.
              logger.e("The GPS stream data is null", time: DateTime.now());
            }
          });
        } else {
          // 2023.07.29, jdk
          // 초기에 전달받은 GPS 데이터가 null인 경우.
          // 이후에 적절한 에러 처리가 필요하다.
          logger.e("The initial GPS data is null", time: DateTime.now());
        }
      },
    ).catchError((error) {
      logger.e(
          "An error occurred on Geolocator.getCurrentPosition() : ${error}",
          time: DateTime.now());
    });
  }

  endGPSCallback() async {
    // GPS Data Stream을 취소한다.
    if (_positionStream != null) {
      _isListeningGPSPositionStream = false;

      logger.d("GPS Stream has been canceled...");
      await _positionStream!.cancel().then((_) {
        _positionStream = null;

        _gpsModel.currentPosition = null;

        _startTime = null;
        _endTime = null;
        _streamInterval = null;

        notifyListeners();
      }).catchError((error) {
        logger.e("An error occurred on endGPSCallback : ${error}",
            time: DateTime.now());
      });
    }
  }
}
