import 'package:flutter/material.dart';
import 'package:mytourgether/providers/gps_provider.dart';
import 'package:mytourgether/screens/location_setting_screen.dart';
import 'package:mytourgether/screens/main_screen.dart';
// import 'package:like_button/like_button.dart';
// import 'package:mytourgether/models/messageFormat.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mytourgether/screens/signin_screen.dart';
import 'package:provider/provider.dart';

// import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GPSProvider(),
        )
      ],
      child: MaterialApp(
        title: 'TourGather',
        routes: {
          "/signin": (context) => const LoginSignupScreen(),
          "/main": (context) => MainScreen(),
          "/locationSetting": (context) => LocationSettingScreen(),
        },
        initialRoute: "/signin",
        debugShowCheckedModeBanner: false,
        home: LoginSignupScreen(),
      ),
    );
  }
}

// 2023.07.28, jdk
// 아래 주석처리된 코드는 중간 보고 이전에 사용한 코드들로,
// 임시적인 확인을 위해 만들어진 코드들임. 

// 좋아요 버튼 변수들
  // bool isLiked = false;

  // // 메세지창 리스트의 스크롤링을 위한 리스트.
  // List<messageProduct> productList = [
  //   messageProduct(
  //       imagePath: 'images/ralo.gif',
  //       userName: 'Ralo12',
  //       textContent: '아니 여러분, 어떻게 비트코인을 8천만원에 주고 살수가 있어? 이건 침팬치들이야..',
  //       department: '정보기술대학',
  //       goodCount: 0),
  //   messageProduct(
  //       imagePath: 'images/monrat.png',
  //       userName: 'monseterat',
  //       textContent: '타닥타닥.. 아 우리팀 정글 또 생배야!!!',
  //       department: '공과대학',
  //       goodCount: 1),
  //   messageProduct(
  //       imagePath: 'images/paka.png',
  //       userName: 'paka9999',
  //       textContent: '도구, 또 너야?',
  //       department: '인문대학',
  //       goodCount: 20),
  //   messageProduct(
  //       imagePath: 'images/dog.jpg',
  //       userName: 'dopa24',
  //       textContent: '누나, 물~ ',
  //       department: '경영대학',
  //       goodCount: 34),
  // ];

  // // 입력된 텍스트의 컨트롤러
  // TextEditingController contentController = TextEditingController();

  // // =====================================
  // // 상단 메세지 스크롤 리스트를 생성하는 함수
  // Widget _buildListItem(BuildContext context, int index) {
  //   messageProduct product = productList[index];
  //   return Container(
  //       // height: 100,
  //       margin: EdgeInsets.all(16.0),
  //       padding: EdgeInsets.all(16.0),
  //       decoration: BoxDecoration(
  //           color: Colors.white70,
  //           borderRadius: BorderRadius.circular(20),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.grey.withOpacity(0.3),
  //               spreadRadius: 5,
  //               blurRadius: 7,
  //               offset: Offset(0, 1),
  //             )
  //           ]),
  //       child: Container(
  //         child: Row(
  //           children: [
  //             CircleAvatar(
  //               radius: 30,
  //               backgroundImage: AssetImage(product.imagePath),
  //             ),
  //             SizedBox(width: 10.0),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   product.userName,
  //                   style: TextStyle(
  //                     color: Colors.grey,
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 Container(
  //                   height: 1,
  //                   margin: EdgeInsets.only(bottom: 3.0),
  //                 ),
  //                 Container(
  //                   width: 200,
  //                   child: Text(
  //                     product.textContent,
  //                     style: TextStyle(
  //                         color: Colors.black, fontSize: 14, height: 1),
  //                   ),
  //                 ),
  //                 Container(
  //                   height: 1,
  //                   margin: EdgeInsets.only(bottom: 5.0),
  //                 ),
  //                 Row(children: [
  //                   Icon(
  //                     Icons.fmd_good,
  //                     size: 15,
  //                     color: Colors.blue,
  //                   ),
  //                   SizedBox(
  //                     width: 2,
  //                   ),
  //                   Text(
  //                     product.department,
  //                     style: TextStyle(
  //                         fontSize: 11,
  //                         color: Colors.black,
  //                         fontWeight: FontWeight.bold,
  //                         height: 1),
  //                   ),
  //                 ])
  //               ],
  //             ),
  //             SizedBox(width: 16.0),
  //             LikeButton(
  //               size: 20,
  //               isLiked: isLiked,
  //               likeCount: product.goodCount,
  //             )
  //           ],
  //         ),
  //       ));
  // }

  // // 택스트 메세지 입력
  // Future<void> inputContent(BuildContext context) {
  //   // 다이얼로그 열기
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   '무엇을 남기고 싶나요?',
  //                   style:
  //                       TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
  //                 ),
  //                 Container(
  //                   width: 25,
  //                   height: 25,
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.redAccent,
  //                       shape: CircleBorder(),
  //                     ),
  //                     child: Icon(
  //                       Icons.close,
  //                       size: 10,
  //                       color: Colors.white,
  //                     ),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                 )
  //               ]),
  //           backgroundColor: Colors.white,
  //           shadowColor: Colors.grey,
  //           surfaceTintColor: Colors.white,
  //           iconColor: Colors.white,
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 controller: contentController,
  //                 decoration: InputDecoration(
  //                     labelText: '내용',
  //                     labelStyle: TextStyle(color: Colors.grey)),
  //               )
  //             ],
  //           ),
  //           actions: [
  //             // TextButton(
  //             //   child: Text('CANCEL',
  //             //   style: TextStyle(
  //             //     color: Colors.blueAccent
  //             //   ),),
  //             //   onPressed: () {
  //             //     // 취소 눌렀을때
  //             //     Navigator.of(context).pop();
  //             //   },
  //             // ),
  //             TextButton(
  //               child: Text(
  //                 'SEND',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               style: TextButton.styleFrom(
  //                 backgroundColor: Colors.blueAccent,
  //                 minimumSize: Size.fromHeight(50),
  //               ),
  //               onPressed: () {
  //                 // 남기기 눌렀을때
  //                 setState(() {
  //                   // 입력된 메세지 내용 컨트롤
  //                   String content = contentController.text;
  //                 });
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }

  // // pjh. 우측 하단 메뉴 다이얼 버튼.
  // // 라벨을 붙이기에 색깔 선정이 어려워서 주석처리하였습니다.
  // Widget? floatingButtons() {
  //   return SpeedDial(
  //     animatedIcon: AnimatedIcons.menu_close,
  //     visible: true,
  //     curve: Curves.bounceIn,
  //     backgroundColor: Colors.blueAccent,
  //     foregroundColor: Colors.white,
  //     overlayColor: Colors.black,
  //     childMargin: EdgeInsets.all(20.0),
  //     spaceBetweenChildren: 15,
  //     children: [
  //       SpeedDialChild(
  //           // 글 작성하는 버튼
  //           child: Icon(
  //             Icons.border_color_rounded,
  //             color: Colors.blueAccent,
  //           ),
  //           backgroundColor: Colors.white,

  //           // label: "글 남기기",
  //           // labelBackgroundColor: Colors.white,
  //           // labelStyle: TextStyle(
  //           //     fontWeight: FontWeight.bold,
  //           //     color: Colors.blueAccent,
  //           //     fontSize: 13),
  //           onTap: () => inputContent(context)),
  //       SpeedDialChild(
  //           // 설정 버튼
  //           child: Icon(Icons.settings, color: Colors.blueAccent),
  //           backgroundColor: Colors.white,
  //           // label: "설정",
  //           // labelBackgroundColor: Colors.transparent,
  //           // labelStyle: TextStyle(
  //           //     fontWeight: FontWeight.w500,
  //           //     color: Colors.white,
  //           //     fontSize: 13),
  //           onTap: () {
  //             // 버튼 클릭 시
  //           }),
  //     ],
  //   );
  // }

// 2023.07.27, jdk
// 종현이가 작성한 코드를 주석으로 옮겨놓음.

      /* Stack(children: [
        Container(
          height: 800,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.375300, 126.633259),
              zoom: 17.0,
            ),
          ),
        ),
        Container(
          // 상단 메세지 리스트 위젯.
          // pjh. 사용자의 메세지가 길어지면 메세지창 hieght를 초과할수도 있음.
          // 일정 글자 수를 넘게되면 ... 처리를 해줘야 할듯.
          // + 생략된 메세지는 클릭해서 볼수 있도록
          height: 170,
          width: 400,
          color: Colors.transparent,
          margin: EdgeInsets.only(top: 20),
          child: ScrollSnapList(
            itemBuilder: _buildListItem,
            itemCount: productList.length,
            itemSize: 384,
            onItemFocus: (index) {},
            dynamicItemSize: true,
            // scrollDirection: Axis.vertical,
          ),
        ),
      ]), */