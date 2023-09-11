import 'package:TourGather/providers/gps_ui_provider.dart';
import 'package:TourGather/providers/main_screen_ui_provider.dart';
import 'package:TourGather/providers/user_info_provider.dart';
import 'package:TourGather/providers/user_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:TourGather/providers/gps_provider.dart';
import 'package:TourGather/screens/location_setting_screen.dart';
import 'package:TourGather/screens/main_screen.dart';
// import 'package:like_button/like_button.dart';
// import 'package:TourGather/models/messageFormat.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:TourGather/screens/signin_screen.dart';
import 'package:TourGather/screens/user_post_list_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

// import 'package:google_fonts/google_fonts.dart';

void main() {
  // 2023.08.06, jdk
  // Splash Screen이 Initialization 시간 동안 유지되도록 만드는 설정.
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Future.delayed(Duration(seconds: 2), FlutterNativeSplash.remove);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GPSProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MainScreenUIProvider(),
        ),
        // ChangeNotifierProxyProvider<GPSProvider, GPSUIProvider>(
        //   create: (context) => GPSUIProvider(),
        //   update: (context, gpsUIProvider, prevGpsUIProvider) {
        //     return GPSUIProvider();
        //   },
        // ),
        ChangeNotifierProvider(
          create: (context) => UserPostProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserInfoProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'TourGather',
        routes: {
          "/signin": (context) => const LoginSignupScreen(),
          "/main": (context) => MainScreen(),
          "/locationSetting": (context) => LocationSettingScreen(),
          "/userPostList": (context) => UsersPostsListScreen(),
        },
        initialRoute: "/signin",
        debugShowCheckedModeBanner: false,

        // 2023.08.04, jdk
        // theme의 colorScheme Property를 이용하여 간단하게 팔레트 생성,
        // 이후에 Theme.of(context)를 통해 색상을 꺼내 사용할 수 있도록 만든다.
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlueAccent,
            primaryContainer: Color(0xffE1F5FE),
            onPrimaryContainer: Color(0xff1E88E5),
            secondary: Color(0xff424242),
            secondaryContainer: Color(0xff42A5F5),
            onSecondaryContainer: Colors.white,
          ),
          useMaterial3: true,
        ),
      ),
    );
  }
}
