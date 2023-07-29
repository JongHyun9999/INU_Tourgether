import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String userMajor = '';
  String userNum = '';
  String userName = '';
  String userEmail = '';
  String userWarning = '';
  String userRegisterDate = '';

  bool notiPopularText = true;
  bool notiEvent = true;
  bool notiComment = true;
  bool notiChat = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hello world'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blueAccent,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 15, right: 16),
        child: ListView(
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.blueAccent,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "계정",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              height: 10,
              thickness: 2,
            ),
            // 선택 리스트1 계정 정보
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "계정 정보",
                  ),
                  Icon(Icons.arrow_forward_ios)
                ],
              ),
              visualDensity: VisualDensity(
                vertical: -3,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("계정 정보",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("학과: ${userMajor}"),
                                  Text("학번: ${userNum}"),
                                  Text("이름: ${userName}"),
                                  Text("이메일: ${userEmail}"),
                                  Text("경고 내역: ${userWarning}"),
                                  Text("가입 일자: ${userRegisterDate}"),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("닫기")),
                      ],
                    );
                  },
                );
              },
            ),
            // 선택 리스트2 비밀번호 변경
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("비밀번호 변경"), Icon(Icons.arrow_forward_ios)]),
              visualDensity: VisualDensity(vertical: -3),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    //비밀번호 변경 페이지를 따로 만들 것
                    //이것은 임시
                    return AlertDialog(
                      title: Text("비밀번호 변경",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Option 1"),
                          Text("Option 2"),
                          Text("Option 3"),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("닫기")),
                      ],
                    );
                  },
                );
              },
            ),
            // 선택 리스트3 언어 설정
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("언어 설정"), Icon(Icons.arrow_forward_ios)]),
              visualDensity: VisualDensity(vertical: -3),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("언어 설정",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Kr"),
                          Text("En"),
                          Text("Jp"),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("닫기")),
                      ],
                    );
                  },
                );
              },
            ),
            SizedBox(
              height: 10,
            ),

            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "알림 설정",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
            ),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("인기글 알림"),
                    Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: notiPopularText,
                        onChanged: (bool value) {
                          //print(value);
                          notiPopularText = value;
                          // 활동 상태 업데이트 함수 호출
                          //updateUserStatus();
                          //print("switch 동작함");
                          setState(() {});
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                  ]),
              visualDensity: VisualDensity(vertical: -3),
            ),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("댓글 알림"),
                    Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: notiComment,
                        onChanged: (bool value) {
                          //print(value);
                          notiComment = value;
                          // 활동 상태 업데이트 함수 호출
                          //updateUserStatus();
                          //print("switch 동작함");
                          setState(() {});
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                  ]),
              visualDensity: VisualDensity(vertical: -3),
            ),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("채팅 알림"),
                    Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: notiChat,
                        onChanged: (bool value) {
                          //print(value);
                          notiChat = value;
                          // 활동 상태 업데이트 함수 호출
                          //updateUserStatus();
                          //print("switch 동작함");
                          setState(() {});
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                  ]),
              visualDensity: VisualDensity(vertical: -3),
            ),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("이벤트 알림"),
                    Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: notiEvent,
                        onChanged: (bool value) {
                          //print(value);
                          notiEvent = value;
                          // 활동 상태 업데이트 함수 호출
                          //updateUserStatus();
                          //print("switch 동작함");
                          setState(() {});
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                  ]),
              visualDensity: VisualDensity(vertical: -3),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  Icons.book,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "기타",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
            ),
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("개발자 공지사항"), Icon(Icons.arrow_forward_ios)]),
              visualDensity: VisualDensity(vertical: -3),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("개발자 공지사항",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Kr"),
                          Text("En"),
                          Text("Jp"),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("닫기")),
                      ],
                    );
                  },
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {},
                    child: Text("계정 탈퇴",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black)),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {},
                    child: Text("로그아웃",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
