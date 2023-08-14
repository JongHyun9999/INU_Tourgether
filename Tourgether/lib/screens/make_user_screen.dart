import 'package:TourGather/screens/signin_screen.dart';
import 'package:TourGather/screens/signup_verify_screen.dart';
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

class MakeUserScreen extends StatefulWidget {
  const MakeUserScreen({super.key, required this.email});
  final String email;
  @override
  State<MakeUserScreen> createState() => _MakeUserScreenState();
}

class _MakeUserScreenState extends State<MakeUserScreen> {
  late bool isSignUpScreen = false;
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  String userName = '';
  String userPassword = '';
  String userDepartment = '';
  String userStudentNumber = '';
  String userEmail = '';

  void _tryAddUser() async {
    _formKey.currentState!.save();
    Map<String, dynamic> postData = {};

    List<String> parts = userEmail.split("@");
    postData['uid'] = parts[0];
    postData['email'] = userEmail;
    postData['password'] = userPassword;
    postData['name'] = '정동교입니다';

    await PostServices.postAddUser(postData);

    print('회원가입 성공');
    // pjh. 23.08.13
    // 추후에 provider 추가해서 인자로 메일주소 넘길 필요없게 처리해야함.
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/signin",
      (_) => false,
    );
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => LoginSignupScreen()));
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
                        '투게더에 오신걸 환영합니다!',
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
                                        '비밀번호 생성',
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
                                ),
                              ],
                            ),
                            Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: Form(
                                  key: _formKey,
                                  child: Column(children: [
                                    TextFormField(
                                        key: const ValueKey(8),
                                        obscureText: !_passwordVisible,
                                        onSaved: (value) {
                                          userPassword = value!;
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty ||
                                              value.length < 8) {
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
                                            hintText: '비밀번호',
                                            hintStyle: const TextStyle(
                                                fontSize: 14,
                                                color: Palette.textColor1),
                                            contentPadding:
                                                const EdgeInsets.all(10))),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    TextFormField(
                                        key: const ValueKey(9),
                                        obscureText: !_passwordVisible,
                                        onSaved: (value) {
                                          // userPassword = value!;
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty ||
                                              value.length < 8) {
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
                                            hintText: '비밀번호 재입력',
                                            hintStyle: const TextStyle(
                                                fontSize: 14,
                                                color: Palette.textColor1),
                                            contentPadding:
                                                const EdgeInsets.all(10))),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ]),
                                ))
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
                          this.userEmail = widget.email;
                          _tryAddUser();
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
                  ))
            ],
          ),
        ));
  }
}
