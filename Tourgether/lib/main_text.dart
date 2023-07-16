// 메인페이지에서 바로 텍스트 메세지 입력창 버전.

import 'package:flutter/material.dart';
// import 'package:scroll_snap_list/scroll_snap_list.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Map App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _textEditingController = TextEditingController();
  bool _isHintTextVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(20)),
                child: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // GoogleMap(
          //   initialCameraPosition: CameraPosition(
          //     target: LatLng(37.4219999, -122.0840575),
          //     zoom: 15.0,
          //   ),
          // ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('images/ralo.gif'),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      onTap: () {
                        setState(() {
                          _isHintTextVisible = false;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: _isHintTextVisible ? 'What is in your mind?' : '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Color.fromARGB(
                                255, 222, 220, 220), // 연한 색상으로 설정
                            width: 1, // 테두리의 너비 설정
                          ),
                        ),
                      ),
                      // style: TextStyle(
                      //   fontFamily: GoogleFonts.getFont('Lato').fontFamily,
                      // ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      // 메시지 전송 로직 추가
                    },
                  ),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
