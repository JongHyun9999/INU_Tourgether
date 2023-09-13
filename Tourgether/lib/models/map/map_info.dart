class MapInfo {
  // 배경 이미지의 너비, 높이
  static const double backgroundImageWidth = 2000;
  static const double backgroundImageHeight = 1800;

  // 배경 이미지 4개의 꼭짓점의 실제 gps 좌표
  static const Map<String, double> left_up_gps = {
    'x': 37.380811,
    'y': 126.623806
  };
  static const Map<String, double> left_down_gps = {
    'x': 37.369205,
    'y': 126.623806
  };
  static const Map<String, double> right_up_gps = {
    'x': 37.380811,
    'y': 126.639884
  };
  static const Map<String, double> right_down_gps = {
    'x': 37.369205,
    'y': 126.639884
  };
}
