class GPSModel {
  double? latitude;
  double? longitude;

  GPSModel(double? latitudeArg, double? longitudeArg) {
    latitude = latitudeArg;
    longitude = longitudeArg;
  }

  // 2023.07.10, jdk
  // 새로운 GPS 데이터로 변경
  void changeGPSData(double? newLatitude, double? newLongtidue) {
    latitude = newLatitude;
    longitude = newLongtidue;
  }

  factory GPSModel.fromData(double latitudeArg, double longitudeArg) {
    return GPSModel(
      latitudeArg,
      longitudeArg,
    );
  }
}
