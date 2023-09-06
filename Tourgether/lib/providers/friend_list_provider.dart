import 'package:TourGather/services/network.dart';
import 'package:TourGather/utilities/api_url.dart';
import 'package:flutter/material.dart';
// 클래스 설명
// 1. 친구 수락이 되었을 때 table 추가
// 2. 친구 목록 DB 검색
//  1) 유저의 친구 목록 검색
//  2) 유저의 친구 목록 중, 특정 친구 관계 검색 (true or false)

class FriendList with ChangeNotifier {
  final isFriend = false;

  // 2023.09.06, JKE
  // 친구 목록 검색
  // UK인 userId를 가지고 검색해서 자신과 친구인 목록을 불러옴
  void load_friend_list(String arg_userId) async {
    Network network =
        Network("${ApiUrl.address}${ApiUrl.load_friend_list_apiurl}");
    var jsonData = await network.getFriendListById(arg_userId);
    print("jsonData(친구목록): ");
    print(jsonData);
    //새로고침
    notifyListeners();
  }

  // 2023.09.06 JKE
  // 특정 친구 관계 검색
  void search_friend_list(String userId, String targetUserId) async {
    Network network =
        Network("${ApiUrl.address}${ApiUrl.search_friend_apiurl}");
    var jsonData = await network.getFriendRelationById(userId, targetUserId);
    print("jsonData(친구인지 아닌지 결과): ");
    print(jsonData);

    //새로고침
    notifyListeners();
  }

  // 2023.09.06 JKE
  // 친구 수락 되었을 때, 친구 목록 DB에 table 추가

  // 1. DB에서 timestamp 자료형으로 변경 방법 여쭤보기
  // 2. timestamp를 여기서 보내서 table에 직접 넣어야하는건지,
  //    DB에서 알아서 DB에 넣은 시간을 기준으로 넣어주는지 여부 알아보기
  void update_friend_list(String friendFirst, String friendSecond) {
    Network network =
        Network("${ApiUrl.address}${ApiUrl.update_friend_list_apiurl}");
    network.updateFriendList(friendFirst, friendSecond);

    //새로고침
    notifyListeners();
  }
}
