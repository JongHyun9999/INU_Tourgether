import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../models/user_comment.dart';
import '../models/user_post_model.dart';
import '../providers/user_info_provider.dart';
import '../providers/user_post_provider.dart';
import '../screens/user_post_detail_screen.dart';
import '../services/post_services.dart';
import '../utilities/log.dart';

class UserPost extends StatelessWidget {
  UserPost({
    super.key,
    required this.postData,
    required this.index,
  });

  final UserPostModel postData;
  final int index;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final userPostProvider = context.read<UserPostProvider>();

    return InkWell(
      onTap: () async {
        // 사용자의 좋아요 정보를 가져옴.
        Map<String, dynamic> postDataForLikeCheking = {
          'rid': postData.rid,
          'user_name': context.read<UserInfoProvider>().userName,
        };

        // 두 개의 API 동시 실행.
        // results[0] : bool
        // results[1] : List
        final List<dynamic> results = await Future.wait([
          PostServices.isLikeButtonPressed(postDataForLikeCheking),
          PostServices.getUserComments(postData.rid)
        ]);

        // 선택한 게시글에 좋아요를 눌렀는지 검사한다.
        bool isLikeButtonPrseed = results[0];

        // 선택한 게시글에 작성된 comment의 list를 받아온다.
        List<UserComment> commentList = results[1];

        // 현재 게시글의 좋아요 수를 provider에 저장.
        userPostProvider.selectedPostLikeNum = postData.liked;
        userPostProvider.selectedPostIndex = index;

        // 현재 게시글에 작성된 댓글의 리스트를 provider에 저장.
        userPostProvider.userCommentList = commentList;
        Log.logger.d("length : ${userPostProvider.userCommentList.length}");

        // detail screen으로 이동, await을 통해서 사용자가 화면을 나오길 기다린다.
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserPostDetailScreen(
              postData: postData,
            ),
          ),
        );

        // detail screen을 나온 후, UserPostProvider의 세팅을 변경한다.
        userPostProvider.selectedPostLikeNum = 0;
        userPostProvider.selectedPostIndex = -1;

        // PostServices.isLikeButtonPressed(postDataForLikeCheking).then(
        //   (likedValue) async {
        //     context.read<UserPostProvider>().selectedPostLikeNum =
        //         postData.liked;

        //     if (likedValue == true) {
        //       // 2023.08.14, jdk
        //       // API 통신 결과 이미 좋아요를 눌렀다면 UserPostProvider에서 값을 true로 변경한다.
        //       context.read<UserPostProvider>().isLikePressed = true;
        //     } else if (likedValue == false) {
        //       context.read<UserPostProvider>().isLikePressed = false;
        //     }

        //     // 2023.08.14, jdk
        //     // 좋아요 결과를 반영하기 위해서 provider에 현재 index 기록.
        //     context.read<UserPostProvider>().selectedPostIndex = index;

        //     await Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => UserPostDetailScreen(
        //           postData: postData,
        //         ),
        //       ),
        //     );

        //     // Detail Screen에 들어갔다가 나온 이후, selectedPost 관련한 변수를 리셋한다.
        //     // 코드 일관성을 위해서는, selectedPost도 리셋해주는 것이 좋다.
        //     // 현재 UserPostProvider의 selectedPost가 nullable이 아니기 때문에
        //     // 이후에 nullable로 수정해서, list screen으로 넘어올 때는 null로 바뀌도록 하자.
        //     context.read<UserPostProvider>().selectedPostIndex = 0;
        //   },
        // );
      },
      child: Container(
        decoration: BoxDecoration(
          border: (index == 0)
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
                        "${postData.title}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        // 2023.08.10, jdk
                        // TextOverFlow.ellipsis property를 이용하면
                        // Text가 Overflow 될 때, ... 으로 표시되도록 만들 수 있다.
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      height: 40,
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${postData.content}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                                "${postData.user_name}",
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
                                // n분 전, n시간 전, n일 전, n달 전, n년 전
                                "${postData.posted_time.substring(11, 16)}",
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
                              child: Expanded(
                                child: Text(
                                  // TODO
                                  // Location 변환 알고리즘 추가
                                  "인천대학교 어딘가",
                                  style: TextStyle(
                                    color: ColorPalette.spacerColor,
                                    fontSize: 12,
                                  ),
                                  // 혹시 모를 overflow에 대비해 ellipsis 적용.
                                  // 가장 끝 쪽에만 적용하면 됨.
                                  overflow: TextOverflow.ellipsis,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Comments Num Icon
                  Container(
                    decoration: BoxDecoration(
                        // color: ColorPalette.primaryContainer,
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
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Icon(
                            Icons.comment,
                            color: ColorPalette.primaryContainer,
                            size: 25,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Consumer<UserPostProvider>(
                              builder: (context, userPostProvider, child) {
                                return Text(
                                  "0",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Like Num Icon
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
                          padding: const EdgeInsets.all(0),
                          child: Icon(
                            Icons.thumb_up_alt,
                            color: ColorPalette.primaryContainer,
                            size: 25,
                          ),
                        ),
                        // 2023.08.14, jdk
                        // 현재는 데이터를 instance 생성자를 통해서 넘겨주는데,
                        // 이후에 Provider에서 관리할 수 있도록 수정하기.
                        // 여기서는 userPostList[index]로 접근.
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Consumer<UserPostProvider>(
                              builder: (context, userPostProvider, child) {
                                return Text(
                                  "${userPostProvider.userPostList[index].liked}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
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
