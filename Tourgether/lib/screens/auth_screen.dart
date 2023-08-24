import 'package:TourGather/providers/user_info_provider.dart';
import 'package:TourGather/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
      ChangeNotifierProvider(
          create: (context) => UserInfoProvider(app_name: "투게더")),
      ], 
      child: LoginRoute());
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
