import 'package:TourGather/models/messageFormat.dart';
import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  List<MessageProduct> message_list = [];

  void makeList(List<dynamic> jsoncontent) {
    for (int i = 0; i < jsoncontent.length; i++) {
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
    notifyListeners();
  }
}
