import 'package:TourGather/providers/gps_provider.dart';
import 'package:TourGather/providers/main_screen_ui_provider.dart';
import 'package:TourGather/providers/user_info_provider.dart';
import 'package:TourGather/providers/user_post_provider.dart';
import 'package:TourGather/screens/location_setting_screen.dart';
import 'package:TourGather/screens/main_screen.dart';
import 'package:TourGather/screens/auth/signin_screen.dart';
import 'package:TourGather/screens/user_post_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

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
        ChangeNotifierProvider(
          create: (context) => UserPostProvider(),
        ),
        ChangeNotifierProvider(
            create: (context) => UserInfoProvider(app_name: "투게더")),
        ], 
      // loginpage or mainpage
      child: MaterialApp(
        routes: {
          "/signin": (context) => const LoginSignupScreen(),
          "/main": (context) => MainScreen(),
          "/locationSetting": (context) => LocationSettingScreen(),
          "/userPostList": (context) => UsersPostsListScreen(),
          "/routeTest" : (context) => AuthScreen()
        },
        initialRoute: "/signin",
        debugShowCheckedModeBanner: false,
      ));
  }
}

class LoginRoute extends StatefulWidget {
  const LoginRoute({super.key});

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<UserInfoProvider>(
          builder: (_, user_info, child) {
            return Container(
              child: LoginSignupScreen(),
            );
          },
        ));
  }
}
