import 'package:TourGather/models/message/messageProduct.dart';
import 'package:TourGather/utilities/log.dart';
import 'package:flutter/material.dart';

// 2023.09.17 JKE
// 인접한 메세지 정보를 받아서 제공하는 provider

class NearMessageInfoProvider with ChangeNotifier {
  late List<MessageProduct> message_info_list = [];

  // 인접한 메시지 정보를 모두 받아옴
  void getNearMessageList(List<MessageProduct> arg) {
    print(' pjh, ${arg.length}');
    for (int i = 0; i < arg.length; i++) {
      print('pjh, ${arg[i].content}');
    }
    message_info_list = arg;

    Log.logger.d("JKE " + message_info_list[0].title.toString());
  }
}
