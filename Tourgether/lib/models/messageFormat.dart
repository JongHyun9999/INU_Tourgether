// pjh. 메인페이지 메세지 리스트 전용 class.
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MessageProduct with ChangeNotifier {
  final String image_path;
  final String user_name;
  final String title;
  final String content;
  final String department;
  final LatLng gps;
  final Map<String, dynamic> location_map;
  final String posted_time;
  final int liked;
  final int comments_num;

  MessageProduct({required this.image_path,
      required this.user_name,
      required this.title,
      required this.content,
      required this.department,
      required this.gps,
      required this.location_map,
      required this.posted_time,
      required this.liked,
      required this.comments_num});
}
