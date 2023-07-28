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
    // network 객체 생성
    // 애뮬레이터 실습 시에는 localHost를 사용할 수 없다.
    // 아래와 같은 주소를 url을 이용해서 http 통신 시도
    Network network = Network('http://10.0.2.2:3000/get');

    // network 통신 실시.
    var jsonData = await network.getJsonData();

    // 가져온 jsonData(map형)을 전공, 이름, 학번으로 나누어 선언
    userMajor = await jsonData['user_info'][0]["user_major"];
    userName = await jsonData['user_info'][0]["user_name"];
    userNum = await jsonData['user_info'][0]['user_schoolnum'].toString();

    // 새로고침
    setState(() {});
  }

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
                      "활동 상태",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Switch(
                      value: onlineSwitch,
                      onChanged: (value) {
                        setState(() {
                          onlineSwitch = value;
                        });
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
                      icon: Icon(Icons.favorite),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.star),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.description),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {},
                    ),
                  ],
                )

                // 메뉴
                // ListTile(
                //   leading: const Icon(Icons.favorite),
                //   title: const Text('즐겨찾기'),
                //   onTap: () {},
                // ),
                // ListTile(
                //   leading: const Icon(Icons.people),
                //   title: const Text('친구'),
                //   onTap: () {},
                //   // 친구 요청 알림
                //   trailing: ClipOval(
                //       child: Container(
                //           color: Colors.red,
                //           width: 20,
                //           height: 20,
                //           child: const Center(
                //             child: Text(
                //               '8',
                //               style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 12,
                //               ),
                //             ),
                //           ))),
                // ),
                // ListTile(
                //   leading: const Icon(Icons.settings),
                //   title: const Text('설정'),
                //   onTap: () {},
                // ),
                // const Divider(),
                // ListTile(
                //   leading: const Icon(Icons.description),
                //   title: const Text('라이선스'),
                //   onTap: () {},
                // ),
                // ListTile(
                //   leading: const Icon(Icons.star),
                //   title: const Text('개발자들'),
                //   onTap: () {},
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
