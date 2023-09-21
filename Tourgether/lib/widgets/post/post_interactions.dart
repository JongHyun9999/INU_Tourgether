import 'package:TourGather/utilities/color_palette.dart';
import 'package:flutter/material.dart';

// 2023.09.17, jdk
// User_Post_Detail_Screen.dart에서 more_vert를 통해
// 상호작용하는데 필요한 각종 interaction widget들을 정의한 Class.
class PostInteractions {
  PostInteractions(BuildContext inputContext) {
    context = inputContext; // context 초기화

    // interaction 취소 버튼 초기화
    cancelButton = TextButton(
      onPressed: () {
        Navigator.of(context!).pop(false);
      },
      child: Container(
        height: 18,
        child: Text(
          "취소",
          style: TextStyle(
            color: ColorPalette.normalColor,
          ),
        ),
      ),
    );

    // interaction 삭제 버튼 초기화
    continueButton = TextButton(
      onPressed: () {
        Navigator.of(context!).pop(true);
      },
      child: Container(
        height: 18,
        child: Text(
          "삭제",
          style: TextStyle(
            color: ColorPalette.accentColor,
          ),
        ),
      ),
    );

    // interaction AlertDialog 초기화
    postInteractionDialog = AlertDialog(
      title: Text(
        "게시글 삭제",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      content: Container(
        height: 45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "정말로 게시글을 삭제하시겠습니까?",
            ),
            Text(
              "삭제한 게시글은 되돌릴 수 없습니다.",
              style: TextStyle(
                color: ColorPalette.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        cancelButton!,
        continueButton!,
      ],
    );
  }

  BuildContext? context;
  Widget? cancelButton;
  Widget? continueButton;
  AlertDialog? postInteractionDialog;
}
