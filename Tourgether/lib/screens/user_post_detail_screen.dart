import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';

import '../models/message_model.dart';
import '../services/post_services.dart';
import '../utilities/log.dart';
import '../widgets/user_post_comment.dart';

class UserPostDetailScreen extends StatefulWidget {
  UserPostDetailScreen({
    super.key,
    required this.postData,
  });

  final MessageModel postData;

  @override
  State<UserPostDetailScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UserPostDetailScreen> {
  TextEditingController commentController = TextEditingController();

  late final int rid;
  late final String user_name;
  late final String content;
  late final double latitude;
  late final double longitude;
  late final String posted_time;
  late int liked;
  late int comments_num;

  bool isLikePressed = false;
  bool isBookMarked = false;

  final double appBarHeight = 50;

  // postData 변수 초기화
  // ----------------------------------------------------------
  // 2023.08.13, jdk
  // TODO
  // 게시글에 들어갔을 때 내용이 수정되었을 수도 있으므로,
  // API를 통해 게시글 내용을 다시 받아올 수 있도록 수정해야 함.

  // initState는 async method가 될 수 없음.
  // ----------------------------------------------------------
  @override
  void initState() {
    super.initState();

    rid = widget.postData.rid;
    user_name = widget.postData.user_name;
    content = widget.postData.content;
    latitude = widget.postData.latitude;
    longitude = widget.postData.longitude;
    posted_time = widget.postData.posted_time;
    liked = widget.postData.liked;
    comments_num = widget.postData.comments_num;

    checkLikeButtonPressed();
  }

  checkLikeButtonPressed() {
    Map<String, dynamic> postData = {
      'rid': rid,
      'user_name': user_name,
    };

    PostServices.isPressedPostLike(postData).then((isPressedPostLike) {
      if (isPressedPostLike == true) {
        isLikePressed = true;
        Log.logger.d("check : ${isLikePressed}");

        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    // 2023.08.10, jdk
    // Build Method 안에 TextEditingController를 설정하면
    // 입력 후에 Build 메서드가 다시 실행될 때 변수가 초기화 되므로
    // 입력한 내용 또한 초기화 된다.
    // 따라서, TextEditingController는 Build Method 밖에 선언하자.
    // TextEditingController commentController = TextEditingController();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          iconTheme: IconThemeData(
            color: ColorPalette.onPrimaryContainer,
          ),
          backgroundColor: ColorPalette.primaryContainer,
        ),
      ),
      // body의 최상단에 Container를 선언하고 크기를 고정,
      // 이로서 화면에 한 번에 보이는 Container의 크기는 제한된다.
      // 하지만 자식 Widget으로 SingleChildScrollView를 가져서
      // SingleChildScrollView의 height는 제한이 없어진다.
      body: Container(
        width: screenWidth,
        height: screenHeight - (appBarHeight + statusBarHeight),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // TODO 사용자 이미지 프로필 이미지도 추가하기

              // Container 1)
              // user_image, user_id, posted_time
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                      // color: Colors.lime,
                      ),
                  height: screenHeight * 0.1,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: ColorPalette.primaryContainer,
                          child: Icon(
                            Icons.person,
                            color: ColorPalette.onPrimaryContainer,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // user_id, posted_time
                          Container(
                            child: Text(
                              "${widget.postData.user_name}",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                color: ColorPalette.normalColor,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              "${widget.postData.posted_time.substring(0, 16)}",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                color: ColorPalette.normalColor,
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              // TODO 매칭 알고리즘 추가 필요
                              "인천대학교 어딘가",
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                color: ColorPalette.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Container 2)
              // title
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      // color: Colors.red,
                      ),
                  child: Row(
                    children: [
                      // Title
                      Expanded(
                        child: Container(
                          child: Text(
                            "${widget.postData.title}",
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Container 3)
              // content
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
                child: Container(
                  decoration: BoxDecoration(
                      // color: Colors.amber,
                      ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          "${widget.postData.content}",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Container 4)
              // interaction buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                child: Container(
                  child: Row(
                    children: [
                      // 2023.08.11, jdk
                      // Container의 크기를 지정하지 않으면,
                      // 그 방향으로 크기가 Flexible하게 증가한다.
                      InkWell(
                        onTap: () async {
                          Log.logger.d("Like touched!");

                          isLikePressed = !isLikePressed;

                          // TODO : 현재 유저의 로그인 정보를 이용하여
                          // 좋아요 기능에 유저 아이디가 변수로 전달되도록 변경.

                          Map<String, dynamic> likedPostData = {
                            "rid": rid,
                            "user_name": "개발자정동교",
                          };

                          // 좋아요를 누른 경우.
                          if (isLikePressed == true) {
                            liked++;
                            likedPostData['isCanceled'] = false;
                            // 좋아요를 취소한 경우.
                          } else if (isLikePressed == false) {
                            liked--;
                            likedPostData['isCanceled'] = true;
                          }

                          bool isSucceeded =
                              await PostServices.pressedLikeButton(
                            likedPostData,
                          );

                          if (isSucceeded) {
                            Log.logger.d("성공");
                          } else {
                            Log.logger.d("실패");
                          }

                          setState(() {});
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: (isLikePressed)
                                ? ColorPalette.primaryContainer
                                : ColorPalette.lightGreyColor,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                                child: Icon(
                                  (isLikePressed)
                                      ? Icons.thumb_up_alt_rounded
                                      : Icons.thumb_up_alt_outlined,
                                  color: ColorPalette.whiteColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${liked}",
                                    style: TextStyle(
                                      color: ColorPalette.whiteColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          Log.logger.d("Bookmark touched!");
                          setState(() {
                            isBookMarked = !isBookMarked;
                          });
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            // border: (isBookMarked)
                            //     ? null
                            //     : Border.all(
                            //         width: 0.5,
                            //         color: ColorPalette.normalColor,
                            //       ),
                            color: (isBookMarked)
                                ? ColorPalette.primaryContainer
                                : ColorPalette.lightGreyColor,
                          ),
                          child: Row(
                            children: [
                              // 2023.08.13, jdk
                              // TODO
                              // 즐겨찾기는 적절한 구현법을 구상하기 전까지 주석처리.
                              // Padding(
                              //   padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                              //   child: Icon(
                              //     (isBookMarked)
                              //         ? Icons.star
                              //         : Icons.star_border,
                              //     color: (isBookMarked)
                              //         ? Colors.yellow
                              //         : ColorPalette.whiteColor,
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                              //   child: Container(
                              //     child: Text(
                              //       "즐겨찾기",
                              //       style: TextStyle(
                              //         color: ColorPalette.whiteColor,
                              //         fontSize: 15,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Container 5)
              // comment input
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Flexible(
                  child: Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.greenAccent,
                    // ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: CircleAvatar(
                            child: Icon(
                              Icons.person,
                              color: ColorPalette.whiteColor,
                            ),
                            backgroundColor: ColorPalette.primaryContainer,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: commentController,
                                maxLength: 50,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorPalette.lightGreyColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  ),
                                  counterText: "",
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: CircleAvatar(
                            backgroundColor: ColorPalette.secondaryContainer,
                            child: IconButton(
                              icon: Icon(
                                Icons.send,
                                color: ColorPalette.accentColor,
                              ),
                              iconSize: 25,
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Container 6)
              // comment spacer text
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                        color: ColorPalette.spacerColor,
                      ),
                    ),
                  ),
                  width: screenWidth,
                  height: 35,
                  alignment: Alignment.topLeft,
                  child: Container(
                    child: Text(
                      "댓글 ${comments_num}",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              // Container 7)
              // comments
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Flexible(
                  child: Container(
                    width: screenWidth * 0.95,
                    child: Column(
                      children: [
                        // 2023.08.11, jdk
                        // User Post Comment는 따로 Widget으로 분리하였음.
                        UserPostComment(
                          screenWidth: screenWidth,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
