import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mytourgether/providers/gps_provider.dart';
import 'package:mytourgether/services/post_services.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
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

  // 2023.07.29, jdk
  // 이전에는 inputContent라는 이름이었으나,
  // 직관성 확보를 위해 displayPostContent로 이름을 교체함.
  Future<void> displayPostContent(BuildContext context) {
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

    // 다이얼로그 열기
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '어떤 내용을 남기고 싶나요?',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.grey,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 2023.07.29, jdk
              // 현재 GPS가 측정 중이라면 <쪽지 작성> 버튼을 눌렀을 때
              // 사용자의 위치를 기록하여 보여준다.
              // 이후에는 Matching 알고리즘을 거쳐서, 어디에 위치하고 있는지
              // Location(ex. 정보기술대학 A동, 12호관 학생식당 근처 등)으로 나타내도록 한다.
              isListeningGPSPositionStream
                  ? Text(
                      "현재 위치 : ${currentLatitudeForPost} ${currentLongitudeForPost}",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                      ),
                    )
                  : Text(
                      "현재 위치 : N/A",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                      ),
                    ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: '내용',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontFamily: 'Pretendard',
                  ),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'SEND',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Pretendard',
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size.fromHeight(25),
              ),
              onPressed: () async {
                // 2023.07.29, jdk
                // 글 작성(SEND) 버튼을 눌렀을 때의 동작.
                // HTTP 통신을 통해 데이터를 DB에 전달한다.

                var postedTime = DateTime.now();
                logger.d("current time : " + postedTime.toString());

                Map<String, dynamic> postData = {};
                postData['user_id'] = 'jdk';
                postData['content'] = contentController.text;
                postData['posted_time'] =
                    postedTime.toString().substring(0, 19);
                postData['latitude'] = currentLatitudeForPost;
                postData['longitude'] = currentLongitudeForPost;

                logger.d("postData : ${postData}");

                // 2023.07.29, jdk
                // await을 통해 비동기적으로 처리하도록 한다.
                // 이후에는 올바른 error 처리를 위해 catchError가
                // 올바르게 동작하는지 확인이 필요하다.
                await PostServices.postUserContent(postData).then((_) {
                  contentController.clear();
                  Navigator.of(context).pop();
                }).catchError((error) {
                  logger.e("Error on PostServices. ${error}");
                });
              },
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // 2023.07.29, jdk
  // 이름을 floatingButtons에서 displayFloatingActionButtons로 교체

  // 2023.08.04, jdk
  // 현재 floatingActionButton을 처음 터치할 때 애니메이션이 나오지 않는
  // 버그가 있음. 추후에 수정이 필요함.
  // -------------------------------------------------------------
  Widget? displayFloatingActionButtons(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      overlayColor: Colors.black,
      childMargin: EdgeInsets.all(20.0),
      spaceBetweenChildren: 15,
      children: [
        // 글 작성 IconButton
        SpeedDialChild(
          child: Icon(
            Icons.local_post_office,
            color: Colors.blueAccent,
          ),
          backgroundColor: Colors.white,
          label: "쪽지 작성하기",
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButton: displayFloatingActionButtons(context),
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
                  minScale: 1.0,
                  // 2023.07.27, jdk
                  // 지도 위치 조정 과정 확인 필요
                  boundaryMargin: EdgeInsets.fromLTRB(
                    (backgroundImageWidth - screenWidth) / 2,
                    (backgroundImageHeight - screenHeight) / 2,
                    (backgroundImageWidth - screenWidth) / 2,
                    (backgroundImageHeight - screenHeight) / 2,
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
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 25, 0, 0),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Color.fromARGB(255, 200, 231, 247),
                        child: IconButton(
                          icon: Icon(
                            Icons.menu,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/userPostList",
                            );
                          },
                          color: Colors.blueAccent,
                          iconSize: 30,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 25, 10, 0),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Color.fromARGB(255, 200, 231, 247),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/locationSetting",
                            );
                          },
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                          ),
                          iconSize: 30,
                        ),
                      ),
                    )
                  ],
                ),
                width: screenWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
