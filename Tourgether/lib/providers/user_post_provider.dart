import 'package:TourGather/services/post_services.dart';
import 'package:flutter/material.dart';

import '../models/message_model.dart';
import '../utilities/log.dart';

class UserPostProvider with ChangeNotifier {
  late List<MessageModel> _userPostList;

  late MessageModel _selectedPost;
  bool _isLikePressed = false;
  int _selectedPostLikeNum = 0;

  // 2023.08.13, jdk
  // MessageModel과 List<MessageModel>의 Class를 구분할 수 있다면 구분하기.
  List<MessageModel> get userPostList => _userPostList;

  MessageModel get currentSelectedPost => _selectedPost;
  bool get isLikePressed => _isLikePressed;
  int get selectedPostLikeNum => _selectedPostLikeNum;

  // 2023.08.14, jdk
  // 변수명이 너무 길어서 그런지 가독성이 매우 떨어져서 한 번 수정해야 할듯.
  set userPostList(List<MessageModel> userPostList) =>
      _userPostList = userPostList;

  set currentSelectedPost(MessageModel selectedPost) =>
      _selectedPost = selectedPost;

  set isLikePressed(bool isLikePressed) => _isLikePressed = isLikePressed;

  set selectedPostLikeNum(int selectedPostLikeNum) =>
      _selectedPostLikeNum = selectedPostLikeNum;

  // 2023.08.13, jdk
  // static method local method로 변경하기.
  PostServices postServices = PostServices();

  Future<List<MessageModel>> getUsersPostsList() async {
    List<MessageModel> userPostLists = await PostServices.getUsersPostsList();
    _userPostList = userPostLists;

    return _userPostList;
  }

  // 2023.08.14, jdk
  // Detail Screen을 처음 들어가는 경우, 혹은 한 Screen에 들어갔다가
  // 나와서 다시 새로운 Screen을 들어가는 경우. 데이터를 새롭게 초기화 해야 한다.
  void setCurrentSelectedPostData(MessageModel postData) {
    _selectedPost = postData;
  }

  // 2023.08.14, jdk
  // 우선 임시로 누를 경우 좋아요 수까지 같이 바뀌도록 설정.
  void changeCurrentPostLikeButtonState() {
    if (isLikePressed == true) {
      isLikePressed = false;
      selectedPostLikeNum--;
    } else {
      isLikePressed = true;
      selectedPostLikeNum++;
    }

    notifyListeners();
  }
}
