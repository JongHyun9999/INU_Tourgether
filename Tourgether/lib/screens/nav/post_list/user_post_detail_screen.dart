import 'package:TourGather/enums/page_movement_reason.dart';
import 'package:TourGather/enums/user_post_interaction.dart';
import 'package:TourGather/providers/user_info_provider.dart';
import 'package:TourGather/utilities/my_timer.dart';
import 'package:TourGather/utilities/color_palette.dart';
import 'package:TourGather/utilities/log.dart';
import 'package:TourGather/widgets/post/post_interactions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

// import 'package:TourGather/models/comments/user_comment.dart';
import 'package:TourGather/models/message/user_post_model.dart';
import 'package:TourGather/providers/user_post_provider.dart';
import 'package:TourGather/services/post_services.dart';
import 'package:TourGather/widgets/post/user_post_comment.dart';

class UserPostDetailScreen extends StatefulWidget {
  UserPostDetailScreen({
    super.key,
    required this.postData,
  });

  final UserPostModel postData;

  @override
  State<UserPostDetailScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UserPostDetailScreen> {
  TextEditingController commentController = TextEditingController();

  late final int rid;
  late final String user_name;
  late final String title;
  late final String content;
  late final Map<String, dynamic> gps;
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
    title = widget.postData.title;
    content = widget.postData.content;
    gps = widget.postData.gps;
    posted_time = widget.postData.posted_time;
    liked = widget.postData.liked;
    comments_num = widget.postData.comments_num;

    // 작성된 게시글에 대한 정보이다. (접속한 유저에 대한 정보가 아님.)
    UserPostModel postData = UserPostModel(
      rid: rid,
      user_name: user_name,
      title: title,
      content: content,
      gps: gps,
      posted_time: posted_time,
      liked: liked,
      comments_num: comments_num,
    );

    // 2023.08.14, jdk
    // TODO UserPostModel 이름 수정. => UserPostModel
    // Provider에 CurrentSelectedPost(UserPostModel) 데이터 초기화하기.
    context.read<UserPostProvider>().setCurrentSelectedPostData(postData);
  }

  bool checkContentEmpty(String content) {
    if (content == "") {
      return true;
    }

    return false;
  }

  // 2023.09.16, jdk
  // 유저가 입력한 댓글 내용을 바탕으로
  // 업로드한 데이터의 Map 객체를 만드는 함수.
  Map<String, dynamic> makeCommentMapData(String content) {
    // 서버로 전송할 Map 데이터 생성
    Map<String, dynamic> commentData = {};
    UserInfoProvider userInfoProvider = context.read<UserInfoProvider>();
    MyTimer timer = MyTimer();

    // 여기서 comment_idx를 설정해야 하는데, 동시에 댓글 작성을 요청할 경우
    // comment_idx가 duplicated 될 가능성이 있으므로 이에 주의해야 한다.
    commentData['content'] = content;
    commentData['user_name'] = userInfoProvider.userName;
    commentData['rid'] = rid;
    commentData['liked_num'] = 0;
    commentData['posted_time'] = timer.getCurrentTimeFormatted();

    return commentData;
  }

  // 2023.09.12, jdk
  // 유저가 입력한 댓글을 포스팅하는 함수.
  void postComment() async {
    String content = commentController.text;

    // 입력한 내용이 비어있는지 확인
    if (checkContentEmpty(content)) {
      Log.logger.d("내용을 작성해 주세요.");
      // TODO : 사용자에게 알림 전달 필요
      return;
    }

    // 전송할 데이터 생성
    Map<String, dynamic> commentData = makeCommentMapData(content);

    // 유저가 작성한 comment를 전송함.
    bool isSucceeded = await PostServices.postUserComment(commentData);

    if (isSucceeded) {
      var userPostProvider = context.read<UserPostProvider>();

      // 작성한 댓글을 현재 디스플레이에 추가
      userPostProvider.updateCurrentPostCommentsState(commentData);
      commentController.clear(); // 입력한 내용 지우기
      FocusManager.instance.primaryFocus?.unfocus(); // 키보드가 올라와 있을 경우 내리기
    } else {
      // TODO
    }
  }

  void onMenuInteraction(UserPostInteraction interaction) {
    switch (interaction) {
      case UserPostInteraction.edit:
        // 2023.09.19, jdk
        // TODO : edit할 때 동작 추가, 추후 개발.
        onEditPost();
        break;
      case UserPostInteraction.delete:
        onDeletePost();
        break;
      default:
        break;
    }
  }

  // 2023.09.21, jdk
  // 유저가 현재 게시글을 지울 수 있는지 검사하는 함수
  bool canUserDeletePost() {
    String current_user_name = context.read<UserInfoProvider>().userName;

    if (current_user_name == user_name || current_user_name == "admin") {
      return true;
    }

    return false;
  }

  // 2023.09.17, jdk
  // 현재 선택한 게시글을 수정하는 함수
  void onEditPost() {}

  // 2023.09.17, jdk
  // 현재 선택한 게시글을 제거하는 함수
  void onDeletePost() async {
    if (canUserDeletePost() == false) {
      Log.logger.d("jdk, false!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('본인의 게시글만 삭제할 수 있습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }
    Log.logger.d("jdk, true!");

    // action을 표시하는데 필요한 widget들을 가져온다.
    PostInteractions postInteractions = PostInteractions(context);

    // alertDialog 인스턴스 생성
    AlertDialog postInteractionDialog = postInteractions.postInteractionDialog!;

    // 생성한 AlertDialog를 띄운다.
    bool isDeleteing = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return postInteractionDialog;
      },
    );

    // 삭제를 선택한 경우
    if (isDeleteing) {
      Map<String, int> postData = {};
      postData['rid'] = rid;

      // 삭제 API 실시
      bool isDeleteSucceeded = await PostServices.deleteUserPost(postData);

      // post 삭제 성공
      if (isDeleteSucceeded) {
        // 이전 페이지 (user_post_list_screen.dart)로 이동한다.
        // 사유는 delete이므로 PageMovementReason Enum을 이용해 Map을 반환한다.
        Navigator.of(context).pop({"reason": PageMovementReason.delete});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('성공적으로 삭제되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      // post 삭제 실패
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제에 실패했습니다. 잠시 후에 다시 시도해 주세요.'),
          ),
        );
      }
    }
    // 취소를 선택한 경우
    else {
      // TODO
    }
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
              // user_image, user_id, posted_time and interaction button(more_vert)
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
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // user_id, posted_time
                            Container(
                              child: Text(
                                "${user_name}",
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 13,
                                  color: ColorPalette.normalColor,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "${posted_time.substring(0, 16)}",
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
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // 게시글 수정 기능
                            // TODO : 나중에 추가
                            Container(
                                width: 40,
                                height: 40,
                                child: PopupMenuButton<UserPostInteraction>(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: ColorPalette.accentColor,
                                  ),
                                  // PopupMenu에서 특정 Item을 선택할 경우 실행하는 Callback 함수
                                  onSelected:
                                      (UserPostInteraction interaction) {
                                    onMenuInteraction(interaction);
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem(
                                        value: UserPostInteraction.edit,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: ColorPalette.accentColor,
                                            ),
                                            Text("수정"),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: UserPostInteraction.delete,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: ColorPalette.accentColor,
                                            ),
                                            Text("삭제"),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                )),
                          ],
                        ),
                      )
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
                  child: Row(
                    children: [
                      // Title
                      Expanded(
                        child: Container(
                          child: Text(
                            "${title}",
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          "${content}",
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

                          // 현재 Provider에서 가진 isLikeButtonPressed 상태를 반전하여
                          // 이후에 반영될 결과를 서버에 전달함.
                          bool isPressed =
                              context.read<UserPostProvider>().isLikePressed;
                          isPressed = !isPressed;

                          String likedUserName =
                              context.read<UserInfoProvider>().userName;

                          Map<String, dynamic> likedPostData = {
                            "rid": rid,
                            "user_name": likedUserName,
                            "isPressed": isPressed,
                          };

                          bool isSucceeded =
                              await PostServices.pressedLikeButton(
                            likedPostData,
                          );

                          // 2023.08.14, jdk
                          // API 통신 결, 좋아요 기능이 반영되었으므로
                          // UserPostProvider에서 결과를 바꿔준다.

                          // 좋아요 반영이 성공할 경우, UserPostProvider의 함수를 이용하여
                          // User_Post_List_Screen의 좋아요 결과도 재빌드 하도록 한다.
                          if (isSucceeded) {
                            context
                                .read<UserPostProvider>()
                                .changeCurrentPostLikeButtonState();
                            Log.logger.d("좋아요 반영 성공");
                          } else {
                            Log.logger.d("좋아요 반영 실패");
                          }
                        },
                        child: Consumer<UserPostProvider>(
                          builder: (context, userPostProvider, child) {
                            return Container(
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: (userPostProvider.isLikePressed)
                                    ? ColorPalette.primaryContainer
                                    : ColorPalette.lightGreyColor,
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 5, 5),
                                    child: Icon(
                                      (userPostProvider.isLikePressed)
                                          ? Icons.thumb_up_alt_rounded
                                          : Icons.thumb_up_alt_outlined,
                                      color: ColorPalette.whiteColor,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 5, 10, 5),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "${context.read<UserPostProvider>().selectedPostLikeNum}",
                                        style: TextStyle(
                                          color: ColorPalette.whiteColor,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      // 2023.09.16, jdk
                      // TODO
                      // 북마크 코드 개선 필요
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
                                    "북마크",
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
                              onPressed: postComment,
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
                      "댓글 ${context.read<UserPostProvider>().userCommentList.length}",
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
                      child: Consumer<UserPostProvider>(
                        builder: (_, userPostProvider, __) {
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return UserPostComment(index: index);
                            },
                            itemCount: userPostProvider.userCommentList.length,
                          );
                        },
                      )
                      // child: FutureBuilder<List<UserComment>>(
                      //   future: PostServices.getUserComments(rid),
                      //   builder: (context, snapshot) {
                      //     if (snapshot.connectionState ==
                      //         ConnectionState.waiting) {
                      //       return CircularProgressIndicator();
                      //     } else if (snapshot.hasError) {
                      //       return Text('Error: ${snapshot.error}');
                      //     } else if (snapshot.hasData) {
                      //       Log.logger
                      //           .d("fetched comment data : ${snapshot.data}");

                      //       List<UserComment> comments = snapshot.data!;
                      //       return ListView.builder(
                      //         itemCount: comments.length,
                      //         itemBuilder: (context, index) {
                      //           return UserPostComment();
                      //         },
                      //       );
                      //     } else {
                      //       // 에러 처리 자세하게 필요.
                      //       return Text("Error.");
                      //     }
                      //   },
                      // ),
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
