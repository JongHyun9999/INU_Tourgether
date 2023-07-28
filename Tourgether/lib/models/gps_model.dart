class GPSModel {
  double? latitude;
  double? longitude;
  double? accuracy;

  GPSModel(double? latitudeArg, double? longitudeArg, double? accuracyArg) {
    latitude = latitudeArg;
    longitude = longitudeArg;
    accuracy = accuracyArg;
  }

  // 2023.07.10, jdk
  // 새로운 GPS 데이터로 변경
  void changeGPSData(
      double? newLatitude, double? newLongtidue, double? newAccuracy) {
    latitude = newLatitude;
    longitude = newLongtidue;
    accuracy = newAccuracy;
  }

  factory GPSModel.fromData(
      double latitudeArg, double longitudeArg, double accuracyArg) {
    return GPSModel(latitudeArg, longitudeArg, accuracyArg);
  }
}
