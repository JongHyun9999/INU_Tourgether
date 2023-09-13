import 'package:geolocator/geolocator.dart';

class GPSModel {
  Position? _currentPosition;

  // 2023.07.29, jdk
  // null safety 연산자 ?를 사용하여 null일 경우 null을 return한다.
  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;
  double? get accuracy => _currentPosition?.accuracy;
  Position? get currentPosition => _currentPosition;

  set currentPosition(Position? position) => _currentPosition = position;
}
