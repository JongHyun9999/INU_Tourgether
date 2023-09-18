import 'dart:async';
import 'dart:math';
import 'package:TourGather/models/map/map_info.dart';
import 'package:TourGather/models/message/messageProduct.dart';
import 'package:TourGather/providers/gps_provider.dart';
import 'package:TourGather/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class MessageProvider with ChangeNotifier {
  // DB에서 post정보 받아오는 일회용 변수
  List<dynamic> jsoncontent = [];

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
  Timer? timer2;
  AnimationController? _animationController;

  bool is_clicked = false;

  List<int> adjacent_index = [];

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
      'user_gps_x': current_position['latitude'],
      'user_gps_y': current_position['longitude'],
      'last_date': last_date
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

      message_info_list.add(
        MessageProduct(
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
      message_info_list_new.add(
        MessageProduct(
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
    }
  }

  // 생성자.
  MessageProvider(AnimationController animationController) {
    _animationController = animationController;
    print('생성자');
    print(positioned_list);
    positioned_list.clear();

    getMessageList().then((_) {
      print('then 시작');
      copyNewToList();

      for (int i = 0; i < message_info_list.length; i++) {
        Positioned? positioned = Positioned(
          top: message_info_list[i].location_map['y'],
          left: message_info_list[i].location_map['x'],
          child: IconButton(
            icon:
                (calculateDistance(current_position, message_info_list[i].gps) <
                        0.00018)
                    ? Icon(
                        Icons.mail,
                        size: 50,
                        color: Colors.blueAccent,
                      )
                    : Icon(
                        Icons.brightness_1,
                        size: 30,
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
      // addStreamDistance();
      message_info_list_new.clear();

      timer = _startTimer();
      timer2 = _addMessage();
      last_date = DateTime.now().toString().split('.')[0];
      print('마지막 측정 시간 : ${last_date}');
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
      print('====== ${timer.tick}번째 새로운 메세지 확인 =======');
      getMessageList().then((_) {
        copyNewToList();

        for (int i = 0; i < message_info_list_new.length; i++) {
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
        last_date = DateTime.now().toString().split('.')[0];
        // print(last_date);
      }).catchError((err) {
        print(err);
      });
    });
  }

  // 현재 나와 최단거리인 메세지의 인덱스를 반환하는 함수
  double calculateDistance(Map<String, dynamic> a, Map<String, dynamic> b) {
    return sqrt(pow(a['latitude']! - b['latitude']!, 2) +
        pow(a['longitude']! - b['longitude']!, 2));
  }

  Map<String, dynamic> getShortestDistance() {
    List<int> distance_list = [];
    for (int i = 0; i < message_info_list.length; i++) {
      // print('조사 대상 ${message_info_list[i].gps}');
      if (calculateDistance(
              this.current_position, this.message_info_list[i].gps) <
          0.00148) {
        distance_list.add(i);
      }
    }

    // double minDistance = distance_list.reduce(min);
    // int minIndex = distance_list.indexOf(minDistance);

    // 새로 조사한 인접 메세지 배열과 기존 인접메세지를 비교했을때
    // 1. 이전에는 인접했지만 새 배열에는 존재하지 않을때,
    // 2. 이전에는 없었지만 새 배열에는 추가되었을 때,
    // 를 구분하여 메세지 위젯을 업데이트 해준다.

    print('과거 인접한 메세지들 : ${adjacent_index}');
    print('현재 인접한 메세지들 : ${distance_list}');
    Set<int> before_adjacent_set = Set.from(adjacent_index);
    Set<int> after_adjacent_set = Set.from(distance_list);

    // 과거엔 없었는데 새로 인접하게 된 메세지들
    Set<int> new_adjacent_set =
        after_adjacent_set.difference(before_adjacent_set);
    // 과거에도 인접했고 현재도 인접한 메세지들
    Set<int> alive_adjacent_set = after_adjacent_set
        .difference(after_adjacent_set.difference(before_adjacent_set));

    Map<String, dynamic> difference_list = {
      // 새로 추가된 놈들만 뽑기
      'new': new_adjacent_set.toList(),
      // 멀어진 놈들만 뽑기
      'rem': before_adjacent_set.difference(after_adjacent_set).toList(),
      // 살아 있는 놈들
      'old': alive_adjacent_set.toList()
    };

    print('추가된거 : ${difference_list['new']}');
    print('멀어진거 : ${difference_list['rem']}');
    print('살아있는거 : ${difference_list['old']}');

    // 인접 메세지들 업데이트
    adjacent_index = distance_list;

    return difference_list;
  }

  // 첫 빌드 후 주기적으로 일정 범위 내의 메세지 키우기
  Timer _startTimer() {
    return Timer.periodic(const Duration(seconds: 3), (timer) {
      Map<String, dynamic> difference_list = getShortestDistance();

      print(message_info_list.length);
      // _animationController!.reset();
      // 멀어져서 원으로 만드는 코드
      for (int i = 0; i < difference_list['rem'].length; i++) {
        print('사라진 인덱스 : ${difference_list['rem'][i]}');
        positioned_list[difference_list['rem'][i]] = Positioned(
          top: message_info_list[difference_list['rem'][i]].location_map['y'],
          left: message_info_list[difference_list['rem'][i]].location_map['x'],
          child: IconButton(
            icon: Icon(
              Icons.brightness_1,
              size: 30,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              print('${difference_list['rem'][i]} 메세지 눌림');
            },
          ),
        );
      }

      for (int i = 0; i < difference_list['old'].length; i++) {
        print('가까운 인덱스 : ${difference_list['old'][i]}');
        positioned_list[difference_list['old'][i]] = Positioned(
          top: message_info_list[difference_list['old'][i]].location_map['y'],
          left: message_info_list[difference_list['old'][i]].location_map['x'],
          child: IconButton(
            icon: Icon(
              Icons.mail,
              size: 30,
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

              print('${difference_list['old'][i]} 메세지 눌림');
            },
          ),
        );
      }

      // 가까워져서 메세지로 만드는 코드
      for (int i = 0; i < difference_list['new'].length; i++) {
        print('가까운 인덱스 : ${difference_list['new'][i]}');
        positioned_list[difference_list['new'][i]] = Positioned(
          top: message_info_list[difference_list['new'][i]].location_map['y'],
          left: message_info_list[difference_list['new'][i]].location_map['x'],
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.5).animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.elasticOut)),
            child: IconButton(
              icon: Icon(
                Icons.mail,
                size: 30,
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

                print('${difference_list['new'][i]} 메세지 눌림');
              },
            ),
          ),
        );
      }

      is_clicked = true;
      _animationController!
          .forward()
          .then((value) => _animationController!.reverse());

      current_position['longitude'] = current_position['longitude'] - 0.001;
      notifyListeners();
    });
  }

  void copyNewToList() {
    for (int i = 0; i < message_info_list_new.length; i++) {
      message_info_list.add(message_info_list_new[i]);
    }
  }

  // =============================================
  // proxyprovier를 위한 update 함수
  void update(GPSProvider gpsProvider) {
    // pjh. 프로바이더 생성시에도 update가 호출되는데,
    // 아직 gps가 들어오지 않았을수 있기 때문에 null일 경우 pass.
    if (gpsProvider.latitude == null) return;

    // current_position['latitude'] = gpsProvider.latitude;
    // current_position['longitude'] = gpsProvider.longitude;
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
