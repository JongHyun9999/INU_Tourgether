import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    const double backgroundImageWidth = 2470;
    const double backgroundImageHeight = 1321;

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: -(backgroundImageWidth / 2 - screenWidth / 2),
              top: -(backgroundImageHeight / 2 - screenHeight / 2),
              child: Container(
                width: backgroundImageWidth,
                height: backgroundImageHeight,
                child: InteractiveViewer(
                  minScale: 1.0,
                  // 2023.07.27, jdk
                  // 지도 위치 조정 과정 확인 필요
                  boundaryMargin: EdgeInsets.fromLTRB(
                    (backgroundImageWidth - screenWidth) / 2,
                    (backgroundImageHeight - screenHeight) / 2,
                    (backgroundImageWidth - screenWidth) / 2,
                    (backgroundImageHeight - screenHeight) / 2,
                  ),
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
                          image: AssetImage("images/test-map4.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: backgroundImageWidth / 2,
                        top: backgroundImageHeight / 2,
                        child: IconButton(
                          icon: Icon(Icons.local_post_office),
                          onPressed: () {
                            print("Touched!");
                          },
                          color: Colors.blueAccent,
                        ),
                      ),
                      Positioned(
                        left: backgroundImageWidth / 2 - 50,
                        top: backgroundImageHeight / 2 + 25,
                        child: IconButton(
                          icon: Icon(Icons.local_post_office),
                          onPressed: () {
                            print("Touched!");
                          },
                          color: Colors.blueAccent,
                        ),
                      ),
                      Positioned(
                        left: backgroundImageWidth / 2 - 80,
                        top: backgroundImageHeight / 2 - 25,
                        child: IconButton(
                          icon: Icon(Icons.local_post_office),
                          onPressed: () {
                            print("Touched!");
                          },
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 25, 0, 0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Color.fromARGB(255, 200, 231, 247),
                        child: IconButton(
                          icon: Icon(
                            Icons.menu,
                          ),
                          onPressed: () {},
                          color: Colors.blueAccent,
                          iconSize: 30,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 25, 10, 0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Color.fromARGB(255, 200, 231, 247),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              "/locationSetting",
                            );
                          },
                          icon: Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                          ),
                          iconSize: 30,
                        ),
                      ),
                    )
                  ],
                ),
                width: screenWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
