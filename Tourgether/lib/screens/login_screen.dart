import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("TourGather"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  decoration: const BoxDecoration(
                    // border: Border.all(
                    //   color: Color.fromARGB(255, 255, 255, 255),
                    // ),
                    // boxShadow: const [
                    //   BoxShadow(
                    //     color: Color.fromARGB(255, 255, 255, 255),
                    //     blurRadius: 1.0,
                    //     spreadRadius: 1.0,
                    //   )
                    // ],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    shadows: [
                      Shadow(
                        color: Color.fromARGB(255, 66, 66, 66),
                        offset: Offset(1, 1),
                        blurRadius: 5.0,
                      )
                    ],
                    size: 150,
                    color: Color.fromARGB(255, 57, 147, 221),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: TextFormField(
                      obscureText: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "ID",
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "PW",
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // 2023.07.09, jdk
                          // 이후에 width, height를 화면 높이 비율에 맞춰서 조절되도록 코딩 수정.
                          width: 90,
                          height: 30,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Login Procedure
                              Navigator.pushNamed(
                                context,
                                "/main",
                              );
                            },
                            child: const Text(
                              "Login",
                            ),
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 30,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Register Procedure
                            },
                            child: const Text(
                              "Register",
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
