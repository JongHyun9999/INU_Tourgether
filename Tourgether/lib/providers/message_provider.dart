import 'package:TourGather/models/map_info.dart';
import 'package:TourGather/models/messageFormat.dart';
import 'package:TourGather/services/post_services.dart';
import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  List<dynamic> jsoncontent = [];
  List<MessageProduct> message_list = [];
  Widget content = Text('test');

  final double backgroundImageWidth = MapInfo.backgroundImageWidth;
  final double backgroundImageHeight = MapInfo.backgroundImageHeight;

  // 실제 측정결과 위도 경도가 뒤집어진 결과를 보였음. x와 y 주의
  final double? mapUp = MapInfo.left_up_gps['x'];
  final double? mapDown = MapInfo.left_down_gps['x'];
  final double? mapLeft = MapInfo.left_down_gps['y'];
  final double? mapRight = MapInfo.right_down_gps['y'];

  Future<void> getMessageList() async {
    Map<String, dynamic> postData = {
      'user_gps_x': 37.371,
      'user_gps_y': 126.33
    };

    jsoncontent = await PostServices.postGetMessage(postData);
    print('DB에서 post 받아옴');
    print(jsoncontent.length);
    for (int i = 0; i < jsoncontent.length; i++) {
      jsoncontent[i]['gps']['y'] = (jsoncontent[i]['gps']['y'] - mapLeft) /
          (mapRight! - mapLeft!) *
          backgroundImageWidth;
      jsoncontent[i]['gps']['x'] =
          (1 - (jsoncontent[i]['gps']['x'] - mapDown) / (mapUp! - mapDown!)) *
              backgroundImageHeight;
      print(
          '변경후 : ${jsoncontent[i]['gps']['y']} , ${jsoncontent[i]['gps']['x']}');

      message_list.add(MessageProduct(
          image_path: 'image_path_testing',
          user_name: jsoncontent[i]['user_name'],
          title: jsoncontent[i]['title'],
          content: jsoncontent[i]['content'],
          department: '소속학과',
          gps: {
            'x': jsoncontent[i]['gps']['x'],
            'y': jsoncontent[i]['gps']['y']
          },
          posted_time: jsoncontent[i]['posted_time'],
          liked: jsoncontent[i]['liked'],
          comments_num: jsoncontent[i]['comments_num']));
    }
  }

  MessageProvider() {
    print('생성자');
    print('시작');

    getMessageList().then((_) {
      print('시작');
      print(message_list[0].gps['x']);
      print(message_list[0].gps['y']);
      print(message_list.length);
      // content = Stack(
      //   children: [Positioned(
      //     top: message_list[0].gps['x'],
      //     left: message_list[0].gps['y'],
      //     child: IconButton(
      //       icon: Icon(
      //         Icons.mail,
      //         size: 100,
      //         color: Colors.blueAccent,
      //       ),
      //       onPressed: () {
      //         print('0 메세지 눌림');
      //       },
      //     ),
      //   ),]
      // );
      content = Stack(
        children: [
        for (int i = 0; i < message_list.length; i++)
          Positioned(
            top: message_list[i].gps['x'],
            left: message_list[i].gps['y'],
            child: IconButton(
              icon: Icon(
                Icons.mail,
                size: 100,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                print('${i} 메세지 눌림');
              },
            ),
          )
      ]);
      print('끝');
      notifyListeners();
    }).catchError((err) {
      print(err);
    });
  }
}
