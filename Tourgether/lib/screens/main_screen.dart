import 'package:TourGather/providers/main_screen_ui_provider.dart';
import 'package:TourGather/widgets/app_bars.dart';
import 'package:flutter/material.dart';
import 'package:TourGather/providers/gps_provider.dart';
import 'package:provider/provider.dart';
import '../utilities/log.dart';
import '../widgets/nav_bar.dart';
import '../widgets/post_dialog.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
  final double backgroundImageWidth = 2000;
  final double backgroundImageHeight = 1800;
  // final double backgroundImageWidth = 2043;
  // final double backgroundImageHeight = 1903;

  bool isListeningGPSPositionStream = false;
  late double currentLatitudeForPost;
  late double currentLongitudeForPost;

  TextEditingController contentController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();

    // Future.microtask(
    //   () => Provider.of<UserInfoProvider>(context, listen: false).initUserInfo(),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final double bottomNavigationBarHeight = 60;
    final double appBarHeight = 50;

    final gpsProvider = Provider.of<GPSProvider>(context, listen: false);
    final mainScreenUIProvider =
        Provider.of<MainScreenUIProvider>(context, listen: false);

    bool showPostThing = false;
    return Scaffold(
      drawer: const NavBar(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ), // getAppBar(context, appBarHeight),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      floatingActionButton:
          (context.read<MainScreenUIProvider>().isAppBarVisible)
              ? showFloatingActionButton(
                  context,
                  gpsProvider.isListeningGPSPositionStream,
                  Provider.of<MainScreenUIProvider>(context).isAppBarVisible,
                  titleController,
                  contentController,
                )
              : null,
      bottomNavigationBar:
          (Provider.of<MainScreenUIProvider>(context).isAppBarVisible)
              ? getBottomAppBar(
                  context,
                  bottomNavigationBarHeight,
                )
              : null,
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: -(backgroundImageWidth / 2 - screenWidth / 2),
              top: -(backgroundImageHeight / 2 - screenHeight / 2),
              child: Container(
                width: backgroundImageWidth,
                height: backgroundImageHeight,
                child: GestureDetector(
                  // 2023.08.14, jdk
                  // InteractiveVeiwer를 GestureDetector로 감싸서 Interaction Callback을 지정하면
                  // 이벤트를 먼저 처리해서 InteractiveViewer에서 발생하지 않도록 할 수 있다.
                  // onTapUP 이벤트를 지정해서 사용자가 Map을 한 번 터치했을 떄는 다른 이벤트를 처리하고,
                  // 그게 아니라면 (Pan/Scale) 다른 Callback을 처리하도록 한다.
                  onTapUp: (_ /*TapUpDetails details*/) {
                    Log.logger
                        .d("OnInteractionStart Callback Function Called.");

                    mainScreenUIProvider.changeAppBarsVisibility();
                  },
                  child: InteractiveViewer(
                    constrained: false,
                    transformationController: _transformationController,
                    // onInteractionStart: (details) {},
                    onInteractionEnd: (details) {
                      // Log.logger
                      //    .d("OnInteractionEnd Callback Function Called.");

                      Matrix4 transformationMatrix =
                          _transformationController.value;

                      // Log.logger.d("${transformationMatrix}");

                      double newScaleValue =
                          transformationMatrix.getMaxScaleOnAxis();

                      // ---------------------------------------------------------------------------
                      // 2023.08.09, jdk
                      // InteractiveViewer에 등록한 controller는 매 업데이트마다
                      // Matrix4 객체를 갱신한다. (transformationController.value)
                      // Matrix4는 4x4 Size이며, Translate Matrix, Rotation Matrix로 나타내어진다.
                      // transformationMatrix[12]와 [13]은 x, y축 이동량을 의미한다.

                      // logger.d("${transformationMatrix}");
                      // logger.d("${transformationMatrix[12]}");
                      // logger.d("${transformationMatrix[13]}");
                      // ---------------------------------------------------------------------------

                      // 2023.08.09, jdk
                      // Scale Level의 변화를 체크하는 파트.
                      // 만약 Scale Level이 달라진다면, MainScreenUIProvider의 변수인
                      // currentScaleValue를 갱신한다. 이후에는 확대 레벨에 맞춰서
                      // InteractiveViewer에 대한 margin 값을 조정하면 된다.

                      bool isMapScaled = false;

                      // Scale Level의 변화를 감지하는 부분
                      // if (mainScreenUIProvider
                      //         .compareNewScaleValueWithPrev(newScaleValue) ==
                      //     false) {
                      //   mainScreenUIProvider.currentScaleValue = newScaleValue;

                      //   isMapScaled = true;
                      //   Log.logger.d("scaleValue is equal");
                      // }

                      mainScreenUIProvider
                          .compareNewScaleValueWithPrev(newScaleValue);

                      // // 새롭게 들어온 Map의 X, Y 데이터가 이전의 데이터와 같은지 비교하는 부분.
                      // // 만약 데이터가 같다면 사용자가 Map을 한 번만 터치한 것으로 판단할 수 있다.

                      // double newMapPositionX =
                      //     transformationMatrix[12]; // 새로운 X pos
                      // double newMapPositionY =
                      //     transformationMatrix[13]; // 새로운 Y pos

                      // // 디버깅용 출력
                      // Log.logger.d("newMapPosX : ${newMapPositionX}");
                      // Log.logger.d("newMapPosY : ${newMapPositionY}");

                      // // 새로운 좌표가 이전 좌표와 같은지 비교한다.
                      // // 값이 true라면 사용자가 화면을 한 번 터치한 경우이거나
                      // // 화면을 Scaling한 경우라고 판단할 수 있다.
                      // if (mainScreenUIProvider.compareNewPositionWithPrev(
                      //   newMapPositionX,
                      //   newMapPositionY,
                      // )) {
                      //   // 좌표가 같다면 현재 AppBar가 Invisible인지 파악한다.
                      //   // AppBar가 Invisible이라면 AppBar의 Visibility를 Visible로 바꾼다.
                      //   // 그런데, 만약 Map이 Scaled 되었다면 화면 터치가 아니므로
                      //   // isMapScaled == false도 판단한다.
                      //   Log.logger.d("it's true!");

                      //   Log.logger.d(
                      //     "isAppBarVisible : ${mainScreenUIProvider.isAppBarVisible}",
                      //   );

                      //   Log.logger.d("isMapScaled : ${isMapScaled}");

                      //   if (mainScreenUIProvider.isAppBarVisible == false &&
                      //       isMapScaled == false) {
                      //     Log.logger.d("Change Visibility!");
                      //     mainScreenUIProvider.changeAppBarsVisibility();
                      //   }
                      // }

                      // // 새롭게 들어온 좌표로 기존 좌표 변수를 갱신한다.
                      // mainScreenUIProvider.changeMapPosition(
                      //   newMapPositionX,
                      //   newMapPositionY,
                      // );
                    },
                    scaleEnabled: false,
                    maxScale: 1.0,
                    minScale: 0.25,
                    // 2023.07.27, jdk
                    // 지도 위치 조정 과정 확인 필요
                    boundaryMargin: EdgeInsets.fromLTRB(
                        // (backgroundImageWidth - screenWidth) / 2 -
                        //     520 * (mainScreenUIProvider.currentScaleValue - 1),
                        // (backgroundImageHeight - screenHeight) / 2 -
                        //     130 * (mainScreenUIProvider.currentScaleValue - 1),
                        // (backgroundImageWidth - screenWidth) / 2 -
                        //     515 * (mainScreenUIProvider.currentScaleValue - 1),
                        // (backgroundImageHeight - screenHeight) / 2 +
                        //     20 -
                        //     148 * (mainScreenUIProvider.currentScaleValue - 1),
                        (backgroundImageWidth - screenWidth) / 2,
                        (backgroundImageHeight - screenHeight) / 2,
                        (backgroundImageWidth - screenWidth) / 2,
                        (backgroundImageHeight - screenHeight) / 2 -
                            bottomNavigationBarHeight
                        // 원래는 BottomNavigationBarHeight만큼 더해야 하나,
                        // 아직 Custom Map이 완성되지 않아 임시로 Hard Coding 한다.
                        ),
                    // boundaryMargin: EdgeInsets.symmetric(
                    //   vertical: 2500,
                    //   horizontal: 3000,
                    // ),
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
                            image: AssetImage("images/inu-map.png"),
                            fit: BoxFit.cover,
                          ),
                        ),

                        // 2023.07.29, jdk
                        // Map Image 위에 아이콘을 표시하기 위하여
                        // Positioned Widget을 위치시켜야 하는 부분.
                        // Positioned(
                        //   left: backgroundImageWidth / 2,
                        //   top: backgroundImageHeight / 2,
                        //   child: IconButton(
                        //     icon: Icon(Icons.local_post_office),
                        //     onPressed: () {
                        //       print("Touched!");
                        //     },
                        //     color: Colors.blueAccent,
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Positioned(
            //   left: 0,
            //   top: 0,
            //   child: Opacity(
            //     opacity: 0.6,
            //     child: Container(
            //       width: backgroundImageWidth,
            //       height: backgroundImageHeight,
            //       color: Colors.red,
            //     ),
            //   ),
            // ),
          ],
        ),
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
