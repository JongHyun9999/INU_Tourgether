import 'package:TourGather/models/gps_model.dart';
import 'package:flutter/material.dart';

class GPSUIProvider with ChangeNotifier {
  GPSModel? _gpsModel = null;
  double? get latitude => _gpsModel?.latitude;
  double? get longitude => _gpsModel?.longitude;
  double? get accuracy => _gpsModel?.accuracy;
}
