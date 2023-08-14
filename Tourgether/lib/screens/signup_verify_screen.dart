import 'package:TourGather/screens/make_user_screen.dart';
import 'package:TourGather/screens/signin_screen.dart';
import 'package:TourGather/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:TourGather/main.dart';
import 'package:TourGather/screens/main_screen.dart';

import '../utilities/color_palette.dart';

class Palette {
  static const Color iconColor = Color(0xFFB6C7D1);
  static const Color activeColor = Color(0xFF09126C);
  static const Color textColor1 = Color(0XFFA7BCC7);
  static const Color textColor2 = Color(0XFF9BB3C0);
  static const Color facebookColor = Color(0xFF3B5999);
  static const Color googleColor = Color(0xFFDE4B39);
  static const Color backgroundColor = Color(0xFFECF3F9);
}

// void main() {
//   runApp(LoginSignupScreen());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'My Map App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       debugShowCheckedModeBanner: false,
//       // home: SafeArea(child: HomePage()),
//       home: LoginSignupScreen(),
//     );
//   }
// }

class SignUpVerifyScrren extends StatefulWidget {
  const SignUpVerifyScrren({super.key, required this.email});
  final String email;

  @override
  State<SignUpVerifyScrren> createState() => _SignUpVerifyScrrenState();
}

class _SignUpVerifyScrrenState extends State<SignUpVerifyScrren> {
  late bool isSignUpScreen = true;
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  String userName = '';
  String userPassword = '';
  String userMajor = '';
  String userEmail = '';

  void _tryValidation() async {
    Map<String, dynamic> postData = {};
    postData['email'] = userEmail;
    bool isPostSucceeded = await PostServices.emailVerify(postData);
    print(isPostSucceeded);

    if (isPostSucceeded) {
      // pjh. 23.08.13
      // 추후에 provider 추가해서 인자로 메일주소 넘길 필요없게 처리해야함.
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   "/addUser",
      //   (_) => false,
      // );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MakeUserScreen(email: userEmail)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증이 완료되지 않았습니다. 이메일을 확인해주세요.')));
    }
  }

  TextEditingController stringController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueAccent,
        body: GestureDetector(
          // 다른 곳 선택 시 소프트 키보드 자동 내림
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Container(
                      padding: EdgeInsets.only(top: 90, left: 20),
                      child: Text(
                        '학교 메일로 전송된 인증번호를 입력해주세요',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              //배경을 위한 포지션
              AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  top: 180,
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      padding: const EdgeInsets.all(20.0),
                      height: 250.0,
                      //mediaQuery가 항상 좌우 픽셀의 40만큼 띄도록 한다
                      width: MediaQuery.of(context).size.width - 40,
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5)
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '메일 인증',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Palette.activeColor),
                                    ),
                                    Container(
                                      height: 2,
                                      width: 300,
                                      color: Colors.blueAccent,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                                margin: const EdgeInsets.only(top: 20),
                                child: Form(
                                  key: _formKey,
                                  child: Column(children: [
                                    TextFormField(
                                        key: const ValueKey(2),
                                        //controller: _userPasswordController,
                                        obscureText: !_passwordVisible,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return '인증번호를 입력하세요.';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          userPassword = value!;
                                        },
                                        decoration: InputDecoration(
                                            prefixIcon: const Icon(
                                              Icons.vpn_key,
                                              color: Palette.iconColor,
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                                    borderSide:
                                                        BorderSide(
                                                            color: Palette
                                                                .textColor1),
                                                    borderRadius: BorderRadius
                                                        .all(Radius
                                                            .circular(35.0))),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                                    borderSide:
                                                        BorderSide(
                                                            color: Palette
                                                                .textColor1),
                                                    borderRadius:
                                                        BorderRadius.all(Radius
                                                            .circular(35.0))),
                                            hintText: '인증코드',
                                            hintStyle: const TextStyle(
                                                fontSize: 14,
                                                color: Palette.textColor1),
                                            contentPadding:
                                                const EdgeInsets.all(10))),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginSignupScreen()));
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_back,
                                                size: 20,
                                              ),
                                              SizedBox(
                                                width: 1,
                                              ),
                                              Text(
                                                '돌아가기',
                                                style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    decoration: TextDecoration
                                                        .underline),
                                              )
                                            ],
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.all(10),
                                              backgroundColor: Colors.white,
                                              elevation: 0),
                                        )
                                      ],
                                    )
                                  ]),
                                )),
                          ],
                        ),
                      ))),
              //텍스트 폼을 위한 포지션
              AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  top: 350,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.pushNamedAndRemoveUntil(
                          //   context,
                          //   "/main",
                          //   (_) => false,
                          // );
                          this.userEmail = widget.email;
                          _tryValidation();
                        },
                        child: Container(
                            width: 300,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 1),
                                  ),
                                ]),
                            child: Center(
                              child: Text(
                                '완료',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            )),
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }
}
