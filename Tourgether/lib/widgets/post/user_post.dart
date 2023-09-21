import 'package:TourGather/enums/page_movement_reason.dart';
import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../models/comments/user_comment.dart';
import '../../models/message/user_post_model.dart';
import '../../providers/user_info_provider.dart';
import '../../providers/user_post_provider.dart';
import '../../screens/nav/post_list/user_post_detail_screen.dart';
import '../../services/post_services.dart';
import '../../utilities/log.dart';

class UserPost extends StatelessWidget {
  UserPost({
    super.key,
    required this.postData,
    required this.index,
  });

  final UserPostModel postData;
  final int index;

  // 2023.09.19, jdk
  // user_post_detail_screen에 들어갔다가 다시 나올때
  // 설정된 post setting들을 default value로 clear하는 함수.
  void clearPostSettings(UserPostProvider userPostProvider) {
    Log.logger.d("jdk, clearPostSettings is executed!");
    // detail screen을 나온 후, UserPostProvider의 세팅을 default로 변경한다.

    // 선택한 post의 인덱스 초기화 (선택된 post가 없는 상태이므로 -1)
    userPostProvider.selectedPostIndex = -1;

    // 좋아요 상태 초기화
    userPostProvider.isLikePressed = false;

    // 선택한 post의 좋아요 수 초기화
    userPostProvider.selectedPostLikeNum = 0;

    // 선택한 post의 comment list 초기화
    userPostProvider.userCommentList.clear();

    // 선택한 post의 data model을 null로 초기화
    userPostProvider.currentSelectedPost = null;
  }

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

        // 선택한 게시글에 좋아요 등록 여부를 provider에 기록한다.
        if (results[0]) {
          userPostProvider.isLikePressed = results[0];
        }

        // 선택한 게시글에 작성된 comment의 list를 받아온다.
        List<UserComment> commentList = results[1];

        // 현재 게시글의 좋아요 수를 provider에 저장.
        userPostProvider.selectedPostLikeNum = postData.liked;
        userPostProvider.selectedPostIndex = index;

        // 현재 게시글에 작성된 댓글의 리스트를 provider에 저장.
        userPostProvider.userCommentList = commentList;
        Log.logger.d("length : ${userPostProvider.userCommentList.length}");

        // 2023.09.20, jdk
        // detail screen으로 이동, await을 통해서 사용자가 화면을 나오길 기다린다.
        // 화면에서 나온 후(직접 이동 혹은 게시글 삭제)에는 데이터를 전달받는데,
        // 만약 특별한 사유가 없는 페이지 이동이라면 pageMoveResult는 null이 된다. (단순 이동)
        // 삭제, 수정 등과 같이 특별한 이유가 있는 페이지 이동이라면 Map을 반환하여
        // if condition 판단을 통해 이후에 실행할 동작을 구분하게 된다.
        var pageMovementReason = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserPostDetailScreen(
              postData: postData,
            ),
          ),
        );

        if (pageMovementReason != null) {
          switch (pageMovementReason['reason']) {
            case PageMovementReason.delete:
              userPostProvider.removePostFromListByIndex(index);
              break;
            case PageMovementReason.Edit:
              // TODO : 필요할지 확실하지는 않음.
              break;
            default:
              break;
          }
        }

        clearPostSettings(userPostProvider); // 선택한 게시글의 setting들을 초기화함.
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
                                  "${userPostProvider.userPostList[index].comments_num}",
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
