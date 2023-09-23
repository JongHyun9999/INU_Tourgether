import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:TourGather/models/map/map_info.dart';
import 'package:TourGather/models/message/messageProduct.dart';
import 'package:TourGather/providers/gps_provider.dart';
import 'package:TourGather/services/post_services.dart';
import 'package:TourGather/widgets/message_icon.dart';
import 'package:flutter/material.dart';

class MessageProvider with ChangeNotifier {
  // DB에서 post정보 받아오는 일회용 변수
  List<dynamic> jsoncontent = [];
  List<dynamic> json_content = [];

  // 인덱스별 메세지들의 정보가 담긴 model 저장
  List<MessageProduct> message_info_list = [];
  List<MessageProduct> message_info_list_new = [];

  // 인덱스별 메세지들 위젯인 Positioned들.
  List<Widget> positioned_list = [];

  // 임시 현재 내 좌표
  Map<String, dynamic> current_position = {
    'latitude': 37.3744767,
    'longitude': 126.6336167
  };

  Timer? timer;

  bool is_clicked = false;
  int first_rid = 0;
  int last_rid = 0;
  List<int> before_rid_list = [];
  List<int> current_rid_list = [];
  List<int> removed_rid_list = [];

  List<MessageProduct> adjacent_message_list = [];

  final double backgroundImageWidth = MapInfo.backgroundImageWidth;
  final double backgroundImageHeight = MapInfo.backgroundImageHeight;

  // 실제 측정결과 위도 경도가 뒤집어진 결과를 보였음. x와 y 주의
  final double? mapUp = MapInfo.left_up_gps['x'];
  final double? mapDown = MapInfo.left_down_gps['x'];
  final double? mapLeft = MapInfo.left_down_gps['y'];
  final double? mapRight = MapInfo.right_down_gps['y'];

  String last_date = DateTime(2000 - 12 - 02).toString().split('.')[0];

  // ==================== Method ========================
  Future<void> updateMessageList() async {
    Map<String, dynamic> postData = {
      'first_rid': first_rid,
      'last_rid': last_rid
    };

    json_content.clear();
    json_content = await PostServices.postUpdateMessage(postData);
    print('pjh, ${jsoncontent}');
    for (int i = 0; i < json_content.length; i++) {
      current_rid_list.add(json_content[i]['rid']);
    }
    checkIsRemoved();
  }

  void checkIsRemoved() {
    Set<int> before_rid_set = Set.from(before_rid_list);
    Set<int> current_rid_set = Set.from(current_rid_list);

    removed_rid_list = before_rid_set.difference(current_rid_set).toList();

    message_info_list.removeWhere((element) => removed_rid_list.contains(element.rid));
  }

  // DB에서 메세지 리스트를 가지고 오는 함수
  Future<void> getMessageList() async {
    Map<String, dynamic> postData = {
      'user_gps_x': current_position['latitude'],
      'user_gps_y': current_position['longitude'],
      'last_date': last_date,
      'last_rid': last_rid
    };
    print(postData['last_date']);

    jsoncontent = await PostServices.postGetMessage(postData);
    print('DB에서 post 받아옴 : ${jsoncontent.length}개');
    for (int i = 0; i < jsoncontent.length; i++) {
      Map<String, dynamic> gps_point = {
        'latitude': jsoncontent[i]['gps']['x'],
        'longitude': jsoncontent[i]['gps']['y']
      };
      // 좌우 위치보정
      jsoncontent[i]['gps']['y'] = (jsoncontent[i]['gps']['y'] - mapLeft) /
          (mapRight! - mapLeft!) *
          backgroundImageWidth;

      // 상하 위치보정. 위부터 그려야 해서 1-비율 해줘야함.
      jsoncontent[i]['gps']['x'] =
          (1 - (jsoncontent[i]['gps']['x'] - mapDown) / (mapUp! - mapDown!)) *
              backgroundImageHeight;

      message_info_list_new.add(
        MessageProduct(
            rid: jsoncontent[i]['rid'],
            image_path: 'image_path_testing',
            user_name: jsoncontent[i]['user_name'],
            title: jsoncontent[i]['title'],
            content: jsoncontent[i]['content'],
            department: '소속학과',
            gps: {
              'latitude': gps_point['latitude'],
              'longitude': gps_point['longitude']
            },
            location_map: {
              'x': jsoncontent[i]['gps']['y'],
              'y': jsoncontent[i]['gps']['x']
            },
            posted_time: jsoncontent[i]['posted_time'],
            liked: jsoncontent[i]['liked'],
            comments_num: jsoncontent[i]['comments_num']),
      );

      if (i == jsoncontent.length - 1) {
        last_rid = jsoncontent[i]['rid'];
      }
    }
  }

  // 생성자.
  MessageProvider() {
    positioned_list.clear();
    print('생성자');

    getMessageList().then((_) async {
      print('then 시작');
      copyNewToList();

      print(message_info_list.length);
      for (int i = 0; i < message_info_list.length; i++) {
        if (first_rid == 0) first_rid = message_info_list[i].rid;
        print('pjh, 추가함, ${i}');
        print('pjh, ${message_info_list[i].content}');
        Widget positioned = MessageIcon(messageInfo: message_info_list[i]);
        positioned_list.add(positioned);
      }

      updateMessageList().then((value) {});

      notifyListeners();

      message_info_list_new.clear();
      // timer = _startTimer();
      timer = _addMessage();
      last_date = DateTime.now().toString().split('.')[0];
      print('pjh, 마지막 측정 시간 : ${last_date}');
    }).catchError((err) {
      print(err);
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
      print('pjh, ====== ${timer.tick}번째 새로운 메세지 확인 =======');
      getMessageList().then((_) {
        copyNewToList();

        for (int i = 0; i < message_info_list_new.length; i++) {
          print('pjh, 새로운 메세지 추가');
          Widget positioned =
              MessageIcon(messageInfo: message_info_list_new[i]);
          positioned_list.add(positioned);
        }

        if (message_info_list_new.length > 0) {
          notifyListeners();
        }
        message_info_list_new.clear();
        last_date =
            DateTime.now().add(Duration(seconds: 5)).toString().split('.')[0];
        print('pjh, 현재 시간 ${last_date}');
        // notifyListeners();
      }).catchError((err) {
        print(err);
      });
    });
  }

  Timer _removeMessage() {
    return Timer.periodic(const Duration(seconds: 5), (timer) async {
      print('pjh, ====== ${timer.tick}번째 제거될 메세지 확인 =======');
      getMessageList().then((_) {
        copyNewToList();

        for (int i = 0; i < message_info_list_new.length; i++) {
          print('pjh, 새로운 메세지 추가');
          Widget positioned =
              MessageIcon(messageInfo: message_info_list_new[i]);
          positioned_list.add(positioned);
        }

        if (message_info_list_new.length > 0) {
          notifyListeners();
        }
        message_info_list_new.clear();
        // notifyListeners();
      }).catchError((err) {
        print(err);
      });
    });
  }

  void copyNewToList() {
    for (int i = 0; i < message_info_list_new.length; i++) {
      message_info_list.add(message_info_list_new[i]);
      before_rid_list.add(message_info_list_new[i].rid);
    }
  }

  void getAdjacentMessage() {
    // 메세지 위젯 중 특정 위젯 클릭시 발동되며,
    // 인접한 메세지들을 찾아준다.
    adjacent_message_list.clear();
    for (int i = 0; i < message_info_list.length; i++) {
      double distance =
          calculateDistance(this.current_position, message_info_list[i].gps);
      if (distance < 0.001) {
        adjacent_message_list.add(message_info_list[i]);
      }
    }
  }

  double calculateDistance(Map<String, dynamic> a, Map<String, dynamic> b) {
    return sqrt(pow(a['latitude']! - b['latitude']!, 2) +
        pow(a['longitude']! - b['longitude']!, 2));
  }

  // =============================================
  // proxyprovier를 위한 update 함수
  void update(GPSProvider gpsProvider) {
    // pjh. 프로바이더 생성시에도 update가 호출되는데,
    // 아직 gps가 들어오지 않았을수 있기 때문에 null일 경우 pass.
    if (gpsProvider.latitude == null) return;

    current_position['latitude'] = gpsProvider.latitude;
    current_position['longitude'] = gpsProvider.longitude;
    print('update 실행');
    return;
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
