import 'package:TourGather/services/post_services.dart';
import 'package:flutter/material.dart';

import '../models/user_post_model.dart';
import '../utilities/log.dart';

class UserPostProvider with ChangeNotifier {
  late List<UserPostModel> _userPostList;

  late UserPostModel _selectedPost;
  int _selectedPostIndex = 0;
  bool _isLikePressed = false;
  int _selectedPostLikeNum = 0;

  // 2023.08.13, jdk
  // UserPostModel과 List<UserPostModel>의 Class를 구분할 수 있다면 구분하기.

  // ----------------------------------------------------------
  // Getters
  List<UserPostModel> get userPostList => _userPostList;

  UserPostModel get currentSelectedPost => _selectedPost;
  int get selectedPostIndex => _selectedPostIndex;

  bool get isLikePressed => _isLikePressed;
  int get selectedPostLikeNum => _selectedPostLikeNum;
  // ----------------------------------------------------------

  // ----------------------------------------------------------
  // Setters
  set userPostList(List<UserPostModel> userPostList) =>
      _userPostList = userPostList;

  set currentSelectedPost(UserPostModel selectedPost) =>
      _selectedPost = selectedPost;

  set selectedPostIndex(int index) => _selectedPostIndex = index;
  set isLikePressed(bool isLikePressed) => _isLikePressed = isLikePressed;

  set selectedPostLikeNum(int selectedPostLikeNum) =>
      _selectedPostLikeNum = selectedPostLikeNum;
  // ----------------------------------------------------------

  // 2023.08.13, jdk
  // static method local method로 변경하기.
  PostServices postServices = PostServices();

  Future<List<UserPostModel>> getUsersPostsList() async {
    List<UserPostModel> userPostLists = await PostServices.getUsersPostsList();
    _userPostList = userPostLists;

    return _userPostList;
  }

  // 2023.08.14, jdk
  // Detail Screen을 처음 들어가는 경우, 혹은 한 Screen에 들어갔다가
  // 나와서 다시 새로운 Screen을 들어가는 경우. 데이터를 새롭게 초기화 해야 한다.
  void setCurrentSelectedPostData(UserPostModel postData) {
    _selectedPost = postData;
  }

  // 2023.08.14, jdk
  // -------------------------------------------------------------------------------
  // user가 detail screen에서 post에 좋아요를 누르거나 취소할 경우 사용되는 메서드.
  // isLikePressed 상태를 바꿔서, 삼항 연산자로 상태가 나뉘어진 UI를 재빌드 한다.
  // 이때 selectedPostLikeNum은 현재 들어온 post의 좋아요 숫자이고, 이것을 바탕으로
  // detail screen의 좋아요를 갱신한다.

  // 또한 userPostList[selectedPostIndex].liked를 변경해서, User_Post_List_Screen에서
  // 유저가 interaction한 좋아요 결과도 반영되도록 한다.
  // -------------------------------------------------------------------------------
  void changeCurrentPostLikeButtonState() {
    if (isLikePressed == true) {
      isLikePressed = false;
      selectedPostLikeNum--;
      userPostList[selectedPostIndex].liked--;
    } else {
      isLikePressed = true;
      selectedPostLikeNum++;
      userPostList[selectedPostIndex].liked++;
    }

    notifyListeners();
  }
}
