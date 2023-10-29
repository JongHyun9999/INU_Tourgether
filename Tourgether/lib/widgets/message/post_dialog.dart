import 'package:TourGather/providers/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../enums/alert_message_type.dart';
import '../../providers/gps_provider.dart';
import '../../providers/main_screen_ui_provider.dart';
import '../../services/post_services.dart';
import '../../utilities/color_palette.dart';
import '../../utilities/log.dart';

Widget? showFloatingActionButton(
  BuildContext context,
  bool isListeningGPSPositionStream,
  bool isAppBarVisible,
  TextEditingController titleController,
  TextEditingController contentController,
) {
  return Padding(
    padding: EdgeInsets.zero,
    child: FloatingActionButton(
      backgroundColor: ColorPalette.primaryContainer,
      onPressed: (isAppBarVisible)
          ? () async {
              await showPostContent(
                context,
                isListeningGPSPositionStream,
                titleController,
                contentController,
              ).then(
                (alertMessageType) {
                  if (alertMessageType == AlertMessageType.postCancel) {
                    return;
                  } else {
                    // TODO
                  }
                },
              );
            }
          : () {
              // true로 하면 설정 불가능. 업데이트되지 않기 때문에 true설정하면 실행 불가.
              // Provider.of<MainScreenUIProvider>(context, listen: false)
              //     .changeAppBarsVisibility();
            },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      child: FaIcon(
        // (isAppBarVisible) ? FontAwesomeIcons.plus : FontAwesomeIcons.arrowUp,
        FontAwesomeIcons.plus,
        color: ColorPalette.whiteColor,
      ),
    ),
  );
}

(bool, bool) checkContentsEmpty(Map<String, dynamic> postData) {
  bool isTitleEmpty = false;
  bool isContentEmpty = false;

  if (postData['title'] == "") {
    isTitleEmpty = true;
  }

  if (postData['content'] == "") {
    isContentEmpty = true;
  }

  return (isTitleEmpty, isContentEmpty);
}

// 2023.08.07, jdk
// Either를 사용하여 성공과 실패 분류
Future<bool> sendPost(
  double? currentLatitudeForPost,
  double? currentLongitudeForPost,
  Map<String, dynamic> postData,
  TextEditingController contentController,
  TextEditingController titleController,
) async {
  // 2023.07.29, jdk
  // 글 작성(SEND) 버튼을 눌렀을 때의 동작.
  // HTTP 통신을 통해 데이터를 DB에 전달한다.

  // 2023.08.07, jdk
  // 위치가 지정되지 않은 경우. GPS가 켜져 있지 않은 상태이다.
  // 이후에는 자유 게시판에 작성이 가능하도록 바꾸도록 한다.
  // 현재는 작성 기능이 쪽지로 제한되어 있으므로 임시로 허용한다.

  if (currentLatitudeForPost == null || currentLongitudeForPost == null) {
    currentLatitudeForPost = -1.1;
    currentLongitudeForPost = -1.1;
  }

  postData['latitude'] = currentLatitudeForPost;
  postData['longitude'] = currentLongitudeForPost;

  contentController.clear();
  titleController.clear();

  // --------------------------------------------
  // 2023.07.29, jdk
  // await을 통해 비동기적으로 처리하도록 한다.
  // 이후에는 올바른 error 처리를 위해 catchError가
  // 올바르게 동작하는지 확인이 필요하다.
  // --------------------------------------------
  // 2023.08.07, jdk
  // true/false로 return이 구분되며, true는 API 성공,
  // false일 경우 API 실패로 구분된다.
  // --------------------------------------------
  bool isPostSucceeded = await PostServices.postUserContent(postData);

  if (isPostSucceeded) {
    return true;
  } else {
    return false;
  }
}

InputDecoration getCustomTitleInputDecoration(
    bool isTitleEmpty, BuildContext context) {
  String hintText = "제목";
  TextStyle? hintStyle;

  if (isTitleEmpty) {
    hintText = "제목을 입력해 주세요.";
    hintStyle = TextStyle(
      color: ColorPalette.accentColor,
      fontSize: 13,
      fontFamily: 'Pretendard',
    );
  }

  return InputDecoration(
    hintText: hintText,
    hintStyle: hintStyle,
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: ColorPalette.normalColor),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide:
          BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
    ),
  );
}

InputDecoration getCustomContentInputDecoration(
    bool isContentEmpty, BuildContext context) {
  String? hintText;
  TextStyle? hintStyle;

  if (isContentEmpty) {
    hintText = "내용을 입력해 주세요.";
    hintStyle = TextStyle(
      color: ColorPalette.accentColor,
      fontSize: 13,
      fontFamily: 'Pretendard',
    );
  }

  return InputDecoration(
    hintText: hintText,
    hintStyle: hintStyle,
    helperText: "현재 위치에 쪽지를 떨어트립니다.",
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: ColorPalette.normalColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer),
    ),
  );
}

// 2023.07.29, jdk
// 이전에는 inputContent라는 이름이었으나,
// 직관성 확보를 위해 displayPostContent로 이름을 교체함.
Future<dynamic> showPostContent(
  BuildContext context,
  bool isListeningGPSPositionStream,
  TextEditingController titleController,
  TextEditingController contentController,
) {
  // ----------------------------------------------------------------
  // 2023.07.29, jdk
  // 이 위치에서 Provider의 변수에 접근하면 AlertDialog가 열리지 않음.
  // 왜 그런 것인지 생각해 볼 필요가 있음.
  // 그런데, 변수에 접근하는게 아니라 함수에 접근하는 것은 가능함.
  // 따라서 우선적으로, 필요한 변수들을 gps_provider에 선언하고 사용함.
  // ----------------------------------------------------------------
  // bool isListeningGPSPositionStream =
  //     Provider.of<GPSProvider>(context).isListeningGPSPositionStream;
  // ----------------------------------------------------------------
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final gpsProvider = Provider.of<GPSProvider>(context, listen: false);

  // GPSProvider를 통해서 현재 사용자의 위치를 가져온다.
  gpsProvider.setCurrentPositionForPost();

  // ------------------------------------------------------------------------
  // 2023.08.07, jdk
  // Another exception was thrown: Tried to listen to a value exposed with provider,
  // from outside of the widget tree.
  // Widget Tree 밖에서 Provider 접근을 시도하면 이와 같은 오류가 발생함.
  // 따라서 Widget Tree에서 함수에 인자로 전달해 주어야 할 듯 하다.
  // 해당 오류가 발생하는 이유는 state가 바뀔 때, 재랜더링이 필요하지 않은 곳에서
  // listen: true를 사용했기 때문이다. (혹은 watch())
  // 이 경우, listen: false를 사용하거나, read()를 사용하면 된다.

  // gpsProvider.isListeningGPSPositionStream
  // ------------------------------------------------------------------------

  // 다이얼로그 열기
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      final mainScreenUIProvider =
          Provider.of<MainScreenUIProvider>(context, listen: false);

      return AlertDialog(
        backgroundColor: Colors.white,
        shadowColor: Colors.grey,
        content: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.1,
                  width: screenWidth * 0.8,
                  child: Consumer<MainScreenUIProvider>(
                    builder: (context, provider, child) {
                      return TextField(
                        controller: titleController,
                        maxLength: 20,
                        maxLines: 1,
                        decoration: getCustomTitleInputDecoration(
                            provider.isTitleEmpty, context),
                      );
                    },
                  ),
                ),
                // 2023.07.29, jdk
                // 현재 GPS가 측정 중이라면 <+> 버튼을 눌렀을 때
                // 사용자의 위치를 기록하여 보여준다.
                // 이후에는 Matching 알고리즘을 거쳐서, 어디에 위치하고 있는지
                // Location(ex. 정보기술대학 A동, 12호관 학생식당 근처 등)으로 나타내도록 한다.
                Container(
                  height: screenHeight * 0.3,
                  width: screenWidth * 0.8,
                  // 2023.08.07, jdk
                  // 이 부분에 Boiler Plate 코드가 많은데,
                  // hintText를 non-final로 설정하면 짧게 만들 수 있다.
                  //
                  child: Consumer<MainScreenUIProvider>(
                    builder: (context, provider, child) {
                      return TextField(
                        controller: contentController,
                        // maxLines : 한 번에 보여줄 최대 Line의 수
                        minLines: 10,
                        maxLines: 50,
                        maxLength: 50,
                        decoration: getCustomContentInputDecoration(
                            provider.isContentEmpty, context),
                      );
                    },
                  ),
                ),
                Container(
                  height: screenHeight * 0.1,
                  width: screenWidth * 0.8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (gpsProvider.isListeningGPSPositionStream)
                          // GPS가 켜진 상태. 이후에 판단 알고리즘 추가.
                          ? Text(
                              "현재 위치 : 정보기술대학 근처",
                              style: TextStyle(
                                fontSize: 15,
                                color: ColorPalette.normalColor,
                              ),
                            )
                          : Text(
                              "현재 위치 : 인천대학교 어딘가",
                              style: TextStyle(
                                fontSize: 15,
                                color: ColorPalette.normalColor,
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        actions: [
          Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2023.08.07, jdk
                // Expanded가 아닌 Flexible을 적용하면
                // 확장이 안되는데, 이유가 뭔지 알아볼 필요 있음.
                Expanded(
                  child: Container(
                    child: ElevatedButton(
                      child: Text(
                        '쪽지 남기기',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor: ColorPalette.primaryContainer),
                      onPressed: () async {
                        Map<String, dynamic> postData = {};
                        postData['title'] = titleController.text;
                        postData['content'] = contentController.text;
                        postData['user_name'] =
                            context.read<UserInfoProvider>().userName;

                        var postedTime = DateTime.now();
                        postData['posted_time'] =
                            postedTime.toString().substring(0, 19);
                        Log.logger.d(
                          "posted_time : ${postData['posted_time']}",
                        );

                        // 2023.08.07, jdk
                        // 빈 곳만 hintText를 바꾸도록 코드 수정
                        bool isTitleEmpty, isContentEmpty;
                        (isTitleEmpty, isContentEmpty) =
                            checkContentsEmpty(postData);

                        Log.logger.d("$isTitleEmpty $isContentEmpty");

                        if (isTitleEmpty || isContentEmpty) {
                          Log.logger.d("Text Field is Empty");
                          mainScreenUIProvider.detectEmptyTextField(
                              isTitleEmpty, isContentEmpty);
                          return;
                        }

                        // 2023.09.02, jdk
                        // 입력한 데이터를 바탕으로 post를 전송한다.
                        bool isPostSucceeded = await sendPost(
                          gpsProvider.latitude,
                          gpsProvider.longitude,
                          postData,
                          titleController,
                          contentController,
                        );

                        // 키보드가 올라와 있을 경우 키보드를 화면 아래로 내린다.
                        FocusManager.instance.primaryFocus?.unfocus();

                        AlertMessageType alertMessageType;
                        if (isPostSucceeded) {
                          alertMessageType = AlertMessageType.postSucceeded;
                        } else {
                          alertMessageType = AlertMessageType.postApiError;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('성공적으로 등록했습니다.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        Navigator.of(context).pop(alertMessageType);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: ElevatedButton(
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: ColorPalette.accentColor,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      style:
                          TextButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () {
                        // 키보드가 올라와 있을 경우 키보드를 화면 아래로 내린다.
                        FocusManager.instance.primaryFocus?.unfocus();

                        Map<String, dynamic> postResult = {
                          'isPostSucceeded': false,
                          'meesageType': AlertMessageType.postCancel,
                        };

                        // 2023.08.07, jdk
                        // postDialog가 종료될 때, textFieldEmpty 판단을 위해 사용된
                        // 변수들의 상태를 초기화 한다.
                        mainScreenUIProvider.onPostDialogClosed();

                        // 2023.08.07, jdk
                        // 이후에 임시 저장 기능 만들기.
                        titleController.clear();
                        contentController.clear();

                        Navigator.of(context).pop(postResult);
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    },
  );
}
