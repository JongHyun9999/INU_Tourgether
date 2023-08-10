import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/message_model.dart';
import '../utilities/log.dart';

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

  bool isLikePressed = false;
  bool isBookMarked = false;

  int likeNum = 0;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
      body: Container(
        width: screenWidth,
        height: screenHeight,
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
                              "${widget.postData.user_id}",
                            ),
                          ),
                          Container(
                            child: Text(
                                "${widget.postData.posted_time.substring(0, 16)}"),
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
                        onTap: () {
                          Log.logger.d("Like touched!");
                          setState(() {
                            isLikePressed = !isLikePressed;

                            if (isLikePressed == true) {
                              likeNum++;
                            } else if (isLikePressed == false) {
                              likeNum--;
                            }

                            Log.logger.d("${likeNum}");
                          });
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
                                    "${likeNum}",
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
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                                child: Icon(
                                  (isBookMarked)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: (isBookMarked)
                                      ? Colors.yellow
                                      : ColorPalette.whiteColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                                child: Container(
                                  child: Text(
                                    "즐겨찾기",
                                    style: TextStyle(
                                      color: ColorPalette.whiteColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
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
                          padding: const EdgeInsets.all(8),
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
                                      color: ColorPalette.normalColor,
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 0),
                          child: IconButton(
                            icon: Icon(Icons.send),
                            iconSize: 25,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Container 6)
              // comments
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Flexible(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                    ),
                    child: Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //     vertical: 5,
                        //     horizontal: 0,
                        //   ),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       border: Border.all(width: 1),
                        //     ),
                        //     height: 100,
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //     vertical: 5,
                        //     horizontal: 0,
                        //   ),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       border: Border.all(width: 1),
                        //     ),
                        //     height: 100,
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //     vertical: 5,
                        //     horizontal: 0,
                        //   ),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       border: Border.all(width: 1),
                        //     ),
                        //     height: 100,
                        //   ),
                        // ),
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
