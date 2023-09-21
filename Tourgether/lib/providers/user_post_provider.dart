import 'package:TourGather/services/post_services.dart';
import 'package:flutter/material.dart';

import '../models/comments/user_comment.dart';
import '../models/message/user_post_model.dart';
import '../utilities/log.dart';

class UserPostProvider with ChangeNotifier {
  // user_post_list_screen에서 출력되는 post들의 인스턴스를 가지고 있는 리스트
  late List<UserPostModel> _userPostList;

  // user_post_detail_screen에서 현재 선택된
  // post에 작성된 댓글의 인스턴스를 가지고 있는 리스트
  List<UserComment> userCommentList = [];

  // 현재 선택한 post의 data model 인스턴스
  // post의 내용 등의 데이터를 포함한다.
  UserPostModel? _selectedPost;

  // 현재 선택된 post의 index.
  // index는 0부터 시작이므로 -1을 기본값으로 설정
  int _selectedPostIndex = -1;

  // 현재 로그인한 유저가
  // 현재 선택한 post에 좋아요를 눌렀는지 여부
  bool _isLikePressed = false;

  // 현재 선택한 post에 등록된 좋아요의 개수
  int _selectedPostLikeNum = 0;

  // 2023.08.13, jdk
  // PostServices의 static method들을
  // local method로 변경하기.
  PostServices postServices = PostServices();

  // 2023.08.13, jdk
  // UserPostModel과 List<UserPostModel>의 Class를 구분할 수 있다면 구분하기.
  // ----------------------------------------------------------
  // Getters
  List<UserPostModel> get userPostList => _userPostList;

  UserPostModel? get currentSelectedPost => _selectedPost;
  int get selectedPostIndex => _selectedPostIndex;

  bool get isLikePressed => _isLikePressed;
  int get selectedPostLikeNum => _selectedPostLikeNum;
  // ----------------------------------------------------------

  // ----------------------------------------------------------
  // Setters
  set userPostList(List<UserPostModel> userPostList) =>
      _userPostList = userPostList;

  set currentSelectedPost(UserPostModel? selectedPost) {
    if (selectedPost != null) {
      _selectedPost = selectedPost;
    }
  }

  set selectedPostIndex(int index) => _selectedPostIndex = index;
  set isLikePressed(bool isLikePressed) => _isLikePressed = isLikePressed;

  set selectedPostLikeNum(int selectedPostLikeNum) =>
      _selectedPostLikeNum = selectedPostLikeNum;
  // ----------------------------------------------------------

  Future<List<UserPostModel>> getUsersPostsList() async {
    List<UserPostModel> userPostLists = await PostServices.getUsersPostsList();
    _userPostList = userPostLists;

    return userPostLists;
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

  // 2023.09.12, jdk
  // 현재 유저가 확인 중인 게시글에서 댓글 상태에 변화가 생길 경우
  // 변화되는 내용을 처리해 주는 함수.
  // 1) 댓글의 개수를 변화시킨다. 다시 fetch할 때까지 자신의 변화만 처리한다.
  // 2) list 상에 댓글을 새롭게 추가한다.
  void updateCurrentPostCommentsState(Map<String, dynamic> commentData) {
    // 1) 댓글의 개수 변화. Consumer를 통해 listen하고 있던 widget들이 변화됨.
    // 현재는 댓글을 추가하는 경우만 처리한다.
    userPostList[selectedPostIndex].comments_num++;

    // 2) list에 댓글 추가. 가장 끝번 idx로 추가한다.
    UserComment userComment = UserComment.fromJson(commentData);
    userCommentList.add(userComment);

    // 변경사항을 listener들에게 알림.
    notifyListeners();
  }

  // 2023.09.19, jdk
  // 함수의 인자로 전달된 index에 해당되는 post의 인스턴스를
  // userPostList로부터 제거하는 메서드
  void removePostFromListByIndex(int index) {
    // index가 음수이거나, list의 길이보다 길다면 잘못된 경우이므로 return한다.
    if (index >= userPostList.length || index < 0) {
      return;
    }

    Log.logger.d("jdk, ${index}");

    // 전달받은 index에 있는 post instance를 제거한다.
    Log.logger.d("jdk, length of list ${userPostList.length}");
    this.userPostList.removeAt(index);
    Log.logger.d("jdk, check?");
    notifyListeners(); // 변경 사항을 listener들에게 전달한다.
  }
}
