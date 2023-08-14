import 'package:flutter/material.dart';
import 'package:TourGather/utilities/api_url.dart';
import '../services/network.dart';

class UserInfoProvider extends ChangeNotifier {
  // network 통신 실시.

  String _userMajor = "null";
  String _userName = "null";
  String _userEmail = "null";
  String _userBadge = "null";
  String _userNum = "null";
  bool _user_map_visibility_status = false;
  int _show_online_status_type = 0;

  String get userMajor => _userMajor;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userBadge => _userBadge;
  String get userNum => _userNum;
  bool get user_map_visibility_status => _user_map_visibility_status;
  int get show_online_status_type => _show_online_status_type;
  // 테스트 데이터를 가져오는 메서드1
  void getTestData() async {
    // 2023.07.29, comjke33
    // network 객체 생성
    // 애뮬레이터 실습 시에는 localHost를 사용할 수 없다.
    // 아래와 같은 주소를 url을 이용해서 http 통신 시도

    // -------------------------------------------------------------------------
    // 2023.07.29, jdk
    // 1. API별 URL은 별도의 Utility Data Class를 만들어서 저장해 둘 것.
    // 현재는 하드코딩 방식으로 되어 있어서 코드의 유연성이 부족하다고 할 수 있음.
    // uilities(이름은 바꿔도 됨) 폴더를 만들고, 거기에 data class를 만들어서
    // API URL들을 String으로 정리해보자.
    // => Data Class 공부해보기.s

    // 2. Network Class를 Singleton Class로 생성하기.
    // 전역 변수를 예시로 생각해보자. 현재 getTestData() 메서드와
    // update_user_map_visibility_status 메서드는 각 메서드 내에서 Network의 객체를 새롭게 생성하고 있다.
    // 이것은 메서드가 실행될 때마다 새로운 객체를 만들고 메서드의 실행이 끝나면
    // 해당 객체들의 할당을 해제하는 방식이므로, 다소 비효율적이라고 할 수 있다.
    // 따라서 Network Class를 전역적인 변수(OOP에서는 Singleton Pattern 이라고 함.)로 생성,
    // API 요청을 처리해주는 단일 전역 객체를 생성해보자.
    // => Singleton Pattern, static 키워드 공부해보기.

    // -------------------------------------------------------------------------
    Network network = Network("${ApiUrl.address}${ApiUrl.userInfoApiUrl}");
    var jsonData = await network.getJsonData();
    // 가져온 jsonData(map형)을 전공, 이름, 학번으로 나누어 선언
    _userMajor = await jsonData['user_info'][0]["user_major"];
    _userName = await jsonData['user_info'][0]["user_name"];
    _userNum = await jsonData['user_info'][0]['user_num'].toString();
    _user_map_visibility_status =
        await jsonData['user_info'][0]['user_map_visibility_status'] == 1;
    _show_online_status_type =
        await jsonData['user_info'][0]['show_online_status_type'];
    _userEmail = await jsonData['user_info'][0]['user_Email'];
    _userBadge = await jsonData['user_info'][0]['user_Badge'];
    print("userInfo 정보 받아오기 성공");
    // 새로고침
    notifyListeners();
  }

  // 사용자 상태 정보 업데이트 메서드2
  void update_user_map_visibility_status(String userNum, bool _userOnline) {
    this._user_map_visibility_status = _userOnline;
    // URL, apiURL 주고 네트워크 메서드 호출
    Network network = Network(
        "${ApiUrl.address}${ApiUrl.update_user_map_visibility_statusApiUrl}");

    //
    Map<String, String> update_user_map_visibility_statusData = {
      "user_map_visibility_status": _user_map_visibility_status ? "1" : "0",
      "user_num": userNum
    };
    network.update_user_map_visibility_status(
        update_user_map_visibility_statusData);

    notifyListeners();
  }
}
