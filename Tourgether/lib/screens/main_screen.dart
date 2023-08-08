import 'package:TourGather/providers/main_screen_ui_provider.dart';
import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:TourGather/providers/gps_provider.dart';
import 'package:TourGather/services/post_services.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../enums/alert_message_type.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  // ------------------------------------------
  // 2023.07.29, jdk
  // 왜 이 변수는 const로 선언될 수 없는가?
  // Only static fields can ...
  // TODO
  // ------------------------------------------
  // 2023.08.04, jdk
  // width/height 설정은 추후에 utilities로 모두 넘기기.
  // TODO
  // ------------------------------------------
  final double backgroundImageWidth = 2470;
  final double backgroundImageHeight = 1321;

  bool isListeningGPSPositionStream = false;
  late double currentLatitudeForPost;
  late double currentLongitudeForPost;

  TextEditingController contentController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  TransformationController _transformationController =
      TransformationController();

  double currentScaleValue = 1;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final double bottomNavigationBarHeight = 60;
    final double appBarHeight = 50;

    final gpsProvider = Provider.of<GPSProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          // 2023.08.07, jdk
          // Circular Border AppBar
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.vertical(
          //     bottom: Radius.circular(30),
          //   ),
          // ),
          backgroundColor: ColorPalette.primaryContainer,
          leading: IconButton(
            iconSize: 30,
            onPressed: () {},
            icon: Icon(
              Icons.menu,
              color: ColorPalette.onPrimaryContainer,
            ),
          ),
          actions: [
            IconButton(
              iconSize: 30,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/locationSetting",
                );
              },
              icon: Icon(
                Icons.location_on,
                color: ColorPalette.primaryContainer,
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      floatingActionButton: showFloatingActionButton(
        context,
        gpsProvider.isListeningGPSPositionStream,
      ),
      bottomNavigationBar: Container(
        height: bottomNavigationBarHeight,
        child: BottomAppBar(
          color: ColorPalette.primaryContainer,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            "/userPostList",
                          );
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.listUl,
                          color: ColorPalette.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: FaIcon(
                          FontAwesomeIcons.solidComments,
                          color: ColorPalette.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: FaIcon(
                          FontAwesomeIcons.userGroup,
                          color: ColorPalette.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: FaIcon(
                          FontAwesomeIcons.trophy,
                          color: ColorPalette.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: -(backgroundImageWidth / 2 - screenWidth / 2),
              top: -(backgroundImageHeight / 2 - screenHeight / 2),
              child: Container(
                width: backgroundImageWidth,
                height: backgroundImageHeight,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  onInteractionEnd: (details) {
                    double correctScaleValue =
                        _transformationController.value.getMaxScaleOnAxis();

                    if (correctScaleValue != currentScaleValue) {
                      currentScaleValue = correctScaleValue;
                      logger.d("currentScaleValue : $currentScaleValue");
                    }
                  },
                  scaleEnabled: true,
                  maxScale: 2.0,
                  minScale: 1.0,
                  // 2023.07.27, jdk
                  // 지도 위치 조정 과정 확인 필요
                  boundaryMargin: EdgeInsets.fromLTRB(
                    (backgroundImageWidth - screenWidth) / 2,
                    (backgroundImageHeight - screenHeight) / 2 +
                        appBarHeight +
                        statusBarHeight,
                    (backgroundImageWidth - screenWidth) / 2,
                    (backgroundImageHeight - screenHeight) / 2 + 20,
                    // 원래는 BottomNavigationBarHeight만큼 더해야 하나,
                    // 아직 Custom Map이 완성되지 않아 임시로 Hard Coding 한다.
                  ),
                  child: Stack(
                    children: [
                      /* 
                        2023.07.27, jdk
                        Custom Map과 같은 Level에서 Message를 생성.
                        이후에는 함수를 통해서 생성하도록 자동화한다.
    
                        현재는 임시적인 확인을 위해 Icon을 하드코딩으로 띄워두도록 함.
                      */
                      Positioned(
                        child: Image(
                          image: AssetImage("images/test-map4.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      /* 
                      // 2023.07.29, jdk
                      // Map Image 위에 아이콘을 표시하기 위하여
                      // Positioned Widget을 위치시켜야 하는 부분.
                      Positioned(
                        left: backgroundImageWidth / 2,
                        top: backgroundImageHeight / 2,
                        child: IconButton(
                          icon: Icon(Icons.local_post_office),
                          onPressed: () {
                            print("Touched!");
                          },
                          color: Colors.blueAccent,
                        ),
                      ),
                      */
                    ],
                  ),
                ),
              ),
            ),
          ],
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
  ) async {
    // 2023.07.29, jdk
    // 글 작성(SEND) 버튼을 눌렀을 때의 동작.
    // HTTP 통신을 통해 데이터를 DB에 전달한다.

    var postedTime = DateTime.now();
    logger.d("${DateTime.now().timeZoneName}");
    logger.d("current time : $postedTime");

    // 유저 정보를 보관하는 Class에서 유저의 정보를 가져와야 함.
    postData['user_id'] = 'test';
    postData['posted_time'] = postedTime.toString().substring(0, 19);

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

  InputDecoration getCustomTitleInputDecoration(bool isTitleEmpty) {
    String hintText = "제목";
    TextStyle? hintStyle;

    if (isTitleEmpty == true) {
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

  InputDecoration getCustomContentInputDecoration(bool isContentEmpty) {
    String? hintText;
    TextStyle? hintStyle;

    if (isContentEmpty == true) {
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
      BuildContext context, bool isListeningGPSPositionStream) {
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
      barrierDismissible: false,
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
                          provider.isTitleEmpty,
                        ),
                      );
                    }),
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
                            provider.isContentEmpty,
                          ),
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

                          logger.d("${postData['title']}");

                          // 2023.08.07, jdk
                          // 빈 곳만 hintText를 바꾸도록 코드 수정
                          bool isTitleEmpty, isContentEmpty;
                          (isTitleEmpty, isContentEmpty) =
                              checkContentsEmpty(postData);

                          logger.d("$isTitleEmpty $isContentEmpty");

                          if (isTitleEmpty == true || isContentEmpty == true) {
                            logger.d("Text Field is Empty");
                            mainScreenUIProvider.detectEmptyTextField(
                                isTitleEmpty, isContentEmpty);
                            return;
                          }

                          bool isPostSucceeded = await sendPost(
                            gpsProvider.latitude,
                            gpsProvider.longitude,
                            postData,
                          );

                          // 키보드가 올라와 있을 경우 키보드를 화면 아래로 내린다.
                          FocusManager.instance.primaryFocus?.unfocus();

                          AlertMessageType alertMessageType;
                          if (isPostSucceeded) {
                            alertMessageType = AlertMessageType.postSucceeded;
                          } else {
                            alertMessageType = AlertMessageType.postApiError;
                          }

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

  Widget? showFloatingActionButton(
      BuildContext context, bool isListeningGPSPositionStream) {
    return FloatingActionButton(
      backgroundColor: ColorPalette.primaryContainer,
      onPressed: () async {
        await showPostContent(context, isListeningGPSPositionStream).then(
          (alertMessageType) {
            if (alertMessageType == AlertMessageType.postCancel) {
              return;
            } else {
              // TODO
            }
          },
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      child: FaIcon(
        FontAwesomeIcons.plus,
        color: Colors.white,
      ),
    );
  }

  // -------------------------------------------------------------
  // 2023.07.29, jdk
  // 이름을 floatingButtons에서  showFloatingActionButtons로 교체

  // 2023.08.04, jdk
  // 현재 floatingActionButton을 처음 터치할 때 애니메이션이 나오지 않는
  // 버그가 있음. 추후에 수정이 필요함.

  // 2023.08.06, jdk
  // 기능의 단순화를 위하여 SpeedDial을 임시적으로 주석처리 하고,
  // FloatingActionButton 단일 기능으로 축소한다.
  // -------------------------------------------------------------

  /*
  Widget? showFloatingActionButtons(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      // backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: Colors.white,
      overlayColor: Colors.black,
      childMargin: EdgeInsets.all(20.0),
      spaceBetweenChildren: 15,
      children: [
        // 글 작성 IconButton
        SpeedDialChild(
          child: Icon(
            Icons.add_comment,
            color: Colors.blueAccent,
          ),
          backgroundColor: Colors.white,
          label: "쪽지 남기기",
          labelBackgroundColor: Colors.blueAccent,
          labelStyle: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 15,
          ),
          onTap: () {
            // 2023.07.29, jdk
            // listen: false로 설정하면, 함수 실행 후에 UI를 업데이트 하지 않는다.
            final provider = Provider.of<GPSProvider>(context, listen: false);
            isListeningGPSPositionStream =
                provider.isListeningGPSPositionStream;

            // isListeningGPSPostionStream이 true이면, 현재 GPS가 켜져있는 것이므로,
            // 쪽지를 작성할 때 현재 위치가 표시되도록 해야 한다.
            // 따라서 GPSProvider로부터 Position.latitude, Position.longitude를
            // main_screen의 변수에 기록해둔다. (작성하기 시작한 위치 기록)
            if (isListeningGPSPositionStream) {
              currentLatitudeForPost = provider.latitude!;
              currentLongitudeForPost = provider.longitude!;
            }

            displayPostContent(context);
          },
        ),
      ],
    );
  }
  */
}
