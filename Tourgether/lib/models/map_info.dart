class MapInfo {
  // 배경 이미지의 너비, 높이
  static const double backgroundImageWidth = 2000;
  static const double backgroundImageHeight = 1800;

  // 배경 이미지 4개의 꼭짓점의 실제 gps 좌표
  static const Map<String, double> left_up_gps = {'x' : 37.380846, 'y' : 126.623816};
  static const Map<String, double> left_down_gps = {'x' : 37.370007 , 'y' : 126.623816};
  static const Map<String, double> right_up_gps = {'x' : 37.380846 , 'y' : 126.639884};
  static const Map<String, double> right_down_gps = {'x' : 37.370007, 'y' : 126.639884};
}