import 'dart:async';
import 'dart:math';

import 'package:TourGather/models/map/map_info.dart';
import 'package:TourGather/models/message/messageProduct.dart';
import 'package:TourGather/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../utilities/log.dart';

class MessageProvider extends ChangeNotifier {
  // DB에서 post정보 받아오는 일회용 변수
  List<dynamic> jsoncontent = [];

  // 인덱스별 메세지들의 정보가 담긴 model 저장
  List<MessageProduct> message_info_list = [];
  List<MessageProduct> message_info_list_new = [];

  // 인덱스별 메세지들 위젯인 Positioned들.
  List<Widget> positioned_list = [];

  // 임시 현재 내 좌표
  LatLng current_position = LatLng(37.3744767, 126.6336167);

  Timer? timer;
  Timer? timer2;
  AnimationController? _animationController;

  bool is_clicked = false;

  final double backgroundImageWidth = MapInfo.backgroundImageWidth;
  final double backgroundImageHeight = MapInfo.backgroundImageHeight;

  // 실제 측정결과 위도 경도가 뒤집어진 결과를 보였음. x와 y 주의
  final double? mapUp = MapInfo.left_up_gps['x'];
  final double? mapDown = MapInfo.left_down_gps['x'];
  final double? mapLeft = MapInfo.left_down_gps['y'];
  final double? mapRight = MapInfo.right_down_gps['y'];

  final DateFormat dateFormat = DateFormat("YYYY-MM-DD HH:mm:ss");
  String last_date = DateTime(2000 - 12 - 02).toString().split('.')[0];

  // ==================== Method ========================
  // DB에서 메세지 리스트를 가지고 오는 함수
  Future<void> getMessageList() async {
    Map<String, dynamic> postData = {
      'user_gps_x': current_position.latitude,
      'user_gps_y': current_position.longitude,
      'last_date': last_date
    };

    jsoncontent = await PostServices.postGetMessage(postData);
    print('DB에서 post 받아옴 : ${jsoncontent.length}개');
    for (int i = 0; i < jsoncontent.length; i++) {
      LatLng gps_point =
          LatLng(jsoncontent[i]['gps']['x'], jsoncontent[i]['gps']['y']);
      // 좌우 위치보정
      jsoncontent[i]['gps']['y'] = (jsoncontent[i]['gps']['y'] - mapLeft) /
          (mapRight! - mapLeft!) *
          backgroundImageWidth;

      // 상하 위치보정. 위부터 그려야 해서 1-비율 해줘야함.
      jsoncontent[i]['gps']['x'] =
          (1 - (jsoncontent[i]['gps']['x'] - mapDown) / (mapUp! - mapDown!)) *
              backgroundImageHeight;

      // print('저장되는 실제 gps : ${gps_point.latitude} , ${gps_point.longitude}');
      // print(
      //     '변경후 : ${jsoncontent[i]['gps']['x']} , ${jsoncontent[i]['gps']['y']}');

      message_info_list.add(
        MessageProduct(
          image_path: 'image_path_testing',
          user_name: jsoncontent[i]['user_name'],
          title: jsoncontent[i]['title'],
          content: jsoncontent[i]['content'],
          department: '소속학과',
          gps: LatLng(gps_point.latitude, gps_point.longitude),
          location_map: {
            'x': jsoncontent[i]['gps']['y'],
            'y': jsoncontent[i]['gps']['x']
          },
          posted_time: jsoncontent[i]['posted_time'],
          liked: jsoncontent[i]['liked'],
          comments_num: jsoncontent[i]['comments_num'],
        ),
      );
      message_info_list_new.add(
        MessageProduct(
          image_path: 'image_path_testing',
          user_name: jsoncontent[i]['user_name'],
          title: jsoncontent[i]['title'],
          content: jsoncontent[i]['content'],
          department: '소속학과',
          gps: LatLng(gps_point.latitude, gps_point.longitude),
          location_map: {
            'x': jsoncontent[i]['gps']['y'],
            'y': jsoncontent[i]['gps']['x']
          },
          posted_time: jsoncontent[i]['posted_time'],
          liked: jsoncontent[i]['liked'],
          comments_num: jsoncontent[i]['comments_num'],
        ),
      );
    }
  }

  // 생성자.
  MessageProvider(AnimationController animationController) {
    _animationController = animationController;
    print('생성자');

    getMessageList().then((_) {
      for (int i = 0; i < message_info_list.length; i++) {
        Positioned positioned = Positioned(
          top: message_info_list[i].location_map['y'],
          left: message_info_list[i].location_map['x'],
          child: IconButton(
            icon: Icon(
              Icons.mail,
              size: 50,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              print('${i} 메세지 눌림');
            },
          ),
        );
        positioned_list.add(positioned);
      }

      notifyListeners();
      message_info_list_new.clear();
      // addStreamDistance();

      timer = _startTimer();
      timer2 = _addMessage();
      last_date = DateTime.now().toString().split('.')[0];
      print('마지막 측정 시간 : ${last_date}');
    }).catchError((err) {
      print(err);
    });
  }

  // 현재 나와 최단거리인 메세지의 인덱스를 반환하는 함수
  double calculateDistance(LatLng a, LatLng b) {
    return sqrt(
        pow(a.latitude - b.latitude, 2) + pow(a.longitude - b.longitude, 2));
  }

  int getShortestDistance() {
    List<double> distance_list = [];
    for (int i = 0; i < message_info_list.length; i++) {
      // print('조사 대상 ${message_info_list[i].gps}');
      distance_list.add(calculateDistance(
          this.current_position, this.message_info_list[i].gps));
    }
    // print(distance_list);

    double minDistance = distance_list.reduce(min);
    int minIndex = distance_list.indexOf(minDistance);
    // Widget nearestPoint = positioned_list[minIndex];

    return minIndex;
  }

  // Stream<void> addStreamDistance() {
  //   print('Stream 시작');
  //   return Stream<void>.periodic(
  //       const Duration(seconds: 5), (timer) => _startTimer());
  // }

  // 첫 빌드 후 주기적으로 가장 가까운 메세지의 크기 키우기.
  Timer _startTimer() {
    return Timer.periodic(const Duration(seconds: 3), (timer) {
      int shortest_index = getShortestDistance();
      print('제일 가까운 인덱스 : ${shortest_index}');

      positioned_list[shortest_index] = Positioned(
        top: message_info_list[shortest_index].location_map['y'],
        left: message_info_list[shortest_index].location_map['x'],
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.5).animate(CurvedAnimation(
              parent: _animationController!,
              curve: Curves.fastEaseInToSlowEaseOut)),
          child: IconButton(
            icon: Icon(
              Icons.mail,
              size: 50,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              if (!is_clicked) {
                is_clicked = true;
                _animationController!.forward();
              } else {
                is_clicked = false;
                _animationController!.reverse();
              }

              print('${shortest_index} 메세지 눌림');
            },
          ),
        ),
      );
      _animationController!.forward();
      is_clicked = true;
      notifyListeners();
    });
  }

  // 09. 12. pjh
  // 현재 메세지 스크린의 로딩 과정은
  // 첫 로딩때 메세지들을 가져와서 화면에 띄우고,
  // 5초마다 가장 가까운 메세지를 찾아 해당 인덱스의 위젯만 스케일위젯으로 수정하고,
  // 수정사항을 화면에 반영한다.
  // 리스트 사이즈가 커진다면 리스트 전체를 화면에 다시 그리는게 불필요한 작업같아 개선하고 싶음.
  // 추가적으로, 첫 로딩외에 주기적으로 새로 추가되는 메세지를 화면에 반영해주는 작업이 필요하다.

  // 첫 로딩후 5초마다 주기적인 추가 메세지 확인
  Timer _addMessage() {
    return Timer.periodic(const Duration(seconds: 5), (timer) async {
      print('====== ${timer.tick}번째 새로운 메세지 확인 =======');
      getMessageList().then((_) {
        for (int i = 0; i < message_info_list_new.length; i++) {
          Log.logger.d("executed???");
          Positioned positioned = Positioned(
            top: message_info_list[i].location_map['y'],
            left: message_info_list[i].location_map['x'],
            child: IconButton(
              icon: Icon(
                Icons.mail,
                size: 50,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                print('${i} 메세지 눌림');
              },
            ),
          );
          positioned_list.add(positioned);
        }

        notifyListeners();
        message_info_list_new.clear();
        // last_date = dateFormat.format(DateTime.now());
        last_date = DateTime.now().toString().split('.')[0];
        // print(last_date);
      }).catchError((err) {
        print(err);
      });
    });
  }

  @override
  void dispose() {
    print('ㅅㅂ 타이머 죽어 그냥');
    timer!.cancel();
    super.dispose();
  }

  // void didPop() {
  //   timer!.cancel();
  // }
}
