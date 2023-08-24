import 'package:TourGather/providers/user_info_provider.dart';
import 'package:TourGather/screens/signup_verify_screen.dart';
import 'package:TourGather/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:TourGather/main.dart';
import 'package:TourGather/screens/main_screen.dart';
import 'package:provider/provider.dart';

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

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  late bool isSignUpScreen = false;
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  String appTitle = '';
  String userName = '';
  String userPassword = '';
  String userDepartment = '';
  String userStudentNumber = '';
  String userEmail = '';

  void _tryValidation() async {
    // 로그인 인증 부분.
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      // 입력 양식이 올바르지 않을때.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('올바르지 않은 이메일 양식입니다.')));
    } else {
      // onSaved 함수 실행.
      _formKey.currentState!.save();

      // 23.08.12 pjh
      // 로그인 api 전송.
      // 로그인 성공 시 메인페이지로 넘어간다.
      Map<String, dynamic> postData = {};
      postData['email'] = userEmail;
      postData['password'] = userPassword;
      bool isPostSucceeded = await PostServices.postSignin(postData);
      print(isPostSucceeded);

      if (isPostSucceeded) {
        // ----------------------------------------
        // 2023.08.04, jdk
        // 페이지 이동 방식을 named 방식으로 변경,
        // 로그인 페이지로 돌아오는 것을 막기 위하여
        // pushNamedAndRemoveUntil로 변경한다.
        //
        // 메서드의 세 번째 인자를 통해서
        // 내가 지울 Page를 지정할 수 있는 방식인데,
        // callback 함수에 대하여 true를 return하면
        // 현재 widget tree에서 지워지게 된다.
        // (_) => false 로 지정하면 모든 페이지를 지운다.
        // ----------------------------------------
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/main",
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('등록되지 않은 이메일 혹은 비밀번호입니다.')));
      }
    }
  }

  void _trySignup() async {
    _formKey.currentState!.save();
    Map<String, dynamic> postData = {};
    postData['email'] = userEmail;
    print(userEmail);
    PostServices.postSignup(postData);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpVerifyScrren(email: userEmail)));
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
                      child: Consumer<UserInfoProvider>(
                        child: Text(
                          ' 에 오신걸 환영합니다!',
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        builder: (_, provider, child) {
                          return (provider.app_name == "정동교")
                              ? Text(
                                  '동교는 신이야!!',
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  '${provider.app_name}에 오신걸 환영합니다!',
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                );
                        },
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
                      height: isSignUpScreen ? 200.0 : 250.0,
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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSignUpScreen = false;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        '로그인',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: !isSignUpScreen
                                                ? Palette.activeColor
                                                : Palette.textColor1),
                                      ),
                                      if (!isSignUpScreen)
                                        Container(
                                          height: 2,
                                          width: 55,
                                          color: Colors.blueAccent,
                                        )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSignUpScreen = true;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        '회원등록',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isSignUpScreen
                                                ? Palette.activeColor
                                                : Palette.textColor1),
                                      ),
                                      if (isSignUpScreen)
                                        Container(
                                          height: 2,
                                          width: 55,
                                          color: Colors.blueAccent,
                                        )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            if (isSignUpScreen)
                              // 회원가입 스크린
                              (AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                  margin: const EdgeInsets.only(top: 20),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(children: [
                                      TextFormField(
                                          key: const ValueKey(1),
                                          validator: (value) {
                                            if (value!.isEmpty ||
                                                !value.contains('@')) {
                                              print(value);
                                              return 'Please enter a valid email address';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            userEmail = value!;
                                          },
                                          decoration: const InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.mail_rounded,
                                                color: Palette.iconColor,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Palette.textColor1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              35.0))),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Palette.textColor1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              35.0))),
                                              hintText: '학교 이메일',
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.textColor1),
                                              contentPadding:
                                                  EdgeInsets.all(10))),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                    ]),
                                  )))
                            else
                              (Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(children: [
                                      TextFormField(
                                          key: const ValueKey(1),
                                          validator: (value) {
                                            if (value!.isEmpty ||
                                                !value.contains('@')) {
                                              return 'Please enter a valid email address';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            userEmail = value!;
                                          },
                                          decoration: const InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.mail_rounded,
                                                color: Palette.iconColor,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Palette.textColor1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              35.0))),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color:
                                                          Palette.textColor1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              35.0))),
                                              hintText: '학교 이메일',
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.textColor1),
                                              contentPadding:
                                                  EdgeInsets.all(10))),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                          key: const ValueKey(8),
                                          obscureText: !_passwordVisible,
                                          onSaved: (value) {
                                            userPassword = value!;
                                          },
                                          validator: (value) {
                                            if (value!.isEmpty ||
                                                value.length < 4) {
                                              return 'Please enter over 8 length';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              prefixIcon: const Icon(
                                                Icons.lock_rounded,
                                                color: Palette.iconColor,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  size: 20,
                                                  _passwordVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _passwordVisible =
                                                        !_passwordVisible;
                                                  });
                                                },
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Palette
                                                              .textColor1),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  35.0))),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Palette
                                                              .textColor1),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  35.0))),
                                              hintText: '비밀번호',
                                              hintStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.textColor1),
                                              contentPadding:
                                                  const EdgeInsets.all(10))),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                    ]),
                                  )))
                          ],
                        ),
                      ))),
              //텍스트 폼을 위한 포지션
              AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  top: isSignUpScreen ? 340 : 390,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50)),
                      child: GestureDetector(
                        onTap: () {
                          if (isSignUpScreen) {
                            _trySignup();
                          } else {
                            _tryValidation();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.blueAccent, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ]),
                          child: const Icon(
                            size: 25,
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )),
              Positioned(
                  top: MediaQuery.of(context).size.height - 150,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 200,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Consumer<UserInfoProvider>(
                      builder: (_, userinfo, child) {
                        return GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => MainScreen()));
                            userinfo.changeTitle();
                          },
                          child: Center(
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 20),
                            ),
                          ),
                        );
                      },
                    ),
                  )),
            ],
          ),
        ));
  }
}
