import 'package:TourGather/providers/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<dynamic> ShowPostDetail(
  BuildContext context,
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
  final PageController controller =
      PageController(initialPage: 0, viewportFraction: 0.8);
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
        return PageView(
          scrollDirection: Axis.horizontal,
          controller: controller,
          children: [
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // 가장자리 둥글기 설정
              ),
              backgroundColor: Colors.blue[100],
              shadowColor: Colors.grey,
              content: SingleChildScrollView(
                child: Container(
                  width: 500, // 원하는 너비로 조절
                  height: 400, // 원하는 높이로 조절
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "환한 고독",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Consumer<UserInfoProvider>(
                              builder: (context, userinfo, child) {
                            return Text(
                              "${userinfo.userMajor} ${userinfo.userName}",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w100),
                            );
                          }),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Text(
                              "하동(河東)이 아무래도 나를 당기는 것 같다. 지리산이 나를 당기는가, 섬진강이 나를 끄는가. 아니면 푸른 학이 내 그림자를 물고 날고 있나, 재첩조개가 내 옷자락을 물고 입을 다물었나, 대봉시에 부리 파묻은 그 까마귀가 울음을 한 덩어리 파묻어 더 붉어지던 침묵인가. "),
                        ),
                      ),
                      Divider(color: Colors.white),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: Colors.white,
                            ),
                            iconSize: 25,
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.star,
                              color: Colors.white,
                            ),
                            iconSize: 25,
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // 가장자리 둥글기 설정
              ),
              backgroundColor: Colors.white,
              shadowColor: Colors.grey,
              content: SingleChildScrollView(
                child: Container(
                  width: 500, // 원하는 너비로 조절
                  height: 400, // 원하는 높이로 조절
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "환한 고독",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Consumer<UserInfoProvider>(
                              builder: (context, userinfo, child) {
                            return Text(
                              "${userinfo.userMajor} ${userinfo.userName}",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w100),
                            );
                          }),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Text(
                              "하동(河東)이 아무래도 나를 당기는 것 같다. 지리산이 나를 당기는가, 섬진강이 나를 끄는가. 아니면 푸른 학이 내 그림자를 물고 날고 있나, 재첩조개가 내 옷자락을 물고 입을 다물었나, 대봉시에 부리 파묻은 그 까마귀가 울음을 한 덩어리 파묻어 더 붉어지던 침묵인가. "),
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: Colors.blueAccent,
                            ),
                            iconSize: 25,
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.star,
                              color: Colors.blueAccent,
                            ),
                            iconSize: 25,
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // 가장자리 둥글기 설정
              ),
              backgroundColor: Colors.blue[100],
              shadowColor: Colors.grey,
              content: SingleChildScrollView(
                child: Container(
                  width: 500, // 원하는 너비로 조절
                  height: 400, // 원하는 높이로 조절
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "환한 고독",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Consumer<UserInfoProvider>(
                              builder: (context, userinfo, child) {
                            return Text(
                              "${userinfo.userMajor} ${userinfo.userName}",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w100),
                            );
                          }),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Text(
                              "하동(河東)이 아무래도 나를 당기는 것 같다. 지리산이 나를 당기는가, 섬진강이 나를 끄는가. 아니면 푸른 학이 내 그림자를 물고 날고 있나, 재첩조개가 내 옷자락을 물고 입을 다물었나, 대봉시에 부리 파묻은 그 까마귀가 울음을 한 덩어리 파묻어 더 붉어지던 침묵인가. "),
                        ),
                      ),
                      Divider(color: Colors.white),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: Colors.white,
                            ),
                            iconSize: 25,
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.star,
                              color: Colors.white,
                            ),
                            iconSize: 25,
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
        // return AlertDialog(
        //   backgroundColor: Colors.white,
        //   shadowColor: Colors.grey,
        //   content: Container(
        //     child: Column(
        //       children: [
        //         Container(
        //             height: screenHeight * 0.1,
        //             width: screenWidth * 0.8,
        //             child: Text("hi")),

        //         // 2023.07.29, jdk
        //         // 현재 GPS가 측정 중이라면 <+> 버튼을 눌렀을 때
        //         // 사용자의 위치를 기록하여 보여준다.
        //         // 이후에는 Matching 알고리즘을 거쳐서, 어디에 위치하고 있는지
        //         // Location(ex. 정보기술대학 A동, 12호관 학생식당 근처 등)으로 나타내도록 한다.
        //       ],
        //     ),
        //   ),
        // );
      });
}

// import 'package:flutter/material.dart';

// class MyDialogWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Dialog Title'),
//       content: SingleChildScrollView(
//         child: ListBody(
//           children: <Widget>[
//             Text('This is the content of the dialog.'),
//             Text('You can add more widgets here as needed.'),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           child: Text('Close'),
//           onPressed: () {
//             Navigator.of(context).pop(); // 다이얼로그 닫기
//           },
//         ),
//       ],
//     );
//   }
// }