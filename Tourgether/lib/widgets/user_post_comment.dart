import 'package:flutter/material.dart';

import '../utilities/color_palette.dart';

class UserPostComment extends StatelessWidget {
  const UserPostComment({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 0,
      ),
      child: Flexible(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.8,
              color: ColorPalette.lightGreyColor,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.15,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: Icon(
                      Icons.person,
                      color: ColorPalette.whiteColor,
                    ),
                    backgroundColor: ColorPalette.primaryContainer,
                  ),
                ),
              ),
              // 2023.08.11, jdk
              // Text의 길이에 따라 Widget의 크기가 자동으로 설정되도록 하는 방법.
              // 크기가 바뀌지 않을 다른 Widget들은 크기를 고정시키고,
              // Text의 크기가 늘어날 방향으로 Container의 크기 제한을 없앤 다음
              // Expanded, Flexible, Wrap 등으로 감싸준다.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: Text(
                          "",
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Text(
                          "",
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: screenWidth * 0.1,
                child: Column(
                  children: [
                    // 2023.08.11, jdk
                    // reply 기능은 일시적으로 비활성화
                    // IconButton(
                    //   onPressed: () {},
                    //   icon: Icon(
                    //     Icons.reply,
                    //     size: 20,
                    //     color: ColorPalette.normalColor,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
