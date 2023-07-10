import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Palette {
  static const Color iconColor = Color(0xFFB6C7D1);
  static const Color activeColor = Color(0xFF09126C);
  static const Color textColor1 = Color(0XFFA7BCC7);
  static const Color textColor2 = Color(0XFF9BB3C0);
  static const Color facebookColor = Color(0xFF3B5999);
  static const Color googleColor = Color(0xFFDE4B39);
  static const Color backgroundColor = Color(0xFFECF3F9);
}

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  late bool isSignUpScreen = true;
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  String userName = '';
  String userPassword = '';
  String userDepartment = '';
  String userStudentNumber = '';
  String userEmail = '';
  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  TextEditingController stringController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.backgroundColor,
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
                    height: 300,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('image/purple.png'),
                            fit: BoxFit.fill)),
                    child: Container(
                        padding: const EdgeInsets.only(top: 90, left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                  text: 'Welcome',
                                  style: const TextStyle(
                                      letterSpacing: 1.0,
                                      fontSize: 25,
                                      color: Colors.white),
                                  children: [
                                    TextSpan(
                                      text: isSignUpScreen ? ' ' : ' back!',
                                      style: const TextStyle(
                                          letterSpacing: 1.0,
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (isSignUpScreen)
                                      const TextSpan(
                                        text: 'to ',
                                        style: TextStyle(
                                          letterSpacing: 1.0,
                                          fontSize: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                    if (isSignUpScreen)
                                      const TextSpan(
                                        text: 'Tourgether!',
                                        style: TextStyle(
                                            letterSpacing: 1.0,
                                            fontSize: 25,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                  ]),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              isSignUpScreen
                                  ? 'Signup to Continue'
                                  : 'Signin to Continue',
                              style: const TextStyle(
                                letterSpacing: 1.0,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ))),
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
                      height: isSignUpScreen ? 450.0 : 250.0,
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
                                        'LOGIN',
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
                                          color: Colors.orange,
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
                                        'SIGNUP',
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
                                          color: Colors.orange,
                                        )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            if (isSignUpScreen)
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
                                                value.length < 5) {
                                              return 'Please enter over 5 length';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            userName = value!;
                                          },
                                          decoration: const InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.account_circle,
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
                                              hintText: 'User name',
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.textColor1),
                                              contentPadding:
                                                  EdgeInsets.all(10))),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                          key: const ValueKey(2),
                                          //controller: _userPasswordController,
                                          obscureText: !_passwordVisible,
                                          validator: (value) {
                                            if (value!.isEmpty ||
                                                value.length < 8) {
                                              return 'Please enter over 8 length';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            userPassword = value!;
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
                                              hintText: 'Password',
                                              hintStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.textColor1),
                                              contentPadding:
                                                  const EdgeInsets.all(10))),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                          key: const ValueKey(3),
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.lock_rounded,
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
                                              hintText: 'Password repeat',
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.textColor1),
                                              contentPadding:
                                                  EdgeInsets.all(10))),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                          key: const ValueKey(4),
                                          onSaved: (value) {
                                            userDepartment = value!;
                                          },
                                          decoration: const InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.account_tree,
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
                                              hintText: 'Department',
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.textColor1),
                                              contentPadding:
                                                  EdgeInsets.all(10))),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                          key: const ValueKey(5),
                                          controller: stringController,
                                          validator: (value) {
                                            String checkingString =
                                                stringController.text.trim();
                                            if (value!.isEmpty) {
                                              return 'Please enter all';
                                            }
                                            if (checkingString.isNotEmpty) {
                                              return 'Do not enter String';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            userStudentNumber = value!;
                                          },
                                          decoration: const InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.numbers_rounded,
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
                                              hintText: 'Student Number',
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.textColor1),
                                              contentPadding:
                                                  EdgeInsets.all(10))),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      TextFormField(
                                          key: const ValueKey(6),
                                          validator: (value) {
                                            if (value!.isEmpty ||
                                                value.contains('@')) {
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
                                              hintText: 'E-mail',
                                              hintStyle: TextStyle(
                                                  fontSize: 14,
                                                  color: Palette.textColor1),
                                              contentPadding:
                                                  EdgeInsets.all(10))),
                                    ]),
                                  )))
                            else
                              (Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(children: [
                                      TextFormField(
                                          key: const ValueKey(7),
                                          onSaved: (value) {
                                            userName = value!;
                                          },
                                          validator: (value) {
                                            if (value!.isEmpty ||
                                                value.length < 5) {
                                              return 'Please enter over 5 length';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.account_circle,
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
                                              hintText: 'User name',
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
                                              hintText: 'Password',
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
                  top: isSignUpScreen ? 580 : 390,
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
                          _tryValidation();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.purple, Colors.white],
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
