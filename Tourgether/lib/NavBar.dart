import 'package:flutter/material.dart';
import 'package:tourgether/network.dart';

import 'package:badges/badges.dart' as badges;
//import 'dart:convert';

// 사용자 정보를 담은 Stateful 위젯 선언
class NarBar extends StatefulWidget {
  const NarBar({super.key});

  @override
  // 계속 위젯 상태 변경
  State<NarBar> createState() => _NarBarState();
}

// 위젯 상태 설정 class
// 실질적으로 위젯에 관련된 정보가 들어있는 부분
class _NarBarState extends State<NarBar> {
  bool onlineSwitch = false;
  bool friendRequest = true;
  late String userMajor = '';
  late String userName = '';
  late String userNum = '';
  late String userEmail = '';

  // 첫번째로 호출되는 메서드
  @override
  void initState() {
    super.initState();
    //print("jdk test");
    getTestData();
  }

  Map<String, String> updateUserStatusData = {};
  // --- 개념 ---
  // async: promise를 반환
  // promise: js 비동기 처리에 사용되는 객체
  // 하던 일을 모두 마무리하지 않고 다음 일을 하는 js 특성 때문에
  // 하던 일을 먼저 다 끝낼 수 있도록 함.
  // async로 선언된 함수 안에서만 await를 사용할 수 있음
  // await: promise가 처리될 때까지 기다림
  // ------------

  // 테스트 데이터를 가져옴
  getTestData() async {
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
    // => Data Class 공부해보기.

    // 2. Network Class를 Singleton Class로 생성하기.
    // 전역 변수를 예시로 생각해보자. 현재 getTestData() 메서드와
    // updateUserStatus 메서드는 각 메서드 내에서 Network의 객체를 새롭게 생성하고 있다.
    // 이것은 메서드가 실행될 때마다 새로운 객체를 만들고 메서드의 실행이 끝나면
    // 해당 객체들의 할당을 해제하는 방식이므로, 다소 비효율적이라고 할 수 있다.
    // 따라서 Network Class를 전역적인 변수(OOP에서는 Singleton Pattern 이라고 함.)로 생성,
    // API 요청을 처리해주는 단일 전역 객체를 생성해보자.
    // => Singleton Pattern, static 키워드 공부해보기.

    // -------------------------------------------------------------------------

    Network network = Network('http://10.0.2.2:3000/getUserInfo');

    // network 통신 실시.
    var jsonData = await network.getJsonData();

    // 가져온 jsonData(map형)을 전공, 이름, 학번으로 나누어 선언
    userMajor = await jsonData['user_info'][0]["user_major"];
    userName = await jsonData['user_info'][0]["user_name"];
    userNum = await jsonData['user_info'][0]['user_schoolnum'].toString();

    // 새로고침
    setState(() {});
  }

  updateUserStatus() async {
    Network network = Network('http://10.0.2.2:3000/updateUserStatus');
    final s = onlineSwitch ? 1 : 0;
    updateUserStatusData = {
      "user_status": s.toString(),
      "user_schoolnum": userNum
    };
    network.updateUserStatus(updateUserStatusData);

    setState(() {});
  }

  // ---> 친구 요청
  // updateFriendBadge() async {
  //   Network network = Network('http://10.0.2.2:3000/updateFriendBadge');
  //   final friendData = await network.getFriendData();
  //   userF
  // }

  // 위젯 모양
  Widget build(BuildContext context) {
    // Drawer: material 디자인을 쉽게 조절할 수 있도록 함
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.45,
          child: Drawer(
            // ListView: 선택 리스트를 쉽게 구현
            child: ListView(
              // appBar 부분까지 범위 내에 들도록 padding을 없앰
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: EdgeInsets.zero,
                ),
                // 사용자 정보를 슬라이드 바 형태로 쉽게 구현할 수 있도록 구현된 메서드
                UserAccountsDrawerHeader(
                  // 프로필 사진
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.asset(
                        'image/userInfo_profile.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  otherAccountsPictures: [
                    CircleAvatar(
                      //backgroundImage: AssetImage('image/userInfo_profile.jpg'),
                      backgroundColor: Colors.blueAccent,
                      radius: 5,
                    ),
                    CircleAvatar(
                      //backgroundImage: AssetImage('image/userInfo_profile.jpg'),
                      backgroundColor: Colors.lightGreenAccent,
                      radius: 5,
                    ),
                    CircleAvatar(
                      //backgroundImage: AssetImage('image/userInfo_profile.jpg'),
                      backgroundColor: Colors.pinkAccent,
                      radius: 5,
                    ),
                  ],
                  // 학과, 학번, 이름
                  accountName: Text(
                    '${userMajor}',
                    style: TextStyle(fontSize: 15),
                  ),
                  accountEmail: Text(
                    "${userNum} ${userName}",
                    style: TextStyle(fontSize: 15),
                  ),
                  // 배경 이미지
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(40.0)),
                      image: DecorationImage(
                        image: AssetImage(
                          'image/userInfo_background.jpg',
                        ),
                        fit: BoxFit.cover,
                      )),
                ),
                Row(
                  children: [
                    // 활동 상태 스위치
                    const SizedBox(
                      width: 13,
                    ),
                    Icon(
                      onlineSwitch
                          ? Icons.wifi_tethering
                          : Icons.portable_wifi_off,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "활동 공개",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Switch(
                      value: onlineSwitch,
                      onChanged: (value) {
                        print(value);
                        onlineSwitch = value;
                        // 활동 상태 업데이트 함수 호출
                        updateUserStatus();
                        print("switch 동작함");
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Transform.translate(
                            offset: Offset(0, 0),
                            child: IconButton(
                              icon: Icon(Icons.people),
                              onPressed: () {},
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 18,
                            child: badges.Badge(
                              showBadge: friendRequest,
                              badgeColor: Colors.redAccent,
                              child: SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.star),
                      onPressed: () {},
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.star),
                    //   onPressed: () {},
                    // ),
                    // IconButton(
                    //   icon: Icon(Icons.description),
                    //   onPressed: () {},
                    // ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
