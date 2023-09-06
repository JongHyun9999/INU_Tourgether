// pjh. 메인 페이지에서 지도 위에 겹쳐지는 메세지 아이콘의 플로팅 전용 스크린

import 'package:TourGather/models/map_info.dart';
import 'package:TourGather/models/messageFormat.dart';
import 'package:TourGather/providers/message_provider.dart';
import 'package:TourGather/services/post_services.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final String message = "테스트중입니다";

  final double backgroundImageWidth = MapInfo.backgroundImageWidth;
  final double backgroundImageHeight = MapInfo.backgroundImageHeight;

  // 실제 측정결과 위도 경도가 뒤집어진 결과를 보였음. x와 y 주의
  final double? mapUp = MapInfo.left_up_gps['x'];
  final double? mapDown = MapInfo.left_down_gps['x'];
  final double? mapLeft = MapInfo.left_down_gps['y'];
  final double? mapRight = MapInfo.right_down_gps['y'];

  List<dynamic>? content;

  Future getMessageList() async {
    Map<String, dynamic> postData = {
      'user_gps_x': 37.371,
      'user_gps_y': 126.33
    };
    content = await PostServices.postGetMessage(postData);

    print('받은 content');
    print(content!);
    print('========================');
    for (int i = 0; i < content!.length; i++) {
      // 좌우 위치보정
      content![i]['gps']['y'] = (content![i]['gps']['y'] - mapLeft) /
          (mapRight! - mapLeft!) *
          backgroundImageWidth;

      // 상하 위치보정. 위부터 그려야 해서 1-비율 해줘야함.
      // print(content![i]['gps']['x']);
      // print(mapUp);
      // print(mapDown);
      content![i]['gps']['x'] =
          (1 - (content![i]['gps']['x'] - mapDown) / (mapUp! - mapDown!)) *
              backgroundImageHeight;
      print('변경후 : ${content![i]['gps']['y']} , ${content![i]['gps']['x']}');
    }
  }

  Widget makeMessageList() {
    return Stack(
      children: [
        for (int i = 0; i < content!.length; i++)
          Positioned(
            top: content![i]['gps']['x'],
            left: content![i]['gps']['y'],
            child: IconButton(
              icon: Icon(
                Icons.mail,
                size: 100,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                // getMessageList();
                print('${i} 메세지 눌림');
              },
            ),
          )
      ],
    );
  }

  // @override
  // void initState() {
  //   super.initState();

  //   Future.microtask(
  //     () => getMessageList(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2000,
      height: 1800,
      child: FutureBuilder(
        future: getMessageList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print('그리기');
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return makeMessageList();
            }
          } else {
            return CircularProgressIndicator();
          }
        },
        // child: makeMessageList()
      ),
    );
  }
}
