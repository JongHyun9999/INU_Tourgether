import 'package:TourGather/models/message/messageProduct.dart';
import 'package:flutter/material.dart';

// 2023.09.17 JKE
// 인접한 메세지 정보를 받아서 제공하는 provider

class NearMessageInfoProvider with ChangeNotifier {
  List<MessageProduct> message_info_list = [];

  bool _isVisibleMessage = true;
  bool get isVisibleMessage => _isVisibleMessage;

  // 메시지가 눌려서 위젯을 보여줘야함을 알려주는 활성화 함수
  void showMessage() {
    _isVisibleMessage = !_isVisibleMessage;
    notifyListeners();
  }

  // 인접한 메시지 정보를 모두 받아옴
  void getNearMessageList(List<MessageProduct> arg) {
    print(' pjh, ${arg.length}');
    for (int i = 0; i < arg.length; i++) {
      print('pjh, ${arg[i].content}');
    }
    // message_info_list.add(arg);
    notifyListeners();
  }
}
