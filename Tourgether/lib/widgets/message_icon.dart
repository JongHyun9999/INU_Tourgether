import 'dart:async';
import 'dart:math';

import 'package:TourGather/models/message/messageProduct.dart';
import 'package:TourGather/providers/gps_provider.dart';
import 'package:TourGather/providers/message_provider.dart';
import 'package:TourGather/providers/near_message_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageIcon extends StatefulWidget {
  MessageIcon({super.key, required this.messageInfo});
  final MessageProduct messageInfo;

  @override
  State<MessageIcon> createState() =>
      _MessageIconState(message_info: messageInfo);
}

class _MessageIconState extends State<MessageIcon>
    with TickerProviderStateMixin {
  final MessageProduct message_info;
  bool is_closed = false;
  AnimationController? _animationController;

  _MessageIconState({required this.message_info});

  // GPS 데이터의 변화를 감지해야한다.
  void checkDistance(
      GPSProvider gpsProvider, NearMessageInfoProvider nearProvider) {
    // print('====== pjh, 메세지의 사용자와의 거리 측정 =======');
    // print('pjh, ${gpsProvider.latitude} <-> ${message_info.gps['latitude']}');
    // print('pjh, ${gpsProvider.longitude} <-> ${message_info.gps['longitude']}');

    double distance = calculateDistance(gpsProvider, message_info.gps);
    if (distance <= 0.001) {
      // 가깝다고 판단
      is_closed = true;
    } else {
      // 멀다고 판단
      is_closed = false;
    }
  }

  double calculateDistance(
      GPSProvider gpsProvider, Map<String, dynamic> message_gps) {
    // pjh. 23.09.21
    // 아직 gps 값이 들어오지 않았을때는 점으로 표현하도록 함.
    if (gpsProvider.latitude == null) return 10.0;
    return sqrt(pow(gpsProvider.latitude! - message_gps['latitude']!, 2) +
        pow(gpsProvider.longitude! - message_gps['longitude']!, 2));
  }

  void messageClick(
      MessageProvider messageProvider, NearMessageInfoProvider nearProvider) {
    // 메세지 버튼 클릭시 수행 함수
    print(
        'pjh, title : ${message_info.title} \n pjh, content : ${message_info.content}');
    messageProvider.getAdjacentMessage();
    nearProvider.getNearMessageList(messageProvider.adjacent_message_list);
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final gpsProvider = Provider.of<GPSProvider>(context, listen: true);
    final nearProvider =
        Provider.of<NearMessageInfoProvider>(context, listen: false);
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    checkDistance(gpsProvider, nearProvider);

    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController?.forward();
    });

    return Positioned(
      top: message_info.location_map['y'],
      left: message_info.location_map['x'],
      child: (is_closed)
          ? ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.5).animate(
                CurvedAnimation(
                    parent: _animationController!, curve: Curves.elasticOut),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.mail,
                  size: 30,
                  color: Colors.blueAccent,
                  shadows: [],
                ),
                onPressed: () {
                  messageClick(messageProvider, nearProvider);
                },
              ),
            )
          : IconButton(
              icon: Icon(
                Icons.brightness_1,
                size: 25,
                color: Colors.blueAccent.withOpacity(0.8),
              ),
              onPressed: () {},
            ),
    );
  }
}
