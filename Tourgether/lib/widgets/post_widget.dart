import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../models/message_model.dart';
import '../screens/user_post_detail_screen.dart';

class PostWidget extends StatefulWidget {
  PostWidget({super.key, required this.postData, required this.index});

  final MessageModel postData;
  final int index;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserPostDetailScreen(
              postData: widget.postData,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: (widget.index == 0)
              ? Border(
                  bottom: BorderSide(color: ColorPalette.spacerColor, width: 1),
                  top: BorderSide(color: ColorPalette.spacerColor, width: 1),
                )
              : Border(
                  bottom: BorderSide(color: ColorPalette.spacerColor, width: 1),
                ),
          color: ColorPalette.whiteColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "${widget.postData.title}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        // 2023.08.10, jdk
                        // TextOverFlow.ellipsis property를 이용하면
                        // Text가 Overflow 될 때, ... 으로 표시되도록 만들 수 있다.
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${widget.postData.content}",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        // 2023.08.10, jdk
                        // TextOverFlow.ellipsis property를 이용하면
                        // Text가 Overflow 될 때, ... 으로 표시되도록 만들 수 있다.
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 15,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                "${widget.postData.user_id}",
                                style: TextStyle(
                                  color: ColorPalette.spacerColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              child: Text(
                                // TODO
                                // 시간 변환 알고리즘 추가
                                "${widget.postData.posted_time.substring(11, 16)}",
                                style: TextStyle(
                                  color: ColorPalette.spacerColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              child: Text(
                                // TODO
                                // Location 변환 알고리즘 추가
                                "Location",
                                style: TextStyle(
                                  color: ColorPalette.spacerColor,
                                  fontSize: 12,
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
            Container(
              width: 10,
              height: 95,
            ),
            Container(
              decoration: BoxDecoration(),
              width: 60,
              height: 95,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 2023.08.11, jdk
                  // 댓글 및 추천 수 확인 Icon은 임시적으로 주석 처리 함.

                  Container(
                    decoration: BoxDecoration(
                      color: ColorPalette.primaryContainer,
                      // border: Border.all(
                      //   width: 1,
                      //   color: ColorPalette.spacerColor,
                      // ),
                      // borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.comment,
                            color: ColorPalette.whiteColor,
                            size: 25,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "0",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     width: 1,
                    //     color: ColorPalette.spacerColor,
                    //   ),
                    //   borderRadius: BorderRadius.circular(5),
                    // ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.thumb_up_alt,
                            color: ColorPalette.primaryContainer,
                            size: 25,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "0",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
